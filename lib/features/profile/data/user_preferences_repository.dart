import 'package:shared_preferences/shared_preferences.dart';

/// User settings and preferences model for Melo audio and storage behavior.
class UserPreferences {
  final String audioQuality;
  final bool gaplessPlayback;
  final bool normalizeVolume;
  final double crossfadeDuration;
  final bool offlineOnly;
  final bool downloadOnWifiOnly;

  const UserPreferences({
    this.audioQuality = 'Hi-Res Lossless (FLAC 24-bit)',
    this.gaplessPlayback = true,
    this.normalizeVolume = true,
    this.crossfadeDuration = 3.0,
    this.offlineOnly = false,
    this.downloadOnWifiOnly = true,
  });

  UserPreferences copyWith({
    String? audioQuality,
    bool? gaplessPlayback,
    bool? normalizeVolume,
    double? crossfadeDuration,
    bool? offlineOnly,
    bool? downloadOnWifiOnly,
  }) {
    return UserPreferences(
      audioQuality: audioQuality ?? this.audioQuality,
      gaplessPlayback: gaplessPlayback ?? this.gaplessPlayback,
      normalizeVolume: normalizeVolume ?? this.normalizeVolume,
      crossfadeDuration: crossfadeDuration ?? this.crossfadeDuration,
      offlineOnly: offlineOnly ?? this.offlineOnly,
      downloadOnWifiOnly: downloadOnWifiOnly ?? this.downloadOnWifiOnly,
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
}
