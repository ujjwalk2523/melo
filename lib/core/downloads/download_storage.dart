import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../shared/models/song.dart';
import 'download_errors.dart';

/// Manages application-private filesystem storage for downloaded audio files.
class DownloadStorage {
  final Directory? _customBaseDir;

  DownloadStorage([this._customBaseDir]);

  /// Returns the base directory for storing downloads.
  Future<Directory> getBaseDirectory() async {
    if (_customBaseDir != null) {
      if (!await _customBaseDir.exists()) {
        await _customBaseDir.create(recursive: true);
      }
      return _customBaseDir;
    }

    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final meloDir = Directory(p.join(appDocDir.path, 'Melo', 'downloads'));
      if (!await meloDir.exists()) {
        await meloDir.create(recursive: true);
      }
      return meloDir;
    } catch (_) {
      // In headless test environments where path_provider is not mocked
      final tempDir = Directory(
        p.join(Directory.systemTemp.path, 'melo_downloads'),
      );
      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }
      return tempDir;
    }
  }

  /// Sanitizes arbitrary strings (e.g. provider track IDs) into safe directory and file names.
  String sanitizeIdentifier(String id) {
    // Prevent path traversal and remove illegal filesystem characters
    final safe = id.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    return safe.isEmpty ? 'unknown_id' : safe;
  }

  /// Returns the directory dedicated to a specific song.
  Future<Directory> getSongDirectory(Song song) async {
    final baseDir = await getBaseDirectory();
    final safeProvider = sanitizeIdentifier(song.provider);
    final safeId = sanitizeIdentifier(song.id);

    final dir = Directory(p.join(baseDir.path, safeProvider, safeId));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Returns the final, completed audio file location.
  Future<File> getFinalAudioFile(Song song) async {
    final songDir = await getSongDirectory(song);
    return File(p.join(songDir.path, 'audio.file'));
  }

  /// Returns the temporary partial download file location.
  Future<File> getTempAudioFile(Song song) async {
    final songDir = await getSongDirectory(song);
    return File(p.join(songDir.path, 'audio.part'));
  }

  /// Atomically commits a completed `.part` file to the final `audio.file` after validation.
  Future<File> commitTempFile(Song song, {int? expectedSizeBytes}) async {
    final tempFile = await getTempAudioFile(song);
    final finalFile = await getFinalAudioFile(song);

    if (!await tempFile.exists()) {
      throw DownloadCorruptException(
        'Temporary download file does not exist',
        songId: song.id,
      );
    }

    final size = await tempFile.length();
    if (size == 0) {
      await deleteTempFile(song);
      throw DownloadCorruptException(
        'Downloaded file is empty (0 bytes)',
        songId: song.id,
      );
    }

    if (expectedSizeBytes != null &&
        expectedSizeBytes > 0 &&
        size != expectedSizeBytes) {
      await deleteTempFile(song);
      throw DownloadCorruptException(
        'Downloaded file size ($size bytes) does not match expected size ($expectedSizeBytes bytes)',
        songId: song.id,
      );
    }

    // Verify readable by reading header bytes
    try {
      final raf = await tempFile.open(mode: FileMode.read);
      await raf.read(16);
      await raf.close();
    } catch (e) {
      await deleteTempFile(song);
      throw DownloadCorruptException(
        'Downloaded file cannot be read: $e',
        songId: song.id,
      );
    }

    // Atomic move / rename
    if (await finalFile.exists()) {
      await finalFile.delete();
    }
    await tempFile.rename(finalFile.path);

    return finalFile;
  }

  /// Verifies whether an existing completed audio file is valid on disk.
  Future<bool> validateExistingFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;
      final length = await file.length();
      if (length <= 0) return false;

      final raf = await file.open(mode: FileMode.read);
      await raf.read(16);
      await raf.close();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Deletes the temporary `.part` file if it exists.
  Future<void> deleteTempFile(Song song) async {
    try {
      final tempFile = await getTempAudioFile(song);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (_) {}
  }

  /// Deletes the downloaded audio file and directory for a song.
  Future<void> deleteAudioFile(Song song) async {
    try {
      await deleteTempFile(song);
      final finalFile = await getFinalAudioFile(song);
      if (await finalFile.exists()) {
        await finalFile.delete();
      }
      final songDir = await getSongDirectory(song);
      if (await songDir.exists() && (await songDir.list().isEmpty)) {
        await songDir.delete();
      }
    } catch (_) {}
  }

  /// Cleans up any stale temporary `.part` files on application startup.
  Future<int> cleanupStaleTempFiles() async {
    int deletedCount = 0;
    try {
      final baseDir = await getBaseDirectory();
      if (!await baseDir.exists()) return 0;

      await for (final entity in baseDir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File && entity.path.endsWith('.part')) {
          try {
            await entity.delete();
            deletedCount++;
          } catch (_) {}
        }
      }
    } catch (_) {}
    return deletedCount;
  }

  /// Calculates the total bytes consumed by all completed downloads.
  Future<int> calculateTotalStorageBytes() async {
    int totalBytes = 0;
    try {
      final baseDir = await getBaseDirectory();
      if (!await baseDir.exists()) return 0;

      await for (final entity in baseDir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File && !entity.path.endsWith('.part')) {
          try {
            totalBytes += await entity.length();
          } catch (_) {}
        }
      }
    } catch (_) {}
    return totalBytes;
  }

  /// Clears all downloaded audio files from storage.
  Future<void> clearAll() async {
    try {
      final baseDir = await getBaseDirectory();
      if (await baseDir.exists()) {
        await for (final entity in baseDir.list(recursive: false)) {
          await entity.delete(recursive: true);
        }
      }
    } catch (_) {}
  }
}
