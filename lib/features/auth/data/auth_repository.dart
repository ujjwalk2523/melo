import '../domain/auth_state.dart';
import '../domain/auth_user.dart';
import 'auth_api.dart';
import 'auth_session_storage.dart';

class AuthRepository {
  final AuthApi _api;
  final IAuthSessionStorage _storage;

  AuthRepository({
    AuthApi? api,
    IAuthSessionStorage? storage,
  })  : _api = api ?? AuthApi(),
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
    } on AuthApiException catch (e) {
      return AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      return AuthState(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred during registration',
      );
    }
  }

  Future<AuthState> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _api.login(
        email: email,
        password: password,
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
    } on AuthApiException catch (e) {
      return AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      return AuthState(
        status: AuthStatus.error,
        errorMessage: 'Unable to connect to login server',
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

  Future<AuthUser> updateProfile(String token, {String? displayName, String? avatarUrl}) async {
    final updated = await _api.updateMe(token, displayName: displayName, avatarUrl: avatarUrl);
    await _storage.saveUser(updated);
    return updated;
  }

  Future<void> deleteAccount(String token) async {
    await _api.deleteMe(token);
    await _storage.clearSession();
  }
}
