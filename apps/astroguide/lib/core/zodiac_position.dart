class ZodiacPosition {
  const ZodiacPosition({required this.sign, required this.degreeWithinSign});

  static const signs = [
    'Aries',
    'Taurus',
    'Gemini',
    'Cancer',
    'Leo',
    'Virgo',
    'Libra',
    'Scorpio',
    'Sagittarius',
    'Capricorn',
    'Aquarius',
    'Pisces',
  ];

  final String sign;
  final double degreeWithinSign;

  factory ZodiacPosition.fromSiderealLongitude(double longitude) {
    if (!longitude.isFinite || longitude < 0 || longitude >= 360) {
      throw ArgumentError.value(
        longitude,
        'longitude',
        'Expected a longitude from 0 to less than 360.',
      );
    }

    final signIndex = (longitude / 30).floor();
    return ZodiacPosition(
      sign: signs[signIndex],
      degreeWithinSign: longitude - signIndex * 30,
    );
  }
}
