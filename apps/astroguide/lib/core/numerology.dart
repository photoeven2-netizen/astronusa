import 'package:diacritic/diacritic.dart';

class NumerologyNumbers {
  const NumerologyNumbers({
    required this.expression,
    required this.soulUrge,
    required this.personality,
  });

  final int expression;
  final int soulUrge;
  final int personality;

  @override
  bool operator ==(Object other) =>
      other is NumerologyNumbers &&
      other.expression == expression &&
      other.soulUrge == soulUrge &&
      other.personality == personality;

  @override
  int get hashCode => Object.hash(expression, soulUrge, personality);
}

class PythagoreanNumerology {
  PythagoreanNumerology._();

  static const Map<String, int> _values = {
    'A': 1,
    'J': 1,
    'S': 1,
    'B': 2,
    'K': 2,
    'T': 2,
    'C': 3,
    'L': 3,
    'U': 3,
    'D': 4,
    'M': 4,
    'V': 4,
    'E': 5,
    'N': 5,
    'W': 5,
    'F': 6,
    'O': 6,
    'X': 6,
    'G': 7,
    'P': 7,
    'Y': 7,
    'H': 8,
    'Q': 8,
    'Z': 8,
    'I': 9,
    'R': 9,
  };

  static const Set<int> _masterNumbers = {11, 22, 33};
  static const Set<String> _vowels = {'A', 'E', 'I', 'O', 'U'};

  static NumerologyNumbers calculate(String fullName) {
    final normalized = removeDiacritics(fullName.trim().toUpperCase());
    final letters = normalized.split('').where(_values.containsKey).toList();
    if (letters.isEmpty) {
      throw ArgumentError.value(
        fullName,
        'fullName',
        'Enter a name containing letters.',
      );
    }

    final expression = _reduce(
      letters.fold<int>(0, (sum, letter) => sum + _values[letter]!),
    );
    final soulUrge = _reduce(
      letters
          .where(_vowels.contains)
          .fold<int>(0, (sum, letter) => sum + _values[letter]!),
    );
    final personality = _reduce(
      letters
          .where((letter) => !_vowels.contains(letter))
          .fold<int>(0, (sum, letter) => sum + _values[letter]!),
    );

    return NumerologyNumbers(
      expression: expression,
      soulUrge: soulUrge,
      personality: personality,
    );
  }

  static int _reduce(int value) {
    while (value > 9 && !_masterNumbers.contains(value)) {
      value = value
          .toString()
          .split('')
          .fold<int>(0, (sum, digit) => sum + int.parse(digit));
    }
    return value;
  }
}
