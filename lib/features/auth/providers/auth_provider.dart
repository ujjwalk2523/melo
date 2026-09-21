import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sync/sync_engine.dart';
import '../../../core/sync/sync_providers.dart';
import '../data/auth_api.dart';
import '../data/auth_repository.dart';
import '../data/auth_session_storage.dart';
import '../domain/auth_state.dart';
import '../domain/auth_user.dart';

final authSessionStorageProvider = Provider<IAuthSessionStorage>((ref) {
  return FlutterSecureAuthSessionStorage();
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.watch(authSessionStorageProvider);
  final api = ref.watch(authApiProvider);
  return AuthRepository(api: api, storage: storage);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final SyncEngine? _syncEngine;

  AuthNotifier(this._repository, [this._syncEngine]) : super(AuthState.initial) {
    restoreSession();
  }

  Future<void> restoreSession() async {
    state = state.copyWith(status: AuthStatus.authenticating);
    final restored = await _repository.restoreSession();
    state = restored;
    if (restored.isAuthenticated && restored.accessToken != null) {
      _syncEngine?.performLoginSync(restored.accessToken!, restored.user!.id);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.authenticating, clearError: true);
    final result = await _repository.login(email: email, password: password);
    state = result;
    if (result.isAuthenticated && result.accessToken != null) {
      _syncEngine?.performLoginSync(result.accessToken!, result.user!.id);
    }
    return result.isAuthenticated;
  }

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating, clearError: true);
    final result = await _repository.register(
      email: email,
      password: password,
      displayName: displayName,
    );
    state = result;
    if (result.isAuthenticated && result.accessToken != null) {
      _syncEngine?.performLoginSync(result.accessToken!, result.user!.id);
    }
    return result.isAuthenticated;
  }

  Future<void> logout() async {
    final token = state.accessToken;
    await _repository.logout(token);
    state = AuthState.unauthenticated;
  }

  Future<String> forgotPassword(String email) async {
    return _repository.forgotPassword(email);
  }

  Future<void> updateProfile({String? displayName, String? avatarUrl}) async {
    final token = state.accessToken;
    if (token == null) return;
    try {
      final updated = await _repository.updateProfile(token,
          displayName: displayName, avatarUrl: avatarUrl);
      state = state.copyWith(user: updated);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<bool> deleteAccount() async {
    final token = state.accessToken;
    if (token == null) return false;
    try {
      await _repository.deleteAccount(token);
      state = AuthState.unauthenticated;
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete account');
      return false;
    }
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final syncEngine = ref.watch(syncEngineProvider);
  return AuthNotifier(repo, syncEngine);
});

final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authStateProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isAuthenticated;
});
