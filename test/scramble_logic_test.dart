import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Pure logic extracted from _ScrambleMainPageState for testability.
// These functions mirror the implementations in main.dart exactly.
// ---------------------------------------------------------------------------

String scrambleWord(String word) {
  if (word.length <= 1) return word;
  List<String> letters = word.split('')..shuffle();
  String scrambled = letters.join('');
  if (scrambled == word && word.length > 1) {
    return scrambleWord(word);
  }
  return scrambled;
}

List<String> extractWords(String text) {
  return text
      .split(RegExp(r'[\s\p{P}1234567890]+', unicode: true))
      .where((s) => s.isNotEmpty && s.length >= 2)
      .toList();
}

String formatScrambled(String word, {bool isUppercase = true}) {
  return isUppercase ? word.toUpperCase() : word.toLowerCase();
}

/// Simulates _addWordsToList deduplication logic.
List<String> addUniqueWords(List<String> existing, List<String> incoming) {
  final result = List<String>.from(existing);
  for (final word in incoming) {
    final cleaned = word.trim();
    if (cleaned.length >= 2 &&
        !result.any((w) => w.toLowerCase() == cleaned.toLowerCase())) {
      result.add(cleaned);
    }
  }
  return result;
}

// ---------------------------------------------------------------------------

void main() {
  group('scrambleWord', () {
    test('returns single-char words unchanged', () {
      expect(scrambleWord('a'), equals('a'));
      expect(scrambleWord('Z'), equals('Z'));
    });

    test('scrambled word has the same length as original', () {
      const word = 'flutter';
      final scrambled = scrambleWord(word);
      expect(scrambled.length, equals(word.length));
    });

    test('scrambled word contains the same letters as original', () {
      const word = 'scramble';
      final scrambled = scrambleWord(word);
      final sortedOriginal = (word.split('')..sort()).join();
      final sortedScrambled = (scrambled.split('')..sort()).join();
      expect(sortedScrambled, equals(sortedOriginal));
    });

    test('scrambled word is different from original (for longer words)', () {
      // With 8+ letters the chance of same-order shuffle is astronomically low.
      // Run multiple times to be statistically confident.
      const word = 'elephant';
      bool foundDifferent = false;
      for (int i = 0; i < 20; i++) {
        if (scrambleWord(word) != word) {
          foundDifferent = true;
          break;
        }
      }
      expect(foundDifferent, isTrue,
          reason: 'scrambleWord should produce a different order at least once');
    });

    test('two-letter word is always scrambled (swapped)', () {
      // For a 2-letter word the only different arrangement is the swap.
      const word = 'ab';
      final scrambled = scrambleWord(word);
      expect(scrambled, equals('ba'));
    });

    test('empty string returns empty string', () {
      expect(scrambleWord(''), equals(''));
    });
  });

  group('extractWords', () {
    test('splits on whitespace', () {
      expect(extractWords('hello world'), containsAll(['hello', 'world']));
    });

    test('filters out single-character tokens', () {
      final result = extractWords('a big cat');
      expect(result, isNot(contains('a')));
      expect(result, containsAll(['big', 'cat']));
    });

    test('strips punctuation delimiters', () {
      final result = extractWords('cat, dog; bird.');
      expect(result, containsAll(['cat', 'dog', 'bird']));
    });

    test('strips numeric characters', () {
      final result = extractWords('word1 another2word three');
      // Numbers act as separators so "word" and "another" and "word" should appear
      expect(result, contains('three'));
      expect(result, isNot(contains('word1')));
    });

    test('returns empty list for empty string', () {
      expect(extractWords(''), isEmpty);
    });

    test('returns empty list for whitespace-only string', () {
      expect(extractWords('   \n\t  '), isEmpty);
    });

    test('handles multi-line text', () {
      final result = extractWords('apple\nbanana\norange');
      expect(result, containsAll(['apple', 'banana', 'orange']));
    });

    test('ignores tokens shorter than 2 characters', () {
      final result = extractWords('I go to school');
      expect(result, isNot(contains('I')));
      expect(result, containsAll(['go', 'to', 'school']));
    });
  });

  group('formatScrambled', () {
    test('returns uppercase when isUppercase is true', () {
      expect(formatScrambled('hello', isUppercase: true), equals('HELLO'));
    });

    test('returns lowercase when isUppercase is false', () {
      expect(formatScrambled('HELLO', isUppercase: false), equals('hello'));
    });

    test('handles already-uppercase input with uppercase flag', () {
      expect(formatScrambled('WORLD', isUppercase: true), equals('WORLD'));
    });

    test('handles already-lowercase input with lowercase flag', () {
      expect(formatScrambled('world', isUppercase: false), equals('world'));
    });
  });

  group('addUniqueWords (deduplication)', () {
    test('adds new words to empty list', () {
      final result = addUniqueWords([], ['apple', 'banana']);
      expect(result, containsAll(['apple', 'banana']));
      expect(result.length, equals(2));
    });

    test('skips duplicates (case-insensitive)', () {
      final result = addUniqueWords(['Apple'], ['apple', 'APPLE', 'cherry']);
      // Only 'cherry' should be added; 'apple' / 'APPLE' are duplicates
      expect(result.length, equals(2));
      expect(result, contains('cherry'));
    });

    test('skips words shorter than 2 characters', () {
      final result = addUniqueWords([], ['a', 'bb', 'c']);
      expect(result, equals(['bb']));
    });

    test('skips whitespace-only or empty strings after trim', () {
      final result = addUniqueWords([], ['  ', '', 'valid']);
      expect(result, equals(['valid']));
    });

    test('preserves original list order', () {
      final result = addUniqueWords(['cat', 'dog'], ['fish', 'bird']);
      expect(result, equals(['cat', 'dog', 'fish', 'bird']));
    });

    test('does not mutate existing list', () {
      final existing = ['cat'];
      addUniqueWords(existing, ['dog']);
      expect(existing, equals(['cat']));
    });
  });
}
