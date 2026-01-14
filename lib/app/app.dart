import 'package:flutter/material.dart';
import 'di/app_scope.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Practice Base Project',
      routerConfig: AppScope.instance.router,
    );
  }
}