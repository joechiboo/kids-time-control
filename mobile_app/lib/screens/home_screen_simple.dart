import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const platform = MethodChannel('com.kidstimecontrol.app/lock');

  int _remainingMinutes = 120;
  int _usedMinutes = 0;
  bool _isLocked = false;
  Timer? _timer;
  bool _showDevControls = false;
  int _headerTapCount = 0;
  int _bottomTapCount = 0;
  Timer? _tapResetTimer;
  SharedPreferences? _prefs;
  bool _accessibilityEnabled = false;
  int _lockIconTapCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadData();
    await _checkAccessibilityService();

    // 每分鐘倒數（使用時才倒數）
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_remainingMinutes > 0 && !_isLocked) {
        setState(() {
          _remainingMinutes--;
          _usedMinutes++;
        });
        _saveData();

        // 時間用完自動鎖定
        if (_remainingMinutes == 0) {
          _lockDevice();
        }
      }

      // 每分鐘檢查是否需要重設
      _checkAndResetDaily();
    });
  }

  Future<void> _loadData() async {
    final lastDate = _prefs?.getString('lastDate') ?? '';
    final today = DateTime.now().toIso8601String().substring(0, 10);

    // 檢查並設定預設 PIN 碼
    if (!(_prefs?.containsKey('parentPin') ?? false)) {
      await _prefs?.setString('parentPin', '1234');
    }

    if (lastDate != today) {
      // 新的一天，重設時間
      setState(() {
        _remainingMinutes = 120;
        _usedMinutes = 0;
        _isLocked = false;
      });
      await _prefs?.setString('lastDate', today);
      await _saveData();
    } else {
      // 載入上次的狀態
      setState(() {
        _remainingMinutes = _prefs?.getInt('remainingMinutes') ?? 120;
        _usedMinutes = _prefs?.getInt('usedMinutes') ?? 0;
        _isLocked = _prefs?.getBool('isLocked') ?? false;
      });
    }
  }

  Future<void> _saveData() async {
    await _prefs?.setInt('remainingMinutes', _remainingMinutes);
    await _prefs?.setInt('usedMinutes', _usedMinutes);
    await _prefs?.setBool('isLocked', _isLocked);
  }

  void _checkAndResetDaily() {
    final now = DateTime.now();
    final lastDate = _prefs?.getString('lastDate') ?? '';
    final today = now.toIso8601String().substring(0, 10);

    // 檢查日期是否改變
    if (lastDate != today) {
      setState(() {
        _remainingMinutes = 120;
        _usedMinutes = 0;
        _isLocked = false;
      });
      _prefs?.setString('lastDate', today);
      _saveData();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tapResetTimer?.cancel();
    super.dispose();
  }

  void _onHeaderTap() {
    _headerTapCount++;
    _tapResetTimer?.cancel();

    if (_headerTapCount == 2 && _bottomTapCount == 2) {
      setState(() {
        _showDevControls = !_showDevControls;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_showDevControls ? '開發者模式已開啟' : '開發者模式已關閉'),
          duration: const Duration(seconds: 1),
        ),
      );
      _headerTapCount = 0;
      _bottomTapCount = 0;
    } else {
      _tapResetTimer = Timer(const Duration(seconds: 3), () {
        setState(() {
          _headerTapCount = 0;
          _bottomTapCount = 0;
        });
      });
    }
  }

  void _onBottomTap() {
    _bottomTapCount++;
    _tapResetTimer?.cancel();

    if (_headerTapCount == 2 && _bottomTapCount == 2) {
      setState(() {
        _showDevControls = !_showDevControls;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_showDevControls ? '開發者模式已開啟' : '開發者模式已關閉'),
          duration: const Duration(seconds: 1),
        ),
      );
      _headerTapCount = 0;
      _bottomTapCount = 0;
    } else {
      _tapResetTimer = Timer(const Duration(seconds: 3), () {
        setState(() {
          _headerTapCount = 0;
          _bottomTapCount = 0;
        });
      });
    }
  }

  Future<void> _checkAccessibilityService() async {
    try {
      final bool enabled = await platform.invokeMethod('isAccessibilityEnabled');
      setState(() {
        _accessibilityEnabled = enabled;
      });
    } catch (e) {
      print('檢查無障礙服務失敗: $e');
    }
  }

  Future<void> _openAccessibilitySettings() async {
    try {
      await platform.invokeMethod('openAccessibilitySettings');
    } catch (e) {
      print('打開設定失敗: $e');
    }
  }

  Future<void> _lockDevice() async {
    if (!_accessibilityEnabled) {
      _showAccessibilityDialog();
      return;
    }

    setState(() {
      _isLocked = true;
    });
    _saveData();

    // 隱藏狀態列和導航列（全螢幕沉浸模式）
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    try {
      await platform.invokeMethod('setLocked', {'locked': true});
    } catch (e) {
      print('設定鎖定失敗: $e');
    }
  }

  Future<void> _unlockDevice() async {
    setState(() {
      _isLocked = false;
    });
    _saveData();

    // 恢復狀態列和導航列
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    try {
      await platform.invokeMethod('setLocked', {'locked': false});
    } catch (e) {
      print('解除鎖定失敗: $e');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('裝置已解鎖')),
    );
  }

  void _showAccessibilityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('需要啟用無障礙服務'),
        content: const Text(
          '為了鎖定裝置功能正常運作，需要啟用無障礙服務。\n\n'
          '請在設定中找到「Kids Time Control」並啟用。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openAccessibilitySettings();
            },
            child: const Text('前往設定'),
          ),
        ],
      ),
    );
  }

  void _onLockIconTap() {
    _lockIconTapCount++;
    if (_lockIconTapCount >= 5) {
      _lockIconTapCount = 0;
      _showParentVerificationDialog();
    }

    // 3 秒後重設計數
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _lockIconTapCount = 0;
        });
      }
    });
  }

  void _showParentVerificationDialog() {
    final TextEditingController pinController = TextEditingController();
    final savedPin = _prefs?.getString('parentPin') ?? '1234';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('家長驗證'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('請輸入家長 PIN 碼：'),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'PIN 碼',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (pinController.text == savedPin) {
                Navigator.pop(context);
                _showAddTimeDialog();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN 碼錯誤'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('確認'),
          ),
        ],
      ),
    );
  }

  void _showAddTimeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('家長控制'),
        content: const Text('選擇操作：'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showChangePinDialog();
            },
            child: const Text('設定 PIN'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _addTime(5);
            },
            child: const Text('+5 分鐘'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _addTime(10);
            },
            child: const Text('+10 分鐘'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _addTime(20);
            },
            child: const Text('+20 分鐘'),
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog() {
    final TextEditingController newPinController = TextEditingController();
    final TextEditingController confirmPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('設定 PIN 碼'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: '新 PIN 碼',
                hintText: '4 位數字',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: '確認 PIN 碼',
                hintText: '再次輸入',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              if (newPinController.text.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN 碼必須是 4 位數字'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (newPinController.text != confirmPinController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('兩次輸入的 PIN 碼不一致'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              await _prefs?.setString('parentPin', newPinController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PIN 碼設定成功'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('確認'),
          ),
        ],
      ),
    );
  }

  void _addTime(int minutes) {
    setState(() {
      _remainingMinutes += minutes;
      _isLocked = false;
    });
    _saveData();

    // 恢復狀態列和導航列
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    try {
      platform.invokeMethod('setLocked', {'locked': false});
    } catch (e) {
      print('解除鎖定失敗: $e');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已增加 $minutes 分鐘使用時間')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 如果鎖定，顯示全螢幕鎖定畫面
    if (_isLocked) {
      return WillPopScope(
        onWillPop: () async {
          // 攔截返回鍵，防止關閉 APP
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('時間到了，無法關閉 APP'),
              duration: Duration(seconds: 1),
            ),
          );
          return false;
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF2D3436),
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              // 覆蓋整個螢幕包括狀態列
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF2D3436),
                ),
              ),
              // 主要內容
              Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 點擊鎖頭 5 次進入家長驗證
                  GestureDetector(
                    onTap: _onLockIconTap,
                    child: const Icon(
                      Icons.lock_clock,
                      size: 120,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    '時間到了！',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '今天的螢幕時間已經用完了\n去做點其他有趣的事情吧！',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
              ),
            ],
          ),
        ),
      );
    }

    // 正常畫面
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        appBar: AppBar(
          title: const Text('Kids Time Control'),
          backgroundColor: const Color(0xFF7C4DFF),
        ),
        body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - 可點擊區域（開發者手勢第一步）
              GestureDetector(
                onTap: _onHeaderTap,
                child: Column(
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
                    const SizedBox(height: 8),
                    const Text(
                      '今天也要合理使用手機哦',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF636E72),
                      ),
                    ),
                  ],
                ),
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
                    // Simple timer display
                    Text(
                      '$_remainingMinutes',
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7C4DFF),
                      ),
                    ),
                    const Text(
                      '分鐘',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xFF636E72),
                      ),
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

              // Digital Health Reminder - 可點擊區域（開發者手勢第二步）
              GestureDetector(
                onTap: _onBottomTap,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.health_and_safety,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '數位健康提醒',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '學齡前兒童建議每天使用 3C\n(手機/平板) 時間不得超過 2 個小時',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Test Controls - 只在開發者模式顯示
              if (_showDevControls) ...[
                const Text(
                  '測試控制',
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
                      child: ElevatedButton.icon(
                        onPressed: _isLocked ? null : _lockDevice,
                        icon: const Icon(Icons.lock),
                        label: const Text('鎖定裝置'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLocked ? _unlockDevice : null,
                        icon: const Icon(Icons.lock_open),
                        label: const Text('解鎖裝置'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
        ),
      ),
    );
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
}
