// lib/core/config/app_config.dart
import '../network/api_target.dart';

class AppConfig {
  const AppConfig({
    required this.baseUrls,
    this.enableNetworkLogging = false,
  });

  /// 서버별 baseUrl 맵
  final Map<ApiTarget, String> baseUrls;

  final bool enableNetworkLogging;

  factory AppConfig.dev() => const AppConfig(
        baseUrls: {
          ApiTarget.main: 'https://dev.example.com',
          // ApiTarget.payment: 'https://dev-pay.example.com',
        },
        enableNetworkLogging: true,
      );

  factory AppConfig.prod() => const AppConfig(
        baseUrls: {
          ApiTarget.main: 'https://api.example.com',
          // ApiTarget.payment: 'https://pay.example.com',
        },
        enableNetworkLogging: false,
      );
}