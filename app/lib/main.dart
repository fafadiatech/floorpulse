import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'api/frappe_client.dart';
import 'api/session.dart';
import 'screens/auth/login_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await FrappeClient.instance.init();
  runApp(const FloorPulseApp());
}

class FloorPulseApp extends StatelessWidget {
  const FloorPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final session = SessionController();
        session.restore();
        return session;
      },
      child: MaterialApp(
        title: 'FloorPulse',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    if (session.restoring && session.user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = session.user;
    if (user == null) return const LoginScreen();
    return homeShellFor(user.userRole);
  }
}
