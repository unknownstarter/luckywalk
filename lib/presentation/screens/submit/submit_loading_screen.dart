import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/index.dart';

class SubmitLoadingScreen extends StatefulWidget {
  final int ticketCount;

  const SubmitLoadingScreen({
    super.key,
    required this.ticketCount,
  });

  @override
  State<SubmitLoadingScreen> createState() => _SubmitLoadingScreenState();
}

class _SubmitLoadingScreenState extends State<SubmitLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    // 3초 후 다음 화면으로 이동
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/submit/confirm', extra: {
          'ticketCount': widget.ticketCount,
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0088FF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 상태바
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppText(
                      '9:41',
                      style: AppTextStyle.caption,
                      color: Colors.black,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.signal_cellular_4_bar, size: 16),
                        const SizedBox(width: 4),
                        const Icon(Icons.wifi, size: 16),
                        const SizedBox(width: 4),
                        const Icon(Icons.battery_full, size: 16),
                      ],
                    ),
                  ],
                ),
              ),

              // 메인 컨텐츠
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 로딩 애니메이션 (모래시계)
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: const Color(0xFF20C997),
                            borderRadius: BorderRadius.circular(75),
                          ),
                          child: const Icon(
                            Icons.hourglass_empty,
                            size: 80,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // 설명 텍스트
                    AppText(
                      '로또 6/45에 응모할\n복권 ${widget.ticketCount}장을 만들고 있어요!',
                      style: AppTextStyle.headline3,
                      color: Colors.black,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // 광고 영역
              Container(
                margin: const EdgeInsets.all(16),
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF121313),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: AppText(
                    '광고 영역',
                    style: AppTextStyle.caption,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
