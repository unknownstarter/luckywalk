// Edge Function: Apple Login Authentication
// Purpose: Handle Apple Sign-In and create/update Supabase user
// Created: 2025-01-17 01:30:00 KST

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { verifyAppleToken } from 'https://esm.sh/@supabase/auth-helpers@0.0.1'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface AppleUserInfo {
  sub: string
  email?: string
  email_verified?: boolean
  name?: {
    firstName?: string
    lastName?: string
  }
  given_name?: string
  family_name?: string
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { identityToken, authorizationCode, user } = await req.json()
    
    if (!identityToken) {
      return new Response(
        JSON.stringify({ error: 'Missing identity token' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // 1. Verify Apple identity token
    const appleUser = await verifyAppleToken(identityToken, {
      audience: Deno.env.get('APPLE_CLIENT_ID')!,
      issuer: 'https://appleid.apple.com',
    })

    if (!appleUser) {
      return new Response(
        JSON.stringify({ error: 'Invalid Apple identity token' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // 2. Initialize Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    // 3. Check if user already exists
    const { data: existingUser } = await supabaseClient
      .from('users')
      .select('*')
      .eq('apple_id', appleUser.sub)
      .single()

    let user
    let session

    if (existingUser) {
      // Update existing user
      const { data: updatedUser, error: updateError } = await supabaseClient
        .from('users')
        .update({
          last_login_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        })
        .eq('id', existingUser.id)
        .select()
        .single()

      if (updateError) {
        console.error('Failed to update user:', updateError)
        return new Response(
          JSON.stringify({ error: 'Failed to update user' }),
          { 
            status: 500, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
          }
        )
      }

      user = updatedUser
    } else {
      // Create new user
      const email = appleUser.email || `${appleUser.sub}@apple.temp`
      const password = crypto.randomUUID() // Generate random password

      const { data: authData, error: authError } = await supabaseClient.auth.signUp({
        email,
        password,
        options: {
          data: {
            apple_id: appleUser.sub,
            nickname: appleUser.name ? 
              `${appleUser.name.firstName || ''} ${appleUser.name.lastName || ''}`.trim() :
              appleUser.given_name || 'Apple User',
          }
        }
      })

      if (authError) {
        console.error('Failed to create user:', authError)
        return new Response(
          JSON.stringify({ error: 'Failed to create user' }),
          { 
            status: 500, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
          }
        )
      }

      user = authData.user
      session = authData.session

      // Create user profile
      const nickname = appleUser.name ? 
        `${appleUser.name.firstName || ''} ${appleUser.name.lastName || ''}`.trim() :
        appleUser.given_name || 'Apple User'

      const { error: profileError } = await supabaseClient
        .from('user_profiles')
        .insert({
          user_id: user.id,
          nickname,
        })

      if (profileError) {
        console.error('Failed to create user profile:', profileError)
        // Continue anyway, profile can be created later
      }
    }

    // 4. Log login activity
    if (user) {
      await supabaseClient
        .from('user_activities')
        .insert({
          user_id: user.id,
          activity_type: 'login',
          activity_value: 1,
          activity_data: {
            login_method: 'apple',
            timestamp: new Date().toISOString(),
          },
        })
    }

    return new Response(
      JSON.stringify({ 
        user, 
        session,
        apple_user: {
          id: appleUser.sub,
          email: appleUser.email,
          name: appleUser.name,
        }
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Apple login error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})
