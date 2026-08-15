import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../screens/home/home_screen.dart';
import '../screens/maintenance/maintenance_home_screen.dart';
import '../screens/qc/qc_home_screen.dart';
import '../screens/sales/sales_home_screen.dart';
import '../screens/warehouse/warehouse_home_screen.dart';
import '../theme/app_theme.dart';
import 'config.dart';
import 'floorpulse_api.dart';
import 'frappe_client.dart';
import 'frappe_exception.dart';

class SessionController extends ChangeNotifier {
  AppUser? _user;
  bool _restoring = !ApiConfig.useMock;

  AppUser? get user => _user;
  bool get restoring => _restoring;

  Future<AppUser> login(String usr, String pwd) async {
    if (ApiConfig.useMock) {
      final mock = FloorPulseApi.mockUserForCredentials(usr, pwd);
      if (mock == null) {
        throw const FrappeException('Invalid credentials');
      }
      _user = mock;
      notifyListeners();
      return mock;
    }

    await FloorPulseApi.instance.login(usr, pwd);
    try {
      final session = await FloorPulseApi.instance.getSession();
      final user = AppUser.fromSession(session);
      _user = user;
      notifyListeners();
      return user;
    } on FormatException {
      await FloorPulseApi.instance.logout();
      throw const FrappeException('No FloorPulse role assigned');
    }
  }

  Future<void> logout() async {
    await FloorPulseApi.instance.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> restore() async {
    if (ApiConfig.useMock) {
      _restoring = false;
      notifyListeners();
      return;
    }
    try {
      final hasCookie = await FrappeClient.instance.hasSessionCookie();
      if (hasCookie) {
        final session = await FloorPulseApi.instance.getSession();
        _user = AppUser.fromSession(session);
      }
    } catch (_) {
      await FrappeClient.instance.clearCookies();
      _user = null;
    } finally {
      _restoring = false;
      notifyListeners();
    }
  }
}

Widget homeShellFor(UserRole role) => switch (role) {
  UserRole.production => const HomeScreen(),
  UserRole.qc => const QCHomeScreen(),
  UserRole.warehouse => const WarehouseHomeScreen(),
  UserRole.sales => const SalesHomeScreen(),
  UserRole.maintenance => const MaintenanceHomeScreen(),
};

AppUser sessionUser(BuildContext context) {
  return context.watch<SessionController>().user ??
      const AppUser(
        username: '',
        name: 'User',
        userRole: UserRole.production,
        roleLabel: '',
        employeeId: '',
        department: '',
        initials: '?',
      );
}

Future<void> confirmLogout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Log Out',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      content: const Text('Are you sure you want to log out of FloorPulse?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.danger,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          child: const Text('Log Out'),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) {
    await context.read<SessionController>().logout();
  }
}
