import 'package:flutter/material.dart';

class KycFormScreen extends StatelessWidget {
  final String roundId;
  
  const KycFormScreen({super.key, required this.roundId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC 제출'),
      ),
      body: Center(
        child: Text('KYC 제출 화면 - 회차: $roundId'),
      ),
    );
  }
}
