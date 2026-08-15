class ApiConfig {
  static const useMock = bool.fromEnvironment('USE_MOCK', defaultValue: false);

  static const frappeUrl = String.fromEnvironment(
    'FRAPPE_URL',
    defaultValue: 'http://floorpulse.localhost:8080',
  );

  /// Site name sent as the Host header when [frappeUrl] is an IP
  /// (Android emulator `10.0.2.2` or a LAN address).
  static const frappeSiteHost = String.fromEnvironment(
    'FRAPPE_HOST',
    defaultValue: 'floorpulse.localhost',
  );
}
