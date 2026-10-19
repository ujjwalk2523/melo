import 'song.dart';

/// Represents a musical album or EP in Melo.
class Album {
  final String id;
  final String title;
  final String artist;
  final String artworkUrl;
  final int year;
  final int trackCount;
  final String genre;
  final List<Song> songs;

  const Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.artworkUrl,
    required this.year,
    required this.trackCount,
    required this.genre,
    this.songs = const [],
  });
}
