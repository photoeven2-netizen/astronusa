import 'package:flutter_test/flutter_test.dart';
import 'package:astro_guide/core/numerology.dart';

void main() {
  group('PythagoreanNumerology.calculate', () {
    test('reduces the full name, vowels, and consonants separately', () {
      expect(
        PythagoreanNumerology.calculate('Ada Lovelace'),
        equals(
          const NumerologyNumbers(expression: 9, soulUrge: 1, personality: 8),
        ),
      );
    });

    test(
      'preserves master numbers instead of reducing them to a single digit',
      () {
        expect(PythagoreanNumerology.calculate('AAAAAAAAAAA').expression, 11);
      },
    );

    test('normalizes accented letters and ignores spaces and punctuation', () {
      expect(
        PythagoreanNumerology.calculate('Éva—María'),
        PythagoreanNumerology.calculate('Eva Maria'),
      );
    });

    test('allows zero personality when a name contains only vowels', () {
      expect(PythagoreanNumerology.calculate('Aei').personality, 0);
    });

    test('rejects input that contains no letters', () {
      expect(
        () => PythagoreanNumerology.calculate('123 -'),
        throwsArgumentError,
      );
    });
  });
}
