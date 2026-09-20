import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

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
class ApiClient {
  final http.Client _client;
  final String baseUrl;

  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      baseUrl = baseUrl ?? ApiConfig.baseUrl;

  /// Perform a GET request to the given endpoint.
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    Duration? timeout,
  }) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final baseUri = Uri.parse('$baseUrl$cleanEndpoint');

    final uri = queryParameters != null && queryParameters.isNotEmpty
        ? baseUri.replace(
            queryParameters: {...baseUri.queryParameters, ...queryParameters},
          )
        : baseUri;

    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(timeout ?? ApiConfig.timeout);

      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
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
      throw const ApiException(
        'Connection timed out. Server may be offline.',
        statusCode: 408,
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        'Network connection failed: ${e.message}',
        statusCode: 0,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected network error: $e');
    }
  }

  void close() {
    _client.close();
  }
}
