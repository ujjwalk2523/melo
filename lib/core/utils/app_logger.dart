import 'package:flutter/foundation.dart';

enum LogCategory {
  auth,
  api,
  player,
  download,
  sync,
  recommendation,
  provider,
  database,
  general,
}

enum LogLevel { debug, info, warning, error }

/// Production-hardened structured logger for Melo.
///
/// Features:
/// - Categorical tagging for precise log filtering
/// - Log levels (DEBUG, INFO, WARN, ERROR)
/// - Automatic redaction of passwords, tokens, API keys, and sensitive auth data
/// - Suppression of DEBUG logs in release mode
class AppLogger {
  AppLogger._();

  static LogLevel minLevel = kReleaseMode ? LogLevel.info : LogLevel.debug;

  /// Sensitive pattern matchers for redaction.
  static final RegExp _bearerPattern = RegExp(
    r'Bearer\s+[A-Za-z0-9\-\._~\+\/]+=*',
    caseSensitive: false,
  );
  static final RegExp _passwordPattern = RegExp(
    r"""(password|passwd|pwd)\s*[:=]\s*["']?([^"'\s,]+)""",
    caseSensitive: false,
  );
  static final RegExp _apiKeyPattern = RegExp(
    r"""(api[_-]?key|client[_-]?secret|token)\s*[:=]\s*["']?([^"'\s,]+)""",
    caseSensitive: false,
  );
  static final RegExp _emailPattern = RegExp(
    r'\b([a-zA-Z0-9_.+-])[a-zA-Z0-9_.+-]*@([a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+)\b',
  );

  /// Redacts sensitive details from any log message.
  static String sanitize(String message) {
    var sanitized = message;
    sanitized = sanitized.replaceAllMapped(
      _bearerPattern,
      (_) => 'Bearer REDACTED',
    );
    sanitized = sanitized.replaceAllMapped(
      _passwordPattern,
      (m) => '${m.group(1)}=REDACTED',
    );
    sanitized = sanitized.replaceAllMapped(
      _apiKeyPattern,
      (m) => '${m.group(1)}=REDACTED',
    );
    sanitized = sanitized.replaceAllMapped(
      _emailPattern,
      (m) => '${m.group(1)}***@${m.group(2)}',
    );
    return sanitized;
  }

  static void debug(
    String message, {
    LogCategory category = LogCategory.general,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.debug, category, message, error, stackTrace);
  }

  static void info(
    String message, {
    LogCategory category = LogCategory.general,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.info, category, message, error, stackTrace);
  }

  static void warning(
    String message, {
    LogCategory category = LogCategory.general,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.warning, category, message, error, stackTrace);
  }

  static void error(
    String message, {
    LogCategory category = LogCategory.general,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.error, category, message, error, stackTrace);
  }

  static void _log(
    LogLevel level,
    LogCategory category,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    if (level.index < minLevel.index) return;

    final categoryTag = category.name.toUpperCase();
    final levelTag = level.name.toUpperCase();
    final cleanMessage = sanitize(message);

    final line = '[$levelTag][$categoryTag] $cleanMessage';

    if (level == LogLevel.error) {
      debugPrint(line);
      if (error != null) {
        debugPrint('  Error: ${sanitize(error.toString())}');
      }
      if (stackTrace != null && !kReleaseMode) {
        debugPrint('  StackTrace:\n$stackTrace');
      }
    } else {
      debugPrint(line);
    }
  }
}
