import 'dart:async';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/time_rule.dart';
import 'socket_service.dart';

class TimeControlService {
  static const platform = MethodChannel('com.kidstimecontrol/time_control');
  static const eventChannel = EventChannel('com.kidstimecontrol/events');

  final SocketService _socketService;
  late SharedPreferences _prefs;
  late StreamSubscription _eventSubscription;

  // Current state
  TimeRule? _currentRule;
  int _todayUsageMinutes = 0;
  bool _isDeviceLocked = false;
  Timer? _usageTimer;

  // Callbacks
  Function(int)? onUsageUpdate;
  Function(bool)? onLockStatusChange;
  Function()? onTimeLimitReached;

  TimeControlService(this._socketService);

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    // Setup platform channel handlers
    platform.setMethodCallHandler(_handleMethod);

    // Listen to native events
    _eventSubscription = eventChannel.receiveBroadcastStream().listen(_handleEvent);

    // Start usage tracking
    _startUsageTracking();

    // Load saved rules
    await loadTimeRules();

    // Check and enable accessibility service if needed
    await checkAccessibilityService();
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'requestMoreTime':
        return _handleMoreTimeRequest();
      case 'updateUsage':
        final minutes = call.arguments['minutes'] as int;
        _updateUsage(minutes);
        break;
      case 'lockDevice':
        await lockDevice(call.arguments['reason']);
        break;
      case 'unlockDevice':
        await unlockDevice();
        break;
    }
  }

  void _handleEvent(dynamic event) {
    if (event is Map) {
      switch (event['type']) {
        case 'usage_update':
          _todayUsageMinutes = event['minutes'] ?? 0;
          onUsageUpdate?.call(_todayUsageMinutes);
          _checkTimeLimit();
          break;
        case 'blocking_status':
          _isDeviceLocked = event['is_blocking'] ?? false;
          onLockStatusChange?.call(_isDeviceLocked);
          break;
        case 'request_more_time':
          _handleMoreTimeRequest();
          break;
      }
    }
  }

  Future<void> checkAccessibilityService() async {
    try {
      final bool isEnabled = await platform.invokeMethod('isAccessibilityEnabled');
      if (!isEnabled) {
        // Prompt user to enable
        await promptEnableAccessibility();
      }
    } catch (e) {
      print('Error checking accessibility: $e');
    }
  }

  Future<void> promptEnableAccessibility() async {
    try {
      await platform.invokeMethod('openAccessibilitySettings');
    } catch (e) {
      print('Error opening settings: $e');
    }
  }

  Future<void> loadTimeRules() async {
    // Load from server or local storage
    final ruleData = _prefs.getString('time_rule');
    if (ruleData != null) {
      _currentRule = TimeRule.fromJson(ruleData);
      await _applyRule(_currentRule!);
    }
  }

  Future<void> _applyRule(TimeRule rule) async {
    try {
      // Send rule to native service
      await platform.invokeMethod('setTimeRule', {
        'dailyLimitMinutes': rule.dailyLimitMinutes,
        'blockedPeriods': rule.blockedPeriods.map((p) => p.toJson()).toList(),
        'appLimits': rule.appLimits,
      });

      // Save locally
      await _prefs.setString('time_rule', rule.toJson());

      // Update native SharedPreferences
      await _prefs.setInt('daily_limit_minutes', rule.dailyLimitMinutes);
    } catch (e) {
      print('Error applying rule: $e');
    }
  }

  void _startUsageTracking() {
    _usageTimer = Timer.periodic(Duration(minutes: 1), (_) {
      _checkTimeLimit();
      _sendUsageToServer();
    });
  }

  void _checkTimeLimit() {
    if (_currentRule == null) return;

    // Check if daily limit reached
    if (_todayUsageMinutes >= _currentRule!.dailyLimitMinutes) {
      if (!_isDeviceLocked) {
        onTimeLimitReached?.call();
        lockDevice('Daily time limit reached');
      }
    }

    // Check if in blocked period
    if (_isInBlockedPeriod()) {
      if (!_isDeviceLocked) {
        lockDevice('Blocked time period');
      }
    }
  }

  bool _isInBlockedPeriod() {
    if (_currentRule == null) return false;

    final now = DateTime.now();
    for (final period in _currentRule!.blockedPeriods) {
      if (period.isActive(now)) {
        return true;
      }
    }
    return false;
  }

  Future<void> lockDevice(String reason) async {
    try {
      _isDeviceLocked = true;
      await _prefs.setBool('device_locked', true);

      // Notify native service
      await platform.invokeMethod('lockDevice', {'reason': reason});

      // Notify server
      _socketService.emit('limit:reached', {
        'limitType': reason,
        'usageMinutes': _todayUsageMinutes,
      });

      onLockStatusChange?.call(true);
    } catch (e) {
      print('Error locking device: $e');
    }
  }

  Future<void> unlockDevice() async {
    try {
      _isDeviceLocked = false;
      await _prefs.setBool('device_locked', false);

      // Notify native service
      await platform.invokeMethod('unlockDevice');

      onLockStatusChange?.call(false);
    } catch (e) {
      print('Error unlocking device: $e');
    }
  }

  Future<void> _handleMoreTimeRequest() async {
    // Send request to parent through socket
    _socketService.emit('request:more_time', {
      'currentUsage': _todayUsageMinutes,
      'reason': 'User requested',
    });
  }

  void _updateUsage(int minutes) {
    _todayUsageMinutes = minutes;
    onUsageUpdate?.call(minutes);
  }

  void _sendUsageToServer() {
    if (_todayUsageMinutes > 0) {
      _socketService.emit('usage:update', {
        'minutes': _todayUsageMinutes,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> grantExtraTime(int minutes) async {
    if (_currentRule != null) {
      final newLimit = _currentRule!.dailyLimitMinutes + minutes;
      _currentRule = _currentRule!.copyWith(dailyLimitMinutes: newLimit);
      await _applyRule(_currentRule!);

      // Unlock if currently locked
      if (_isDeviceLocked) {
        await unlockDevice();
      }
    }
  }

  int get remainingMinutes {
    if (_currentRule == null) return 0;
    return (_currentRule!.dailyLimitMinutes - _todayUsageMinutes).clamp(0, 999);
  }

  int get todayUsageMinutes => _todayUsageMinutes;
  bool get isDeviceLocked => _isDeviceLocked;

  void dispose() {
    _usageTimer?.cancel();
    _eventSubscription.cancel();
  }
}