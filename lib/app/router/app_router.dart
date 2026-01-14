import 'package:go_router/go_router.dart';
import 'package:flutter_practice_base/features/splash/4_page/splash_page.dart';
import 'package:flutter_practice_base/features/dashboard/4_page/dashboard_page.dart';

import 'app_routes.dart';
import 'session_gate.dart';
import '_internal/route_utility.dart';

final List<GoRoute> appMainRoutes = <GoRoute>[
  createRoute(item: Routes.splash, page: () => const SplashPage()),
  createRoute(
    item: Routes.dashboard,
    page: () => const DashboardPage(),
    transition: RouteTransition.slideFromRight,
  ),
];

GoRouter buildRouter(SessionGate sessionGate) {
  return GoRouter(
    initialLocation: Routes.splash.path,
    routes: appMainRoutes,
    refreshListenable: sessionGate.listenable,
    redirect: (context, state) => sessionGate.redirect(state),
  );
}