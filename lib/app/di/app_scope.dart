import 'package:go_router/go_router.dart';

import '../router/app_router.dart' show buildRouter;
import '../router/session_gate.dart';
import '../router/session_gate_dummy.dart';

class AppScope {
  AppScope._(this.sessionGate, this.router);

  final SessionGate sessionGate;
  final GoRouter router;

  static AppScope? _instance;

  static AppScope get instance {
    final inst = _instance;
    if (inst == null) {
      throw StateError('AppScope is not initialized. Call AppScope.init() first.');
    }
    return inst;
  }

  static Future<void> init() async {
    if (_instance != null) return;

    final SessionGate sessionGate = SessionGateDummy();
    final GoRouter router = buildRouter(sessionGate);

    _instance = AppScope._(sessionGate, router);
  }

  static void dispose() {
    _instance = null;
  }
}