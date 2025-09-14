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
    const { round_id } = await req.json()

    if (!round_id) {
      return new Response(
        JSON.stringify({ error: 'round_id is required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 인증 확인 (관리자만 접근 가능)
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

    // 관리자 권한 확인
    const { data: userRole, error: roleError } = await supabase
      .from('user_roles')
      .select('role')
      .eq('uid', user.id)
      .eq('role', 'admin')
      .single()

    if (roleError || !userRole) {
      return new Response(
        JSON.stringify({ error: 'Admin access required' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 회차 정보 조회
    const { data: round, error: roundError } = await supabase
      .from('rounds')
      .select('*')
      .eq('id', round_id)
      .single()

    if (roundError || !round) {
      return new Response(
        JSON.stringify({ error: 'Round not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (!round.result_nums || round.result_nums.length !== 6) {
      return new Response(
        JSON.stringify({ error: 'Winning numbers not set' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (round.status !== 'scheduled') {
      return new Response(
        JSON.stringify({ error: 'Round already processed' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 해당 회차 복권 조회
    const { data: tickets, error: ticketsError } = await supabase
      .from('tickets')
      .select('*')
      .eq('round_id', round_id)

    if (ticketsError) {
      console.error('Tickets query error:', ticketsError)
      return new Response(
        JSON.stringify({ error: 'Failed to fetch tickets' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (!tickets || tickets.length === 0) {
      return new Response(
        JSON.stringify({ error: 'No tickets found for this round' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 당첨 결과 계산
    const results = calculateWinningResults(tickets, round.result_nums, round.result_bonus)
    
    // 결과 저장
    if (results.length > 0) {
      const { error: insertError } = await supabase
        .from('results_user')
        .insert(results)

      if (insertError) {
        console.error('Results insert error:', insertError)
        return new Response(
          JSON.stringify({ error: 'Failed to save results' }),
          { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
    }

    // 회차 상태 업데이트
    const { error: updateError } = await supabase
      .from('rounds')
      .update({ 
        status: 'drawn',
        updated_at: new Date().toISOString()
      })
      .eq('id', round_id)

    if (updateError) {
      console.error('Round update error:', updateError)
      return new Response(
        JSON.stringify({ error: 'Failed to update round status' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 관리자 액션 로그
    await supabase
      .from('admin_actions')
      .insert({
        admin_uid: user.id,
        action_type: 'draw_apply_results',
        payload: {
          round_id,
          round_no: round.round_no,
          total_tickets: tickets.length,
          winners_count: results.length,
          results_by_tier: getResultsByTier(results)
        },
        ip_address: req.headers.get('x-forwarded-for') || req.headers.get('x-real-ip'),
        created_at: new Date().toISOString()
      })

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Results applied successfully',
        round_id,
        round_no: round.round_no,
        total_tickets: tickets.length,
        winners_count: results.length,
        results_by_tier: getResultsByTier(results),
        timestamp: new Date().toISOString()
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Draw apply results error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

function calculateWinningResults(tickets: any[], winningNumbers: number[], bonusNumber?: number) {
  const results = []
  const tierCounts = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 }

  for (const ticket of tickets) {
    const matches = countMatches(ticket.numbers, winningNumbers)
    const hasBonus = bonusNumber ? ticket.numbers.includes(bonusNumber) : false
    const tier = getTier(matches, hasBonus)
    
    if (tier > 0) {
      tierCounts[tier]++
      results.push({
        uid: ticket.uid,
        round_id: ticket.round_id,
        tier: tier,
        share_amount_krw: calculateShareAmount(tier, tierCounts[tier]),
        kyc_required: tier <= 2,
        kyc_status: tier <= 2 ? 'none' : null,
        created_at: new Date().toISOString()
      })
    }
  }

  return results
}

function countMatches(userNumbers: number[], winningNumbers: number[]): number {
  return userNumbers.filter(num => winningNumbers.includes(num)).length
}

function getTier(matches: number, hasBonus: boolean): number {
  if (matches === 6) return 1
  if (matches === 5 && hasBonus) return 2
  if (matches === 5) return 3
  if (matches === 4) return 4
  if (matches === 3) return 5
  return 0
}

function calculateShareAmount(tier: number, winnerCount: number): number {
  const baseAmounts = { 1: 1000000, 2: 500000, 3: 50, 4: 10, 5: 5 }
  const baseAmount = baseAmounts[tier]
  
  if (tier <= 2) {
    return Math.floor(baseAmount / winnerCount)
  }
  
  return baseAmount
}

function getResultsByTier(results: any[]) {
  const tierCounts = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 }
  
  for (const result of results) {
    tierCounts[result.tier]++
  }
  
  return tierCounts
}
