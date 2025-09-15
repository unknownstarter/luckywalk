import 'package:flutter/material.dart';

/// 수량 조절을 위한 스테퍼 버튼
class StepperButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;
  final IconData icon;
  final double size;

  const StepperButton({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
    required this.icon,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled 
              ? const Color(0xFF1E3A8A) 
              : const Color(0xFFE5E7EB),
          foregroundColor: isEnabled 
              ? Colors.white 
              : const Color(0xFF9CA3AF),
          shape: const CircleBorder(),
          elevation: isEnabled ? 2 : 0,
          padding: EdgeInsets.zero,
        ),
        child: Icon(
          icon,
          size: 16,
        ),
      ),
    );
  }
}
