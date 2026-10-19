import 'package:flutter_test/flutter_test.dart';
import 'package:melo/core/lyrics/transliteration_service.dart';

void main() {
  group('TransliterationService Tests', () {
    final transliterator = TransliterationService.instance;

    test('Transliterates Punjabi Gurmukhi lyrics to natural Romanized Punjabi', () {
      // "ਮੇਰੇ ਦਿਲ ਵਿੱਚ ਤੂੰ ਵੱਸਦਾ" -> "Mere dil vich toon vassda"
      final punjabi = 'ਮੇਰੇ ਦਿਲ ਵਿੱਚ ਤੂੰ ਵੱਸਦਾ';
      final result = transliterator.transliterate(punjabi);
      expect(result.toLowerCase(), contains('mere'));
      expect(result.toLowerCase(), contains('dil'));
      expect(result.toLowerCase(), contains('vich'));
      expect(result.toLowerCase(), contains('toon'));
      expect(result.toLowerCase(), contains('vassda'));
    });

    test('Transliterates Hindi Devanagari lyrics to natural Hinglish', () {
      // "केसरिया तेरा इश्क है पिया" -> "Kesariya tera ishq hai piya"
      final hindi = 'केसरिया तेरा इश्क है पिया';
      final result = transliterator.transliterate(hindi);
      expect(result.toLowerCase(), contains('kesariya'));
      expect(result.toLowerCase(), contains('tera'));
      expect(result.toLowerCase(), contains('ishk'));
      expect(result.toLowerCase(), contains('hai'));
      expect(result.toLowerCase(), contains('piya'));
    });

    test('Preserves English lyrics completely untouched', () {
      final english = "I'm in love with the shape of you\nWe push and pull like a magnet do";
      final result = transliterator.transliterate(english);
      expect(result, equals(english));
    });

    test('Detects presence of Indic scripts accurately', () {
      expect(transliterator.containsIndicScript('Starboy'), isFalse);
      expect(transliterator.containsIndicScript('ਕੋਈ ਨੀ'), isTrue);
      expect(transliterator.containsIndicScript('तुम ही हो'), isTrue);
    });
  });
}
