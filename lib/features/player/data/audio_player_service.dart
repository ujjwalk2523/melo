import 'dart:async';

import 'package:just_audio/just_audio.dart' as ja;

/// Processing state of the underlying audio engine.
enum AudioProcessingStatus { idle, loading, buffering, ready, completed }

/// Composite state representing the playback and processing status of the audio engine.
class AudioEngineState {
  final bool isPlaying;
  final AudioProcessingStatus processingStatus;

  const AudioEngineState({
    required this.isPlaying,
    required this.processingStatus,
  });

  @override
  String toString() =>
      'AudioEngineState(isPlaying: $isPlaying, processingStatus: $processingStatus)';
}

/// Abstraction for the audio playback engine to isolate just_audio details from state notifiers.
abstract class AudioPlayerService {
  /// Stream emitting real-time playback position.
  Stream<Duration> get positionStream;

  /// Stream emitting total audio duration once determined.
  Stream<Duration?> get durationStream;

  /// Stream emitting buffered content position for progressive streaming.
  Stream<Duration> get bufferedPositionStream;

  /// Stream emitting combined playback and processing state.
  Stream<AudioEngineState> get playerStateStream;

  /// Current position.
  Duration get position;

  /// Current total duration.
  Duration? get duration;

  /// Current buffered position.
  Duration get bufferedPosition;

  /// Whether audio is actively playing.
  bool get isPlaying;

  /// Loads and prepares an authorized audio stream URL.
  Future<Duration?> setUrl(String url);

  /// Loads and prepares an authorized local audio file path for offline playback.
  Future<Duration?> setFilePath(String filePath);

  /// Starts or resumes playback.
  Future<void> play();

  /// Pauses playback.
  Future<void> pause();

  /// Seeks to a specific timestamp.
  Future<void> seek(Duration position);

  /// Stops playback.
  Future<void> stop();

  /// Disposes audio resources.
  Future<void> dispose();
}

/// Concrete production implementation of [AudioPlayerService] wrapping [ja.AudioPlayer].
class JustAudioPlayerService implements AudioPlayerService {
  final ja.AudioPlayer _player;

  JustAudioPlayerService({ja.AudioPlayer? player})
    : _player = player ?? ja.AudioPlayer();

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;

  @override
  Stream<AudioEngineState> get playerStateStream =>
      _player.playerStateStream.map((ps) {
        final status = switch (ps.processingState) {
          ja.ProcessingState.idle => AudioProcessingStatus.idle,
          ja.ProcessingState.loading => AudioProcessingStatus.loading,
          ja.ProcessingState.buffering => AudioProcessingStatus.buffering,
          ja.ProcessingState.ready => AudioProcessingStatus.ready,
          ja.ProcessingState.completed => AudioProcessingStatus.completed,
        };
        return AudioEngineState(
          isPlaying: ps.playing,
          processingStatus: status,
        );
      });

  @override
  Duration get position => _player.position;

  @override
  Duration? get duration => _player.duration;

  @override
  Duration get bufferedPosition => _player.bufferedPosition;

  @override
  bool get isPlaying => _player.playing;

  @override
  Future<Duration?> setUrl(String url) async {
    try {
      return await _player.setUrl(url);
    } catch (e) {
      throw Exception('Audio engine failed to load stream: $e');
    }
  }

  @override
  Future<Duration?> setFilePath(String filePath) async {
    try {
      return await _player.setFilePath(filePath);
    } catch (e) {
      throw Exception('Audio engine failed to load local file: $e');
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() => _player.dispose();
}

/// In-memory mock audio service for automated headless tests.
class FakeAudioPlayerService implements AudioPlayerService {
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();
  final _bufferedController = StreamController<Duration>.broadcast();
  final _stateController = StreamController<AudioEngineState>.broadcast();

  Duration _currentPosition = Duration.zero;
  Duration? _currentDuration;
  bool _isPlaying = false;
  AudioProcessingStatus _status = AudioProcessingStatus.idle;

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<Duration?> get durationStream => _durationController.stream;

  @override
  Stream<Duration> get bufferedPositionStream => _bufferedController.stream;

  @override
  Stream<AudioEngineState> get playerStateStream => _stateController.stream;

  @override
  Duration get position => _currentPosition;

  @override
  Duration? get duration => _currentDuration;

  @override
  Duration get bufferedPosition => _isPlaying
      ? _currentPosition + const Duration(seconds: 30)
      : Duration.zero;

  @override
  bool get isPlaying => _isPlaying;

  String? lastLoadedUrl;
  String? lastLoadedPath;

  @override
  Future<Duration?> setUrl(String url) async {
    lastLoadedUrl = url;
    lastLoadedPath = null;
    _currentDuration = const Duration(minutes: 3, seconds: 30);
    _status = AudioProcessingStatus.ready;
    _stateController.add(
      AudioEngineState(isPlaying: _isPlaying, processingStatus: _status),
    );
    _durationController.add(_currentDuration);
    return _currentDuration;
  }

  @override
  Future<Duration?> setFilePath(String filePath) async {
    lastLoadedPath = filePath;
    lastLoadedUrl = null;
    _currentDuration = const Duration(minutes: 3, seconds: 30);
    _status = AudioProcessingStatus.ready;
    _stateController.add(
      AudioEngineState(isPlaying: _isPlaying, processingStatus: _status),
    );
    _durationController.add(_currentDuration);
    return _currentDuration;
  }

  @override
  Future<void> play() async {
    _isPlaying = true;
    _status = AudioProcessingStatus.ready;
    _stateController.add(
      AudioEngineState(isPlaying: true, processingStatus: _status),
    );
  }

  @override
  Future<void> pause() async {
    _isPlaying = false;
    _stateController.add(
      AudioEngineState(isPlaying: false, processingStatus: _status),
    );
  }

  @override
  Future<void> seek(Duration target) async {
    _currentPosition = target;
    _positionController.add(target);
  }

  @override
  Future<void> stop() async {
    _isPlaying = false;
    _currentPosition = Duration.zero;
    _status = AudioProcessingStatus.idle;
    _stateController.add(
      AudioEngineState(isPlaying: false, processingStatus: _status),
    );
  }

  /// Test helper to simulate playback position progress.
  void emitPosition(Duration pos) {
    _currentPosition = pos;
    _positionController.add(pos);
  }

  /// Test helper to simulate audio completion event.
  void emitCompleted() {
    _isPlaying = false;
    _status = AudioProcessingStatus.completed;
    _stateController.add(
      AudioEngineState(
        isPlaying: false,
        processingStatus: AudioProcessingStatus.completed,
      ),
    );
  }

  /// Test helper to simulate buffering event.
  void emitBuffering() {
    _status = AudioProcessingStatus.buffering;
    _stateController.add(
      AudioEngineState(
        isPlaying: _isPlaying,
        processingStatus: AudioProcessingStatus.buffering,
      ),
    );
  }

  @override
  Future<void> dispose() async {
    await _positionController.close();
    await _durationController.close();
    await _bufferedController.close();
    await _stateController.close();
  }
}
