import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../network/api_config.dart';
import 'sync_queue.dart';

class SyncRepositoryException implements Exception {
  final String message;
  final int? statusCode;

  const SyncRepositoryException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class CloudSyncData {
  final List<Map<String, dynamic>> favorites;
  final List<Map<String, dynamic>> playlists;
  final List<Map<String, dynamic>> playlistSongs;
  final List<Map<String, dynamic>> history;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic> metadata;
  final DateTime serverTimestamp;

  const CloudSyncData({
    required this.favorites,
    required this.playlists,
    required this.playlistSongs,
    required this.history,
    this.preferences,
    required this.metadata,
    required this.serverTimestamp,
  });

  factory CloudSyncData.fromJson(Map<String, dynamic> json) {
    return CloudSyncData(
      favorites: (json['favorites'] as List? ?? [])
          .cast<Map<String, dynamic>>(),
      playlists: (json['playlists'] as List? ?? [])
          .cast<Map<String, dynamic>>(),
      playlistSongs: (json['playlistSongs'] as List? ?? [])
          .cast<Map<String, dynamic>>(),
      history: (json['history'] as List? ?? []).cast<Map<String, dynamic>>(),
      preferences: json['preferences'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      serverTimestamp: json['serverTimestamp'] != null
          ? DateTime.parse(json['serverTimestamp'] as String)
          : DateTime.now(),
    );
  }
}

class SyncRepository {
  final http.Client _client;
  final String _baseUrl;

  SyncRepository({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Future<CloudSyncData> pullState(String token) async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/sync/state'), headers: _headers(token))
          .timeout(ApiConfig.timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return CloudSyncData.fromJson(body);
      } else {
        throw SyncRepositoryException(
          'Failed to pull sync state',
          response.statusCode,
        );
      }
    } on SocketException {
      throw const SyncRepositoryException('Cannot reach server (offline)');
    } catch (e) {
      if (e is SyncRepositoryException) rethrow;
      throw SyncRepositoryException(e.toString());
    }
  }

  Future<int> pushOperations(
    String token,
    List<SyncQueueOperation> operations,
  ) async {
    if (operations.isEmpty) return 0;
    try {
      final payload = {
        'operations': operations.map((o) => o.toApiPayload()).toList(),
      };

      final response = await _client
          .post(
            Uri.parse('$_baseUrl/sync/push'),
            headers: _headers(token),
            body: jsonEncode(payload),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['processedCount'] as int? ?? operations.length;
      } else {
        throw SyncRepositoryException(
          'Failed to push sync operations',
          response.statusCode,
        );
      }
    } on SocketException {
      throw const SyncRepositoryException('Cannot reach server (offline)');
    } catch (e) {
      if (e is SyncRepositoryException) rethrow;
      throw SyncRepositoryException(e.toString());
    }
  }

  Future<CloudSyncData> fullSync(
    String token,
    List<SyncQueueOperation> operations,
  ) async {
    try {
      final payload = {
        'operations': operations.map((o) => o.toApiPayload()).toList(),
      };

      final response = await _client
          .post(
            Uri.parse('$_baseUrl/sync'),
            headers: _headers(token),
            body: jsonEncode(payload),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return CloudSyncData.fromJson(body['state'] as Map<String, dynamic>);
      } else {
        throw SyncRepositoryException('Full sync failed', response.statusCode);
      }
    } on SocketException {
      throw const SyncRepositoryException('Cannot reach server (offline)');
    } catch (e) {
      if (e is SyncRepositoryException) rethrow;
      throw SyncRepositoryException(e.toString());
    }
  }
}
