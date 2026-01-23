enum AppEnv { dev, prod }
enum ApiTarget {
  main,
  // payment,
  // analytics,
}

class AppConfig {
  const AppConfig({
    required this.env,
    required this.baseUrls,
    this.enableNetworkLogging = false,
  });

  final AppEnv env;
  final Map<ApiTarget, String> baseUrls;
  final bool enableNetworkLogging;

  String get baseUrl => baseUrls[ApiTarget.main]!;

  factory AppConfig.dev() => const AppConfig(
        env: AppEnv.dev,
        baseUrls: {
          ApiTarget.main: 'http://dev.practice.com',
        },
        enableNetworkLogging: true,
      );

  factory AppConfig.prod() => const AppConfig(
        env: AppEnv.prod,
        baseUrls: {
          ApiTarget.main: 'http://prod.practice.com',
        },
        enableNetworkLogging: false,
      );
}