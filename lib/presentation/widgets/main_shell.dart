import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _getCurrentIndex(context),
        onTap: (index) => _onTap(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: '응모하기',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: '내 응모',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: '결과',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).subloc;
    switch (location) {
      case '/home':
        return 0;
      case '/submit':
        return 1;
      case '/my-tickets':
        return 2;
      case '/results':
        return 3;
      case '/settings':
        return 4;
      default:
        return 0;
    }
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/submit');
        break;
      case 2:
        context.go('/my-tickets');
        break;
      case 3:
        context.go('/results');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }
}
