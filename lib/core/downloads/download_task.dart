import 'dart:async';
import '../../shared/models/song.dart';
import 'download_service.dart';
import 'download_state.dart';

/// Represents an active or queued download task managed by [DownloadManager].
class DownloadTask {
  final Song song;
  final CancellationToken cancelToken;
  final StreamController<TrackDownloadState> _stateController;
  TrackDownloadState _state;
  final DateTime createdAt;

  DownloadTask({
    required this.song,
    CancellationToken? cancelToken,
    TrackDownloadState? initialState,
  })  : cancelToken = cancelToken ?? CancellationToken(),
        _stateController = StreamController<TrackDownloadState>.broadcast(),
        _state = initialState ?? TrackDownloadState.notDownloaded(song.id),
        createdAt = DateTime.now();

  String get songId => song.id;

  TrackDownloadState get state => _state;

  Stream<TrackDownloadState> get stateStream => _stateController.stream;

  void updateState(TrackDownloadState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  void cancel() {
    cancelToken.cancel();
  }

  void dispose() {
    _stateController.close();
  }
}
