
import 'config/app_config.dart';
import 'di/app_scope.dart';

Future<void> bootstrap() async {
  final envName = const String.fromEnvironment('APP_ENV');

  final config = switch (envName) {
    'prod' => AppConfig.prod(),
    'dev' => AppConfig.dev(),
    _ => AppConfig.dev(),
  };
  await AppScope.init(config);
}