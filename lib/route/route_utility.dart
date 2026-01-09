import 'package:flutter/material.dart';
import 'package:flutter_practice_base/route/routes.dart';
import 'package:go_router/go_router.dart';

extension RouteStringExtension on String {
  String get name => this;

  String get path {
    if (this == Routes.splash) return '/';
    if (startsWith('/')) return this;
    return '/$this';
  }
}

enum RouteTransition { fade, slideFromTop, slideFromRight, slideFromLeft, scale, none }

class RouteTransitionData {
  final RouteTransition transition;
  final Duration? duration;
  const RouteTransitionData({required this.transition, this.duration});
}

CustomTransitionPage<T> buildPageWithTransition<T>({
  required Widget child,
  required GoRouterState state,
  RouteTransition fallbackTransition = RouteTransition.fade,
  Duration fallbackDuration = const Duration(milliseconds: 300),
}) {
  final extra = state.extra;
  final RouteTransition effectiveTransition =
      (extra is RouteTransitionData) ? extra.transition : fallbackTransition;
  final Duration effectiveDuration =
      (extra is RouteTransitionData && extra.duration != null) ? extra.duration! : fallbackDuration;

  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: effectiveDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      switch (effectiveTransition) {
        case RouteTransition.none:
          return child;
        case RouteTransition.fade:
          return FadeTransition(opacity: animation, child: child);
        case RouteTransition.scale:
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
          return ScaleTransition(scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved), child: child);
        case RouteTransition.slideFromTop:
          return SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child);
        case RouteTransition.slideFromRight:
          return SlideTransition(
              position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child);
        case RouteTransition.slideFromLeft:
          return SlideTransition(
              position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child);
      }
    },
  );
}

GoRoute createRoute({
  required String item,
  required Widget Function() page,
  RouteTransition fallbackTransition = RouteTransition.fade,
  Duration fallbackDuration = const Duration(milliseconds: 300),
  List<GoRoute> routes = const <GoRoute>[],
}) {
  final resolvedName = item.name;
  final resolvedPath = item.path;

  return GoRoute(
    path: resolvedPath,
    name: resolvedName,
    routes: routes,
    pageBuilder: (BuildContext context, GoRouterState state) =>
        buildPageWithTransition(child: page(), state: state, fallbackTransition: fallbackTransition, fallbackDuration: fallbackDuration),
  );
}
