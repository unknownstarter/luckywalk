import 'package:flutter/material.dart';

class StepsRewardScreen extends StatelessWidget {
  const StepsRewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('걸음수보상'),
      ),
      body: const Center(
        child: Text('걸음수보상 화면'),
      ),
    );
  }
}
