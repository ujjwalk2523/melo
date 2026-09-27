import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../features/downloads/domain/download_metadata_repository.dart';
import '../../features/profile/data/user_preferences_repository.dart';
import '../../shared/models/song.dart';
import 'download_errors.dart';
import 'download_permission.dart';
import 'download_repository.dart';
import 'download_service.dart';
import 'download_state.dart';
import 'download_storage.dart';
import 'download_task.dart';

/// Central coordinator for authorized music downloads, queue scheduling, and offline storage.
class DownloadManager {
  final DownloadStorage storage;
  final DownloadService service;
  final DownloadRepository repository;
  final UserPreferencesRepository? preferencesRepo;
  final DownloadPermissionEvaluator _permissionEvaluator;
  final int maxConcurrentDownloads;

  final Map<String, DownloadTask> _activeTasks = {};
  final List<DownloadTask> _pendingQueue = [];
  final Map<String, TrackDownloadState> _stateCache = {};
  final StreamController<Map<String, TrackDownloadState>> _allStatesController =
      StreamController<Map<String, TrackDownloadState>>.broadcast();

  bool _isDisposed = false;
  bool _isProcessingQueue = false;

  /// Function returning whether current network is on Wi-Fi (for Wi-Fi only downloads).
  bool Function()? isWifiConnection;

  DownloadManager({
    required this.storage,
    required this.service,
    required this.repository,
    this.preferencesRepo,
    DownloadPermissionEvaluator? permissionEvaluator,
    this.maxConcurrentDownloads = 2,
    this.isWifiConnection,
  }) : _permissionEvaluator =
           permissionEvaluator ?? const DownloadPermissionEvaluator();

  /// Initializes download manager, cleans stale temp files, and reconciles storage on startup.
  Future<void> initialize() async {
    await storage.cleanupStaleTempFiles();
    await recoverInterruptedDownloads();
  }

