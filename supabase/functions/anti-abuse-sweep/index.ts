import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'

serve(async (req) => {
  // CORS 처리
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const results = {
      suspiciousDevices: 0,
      flaggedUsers: 0,
      fakeStepsDetected: 0,
      adFraudDetected: 0,
      totalFlagged: 0
    }

    // 1. 다중 계정 탐지
    const { data: multipleAccounts, error: multiError } = await supabase
      .from('user_profiles')
      .select('device_fingerprint, uid, created_at')
      .not('device_fingerprint', 'is', null)
      .eq('abuse_flag', false)

    if (multiError) {
      console.error('Multiple accounts query error:', multiError)
      return new Response(
        JSON.stringify({ error: 'Failed to check multiple accounts' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 디바이스별 계정 수 계산
    const deviceCounts: { [key: string]: any[] } = {}
    for (const account of multipleAccounts || []) {
      const device = account.device_fingerprint
      if (!deviceCounts[device]) {
        deviceCounts[device] = []
      }
      deviceCounts[device].push(account)
    }

    // 3개 이상 계정이 있는 디바이스 탐지
    const suspiciousDevices = Object.entries(deviceCounts)
      .filter(([_, accounts]) => accounts.length >= 3)
      .map(([device, accounts]) => ({ device, accounts }))

    results.suspiciousDevices = suspiciousDevices.length

    // 어뷰징 플래그 설정
    for (const { device, accounts } of suspiciousDevices) {
      for (const account of accounts) {
        const abuseScore = Math.min(accounts.length * 0.3, 1.0)
        
        const { error: flagError } = await supabase
          .from('user_profiles')
          .update({ 
            abuse_flag: true,
            abuse_reason: 'multiple_accounts',
            abuse_score: abuseScore
          })
          .eq('uid', account.uid)

        if (flagError) {
          console.error('Abuse flag error:', flagError)
        } else {
          results.flaggedUsers++
        }
      }
    }

    // 2. 비정상적인 걸음수 패턴 탐지
    const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]
    
    const { data: suspiciousSteps, error: stepsError } = await supabase
      .from('daily_progress')
      .select(`
        uid,
        step_claimed_flags,
        user_profiles!inner(abuse_flag)
      `)
      .gte('date', sevenDaysAgo)
      .eq('user_profiles.abuse_flag', false)

    if (stepsError) {
      console.error('Suspicious steps query error:', stepsError)
    }

    // 모든 임계값을 매일 달성하는 사용자 탐지
    const userStepPatterns: { [key: string]: number[] } = {}
    
    for (const progress of suspiciousSteps || []) {
      const uid = progress.uid
      if (!userStepPatterns[uid]) {
        userStepPatterns[uid] = []
      }
      
      const flags = progress.step_claimed_flags || {}
      const claimedCount = Object.keys(flags).length
      userStepPatterns[uid].push(claimedCount)
    }

    // 7일 중 5일 이상 모든 임계값 달성하는 사용자 탐지
    for (const [uid, dailyClaims] of Object.entries(userStepPatterns)) {
      const perfectDays = dailyClaims.filter(count => count >= 10).length
      
      if (perfectDays >= 5) {
        const { error: flagError } = await supabase
          .from('user_profiles')
          .update({ 
            abuse_flag: true,
            abuse_reason: 'fake_steps',
            abuse_score: 0.8
          })
          .eq('uid', uid)

        if (flagError) {
          console.error('Abuse flag error:', flagError)
        } else {
          results.fakeStepsDetected++
        }
      }
    }

    // 3. 광고 사기 탐지
    const { data: adSessions, error: adError } = await supabase
      .from('ad_sessions')
      .select(`
        uid,
        status,
        created_at,
        user_profiles!inner(abuse_flag)
      `)
      .gte('created_at', sevenDaysAgo)
      .eq('user_profiles.abuse_flag', false)

    if (adError) {
      console.error('Ad sessions query error:', adError)
    }

    // 사용자별 광고 완료율 계산
    const userAdPatterns: { [key: string]: { total: number, completed: number } } = {}
    
    for (const session of adSessions || []) {
      const uid = session.uid
      if (!userAdPatterns[uid]) {
        userAdPatterns[uid] = { total: 0, completed: 0 }
      }
      
      userAdPatterns[uid].total++
      if (session.status === 'completed') {
        userAdPatterns[uid].completed++
      }
    }

    // 100% 완료율을 가진 사용자 탐지 (의심스러운 패턴)
    for (const [uid, pattern] of Object.entries(userAdPatterns)) {
      if (pattern.total >= 20 && pattern.completed === pattern.total) {
        const { error: flagError } = await supabase
          .from('user_profiles')
          .update({ 
            abuse_flag: true,
            abuse_reason: 'ad_fraud',
            abuse_score: 0.7
          })
          .eq('uid', uid)

        if (flagError) {
          console.error('Abuse flag error:', flagError)
        } else {
          results.adFraudDetected++
        }
      }
    }

    // 4. 어뷰징 탐지 로그
    results.totalFlagged = results.flaggedUsers + results.fakeStepsDetected + results.adFraudDetected

    await supabase
      .from('analytics_events')
      .insert({
        event_name: 'abuse_sweep_completed',
        parameters: {
          suspicious_devices: results.suspiciousDevices,
          flagged_users: results.flaggedUsers,
          fake_steps_detected: results.fakeStepsDetected,
          ad_fraud_detected: results.adFraudDetected,
          total_flagged: results.totalFlagged
        },
        created_at: new Date().toISOString()
      })

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Anti-abuse sweep completed',
        results,
        timestamp: new Date().toISOString()
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Anti-abuse sweep error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
