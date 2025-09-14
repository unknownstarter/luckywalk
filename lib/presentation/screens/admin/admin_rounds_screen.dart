import 'package:flutter/material.dart';

class AdminRoundsScreen extends StatelessWidget {
  const AdminRoundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회차 관리'),
      ),
      body: const Center(
        child: Text('회차 관리 화면'),
      ),
    );
  }
}
