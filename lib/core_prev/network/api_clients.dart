// lib/core/network/api_clients.dart
import 'package:dio/dio.dart';

import '../auth/token_storage.dart';
import 'api_target.dart';
import 'dio_client.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/auth_interceptor.dart';

class ApiClients {
  ApiClients({
    required Map<ApiTarget, String> baseUrls,
    required TokenStorage tokenStorage,
    required bool enableLogging,
    RefreshTokenHandler? refreshTokenHandler,
    UnauthorizedHandler? onUnauthorized,
    int maxRetryOnUnauthorized = 1,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration sendTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 20),
    Map<String, String>? defaultHeaders,
    LoggingInterceptor? loggingInterceptor,
    List<Interceptor> extraInterceptors = const <Interceptor>[],
  })  : _baseUrls = baseUrls,
        _tokenStorage = tokenStorage,
        _enableLogging = enableLogging,
        _refreshTokenHandler = refreshTokenHandler,
        _onUnauthorized = onUnauthorized,
        _maxRetryOnUnauthorized = maxRetryOnUnauthorized,
        _connectTimeout = connectTimeout,
        _sendTimeout = sendTimeout,
        _receiveTimeout = receiveTimeout,
        _defaultHeaders = defaultHeaders,
        _loggingInterceptor = loggingInterceptor,
        _extraInterceptors = extraInterceptors;

  final Map<ApiTarget, String> _baseUrls;
  final TokenStorage _tokenStorage;
  final bool _enableLogging;

  final RefreshTokenHandler? _refreshTokenHandler;
  final UnauthorizedHandler? _onUnauthorized;
  final int _maxRetryOnUnauthorized;

  final Duration _connectTimeout;
  final Duration _sendTimeout;
  final Duration _receiveTimeout;
  final Map<String, String>? _defaultHeaders;

  final LoggingInterceptor? _loggingInterceptor;
  final List<Interceptor> _extraInterceptors;

  final Map<ApiTarget, DioClient> _cache = {};

  DioClient get(ApiTarget target) {
    return _cache[target] ??= _build(target);
  }

  DioClient _build(ApiTarget target) {
    final baseUrl = _baseUrls[target];
    if (baseUrl == null || baseUrl.isEmpty) {
      throw StateError('Missing baseUrl for ApiTarget.$target');
    }

    return DioClient.create(
      baseUrl: baseUrl,
      tokenStorage: _tokenStorage,
      enableLogging: _enableLogging,
      loggingInterceptor: _loggingInterceptor,
      refreshTokenHandler: _refreshTokenHandler,
      onUnauthorized: _onUnauthorized,
      maxRetryOnUnauthorized: _maxRetryOnUnauthorized,
      connectTimeout: _connectTimeout,
      sendTimeout: _sendTimeout,
      receiveTimeout: _receiveTimeout,
      defaultHeaders: _defaultHeaders,
      extraInterceptors: _extraInterceptors,
    );
  }
}