// lib/core/network/interceptors/logging_interceptor.dart

import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../utils/logger.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({
    this.tag = 'DIO',
    this.logRequestHeaders = true,
    this.logRequestBody = true,
    this.logResponseHeaders = false,
    this.logResponseBody = true,
    this.maxBodyLength = 2000,
  });

  final String tag;
  final bool logRequestHeaders;
  final bool logRequestBody;
  final bool logResponseHeaders;
  final bool logResponseBody;

  /// body 로그 최대 길이 (초과분은 잘라서 출력)
  final int maxBodyLength;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_kStartAtKey] = DateTime.now().millisecondsSinceEpoch;

    final uri = options.uri.toString();
    AppLogger.d('→ ${options.method} $uri', tag: tag);

    if (logRequestHeaders) {
      AppLogger.d('headers: ${_safeJson(options.headers)}', tag: tag);
    }

    if (logRequestBody && options.data != null) {
      AppLogger.d('body: ${_pretty(options.data)}', tag: tag);
    }

    if (options.queryParameters.isNotEmpty) {
      AppLogger.d('query: ${_safeJson(options.queryParameters)}', tag: tag);
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final ms = _elapsedMs(response.requestOptions);
    final uri = response.requestOptions.uri.toString();

    AppLogger.i('← ${response.statusCode} (${ms}ms) $uri', tag: tag);

    if (logResponseHeaders) {
      AppLogger.d('headers: ${_safeJson(response.headers.map)}', tag: tag);
    }

    if (logResponseBody && response.data != null) {
      AppLogger.d('data: ${_truncate(_pretty(response.data))}', tag: tag);
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final ms = _elapsedMs(err.requestOptions);
    final uri = err.requestOptions.uri.toString();
    final status = err.response?.statusCode;

    AppLogger.e(
      '✕ $status (${ms}ms) ${err.requestOptions.method} $uri',
      tag: tag,
      error: err,
      stackTrace: err.stackTrace,
      data: err.response?.data,
    );

    handler.next(err);
  }

  int _elapsedMs(RequestOptions options) {
    final start = options.extra[_kStartAtKey] as int?;
    if (start == null) return -1;
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - start;
  }

  String _truncate(String s) {
    if (s.length <= maxBodyLength) return s;
    return '${s.substring(0, maxBodyLength)}…(truncated ${s.length - maxBodyLength} chars)';
  }

  String _pretty(Object? data) {
    try {
      if (data == null) return 'null';
      if (data is String) return _truncate(data);

      // map/list면 pretty json
      if (data is Map || data is List) {
        final enc = const JsonEncoder.withIndent('  ');
        return _truncate(enc.convert(data));
      }

      return _truncate(data.toString());
    } catch (_) {
      return _truncate(data.toString());
    }
  }

  String _safeJson(Object? data) {
    try {
      return jsonEncode(data);
    } catch (_) {
      return data.toString();
    }
  }
}

const String _kStartAtKey = '__log_start_at_ms__';