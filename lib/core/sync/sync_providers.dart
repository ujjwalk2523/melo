import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database_providers.dart';
import 'sync_engine.dart';
import 'sync_queue.dart';
import 'sync_repository.dart';
import 'sync_state.dart';

final syncQueueProvider = Provider<SyncQueue>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SyncQueue(db);
});

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SyncRepository();
});

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final queue = ref.watch(syncQueueProvider);
  final api = ref.watch(syncRepositoryProvider);
  final prefs = ref.watch(userPreferencesRepositoryProvider);

  final engine = SyncEngine(
    db: db,
    queue: queue,
    api: api,
    preferencesRepo: prefs,
  );

  ref.onDispose(() => engine.dispose());
  return engine;
});

class SyncStateNotifier extends StateNotifier<SyncState> {
  final SyncEngine _engine;

  SyncStateNotifier(this._engine) : super(_engine.state) {
    _engine.stateStream.listen((newState) {
      state = newState;
    });
  }

  Future<void> syncNow(String? token, String? userId) async {
    await _engine.manualSync(token, userId);
  }
}

final syncStateProvider = StateNotifierProvider<SyncStateNotifier, SyncState>((
  ref,
) {
  final engine = ref.watch(syncEngineProvider);
  return SyncStateNotifier(engine);
});

final syncStatusProvider = Provider<SyncStatus>((ref) {
  return ref.watch(syncStateProvider).status;
});

final lastSyncProvider = Provider<DateTime?>((ref) {
  return ref.watch(syncStateProvider).lastSuccessfulSyncAt;
});
