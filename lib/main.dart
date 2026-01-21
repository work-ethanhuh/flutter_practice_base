import 'package:flutter/material.dart';
import 'package:flutter_practice_base/app/app.dart';
import 'package:flutter_practice_base/app/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap();
  runApp(const App());
}