import 'package:flutter/material.dart';

class ReferralJoinScreen extends StatelessWidget {
  final String? code;
  
  const ReferralJoinScreen({super.key, this.code});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 초대'),
      ),
      body: Center(
        child: Text('친구 초대 화면 - 코드: ${code ?? "없음"}'),
      ),
    );
  }
}
