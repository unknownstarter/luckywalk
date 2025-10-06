// Edge Function: Process Lottery Winners
// Purpose: Calculate winners and update ticket status after lottery draw
// Created: 2025-01-17 01:30:00 KST

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface Ticket {
  id: string
  user_id: string
  ticket_numbers: number[]
  is_winner: boolean
  prize_tier: number
  matched_numbers: number
  prize_amount: number
}

interface LotteryResult {
  total_winners: number
  total_prize_amount: number
  tier_1_winners: number
  tier_1_prize_amount: number
  tier_2_winners: number
  tier_2_prize_amount: number
  tier_3_winners: number
  tier_3_prize_amount: number
  tier_4_winners: number
  tier_4_prize_amount: number
  tier_5_winners: number
  tier_5_prize_amount: number
  tier_6_winners: number
  tier_6_prize_amount: number
}

// Calculate matched numbers between ticket and winning numbers
function calculateMatchedNumbers(ticketNumbers: number[], winningNumbers: number[]): number {
  return ticketNumbers.filter(num => winningNumbers.includes(num)).length
}

// Calculate prize tier based on matched numbers and bonus number
function calculatePrizeTier(
  matchedNumbers: number, 
  bonusNumber: number, 
  ticketNumbers: number[]
): number {
  // 1st place: 6 numbers match
  if (matchedNumbers === 6) {
    return 1
  }
  // 2nd place: 5 numbers match + bonus number
  else if (matchedNumbers === 5 && ticketNumbers.includes(bonusNumber)) {
    return 2
  }
  // 3rd place: 5 numbers match
  else if (matchedNumbers === 5) {
    return 3
  }
  // 4th place: 4 numbers match
  else if (matchedNumbers === 4) {
    return 4
  }
  // 5th place: 3 numbers match
  else if (matchedNumbers === 3) {
    return 5
  }
  // 6th place: 2 numbers match
  else if (matchedNumbers === 2) {
    return 6
  }
  else {
    return 0 // No win
  }
}

