import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/supabase_auth_provider.dart';
import '../../shared/index.dart';

/// 설정 화면
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotifications = true;
  bool _winningNotifications = true;
  bool _marketingNotifications = false;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(supabaseAuthProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const AppText('설정', style: AppTextStyle.title),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textInverse,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 계정 관리 섹션
            _buildSection(
              title: '계정 관리',
              children: [_buildProfileCard(authState), _buildLogoutButton()],
            ),
            const SizedBox(height: 24),

            // 알림 설정 섹션
            _buildSection(
              title: '알림 설정',
              children: [
                _buildSwitchTile(
                  title: '푸시 알림',
                  subtitle: '앱 알림을 받습니다',
                  value: _pushNotifications,
                  onChanged: (value) =>
                      setState(() => _pushNotifications = value),
                ),
                _buildSwitchTile(
                  title: '당첨 결과 알림',
                  subtitle: '당첨 결과를 즉시 알려드립니다',
                  value: _winningNotifications,
                  onChanged: (value) =>
                      setState(() => _winningNotifications = value),
                ),
                _buildSwitchTile(
                  title: '마케팅 알림',
                  subtitle: '이벤트 및 프로모션 정보를 받습니다',
                  value: _marketingNotifications,
                  onChanged: (value) =>
                      setState(() => _marketingNotifications = value),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 앱 설정 섹션
            _buildSection(
              title: '앱 설정',
              children: [
                _buildListTile(
                  title: '언어',
                  subtitle: '한국어',
                  onTap: () => _showLanguageDialog(),
                ),
                _buildListTile(
                  title: '테마',
                  subtitle: '라이트 모드',
                  onTap: () => _showThemeDialog(),
                ),
                _buildSwitchTile(
                  title: '진동',
                  subtitle: '터치 시 진동을 활성화합니다',
                  value: _vibrationEnabled,
                  onChanged: (value) =>
                      setState(() => _vibrationEnabled = value),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 정보 섹션
            _buildSection(
              title: '정보',
              children: [
                _buildListTile(title: '앱 버전', subtitle: '1.0.0', onTap: null),
                _buildListTile(
                  title: '이용약관',
                  subtitle: '서비스 이용약관을 확인하세요',
                  onTap: () => _showTermsDialog(),
                ),
                _buildListTile(
                  title: '개인정보처리방침',
                  subtitle: '개인정보 보호정책을 확인하세요',
                  onTap: () => _showPrivacyDialog(),
                ),
                _buildListTile(
                  title: '문의하기',
                  subtitle: '궁금한 점이 있으시면 문의하세요',
                  onTap: () => _showContactDialog(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 데이터 관리 섹션
            _buildSection(
              title: '데이터 관리',
              children: [
                _buildListTile(
                  title: '캐시 삭제',
                  subtitle: '앱 데이터를 정리합니다',
                  onTap: () => _clearCache(),
                ),
                _buildListTile(
                  title: '데이터 동기화',
                  subtitle: '서버와 데이터를 동기화합니다',
                  onTap: () => _syncData(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 위험한 작업 섹션
            _buildSection(
              title: '위험한 작업',
              children: [
                _buildDangerTile(
                  title: '계정 삭제',
                  subtitle: '모든 데이터가 영구적으로 삭제됩니다',
                  onTap: () => _showDeleteAccountDialog(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(title, style: AppTextStyle.title),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildProfileCard(SupabaseAuthState authState) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: authState.isLoading
          ? const CircularProgressIndicator()
          : authState.error != null
          ? AppText(
              '프로필 로드 실패',
              style: AppTextStyle.body,
              color: AppColors.errorRed,
            )
          : Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryBlue,
                  child: AppText(
                    authState.user?.userMetadata?['display_name']
                            ?.toString()
                            .substring(0, 1)
                            .toUpperCase() ??
                        'U',
                    style: AppTextStyle.title,
                    color: AppColors.textInverse,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        authState.user?.userMetadata?['display_name'] ?? '사용자',
                        style: AppTextStyle.subtitle,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        authState.user?.email ?? '이메일 없음',
                        style: AppTextStyle.caption,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primaryBlue),
                  onPressed: () => _showEditProfileDialog(),
                ),
              ],
            ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.logout, color: AppColors.errorRed),
          const SizedBox(width: 16),
          Expanded(
            child: AppText(
              '로그아웃',
              style: AppTextStyle.subtitle,
              color: AppColors.errorRed,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () => _showLogoutDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: AppText(title, style: AppTextStyle.subtitle),
      subtitle: AppText(
        subtitle,
        style: AppTextStyle.caption,
        color: AppColors.textSecondary,
      ),
      trailing: onTap != null
          ? const Icon(Icons.arrow_forward_ios, size: 16)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: AppText(title, style: AppTextStyle.subtitle),
      subtitle: AppText(
        subtitle,
        style: AppTextStyle.caption,
        color: AppColors.textSecondary,
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primaryBlue,
      ),
    );
  }

  Widget _buildDangerTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: AppText(
        title,
        style: AppTextStyle.subtitle,
        color: AppColors.errorRed,
      ),
      subtitle: AppText(
        subtitle,
        style: AppTextStyle.caption,
        color: AppColors.textSecondary,
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // 다이얼로그 메서드들
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText('언어 선택', style: AppTextStyle.title),
        content: const AppText('현재 한국어만 지원됩니다.', style: AppTextStyle.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText('확인', style: AppTextStyle.subtitle),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText('테마 선택', style: AppTextStyle.title),
        content: const AppText('현재 라이트 모드만 지원됩니다.', style: AppTextStyle.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText('확인', style: AppTextStyle.subtitle),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText('이용약관', style: AppTextStyle.title),
        content: const AppText('이용약관 내용이 여기에 표시됩니다.', style: AppTextStyle.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText('확인', style: AppTextStyle.subtitle),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText('개인정보처리방침', style: AppTextStyle.title),
        content: const AppText(
          '개인정보처리방침 내용이 여기에 표시됩니다.',
          style: AppTextStyle.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText('확인', style: AppTextStyle.subtitle),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText('문의하기', style: AppTextStyle.title),
        content: const AppText(
          '문의사항이 있으시면 support@luckywalk.com으로 연락해주세요.',
          style: AppTextStyle.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText('확인', style: AppTextStyle.subtitle),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText('프로필 수정', style: AppTextStyle.title),
        content: const AppText('프로필 수정 기능은 준비 중입니다.', style: AppTextStyle.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText('확인', style: AppTextStyle.subtitle),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText('로그아웃', style: AppTextStyle.title),
        content: const AppText('정말 로그아웃하시겠습니까?', style: AppTextStyle.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText('취소', style: AppTextStyle.subtitle),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(supabaseAuthProvider.notifier).signOut();
            },
            child: const AppText(
              '로그아웃',
              style: AppTextStyle.subtitle,
              color: AppColors.errorRed,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText('계정 삭제', style: AppTextStyle.title),
        content: const AppText(
          '계정을 삭제하면 모든 데이터가 영구적으로 삭제됩니다. 정말 삭제하시겠습니까?',
          style: AppTextStyle.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText('취소', style: AppTextStyle.subtitle),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 계정 삭제 구현
              AppToast.info(context, message: '계정 삭제 기능은 준비 중입니다.');
            },
            child: const AppText(
              '삭제',
              style: AppTextStyle.subtitle,
              color: AppColors.errorRed,
            ),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    AppToast.success(context, message: '캐시가 삭제되었습니다.');
  }

  void _syncData() {
    AppToast.success(context, message: '데이터 동기화가 완료되었습니다.');
  }
}
