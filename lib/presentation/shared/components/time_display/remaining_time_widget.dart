import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../index.dart';
import '../../../../core/utils/index.dart';

class RemainingTimeWidget extends ConsumerStatefulWidget {
  final bool showSeconds;
  final TextStyle? textStyle;
  final Color? color;

  const RemainingTimeWidget({
    super.key,
    this.showSeconds = false,
    this.textStyle,
    this.color,
  });

  @override
  ConsumerState<RemainingTimeWidget> createState() => _RemainingTimeWidgetState();
}

class _RemainingTimeWidgetState extends ConsumerState<RemainingTimeWidget> {
  Timer? _timer;
  String _remainingTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateTime();
      }
    });
  }

  void _updateTime() {
    setState(() {
      _remainingTime = SubmitPolicy.getRemainingTimeString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppText(
      _remainingTime,
      style: widget.textStyle ?? AppTextStyle.caption,
      color: widget.color ?? AppColors.textSecondary,
    );
  }
}
