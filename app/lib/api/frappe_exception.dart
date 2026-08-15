import 'dart:convert';

import 'package:dio/dio.dart';

class FrappeException implements Exception {
  final String message;
  final int? statusCode;

  const FrappeException(this.message, {this.statusCode});

  factory FrappeException.fromDio(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;
    final parsed = _messageFromBody(data);
    if (parsed != null && parsed.isNotEmpty) {
      return FrappeException(parsed, statusCode: status);
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return FrappeException('Connection timed out', statusCode: status);
      case DioExceptionType.connectionError:
        return const FrappeException(
          'Cannot reach the server. Check FRAPPE_URL and that the backend is running.',
        );
      default:
        return FrappeException(
          error.message ?? 'Request failed',
          statusCode: status,
        );
    }
  }

  static String? _messageFromBody(dynamic data) {
    if (data == null) return null;
    if (data is String && data.trim().isNotEmpty) {
      try {
        return _messageFromBody(jsonDecode(data));
      } catch (_) {
        return data;
      }
    }
    if (data is! Map) return data.toString();

    final serverMessages = data['_server_messages'];
    if (serverMessages is String) {
      try {
        final list = jsonDecode(serverMessages) as List<dynamic>;
        final parts = <String>[];
        for (final item in list) {
          if (item is String) {
            try {
              final inner = jsonDecode(item);
              if (inner is Map && inner['message'] != null) {
                parts.add(inner['message'].toString());
                continue;
              }
            } catch (_) {}
            parts.add(item);
          } else if (item is Map && item['message'] != null) {
            parts.add(item['message'].toString());
          }
        }
        if (parts.isNotEmpty) return parts.join('\n');
      } catch (_) {}
    }

    final exception = data['exception'];
    if (exception is String && exception.isNotEmpty) {
      final cleaned = exception.split('\n').first;
      return cleaned.replaceFirst(RegExp(r'^[\w.]+:\s*'), '');
    }

    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;

    final excType = data['exc_type'];
    if (excType is String && excType.isNotEmpty) return excType;

    return null;
  }

  @override
  String toString() => message;
}
