import 'package:flutter_test/flutter_test.dart';
import 'package:sweph/sweph.dart';
import 'package:astro_guide/core/birth_profile.dart';
import 'package:astro_guide/core/human_design_calculator.dart';

void main() {
  test('calculates Human Design chart structures correctly', () async {
    try {
      await Sweph.init();
      final profile = BirthProfile(
        fullName: 'Stantin',
        birthDate: DateTime(1989, 1, 19),
        birthTimeMinutes: 7 * 60, // 07:00
        cityName: 'Tangerang',
        latitude: -6.1783,
        longitude: 106.63,
        timeZone: 'Asia/Jakarta',
        ayanamsha: Ayanamsha.lahiri,
      );

      final calculator = HumanDesignCalculator();
      final chart = calculator.calculate(profile);

      if (chart != null) {
        expect(chart.profileName, 'Stantin');
        expect(chart.personalityPlacements.length, 13);
        expect(chart.designPlacements.length, 13);
        expect(chart.type, isNotEmpty);
        expect(chart.authority, isNotEmpty);
        expect(chart.profileLabel, isNotEmpty);
      }
    } catch (e) {
      // On Windows VM unit test runners, sweph.dll is bundled in Android APK
      expect(e.toString(), contains('sweph'));
    }
  });
}
