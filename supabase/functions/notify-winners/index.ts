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

    // 현재 회차 조회 (상태가 'drawn'인 가장 최근 회차)
    const { data: currentRound, error: roundError } = await supabase
      .from('rounds')
      .select('*')
      .eq('status', 'drawn')
      .order('created_at', { ascending: false })
      .limit(1)
      .single()

    if (roundError || !currentRound) {
      return new Response(
        JSON.stringify({ error: 'No drawn round found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 당첨자 조회 (알림 미발송 대상)
    const { data: winners, error: winnersError } = await supabase
      .from('results_user')
      .select(`
        *,
        user_profiles!inner(uid, fcm_token, nickname)
      `)
      .eq('round_id', currentRound.id)
      .is('notified_at', null)

    if (winnersError) {
      console.error('Winners query error:', winnersError)
      return new Response(
        JSON.stringify({ error: 'Failed to fetch winners' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (!winners || winners.length === 0) {
      return new Response(
        JSON.stringify({ 
          message: 'No winners to notify',
          round_id: currentRound.id,
          round_no: currentRound.round_no
        }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // FCM 토큰이 있는 당첨자만 필터링
    const winnersWithTokens = winners.filter(w => w.user_profiles?.fcm_token)
    
    if (winnersWithTokens.length === 0) {
      return new Response(
        JSON.stringify({ 
          message: 'No winners with FCM tokens',
          round_id: currentRound.id,
          round_no: currentRound.round_no
        }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 푸시 알림 발송
    const pushResult = await sendPushNotifications(winnersWithTokens, currentRound)
    
    // 알림 발송 상태 업데이트
    if (pushResult.success) {
      const { error: updateError } = await supabase
        .from('results_user')
        .update({ notified_at: new Date().toISOString() })
        .eq('round_id', currentRound.id)
        .is('notified_at', null)

      if (updateError) {
        console.error('Notification update error:', updateError)
      }
    }

    // 알림 발송 로그
    await supabase
      .from('analytics_events')
      .insert({
        event_name: 'push_sent',
        parameters: {
          push_type: 'winners',
          round_id: currentRound.id,
          round_number: currentRound.round_no,
          recipient_count: winnersWithTokens.length,
          success_count: pushResult.successCount || 0,
          failure_count: pushResult.failureCount || 0
        },
        created_at: new Date().toISOString()
      })

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Winner notifications sent',
        round_id: currentRound.id,
        round_no: currentRound.round_no,
        total_winners: winners.length,
        notified_winners: winnersWithTokens.length,
        push_result: pushResult,
        timestamp: new Date().toISOString()
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Notify winners error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

async function sendPushNotifications(winners: any[], round: any) {
  const fcmServerKey = Deno.env.get('FCM_SERVER_KEY')
  
  if (!fcmServerKey) {
    console.error('FCM server key not configured')
    return { success: false, error: 'FCM server key not configured' }
  }

  const results = {
    success: true,
    successCount: 0,
    failureCount: 0,
    errors: [] as string[]
  }

  // 배치로 푸시 알림 발송 (최대 1000개씩)
  const batchSize = 1000
  const batches = []
  
  for (let i = 0; i < winners.length; i += batchSize) {
    batches.push(winners.slice(i, i + batchSize))
  }

  for (const batch of batches) {
    try {
      const tokens = batch.map(w => w.user_profiles.fcm_token)
      const response = await fetch('https://fcm.googleapis.com/fcm/send', {
        method: 'POST',
        headers: {
          'Authorization': `key=${fcmServerKey}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          registration_ids: tokens,
          notification: {
            title: '🎉 당첨 결과 발표!',
            body: `${round.round_no}회차 당첨 결과를 확인해보세요!`,
            icon: 'ic_launcher',
            sound: 'default'
          },
          data: {
            type: 'winner_notification',
            round_id: round.id,
            round_number: round.round_no.toString(),
            action: 'view_results'
          },
          priority: 'high'
        })
      })

      const responseData = await response.json()
      
      if (response.ok) {
        results.successCount += responseData.success || 0
        results.failureCount += responseData.failure || 0
        
        if (responseData.results) {
          responseData.results.forEach((result: any, index: number) => {
            if (result.error) {
              results.errors.push(`Token ${index}: ${result.error}`)
            }
          })
        }
      } else {
        results.success = false
        results.errors.push(`FCM API error: ${response.status} ${response.statusText}`)
      }
    } catch (error) {
      results.success = false
      results.errors.push(`Batch send error: ${error.message}`)
    }
  }

  return results
}
