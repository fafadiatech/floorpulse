import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

import 'config.dart';
import 'frappe_exception.dart';

class FrappeClient {
  FrappeClient._();

  static final FrappeClient instance = FrappeClient._();

  late final Dio _dio;
  PersistCookieJar? _cookieJar;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    final dir = await getApplicationSupportDirectory();
    _cookieJar = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage('${dir.path}/cookies'),
    );

    final base = Uri.parse(ApiConfig.frappeUrl);
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.frappeUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (_isIpHost(base.host)) 'Host': ApiConfig.frappeSiteHost,
        },
      ),
    );
    _dio.interceptors.add(CookieManager(_cookieJar!));
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final jar = _cookieJar;
          if (jar != null) {
            final cookies = await jar.loadForRequest(options.uri);
            final csrf = cookies.where((c) => c.name == 'csrf_token');
            if (csrf.isNotEmpty && csrf.first.value.isNotEmpty) {
              options.headers['X-Frappe-CSRF-Token'] = csrf.first.value;
            }
          }
          handler.next(options);
        },
      ),
    );
    _initialized = true;
  }

  static bool _isIpHost(String host) =>
      host == '10.0.2.2' || RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(host);

  Future<void> login(String usr, String pwd) async {
    try {
      await _dio.post('/api/method/login', data: {'usr': usr, 'pwd': pwd});
    } on DioException catch (e) {
      throw FrappeException.fromDio(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/api/method/logout');
    } on DioException {
      // Still drop the local session even if the server call fails.
    }
    await clearCookies();
  }

  Future<void> clearCookies() async {
    await _cookieJar?.deleteAll();
  }

  Future<bool> hasSessionCookie() async {
    final jar = _cookieJar;
    if (jar == null) return false;
    final cookies = await jar.loadForRequest(Uri.parse(ApiConfig.frappeUrl));
    return cookies.any(
      (c) => c.name == 'sid' && c.value.isNotEmpty && c.value != 'Guest',
    );
  }

  /// POST `/api/method/<method>` and unwrap Frappe `{message: ...}`.
  Future<dynamic> call(String method, {Map<String, dynamic>? args}) async {
    try {
      final response = await _dio.post('/api/method/$method', data: args ?? {});
      final data = response.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
      return data;
    } on DioException catch (e) {
      throw FrappeException.fromDio(e);
    }
  }
}
