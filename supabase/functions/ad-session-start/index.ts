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

    // 요청 데이터 파싱
    const { ad_unit_id, seq } = await req.json()

    if (!ad_unit_id || !seq) {
      return new Response(
        JSON.stringify({ error: 'ad_unit_id and seq are required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 인증 확인
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Authorization header required' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabase.auth.getUser(token)

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Invalid token' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 사용자 일일 진행 상황 확인
    const today = new Date().toISOString().split('T')[0]
    const { data: progress, error: progressError } = await supabase
      .from('daily_progress')
      .select('ad_claimed_seq')
      .eq('uid', user.id)
      .eq('date', today)
      .single()

    if (progressError && progressError.code !== 'PGRST116') {
      console.error('Progress query error:', progressError)
      return new Response(
        JSON.stringify({ error: 'Failed to check progress' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const currentSeq = progress?.ad_claimed_seq || 0

    // 순차 해금 확인
    if (seq !== currentSeq + 1) {
      return new Response(
        JSON.stringify({ 
          error: 'Invalid sequence',
          expected_seq: currentSeq + 1,
          current_seq: currentSeq
        }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 일일 제한 확인 (최대 10회)
    if (seq > 10) {
      return new Response(
        JSON.stringify({ error: 'Daily limit exceeded' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 1회용 nonce 생성
    const nonce = crypto.randomUUID()
    const expiresAt = new Date(Date.now() + 60 * 1000) // 1분 후 만료

    // 광고 세션 생성
    const { data: session, error: sessionError } = await supabase
      .from('ad_sessions')
      .insert({
        uid: user.id,
        ad_unit_id,
        seq,
        nonce,
        expires_at: expiresAt.toISOString(),
        status: 'issued'
      })
      .select()
      .single()

    if (sessionError) {
      console.error('Session creation error:', sessionError)
      return new Response(
        JSON.stringify({ error: 'Failed to create session' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({
        success: true,
        session_id: session.id,
        nonce: session.nonce,
        expires_at: session.expires_at,
        seq: session.seq
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Ad session start error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
