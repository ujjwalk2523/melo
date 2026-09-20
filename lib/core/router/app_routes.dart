/// Centralized route paths and route names for Melo.
abstract final class AppRoutes {
  static const String home = '/home';
  static const String search = '/search';
  static const String library = '/library';
  static const String profile = '/profile';

  // Future Detail & Player Routes (Prepared for subsequent phases)
  static const String player = '/player/:songId';
  static const String artist = '/artist/:artistId';
  static const String album = '/album/:albumId';
  static const String playlist = '/playlist/:playlistId';

  static String playerPath(String songId) => '/player/$songId';
  static String artistPath(String artistId) => '/artist/$artistId';
  static String albumPath(String albumId) => '/album/$albumId';
  static String playlistPath(String playlistId) => '/playlist/$playlistId';
}
