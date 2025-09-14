import 'package:flutter/material.dart';

class ResultDetailScreen extends StatelessWidget {
  final String roundId;
  
  const ResultDetailScreen({super.key, required this.roundId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('결과 상세'),
      ),
      body: Center(
        child: Text('결과 상세 화면 - 회차: $roundId'),
      ),
    );
  }
}
