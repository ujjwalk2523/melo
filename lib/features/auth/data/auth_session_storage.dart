import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/auth_user.dart';

abstract class IAuthSessionStorage {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveUser(AuthUser user);
  Future<AuthUser?> getUser();
  Future<void> clearSession();
}

class FlutterSecureAuthSessionStorage implements IAuthSessionStorage {
  final FlutterSecureStorage _storage;

  static const _keyAccessToken = 'melo_secure_access_token';
  static const _keyRefreshToken = 'melo_secure_refresh_token';
  static const _keyUser = 'melo_secure_user_profile';

  FlutterSecureAuthSessionStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  @override
  Future<String?> getAccessToken() async {
    return _storage.read(key: _keyAccessToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _storage.read(key: _keyRefreshToken);
  }

  @override
  Future<void> saveUser(AuthUser user) async {
    final raw = jsonEncode(user.toJson());
    await _storage.write(key: _keyUser, value: raw);
  }

  @override
  Future<AuthUser?> getUser() async {
    final raw = await _storage.read(key: _keyUser);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AuthUser.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyUser);
  }
}

/// In-memory implementation of IAuthSessionStorage for testing and environments without platform channels.
class InMemoryAuthSessionStorage implements IAuthSessionStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _data['access'] = accessToken;
    _data['refresh'] = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async => _data['access'];

  @override
  Future<String?> getRefreshToken() async => _data['refresh'];

  @override
  Future<void> saveUser(AuthUser user) async {
    _data['user'] = jsonEncode(user.toJson());
  }

  @override
  Future<AuthUser?> getUser() async {
    final raw = _data['user'];
    if (raw == null) return null;
    return AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> clearSession() async {
    _data.clear();
  }
}
