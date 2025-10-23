import 'package:flutter/material.dart';

class QuickStats extends StatelessWidget {
  final int usageMinutes;

  const QuickStats({
    super.key,
    required this.usageMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          icon: Icons.videogame_asset,
          title: '遊戲時間',
          value: '${(usageMinutes * 0.4).round()} 分鐘',
          color: const Color(0xFF7C4DFF),
        ),
        _buildStatCard(
          icon: Icons.movie,
          title: '影片時間',
          value: '${(usageMinutes * 0.3).round()} 分鐘',
          color: const Color(0xFFFF6B6B),
        ),
        _buildStatCard(
          icon: Icons.school,
          title: '學習時間',
          value: '${(usageMinutes * 0.2).round()} 分鐘',
          color: const Color(0xFF4ECDC4),
        ),
        _buildStatCard(
          icon: Icons.more_horiz,
          title: '其他',
          value: '${(usageMinutes * 0.1).round()} 分鐘',
          color: const Color(0xFFFFD93D),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF636E72),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}