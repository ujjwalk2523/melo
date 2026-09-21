enum SyncStatus { idle, syncing, success, offline, error, pending }

class SyncState {
  final SyncStatus status;
  final DateTime? lastSuccessfulSyncAt;
  final DateTime? lastAttemptedSyncAt;
  final int pendingCount;
  final String? lastError;
  final bool isOnline;

  const SyncState({
    this.status = SyncStatus.idle,
    this.lastSuccessfulSyncAt,
    this.lastAttemptedSyncAt,
    this.pendingCount = 0,
    this.lastError,
    this.isOnline = true,
  });

  String get humanReadableStatus {
    switch (status) {
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.offline:
        return 'Offline — changes saved locally';
      case SyncStatus.error:
        return 'Sync failed — retry';
      case SyncStatus.pending:
        return pendingCount > 0
            ? '$pendingCount changes pending sync'
            : 'Pending sync';
      case SyncStatus.success:
      case SyncStatus.idle:
        if (lastSuccessfulSyncAt == null) {
          return 'Local only — Log in to sync';
        }
        final diff = DateTime.now().difference(lastSuccessfulSyncAt!);
        if (diff.inMinutes < 1) {
          return 'Synced just now';
        } else if (diff.inHours < 1) {
          return 'Synced ${diff.inMinutes}m ago';
        } else if (diff.inDays < 1) {
          return 'Synced ${diff.inHours}h ago';
        } else {
          return 'Synced ${diff.inDays}d ago';
        }
    }
  }

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSuccessfulSyncAt,
    DateTime? lastAttemptedSyncAt,
    int? pendingCount,
    String? lastError,
    bool? isOnline,
    bool clearError = false,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSuccessfulSyncAt: lastSuccessfulSyncAt ?? this.lastSuccessfulSyncAt,
      lastAttemptedSyncAt: lastAttemptedSyncAt ?? this.lastAttemptedSyncAt,
      pendingCount: pendingCount ?? this.pendingCount,
      lastError: clearError ? null : (lastError ?? this.lastError),
      isOnline: isOnline ?? this.isOnline,
    );
  }

  static const initial = SyncState();
}
