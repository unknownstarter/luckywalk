# LuckyWalk 임시 제거/비활성화 기능 목록

**생성일**: 2024-09-15  
**목적**: Mock 데이터 사용 중 임시로 제거된 기능들을 추적하고, 나중에 다시 활성화할 때 참고

---

## 🚨 **임시 제거된 기능들**

### 1. **Google Mobile Ads SDK**
- **제거일**: 2024-09-15
- **제거 이유**: App ID 미설정으로 인한 크래시
- **영향**: 광고 시청 보상 기능 비활성화
- **복구 필요 시점**: 실제 광고 수익화 단계
- **복구 방법**:
  ```yaml
  # pubspec.yaml
  google_mobile_ads: ^4.0.0
  ```
  ```dart
  // main.dart
  import 'package:google_mobile_ads/google_mobile_ads.dart';
  await MobileAds.instance.initialize();
  ```
- **추가 설정 필요**:
  - `ios/Runner/Info.plist`에 AdMob App ID 추가
  - `android/app/src/main/AndroidManifest.xml`에 AdMob App ID 추가

### 2. **Firebase Core**
- **제거일**: 2024-09-15
- **제거 이유**: Mock 데이터 사용 중 불필요
- **영향**: Firebase 서비스 전체 비활성화
- **복구 필요 시점**: 실제 백엔드 연동 단계
- **복구 방법**:
  ```yaml
  # pubspec.yaml
  firebase_core: ^2.24.2
  ```
  ```dart
  // main.dart
  import 'package:firebase_core/firebase_core.dart';
  await Firebase.initializeApp();
  ```

### 3. **Firebase Messaging**
- **제거일**: 2024-09-15
- **제거 이유**: Firebase Core와 함께 제거
- **영향**: 푸시 알림 기능 비활성화
- **복구 필요 시점**: 실제 푸시 알림 구현 단계
- **복구 방법**:
  ```yaml
  # pubspec.yaml
  firebase_messaging: ^14.7.10
  ```
- **추가 설정 필요**:
  - Firebase 프로젝트 설정
  - APNs 인증서 설정
  - FCM 토큰 관리

---

## 🔄 **현재 Mock 사용 중인 기능들**

### 1. **인증 시스템**
- **파일**: `lib/providers/mock_auth_provider.dart`
- **기능**: 로그인/로그아웃, 세션 관리, 네트워크 상태
- **실제 구현 필요 시점**: Supabase Auth 연동
- **대체 예정**: `lib/providers/supabase_auth_provider.dart`

### 2. **사용자 데이터**
- **파일**: `lib/providers/mock_data_providers.dart`
- **기능**: 사용자 프로필, 복권 데이터, 보상 상태
- **실제 구현 필요 시점**: Supabase 데이터베이스 연동
- **대체 예정**: `lib/providers/supabase_data_providers.dart`

### 3. **걸음수 데이터**
- **현재**: Mock 데이터 (고정값)
- **실제 구현 필요 시점**: HealthKit/Google Fit 연동
- **대체 예정**: `health` 패키지 활용

### 4. **광고 보상**
- **현재**: Mock 데이터 (버튼 클릭으로 시뮬레이션)
- **실제 구현 필요 시점**: Google Mobile Ads 재활성화 후
- **대체 예정**: 실제 광고 시청 콜백 연동

---

## 📋 **복구 우선순위**

### **Phase 1: 기본 기능 (우선순위 높음)**
1. **Supabase 연동** - 인증 및 데이터베이스
2. **실제 걸음수 연동** - HealthKit/Google Fit
3. **기본 푸시 알림** - Firebase Messaging

### **Phase 2: 수익화 기능 (우선순위 중간)**
1. **Google Mobile Ads** - 광고 시청 보상
2. **고급 푸시 알림** - 마케팅 알림
3. **분석 도구** - 사용자 행동 추적

### **Phase 3: 고급 기능 (우선순위 낮음)**
1. **실시간 알림** - 복권 결과 알림
2. **지역별 맞춤** - 위치 기반 서비스
3. **소셜 기능** - 친구 초대, 공유

---

## 🔧 **복구 체크리스트**

### **Google Mobile Ads 복구 시**
- [ ] AdMob 계정 생성
- [ ] iOS App ID 설정 (`Info.plist`)
- [ ] Android App ID 설정 (`AndroidManifest.xml`)
- [ ] 테스트 광고 ID 설정
- [ ] 광고 단위 생성
- [ ] 보상 콜백 구현

### **Firebase 복구 시**
- [ ] Firebase 프로젝트 생성
- [ ] iOS 앱 등록
- [ ] Android 앱 등록
- [ ] `google-services.json` (Android) 추가
- [ ] `GoogleService-Info.plist` (iOS) 추가
- [ ] APNs 인증서 설정

### **Supabase 연동 시**
- [ ] Supabase 프로젝트 생성
- [ ] 데이터베이스 스키마 적용
- [ ] RLS 정책 설정
- [ ] Edge Functions 배포
- [ ] 인증 설정 (Apple/Kakao)
- [ ] 환경 변수 설정

---

## 📝 **참고사항**

### **현재 개발 단계**
- **UI/UX 개발 완료** ✅
- **Mock 데이터 연동 완료** ✅
- **디자인 시스템 구축 완료** ✅
- **기본 네비게이션 완료** ✅
- **코드 품질 개선 완료** ✅ (32개 이슈 → 0개 해결)
- **빌드 안정성 확보** ✅

### **다음 개발 단계**
- [ ] 실제 백엔드 연동
- [ ] 실제 데이터 연동
- [ ] 실제 광고 연동
- [ ] 실제 푸시 알림 연동

### **주의사항**
- Mock 데이터는 **개발/테스트 목적**으로만 사용
- 실제 서비스 배포 전 **모든 Mock 데이터를 실제 구현으로 교체** 필요
- 각 기능별로 **단계적 연동** 권장 (한 번에 모든 것을 연동하지 말 것)

---

**마지막 업데이트**: 2024-09-15 (코드 품질 개선 완료)  
**다음 검토 예정일**: 2024-09-22
