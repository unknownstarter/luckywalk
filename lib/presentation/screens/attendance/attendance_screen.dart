import 'package:flutter/material.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('출석체크'),
      ),
      body: const Center(
        child: Text('출석체크 화면'),
      ),
    );
  }
}
