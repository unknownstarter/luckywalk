import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared/index.dart';
import '../screens/submit/submit_modal_screen.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      body: child,
      bottomNavigationBar: Container(
        height: 96,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: const Color(0xFFD9D9D9), width: 1),
          ),
        ),
        child: Row(
          children: [
            _buildNavItem(
              context: context,
              icon: Icons.home,
              label: 'Home',
              route: '/home',
              isActive: _getCurrentIndex(context) == 0,
            ),
            _buildNavItem(
              context: context,
              icon: Icons.list_alt,
              label: '내 응모',
              route: '/my-tickets',
              isActive: _getCurrentIndex(context) == 1,
            ),
            _buildSubmitButton(context),
            _buildNavItem(
              context: context,
              icon: Icons.emoji_events,
              label: '응모 결과',
              route: '/results',
              isActive: _getCurrentIndex(context) == 2,
            ),
            _buildNavItem(
              context: context,
              icon: Icons.settings,
              label: '설정',
              route: '/settings',
              isActive: _getCurrentIndex(context) == 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
    required bool isActive,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.go(route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primaryBlue : const Color(0xFF9D9D9D),
              size: 24,
            ),
            const SizedBox(height: 4),
            AppText(
              label,
              style: AppTextStyle.caption,
              color: isActive ? AppColors.primaryBlue : const Color(0xFF9D9D9D),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _showSubmitModal(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 4),
            AppText(
              '응모하기',
              style: AppTextStyle.caption,
              color: AppColors.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  void _showSubmitModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SubmitModalScreen(),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    switch (location) {
      case '/home':
        return 0;
      case '/my-tickets':
        return 1;
      case '/results':
        return 2;
      case '/settings':
        return 3;
      default:
        return 0;
    }
  }
}
