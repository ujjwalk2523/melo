import 'package:shared_preferences/shared_preferences.dart';

/// User settings and preferences model for Melo audio and storage behavior.
class UserPreferences {
  final String audioQuality;
  final bool gaplessPlayback;
  final bool normalizeVolume;
  final double crossfadeDuration;
  final bool offlineOnly;
  final bool downloadOnWifiOnly;
  final bool personalizedRecommendations;
  final bool useListeningHistoryForRecs;
  final String discoveryLevel;
  final List<String> preferredLanguages;
  final List<String> preferredArtists;
  final bool hasCompletedOnboarding;
  final bool spotifyCanvasEnabled;

  const UserPreferences({
    this.audioQuality = 'Hi-Res Lossless (FLAC 24-bit)',
    this.gaplessPlayback = true,
    this.normalizeVolume = true,
    this.crossfadeDuration = 3.0,
    this.offlineOnly = false,
    this.downloadOnWifiOnly = true,
    this.personalizedRecommendations = true,
    this.useListeningHistoryForRecs = true,
    this.discoveryLevel = 'balanced',
    this.preferredLanguages = const [
      'Hindi',
      'Punjabi',
      'English',
      'Bhojpuri',
      'Haryanvi',
    ],
    this.preferredArtists = const [
      'Arijit Singh',
      'Yo Yo Honey Singh',
      'Sidhu Moose Wala',
      'Diljit Dosanjh',
      'Shubh',
    ],
    this.hasCompletedOnboarding = false,
    this.spotifyCanvasEnabled = true,
  });

  UserPreferences copyWith({
    String? audioQuality,
    bool? gaplessPlayback,
    bool? normalizeVolume,
    double? crossfadeDuration,
    bool? offlineOnly,
    bool? downloadOnWifiOnly,
    bool? personalizedRecommendations,
    bool? useListeningHistoryForRecs,
    String? discoveryLevel,
    List<String>? preferredLanguages,
    List<String>? preferredArtists,
    bool? hasCompletedOnboarding,
    bool? spotifyCanvasEnabled,
  }) {
    return UserPreferences(
      audioQuality: audioQuality ?? this.audioQuality,
      gaplessPlayback: gaplessPlayback ?? this.gaplessPlayback,
      normalizeVolume: normalizeVolume ?? this.normalizeVolume,
      crossfadeDuration: crossfadeDuration ?? this.crossfadeDuration,
      offlineOnly: offlineOnly ?? this.offlineOnly,
      downloadOnWifiOnly: downloadOnWifiOnly ?? this.downloadOnWifiOnly,
      personalizedRecommendations:
          personalizedRecommendations ?? this.personalizedRecommendations,
      useListeningHistoryForRecs:
          useListeningHistoryForRecs ?? this.useListeningHistoryForRecs,
      discoveryLevel: discoveryLevel ?? this.discoveryLevel,
      preferredLanguages: preferredLanguages ?? this.preferredLanguages,
      preferredArtists: preferredArtists ?? this.preferredArtists,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      spotifyCanvasEnabled:
          spotifyCanvasEnabled ?? this.spotifyCanvasEnabled,
    );
  }
}

/// Repository managing persistent lightweight user preferences.
class UserPreferencesRepository {
  final SharedPreferences _prefs;

  static const _keyAudioQuality = 'pref_audio_quality';
  static const _keyGapless = 'pref_gapless';
  static const _keyNormalize = 'pref_normalize';
  static const _keyCrossfade = 'pref_crossfade';
  static const _keyOfflineOnly = 'pref_offline_only';
  static const _keyDownloadWifiOnly = 'pref_download_wifi_only';
  static const _keyPersonalizedRecs = 'pref_personalized_recs';
  static const _keyUseHistoryForRecs = 'pref_use_history_recs';
  static const _keyDiscoveryLevel = 'pref_discovery_level';
  static const _keyPreferredLanguages = 'pref_preferred_languages';
  static const _keyPreferredArtists = 'pref_preferred_artists';
  static const _keyCompletedOnboarding = 'pref_completed_onboarding';
  static const _keyCanvasEnabled = 'pref_spotify_canvas_enabled';

