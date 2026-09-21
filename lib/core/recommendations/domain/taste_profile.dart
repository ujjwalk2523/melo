/// Aggregated music taste profile representing a listener's affinities and habits.
class TasteProfile {
  final Map<String, double> topArtists;
  final Map<String, double> topGenres;
  final Map<String, double> topAlbums;
  final List<String> recentArtists;
  final List<String> recentGenres;
  final List<String> favoriteProviders;
  final int totalPlays;
  final int totalFavorites;
  final int totalSkips;
  final int totalDownloads;
  final bool isColdStart;

  const TasteProfile({
    this.topArtists = const {},
    this.topGenres = const {},
    this.topAlbums = const {},
    this.recentArtists = const [],
    this.recentGenres = const [],
    this.favoriteProviders = const [],
    this.totalPlays = 0,
    this.totalFavorites = 0,
    this.totalSkips = 0,
    this.totalDownloads = 0,
    this.isColdStart = true,
  });

  /// Factory constructor for brand-new users with zero interaction history.
  factory TasteProfile.empty() => const TasteProfile(isColdStart: true);

  TasteProfile copyWith({
    Map<String, double>? topArtists,
    Map<String, double>? topGenres,
    Map<String, double>? topAlbums,
    List<String>? recentArtists,
    List<String>? recentGenres,
    List<String>? favoriteProviders,
    int? totalPlays,
    int? totalFavorites,
    int? totalSkips,
    int? totalDownloads,
    bool? isColdStart,
  }) {
    return TasteProfile(
      topArtists: topArtists ?? this.topArtists,
      topGenres: topGenres ?? this.topGenres,
      topAlbums: topAlbums ?? this.topAlbums,
      recentArtists: recentArtists ?? this.recentArtists,
      recentGenres: recentGenres ?? this.recentGenres,
      favoriteProviders: favoriteProviders ?? this.favoriteProviders,
      totalPlays: totalPlays ?? this.totalPlays,
      totalFavorites: totalFavorites ?? this.totalFavorites,
      totalSkips: totalSkips ?? this.totalSkips,
      totalDownloads: totalDownloads ?? this.totalDownloads,
      isColdStart: isColdStart ?? this.isColdStart,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topArtists': topArtists,
      'topGenres': topGenres,
      'topAlbums': topAlbums,
      'recentArtists': recentArtists,
      'recentGenres': recentGenres,
      'favoriteProviders': favoriteProviders,
      'totalPlays': totalPlays,
      'totalFavorites': totalFavorites,
      'totalSkips': totalSkips,
      'totalDownloads': totalDownloads,
      'isColdStart': isColdStart,
    };
  }

  factory TasteProfile.fromJson(Map<String, dynamic> json) {
    return TasteProfile(
      topArtists: Map<String, double>.from(json['topArtists'] as Map? ?? {}),
      topGenres: Map<String, double>.from(json['topGenres'] as Map? ?? {}),
      topAlbums: Map<String, double>.from(json['topAlbums'] as Map? ?? {}),
      recentArtists: List<String>.from(json['recentArtists'] as List? ?? []),
      recentGenres: List<String>.from(json['recentGenres'] as List? ?? []),
      favoriteProviders: List<String>.from(json['favoriteProviders'] as List? ?? []),
      totalPlays: (json['totalPlays'] as num?)?.toInt() ?? 0,
      totalFavorites: (json['totalFavorites'] as num?)?.toInt() ?? 0,
      totalSkips: (json['totalSkips'] as num?)?.toInt() ?? 0,
      totalDownloads: (json['totalDownloads'] as num?)?.toInt() ?? 0,
      isColdStart: json['isColdStart'] as bool? ?? true,
    );
  }

  @override
  String toString() =>
      'TasteProfile(artists: ${topArtists.length}, genres: ${topGenres.length}, plays: $totalPlays, coldStart: $isColdStart)';
}
