/// Base class for all typed download exceptions in Melo.
sealed class DownloadException implements Exception {
  final String message;
  final String? songId;

  const DownloadException(this.message, {this.songId});

  @override
  String toString() => message;
}

class DownloadNotAuthorizedException extends DownloadException {
  const DownloadNotAuthorizedException(super.message, {super.songId});
}

class DownloadUrlExpiredException extends DownloadException {
  const DownloadUrlExpiredException(super.message, {super.songId});
}

class NetworkUnavailableException extends DownloadException {
  const NetworkUnavailableException([
    super.message = 'Network connection is unavailable.',
    String? songId,
  ]) : super(songId: songId);
}

class InsufficientStorageException extends DownloadException {
  const InsufficientStorageException([
    super.message = 'Insufficient device storage space for download.',
    String? songId,
  ]) : super(songId: songId);
}

class DownloadCancelledException extends DownloadException {
  const DownloadCancelledException([
    super.message = 'Download was cancelled.',
    String? songId,
  ]) : super(songId: songId);
}

class DownloadCorruptException extends DownloadException {
  const DownloadCorruptException(super.message, {super.songId});
}

class ProviderUnavailableException extends DownloadException {
  const ProviderUnavailableException(super.message, {super.songId});
}

class StorageFailureException extends DownloadException {
  const StorageFailureException(super.message, {super.songId});
}

class UnknownDownloadFailureException extends DownloadException {
  const UnknownDownloadFailureException(super.message, {super.songId});
}