  UserPreferencesRepository(this._prefs);

  UserPreferences getPreferences() {
    return UserPreferences(
      audioQuality:
          _prefs.getString(_keyAudioQuality) ?? 'Hi-Res Lossless (FLAC 24-bit)',
      gaplessPlayback: _prefs.getBool(_keyGapless) ?? true,
      normalizeVolume: _prefs.getBool(_keyNormalize) ?? true,
      crossfadeDuration: _prefs.getDouble(_keyCrossfade) ?? 3.0,
      offlineOnly: _prefs.getBool(_keyOfflineOnly) ?? false,
      downloadOnWifiOnly: _prefs.getBool(_keyDownloadWifiOnly) ?? true,
      personalizedRecommendations: _prefs.getBool(_keyPersonalizedRecs) ?? true,
      useListeningHistoryForRecs: _prefs.getBool(_keyUseHistoryForRecs) ?? true,
      discoveryLevel: _prefs.getString(_keyDiscoveryLevel) ?? 'balanced',
      preferredLanguages:
          _prefs.getStringList(_keyPreferredLanguages) ??
          const ['Hindi', 'Punjabi', 'English', 'Bhojpuri', 'Haryanvi'],
      preferredArtists:
          _prefs.getStringList(_keyPreferredArtists) ??
          const [
            'Arijit Singh',
            'Yo Yo Honey Singh',
            'Sidhu Moose Wala',
            'Diljit Dosanjh',
            'Shubh',
          ],
      hasCompletedOnboarding:
          _prefs.getBool(_keyCompletedOnboarding) ?? false,
      spotifyCanvasEnabled: _prefs.getBool(_keyCanvasEnabled) ?? true,
    );
  }

  Future<void> setAudioQuality(String quality) async {
    await _prefs.setString(_keyAudioQuality, quality);
  }

  Future<void> setGaplessPlayback(bool enabled) async {
    await _prefs.setBool(_keyGapless, enabled);
  }

  Future<void> setNormalizeVolume(bool enabled) async {
    await _prefs.setBool(_keyNormalize, enabled);
  }

  Future<void> setCrossfadeDuration(double seconds) async {
    await _prefs.setDouble(_keyCrossfade, seconds);
  }

  Future<void> setOfflineOnly(bool enabled) async {
    await _prefs.setBool(_keyOfflineOnly, enabled);
  }

  Future<void> setDownloadOnWifiOnly(bool enabled) async {
    await _prefs.setBool(_keyDownloadWifiOnly, enabled);
  }

  Future<void> setPersonalizedRecommendations(bool enabled) async {
    await _prefs.setBool(_keyPersonalizedRecs, enabled);
  }

  Future<void> setUseListeningHistoryForRecs(bool enabled) async {
    await _prefs.setBool(_keyUseHistoryForRecs, enabled);
  }

  Future<void> setDiscoveryLevel(String level) async {
    await _prefs.setString(_keyDiscoveryLevel, level);
  }

  Future<void> setPreferredLanguages(List<String> languages) async {
    await _prefs.setStringList(_keyPreferredLanguages, languages);
  }

  Future<void> setPreferredArtists(List<String> artists) async {
    await _prefs.setStringList(_keyPreferredArtists, artists);
  }

  Future<void> setHasCompletedOnboarding(bool completed) async {
    await _prefs.setBool(_keyCompletedOnboarding, completed);
  }

  Future<void> setSpotifyCanvasEnabled(bool enabled) async {
    await _prefs.setBool(_keyCanvasEnabled, enabled);
  }

  Future<void> resetPersonalizationPreferences() async {
    await _prefs.remove(_keyPersonalizedRecs);
    await _prefs.remove(_keyUseHistoryForRecs);
    await _prefs.remove(_keyDiscoveryLevel);
    await _prefs.remove(_keyPreferredLanguages);
    await _prefs.remove(_keyPreferredArtists);
    await _prefs.remove(_keyCompletedOnboarding);
  }
}
