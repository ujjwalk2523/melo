/// High-performance phonetically-accurate transliteration service that converts
/// Punjabi (Gurmukhi) and Hindi (Devanagari) lyrics into natural Romanized Hinglish/English script.
/// English and Latin text are preserved unchanged.
class TransliterationService {
  TransliterationService._();

  static final TransliterationService instance = TransliterationService._();

  // Gurmukhi characters mapping
  static const Map<String, String> _gurmukhiVowels = {
    'ਅ': 'a',
    'ਆ': 'aa',
    'ਇ': 'i',
    'ਈ': 'ee',
    'ਉ': 'u',
    'ਊ': 'oo',
    'ਏ': 'e',
    'ਐ': 'ai',
    'ਓ': 'o',
    'ਔ': 'au',
  };

  static const Map<String, String> _gurmukhiConsonants = {
    'ਕ': 'k',
    'ਖ': 'kh',
    'ਗ': 'g',
    'ਘ': 'gh',
    'ਙ': 'ng',
    'ਚ': 'ch',
    'ਛ': 'chh',
    'ਜ': 'j',
    'ਝ': 'jh',
    'ਞ': 'ny',
    'ਟ': 't',
    'ਠ': 'th',
    'ਡ': 'd',
    'ਢ': 'dh',
    'ਣ': 'n',
    'ਤ': 't',
    'ਥ': 'th',
    'ਦ': 'd',
    'ਧ': 'dh',
    'ਨ': 'n',
    'ਪ': 'p',
    'ਫ': 'ph',
    'ਬ': 'b',
    'ਭ': 'bh',
    'ਮ': 'm',
    'ਯ': 'y',
    'ਰ': 'r',
    'ਲ': 'l',
    'ਲ਼': 'l',
    'ਵ': 'v',
    'ਸ਼': 'sh',
    'ਸ': 's',
    'ਹ': 'h',
    'ਖ਼': 'kh',
    'ਗ਼': 'gh',
    'ਜ਼': 'z',
    'ੜ': 'r',
    'ਫ਼': 'f',
  };

  static const Map<String, String> _gurmukhiMatras = {
    'ਾ': 'aa',
    'ਿ': 'i',
    'ੀ': 'ee',
    'ੁ': 'u',
    'ੂ': 'oo',
    'ੇ': 'e',
    'ੈ': 'ai',
    'ੋ': 'o',
    'ੌ': 'au',
  };

  // Devanagari characters mapping
  static const Map<String, String> _devanagariVowels = {
    'अ': 'a',
    'आ': 'aa',
    'इ': 'i',
    'ई': 'ee',
    'उ': 'u',
    'ऊ': 'oo',
    'ऋ': 'ri',
    'ए': 'e',
    'ऐ': 'ai',
    'ओ': 'o',
    'औ': 'au',
  };

  static const Map<String, String> _devanagariConsonants = {
    'क': 'k',
    'ख': 'kh',
    'ग': 'g',
    'घ': 'gh',
    'ङ': 'ng',
    'च': 'ch',
    'छ': 'chh',
    'ज': 'j',
    'झ': 'jh',
    'ञ': 'ny',
    'ट': 't',
    'ठ': 'th',
    'ड': 'd',
    'ढ': 'dh',
    'ण': 'n',
    'त': 't',
    'थ': 'th',
    'द': 'd',
    'ध': 'dh',
    'न': 'n',
    'प': 'p',
    'फ': 'ph',
    'ब': 'b',
    'भ': 'bh',
    'म': 'm',
    'य': 'y',
    'र': 'r',
    'ल': 'l',
    'व': 'v',
    'श': 'sh',
    'ष': 'sh',
    'स': 's',
    'ह': 'h',
    'क़': 'q',
    'ख़': 'kh',
    'ग़': 'gh',
    'ज़': 'z',
    'ड़': 'r',
    'ढ़': 'rh',
    'फ़': 'f',
  };

  static const Map<String, String> _devanagariMatras = {
    'ा': 'aa',
    'ि': 'i',
    'ी': 'ee',
    'ु': 'u',
    'ू': 'oo',
    'ृ': 'ri',
    'े': 'e',
    'ै': 'ai',
    'ो': 'o',
    'ौ': 'au',
  };

  /// Returns true if the string contains any Gurmukhi or Devanagari characters.
  bool containsIndicScript(String text) {
    for (var i = 0; i < text.length; i++) {
      final code = text.codeUnitAt(i);
      // Devanagari range: 0x0900 - 0x097F
      // Gurmukhi range: 0x0A00 - 0x0A7F
      if ((code >= 0x0900 && code <= 0x097F) || (code >= 0x0A00 && code <= 0x0A7F)) {
        return true;
      }
    }
    return false;
  }

