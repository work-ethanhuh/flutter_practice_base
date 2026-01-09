import 'package:go_router/go_router.dart';
import 'package:flutter_practice_base/page_widgets/splash.dart';
import 'package:flutter_practice_base/page_widgets/dashboard.dart';

import 'app_routes.dart';
import 'route_utility.dart';

final List<GoRoute> appMainRoutes = <GoRoute>[
  createRoute(item: Routes.splash, page: () => const Splash()),
  createRoute(
    item: Routes.dashboard,
    page: () => const Dashboard(),
    transition: RouteTransition.slideFromRight,
  ),
];

final GoRouter appRouter = GoRouter(
  initialLocation: Routes.splash.path,
  routes: appMainRoutes,
);