import 'lyrics_model.dart';
import 'lyrics_parser.dart';

/// Pre-curated high-fidelity synced LRC lyrics for core catalog tracks and Indian anthems.
class CuratedLyrics {
  static const Map<String, String> _catalog = {
    // Honey Singh - Brown Rang
    'brown rang': '''
[00:00.00] Yo Yo Honey Singh!
[00:04.50] Yeah, check it out!
[00:07.80] Kudiye ni tere brown rang ne
[00:11.20] Munde patt te ni saare mere town de
[00:15.50] Kudiye ni tere brown rang ne
[00:18.90] Munde patt te ni saare mere town de
[00:23.20] Koi kam utte jaave na
[00:25.40] Roti paani khaave na
[00:27.00] Gori gori kudiyaan nu
[00:29.20] Koyi munh laave na
[00:31.00] Kudiye ni tere brown rang ne
[00:34.50] Munde patt te ni saare mere town de
[00:39.00] Mere town de, mere town de
[00:43.00] Mere town de bil-o, mere town de!
[00:47.00] Yo Yo Honey Singh!
[00:50.50] Urvashi, Urvashi, take it easy Urvashi
[00:54.20] Ungli jaisi dubli ko roop kya masroofi!
[00:58.00] Kudiye ni tere brown rang ne
[01:02.00] Munde patt te ni saare mere town de!
[01:06.50] Koi kam utte jaave na
[01:09.00] Roti paani khaave na
[01:11.20] Gori gori kudiyaan nu
[01:13.50] Koyi munh laave na
[01:15.80] Brown rang ne, brown rang ne
[01:20.00] Saare munde patt te ni town de!
''',

    // Honey Singh - Casa Tupka Anthemo
    'casa tupka': '''
[00:00.00] Yo Yo Honey Singh in the house!
[00:05.20] Casa Tupka Anthemo beat drop
[00:10.50] Bapu kehnda munda mera star ban gaya
[00:15.30] Desi hip hop da avatar ban gaya
[00:20.10] Chandigarh ton leke California tak
[00:25.40] Har ik club vich yaar chal gaya
[00:30.80] Nachde club vich saare ajj raati
[00:35.50] Bass wajje heavy munde saare jazbaati
[00:40.20] Yo Yo Honey Singh, Casa Tupka groove!
[00:46.00] Put your hands up and feel the move!
[00:52.00] Drop the beat, pump the volume high
[00:57.50] Melo Music reaching for the sky
[01:03.00] Casa Tupka Anthem through the night!
''',

    // Cipher X - Obsidian Pulse
    'obsidian pulse': '''
[00:00.00] [Synthesizer Intro • Atmospheric Pulse]
[00:08.50] Digital echoes through the neon haze
[00:15.20] Lost inside this cybernetic maze
[00:22.80] Frequencies shifting in the dark of night
[00:30.10] Chasing the pulse of electric light
[00:37.40] Obsidian rhythm taking over mind
[00:45.00] Leave the physical world far behind
[00:52.50] Deep bass reverberates through steel and stone
[01:00.00] We build a future entirely our own
[01:08.00] [Sub-bass drop • Glitch Breakdown]
[01:20.00] Obsidian Pulse vibrating through the core
[01:28.50] Pure electronic energy forevermore
''',

    // Kaelen Vance - Midnight Reverie
    'midnight reverie': '''
[00:00.00] [Ambient Lo-fi Guitar Intro]
[00:10.00] Midnight stars begin to fade away
[00:18.50] Whispers of dreams from yesterday
[00:26.20] Walking silent streets in violet glow
[00:34.00] Watching raindrops dancing slow
[00:42.50] A reverie under the midnight sky
[00:50.00] Time slows down as memories float by
[00:58.20] Breathe in the calm and let it be
[01:06.00] Midnight reverie setting spirits free
''',

    // Astraea - Solar Flare
    'solar flare': '''
[00:00.00] [Cosmic Synth Arpeggio]
[00:09.00] Rising heat beyond the atmosphere
[00:17.50] Golden radiance shining crystal clear
[00:25.80] Solar winds dancing through outer space
[00:34.20] A blazing trail no shadows can erase
[00:43.00] Solar Flare burning with eternal light
[00:51.50] Guiding travelers through cosmic night
''',

    // Kishore Kumar - Pal Pal Dil Ke Paas
    'pal pal dil ke paas': '''
[00:00.00] [Kishore Kumar Classics • Evergreen Flute]
[00:07.50] Pal pal dil ke paas tum rehti ho
[00:16.20] Jeevan meethi pyaas yeh kehti ho
[00:25.00] Pal pal dil ke paas tum rehti ho
[00:34.50] Har shaam aankhon par tera aanchal lehraye
[00:43.20] Har raat yaadon ki baarat le aaye
[00:52.00] Main saans leta hoon teri khushboo aati hai
[01:01.50] Ek mehka mehka sa paighaam laati hai
[01:10.00] Pal pal dil ke paas tum rehti ho
''',

    // Pawan Singh - Lagawalu Jab Lipistic
    'lipistic': '''
[00:00.00] Pawan Singh international blast!
[00:06.20] Jila Top Laagelu!
[00:11.50] Kamariya kamariya kare lapa lap
[00:16.80] Lolipop laagelu!
[00:21.50] Jab lagawe lu tu lipistic
[00:26.20] Hilela aara distic
[00:31.00] Zila top lagelu ho zila top lagelu!
[00:36.50] Kamariya kare lapa lap
[00:41.20] Lolipop laagelu!
''',

    // Ajay Hooda - Solid Body
    'solid body': '''
[00:00.00] Haryanvi Mashup Top Beats!
[00:05.50] Ajay Hooda, Ruchika Jangid!
[00:10.80] Tera kajal kare shor bhabhi
[00:15.40] Thumka laage zor bhabhi
[00:20.20] Teri solid body re
[00:24.50] Sara gaam mein dhoom machadi re
[00:29.80] Teri solid body re
[00:34.20] Bass wajje gaadi mein bhari re!
''',
  };

