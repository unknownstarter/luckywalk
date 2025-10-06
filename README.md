# LuckyWalk

걸어서 받는 무료 복권 앱 - Flutter + Supabase

## 📱 프로젝트 개요

LuckyWalk는 사용자가 매일 걸으면서 무료 복권을 받고, 실제 로또 6/45 번호와 매칭해서 당첨을 확인할 수 있는 모바일 앱입니다.

### 🎯 현재 개발 상태 (2025-01-17)
- ✅ **UI/UX 완성**: Figma 디자인 100% 구현
- ✅ **핵심 정책 구현**: 걸음수/광고/출석체크 보상 시스템
- ✅ **한국 로또 시간 정책**: 실제 로또와 동일한 발표 시간 (토요일 밤 9시)
- ✅ **재사용 가능한 컴포넌트**: AppBottomSheet, RewardCard, LottoInfoCard
- ✅ **권한 관리**: Notification, Activity Recognition 권한 요청
- ✅ **응모하기 플로우 정책**: 5단계 플로우, 시간 검증, 토스트 시스템
- ✅ **Supabase 백엔드 아키텍처**: 11개 테이블, 인증, 로깅, 백오피스 완전 설계
- ✅ **Mock 코드 완전 제거**: 모든 Mock 데이터를 실제 Supabase API로 교체
- ✅ **실제 Supabase API 구현**: 출석체크, 걸음수/광고 보상, 티켓 관리 완전 구현
- ✅ **테스트 화면**: SupabaseApiTestScreen으로 모든 API 테스트 가능
- ✅ **Figma hg5gntf0 채널 화면**: 내 응모, 응모결과, 별들의 전당 화면 구현
- ✅ **설정 화면**: 계정 관리, 앱 설정, 알림 설정, 정보 관리 완전 구현
- ✅ **Apple 로그인 설정**: Apple Developer Console, Supabase Dashboard 완전 설정
- ✅ **보안 강화**: 인앱 관리자 페이지 제거, 환경 변수 보호, 민감한 정보 보호
- ✅ **네비게이션 수정**: 피그마 디자인에 맞게 별들의 전당 진입점 수정
- ⏳ **다음 단계**: 최종 테스트 및 앱 스토어 배포 준비

### 주요 기능
- **걸음수 기반 보상**: 1,000~10,000걸음 달성 시 복권 지급
- **광고 시청 보상**: 1~10번 순차 해금으로 복권 지급
- **출석체크**: 매일 출석체크로 3장 복권 지급
- **친구 초대**: 초대자/피초대자 각 100장 복권 지급
- **실제 로또 매칭**: 실제 로또 6/45 번호와 매칭하여 당첨 결정
- **KYC 제출**: 1,2등 당첨 시 신분증/통장 제출로 당첨금 수령

## 🏗️ 기술 스택

- **Frontend**: Flutter (iOS/Android)
- **Backend**: Supabase (PostgreSQL, Auth, Storage, Edge Functions)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Ads**: Google AdMob
- **Push Notifications**: Firebase FCM
- **Health Data**: HealthKit (iOS) / Google Fit (Android)

## 📁 프로젝트 구조

```
lib/
├── core/                    # 핵심 기능
│   ├── constants/          # 상수
│   ├── env/               # 환경 변수
│   ├── errors/            # 에러 처리
│   ├── utils/             # 유틸리티
│   └── logging/           # 로깅
├── config/                 # 설정
│   ├── flavors/           # 빌드 플레이버
│   └── feature_flags/     # 기능 플래그
├── data/                   # 데이터 레이어
│   ├── datasources/       # 데이터 소스
│   ├── repositories/      # 리포지토리 구현
│   └── models/            # 데이터 모델
├── domain/                 # 도메인 레이어
│   ├── entities/          # 엔티티
│   ├── repositories/      # 리포지토리 인터페이스
│   └── usecases/          # 유스케이스
└── presentation/           # 프레젠테이션 레이어
    ├── routes/            # 라우팅
    ├── features/          # 기능별 화면
    ├── shared/            # 공통 위젯
    └── theme/             # 테마
```

## 🚀 시작하기

### 1. 환경 설정

#### Flutter 환경
```bash
# Flutter SDK 설치 (3.9.2 이상)
flutter --version

# 의존성 설치
flutter pub get
```

