import 'package:flutter/material.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('家長控制面板'),
        backgroundColor: const Color(0xFF409EFF),
      ),
      body: const Center(
        child: Text(
          '家長控制介面開發中...',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}