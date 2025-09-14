import 'package:flutter/material.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이용방법'),
      ),
      body: const Center(
        child: Text('이용방법 화면'),
      ),
    );
  }
}
