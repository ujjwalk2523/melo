import '../../../core/network/api_client.dart';
import '../../../shared/models/song.dart';

/// API client specifically for executing music search and track queries.
class SearchApi {
  final ApiClient _client;

  SearchApi([ApiClient? client]) : _client = client ?? ApiClient();

  /// Search songs through the Melo backend API.
  Future<List<Song>> searchSongs(
    String query, {
    String? provider,
    int? limit,
  }) async {
    final queryParams = <String, String>{'q': query};
    if (provider != null) queryParams['provider'] = provider;
    if (limit != null) queryParams['limit'] = limit.toString();

    final response = await _client.get('/search', queryParameters: queryParams);

    if (response is Map<String, dynamic> && response['results'] is List) {
      final rawList = response['results'] as List;
      return rawList
          .map((item) => Song.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return const [];
  }

  /// Fetch a specific track by its provider and track ID.
  Future<Song?> getTrack(String provider, String trackId) async {
    final response = await _client.get('/tracks/$provider/$trackId');
    if (response is Map<String, dynamic> &&
        response['data'] is Map<String, dynamic>) {
      return Song.fromJson(response['data'] as Map<String, dynamic>);
    }
    return null;
  }
}