  /// Reconciles database records against disk files.
  Future<void> recoverInterruptedDownloads() async {
    try {
      final downloadedSongs = await repository.getDownloadedSongs();
      for (final song in downloadedSongs) {
        final meta = await repository.getMetadata(song.id);
        if (meta != null && meta.status == DownloadStatus.completed) {
          final localPath = meta.localPath;
          if (localPath == null ||
              !await storage.validateExistingFile(localPath)) {
            // File is missing or invalid on disk: mark failed
            await repository.recordFailed(
              songId: song.id,
              errorMessage: 'Downloaded file is missing or unreadable on disk.',
            );
            _updateState(
              song.id,
              TrackDownloadState(
                songId: song.id,
                status: DownloadStatus.failed,
                errorMessage:
                    'Downloaded file is missing or unreadable on disk.',
              ),
            );
          } else {
            _updateState(
              song.id,
              TrackDownloadState(
                songId: song.id,
                status: DownloadStatus.completed,
                progress: 1.0,
                bytesDownloaded: meta.downloadedBytes,
                totalBytes: meta.totalBytes,
                localPath: localPath,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('DownloadManager recovery warning: $e');
    }
  }

  /// Initiates download for a track after verifying provider authorization.
  Future<void> downloadTrack(Song song) async {
    if (_isDisposed) return;

    // STEP 1 & 2: Verify provider authorization
    final permission = _permissionEvaluator.evaluate(song);
    if (!permission.isAuthorized) {
      final reason = (permission is NotAuthorizedDownloadPermission)
          ? (permission.reason ??
                "Offline download isn't available for this track.")
          : 'Download service unavailable.';

      final errState = TrackDownloadState(
        songId: song.id,
        status: DownloadStatus.failed,
        errorMessage: reason,
      );
      _updateState(song.id, errState);
      throw DownloadNotAuthorizedException(reason, songId: song.id);
    }

    // Check duplicate active or queued
    if (_activeTasks.containsKey(song.id)) {
      return;
    }
    if (_pendingQueue.any((t) => t.songId == song.id)) {
      return;
    }

    // Check if already completed and valid
    final existingMeta = await repository.getMetadata(song.id);
    if (existingMeta != null &&
        existingMeta.status == DownloadStatus.completed) {
      if (existingMeta.localPath != null &&
          await storage.validateExistingFile(existingMeta.localPath!)) {
        // Already downloaded and valid
        _updateState(
          song.id,
          TrackDownloadState(
            songId: song.id,
            status: DownloadStatus.completed,
            progress: 1.0,
            bytesDownloaded: existingMeta.downloadedBytes,
            totalBytes: existingMeta.totalBytes,
            localPath: existingMeta.localPath,
          ),
        );
        return;
      }
    }

    // Check Wi-Fi only requirement if configured
    final prefs = preferencesRepo?.getPreferences();
    if (prefs?.downloadOnWifiOnly == true && isWifiConnection != null) {
      if (!isWifiConnection!()) {
        final pendingState = TrackDownloadState(
          songId: song.id,
          status: DownloadStatus.pending,
          errorMessage: 'Waiting for Wi-Fi connection...',
        );
        _updateState(song.id, pendingState);
        final task = DownloadTask(song: song, initialState: pendingState);
        _pendingQueue.add(task);
        return;
      }
    }

    final pendingState = TrackDownloadState(
      songId: song.id,
      status: DownloadStatus.pending,
      progress: 0.0,
    );
    _updateState(song.id, pendingState);

    final task = DownloadTask(song: song, initialState: pendingState);
    _pendingQueue.add(task);

    _processNextInQueue();
  }

  /// Cancels an active or queued download.
  Future<void> cancelDownload(String songId) async {
    // 1. If queued
    final queueIndex = _pendingQueue.indexWhere((t) => t.songId == songId);
    if (queueIndex != -1) {
      final task = _pendingQueue.removeAt(queueIndex);
      task.cancel();
      task.dispose();
      await repository.recordCancelled(songId);
      await storage.deleteTempFile(task.song);
      _updateState(songId, TrackDownloadState.notDownloaded(songId));
      return;
    }

    // 2. If actively downloading
    final activeTask = _activeTasks[songId];
    if (activeTask != null) {
      activeTask.cancel();
      await storage.deleteTempFile(activeTask.song);
      await repository.recordCancelled(songId);
      _activeTasks.remove(songId);
      activeTask.dispose();
      _updateState(songId, TrackDownloadState.notDownloaded(songId));
      _processNextInQueue();
    }
  }

  /// Retries a failed download.
  Future<void> retryDownload(Song song) async {
    await cancelDownload(song.id);
    await downloadTrack(song);
  }

  /// Removes a completed download and deletes local files.
  Future<void> removeDownload(Song song) async {
    await cancelDownload(song.id);
    await storage.deleteAudioFile(song);
    await repository.removeDownload(song.id);
    _updateState(song.id, TrackDownloadState.notDownloaded(song.id));
  }

  /// Clears all downloaded tracks, cancels active tasks, and wipes audio files.
  Future<void> clearAllDownloads() async {
    // Cancel all queued
    for (final task in List.of(_pendingQueue)) {
      task.cancel();
      task.dispose();
    }
    _pendingQueue.clear();

    // Cancel all active
    for (final task in List.of(_activeTasks.values)) {
      task.cancel();
      task.dispose();
    }
    _activeTasks.clear();

    // Wipe storage files
    await storage.clearAll();

    // Clear database records
    final downloaded = await repository.getDownloadedSongs();
    for (final s in downloaded) {
      await repository.removeDownload(s.id);
      _updateState(s.id, TrackDownloadState.notDownloaded(s.id));
    }

    _stateCache.clear();
    _allStatesController.add({});
  }

  /// Returns current download state for a song.
  TrackDownloadState getTrackDownloadState(String songId) {
    return _stateCache[songId] ?? TrackDownloadState.notDownloaded(songId);
  }

  /// Stream of download state updates for a specific song.
  Stream<TrackDownloadState> watchTrackDownloadState(String songId) {
    return _allStatesController.stream
        .map((map) => map[songId] ?? TrackDownloadState.notDownloaded(songId))
        .distinct();
  }

  /// Awaits completion, cancellation, or failure of a track download task.
  Future<TrackDownloadState> waitUntilComplete(
    String songId, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final current = getTrackDownloadState(songId);
    if (current.status == DownloadStatus.completed ||
        current.status == DownloadStatus.failed ||
        current.status == DownloadStatus.cancelled) {
      return current;
    }
    return watchTrackDownloadState(songId)
        .firstWhere(
          (s) =>
              s.status == DownloadStatus.completed ||
              s.status == DownloadStatus.failed ||
              s.status == DownloadStatus.cancelled,
        )
        .timeout(timeout);
  }

  /// Continuous stream of downloaded song IDs.
  Stream<Set<String>> watchDownloadedSongIds() {
    return repository.watchDownloadedSongIds();
  }

  /// Queries all downloaded songs.
  Future<List<Song>> getDownloadedSongs() {
    return repository.getDownloadedSongs();
  }

  /// Total bytes used by audio downloads.
  Future<int> getTotalStorageBytes() {
    return storage.calculateTotalStorageBytes();
  }

  void _updateState(String songId, TrackDownloadState state) {
    _stateCache[songId] = state;
    if (!_allStatesController.isClosed) {
      _allStatesController.add(Map.unmodifiable(_stateCache));
    }
  }

  void _processNextInQueue() {
    if (_isDisposed || _isProcessingQueue) return;
    _isProcessingQueue = true;

    try {
      while (_activeTasks.length < maxConcurrentDownloads &&
          _pendingQueue.isNotEmpty) {
        final task = _pendingQueue.removeAt(0);
        _startTask(task);
      }
    } finally {
      _isProcessingQueue = false;
    }
  }

  void _startTask(DownloadTask task) {
    final song = task.song;
    _activeTasks[song.id] = task;

    _updateState(
      song.id,
      TrackDownloadState(
        songId: song.id,
        status: DownloadStatus.downloading,
        progress: 0.0,
      ),
    );

    // Run download asynchronously
    () async {
      try {
        await repository.recordDownloadStarted(song);
        final tempFile = await storage.getTempAudioFile(song);

        final targetUrl = (song.downloadUrl?.trim().isNotEmpty == true)
            ? song.downloadUrl!.trim()
            : (song.streamUrl?.trim() ?? '');

        await service.downloadFile(
          url: targetUrl,
          destinationFile: tempFile,
          cancelToken: task.cancelToken,
          onProgress: (received, total) {
            final progress = total > 0
                ? (received / total).clamp(0.0, 1.0)
                : 0.0;
            final progressState = TrackDownloadState(
              songId: song.id,
              status: DownloadStatus.downloading,
              progress: progress,
              bytesDownloaded: received,
              totalBytes: total,
            );
            _updateState(song.id, progressState);
            task.updateState(progressState);
            repository.recordProgress(
              songId: song.id,
              bytesDownloaded: received,
              totalBytes: total,
            );
          },
        );

        if (task.cancelToken.isCancelled) {
          throw const DownloadCancelledException();
        }

        // Commit and validate file
        final committedFile = await storage.commitTempFile(song);
        final fileSize = await committedFile.length();

        await repository.recordCompleted(
          songId: song.id,
          localPath: committedFile.path,
          totalBytes: fileSize,
        );

        final completedState = TrackDownloadState(
          songId: song.id,
          status: DownloadStatus.completed,
          progress: 1.0,
          bytesDownloaded: fileSize,
          totalBytes: fileSize,
          localPath: committedFile.path,
        );
        _updateState(song.id, completedState);
        task.updateState(completedState);
      } on DownloadCancelledException {
        if (!_isDisposed) {
          await storage.deleteTempFile(song);
          await repository.recordCancelled(song.id);
          _updateState(song.id, TrackDownloadState.notDownloaded(song.id));
        }
      } catch (e) {
        if (!_isDisposed) {
          try {
            await storage.deleteTempFile(song);
          } catch (_) {}
          final errorMsg = e.toString();
          try {
            await repository.recordFailed(
              songId: song.id,
              errorMessage: errorMsg,
            );
          } catch (_) {}

          final failedState = TrackDownloadState(
            songId: song.id,
            status: DownloadStatus.failed,
            errorMessage: errorMsg,
          );
          _updateState(song.id, failedState);
          task.updateState(failedState);
        }
      } finally {
        _activeTasks.remove(song.id);
        task.dispose();
        _processNextInQueue();
      }
    }();
  }

  void dispose() {
    _isDisposed = true;
    for (final task in _activeTasks.values) {
      task.cancel();
      task.dispose();
    }
    _activeTasks.clear();
    for (final task in _pendingQueue) {
      task.cancel();
      task.dispose();
    }
    _pendingQueue.clear();
    _allStatesController.close();
  }
}
