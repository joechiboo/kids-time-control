import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/time_control_service.dart';
import '../widgets/circular_timer.dart';
import '../widgets/quick_stats.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TimeControlService _timeService;
  Timer? _timer;
  int _remainingMinutes = 0;
  int _usedMinutes = 0;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    _timeService = context.read<TimeControlService>();

    // Setup callbacks
    _timeService.onUsageUpdate = (minutes) {
      setState(() {
        _usedMinutes = minutes;
        _remainingMinutes = _timeService.remainingMinutes;
      });
    };

    _timeService.onLockStatusChange = (isLocked) {
      setState(() {
        _isLocked = isLocked;
      });

      if (isLocked) {
        _showLockDialog();
      }
    };

    _timeService.onTimeLimitReached = () {
      _showTimeLimitNotification();
    };

    // Update timer every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {
        _remainingMinutes = _timeService.remainingMinutes;
      });
    });

    // Initial values
    _remainingMinutes = _timeService.remainingMinutes;
    _usedMinutes = _timeService.todayUsageMinutes;
    _isLocked = _timeService.isDeviceLocked;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showLockDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('時間到了！'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_clock, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text('今天的螢幕時間已經用完了'),
            Text('去做點其他有趣的事情吧！'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _requestMoreTime,
            child: Text('申請延長時間'),
          ),
          TextButton(
            child: const Text('好的'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showTimeLimitNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('注意！只剩下 5 分鐘了'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: '知道了',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _requestMoreTime() {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('申請延長時間'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('已向家長發送延長時間的申請'),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );

    // Auto close after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '你好！',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      Text(
                        _getGreeting(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF636E72),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Main Timer Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      '今日剩餘時間',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF636E72),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CircularTimer(
                      remainingMinutes: _remainingMinutes,
                      totalMinutes: 120, // Default 2 hours
                      isLocked: _isLocked,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTimeInfo('已使用', '$_usedMinutes 分鐘', Colors.orange),
                        _buildTimeInfo('剩餘', '$_remainingMinutes 分鐘', Colors.green),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Stats
              const Text(
                '今日統計',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 16),
              QuickStats(usageMinutes: _usedMinutes),

              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                '快速操作',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.task_alt,
                      title: '任務',
                      subtitle: '完成任務賺積分',
                      color: const Color(0xFF7C4DFF),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.shopping_bag,
                      title: '商城',
                      subtitle: '兌換獎勵',
                      color: const Color(0xFF4ECDC4),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF7C4DFF),
        unselectedItemColor: const Color(0xFF95A5A6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首頁',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: '任務',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: '積分',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '早安！今天也要合理使用手機哦';
    if (hour < 18) return '午安！記得適度休息眼睛';
    return '晚安！睡前少看螢幕比較好哦';
  }

  Widget _buildTimeInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF95A5A6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF636E72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}