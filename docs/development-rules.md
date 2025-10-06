# LuckyWalk 개발 룰 & 가이드라인

**현재 버전**: v2.3.0  
**마지막 업데이트**: 2025-01-17 01:45:00 KST  
**상태**: Supabase 백엔드 아키텍처 완전 설계, 응모하기 플로우 정책 완성, 핵심 정책 구현 완료, 한국 로또 시간 정책 적용, 실제 데이터 연동 준비

> 📋 **룰 히스토리**: `docs/development-rules-history.md` 참조

---

## 🎯 **핵심 원칙**

### 1. **디자인 시스템 우선**
- 모든 UI는 디자인 시스템 컴포넌트 사용
- 하드코딩된 색상, 폰트, 스타일 금지

### 2. **일관성 유지**
- 동일한 기능은 동일한 컴포넌트 사용
- 네이밍 컨벤션 준수

### 3. **재사용성**
- 중복 코드 최소화
- 공통 로직은 Provider나 Service로 분리

---

## 🎨 **UI 개발 룰**

### **컴포넌트 사용**
```dart
// ✅ 좋은 예
AppText('제목', style: AppTextStyle.title)
PrimaryButton(text: '확인', onPressed: () {})
AppCard(child: Widget)

// ❌ 나쁜 예
Text('제목', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
ElevatedButton(onPressed: () {}, child: Text('확인'))
```

### **색상 사용**
```dart
// ✅ 항상 AppColors 사용
backgroundColor: AppColors.primaryBlue
color: AppColors.textPrimary

// ❌ 하드코딩 금지
backgroundColor: Color(0xFF1E3A8A)
```

### **폰트 시스템**
```dart
// ✅ 폰트 패밀리 규칙
// Baloo: 로고 및 브랜드 텍스트 전용
// Pretendard: 기본 UI 텍스트 (한국어 최적화)

// ✅ AppTextStyle 사용
Text('LuckyWalk', style: AppTextStyle.logoMain)  // Baloo Bold 36
Text('매일 걸으면서 받는 공짜 복권', style: AppTextStyle.slogan)  // Pretendard Medium 20
```

---

## 🔧 **코딩 스타일**

### **Import 순서**
```dart
// 1. Flutter/Dart 기본
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 2. 외부 패키지
import 'package:go_router/go_router.dart';

// 3. 내부 모듈 (상대 경로)
import '../../../providers/mock_data_providers.dart';
import '../../shared/index.dart';
```

### **위젯 구조**
```dart
class FeatureScreen extends ConsumerStatefulWidget {
  const FeatureScreen({super.key});

  @override
  ConsumerState<FeatureScreen> createState() => _FeatureScreenState();
}

class _FeatureScreenState extends ConsumerState<FeatureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const AppText('제목', style: AppTextStyle.title),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textInverse,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 구현
          ],
        ),
      ),
    );
  }

  // Private 메서드들
  Widget _buildSection() {
    return AppCard(
      child: Column(
        children: [
          // 구현
        ],
      ),
    );
  }
}
```

### **Provider 사용**
```dart
// ✅ 좋은 예
final data = ref.watch(provider);
ref.read(provider.notifier).updateData();

// ✅ AsyncValue 처리
final data = ref.watch(provider);
return data.when(
  data: (data) => Widget(data),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

---

## 🚀 **Provider 사용**

### **Mock Provider (현재 사용 중)**
```dart
// 데이터 조회
final homeData = ref.watch(mockHomeDataProvider);
final currentRound = homeData['currentRound'] as MockRound;

// 액션 실행
ref.read(mockUserProfileProvider.notifier).updateAttendance();
```

---

## 🎯 **핵심 기능**

### 1. **인증 시스템**
- Mock 인증 (현재)
- Apple/Kakao 로그인 (예정)
- 세션 관리 (30일)

### 2. **보상 시스템**
- 걸음수 기반 보상 (1k~10k 걸음)
- 광고 시청 보상 (순차 해금)
- 출석체크 보상 (일일 1회)

### 3. **복권 시스템**
- 응모 (100장 단위)
- 결과 확인 (토요일 20:50 발표)
- 당첨금 지급 (일요일 12:00)

---

## 🔒 **보안 고려사항**
- KYC 데이터 암호화
- 어뷰징 방지
- 세션 보안
- 입력 검증

---

## 📱 **플랫폼별 고려사항**
- iOS: Safe Area, 네비게이션 바
- Android: Material Design, 뒤로가기 버튼

---

## 🧪 **테스트 전략**
- 단위 테스트: Provider, 모델, 유틸리티
- 위젯 테스트: 컴포넌트, 상호작용
- 통합 테스트: 전체 플로우

---

## 💻 **다른 컴퓨터에서 작업 시**

### **프로젝트 복원 절차**
```bash
# 1. 프로젝트 클론
git clone https://github.com/unknownstarter/luckywalk.git
cd luckywalk

