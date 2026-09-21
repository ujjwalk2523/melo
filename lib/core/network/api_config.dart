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
  /// Defaults to `http://10.0.2.2:4000/api` for Android Emulator access to host localhost.
  /// Override during runtime using `--dart-define=MELO_API_URL=http://localhost:4000/api`
  /// or `--dart-define=MELO_API_URL=https://api.yourdomain.com/api`.
  static const String baseUrl = String.fromEnvironment(
    'MELO_API_URL',
    defaultValue: 'http://10.0.2.2:4000/api',
  );

  /// Default network timeout duration.
  static const Duration timeout = Duration(seconds: 8);

  /// Max retries for idempotent network operations on transient failures.
  static const int maxRetries = 2;
}
