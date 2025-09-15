# LuckyWalk 빠른 참조 가이드

## 🚀 **빠른 시작**

### 프로젝트 실행
```bash
flutter pub get
flutter run
```

### 코드 생성
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🎨 **디자인 시스템 빠른 참조**

### 색상
```dart
AppColors.primaryBlue      // #1E3A8A
AppColors.primaryYellow    // #FFD700
AppColors.successGreen     // #10B981
AppColors.errorRed         // #EF4444
AppColors.warningOrange    // #F59E0B
AppColors.backgroundLight  // #F8FAFC
AppColors.textPrimary      // #111827
AppColors.textSecondary    // #6B7280
```

### 텍스트 스타일
```dart
AppTextStyle.headline1     // 32px, Bold
AppTextStyle.headline2     // 24px, Bold
AppTextStyle.headline3     // 20px, SemiBold
AppTextStyle.title         // 18px, SemiBold
AppTextStyle.subtitle      // 16px, Medium
AppTextStyle.body          // 14px, Regular
AppTextStyle.caption       // 12px, Regular
AppTextStyle.button        // 16px, SemiBold
```

### 컴포넌트
```dart
// 버튼
PrimaryButton(text: '확인', onPressed: () {})
SecondaryButton(text: '취소', onPressed: () {})
StepperButton(icon: Icons.add, onPressed: () {})

// 카드
AppCard(child: Widget)

// 뱃지
AppBadge(text: '상태', backgroundColor: AppColors.warningOrange)
CircularBadge(text: '1', size: 32)

// 텍스트
AppText('제목', style: AppTextStyle.title)
```

## 🔧 **Provider 패턴**

### Mock Provider 사용
```dart
// 데이터 조회
final homeData = ref.watch(mockHomeDataProvider);
final currentRound = homeData['currentRound'] as MockRound;
final userProfile = homeData['userProfile'] as MockUserProfile;

// 액션 실행
ref.read(mockUserProfileProvider.notifier).updateAttendance();
ref.read(mockUserProfileProvider.notifier).claimStepsReward(1000);
ref.read(mockUserProfileProvider.notifier).claimAdReward(1);
```

### AsyncValue 처리
```dart
final data = ref.watch(provider);
return data.when(
  data: (data) => Widget(data),
  loading: () => const CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

## 🧭 **라우팅**

### 네비게이션
```dart
// 기본 네비게이션
context.go('/home');
context.push('/submit');

// 네임드 라우트
context.goNamed('home');
context.pushNamed('submit');

// 파라미터 전달
context.go('/results/123');
context.push('/results/123/kyc');
```

### 가드 사용
```dart
// 인증 필요
AuthGuardWidget(requireAuthenticated: true, child: Widget)

// 온보딩 필요
AuthGuardWidget(requireOnboarding: true, child: Widget)

// 미인증 필요
AuthGuardWidget(requireUnauthenticated: true, child: Widget)
```

## 📱 **화면 구조**

### 기본 스크린 템플릿
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
}
```

## 🎯 **핵심 기능 구현**

### 걸음수 보상
```dart
// 걸음수 확인
final todaySteps = userProfile.todaySteps;

// 보상 받기
ref.read(mockUserProfileProvider.notifier).claimStepsReward(1000);
```

### 광고 보상
```dart
// 광고 시청 완료
ref.read(mockUserProfileProvider.notifier).claimAdReward(1);
```

### 출석체크
```dart
// 출석체크
ref.read(mockUserProfileProvider.notifier).updateAttendance();
```

### 복권 응모
```dart
// 응모하기
ref.read(mockUserProfileProvider.notifier).submitTickets(100);
```

## 🔍 **디버깅**

### 로깅
```dart
import '../../../core/logging/logger.dart';

logger.info('User action', extra: {'userId': userId});
logger.error('API error', error: e, stackTrace: stackTrace);
```

### 에러 처리
```dart
try {
  final result = await apiCall();
  return result;
} catch (e, stackTrace) {
  logger.error('API call failed', error: e, stackTrace: stackTrace);
  rethrow;
}
```

## 📊 **상태 관리**

### 로딩 상태
```dart
final isLoading = ref.watch(provider.select((state) => state.isLoading));
```

### 에러 상태
```dart
final error = ref.watch(provider.select((state) => state.error));
```

### 데이터 업데이트
```dart
ref.read(provider.notifier).updateData(newData);
```

## 🎨 **UI 패턴**

### 카드 레이아웃
```dart
AppCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(Icons.emoji_events, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          const AppText('제목', style: AppTextStyle.subtitle),
          const Spacer(),
          const AppBadge(text: '상태', backgroundColor: AppColors.warningOrange),
        ],
      ),
      const SizedBox(height: 12),
      const AppText('설명', style: AppTextStyle.body),
      const SizedBox(height: 16),
      PrimaryButton(text: '액션', onPressed: () {}),
    ],
  ),
)
```

### 수량 조절
```dart
Row(
  children: [
    StepperButton(icon: Icons.remove, onPressed: () {}),
    const SizedBox(width: 16),
    const AppText('100', style: AppTextStyle.title),
    const SizedBox(width: 16),
    StepperButton(icon: Icons.add, onPressed: () {}),
  ],
)
```

## 🚨 **주의사항**

### 필수 준수
- 모든 UI는 디자인 시스템 컴포넌트 사용
- 하드코딩된 색상/스타일 금지
- 에러 처리 및 로깅 필수
- const 생성자 적극 사용

### 금지 사항
- 하드코딩된 색상값 사용
- 기본 Flutter 위젯 직접 사용
- 에러 처리 없는 API 호출
- 불필요한 setState 호출

## 📚 **유용한 링크**

- [Flutter 공식 문서](https://docs.flutter.dev/)
- [Riverpod 문서](https://riverpod.dev/)
- [GoRouter 문서](https://pub.dev/packages/go_router)
- [Supabase 문서](https://supabase.com/docs)

---

**이 가이드를 참고하여 빠르고 일관된 개발을 진행하세요!** 🚀
