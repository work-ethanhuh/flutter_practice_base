import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';

extension RouteStringExtension on String {
  String get name => this;

  String get path {
    if (this == Routes.splash) return '/';
    if (startsWith('/')) return this;
    return '/$this';
  }
}

enum RouteTransition {
  fade,
  slideFromTop,
  slideFromRight,
  slideFromLeft,
  scale,
  none,
}

CustomTransitionPage<T> buildPageWithTransition<T>({
  required Widget child,
  required GoRouterState state,
  RouteTransition transition = RouteTransition.fade,
  Duration duration = const Duration(milliseconds: 300),
}) {
  if (transition == RouteTransition.none) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (_, __, ___, child) => child,
      transitionDuration: Duration.zero,
    );
  }

  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      switch (transition) {
        case RouteTransition.fade:
          return FadeTransition(opacity: animation, child: child);

        case RouteTransition.slideFromRight:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          );

        case RouteTransition.slideFromLeft:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          );

        case RouteTransition.slideFromTop:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          );

        case RouteTransition.scale:
          return ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );

        case RouteTransition.none:
          return child;
      }
    },
  );
}

GoRoute createRoute({
  required String item,
  required Widget Function() page,
  RouteTransition transition = RouteTransition.fade,
  Duration duration = const Duration(milliseconds: 300),
  List<GoRoute> routes = const <GoRoute>[],
}) {
  return GoRoute(
    path: item.path,
    name: item.name,
    routes: routes,
    pageBuilder: (context, state) => buildPageWithTransition(
      child: page(),
      state: state,
      transition: transition,
      duration: duration,
    ),
  );
}