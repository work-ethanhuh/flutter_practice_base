import 'package:go_router/go_router.dart';

import '../config/app_config.dart';
import '../router/app_router.dart' show buildRouter;
import '../router/session_gate.dart';
import '../router/session_gate_dummy.dart';

class AppScope {
  AppScope._(
    this.sessionGate,
    this.router,
    this.config,
  );

  final SessionGate sessionGate;
  final GoRouter router;
  final AppConfig config;

  static AppScope? _instance;
  static AppScope get instance => _instance!;

  static Future<void> init(AppConfig config) async {
    if (_instance != null) return;

    final sessionGate = SessionGateDummy();
    final router = buildRouter(sessionGate);

    _instance = AppScope._(
      sessionGate,
      router,
      config,
    );
  }

  static void dispose() {
    _instance = null;
  }
}