import 'package:go_router/go_router.dart';

import '../router/app_router.dart' show buildRouter;
import '../router/session_gate.dart';
import '../router/session_gate_dummy.dart';
import '../../core_prev/config/app_config.dart';
import '../../core_prev/auth/token_storage.dart';
import '../../core_prev/network/api_clients.dart';

class AppScope {
  AppScope._(
    this.sessionGate,
    this.router,
    this.tokenStorage,
    this.apiClients,
    this.config,
  );

  final SessionGate sessionGate;
  final GoRouter router;

  final TokenStorage tokenStorage;
  final ApiClients apiClients;
  final AppConfig config;

  static AppScope? _instance;
  static AppScope get instance => _instance!;

  static Future<void> init(AppConfig config) async {
    if (_instance != null) return;

    final sessionGate = SessionGateDummy();
    final tokenStorage = SecureTokenStorage();

    final apiClients = ApiClients(
      baseUrls: config.baseUrls,
      tokenStorage: tokenStorage,
      enableLogging: config.enableNetworkLogging,
      onUnauthorized: () {
        // 상태관리 패키지 없이도 “세션 만료됨”만 표시하고 싶으면 여기서 처리
        sessionGate.setLoggedIn(false);
      },
      // refreshTokenHandler: () async { ... } // 나중에 붙이면 됨
    );

    final router = buildRouter(sessionGate);

    _instance = AppScope._(
      sessionGate,
      router,
      tokenStorage,
      apiClients,
      config,
    );
  }

  static void dispose() {
    _instance = null;
  }
}