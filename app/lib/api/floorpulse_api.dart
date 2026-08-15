import '../data/maintenance_mock_data.dart';
import '../data/mock_data.dart';
import '../data/qc_mock_data.dart';
import '../data/sales_mock_data.dart';
import '../data/warehouse_mock_data.dart';
import '../models/app_user.dart';
import '../models/scan_hit.dart';
import 'config.dart';
import 'frappe_client.dart';
import 'frappe_exception.dart';

class FloorPulseApi {
  FloorPulseApi._();

  static final FloorPulseApi instance = FloorPulseApi._();

  final _client = FrappeClient.instance;

  Future<Map<String, dynamic>> getSession() async {
    if (ApiConfig.useMock) {
      throw const FrappeException('get_session is not used in mock mode');
    }
    final message = await _client.call('floorpulse.api.auth.get_session');
    if (message is Map<String, dynamic>) return message;
    if (message is Map) return Map<String, dynamic>.from(message);
    throw const FrappeException('Unexpected get_session response');
  }

  Future<Map<String, dynamic>> getDashboard({String? role}) async {
    if (ApiConfig.useMock) {
      return Map<String, dynamic>.from(_mockDashboard(role));
    }
    final message = await _client.call(
      'floorpulse.api.dashboard.get',
      args: {'role': ?role},
    );
    if (message is Map<String, dynamic>) return message;
    if (message is Map) return Map<String, dynamic>.from(message);
    throw const FrappeException('Unexpected dashboard response');
  }

  Future<ScanHit> resolveScan(String code) async {
    if (ApiConfig.useMock) {
      return ScanHit(
        type: 'Work Order',
        doctype: 'Work Order',
        name: code.isEmpty ? 'WO-2024-001' : code,
        label: 'Hydraulic Pump Assembly',
      );
    }
    final message = await _client.call(
      'floorpulse.api.scan.resolve',
      args: {'code': code},
    );
    if (message is Map<String, dynamic>) return ScanHit.fromJson(message);
    if (message is Map) {
      return ScanHit.fromJson(Map<String, dynamic>.from(message));
    }
    throw const FrappeException('Unexpected scan response');
  }

  Future<void> login(String usr, String pwd) => _client.login(usr, pwd);

  Future<void> logout() async {
    if (ApiConfig.useMock) return;
    await _client.logout();
  }

  static Map<String, dynamic> _mockDashboard(String? role) {
    switch (role) {
      case 'qc':
        return {...QCMockData.qcDashboardStats, 'unreadNotifications': 0};
      case 'warehouse':
        return {...WarehouseMockData.dashboardStats, 'unreadNotifications': 0};
      case 'sales':
        return {...SalesMockData.dashboardStats, 'unreadNotifications': 0};
      case 'maintenance':
        return {
          ...MaintenanceMockData.dashboardStats,
          'unreadNotifications': 0,
        };
      default:
        return {...MockData.dashboardStats, 'unreadNotifications': 2};
    }
  }

  static AppUser? mockUserForCredentials(String username, String password) {
    if (username == 'production' && password == 'prod123') {
      return QCMockData.productionUser;
    }
    if (username == 'qc' && password == 'qc123') {
      return QCMockData.qcUser;
    }
    if (username == 'warehouse' && password == 'wh123') {
      return WarehouseMockData.warehouseUser;
    }
    if (username == 'sales' && password == 'sales123') {
      return SalesMockData.salesUser;
    }
    if (username == 'maintenance' && password == 'maint123') {
      return MaintenanceMockData.maintenanceUser;
    }
    return null;
  }
}
