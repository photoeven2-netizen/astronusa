import 'package:flutter_test/flutter_test.dart';
import 'package:astro_guide/core/birth_profile.dart';
import 'package:astro_guide/core/matchmaking_calculator.dart';

void main() {
  test('calculates matchmaking compatibility for two birth profiles', () {
    final profileA = BirthProfile(
      fullName: 'Mahroni',
      birthDate: DateTime(1981, 3, 16),
      birthTimeMinutes: 15 * 60,
      cityName: 'Tuban',
      latitude: -6.89,
      longitude: 112.06,
      timeZone: 'Asia/Jakarta',
      ayanamsha: Ayanamsha.tropical,
    );

    final profileB = BirthProfile(
      fullName: 'Siti Rahma',
      birthDate: DateTime(1985, 8, 20),
      birthTimeMinutes: 10 * 60,
      cityName: 'Surabaya',
      latitude: -7.25,
      longitude: 112.75,
      timeZone: 'Asia/Jakarta',
      ayanamsha: Ayanamsha.tropical,
    );

    final calculator = MatchmakingCalculator();
    final result = calculator.calculate(profileA: profileA, profileB: profileB);

    expect(result.wetnan.kategori, isNotEmpty);
    expect(result.wetnan.totalNeptu, greaterThan(0));
    expect(result.zodiac.signA, isNotEmpty);
    expect(result.zodiac.signB, isNotEmpty);
    expect(result.zodiac.persentase, greaterThan(0));
    expect(result.numerologyScore, greaterThan(0));
    expect(result.humanDesignSynergy, isNotEmpty);
  });
}
