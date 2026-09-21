import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'download_errors.dart';

/// Cancellation token to cancel active download streams.
class CancellationToken {
  bool _isCancelled = false;
  final List<void Function()> _listeners = [];

  bool get isCancelled => _isCancelled;

  void cancel() {
    if (_isCancelled) return;
    _isCancelled = true;
    for (final listener in _listeners) {
      listener();
    }
  }

  void addListener(void Function() listener) {
    if (_isCancelled) {
      listener();
    } else {
      _listeners.add(listener);
    }
  }
}

/// Contract for streaming HTTP file downloads to disk.
abstract class DownloadService {
  Future<void> downloadFile({
    required String url,
    required File destinationFile,
    required void Function(int receivedBytes, int totalBytes) onProgress,
    CancellationToken? cancelToken,
  });
}

/// Production implementation of [DownloadService] using streaming HTTP chunk writes.
class HttpDownloadService implements DownloadService {
  final http.Client _client;

  HttpDownloadService({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<void> downloadFile({
    required String url,
    required File destinationFile,
    required void Function(int receivedBytes, int totalBytes) onProgress,
    CancellationToken? cancelToken,
  }) async {
    if (cancelToken?.isCancelled == true) {
      throw const DownloadCancelledException();
    }

    final uri = Uri.parse(url);
    final request = http.Request('GET', uri);
    http.StreamedResponse response;

    try {
      response = await _client.send(request);
    } catch (e) {
      throw NetworkUnavailableException('Failed to connect to download server: $e');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw DownloadNotAuthorizedException('Server returned status ${response.statusCode}');
      }
      if (response.statusCode == 410) {
        throw DownloadUrlExpiredException('Download URL has expired');
      }
      throw UnknownDownloadFailureException('Download HTTP failed with status ${response.statusCode}');
    }

    final totalBytes = response.contentLength ?? 0;
    int receivedBytes = 0;

    IOSink? sink;
    StreamSubscription<List<int>>? subscription;
    final completer = Completer<void>();

    try {
      sink = destinationFile.openWrite(mode: FileMode.write);

      cancelToken?.addListener(() {
        if (!completer.isCompleted) {
          subscription?.cancel();
          sink?.close();
          completer.completeError(const DownloadCancelledException());
        }
      });

      subscription = response.stream.listen(
        (chunk) {
          if (cancelToken?.isCancelled == true) {
            subscription?.cancel();
            sink?.close();
            if (!completer.isCompleted) {
              completer.completeError(const DownloadCancelledException());
            }
            return;
          }

          sink?.add(chunk);
          receivedBytes += chunk.length;
          onProgress(receivedBytes, totalBytes);
        },
        onError: (error) {
          sink?.close();
          if (!completer.isCompleted) {
            completer.completeError(DownloadCorruptException('Stream interrupted: $error'));
          }
        },
        onDone: () async {
          try {
            await sink?.flush();
            await sink?.close();
            if (!completer.isCompleted) {
              completer.complete();
            }
          } catch (e) {
            if (!completer.isCompleted) {
              completer.completeError(StorageFailureException('Failed to write download file: $e'));
            }
          }
        },
        cancelOnError: true,
      );

      await completer.future;
    } catch (e) {
      await sink?.close();
      rethrow;
    }
  }
}

/// Test fake for [DownloadService] enabling controlled deterministic tests.
class FakeDownloadService implements DownloadService {
  bool shouldFail;
  DownloadException? failureException;
  int fakeFileSizeBytes;
  Duration chunkDelay;

  FakeDownloadService({
    this.shouldFail = false,
    this.failureException,
    this.fakeFileSizeBytes = 1024 * 100, // 100 KB
    this.chunkDelay = Duration.zero,
  });

  @override
  Future<void> downloadFile({
    required String url,
    required File destinationFile,
    required void Function(int receivedBytes, int totalBytes) onProgress,
    CancellationToken? cancelToken,
  }) async {
    if (cancelToken?.isCancelled == true) {
      throw const DownloadCancelledException();
    }

    if (shouldFail) {
      throw failureException ?? const NetworkUnavailableException('Fake network error');
    }

    // Ensure parent directory exists
    if (!await destinationFile.parent.exists()) {
      await destinationFile.parent.create(recursive: true);
    }

    final sink = destinationFile.openWrite(mode: FileMode.write);
    const int chunkSize = 1024 * 10;
    int written = 0;

    while (written < fakeFileSizeBytes) {
      if (cancelToken?.isCancelled == true) {
        await sink.close();
        throw const DownloadCancelledException();
      }

      final remaining = fakeFileSizeBytes - written;
      final currentChunk = remaining < chunkSize ? remaining : chunkSize;
      sink.add(List<int>.filled(currentChunk, 0x42));
      written += currentChunk;
      onProgress(written, fakeFileSizeBytes);

      if (chunkDelay > Duration.zero) {
        await Future.delayed(chunkDelay);
      }
    }

    await sink.flush();
    await sink.close();
  }
}
