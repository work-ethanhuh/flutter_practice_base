import 'dart:async';
import 'package:dio/dio.dart';

typedef AccessTokenProvider = FutureOr<String?> Function();

/// refresh 수행 후 새로운 access token 을 돌려주는 핸들러
typedef RefreshTokenHandler = FutureOr<String?> Function();

/// refresh 실패 / 401 지속 시 상위로 알리는 콜백
typedef UnauthorizedHandler = void Function();

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required AccessTokenProvider accessTokenProvider,
    RefreshTokenHandler? refreshTokenHandler,
    UnauthorizedHandler? onUnauthorized,
    this.authorizationHeader = 'Authorization',
    this.tokenPrefix = 'Bearer ',
    this.maxRetryOnUnauthorized = 1,
  })  : _dio = dio,
        _accessTokenProvider = accessTokenProvider,
        _refreshTokenHandler = refreshTokenHandler,
        _onUnauthorized = onUnauthorized;

  final Dio _dio;
  final AccessTokenProvider _accessTokenProvider;
  final RefreshTokenHandler? _refreshTokenHandler;
  final UnauthorizedHandler? _onUnauthorized;

  final String authorizationHeader;
  final String tokenPrefix;

  /// 401일 때 몇 번 재시도할지 (보통 1)
  final int maxRetryOnUnauthorized;

  /// refresh 동시성 제어 (한 번에 refresh 1개만)
  Future<String?>? _refreshing;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await _accessTokenProvider();
      if (token != null && token.isNotEmpty) {
        options.headers[authorizationHeader] = '$tokenPrefix$token';
      } else {
        options.headers.remove(authorizationHeader);
      }
    } catch (_) {
      // 토큰 조회 실패는 request 자체를 막기보단, 토큰 없이 진행하도록 둡니다.
      options.headers.remove(authorizationHeader);
    }

    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;
    if (status != 401) {
      handler.next(err);
      return;
    }

    // refresh 훅이 없으면 즉시 unauthorized 처리
    if (_refreshTokenHandler == null) {
      _onUnauthorized?.call();
      handler.next(err);
      return;
    }

    final req = err.requestOptions;
    final retryCount = (req.extra[_kRetryKey] as int?) ?? 0;
    if (retryCount >= maxRetryOnUnauthorized) {
      _onUnauthorized?.call();
      handler.next(err);
      return;
    }

    try {
      // refresh는 동시 호출이 들어오면 하나만 수행하고 나머지는 그 결과를 기다림
      _refreshing ??= Future<String?>.sync(() async {
        final newToken = await _refreshTokenHandler!.call();
        return (newToken != null && newToken.isNotEmpty) ? newToken : null;
      });

      final newToken = await _refreshing;
      _refreshing = null;

      if (newToken == null) {
        _onUnauthorized?.call();
        handler.next(err);
        return;
      }

      // 원 요청 재시도
      final newOptions = _cloneRequestOptions(req);
      newOptions.headers[authorizationHeader] = '$tokenPrefix$newToken';
      newOptions.extra[_kRetryKey] = retryCount + 1;

      final response = await _dio.fetch(newOptions);
      handler.resolve(response);
    } catch (_) {
      _refreshing = null;
      _onUnauthorized?.call();
      handler.next(err);
    }
  }

  RequestOptions _cloneRequestOptions(RequestOptions o) {
    final ro = RequestOptions(
      path: o.path,
      method: o.method,
      baseUrl: o.baseUrl,
      queryParameters: Map<String, dynamic>.from(o.queryParameters),
      data: o.data,
      headers: Map<String, dynamic>.from(o.headers),
      connectTimeout: o.connectTimeout,
      sendTimeout: o.sendTimeout,
      receiveTimeout: o.receiveTimeout,
      responseType: o.responseType,
      contentType: o.contentType,
      validateStatus: o.validateStatus,
      receiveDataWhenStatusError: o.receiveDataWhenStatusError,
      followRedirects: o.followRedirects,
      maxRedirects: o.maxRedirects,
      requestEncoder: o.requestEncoder,
      responseDecoder: o.responseDecoder,
      listFormat: o.listFormat,
      extra: Map<String, dynamic>.from(o.extra),
      cancelToken: o.cancelToken,
      onReceiveProgress: o.onReceiveProgress,
      onSendProgress: o.onSendProgress,
    );

    return ro;
  }
}

const String _kRetryKey = '__auth_retry_count__';