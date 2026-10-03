import 'package:flutter_test/flutter_test.dart';
import 'package:melo/core/lyrics/curated_lyrics.dart';
import 'package:melo/core/lyrics/lyrics_model.dart';
import 'package:melo/core/lyrics/lyrics_parser.dart';

void main() {
  group('LyricsParser & LRC Format Tests', () {
    const sampleLrc = '''
[ti:Cheques]
[ar:Shubh]
[al:Still Rollin]
[00:20.67] Je Koyi Shaq Ni, Kar Check Ni
[00:23.53] Biba Jatt Di Aa Challe Sardari
[00:26.26] Lagge Jeck Ni, Wadde Cheque Ni
[00:28.96] Utte Aale Naal Laayi Betha Yaari
[01:26.15]
[01:28.40] (Ch-Ch-Challe Sardari)
''';

    test('parseLrc correctly parses standard timestamps and skips metadata headers', () {
      final lines = LyricsParser.parseLrc(sampleLrc);

      expect(lines.length, equals(6));

      expect(lines[0].time, equals(const Duration(seconds: 20, milliseconds: 670)));
      expect(lines[0].text, equals('Je Koyi Shaq Ni, Kar Check Ni'));

      expect(lines[1].time, equals(const Duration(seconds: 23, milliseconds: 530)));
      expect(lines[1].text, equals('Biba Jatt Di Aa Challe Sardari'));

      expect(lines[3].time, equals(const Duration(seconds: 28, milliseconds: 960)));

      expect(lines[5].time, equals(const Duration(minutes: 1, seconds: 28, milliseconds: 400)));
      expect(lines[5].text, equals('(Ch-Ch-Challe Sardari)'));
    });

    test('parseLrc handles empty content gracefully', () {
      expect(LyricsParser.parseLrc(''), isEmpty);
      expect(LyricsParser.parseLrc('   \n\n  '), isEmpty);
    });

    test('parseLrc handles multiple timestamps on a single line', () {
      const multiTimestampLrc = '[00:10.00][00:25.00] Repeat this hook';
      final lines = LyricsParser.parseLrc(multiTimestampLrc);

      expect(lines.length, equals(2));
      expect(lines[0].time, equals(const Duration(seconds: 10)));
      expect(lines[0].text, equals('Repeat this hook'));
      expect(lines[1].time, equals(const Duration(seconds: 25)));
      expect(lines[1].text, equals('Repeat this hook'));
    });

    test('findActiveIndex returns -1 before first line time', () {
      final lines = LyricsParser.parseLrc(sampleLrc);

      expect(LyricsParser.findActiveIndex(Duration.zero, lines), equals(-1));
      expect(LyricsParser.findActiveIndex(const Duration(seconds: 15), lines), equals(-1));
    });

    test('findActiveIndex accurately identifies current line at exact or intermediate timestamps', () {
      final lines = LyricsParser.parseLrc(sampleLrc);

      // Exactly at first line
      expect(
        LyricsParser.findActiveIndex(const Duration(seconds: 20, milliseconds: 670), lines),
        equals(0),
      );

      // Between first and second line
      expect(
        LyricsParser.findActiveIndex(const Duration(seconds: 22), lines),
        equals(0),
      );

      // At second line
      expect(
        LyricsParser.findActiveIndex(const Duration(seconds: 23, milliseconds: 530), lines),
        equals(1),
      );

      // Past the last line
      expect(
        LyricsParser.findActiveIndex(const Duration(minutes: 2), lines),
        equals(5),
      );
    });
  });

  group('CuratedLyrics & Fallback Generation Tests', () {
    test('CuratedLyrics finds pre-curated lyrics for catalog hits', () {
      final brownRang = CuratedLyrics.findCurated('Brown Rang', 'Yo Yo Honey Singh');
      expect(brownRang, isNotNull);
      expect(brownRang!.isSynced, isTrue);
      expect(brownRang.lines.length, greaterThan(10));
      expect(brownRang.lines.first.text, contains('Honey Singh'));

      final casaTupka = CuratedLyrics.findCurated('Casa Tupka Anthemo', 'Honey Singh');
      expect(casaTupka, isNotNull);
      expect(casaTupka!.isSynced, isTrue);
    });

    test('CuratedLyrics returns null for unknown tracks', () {
      final unknown = CuratedLyrics.findCurated('Unknown 12345 Song', 'Unknown Artist');
      expect(unknown, isNull);
    });

    test('generateDynamicLyrics produces valid synced lines with ordered timestamps', () {
      final dynamicLyrics = CuratedLyrics.generateDynamicLyrics('Custom Song', 'Custom Artist');
      expect(dynamicLyrics.isSynced, isTrue);
      expect(dynamicLyrics.lines.isNotEmpty, isTrue);

      for (int i = 1; i < dynamicLyrics.lines.length; i++) {
        expect(dynamicLyrics.lines[i].time >= dynamicLyrics.lines[i - 1].time, isTrue);
      }
    });
  });
}
