import 'package:melo/shared/models/song.dart';

/// Represents a user-created or system playlist in Melo.
class Playlist {
  final String id;
  final String name;
  final String? description;
  final String? artworkUrl;
  final int trackCount;
  final List<Song> songs;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Playlist({
    required this.id,
    required this.name,
    this.description,
    this.artworkUrl,
    this.trackCount = 0,
    this.songs = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    String? artworkUrl,
    int? trackCount,
    List<Song>? songs,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      trackCount: trackCount ?? this.trackCount,
      songs: songs ?? this.songs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
