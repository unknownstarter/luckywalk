# LuckyWalk 개발 룰 & 가이드라인

**현재 버전**: v1.0.0  
**마지막 업데이트**: 2024-09-15  
**상태**: Mock 데이터 사용 중, Firebase/Google Mobile Ads 임시 제거

> 📋 **룰 히스토리**: `docs/development-rules-history.md` 참조

## 🎯 **핵심 원칙**

### 1. **디자인 시스템 우선**
- **모든 UI 요소는 디자인 시스템 컴포넌트 사용**
- 하드코딩된 색상, 폰트, 스타일 금지
- 새로운 컴포넌트가 필요하면 `lib/presentation/shared/components/`에 추가

### 2. **일관성 유지**
- 동일한 기능은 동일한 컴포넌트 사용
- 네이밍 컨벤션 준수
- 파일 구조 일관성 유지

### 3. **재사용성**
- 중복 코드 최소화
- 공통 로직은 Provider나 Service로 분리
- 컴포넌트는 최대한 범용적으로 설계

## 📁 **파일 구조 룰**

### 디렉토리 구조
```
lib/
├── core/                    # 핵심 로직
│   ├── env/                # 환경 변수
│   ├── logging/            # 로깅
│   └── supabase/           # Supabase 설정
├── providers/              # Riverpod Providers
│   ├── mock_*.dart         # Mock 데이터 (개발용)
│   └── supabase_*.dart     # 실제 Supabase 연동
├── presentation/           # UI 레이어
│   ├── shared/             # 공통 컴포넌트
│   │   ├── components/     # UI 컴포넌트
│   │   ├── colors/         # 색상 팔레트
│   │   └── index.dart      # Export 파일
│   ├── screens/            # 화면별 위젯
│   ├── widgets/            # 화면별 위젯
│   ├── routes/             # 라우팅
│   └── theme/              # 테마 설정
└── main.dart
```

### 파일 네이밍
- **스크린**: `{feature}_screen.dart` (예: `home_screen.dart`)
- **위젯**: `{feature}_widget.dart` (예: `round_info_widget.dart`)
- **Provider**: `{feature}_provider.dart` (예: `mock_auth_provider.dart`)
- **모델**: `{feature}_model.dart` (예: `user_model.dart`)

## 🎨 **UI 개발 룰**

### 1. **컴포넌트 사용**
```dart
// ✅ 좋은 예
AppText('제목', style: AppTextStyle.title)
PrimaryButton(text: '확인', onPressed: () {})
AppCard(child: Widget)

// ❌ 나쁜 예
Text('제목', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
ElevatedButton(onPressed: () {}, child: Text('확인'))
Container(decoration: BoxDecoration(...))
```

### 2. **색상 사용**
```dart
// ✅ 좋은 예
backgroundColor: AppColors.primaryBlue
color: AppColors.textPrimary

// ❌ 나쁜 예
backgroundColor: Color(0xFF1E3A8A)
color: Colors.black
```

### 3. **레이아웃**
- `SingleChildScrollView`로 스크롤 가능하게 구성
- `SizedBox`로 간격 조절 (고정값 사용)
- `Spacer()`로 유연한 공간 배치

## 🔧 **코드 스타일 룰**

### 1. **Import 순서**
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

### 2. **위젯 구조**
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
      // 구현
    );
  }

  // Private 메서드들
  Widget _buildSection() {
    return Widget();
  }
}
```

### 3. **Provider 사용**
```dart
// ✅ 좋은 예
final data = ref.watch(provider);
ref.read(provider.notifier).updateData();

