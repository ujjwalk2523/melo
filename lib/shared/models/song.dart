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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Song(id: $id, title: $title, artist: $artist)';
}
