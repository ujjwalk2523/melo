import 'song.dart';

/// Represents a curated or user-created playlist in Melo.
class Playlist {
  final String id;
  final String title;
  final String description;
  final String artworkUrl;
  final List<Song> songs;
  final bool isCurated;
  final String creator;
  final String? badge;

  const Playlist({
    required this.id,
    required this.title,
    required this.description,
    required this.artworkUrl,
    required this.songs,
    this.isCurated = true,
    this.creator = 'Melo Editorial',
    this.badge,
  });

  int get trackCount => songs.length;

  Duration get totalDuration {
    return songs.fold(Duration.zero, (prev, song) => prev + song.duration);
  }
}