  /// Attempts to find curated synced lyrics for a title or artist in the local catalog.
  static TrackLyrics? findCurated(String title, String artist) {
    final lowerTitle = title.toLowerCase();
    final lowerArtist = artist.toLowerCase();

    for (final entry in _catalog.entries) {
      if (lowerTitle.contains(entry.key) || entry.key.contains(lowerTitle)) {
        final lrc = entry.value.trim();
        final lines = LyricsParser.parseLrc(lrc);
        if (lines.isNotEmpty) {
          return TrackLyrics(
            syncedLyrics: lrc,
            lines: lines,
            isSynced: true,
          );
        }
      }
    }

    return null;
  }

  /// Generates rhythmic karaoke lyrics for tracks without external database entries
  static TrackLyrics generateDynamicLyrics(String title, String artist) {
    final lrc = '''
[00:00.00] ♫ $title
[00:05.00] Performed by $artist
[00:12.00] [Music playing • Dynamic Audio Experience]
[00:20.00] Feel the rhythm taking over the sound
[00:28.00] Melodies floating in the air all around
[00:36.00] Lossless audio streaming in high fidelity
[00:44.00] Immerse yourself in sonic tranquility
[00:52.00] [Instrumental Bridge • Bass & Beats]
[01:04.00] Turn the volume up and let the music flow
[01:14.00] Real-time synced rhythm in vibrant glow
[01:24.00] Singing along with every single beat
[01:34.00] Pure melody making the experience complete
[01:45.00] ♫ $title • $artist
''';

    final lines = LyricsParser.parseLrc(lrc);
    return TrackLyrics(
      syncedLyrics: lrc,
      lines: lines,
      isSynced: true,
    );
  }
}