// ❌ 나쁜 예
final data = ref.watch(provider).value; // AsyncValue 처리 필요
```

## 🚀 **성능 룰**

### 1. **위젯 최적화**
- `const` 생성자 적극 사용
- `ConsumerWidget` vs `ConsumerStatefulWidget` 적절히 선택
- 불필요한 `setState` 호출 방지

### 2. **메모리 관리**
- `StreamSubscription` 적절히 해제
- `Timer` 정리
- 대용량 데이터 캐싱 고려

## 🧪 **테스트 룰**

### 1. **단위 테스트**
- Provider 로직 테스트
- 유틸리티 함수 테스트
- 모델 클래스 테스트

### 2. **위젯 테스트**
- 컴포넌트 렌더링 테스트
- 사용자 상호작용 테스트
- 상태 변경 테스트

## 📝 **문서화 룰**

### 1. **코드 주석**
```dart
/// 사용자 프로필을 관리하는 Provider
/// 
/// [MockUserProfile]을 반환하며, 로그인 상태에 따라
/// 프로필 정보를 업데이트합니다.
final mockUserProfileProvider = StateNotifierProvider<MockUserProfileNotifier, MockUserProfile>((ref) {
  return MockUserProfileNotifier();
});
```

### 2. **README 업데이트**
- 새로운 기능 추가 시 README 업데이트
- 설정 변경 사항 문서화
- 의존성 변경 사항 기록

## 🔒 **보안 룰**

### 1. **민감한 정보**
- API 키, 시크릿은 환경 변수로 관리
- 하드코딩된 비밀번호 금지
- 사용자 데이터 암호화

### 2. **입력 검증**
- 사용자 입력 항상 검증
- SQL 인젝션 방지
- XSS 공격 방지

## 🐛 **디버깅 룰**

### 1. **로깅**
```dart
// ✅ 좋은 예
logger.info('User login successful', extra: {'userId': userId});
logger.error('API call failed', error: e, stackTrace: stackTrace);

// ❌ 나쁜 예
print('User login successful');
print('Error: $e');
```

### 2. **에러 처리**
```dart
// ✅ 좋은 예
try {
  final result = await apiCall();
  return result;
} catch (e, stackTrace) {
  logger.error('API call failed', error: e, stackTrace: stackTrace);
  rethrow;
}
```

## 📱 **플랫폼별 고려사항**

### 1. **iOS**
- Safe Area 고려
- 네비게이션 바 스타일
- 터치 피드백

### 2. **Android**
- Material Design 가이드라인
- 뒤로가기 버튼 처리
- 상태바 스타일

## 🔄 **Git 룰**

### 1. **커밋 메시지**
```
feat: 새로운 기능 추가
fix: 버그 수정
docs: 문서 업데이트
style: 코드 스타일 변경
refactor: 코드 리팩토링
test: 테스트 추가/수정
chore: 빌드/설정 변경
```

### 2. **브랜치 전략**
- `main`: 프로덕션 준비 코드
- `develop`: 개발 중인 기능
- `feature/기능명`: 새로운 기능 개발
- `hotfix/버그명`: 긴급 버그 수정

## 🎯 **코드 리뷰 체크리스트**

### 필수 확인 사항
- [ ] 디자인 시스템 컴포넌트 사용
- [ ] 하드코딩된 값 없음
- [ ] 에러 처리 구현
- [ ] 로깅 추가
- [ ] 테스트 코드 작성
- [ ] 문서 업데이트
- [ ] 성능 영향 고려
- [ ] 보안 취약점 없음

## 📊 **성능 모니터링**

### 1. **메트릭 추적**
- 앱 시작 시간
- 화면 전환 시간
- API 응답 시간
- 메모리 사용량

### 2. **최적화 목표**
- 앱 시작: < 3초
- 화면 전환: < 300ms
- API 응답: < 2초
- 메모리 사용: < 100MB

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

## 🚨 **중요 알림**

이 룰들은 **강제사항**입니다. 모든 개발자는 이 가이드라인을 따라야 하며, 코드 리뷰 시 이 룰들을 기준으로 검토합니다.

**업데이트**: 2024-09-15  
**버전**: v1.0.0  
**다음 업데이트 예정**: 2024-09-22
