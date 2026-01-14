import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

abstract class SessionGate {
  Listenable get listenable;

  bool get isLoggedIn;

  String? redirect(GoRouterState state);
}