# 2. 의존성 설치
flutter pub get

# 3. iOS 설정 (macOS에서만)
cd ios && pod install && cd ..

# 4. 앱 실행
flutter run
```

### **⚠️ 필수 주의사항**
1. **Flutter SDK 버전**: `flutter --version`으로 동일한 버전 사용
2. **플랫폼별 설치**: iOS (Xcode, CocoaPods), Android (Android Studio, SDK)
3. **환경 변수**: `.env` 파일로 민감한 정보 관리
4. **환경 확인**: `flutter doctor` 실행

### **🚨 문제 해결**
- **Flutter 버전 불일치**: `flutter upgrade`
- **iOS 빌드 실패**: `cd ios && pod install && cd ..`
- **Android 빌드 실패**: `flutter clean && flutter pub get`
- **폰트/에셋 로드 실패**: `flutter clean && flutter pub get`

---

## 📝 **문서화 룰**

### **📅 날짜/시간 기록 규칙 (필수)**
**모든 히스토리나 업데이트 문서에는 반드시 정확한 날짜와 시간을 기록해야 합니다.**

#### **기록 형식**
- **형식**: `YYYY-MM-DD HH:MM:SS KST`
- **예시**: `2025-09-16 00:06:48 KST`
- **시간대**: `KST` (한국 표준시) 사용

#### **기록 대상 문서**
- `docs/development-rules-history.md` - 룰 히스토리
- `docs/development-rules.md` - 개발 룰
- `docs/temporary-removals.md` - 임시 제거 기능
- `docs/design-system.md` - 디자인 시스템
- `docs/project-tasks.md` - 프로젝트 Task 관리
- `.cursorrules` - Cursor AI 룰
- `README.md` - 프로젝트 README

#### **기록 시점**
- **문서 생성 시**: 생성일 기록
- **문서 수정 시**: 마지막 업데이트일 기록
- **버전 업데이트 시**: 버전별 날짜/시간 기록
- **기능 추가/제거 시**: 해당 기능의 날짜/시간 기록

---

## 🚨 **현재 상황별 특별 룰**

### **Mock 데이터 사용 중 (2024-09-15 ~ )**
- ✅ **Firebase 제거**: 크래시 방지를 위해 임시 제거
- ✅ **Google Mobile Ads 제거**: App ID 미설정으로 인한 크래시 방지
- ✅ **Mock Provider 사용**: `mock_auth_provider.dart`, `mock_data_providers.dart`
- ⚠️ **주의사항**: 실제 서비스 배포 전 모든 Mock 데이터 교체 필요

### **디자인 시스템 구축 완료 (2024-09-15)**
- ✅ **컴포넌트 라이브러리**: 버튼, 카드, 뱃지, 텍스트
- ✅ **색상 팔레트**: Primary, Secondary, Status 색상
- ✅ **문서화**: `docs/design-system.md` 완성
- ✅ **Cursor 룰**: `.cursorrules` 파일로 자동 적용

### **코드 품질 개선 완료 (2024-09-15)**
- ✅ **AppTextStyle 충돌 해결**: enum과 class 충돌 문제 해결
- ✅ **Deprecated API 업데이트**: withOpacity, printTime 최신 API로 변경
- ✅ **불필요한 중괄호 제거**: 8개 파일에서 코드 가독성 향상
- ✅ **Async Context 안전성**: BuildContext 사용 시 mounted 체크 추가
- ✅ **빌드 안정성**: 32개 이슈 → 0개 이슈로 해결

---

## 🚨 **중요 알림**

### **필수 준수 사항**
1. **모든 UI는 디자인 시스템 컴포넌트 사용**
2. **하드코딩된 색상/스타일 금지**
3. **일관된 네이밍 컨벤션**
4. **에러 처리 및 로깅 필수**
5. **성능 최적화 고려**
6. **📅 날짜/시간 기록 필수** - 모든 히스토리/업데이트 문서에 정확한 날짜/시간 기록

### **금지 사항**
- 하드코딩된 색상값 사용
- 기본 Flutter 위젯 직접 사용 (디자인 시스템 우회)
- 에러 처리 없는 API 호출
- 불필요한 setState 호출
- 중복 코드 작성
- **날짜/시간 없는 히스토리/업데이트 문서 작성**

---

**업데이트**: 2025-09-16 00:06:48 KST  
**버전**: v2.0.0  
**다음 업데이트 예정**: 2024-09-22