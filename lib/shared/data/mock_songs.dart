import '../models/song.dart';
import 'mock_catalog.dart';

/// Seeded mock song data for testing UI shells, playback state, and navigation.
abstract final class MockSongs {
  static List<Song> get items => MockCatalog.songs;
}
