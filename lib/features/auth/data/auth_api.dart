import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/network/api_config.dart';
import '../domain/auth_user.dart';

class AuthApiException implements Exception {
  final String message;
  final int? statusCode;

  const AuthApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class AuthTokensResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  const AuthTokensResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthTokensResponse.fromJson(Map<String, dynamic> json) {
    return AuthTokensResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: json['expiresIn'] as int? ?? 3600,
    );
  }
}

class AuthLoginResult {
  final AuthUser user;
  final AuthTokensResponse tokens;

  const AuthLoginResult({required this.user, required this.tokens});
}

class AuthApi {
  final http.Client _client;
  final String _baseUrl;

  AuthApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  Map<String, String> _headers([String? token]) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<AuthLoginResult> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/auth/register'),
            headers: _headers(),
            body: jsonEncode({
              'email': email,
              'password': password,
              'displayName': displayName,
            }),
          )
          .timeout(ApiConfig.timeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final user = AuthUser.fromJson(body['user'] as Map<String, dynamic>);
        final tokens = AuthTokensResponse.fromJson(body['tokens'] as Map<String, dynamic>);
        return AuthLoginResult(user: user, tokens: tokens);
      } else {
        throw AuthApiException(
          body['message'] as String? ?? 'Registration failed',
          response.statusCode,
        );
      }
    } on SocketException {
      throw const AuthApiException('Cannot reach server. Please check your network connection.');
    } catch (e) {
      if (e is AuthApiException) rethrow;
      throw AuthApiException(e.toString());
    }
  }

  Future<AuthLoginResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/auth/login'),
            headers: _headers(),
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(ApiConfig.timeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final user = AuthUser.fromJson(body['user'] as Map<String, dynamic>);
        final tokens = AuthTokensResponse.fromJson(body['tokens'] as Map<String, dynamic>);
        return AuthLoginResult(user: user, tokens: tokens);
      } else {
        throw AuthApiException(
          body['message'] as String? ?? 'Invalid email or password',
          response.statusCode,
        );
      }
    } on SocketException {
      throw const AuthApiException('Cannot reach server. Please check your network connection.');
    } catch (e) {
      if (e is AuthApiException) rethrow;
      throw AuthApiException(e.toString());
    }
  }

  Future<AuthTokensResponse> refresh(String refreshToken) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/auth/refresh'),
            headers: _headers(),
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(ApiConfig.timeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return AuthTokensResponse.fromJson(body['tokens'] as Map<String, dynamic>);
      } else {
        throw AuthApiException(
          body['message'] as String? ?? 'Session refresh failed',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is AuthApiException) rethrow;
      throw AuthApiException(e.toString());
    }
  }

  Future<void> logout([String? token]) async {
    try {
      await _client
          .post(Uri.parse('$_baseUrl/auth/logout'), headers: _headers(token))
          .timeout(ApiConfig.timeout);
    } catch (_) {
      // Best-effort remote notification
    }
  }

  Future<String> forgotPassword(String email) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/auth/forgot-password'),
            headers: _headers(),
            body: jsonEncode({'email': email}),
          )
          .timeout(ApiConfig.timeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['message'] as String? ??
          'If an account exists for this email, a password reset link has been sent.';
    } catch (e) {
      return 'If an account exists for this email, a password reset link has been sent.';
    }
  }

  Future<AuthUser> getMe(String token) async {
    final response = await _client
        .get(Uri.parse('$_baseUrl/auth/me'), headers: _headers(token))
        .timeout(ApiConfig.timeout);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AuthUser.fromJson(body);
    } else {
      throw AuthApiException(
        body['message'] as String? ?? 'Failed to load profile',
        response.statusCode,
      );
    }
  }

  Future<AuthUser> updateMe(String token, {String? displayName, String? avatarUrl}) async {
    final response = await _client
        .patch(
          Uri.parse('$_baseUrl/auth/me'),
          headers: _headers(token),
          body: jsonEncode({
            'displayName': ?displayName,
            'avatarUrl': ?avatarUrl,
          }),
        )
        .timeout(ApiConfig.timeout);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AuthUser.fromJson(body);
    } else {
      throw AuthApiException(
        body['message'] as String? ?? 'Failed to update profile',
        response.statusCode,
      );
    }
  }

  Future<void> deleteMe(String token) async {
    final response = await _client
        .delete(Uri.parse('$_baseUrl/auth/me'), headers: _headers(token))
        .timeout(ApiConfig.timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw AuthApiException(
        body['message'] as String? ?? 'Failed to delete account',
        response.statusCode,
      );
    }
  }
}
