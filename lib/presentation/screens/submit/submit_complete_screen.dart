import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/index.dart';

class SubmitCompleteScreen extends StatefulWidget {
  final int ticketCount;

  const SubmitCompleteScreen({
    super.key,
    required this.ticketCount,
  });

  @override
  State<SubmitCompleteScreen> createState() => _SubmitCompleteScreenState();
}

class _SubmitCompleteScreenState extends State<SubmitCompleteScreen>
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _goToHome() {
    context.go('/home');
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
                    // 성공 애니메이션
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _animation.value,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: const Color(0xFF20C997),
                              borderRadius: BorderRadius.circular(75),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // 성공 메시지
                    AppText(
                      '${widget.ticketCount}장의 복권을 응모했어요!',
                      style: AppTextStyle.headline3,
                      color: Colors.black,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    const AppText(
                      '응모한만큼 당첨될 확률이 올라가요',
                      style: AppTextStyle.body,
                      color: Color(0xFF696969),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // 하단 버튼
              Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _goToHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0088FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const AppText(
                      'Home으로 돌아가기',
                      style: AppTextStyle.button,
                      color: Colors.white,
                    ),
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
