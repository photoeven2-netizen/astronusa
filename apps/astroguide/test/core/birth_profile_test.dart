import 'package:flutter_test/flutter_test.dart';
import 'package:astro_guide/core/birth_profile.dart';

void main() {
  group('BirthProfile', () {
    final profile = BirthProfile(
      fullName: 'Nadia Putri',
      birthDate: DateTime(1995, 8, 14),
      birthTimeMinutes: 390,
      cityName: 'Jakarta',
      latitude: -6.2088,
      longitude: 106.8456,
      timeZone: 'Asia/Jakarta',
      ayanamsha: Ayanamsha.lahiri,
    );

    test('round-trips profile fields through local JSON storage', () {
      expect(BirthProfile.fromJson(profile.toJson()), profile);
    });

    test('supports a deliberately unknown birth time', () {
      final unknownTime = profile.copyWith(clearBirthTime: true);

      expect(unknownTime.birthTimeMinutes, isNull);
      expect(BirthProfile.fromJson(unknownTime.toJson()), unknownTime);
    });

    test('rejects invalid time-of-day values when reading stored data', () {
      expect(
        () => BirthProfile.fromJson({
          ...profile.toJson(),
          'birthTimeMinutes': 1440,
        }),
        throwsFormatException,
      );
    });
  });
}
