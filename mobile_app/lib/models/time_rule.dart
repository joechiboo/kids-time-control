import 'dart:convert';

class TimeRule {
  final int dailyLimitMinutes;
  final List<BlockedPeriod> blockedPeriods;
  final Map<String, int> appLimits;

  TimeRule({
    required this.dailyLimitMinutes,
    required this.blockedPeriods,
    required this.appLimits,
  });

  TimeRule copyWith({
    int? dailyLimitMinutes,
    List<BlockedPeriod>? blockedPeriods,
    Map<String, int>? appLimits,
  }) {
    return TimeRule(
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      blockedPeriods: blockedPeriods ?? this.blockedPeriods,
      appLimits: appLimits ?? this.appLimits,
    );
  }

  factory TimeRule.fromJson(String json) {
    final Map<String, dynamic> map = jsonDecode(json);
    return TimeRule(
      dailyLimitMinutes: map['dailyLimitMinutes'] ?? 120,
      blockedPeriods: (map['blockedPeriods'] as List? ?? [])
          .map((p) => BlockedPeriod.fromMap(p))
          .toList(),
      appLimits: Map<String, int>.from(map['appLimits'] ?? {}),
    );
  }

  String toJson() {
    return jsonEncode({
      'dailyLimitMinutes': dailyLimitMinutes,
      'blockedPeriods': blockedPeriods.map((p) => p.toJson()).toList(),
      'appLimits': appLimits,
    });
  }
}

class BlockedPeriod {
  final String startTime; // Format: "HH:MM"
  final String endTime;   // Format: "HH:MM"
  final List<int> weekdays; // 1-7, where 1 is Monday

  BlockedPeriod({
    required this.startTime,
    required this.endTime,
    required this.weekdays,
  });

  bool isActive(DateTime now) {
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final currentWeekday = now.weekday;

    if (!weekdays.contains(currentWeekday)) {
      return false;
    }

    // Simple time comparison (doesn't handle overnight periods)
    return currentTime.compareTo(startTime) >= 0 &&
           currentTime.compareTo(endTime) <= 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'weekdays': weekdays,
    };
  }

  factory BlockedPeriod.fromMap(Map<String, dynamic> map) {
    return BlockedPeriod(
      startTime: map['startTime'] ?? '00:00',
      endTime: map['endTime'] ?? '00:00',
      weekdays: List<int>.from(map['weekdays'] ?? []),
    );
  }
}