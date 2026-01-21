// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';

import '../auth/token_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

class DioClient {
  DioClient._(this._dio);

  final Dio _dio;

  Dio get raw => _dio;

  /// 가장 많이 쓰는 생성자(공통 베이스)
  factory DioClient.create({
    required String baseUrl,
    required TokenStorage tokenStorage,

    // 옵션
    Duration connectTimeout = const Duration(seconds: 10),
    Duration sendTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 20),
    Map<String, String>? defaultHeaders,

    // 로깅
    bool enableLogging = false,
    LoggingInterceptor? loggingInterceptor,

    // 인증/세션
    RefreshTokenHandler? refreshTokenHandler,
    UnauthorizedHandler? onUnauthorized,
    int maxRetryOnUnauthorized = 1,

    // 확장 (추가 인터셉터)
    List<Interceptor> extraInterceptors = const <Interceptor>[],
  }) {
    final options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
      headers: <String, dynamic>{
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        ...?defaultHeaders,
      },
    );

    final dio = Dio(options);

    // 1) 로깅 (필요 시)
    if (enableLogging) {
      dio.interceptors.add(loggingInterceptor ?? LoggingInterceptor());
    }

    // 2) 인증 (토큰 주입 + 401 시 refresh 재시도)
    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        accessTokenProvider: () => tokenStorage.readAccessToken(),
        refreshTokenHandler: refreshTokenHandler,
        onUnauthorized: onUnauthorized,
        maxRetryOnUnauthorized: maxRetryOnUnauthorized,
      ),
    );

    // 3) 그 외 확장 인터셉터
    if (extraInterceptors.isNotEmpty) {
      dio.interceptors.addAll(extraInterceptors);
    }

    return DioClient._(dio);
  }

  /// 런타임에 baseUrl 전환이 필요할 때 (QA/Prod, 멀티 테넌트 등)
  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  /// 공통 헤더(언어/앱버전 등) 추가/갱신
  void setHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  // --------------------
  // Convenience wrappers
  // --------------------

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}