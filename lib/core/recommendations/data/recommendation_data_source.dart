import 'package:melo/core/recommendations/domain/recommendation_feedback.dart';
import 'package:melo/features/playlists/domain/playlist_models.dart';
import 'package:melo/features/profile/data/user_preferences_repository.dart';
import 'package:melo/shared/models/song.dart';

/// Abstract contract for reading user music interaction data and storing feedback.
abstract class RecommendationDataSource {
  Future<List<Song>> getFavorites();
  Future<List<Song>> getListeningHistory();
  Future<List<Playlist>> getPlaylists();
  Future<List<Song>> getPlaylistSongs(String playlistId);
  Future<List<Song>> getDownloadedSongs();
  Future<List<Song>> getCatalogSongs();
  Future<List<RecommendationFeedback>> getFeedback();
  Future<void> saveFeedback(RecommendationFeedback feedback);
  Future<void> clearFeedback();
  UserPreferences getPreferences();
}