#### Supabase 설정
1. [Supabase](https://supabase.com)에서 새 프로젝트 생성
2. `lib/core/env/env.dart`에서 Supabase URL과 API 키 설정
3. 데이터베이스 마이그레이션 실행

```bash
# Supabase CLI 설치
npm install -g supabase

# 프로젝트 초기화
supabase init

# 로컬 개발 환경 시작
supabase start

# 마이그레이션 적용
supabase db push
```

#### Firebase 설정
1. [Firebase Console](https://console.firebase.google.com)에서 프로젝트 생성
2. iOS/Android 앱 등록
3. `google-services.json` (Android) 및 `GoogleService-Info.plist` (iOS) 파일 추가

#### AdMob 설정
1. [AdMob](https://admob.google.com)에서 앱 등록
2. 광고 단위 ID 생성
3. `lib/core/env/env.dart`에서 광고 단위 ID 설정

### 2. 빌드 및 실행

```bash
# 개발 빌드
flutter run

# 릴리즈 빌드 (Android)
flutter build apk --release

# 릴리즈 빌드 (iOS)
flutter build ios --release
```

## 📊 데이터베이스 스키마

### 주요 테이블
- `user_profiles`: 사용자 프로필
- `rounds`: 로또 회차 정보
- `tickets`: 복권 정보
- `daily_progress`: 일일 진행 상황
- `wallets`: 지갑 (보유 복권 수)
- `results_user`: 사용자 당첨 결과
- `kyc_submissions`: KYC 제출 정보

### Edge Functions
- `ad-session-start`: 광고 세션 시작
- `ad-session-complete`: 광고 세션 완료
- `draw-apply-results`: 당첨 결과 적용
- `notify-winners`: 당첨자 알림
- `daily-reset`: 일일 리셋
- `anti-abuse-sweep`: 어뷰징 탐지

## 🔧 개발 가이드

### 코드 생성
```bash
# Riverpod, Freezed, JSON 코드 생성
flutter packages pub run build_runner build --delete-conflicting-outputs

# 코드 생성 감시 모드
flutter packages pub run build_runner watch
```

### 테스트
```bash
# 단위 테스트
flutter test

# 통합 테스트
flutter test integration_test/
```

### 린팅
```bash
# 코드 분석
flutter analyze

# 코드 포맷팅
flutter format .
```

## 📱 주요 화면

### 인증
- **스플래시**: 앱 로딩 화면
- **로그인**: Apple/Kakao OAuth 로그인
- **온보딩**: 권한 요청 및 앱 사용법 안내

### 메인
- **홈**: 보상 수령 및 응모
- **내 응모**: 응모 내역 확인
- **결과**: 당첨 결과 확인
- **설정**: 앱 설정

### 보상
- **광고보상**: 광고 시청으로 복권 지급
- **걸음수보상**: 걸음수 달성으로 복권 지급
- **출석체크**: 일일 출석체크로 복권 지급
- **친구 초대**: 초대로 복권 지급

### 관리
- **어드민**: 관리자 기능
- **회차 관리**: 로또 회차 생성/관리
- **KYC 검토**: 당첨자 KYC 검토

## 🔒 보안 및 컴플라이언스

### 데이터 보호
- **암호화**: 민감 정보 AES-GCM 암호화
- **RLS**: Row Level Security 적용
- **감사 로그**: 모든 관리자 행위 기록

### 어뷰징 방지
- **다중 계정 탐지**: 디바이스 지문 기반
- **비정상 패턴 탐지**: 걸음수/광고 패턴 분석
- **자동 차단**: 임계치 초과 시 자동 차단

## 📈 분석 및 모니터링

### 주요 지표
- **DAU/MAU**: 일일/월간 활성 사용자
- **리텐션**: D1, D7, D30 리텐션
- **참여도**: 보상 수령률, 응모 참여율
- **수익성**: 광고 수익, 당첨금 지급

### 이벤트 추적
- 사용자 행동 이벤트
- 보상 시스템 이벤트
- 응모/결과 이벤트
- 에러/크래시 이벤트

## 🚀 배포

### 스토어 배포
1. **Android**: Google Play Store
2. **iOS**: Apple App Store

### 서버 배포
1. **Supabase**: 프로덕션 프로젝트
2. **Edge Functions**: 자동 배포
3. **Cron Jobs**: 스케줄된 작업

## 📞 지원

### 개발팀
- **이메일**: dev@luckywalk.com
- **슬랙**: #luckywalk-dev

### 문서
- **API 문서**: `/docs/api.md`
- **디자인 가이드**: `/docs/design.md`
- **배포 가이드**: `/docs/deployment.md`

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 변경 로그

### v1.0.0 (2025-01-01)
- 초기 릴리즈
- 기본 보상 시스템 구현
- 실제 로또 매칭 기능
- KYC 제출 시스템
- 어뷰징 방지 시스템