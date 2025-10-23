import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircularTimer extends StatelessWidget {
  final int remainingMinutes;
  final int totalMinutes;
  final bool isLocked;

  const CircularTimer({
    Key? key,
    required this.remainingMinutes,
    required this.totalMinutes,
    this.isLocked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = totalMinutes > 0
        ? remainingMinutes / totalMinutes
        : 0.0;

    final hours = remainingMinutes ~/ 60;
    final minutes = remainingMinutes % 60;

    Color progressColor;
    if (isLocked) {
      progressColor = Colors.red;
    } else if (percentage > 0.5) {
      progressColor = Color(0xFF4ECDC4);
    } else if (percentage > 0.2) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return Container(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade100,
            ),
          ),
          // Progress indicator
          CustomPaint(
            size: Size(200, 200),
            painter: CircularProgressPainter(
              progress: percentage,
              color: progressColor,
              strokeWidth: 12,
            ),
          ),
          // Time display
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLocked)
                Icon(
                  Icons.lock,
                  size: 48,
                  color: Colors.red,
                )
              else
                Text(
                  '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
              SizedBox(height: 8),
              Text(
                isLocked ? '已鎖定' : '剩餘時間',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF636E72),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      progressAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}