/// Runtime environment classification for the Melo application.
enum AppEnvironment {
  development,
  staging,
  production;

  static AppEnvironment fromString(String env) {
    return switch (env.toLowerCase().trim()) {
      'production' || 'prod' => AppEnvironment.production,
      'staging' || 'stage' => AppEnvironment.staging,
      _ => AppEnvironment.development,
    };
  }

  bool get isProduction => this == AppEnvironment.production;
  bool get isDevelopment => this == AppEnvironment.development;
}

/// Central network configuration for Melo API communication.
abstract final class ApiConfig {
  /// Active application environment.
  static final AppEnvironment environment = AppEnvironment.fromString(
    const String.fromEnvironment('MELO_ENV', defaultValue: 'development'),
  );

  /// Base API URL for backend services.
  ///
  /// Defaults to `http://127.0.0.1:4000/api` which works directly on physical phones
  /// via USB `adb reverse tcp:4000 tcp:4000`, on emulator with port forwarding,
  /// and local desktop.
  static String baseUrl = const String.fromEnvironment(
    'MELO_API_URL',
    defaultValue: 'http://127.0.0.1:4000/api',
  );

  /// Candidate addresses to probe for host machine backend connection
  static const List<String> candidateBaseUrls = [
    'http://127.0.0.1:4000/api',
    'http://10.3.72.121:4000/api',
    'http://10.0.2.2:4000/api',
    'http://localhost:4000/api',
  ];

  /// Default network timeout duration.
  static const Duration timeout = Duration(seconds: 8);

  /// Max retries for idempotent network operations on transient failures.
  static const int maxRetries = 2;
}
