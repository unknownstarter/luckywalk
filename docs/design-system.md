꼭 필ㅇ
# LuckyWalk 디자인 시스템

## 🎨 색상 팔레트

### Primary Colors
- **Primary Blue**: `#1E3A8A` - 메인 브랜드 컬러
- **Primary Yellow**: `#FFD700` - 강조 컬러
- **Primary White**: `#FFFFFF` - 배경 및 텍스트
- **Primary Black**: `#000000` - 텍스트

### Secondary Colors
- **Secondary Gray**: `#6B7280` - 보조 텍스트
- **Light Gray**: `#F3F4F6` - 배경
- **Medium Gray**: `#9CA3AF` - 비활성 상태
- **Dark Gray**: `#374151` - 어두운 텍스트

### Status Colors
- **Success Green**: `#10B981` - 성공 상태
- **Error Red**: `#EF4444` - 에러 상태
- **Warning Orange**: `#F59E0B` - 경고 상태
- **Info Blue**: `#3B82F6` - 정보 상태

### Gradient Colors
- **Light Blue**: `#8DCAFF` - 그라데이션 시작
- **Dark Blue**: `#0089FF` - 그라데이션 끝

## 🔤 폰트 시스템

### 폰트 패밀리
- **Baloo**: 로고 및 브랜드 텍스트 전용
- **Pretendard**: 기본 UI 텍스트 (한국어 최적화)

### Pretendard 텍스트 스타일 (기본 UI)
- **Medium 20**: 상단 슬로건 ("매일 걸으면서 받는 공짜 복권")
- **ExtraBold 16**: 서브 텍스트 ("로또6/45 숫자 기반 당첨")
- **ExtraBold 30**: 중간 제목 ("매주 보너스 당첨금")
- **ExtraBold 50**: 대형 금액 표시 ("1,500,000원")
- **Light 12**: 약관 동의 문구
- **SemiBold 18**: 버튼 텍스트

### Baloo 텍스트 스타일 (로고 전용)
- **Bold 36**: 메인 로고 ("LuckyWalk")
- **Bold 50**: 대형 로고 (필요시)

## 🔤 텍스트 스타일 (레거시 - 호환성 유지)

### Headlines
- **Headline 1**: 32px, Bold - 메인 제목
- **Headline 2**: 24px, Bold - 섹션 제목
- **Headline 3**: 20px, SemiBold - 카드 제목

### Body Text
- **Title**: 18px, SemiBold - 카드 제목
- **Subtitle**: 16px, Medium - 부제목
- **Body**: 14px, Regular - 본문
- **Caption**: 12px, Regular - 설명 텍스트

### Special
- **Button**: 16px, SemiBold - 버튼 텍스트
- **Overline**: 10px, Medium, Letter Spacing 1.5 - 라벨

## 🔘 버튼 컴포넌트

### PrimaryButton
```dart
PrimaryButton(
  text: '응모하기',
  onPressed: () {},
  isLoading: false,
  isEnabled: true,
)
```
- **용도**: 메인 액션 (응모하기, 로그인 등)
- **색상**: Primary Blue 배경, White 텍스트
- **크기**: 48px 높이, 12px 둥근 모서리

### SecondaryButton
```dart
SecondaryButton(
  text: '받기',
  onPressed: () {},
  isLoading: false,
  isEnabled: true,
)
```
- **용도**: 보조 액션 (받기, 취소 등)
- **색상**: Gray 배경, White 텍스트
- **크기**: 40px 높이, 8px 둥근 모서리

### StepperButton
```dart
StepperButton(
  icon: Icons.add, // 또는 Icons.remove
  onPressed: () {},
  isEnabled: true,
  size: 32,
)
```
- **용도**: 수량 조절 (+/- 버튼)
- **색상**: Primary Blue 배경, White 아이콘
- **크기**: 32px 원형

## 📦 카드 컴포넌트

### AppCard
```dart
AppCard(
  padding: EdgeInsets.all(16),
  backgroundColor: Colors.white,
  elevation: 2,
  borderRadius: BorderRadius.circular(12),
  child: Widget,
)
```
- **용도**: 콘텐츠 그룹핑
- **스타일**: 12px 둥근 모서리, 2px 그림자
- **패딩**: 기본 16px

## 🏷️ 뱃지 컴포넌트

### AppBadge
```dart
AppBadge(
  text: '3일 남음',
  backgroundColor: AppColors.warningOrange,
  textColor: Colors.white,
  fontSize: 12,
)
```
- **용도**: 상태 표시, 정보 라벨
- **스타일**: 12px 둥근 모서리, 8px 패딩

### CircularBadge
```dart
CircularBadge(
  text: '1',
  backgroundColor: AppColors.primaryBlue,
  textColor: Colors.white,
  size: 32,
)
```
- **용도**: 로또 번호, 순서 표시
- **스타일**: 원형, 32px 크기

## 📱 사용 예시

### 홈 화면 카드
```dart
AppCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(Icons.emoji_events, color: AppColors.primaryBlue),
          SizedBox(width: 8),
          AppText('제목', style: AppTextStyle.subtitle),
          Spacer(),
          AppBadge(text: '상태', backgroundColor: AppColors.warningOrange),
        ],
      ),
      SizedBox(height: 12),
      AppText('설명 텍스트', style: AppTextStyle.body),
      SizedBox(height: 16),
      PrimaryButton(
        text: '액션',
        onPressed: () {},
      ),
    ],
  ),
)
```

### 수량 조절 위젯
```dart
Row(
  children: [
    StepperButton(
      icon: Icons.remove,
      onPressed: () {},
    ),
    SizedBox(width: 16),
    AppText('100', style: AppTextStyle.title),
    SizedBox(width: 16),
    StepperButton(
      icon: Icons.add,
      onPressed: () {},
    ),
  ],
)
```

## 🎯 사용 가이드라인

1. **일관성**: 모든 UI 요소는 이 디자인 시스템을 사용
2. **접근성**: 충분한 대비와 터치 영역 확보
3. **반응성**: 다양한 화면 크기에 대응
4. **성능**: 재사용 가능한 컴포넌트로 빌드 시간 단축

## 🔄 업데이트 이력

- **v1.0.0** (2024-01-XX): 초기 디자인 시스템 구축
  - 기본 색상 팔레트 정의
  - 텍스트 스타일 정의
  - 버튼, 카드, 뱃지 컴포넌트 구현
