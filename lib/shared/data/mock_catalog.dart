import '../models/album.dart';
import '../models/artist.dart';
import '../models/playlist.dart';
import '../models/song.dart';

/// Comprehensive fictional music catalog for Melo.
///
/// All content, artists, and songs are completely original and fictional.
abstract final class MockCatalog {
  // ---------------------------------------------------------------------------
  // Fictional Songs (20 tracks across 7 genres)
  // ---------------------------------------------------------------------------
  static const List<Song> songs = [
    Song(
      id: 'melo-001',
      title: 'Midnight Reverie',
      artist: 'Kaelen Vance',
      album: 'Neon Horizons',
      artworkUrl: '',
      duration: Duration(minutes: 3, seconds: 42),
      isDownloadable: true,
      provider: 'melo-mock',
      genre: 'Synthwave',
    ),
    Song(
      id: 'melo-002',
      title: 'Solar Flare',
      artist: 'Astraea',
      album: 'Starlit Orbit',
      artworkUrl: '',
      duration: Duration(minutes: 4, seconds: 15),
      isDownloadable: true,
      provider: 'melo-mock',
      genre: 'Electronic',
    ),
    Song(
      id: 'melo-003',
      title: 'Velvet Rain',
      artist: 'Sora & The Echoes',
      album: 'Quiet Nights',
      artworkUrl: '',
      duration: Duration(minutes: 2, seconds: 58),
      isDownloadable: true,
      provider: 'melo-mock',
      genre: 'Lo-Fi Chill',
    ),
    Song(
      id: 'melo-004',
      title: 'Gravity Well',
      artist: 'Nebula Drift',
      album: 'Deep Space',
      artworkUrl: '',
      duration: Duration(minutes: 5, seconds: 10),
      isDownloadable: true,
      provider: 'melo-mock',
      genre: 'Ambient',
    ),
    Song(
      id: 'melo-005',
      title: 'Obsidian Pulse',
      artist: 'Cipher X',
      album: 'Cybernetic Mind',
      artworkUrl: '',
      duration: Duration(minutes: 3, seconds: 24),
      isDownloadable: true,
      provider: 'melo-mock',
      genre: 'Techno',
    ),
    Song(
      id: 'melo-006',
      title: 'Golden Hour Memories',
      artist: 'Maya Lin',
      album: 'Sundown Solitude',
      artworkUrl: '',
      duration: Duration(minutes: 3, seconds: 50),
      isDownloadable: true,
      provider: 'melo-mock',
      genre: 'Indie Folk',
    ),
    Song(
      id: 'melo-007',
      title: 'Electric Odyssey',
      artist: 'Voltage Crew',
      album: 'High Current',
      artworkUrl: '',
      duration: Duration(minutes: 4, seconds: 04),
      isDownloadable: true,
      provider: 'melo-mock',
      genre: 'Future Bass',
    ),
    Song(
      id: 'melo-008',
      title: 'Echoes in the Mist',
      artist: 'Caelum',
      album: 'Etheria',
      artworkUrl: '',
      duration: Duration(minutes: 4, seconds: 32),
      isDownloadable: true,
      provider: 'melo-mock',
      genre: 'Chillstep',
    ),
    Song(
      id: 'melo-009',
      title: 'Chromatic Dreams',
      artist: 'Kaelen Vance',
      album: 'Neon Horizons',
      artworkUrl: '',
      duration: Duration(minutes: 3, seconds: 18),
      isDownloadable: true,
      provider: 'melo-mock',
      genre: 'Synthwave',
    ),
    Song(
      id: 'melo-010',
      title: 'Luminescent Nights',
      artist: 'Astraea',
      album: 'Starlit Orbit',
      artworkUrl: '',
      duration: Duration(minutes: 3, seconds: 45),
      isDownloadable: true,
      provider: 'melo-mock',
      genre: 'Electronic',
    ),
    Song(
      id: 'melo-011',
      title: 'Coffee in Shibuya',
      artist: 'Sora & The Echoes',
      album: 'Quiet Nights',
      artworkUrl: '',
      duration: Duration(minutes: 2, seconds: 40),
      isDownloadable: true,
      provider: 'melo-mock',
      genre: 'Lo-Fi Chill',
    ),
    Song(
      id: 'melo-012',
      title: 'Quantum Leap',
      artist: 'Cipher X',
      album: 'Cybernetic Mind',
      artworkUrl: '',
      duration: Duration(minutes: 4, seconds: 12),
      isDownloadable: true,
      provider: 'melo-mock',
      genre: 'Techno',
    ),
    Song(
      id: 'melo-013',
      title: 'Event Horizon',
      artist: 'Nebula Drift',
      album: 'Deep Space',
      artworkUrl: '',
      duration: Duration(minutes: 6, seconds: 02),
      isDownloadable: true,
      provider: 'melo-mock',
      genre: 'Ambient',
    ),
    Song(
      id: 'melo-014',
      title: 'Autumn Leaves Falling',
      artist: 'Maya Lin',
      album: 'Sundown Solitude',
      artworkUrl: '',
      duration: Duration(minutes: 3, seconds: 28),
      isDownloadable: true,
      provider: 'melo-mock',
      genre: 'Indie Folk',
    ),
    Song(
      id: 'melo-015',
      title: 'Subatomic Flow',
      artist: 'Voltage Crew',
      album: 'High Current',
      artworkUrl: '',
      duration: Duration(minutes: 3, seconds: 56),
      isDownloadable: true,
      provider: 'melo-mock',
      genre: 'Future Bass',
    ),
    Song(
      id: 'melo-016',
      title: 'Starlight Mirage',
      artist: 'Caelum',
      album: 'Etheria',
      artworkUrl: '',
      duration: Duration(minutes: 4, seconds: 14),
      isDownloadable: true,
      provider: 'melo-mock',
      genre: 'Chillstep',
    ),
    Song(
      id: 'melo-017',
      title: 'Hyperdrive',
      artist: 'Kaelen Vance',
      album: 'Neon Horizons',
      artworkUrl: '',
      duration: Duration(minutes: 3, seconds: 35),
      isDownloadable: true,
      provider: 'melo-mock',
      genre: 'Synthwave',
    ),
    Song(
      id: 'melo-018',
      title: 'Neon Bloom',
      artist: 'Astraea',
      album: 'Starlit Orbit',
      artworkUrl: '',
      duration: Duration(minutes: 4, seconds: 20),
      isDownloadable: true,
      provider: 'melo-mock',
      genre: 'Electronic',
    ),
    // -------------------------------------------------------------------------
    // Indian Catalog (Hindi, Punjabi, Bhojpuri, Haryanvi, Retro Classics)
    // -------------------------------------------------------------------------
    Song(
      id: 'saavn:vj2tW1iy',
      title: 'Brown Rang',
      artist: 'Yo Yo Honey Singh',
      album: 'International Villager',
      artworkUrl:
          'https://c.saavncdn.com/924/International-Villager-Hindi-2011-20190924062024-500x500.jpg',
      duration: Duration(minutes: 2, seconds: 59),
      streamUrl:
          'https://aac.saavncdn.com/924/3cc1b3208e4661a2bcd85ec5f51ea2eb_320.mp4',
      downloadUrl:
          'https://aac.saavncdn.com/924/3cc1b3208e4661a2bcd85ec5f51ea2eb_320.mp4',
      isDownloadable: true,
      provider: 'saavn',
      genre: 'Punjabi Pop',
    ),
    Song(
      id: 'saavn:47_T2N3p',
      title: 'Casa Tupka Anthemo',
      artist: 'Yo Yo Honey Singh, Priyanshi',
      album: 'Casa Tupka Anthemo',
      artworkUrl:
          'https://c.saavncdn.com/786/Casa-Tupka-Anthemo-Hindi-2026-20260917173352-500x500.jpg',
      duration: Duration(minutes: 3, seconds: 03),
      streamUrl:
          'https://aac.saavncdn.com/786/2f7463095ed2bfab1274c018551b00a2_320.mp4',
      downloadUrl:
          'https://aac.saavncdn.com/786/2f7463095ed2bfab1274c018551b00a2_320.mp4',
      isDownloadable: true,
      provider: 'saavn',
      genre: 'Bollywood',
    ),
    Song(
      id: 'saavn:ShubhCheques',
      title: 'Cheques',
      artist: 'Shubh',
      album: 'Still Rollin',
      artworkUrl:
          'https://c.saavncdn.com/704/Still-Rollin-Punjabi-2023-20230519141012-500x500.jpg',
      duration: Duration(minutes: 3, seconds: 03),
      streamUrl:
          'https://aac.saavncdn.com/704/1d43cfc150d1aef7c597c2a9bec1fa48_320.mp4',
      downloadUrl:
          'https://aac.saavncdn.com/704/1d43cfc150d1aef7c597c2a9bec1fa48_320.mp4',
      isDownloadable: true,
      provider: 'saavn',
      genre: 'Punjabi',
    ),
    Song(
      id: 'saavn:RoopTeraMastana',
      title: 'Roop Tera Mastana',
      artist: 'Kishore Kumar',
      album: 'Aradhana',
      artworkUrl:
          'https://c.saavncdn.com/951/Aradhana-Hindi-1969-20200831154508-500x500.jpg',
      duration: Duration(minutes: 3, seconds: 44),
      streamUrl:
          'https://aac.saavncdn.com/951/567184a01fadc302e3bc9b8c2db37347_sar_320.mp4',
      downloadUrl:
          'https://aac.saavncdn.com/951/567184a01fadc302e3bc9b8c2db37347_sar_320.mp4',
      isDownloadable: true,
      provider: 'saavn',
      genre: 'Retro Classics',
    ),
    Song(
      id: 'saavn:LollypopLageli',
      title: 'Lolly Pop Lageli',
      artist: 'Pawan Singh',
      album: 'Lolly Pop Lageli',
      artworkUrl:
          'https://c.saavncdn.com/391/Lolly-Pop-Lageli-Bhojpuri-2018-20180424-500x500.jpg',
      duration: Duration(minutes: 4, seconds: 28),
      streamUrl:
          'https://aac.saavncdn.com/391/eccfe9538c9a7dd264be19a767f36e51_320.mp4',
      downloadUrl:
          'https://aac.saavncdn.com/391/eccfe9538c9a7dd264be19a767f36e51_320.mp4',
      isDownloadable: true,
      provider: 'saavn',
      genre: 'Bhojpuri',
    ),
    Song(
      id: 'saavn:2Numbari',
      title: '2 Numbari',
      artist: 'Masoom Sharma',
      album: '2 Numbari Lofi',
      artworkUrl:
          'https://c.saavncdn.com/184/2-Numbari-Lofi-Haryanvi-2023-20230725173717-500x500.jpg',
      duration: Duration(minutes: 3, seconds: 15),
      streamUrl:
          'https://aac.saavncdn.com/184/ddff3330d2d9167cad37617ca9480f9c_320.mp4',
      downloadUrl:
          'https://aac.saavncdn.com/184/ddff3330d2d9167cad37617ca9480f9c_320.mp4',
      isDownloadable: true,
      provider: 'saavn',
      genre: 'Haryanvi',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Fictional Artists
  // ---------------------------------------------------------------------------
  static const List<Artist> artists = [
    Artist(
      id: 'art-001',
      name: 'Kaelen Vance',
      genre: 'Synthwave / Retro Electro',
      avatarUrl: '',
      monthlyListeners: 1420000,
      isFollowed: true,
    ),
    Artist(
      id: 'art-002',
      name: 'Astraea',
      genre: 'Atmospheric Electronic',
      avatarUrl: '',
      monthlyListeners: 890000,
      isFollowed: true,
    ),
    Artist(
      id: 'art-003',
      name: 'Sora & The Echoes',
      genre: 'Lo-Fi Chill & Beats',
      avatarUrl: '',
      monthlyListeners: 2340000,
      isFollowed: true,
    ),
    Artist(
      id: 'art-004',
      name: 'Nebula Drift',
      genre: 'Deep Space Ambient',
      avatarUrl: '',
      monthlyListeners: 410000,
      isFollowed: false,
    ),
    Artist(
      id: 'art-005',
      name: 'Cipher X',
      genre: 'Industrial Cyber Techno',
      avatarUrl: '',
      monthlyListeners: 730000,
      isFollowed: false,
    ),
    Artist(
      id: 'art-006',
      name: 'Maya Lin',
      genre: 'Warm Acoustic & Indie Folk',
      avatarUrl: '',
      monthlyListeners: 1150000,
      isFollowed: true,
    ),
    Artist(
      id: 'art-007',
      name: 'Yo Yo Honey Singh',
      genre: 'Desi Hip Hop & Bollywood Pop',
      avatarUrl:
          'https://c.saavncdn.com/artists/Yo_Yo_Honey_Singh_004_20260811095253_500x500.jpg',
      monthlyListeners: 18500000,
      isFollowed: true,
    ),
    Artist(
      id: 'art-008',
      name: 'Shubh',
      genre: 'Punjabi Pop & Hip Hop',
      avatarUrl:
          'https://c.saavncdn.com/704/Still-Rollin-Punjabi-2023-20230519141012-500x500.jpg',
      monthlyListeners: 12400000,
      isFollowed: true,
    ),
    Artist(
      id: 'art-009',
      name: 'Pawan Singh',
      genre: 'Bhojpuri Hits & Folk',
      avatarUrl:
          'https://c.saavncdn.com/391/Lolly-Pop-Lageli-Bhojpuri-2018-20180424-500x500.jpg',
      monthlyListeners: 9800000,
      isFollowed: true,
    ),
    Artist(
      id: 'art-010',
      name: 'Masoom Sharma',
      genre: 'Haryanvi Ragni & Pop',
      avatarUrl:
          'https://c.saavncdn.com/184/2-Numbari-Lofi-Haryanvi-2023-20230725173717-500x500.jpg',
      monthlyListeners: 6500000,
      isFollowed: true,
    ),
    Artist(
      id: 'art-011',
      name: 'Kishore Kumar',
      genre: 'Vintage Bollywood Classics',
      avatarUrl:
          'https://c.saavncdn.com/951/Aradhana-Hindi-1969-20200831154508-500x500.jpg',
      monthlyListeners: 15200000,
      isFollowed: true,
    ),
  ];

  // ---------------------------------------------------------------------------
  // Fictional & Real Albums
  // ---------------------------------------------------------------------------
  static const List<Album> albums = [
    Album(
      id: 'alb-001',
      title: 'Neon Horizons',
      artist: 'Kaelen Vance',
      artworkUrl: '',
      year: 2026,
      trackCount: 10,
      genre: 'Synthwave',
    ),
    Album(
      id: 'alb-002',
      title: 'Starlit Orbit',
      artist: 'Astraea',
      artworkUrl: '',
      year: 2025,
      trackCount: 8,
      genre: 'Electronic',
    ),
    Album(
      id: 'alb-003',
      title: 'Quiet Nights',
      artist: 'Sora & The Echoes',
      artworkUrl: '',
      year: 2026,
      trackCount: 12,
      genre: 'Lo-Fi Chill',
    ),
    Album(
      id: 'alb-004',
      title: 'Cybernetic Mind',
      artist: 'Cipher X',
      artworkUrl: '',
      year: 2025,
      trackCount: 9,
      genre: 'Techno',
    ),
    Album(
      id: 'alb-005',
      title: 'International Villager',
      artist: 'Yo Yo Honey Singh',
      artworkUrl:
          'https://c.saavncdn.com/924/International-Villager-Hindi-2011-20190924062024-500x500.jpg',
      year: 2011,
      trackCount: 14,
      genre: 'Punjabi Pop',
    ),
    Album(
      id: 'alb-006',
      title: 'Still Rollin',
      artist: 'Shubh',
      artworkUrl:
          'https://c.saavncdn.com/704/Still-Rollin-Punjabi-2023-20230519141012-500x500.jpg',
      year: 2023,
      trackCount: 7,
      genre: 'Punjabi',
    ),
    Album(
      id: 'alb-007',
      title: 'Aradhana',
      artist: 'Kishore Kumar',
      artworkUrl:
          'https://c.saavncdn.com/951/Aradhana-Hindi-1969-20200831154508-500x500.jpg',
      year: 1969,
      trackCount: 8,
      genre: 'Retro Classics',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Curated Playlists
  // ---------------------------------------------------------------------------
  static List<Playlist> get playlists => [
    Playlist(
      id: 'pl-desi-01',
      title: 'Desi Bollywood & Punjabi Hits',
      description: 'The biggest Indian bangers: Honey Singh, Shubh, and modern classics.',
      artworkUrl:
          'https://c.saavncdn.com/924/International-Villager-Hindi-2011-20190924062024-500x500.jpg',
      songs: [songs[18], songs[19], songs[20]],
      creator: 'Melo India Editorial',
    ),
    Playlist(
      id: 'pl-bhojpuri-01',
      title: 'Bhojpuri Dhamaka',
      description: 'High-energy regional dance anthems from Pawan Singh & Khesari Lal.',
      artworkUrl:
          'https://c.saavncdn.com/391/Lolly-Pop-Lageli-Bhojpuri-2018-20180424-500x500.jpg',
      songs: [songs[22]],
      creator: 'Melo Bhojpuri',
    ),
    Playlist(
      id: 'pl-haryanvi-01',
      title: 'Haryanvi Top Beats',
      description: 'Heavy bass desi folk and Haryanvi rap bangers by Masoom Sharma.',
      artworkUrl:
          'https://c.saavncdn.com/184/2-Numbari-Lofi-Haryanvi-2023-20230725173717-500x500.jpg',
      songs: [songs[23]],
      creator: 'Melo Haryanvi',
    ),
    Playlist(
      id: 'pl-retro-01',
      title: 'Golden Era: Kishore Kumar & Retro 70s',
      description: 'Evergreen melodies and romantic nostalgia from the golden age.',
      artworkUrl:
          'https://c.saavncdn.com/951/Aradhana-Hindi-1969-20200831154508-500x500.jpg',
      songs: [songs[21]],
      creator: 'Melo Vintage',
    ),
    Playlist(
      id: 'pl-001',
      title: 'Deep Focus & Coding',
      description: 'Flow-state electronic, lo-fi rhythms, and ambient beats.',
      artworkUrl: '',
      songs: [songs[0], songs[2], songs[3], songs[8], songs[10]],
      creator: 'Melo Editorial',
    ),
    Playlist(
      id: 'pl-002',
      title: 'Nocturnal Cyberdrive',
      description:
          'High-octane synthwave and pulsating electro for late drives.',
      artworkUrl: '',
      songs: [songs[0], songs[4], songs[6], songs[8], songs[11], songs[16]],
      creator: 'Melo Editorial',
    ),
  ];
}
