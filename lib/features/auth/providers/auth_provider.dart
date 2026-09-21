import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/recommendations/providers/recommendation_providers.dart';
import '../../../core/sync/sync_engine.dart';
import '../../../core/sync/sync_providers.dart';
import '../../../core/utils/app_logger.dart';
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
  final Future<void> Function()? _onClearUserData;

  AuthNotifier(this._repository, [this._syncEngine, this._onClearUserData])
    : super(AuthState.initial) {
    restoreSession();
  }

  Future<void> restoreSession() async {
    state = state.copyWith(status: AuthStatus.authenticating);
    final restored = await _repository.restoreSession();
    if (!mounted) return;
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
    AppLogger.info(
      'User logging out. Purging session and isolating state.',
      category: LogCategory.auth,
    );
    await _repository.logout(token);
    await _syncEngine?.resetSyncData();
    if (_onClearUserData != null) {
      try {
        await _onClearUserData();
      } catch (_) {}
    }
    state = AuthState.unauthenticated;
  }

  Future<String> forgotPassword(String email) async {
    return _repository.forgotPassword(email);
  }

  Future<void> updateProfile({String? displayName, String? avatarUrl}) async {
    final token = state.accessToken;
    if (token == null) return;
    try {
      final updated = await _repository.updateProfile(
        token,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
      state = state.copyWith(user: updated);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<bool> deleteAccount() async {
    final token = state.accessToken;
    if (token == null) return false;
    AppLogger.info(
      'User deleting account. Purging all cached data and session tokens.',
      category: LogCategory.auth,
    );
    try {
      await _repository.deleteAccount(token);
      await _syncEngine?.resetSyncData();
      if (_onClearUserData != null) {
        try {
          await _onClearUserData();
        } catch (_) {}
      }
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
  return AuthNotifier(repo, syncEngine, () async {
    try {
      final recNotifier = ref.read(recommendationStateProvider.notifier);
      await recNotifier.resetPersonalization();
    } catch (_) {}
  });
});

final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authStateProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isAuthenticated;
});
