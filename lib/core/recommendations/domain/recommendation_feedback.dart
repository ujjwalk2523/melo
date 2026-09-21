/// Type of negative or tuning feedback provided by the listener.
enum FeedbackType {
  hideSong,
  hideArtist,
  hideGenre,
  lessLikeThis,
  notInterested,
}

/// A structured feedback event modifying local recommendation affinities.
class RecommendationFeedback {
  final int? id;
  final FeedbackType feedbackType;
  final String targetId; // Song ID, Artist name, or Genre name
  final String targetType; // 'song', 'artist', 'genre'
  final DateTime createdAt;

  RecommendationFeedback({
    this.id,
    required this.feedbackType,
    required this.targetId,
    required this.targetType,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'feedbackType': feedbackType.name,
      'targetId': targetId,
      'targetType': targetType,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RecommendationFeedback.fromJson(Map<String, dynamic> json) {
    return RecommendationFeedback(
      id: json['id'] as int?,
      feedbackType: FeedbackType.values.firstWhere(
        (e) => e.name == json['feedbackType'],
        orElse: () => FeedbackType.notInterested,
      ),
      targetId: json['targetId'] as String? ?? '',
      targetType: json['targetType'] as String? ?? 'song',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
