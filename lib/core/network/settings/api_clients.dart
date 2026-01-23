// lib/core/network/settings/api_clients.dart
import 'package:dio/dio.dart';

import '../../../app/config/app_config.dart';
import '../../utils/token_storage.dart';

import '../services/auth_service.dart';
import '../services/refresh_jwt/refresh_jwt_request.dart';
import 'interceptor/auth_interceptor.dart';
import 'interceptor/logging_interceptor.dart';

class ApiClients {
  static final ApiClients _instance = ApiClients._internal();
  factory ApiClients() => _instance;

  final Dio token;
  final Dio nonToken;

  // ✅ 생성 시점 고정(final)로 두면 dev/prod 전환이 어려워서 내부 mutable로 관리
  bool _enableLogger;

  final TokenStorage _tokenStorage = SecureTokenStorage();

  UnauthorizedHandler? _onUnauthorizedListener;

  late final AuthService _authService;

  ApiClients._internal({
    bool enableLogger = false,
  })  : _enableLogger = enableLogger,
        token = Dio(),
        nonToken = Dio() {
    _init();
  }

  /// (선택) 앱에서 라우팅/토스트 등 하고 싶을 때만 연결
  void setOnUnauthorizedListener(UnauthorizedHandler listener) {
    _onUnauthorizedListener = listener;
  }

  /// ✅ 런타임 설정 주입 (dev/prod + logger)
  /// - baseUrl: host (예: https://dev-api.example.com) ← 끝에 '/' 없이 권장
  /// - enableLogger: dev에서는 true, prod에서는 false 같은 식으로
  void configure(AppConfig config) {
    _setBaseUrl(config.baseUrl);
    _setLogger(config.enableNetworkLogging);
  }

  void _init() {
    _setupBaseOptions(nonToken);
    _setupBaseOptions(token);

    // ✅ AuthService는 nonToken dio를 쓰되,
    //    baseUrl은 dio.options.baseUrl(런타임 주입) + @RestApi의 path 조합으로 최종 URL이 만들어짐
    _authService = AuthService(nonToken);

    // ✅ 기존 생성자 enableLogger를 유지하고 싶으면 초기 시점 로깅도 반영
    _applyLogger(nonToken, _enableLogger, tag: 'NON_TOKEN');
    _applyLogger(token, _enableLogger, tag: 'TOKEN');

    token.interceptors.add(
      AuthInterceptor(
        dio: token,
        accessTokenProvider: () => _tokenStorage.readAccessToken(),
        refreshTokenHandler: _refreshTokenHandler,
        onUnauthorized: _handleUnauthorized,
      ),
    );
  }

  void _setBaseUrl(String baseUrl) {
    // baseUrl은 host만(https://...) 넣는 걸 추천합니다.
    token.options.baseUrl = baseUrl;
    nonToken.options.baseUrl = baseUrl;
  }

  void _setLogger(bool enable) {
    if (_enableLogger == enable) return; // 불필요한 재설정 방지
    _enableLogger = enable;

    _applyLogger(nonToken, enable, tag: 'NON_TOKEN');
    _applyLogger(token, enable, tag: 'TOKEN');
  }

  void _applyLogger(Dio dio, bool enable, {required String tag}) {
    // ✅ 중복 방지: 기존 LoggingInterceptor 제거 후 필요하면 재추가
    dio.interceptors.removeWhere((i) => i is LoggingInterceptor);

    if (enable) {
      dio.interceptors.add(LoggingInterceptor(tag: tag));
    }
  }

  Future<String?> _refreshTokenHandler() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;

    final pair = await _authService.refreshJwt(
      RefreshJwtRequest(refreshToken: refreshToken),
    );

    final newRefresh = pair.refreshToken ?? refreshToken;

    await _tokenStorage.writeTokenPair(
      accessToken: pair.accessToken,
      refreshToken: newRefresh,
    );

    return pair.accessToken;
  }

  void _handleUnauthorized() async {
    await _tokenStorage.clear(); // access/refresh 삭제
    _onUnauthorizedListener?.call();
  }

  void _setupBaseOptions(
    Dio dio, {
    int connectMs = 10000,
    int receiveMs = 10000,
  }) {
    dio.options
      ..connectTimeout = Duration(milliseconds: connectMs)
      ..receiveTimeout = Duration(milliseconds: receiveMs)
      ..headers = <String, String>{
        'content-type': 'application/json; charset=utf-8',
        'accept': 'application/json',
      };
  }
}