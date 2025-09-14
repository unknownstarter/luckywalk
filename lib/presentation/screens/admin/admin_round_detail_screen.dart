import 'package:flutter/material.dart';

class AdminRoundDetailScreen extends StatelessWidget {
  final String roundId;
  
  const AdminRoundDetailScreen({super.key, required this.roundId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회차 상세'),
      ),
      body: Center(
        child: Text('회차 상세 화면 - 회차: $roundId'),
      ),
    );
  }
}
