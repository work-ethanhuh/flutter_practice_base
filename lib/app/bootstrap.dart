import 'package:flutter/material.dart';
import 'app.dart';
import 'di/app_scope.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppScope.init();

  runApp(const App());
}