  /// Transliterates text into Romanized Hinglish/English.
  /// If the text is already in Latin/English, returns it unchanged.
  String transliterate(String text) {
    if (!containsIndicScript(text)) {
      return text;
    }

    final buffer = StringBuffer();
    final runes = text.runes.toList();
    final len = runes.length;

    var justAfterAddak = false;

    for (var i = 0; i < len; i++) {
      final ch = String.fromCharCode(runes[i]);
      final code = runes[i];

      // Handle Gurmukhi
      if (code >= 0x0A00 && code <= 0x0A7F) {
        // Addak (ੱ) - double the next consonant
        if (ch == 'ੱ' && i + 1 < len) {
          final nextCh = String.fromCharCode(runes[i + 1]);
          if (_gurmukhiConsonants.containsKey(nextCh)) {
            final mapped = _gurmukhiConsonants[nextCh]!;
            if (mapped != 'ch') {
              buffer.write(mapped[0]);
            }
            justAfterAddak = true;
          }
          continue;
        }

        // Tippi (ੰ) or Bindi (ਂ)
        if (ch == 'ੰ' || ch == 'ਂ') {
          buffer.write('n');
          continue;
        }

        // Independent Vowel
        if (_gurmukhiVowels.containsKey(ch)) {
          buffer.write(_gurmukhiVowels[ch]);
          continue;
        }

        // Matra
        if (_gurmukhiMatras.containsKey(ch)) {
          var matraVal = _gurmukhiMatras[ch]!;
          if (ch == 'ਾ') {
            final isWordEnd = (i + 1 >= len) || runes[i + 1] == 32 || runes[i + 1] == 10;
            matraVal = isWordEnd ? 'a' : 'aa';
          }
          buffer.write(matraVal);
          continue;
        }

        // Virama (੍)
        if (ch == '੍') {
          continue;
        }

        // Consonant
        if (_gurmukhiConsonants.containsKey(ch)) {
          final rom = _gurmukhiConsonants[ch]!;
          buffer.write(rom);

          var hasMatraOrVirama = false;
          if (justAfterAddak) {
            hasMatraOrVirama = true;
            justAfterAddak = false;
          } else if (i + 1 < len) {
            final nextChar = String.fromCharCode(runes[i + 1]);
            final nextCode = runes[i + 1];
            if (_gurmukhiMatras.containsKey(nextChar) || nextChar == '੍' || nextChar == 'ੰ' || nextChar == 'ਂ') {
              hasMatraOrVirama = true;
            } else if (nextCode < 0x0A00 || nextCode > 0x0A7F || nextChar == ' ' || nextChar == '\n' || nextChar == ',' || nextChar == '.') {
              // Word boundary: omit final schwa
              hasMatraOrVirama = true;
            }
          } else {
            hasMatraOrVirama = true;
          }

          if (!hasMatraOrVirama) {
            buffer.write('a');
          }
          continue;
        }
      }

      // Handle Devanagari
      if (code >= 0x0900 && code <= 0x097F) {
        // Anusvara (ं) or Chandrabindu (ँ)
        if (ch == 'ं' || ch == 'ँ') {
          buffer.write('n');
          continue;
        }

        // Visarga (ः)
        if (ch == 'ः') {
          buffer.write('h');
          continue;
        }

        // Independent Vowel
        if (_devanagariVowels.containsKey(ch)) {
          buffer.write(_devanagariVowels[ch]);
          continue;
        }

        // Matra
        if (_devanagariMatras.containsKey(ch)) {
          buffer.write(_devanagariMatras[ch]);
          continue;
        }

        // Virama (्)
        if (ch == '्') {
          continue;
        }

        // Nukta combinations (e.g. ज़, फ़, ड़)
        String lookupChar = ch;
        if (i + 1 < len && runes[i + 1] == 0x093C) { // Nukta sign
          lookupChar = '$ch\u093C';
          i++; // Consume nukta
        }

        // Consonant
        if (_devanagariConsonants.containsKey(lookupChar)) {
          final rom = _devanagariConsonants[lookupChar]!;
          buffer.write(rom);

          var hasMatraOrVirama = false;
          if (i + 1 < len) {
            final nextChar = String.fromCharCode(runes[i + 1]);
            final nextCode = runes[i + 1];
            if (_devanagariMatras.containsKey(nextChar) || nextChar == '्' || nextChar == 'ं' || nextChar == 'ँ') {
              hasMatraOrVirama = true;
            } else if (nextCode < 0x0900 || nextCode > 0x097F || nextChar == ' ' || nextChar == '\n' || nextChar == ',' || nextChar == '.') {
              // Word boundary: omit final schwa
              hasMatraOrVirama = true;
            }
          } else {
            hasMatraOrVirama = true;
          }

          if (!hasMatraOrVirama) {
            buffer.write('a');
          }
          continue;
        }
      }

      // Default: copy Latin letters, numbers, punctuation, spaces, emojis directly
      buffer.write(ch);
    }

    return _polishHinglish(buffer.toString());
  }

  /// Capitalizes first letters of lines and cleans duplicate spaces.
  String _polishHinglish(String input) {
    final lines = input.split('\n');
    final polished = lines.map((line) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) return '';
      return trimmed[0].toUpperCase() + trimmed.substring(1);
    }).join('\n');
    return polished;
  }
}
