# LuckyWalk 잡/크론 설계

## 1. 크론 잡 개요

### 1.1 잡 분류
- **일일 잡**: 매일 00:00 KST 실행
- **주간 잡**: 매주 일요일 12:00 KST 실행
- **실시간 잡**: 토요일 20:50 KST 이후 실행
- **모니터링 잡**: 24시간 주기로 실행

### 1.2 실행 환경
- **플랫폼**: Supabase Edge Functions
- **스케줄러**: Supabase Cron
- **타임존**: Asia/Seoul (KST)
- **실행 주기**: 분, 시, 일, 주 단위

## 2. 일일 잡 (Daily Jobs)

### 2.1 daily_reset
**목적**: 일일 진행 상황 초기화
**실행 시간**: 매일 00:00 KST
**기능**:
- `daily_progress` 테이블 초기화
- `ad_claimed_seq` 0으로 리셋
- `attendance_done` false로 리셋
- `step_claimed_flags` 초기화

```typescript
// supabase/functions/daily-reset/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  try {
    // 일일 진행 상황 초기화
    const { error: progressError } = await supabase
      .from('daily_progress')
      .update({
        step_claimed_flags: {},
        ad_claimed_seq: 0,
        attendance_done: false,
        updated_at: new Date().toISOString()
      })
      .eq('date', new Date().toISOString().split('T')[0])

    if (progressError) {
      console.error('Progress reset error:', progressError)
      return new Response(JSON.stringify({ error: progressError.message }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // 새로운 일일 진행 상황 생성
    const { data: users } = await supabase
      .from('user_profiles')
      .select('uid')

    if (users) {
      const today = new Date().toISOString().split('T')[0]
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
        .upsert(progressData)

      if (insertError) {
        console.error('Progress insert error:', insertError)
      }
    }

    return new Response(JSON.stringify({ 
      success: true, 
      message: 'Daily reset completed',
      timestamp: new Date().toISOString()
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('Daily reset error:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }
})
```

### 2.2 daily_cleanup
**목적**: 임시 데이터 정리
**실행 시간**: 매일 01:00 KST
**기능**:
- 만료된 광고 세션 정리
- 임시 파일 삭제
- 로그 파일 압축

```typescript
// supabase/functions/daily-cleanup/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  try {
    // 만료된 광고 세션 정리
    const { error: sessionError } = await supabase
      .from('ad_sessions')
      .delete()
      .lt('expires_at', new Date().toISOString())

    if (sessionError) {
      console.error('Session cleanup error:', sessionError)
    }

    // 30일 이상된 로그 정리
    const thirtyDaysAgo = new Date()
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)

    const { error: logError } = await supabase
      .from('analytics_events')
      .delete()
      .lt('created_at', thirtyDaysAgo.toISOString())

    if (logError) {
      console.error('Log cleanup error:', logError)
    }

    return new Response(JSON.stringify({ 
      success: true, 
      message: 'Daily cleanup completed',
      timestamp: new Date().toISOString()
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('Daily cleanup error:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }
})
```

## 3. 주간 잡 (Weekly Jobs)

### 3.1 notify_winners
**목적**: 당첨자에게 푸시 알림 발송
**실행 시간**: 매주 일요일 12:00 KST
**기능**:
- 당첨자 조회
- 푸시 알림 발송
- 알림 발송 상태 업데이트

