/// Represents a normalized audio track in the Melo music streaming platform.
class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String artworkUrl;
  final Duration duration;
  final String? streamUrl;
  final String? downloadUrl;
  final bool isDownloadable;
  final String provider; // e.g. 'audius', 'jamendo', 'local', 'mock'
  final String? genre;
  final DateTime? releaseDate;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.artworkUrl,
    required this.duration,
    this.streamUrl,
    this.downloadUrl,
    this.isDownloadable = false,
    required this.provider,
    this.genre,
    this.releaseDate,
  });

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? artworkUrl,
    Duration? duration,
    String? streamUrl,
    String? downloadUrl,
    bool? isDownloadable,
    String? provider,
    String? genre,
    DateTime? releaseDate,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      duration: duration ?? this.duration,
      streamUrl: streamUrl ?? this.streamUrl,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      isDownloadable: isDownloadable ?? this.isDownloadable,
      provider: provider ?? this.provider,
      genre: genre ?? this.genre,
      releaseDate: releaseDate ?? this.releaseDate,
    );
  }

  /// Create a normalized Song instance from the Melo backend API response.
  factory Song.fromJson(Map<String, dynamic> json) {
    final durationSeconds = (json['durationSeconds'] as num?)?.toInt() ?? 0;
    final rawDate = json['releaseDate'] as String?;

    return Song(
      id: json['id'] as String? ?? 'unknown',
      title: json['title'] as String? ?? 'Untitled Track',
      artist: json['artist'] as String? ?? 'Unknown Artist',
      album: json['album'] as String? ?? '',
      artworkUrl: json['artworkUrl'] as String? ?? '',
      duration: Duration(seconds: durationSeconds),
      streamUrl: json['streamUrl'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
      isDownloadable: json['isDownloadable'] as bool? ?? false,
      provider: json['provider'] as String? ?? 'audius',
      genre: json['genre'] as String?,
      releaseDate: rawDate != null ? DateTime.tryParse(rawDate) : null,
    );
  }

  /// Serialize Song into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'artworkUrl': artworkUrl,
      'durationSeconds': duration.inSeconds,
      'streamUrl': streamUrl,
      'downloadUrl': downloadUrl,
      'isDownloadable': isDownloadable,
      'provider': provider,
      'genre': genre,
      'releaseDate': releaseDate?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Song(id: $id, title: $title, artist: $artist)';
}
