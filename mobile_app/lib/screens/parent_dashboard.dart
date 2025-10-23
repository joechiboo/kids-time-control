import 'package:flutter/material.dart';

class ParentDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('家長控制面板'),
        backgroundColor: Color(0xFF409EFF),
      ),
      body: Center(
        child: Text(
          '家長控制介面開發中...',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}