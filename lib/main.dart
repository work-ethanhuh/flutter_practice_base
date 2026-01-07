import 'package:flutter/material.dart';
import 'package:flutter_practice_base/route/routes.dart';
import 'package:go_router/go_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const AppEntrance());
}

class AppEntrance extends StatelessWidget {
  const AppEntrance({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Practice Base Project',
      routerConfig: GoRouter(
        initialLocation: Routes.splash.path,
        routes: appMainRoutes,
      ),
    );
  }
}
