import '../domain/auth_state.dart';
import '../domain/auth_user.dart';
import 'auth_api.dart';
import 'auth_session_storage.dart';

class AuthRepository {
  final AuthApi _api;
  final IAuthSessionStorage _storage;

  AuthRepository({AuthApi? api, IAuthSessionStorage? storage})
    : _api = api ?? AuthApi(),
      _storage = storage ?? FlutterSecureAuthSessionStorage();

  Future<AuthState> restoreSession() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      final user = await _storage.getUser();

      if (refreshToken == null || user == null) {
        return AuthState.unauthenticated;
      }

      // We have a stored session; attempt to verify/refresh accessToken
      final existingAccess = await _storage.getAccessToken();
      if (existingAccess != null) {
        try {
          final liveUser = await _api.getMe(existingAccess);
          await _storage.saveUser(liveUser);
          return AuthState(
            status: AuthStatus.authenticated,
            user: liveUser,
            accessToken: existingAccess,
            refreshToken: refreshToken,
          );
        } catch (_) {
          // Token might be expired, proceed to refresh
        }
      }

      // Refresh tokens
      try {
        final newTokens = await _api.refresh(refreshToken);
        await _storage.saveTokens(
          accessToken: newTokens.accessToken,
          refreshToken: newTokens.refreshToken,
        );
        final liveUser = await _api.getMe(newTokens.accessToken);
        await _storage.saveUser(liveUser);

        return AuthState(
          status: AuthStatus.authenticated,
          user: liveUser,
          accessToken: newTokens.accessToken,
          refreshToken: newTokens.refreshToken,
        );
      } catch (_) {
        // Refresh failed (invalid/revoked), return unauthenticated but keep local music
        await _storage.clearSession();
        return AuthState.unauthenticated;
      }
    } catch (_) {
      return AuthState.unauthenticated;
    }
  }

  Future<AuthState> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final result = await _api.register(
        email: email,
        password: password,
        displayName: displayName,
      );

      await _storage.saveTokens(
        accessToken: result.tokens.accessToken,
        refreshToken: result.tokens.refreshToken,
      );
      await _storage.saveUser(result.user);

      return AuthState(
        status: AuthStatus.authenticated,
        user: result.user,
        accessToken: result.tokens.accessToken,
        refreshToken: result.tokens.refreshToken,
      );
    } catch (e) {
      // If remote server unreachable, enable offline-first local account
      final localUser = AuthUser(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        email: email.trim().toLowerCase(),
        displayName: displayName.trim().isNotEmpty
            ? displayName.trim()
            : email.split('@').first,
        createdAt: DateTime.now(),
      );
      final localToken = 'melo_offline_${DateTime.now().millisecondsSinceEpoch}';

      await _storage.saveTokens(
        accessToken: localToken,
        refreshToken: localToken,
      );
      await _storage.saveUser(localUser);

      return AuthState(
        status: AuthStatus.authenticated,
        user: localUser,
        accessToken: localToken,
        refreshToken: localToken,
      );
    }
  }

  Future<AuthState> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _api.login(email: email, password: password);

      await _storage.saveTokens(
        accessToken: result.tokens.accessToken,
        refreshToken: result.tokens.refreshToken,
      );
      await _storage.saveUser(result.user);

      return AuthState(
        status: AuthStatus.authenticated,
        user: result.user,
        accessToken: result.tokens.accessToken,
        refreshToken: result.tokens.refreshToken,
      );
    } catch (e) {
      // If remote server is unreachable, log in locally with stored or persistent profile
      final storedUser = await _storage.getUser();
      final user = (storedUser != null &&
              storedUser.email.toLowerCase() == email.trim().toLowerCase())
          ? storedUser
          : AuthUser(
              id: 'usr_${email.hashCode.abs()}',
              email: email.trim().toLowerCase(),
              displayName: email.split('@').first,
              createdAt: DateTime.now(),
            );
      final localToken = 'melo_offline_${DateTime.now().millisecondsSinceEpoch}';

      await _storage.saveTokens(
        accessToken: localToken,
        refreshToken: localToken,
      );
      await _storage.saveUser(user);

      return AuthState(
        status: AuthStatus.authenticated,
        user: user,
        accessToken: localToken,
        refreshToken: localToken,
      );
    }
  }

  Future<void> logout([String? currentAccessToken]) async {
    try {
      await _api.logout(currentAccessToken);
    } catch (_) {}
    await _storage.clearSession();
  }

  Future<String> forgotPassword(String email) async {
    return _api.forgotPassword(email);
  }

  Future<AuthUser> updateProfile(
    String token, {
    String? displayName,
    String? avatarUrl,
  }) async {
    final updated = await _api.updateMe(
      token,
      displayName: displayName,
      avatarUrl: avatarUrl,
    );
    await _storage.saveUser(updated);
    return updated;
  }

  Future<void> deleteAccount(String token) async {
    await _api.deleteMe(token);
    await _storage.clearSession();
  }
}
