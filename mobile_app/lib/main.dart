import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/parent_dashboard.dart';
import 'services/time_control_service.dart';
import 'services/socket_service.dart';
import 'providers/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final socketService = SocketService();
  final timeControlService = TimeControlService(socketService);

  await socketService.connect();
  await timeControlService.initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => socketService),
        Provider(create: (_) => timeControlService),
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kids Time Control',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        primaryColor: Color(0xFF7C4DFF),
        accentColor: Color(0xFF4ECDC4),
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // Check user role and show appropriate screen
    if (appState.userRole == 'parent') {
      return ParentDashboard();
    } else {
      return HomeScreen();
    }
  }
}