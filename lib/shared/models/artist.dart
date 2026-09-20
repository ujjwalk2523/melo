/// Represents a musical artist or creator in Melo.
class Artist {
  final String id;
  final String name;
  final String genre;
  final String avatarUrl;
  final int monthlyListeners;
  final bool isFollowed;

  const Artist({
    required this.id,
    required this.name,
    required this.genre,
    required this.avatarUrl,
    required this.monthlyListeners,
    this.isFollowed = false,
  });

  String get formattedListeners {
    if (monthlyListeners >= 1000000) {
      return '${(monthlyListeners / 1000000).toStringAsFixed(1)}M listeners';
    } else if (monthlyListeners >= 1000) {
      return '${(monthlyListeners / 1000).toStringAsFixed(0)}K listeners';
    }
    return '$monthlyListeners listeners';
  }

  Artist copyWith({
    String? id,
    String? name,
    String? genre,
    String? avatarUrl,
    int? monthlyListeners,
    bool? isFollowed,
  }) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      genre: genre ?? this.genre,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      monthlyListeners: monthlyListeners ?? this.monthlyListeners,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }
}
