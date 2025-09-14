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

    const today = new Date().toISOString().split('T')[0]
    const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString().split('T')[0]

    // 1. 기존 일일 진행 상황 초기화
    const { error: progressError } = await supabase
      .from('daily_progress')
      .update({
        step_claimed_flags: {},
        ad_claimed_seq: 0,
        attendance_done: false,
        updated_at: new Date().toISOString()
      })
      .eq('date', today)

    if (progressError) {
      console.error('Progress reset error:', progressError)
      return new Response(
        JSON.stringify({ error: 'Failed to reset progress' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 2. 모든 활성 사용자에 대해 새로운 일일 진행 상황 생성
    const { data: users, error: usersError } = await supabase
      .from('user_profiles')
      .select('uid')
      .eq('abuse_flag', false) // 어뷰징 플래그가 없는 사용자만

    if (usersError) {
      console.error('Users query error:', usersError)
      return new Response(
        JSON.stringify({ error: 'Failed to fetch users' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (users && users.length > 0) {
      const progressData = users.map(user => ({
        uid: user.uid,
        date: today,
        step_claimed_flags: {},
        ad_claimed_seq: 0,
        attendance_done: false,
        created_at: new Date().toISOString()
      }))

      const { error: insertError } = await supabase
        .from('daily_progress')
        .upsert(progressData, { 
          onConflict: 'uid,date',
          ignoreDuplicates: false 
        })

      if (insertError) {
        console.error('Progress insert error:', insertError)
        return new Response(
          JSON.stringify({ error: 'Failed to insert progress' }),
          { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
    }

    // 3. 만료된 광고 세션 정리
    const { error: sessionError } = await supabase
      .from('ad_sessions')
      .update({ status: 'expired' })
      .eq('status', 'issued')
      .lt('expires_at', new Date().toISOString())

    if (sessionError) {
      console.error('Session cleanup error:', sessionError)
    }

    // 4. 일일 리셋 로그
    await supabase
      .from('analytics_events')
      .insert({
        event_name: 'daily_reset',
        parameters: {
          date: today,
          users_count: users?.length || 0,
          reset_type: 'full'
        },
        created_at: new Date().toISOString()
      })

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Daily reset completed',
        date: today,
        users_count: users?.length || 0,
        timestamp: new Date().toISOString()
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Daily reset error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
