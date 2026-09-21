import '../../shared/models/song.dart';

/// Represents typed authorization permission for downloading a specific audio track.
sealed class DownloadPermission {
  const DownloadPermission();

  const factory DownloadPermission.authorized({
    required String url,
    DateTime? expiresAt,
  }) = AuthorizedDownloadPermission;

  const factory DownloadPermission.notAuthorized({String? reason}) =
      NotAuthorizedDownloadPermission;

  const factory DownloadPermission.unavailable({String? reason}) =
      UnavailableDownloadPermission;

  bool get isAuthorized => this is AuthorizedDownloadPermission;
}

class AuthorizedDownloadPermission extends DownloadPermission {
  final String url;
  final DateTime? expiresAt;

  const AuthorizedDownloadPermission({required this.url, this.expiresAt});

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

class NotAuthorizedDownloadPermission extends DownloadPermission {
  final String? reason;

  const NotAuthorizedDownloadPermission({
    this.reason = "Offline download isn't available for this track.",
  });
}

class UnavailableDownloadPermission extends DownloadPermission {
  final String? reason;

  const UnavailableDownloadPermission({
    this.reason = 'Download service is currently unavailable.',
  });
}

/// Evaluates provider download permissions from normalized song metadata.
class DownloadPermissionEvaluator {
  const DownloadPermissionEvaluator();

  /// Evaluates whether downloading is authorized according to provider metadata.
  DownloadPermission evaluate(Song song) {
    if (!song.isDownloadable) {
      return const DownloadPermission.notAuthorized(
        reason: "Offline download isn't available for this track.",
      );
    }

    final url = song.downloadUrl?.trim();
    if (url == null || url.isEmpty) {
      return const DownloadPermission.notAuthorized(
        reason: 'Provider did not supply an authorized download URL.',
      );
    }

    return DownloadPermission.authorized(url: url);
  }
}
