import 'package:flutter/foundation.dart';
import '../core_prev/config/app_config.dart';
import 'di/app_scope.dart';

Future<void> bootstrap() async {
  final config = kReleaseMode ? AppConfig.prod() : AppConfig.dev();
  await AppScope.init(config);
}