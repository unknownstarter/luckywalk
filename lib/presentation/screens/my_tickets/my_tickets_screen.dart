import 'package:flutter/material.dart';

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 응모'),
      ),
      body: const Center(
        child: Text('내 응모 화면'),
      ),
    );
  }
}