```typescript
// supabase/functions/notify-winners/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  try {
    // 현재 회차 조회
    const { data: currentRound, error: roundError } = await supabase
      .from('rounds')
      .select('*')
      .eq('status', 'drawn')
      .order('created_at', { ascending: false })
      .limit(1)
      .single()

    if (roundError || !currentRound) {
      return new Response(JSON.stringify({ 
        error: 'No drawn round found' 
      }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // 당첨자 조회
    const { data: winners, error: winnersError } = await supabase
      .from('results_user')
      .select(`
        *,
        user_profiles!inner(uid, fcm_token)
      `)
      .eq('round_id', currentRound.id)
      .is('notified_at', null)

    if (winnersError) {
      console.error('Winners query error:', winnersError)
      return new Response(JSON.stringify({ error: winnersError.message }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // 푸시 알림 발송
    const fcmTokens = winners
      ?.filter(w => w.user_profiles?.fcm_token)
      .map(w => w.user_profiles.fcm_token)

    if (fcmTokens && fcmTokens.length > 0) {
      const pushResult = await sendPushNotifications(fcmTokens, {
        title: '🎉 당첨 결과 발표!',
        body: `${currentRound.round_no}회차 당첨 결과를 확인해보세요!`,
        data: {
          type: 'winner_notification',
          round_id: currentRound.id,
          round_number: currentRound.round_no
        }
      })

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
    }

    return new Response(JSON.stringify({ 
      success: true, 
      message: 'Winner notifications sent',
      round_id: currentRound.id,
      winner_count: winners?.length || 0,
      timestamp: new Date().toISOString()
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('Notify winners error:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }
})

async function sendPushNotifications(tokens: string[], payload: any) {
  // Firebase FCM 구현
  const response = await fetch('https://fcm.googleapis.com/fcm/send', {
    method: 'POST',
    headers: {
      'Authorization': `key=${Deno.env.get('FCM_SERVER_KEY')}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      registration_ids: tokens,
      notification: {
        title: payload.title,
        body: payload.body
      },
      data: payload.data
    })
  })

  return await response.json()
}
```

### 3.2 create_new_round
**목적**: 새로운 회차 생성
**실행 시간**: 매주 일요일 12:30 KST
**기능**:
- 새 회차 생성
- 응모 기간 설정
- 발표일 설정

```typescript
// supabase/functions/create-new-round/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  try {
    // 다음 회차 번호 계산
    const { data: lastRound, error: lastRoundError } = await supabase
      .from('rounds')
      .select('round_no')
      .order('round_no', { ascending: false })
      .limit(1)
      .single()

    const nextRoundNo = lastRound ? lastRound.round_no + 1 : 1

    // 발표일 계산 (다음 주 토요일 20:50 KST)
    const nextSaturday = new Date()
    nextSaturday.setDate(nextSaturday.getDate() + (6 - nextSaturday.getDay()))
    nextSaturday.setHours(20, 50, 0, 0)

    // 새 회차 생성
    const { data: newRound, error: createError } = await supabase
      .from('rounds')
      .insert({
        round_no: nextRoundNo,
        draw_datetime: nextSaturday.toISOString(),
        prize_tier1_krw: 1000000,
        prize_tier2_krw: 500000,
        status: 'scheduled',
        created_at: new Date().toISOString()
      })
      .select()
      .single()

    if (createError) {
      console.error('Round creation error:', createError)
      return new Response(JSON.stringify({ error: createError.message }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    return new Response(JSON.stringify({ 
      success: true, 
      message: 'New round created',
      round: newRound,
      timestamp: new Date().toISOString()
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('Create new round error:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }
})
```

## 4. 실시간 잡 (Real-time Jobs)

### 4.1 draw_apply_results
**목적**: 당첨 결과 계산 및 적용
**실행 시점**: 토요일 20:50 KST 이후 (어드민 트리거)
**기능**:
- 당첨 번호와 사용자 복권 매칭
- 등수 계산
- 당첨금 계산
- 결과 저장

```typescript
// supabase/functions/draw-apply-results/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  try {
    const { round_id } = await req.json()

    if (!round_id) {
      return new Response(JSON.stringify({ error: 'Round ID is required' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // 회차 정보 조회
    const { data: round, error: roundError } = await supabase
      .from('rounds')
      .select('*')
      .eq('id', round_id)
      .single()

    if (roundError || !round) {
      return new Response(JSON.stringify({ error: 'Round not found' }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    if (!round.result_nums || round.result_nums.length !== 6) {
      return new Response(JSON.stringify({ error: 'Winning numbers not set' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // 해당 회차 복권 조회
    const { data: tickets, error: ticketsError } = await supabase
      .from('tickets')
      .select('*')
      .eq('round_id', round_id)

    if (ticketsError) {
      console.error('Tickets query error:', ticketsError)
      return new Response(JSON.stringify({ error: ticketsError.message }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // 당첨 결과 계산
    const results = calculateWinningResults(tickets, round.result_nums)
    
    // 결과 저장
    const { error: insertError } = await supabase
      .from('results_user')
      .insert(results)

    if (insertError) {
      console.error('Results insert error:', insertError)
      return new Response(JSON.stringify({ error: insertError.message }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // 회차 상태 업데이트
    const { error: updateError } = await supabase
      .from('rounds')
      .update({ status: 'drawn' })
      .eq('id', round_id)

    if (updateError) {
      console.error('Round update error:', updateError)
    }

    return new Response(JSON.stringify({ 
      success: true, 
      message: 'Results applied successfully',
      round_id: round_id,
      total_tickets: tickets?.length || 0,
      winners_count: results.length,
      timestamp: new Date().toISOString()
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('Draw apply results error:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }
})

function calculateWinningResults(tickets: any[], winningNumbers: number[]) {
  const results = []
  const tierCounts = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 }

  for (const ticket of tickets) {
    const matches = countMatches(ticket.numbers, winningNumbers)
    const tier = getTier(matches)
    
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

function getTier(matches: number): number {
  if (matches === 6) return 1
  if (matches === 5) return 2
  if (matches === 4) return 3
  if (matches === 3) return 4
  if (matches === 2) return 5
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
```

## 5. 모니터링 잡 (Monitoring Jobs)

### 5.1 anti_abuse_sweep
**목적**: 어뷰징 탐지 및 대응
**실행 시간**: 매일 02:00 KST
**기능**:
- 다중 계정 탐지
- 비정상적인 활동 패턴 탐지
- 어뷰징 플래그 설정

```typescript
// supabase/functions/anti-abuse-sweep/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  try {
    // 다중 계정 탐지
    const { data: multipleAccounts, error: multiError } = await supabase
      .from('user_profiles')
      .select('device_fingerprint, uid')
      .not('device_fingerprint', 'is', null)

    if (multiError) {
      console.error('Multiple accounts query error:', multiError)
      return new Response(JSON.stringify({ error: multiError.message }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      })
    }

    // 디바이스별 계정 수 계산
    const deviceCounts = {}
    for (const account of multipleAccounts || []) {
      const device = account.device_fingerprint
      if (!deviceCounts[device]) {
        deviceCounts[device] = []
      }
      deviceCounts[device].push(account.uid)
    }

    // 3개 이상 계정이 있는 디바이스 탐지
    const suspiciousDevices = Object.entries(deviceCounts)
      .filter(([_, uids]) => uids.length >= 3)
      .map(([device, uids]) => ({ device, uids }))

    // 어뷰징 플래그 설정
    for (const { device, uids } of suspiciousDevices) {
      for (const uid of uids) {
        const { error: flagError } = await supabase
          .from('user_profiles')
          .update({ 
            abuse_flag: true,
            abuse_reason: 'multiple_accounts',
            abuse_score: Math.min(uids.length * 0.3, 1.0)
          })
          .eq('uid', uid)

        if (flagError) {
          console.error('Abuse flag error:', flagError)
        }
      }
    }

    // 비정상적인 걸음수 패턴 탐지
    const { data: suspiciousSteps, error: stepsError } = await supabase
      .from('daily_progress')
      .select('uid, step_claimed_flags')
      .gte('date', new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0])

    if (stepsError) {
      console.error('Suspicious steps query error:', stepsError)
    }

    // 모든 임계값을 매일 달성하는 사용자 탐지
    for (const progress of suspiciousSteps || []) {
      const flags = progress.step_claimed_flags || {}
      const claimedCount = Object.keys(flags).length
      
      if (claimedCount >= 10) { // 모든 임계값 달성
        const { error: flagError } = await supabase
          .from('user_profiles')
          .update({ 
            abuse_flag: true,
            abuse_reason: 'fake_steps',
            abuse_score: 0.8
          })
          .eq('uid', progress.uid)

        if (flagError) {
          console.error('Abuse flag error:', flagError)
        }
      }
    }

    return new Response(JSON.stringify({ 
      success: true, 
      message: 'Anti-abuse sweep completed',
      suspicious_devices: suspiciousDevices.length,
      flagged_users: suspiciousDevices.reduce((sum, { uids }) => sum + uids.length, 0),
      timestamp: new Date().toISOString()
    }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('Anti-abuse sweep error:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }
})
```

### 5.2 system_health_check
**목적**: 시스템 상태 모니터링
**실행 시간**: 매시간 00분
**기능**:
- 데이터베이스 연결 상태 확인
- Edge Functions 상태 확인
- 스토리지 상태 확인
- 알림 발송

```typescript
// supabase/functions/system-health-check/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  try {
    const healthChecks = {
      database: false,
      storage: false,
      functions: false,
      timestamp: new Date().toISOString()
    }

    // 데이터베이스 연결 확인
    try {
      const { error: dbError } = await supabase
        .from('user_profiles')
        .select('count')
        .limit(1)
      
      healthChecks.database = !dbError
    } catch (error) {
      console.error('Database health check failed:', error)
    }

    // 스토리지 연결 확인
    try {
      const { error: storageError } = await supabase.storage
        .from('kyc-docs')
        .list('', { limit: 1 })
      
      healthChecks.storage = !storageError
    } catch (error) {
      console.error('Storage health check failed:', error)
    }

    // Functions 상태 확인
    try {
      const response = await fetch(`${Deno.env.get('SUPABASE_URL')}/functions/v1/daily-reset`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')}`
        }
      })
      
      healthChecks.functions = response.ok
    } catch (error) {
      console.error('Functions health check failed:', error)
    }

    // 상태 로깅
    const { error: logError } = await supabase
      .from('system_health_logs')
      .insert({
        health_checks: healthChecks,
        overall_status: Object.values(healthChecks).every(check => 
          typeof check === 'boolean' ? check : true
        ),
        created_at: new Date().toISOString()
      })

    if (logError) {
      console.error('Health log error:', logError)
    }

    return new Response(JSON.stringify(healthChecks), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('System health check error:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }
})
```

## 6. 크론 설정

### 6.1 Supabase Cron 설정
```sql
-- 일일 리셋 (매일 00:00 KST)
SELECT cron.schedule(
  'daily-reset',
  '0 0 * * *',
  'SELECT net.http_post(
    url:='https://your-project.supabase.co/functions/v1/daily-reset',
    headers:='{"Authorization": "Bearer your-service-role-key"}'::jsonb
  );'
);

-- 일일 정리 (매일 01:00 KST)
SELECT cron.schedule(
  'daily-cleanup',
  '0 1 * * *',
  'SELECT net.http_post(
    url:='https://your-project.supabase.co/functions/v1/daily-cleanup',
    headers:='{"Authorization": "Bearer your-service-role-key"}'::jsonb
  );'
);

-- 어뷰징 탐지 (매일 02:00 KST)
SELECT cron.schedule(
  'anti-abuse-sweep',
  '0 2 * * *',
  'SELECT net.http_post(
    url:='https://your-project.supabase.co/functions/v1/anti-abuse-sweep',
    headers:='{"Authorization": "Bearer your-service-role-key"}'::jsonb
  );'
);

-- 당첨자 알림 (매주 일요일 12:00 KST)
SELECT cron.schedule(
  'notify-winners',
  '0 12 * * 0',
  'SELECT net.http_post(
    url:='https://your-project.supabase.co/functions/v1/notify-winners',
    headers:='{"Authorization": "Bearer your-service-role-key"}'::jsonb
  );'
);

-- 새 회차 생성 (매주 일요일 12:30 KST)
SELECT cron.schedule(
  'create-new-round',
  '30 12 * * 0',
  'SELECT net.http_post(
    url:='https://your-project.supabase.co/functions/v1/create-new-round',
    headers:='{"Authorization": "Bearer your-service-role-key"}'::jsonb
  );'
);

-- 시스템 상태 확인 (매시간)
SELECT cron.schedule(
  'system-health-check',
  '0 * * * *',
  'SELECT net.http_post(
    url:='https://your-project.supabase.co/functions/v1/system-health-check',
    headers:='{"Authorization": "Bearer your-service-role-key"}'::jsonb
  );'
);
```

### 6.2 크론 모니터링
```sql
-- 크론 작업 상태 확인
SELECT * FROM cron.job_run_details 
ORDER BY start_time DESC 
LIMIT 10;

-- 실패한 작업 확인
SELECT * FROM cron.job_run_details 
WHERE status = 'failed' 
ORDER BY start_time DESC;
```

## 7. 에러 처리 및 알림

### 7.1 에러 알림
```typescript
async function sendErrorNotification(error: any, jobName: string) {
  const webhookUrl = Deno.env.get('ERROR_WEBHOOK_URL')
  
  if (webhookUrl) {
    await fetch(webhookUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        text: `🚨 Job Error: ${jobName}`,
        attachments: [{
          color: 'danger',
          fields: [{
            title: 'Error',
            value: error.message,
            short: false
          }, {
            title: 'Timestamp',
            value: new Date().toISOString(),
            short: true
          }]
        }]
      })
    })
  }
}
```

### 7.2 재시도 로직
```typescript
async function retryOperation(operation: () => Promise<any>, maxRetries: number = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await operation()
    } catch (error) {
      if (i === maxRetries - 1) {
        throw error
      }
      
      // 지수 백오프
      await new Promise(resolve => setTimeout(resolve, Math.pow(2, i) * 1000))
    }
  }
}
```

## 8. 테스트 및 모니터링

### 8.1 로컬 테스트
```bash
# Edge Function 로컬 테스트
supabase functions serve

# 특정 함수 테스트
curl -X POST http://localhost:54321/functions/v1/daily-reset \
  -H "Authorization: Bearer your-anon-key"
```

### 8.2 프로덕션 모니터링
- **로그 확인**: Supabase Dashboard > Logs
- **메트릭 확인**: Supabase Dashboard > Metrics
- **알림 설정**: Slack/Discord 웹훅 연동
- **대시보드**: Grafana/Prometheus 연동 (옵션)
