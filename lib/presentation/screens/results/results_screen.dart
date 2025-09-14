import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('응모 결과'),
      ),
      body: const Center(
        child: Text('응모 결과 화면'),
      ),
    );
  }
}
