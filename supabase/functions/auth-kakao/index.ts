// Edge Function: Kakao Login Authentication
// Purpose: Handle Kakao OAuth login and create/update Supabase user
// Created: 2025-01-17 01:30:00 KST

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface KakaoTokenResponse {
  access_token: string
  token_type: string
  refresh_token: string
  expires_in: number
  scope: string
}

interface KakaoUserInfo {
  id: number
  connected_at: string
  properties: {
    nickname: string
    profile_image?: string
    thumbnail_image?: string
  }
  kakao_account: {
    profile_nickname_needs_agreement: boolean
    profile_image_needs_agreement: boolean
    profile: {
      nickname: string
      thumbnail_image_url?: string
      profile_image_url?: string
    }
    has_email: boolean
    email_needs_agreement: boolean
    is_email_valid: boolean
    is_email_verified: boolean
    email?: string
    has_age_range: boolean
    age_range_needs_agreement: boolean
    age_range?: string
    has_birthday: boolean
    birthday_needs_agreement: boolean
    birthday?: string
    birthday_type?: string
    has_gender: boolean
    gender_needs_agreement: boolean
    gender?: string
  }
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { code, redirect_uri } = await req.json()
    
    if (!code || !redirect_uri) {
      return new Response(
        JSON.stringify({ error: 'Missing required parameters' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // 1. Exchange authorization code for access token
    const tokenResponse = await fetch('https://kauth.kakao.com/oauth/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        grant_type: 'authorization_code',
        client_id: Deno.env.get('KAKAO_CLIENT_ID')!,
        client_secret: Deno.env.get('KAKAO_CLIENT_SECRET')!,
        redirect_uri,
        code,
      }),
    })

    if (!tokenResponse.ok) {
      const error = await tokenResponse.text()
      console.error('Kakao token exchange failed:', error)
      return new Response(
        JSON.stringify({ error: 'Failed to exchange authorization code' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    const tokenData: KakaoTokenResponse = await tokenResponse.json()

    // 2. Get user information from Kakao
    const userInfoResponse = await fetch('https://kapi.kakao.com/v2/user/me', {
      headers: {
        'Authorization': `Bearer ${tokenData.access_token}`,
        'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8',
      },
    })

    if (!userInfoResponse.ok) {
      const error = await userInfoResponse.text()
      console.error('Kakao user info fetch failed:', error)
      return new Response(
        JSON.stringify({ error: 'Failed to fetch user information' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    const kakaoUser: KakaoUserInfo = await userInfoResponse.json()

    // 3. Initialize Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    // 4. Check if user already exists
    const { data: existingUser } = await supabaseClient
      .from('users')
      .select('*')
      .eq('kakao_id', kakaoUser.id.toString())
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
      const email = kakaoUser.kakao_account.email || `${kakaoUser.id}@kakao.temp`
      const password = crypto.randomUUID() // Generate random password

      const { data: authData, error: authError } = await supabaseClient.auth.signUp({
        email,
        password,
        options: {
          data: {
            kakao_id: kakaoUser.id.toString(),
            nickname: kakaoUser.properties.nickname,
            profile_image_url: kakaoUser.properties.profile_image,
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
      const { error: profileError } = await supabaseClient
        .from('user_profiles')
        .insert({
          user_id: user.id,
          nickname: kakaoUser.properties.nickname,
          profile_image_url: kakaoUser.properties.profile_image,
          birth_year: kakaoUser.kakao_account.birthday ? 
            new Date(kakaoUser.kakao_account.birthday).getFullYear() : null,
          gender: kakaoUser.kakao_account.gender === 'male' ? 'male' : 
                 kakaoUser.kakao_account.gender === 'female' ? 'female' : 'prefer_not_to_say',
        })

      if (profileError) {
        console.error('Failed to create user profile:', profileError)
        // Continue anyway, profile can be created later
      }
    }

    // 5. Log login activity
    if (user) {
      await supabaseClient
        .from('user_activities')
        .insert({
          user_id: user.id,
          activity_type: 'login',
          activity_value: 1,
          activity_data: {
            login_method: 'kakao',
            timestamp: new Date().toISOString(),
          },
        })
    }

    return new Response(
      JSON.stringify({ 
        user, 
        session,
        kakao_user: {
          id: kakaoUser.id,
          nickname: kakaoUser.properties.nickname,
          profile_image: kakaoUser.properties.profile_image,
        }
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Kakao login error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})
