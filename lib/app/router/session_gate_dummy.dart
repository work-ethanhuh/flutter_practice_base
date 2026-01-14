import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'session_gate.dart';

class SessionGateDummy extends ChangeNotifier implements SessionGate {
  bool _loggedIn = true;

  @override
  bool get isLoggedIn => _loggedIn;

  void setLoggedIn(bool value) {
    if (_loggedIn == value) return;
    _loggedIn = value;
    notifyListeners();
  }

  @override
  Listenable get listenable => this;

  @override
  String? redirect(GoRouterState state) {
    return null;
  }
}