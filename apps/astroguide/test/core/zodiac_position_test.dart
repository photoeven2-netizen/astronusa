import 'package:flutter_test/flutter_test.dart';
import 'package:astro_guide/core/zodiac_position.dart';

void main() {
  group('ZodiacPosition.fromSiderealLongitude', () {
    test('maps sign boundaries to the following zodiac sign', () {
      expect(ZodiacPosition.fromSiderealLongitude(30).sign, 'Taurus');
      expect(ZodiacPosition.fromSiderealLongitude(330).sign, 'Pisces');
    });

    test(
      'wraps the final degree into Pisces without rounding across signs',
      () {
        final position = ZodiacPosition.fromSiderealLongitude(359.999999);

        expect(position.sign, 'Pisces');
        expect(position.degreeWithinSign, inInclusiveRange(0, 30));
      },
    );

    test('rejects non-finite and out-of-range longitudes', () {
      expect(
        () => ZodiacPosition.fromSiderealLongitude(double.nan),
        throwsArgumentError,
      );
      expect(
        () => ZodiacPosition.fromSiderealLongitude(-0.01),
        throwsArgumentError,
      );
      expect(
        () => ZodiacPosition.fromSiderealLongitude(360),
        throwsArgumentError,
      );
    });
  });
}
