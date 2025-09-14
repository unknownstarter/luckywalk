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
    const { session_id, nonce, device_id, signature } = await req.json()

    if (!session_id || !nonce || !device_id) {
      return new Response(
        JSON.stringify({ error: 'session_id, nonce, and device_id are required' }),
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

    // 광고 세션 조회
    const { data: session, error: sessionError } = await supabase
      .from('ad_sessions')
      .select('*')
      .eq('id', session_id)
      .eq('uid', user.id)
      .single()

    if (sessionError || !session) {
      return new Response(
        JSON.stringify({ error: 'Session not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 세션 상태 확인
    if (session.status !== 'issued') {
      return new Response(
        JSON.stringify({ error: 'Session already completed or expired' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 만료 시간 확인
    if (new Date() > new Date(session.expires_at)) {
      // 세션 만료 처리
      await supabase
        .from('ad_sessions')
        .update({ status: 'expired' })
        .eq('id', session_id)

      return new Response(
        JSON.stringify({ error: 'Session expired' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // nonce 검증
    if (session.nonce !== nonce) {
      return new Response(
        JSON.stringify({ error: 'Invalid nonce' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 시그니처 검증 (옵션)
    if (signature) {
      const isValidSignature = await verifySignature(session, signature, device_id)
      if (!isValidSignature) {
        return new Response(
          JSON.stringify({ error: 'Invalid signature' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
    }

    // 보상 계산
    const rewardTickets = calculateReward(session.seq)

    // 트랜잭션으로 보상 지급
    const { error: transactionError } = await supabase.rpc('complete_ad_reward', {
      p_session_id: session_id,
      p_uid: user.id,
      p_reward_tickets: rewardTickets,
      p_seq: session.seq
    })

    if (transactionError) {
      console.error('Transaction error:', transactionError)
      return new Response(
        JSON.stringify({ error: 'Failed to process reward' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({
        success: true,
        reward_tickets: rewardTickets,
        seq: session.seq,
        completed_at: new Date().toISOString()
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Ad session complete error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

function calculateReward(seq: number): number {
  if (seq <= 3) return 1
  if (seq <= 6) return 3
  if (seq <= 9) return 5
  if (seq === 10) return 10
  return 0
}

async function verifySignature(session: any, signature: string, deviceId: string): Promise<boolean> {
  // 시그니처 검증 로직 구현
  // 실제 구현에서는 AdMob SDK에서 제공하는 시그니처 검증 사용
  try {
    const expectedSignature = await generateExpectedSignature(session, deviceId)
    return signature === expectedSignature
  } catch (error) {
    console.error('Signature verification error:', error)
    return false
  }
}

async function generateExpectedSignature(session: any, deviceId: string): Promise<string> {
  // 예상 시그니처 생성 로직
  // 실제 구현에서는 AdMob SDK의 시그니처 생성 방식과 일치해야 함
  const data = `${session.id}:${session.nonce}:${deviceId}`
  const encoder = new TextEncoder()
  const dataBuffer = encoder.encode(data)
  const keyBuffer = encoder.encode(Deno.env.get('ADMOB_SECRET_KEY') || '')
  
  const cryptoKey = await crypto.subtle.importKey(
    'raw',
    keyBuffer,
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  )
  
  const signatureBuffer = await crypto.subtle.sign('HMAC', cryptoKey, dataBuffer)
  const signatureArray = new Uint8Array(signatureBuffer)
  return Array.from(signatureArray, byte => byte.toString(16).padStart(2, '0')).join('')
}
