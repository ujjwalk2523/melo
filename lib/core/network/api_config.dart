/// Central network configuration for Melo API communication.
abstract final class ApiConfig {
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
}
