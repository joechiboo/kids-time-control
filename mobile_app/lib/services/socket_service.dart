import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';

class SocketService {
  late IO.Socket socket;
  late SharedPreferences _prefs;
  bool _isConnected = false;

  // Callbacks
  Function(Map<String, dynamic>)? onMessage;
  Function()? onConnect;
  Function()? onDisconnect;

  Future<void> connect() async {
    _prefs = await SharedPreferences.getInstance();

    // Get server URL from preferences or use default
    final serverUrl = _prefs.getString('server_url') ?? 'http://localhost:3000';
    final token = _prefs.getString('auth_token') ?? '';

    socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setAuth({'token': token})
        .build(),
    );

    socket.onConnect((_) {
      print('Connected to server');
      _isConnected = true;
      onConnect?.call();
    });

    socket.onDisconnect((_) {
      print('Disconnected from server');
      _isConnected = false;
      onDisconnect?.call();
    });

    // Listen for lock/unlock commands
    socket.on('lock:device', (data) {
      onMessage?.call({
        'type': 'lock',
        'data': data,
      });
    });

    socket.on('unlock:device', (data) {
      onMessage?.call({
        'type': 'unlock',
        'data': data,
      });
    });

    socket.on('rules:updated', (data) {
      onMessage?.call({
        'type': 'rules_updated',
        'data': data,
      });
    });

    socket.connect();
  }

  void emit(String event, dynamic data) {
    if (_isConnected) {
      socket.emit(event, data);
    }
  }

  bool get isConnected => _isConnected;

  void disconnect() {
    socket.disconnect();
  }

  void dispose() {
    socket.dispose();
  }
}