// Calculate prize amount based on tier
function calculatePrizeAmount(tier: number): number {
  const prizeAmounts = {
    1: 2000000000, // 20억원
    2: 50000000,   // 5천만원
    3: 1500000,    // 150만원
    4: 50000,      // 5만원
    5: 5000,       // 5천원
    6: 0,          // 0원 (6등은 당첨금 없음)
  }
  return prizeAmounts[tier as keyof typeof prizeAmounts] || 0
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { roundNumber, winningNumbers, bonusNumber } = await req.json()
    
    if (!roundNumber || !winningNumbers || !bonusNumber) {
      return new Response(
        JSON.stringify({ error: 'Missing required parameters' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Initialize Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    // 1. Get lottery round information
    const { data: lotteryRound, error: roundError } = await supabaseClient
      .from('lottery_rounds')
      .select('*')
      .eq('round_number', roundNumber)
      .single()

    if (roundError || !lotteryRound) {
      return new Response(
        JSON.stringify({ error: 'Lottery round not found' }),
        { 
          status: 404, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // 2. Get all tickets for this round
    const { data: tickets, error: ticketsError } = await supabaseClient
      .from('user_tickets')
      .select('*')
      .eq('round_id', lotteryRound.id)

    if (ticketsError) {
      return new Response(
        JSON.stringify({ error: 'Failed to fetch tickets' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // 3. Process each ticket
    const processedTickets: Ticket[] = []
    const lotteryResult: LotteryResult = {
      total_winners: 0,
      total_prize_amount: 0,
      tier_1_winners: 0,
      tier_1_prize_amount: 0,
      tier_2_winners: 0,
      tier_2_prize_amount: 0,
      tier_3_winners: 0,
      tier_3_prize_amount: 0,
      tier_4_winners: 0,
      tier_4_prize_amount: 0,
      tier_5_winners: 0,
      tier_5_prize_amount: 0,
      tier_6_winners: 0,
      tier_6_prize_amount: 0,
    }

    for (const ticket of tickets) {
      const matchedNumbers = calculateMatchedNumbers(ticket.ticket_numbers, winningNumbers)
      const prizeTier = calculatePrizeTier(matchedNumbers, bonusNumber, ticket.ticket_numbers)
      const prizeAmount = calculatePrizeAmount(prizeTier)

      const processedTicket: Ticket = {
        id: ticket.id,
        user_id: ticket.user_id,
        ticket_numbers: ticket.ticket_numbers,
        is_winner: prizeTier > 0,
        prize_tier: prizeTier,
        matched_numbers: matchedNumbers,
        prize_amount: prizeAmount,
      }

      processedTickets.push(processedTicket)

      // Update lottery result statistics
      if (prizeTier > 0) {
        lotteryResult.total_winners++
        lotteryResult.total_prize_amount += prizeAmount

        switch (prizeTier) {
          case 1:
            lotteryResult.tier_1_winners++
            lotteryResult.tier_1_prize_amount += prizeAmount
            break
          case 2:
            lotteryResult.tier_2_winners++
            lotteryResult.tier_2_prize_amount += prizeAmount
            break
          case 3:
            lotteryResult.tier_3_winners++
            lotteryResult.tier_3_prize_amount += prizeAmount
            break
          case 4:
            lotteryResult.tier_4_winners++
            lotteryResult.tier_4_prize_amount += prizeAmount
            break
          case 5:
            lotteryResult.tier_5_winners++
            lotteryResult.tier_5_prize_amount += prizeAmount
            break
          case 6:
            lotteryResult.tier_6_winners++
            lotteryResult.tier_6_prize_amount += prizeAmount
            break
        }
      }
    }

    // 4. Update tickets with winning information
    for (const ticket of processedTickets) {
      const { error: updateError } = await supabaseClient
        .from('user_tickets')
        .update({
          is_winner: ticket.is_winner,
          prize_tier: ticket.prize_tier,
          matched_numbers: ticket.matched_numbers,
          prize_amount: ticket.prize_amount,
          updated_at: new Date().toISOString(),
        })
        .eq('id', ticket.id)

      if (updateError) {
        console.error(`Failed to update ticket ${ticket.id}:`, updateError)
      }
    }

    // 5. Update lottery round with winning numbers
    const { error: roundUpdateError } = await supabaseClient
      .from('lottery_rounds')
      .update({
        winning_numbers: winningNumbers,
        bonus_number: bonusNumber,
        status: 'completed',
        updated_at: new Date().toISOString(),
      })
      .eq('id', lotteryRound.id)

    if (roundUpdateError) {
      console.error('Failed to update lottery round:', roundUpdateError)
    }

    // 6. Create or update lottery results
    const { error: resultError } = await supabaseClient
      .from('lottery_results')
      .upsert({
        round_id: lotteryRound.id,
        ...lotteryResult,
        status: 'completed',
        processed_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })

    if (resultError) {
      console.error('Failed to create lottery results:', resultError)
    }

    // 7. Update user profiles with winning information
    const winningTickets = processedTickets.filter(ticket => ticket.is_winner)
    for (const ticket of winningTickets) {
      const { error: profileError } = await supabaseClient
        .from('user_profiles')
        .update({
          total_tickets_won: supabaseClient.raw('total_tickets_won + 1'),
          total_prize_amount: supabaseClient.raw('total_prize_amount + ?', [ticket.prize_amount]),
          updated_at: new Date().toISOString(),
        })
        .eq('user_id', ticket.user_id)

      if (profileError) {
        console.error(`Failed to update user profile for ${ticket.user_id}:`, profileError)
      }
    }

    return new Response(
      JSON.stringify({ 
        success: true,
        processed_tickets: processedTickets.length,
        total_winners: lotteryResult.total_winners,
        total_prize_amount: lotteryResult.total_prize_amount,
        lottery_result: lotteryResult,
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Process winners error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})
