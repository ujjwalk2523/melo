import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../utils/app_logger.dart';
import 'api_config.dart';

/// Typed exception for network and server failures.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  const ApiException(this.message, {this.statusCode, this.errorCode});

  @override
  String toString() =>
      'ApiException(message: $message, statusCode: $statusCode, errorCode: $errorCode)';
}

/// Generic HTTP client for communicating with the Melo backend service.
///
/// Features:
/// - Categorical logging with sensitive token redaction
/// - Configurable timeout and environment awareness
/// - Exponential backoff retry on transient errors (timeouts, 502/503/504, connection drops)
/// - Strictly never retries client-side 4xx errors
class ApiClient {
  final http.Client _client;
  final String baseUrl;
  final int maxRetries;
  final Duration retryBaseDelay;

  ApiClient({
    http.Client? client,
    String? baseUrl,
    int? maxRetries,
    this.retryBaseDelay = const Duration(milliseconds: 200),
  }) : _client = client ?? http.Client(),
       baseUrl = baseUrl ?? ApiConfig.baseUrl,
       maxRetries = maxRetries ?? ApiConfig.maxRetries;

  /// Perform a GET request to the given endpoint with automatic retry on transient errors.
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    Duration? timeout,
    int? customRetries,
  }) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final baseUri = Uri.parse('$baseUrl$cleanEndpoint');

    final uri = queryParameters != null && queryParameters.isNotEmpty
        ? baseUri.replace(
            queryParameters: {...baseUri.queryParameters, ...queryParameters},
          )
        : baseUri;

    final effectiveRetries = customRetries ?? maxRetries;
    int attempt = 0;

    while (true) {
      try {
        AppLogger.debug(
          'GET request: ${uri.path} (attempt ${attempt + 1}/${effectiveRetries + 1})',
          category: LogCategory.api,
        );

        final response = await _client
            .get(uri, headers: {'Accept': 'application/json'})
            .timeout(timeout ?? ApiConfig.timeout);

        // Success (2xx)
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return jsonDecode(response.body);
        }

        // Transient server errors that are eligible for retry
        final isTransientServerCode =
            response.statusCode == 502 ||
            response.statusCode == 503 ||
            response.statusCode == 504;

        if (isTransientServerCode && attempt < effectiveRetries) {
          attempt++;
          final delay = retryBaseDelay * attempt;
          AppLogger.warning(
            'Transient HTTP ${response.statusCode} on $endpoint. Retrying in ${delay.inMilliseconds}ms...',
            category: LogCategory.api,
          );
          await Future.delayed(delay);
          continue;
        }

        // Try decoding error response safely
        dynamic decoded;
        try {
          decoded = jsonDecode(response.body);
        } catch (_) {
          decoded = null;
        }

        final errorObj = decoded is Map<String, dynamic>
            ? decoded['error']
            : null;
        final message = errorObj is Map<String, dynamic>
            ? errorObj['message'] as String? ?? 'Request failed'
            : 'Request failed with status ${response.statusCode}';
        final code = errorObj is Map<String, dynamic>
            ? errorObj['code'] as String?
            : null;

        throw ApiException(
          message,
          statusCode: response.statusCode,
          errorCode: code,
        );
      } on TimeoutException {
        if (attempt < effectiveRetries) {
          attempt++;
          final delay = retryBaseDelay * attempt;
          AppLogger.warning(
            'Request timeout on $endpoint. Retrying in ${delay.inMilliseconds}ms...',
            category: LogCategory.api,
          );
          await Future.delayed(delay);
          continue;
        }
        throw const ApiException(
          'Connection timed out. Server may be offline.',
          statusCode: 408,
        );
      } on http.ClientException catch (e) {
        if (attempt < effectiveRetries) {
          attempt++;
          final delay = retryBaseDelay * attempt;
          AppLogger.warning(
            'ClientException on $endpoint: ${e.message}. Retrying in ${delay.inMilliseconds}ms...',
            category: LogCategory.api,
          );
          await Future.delayed(delay);
          continue;
        }
        throw ApiException(
          'Network connection failed: ${e.message}',
          statusCode: 0,
        );
      } on SocketException catch (e) {
        if (attempt < effectiveRetries) {
          attempt++;
          final delay = retryBaseDelay * attempt;
          AppLogger.warning(
            'SocketException on $endpoint: ${e.message}. Retrying in ${delay.inMilliseconds}ms...',
            category: LogCategory.api,
          );
          await Future.delayed(delay);
          continue;
        }
        throw ApiException(
          'Network connection failed: ${e.message}',
          statusCode: 0,
        );
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException('Unexpected network error: $e');
      }
    }
  }

  void close() {
    _client.close();
  }
}
