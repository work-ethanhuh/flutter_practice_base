import 'package:go_router/go_router.dart';
import 'route_utility.dart';
import 'package:flutter_practice_base/page_widgets/splash.dart';
import 'package:flutter_practice_base/page_widgets/dashboard.dart';

class Routes {
  static const String splash = 'splash';
  static const String dashboard = 'dashboard';
  static const String home = 'home';
  static const String homeSample = 'home_sample';
  static const String settings = 'settings';
}

final List<GoRoute> appMainRoutes = <GoRoute>[
  createRoute(item: Routes.splash, page: () => const Splash()),
  createRoute(item: Routes.dashboard, page: () => const Dashboard(), fallbackTransition: RouteTransition.slideFromRight),
];

final GoRouter appRouter = GoRouter(
        initialLocation: Routes.splash.path,
        routes: appMainRoutes,
      );