import 'package:flutter_test/flutter_test.dart';
import 'package:astro_guide/core/birth_city.dart';

void main() {
  test('reads a GeoNames city without retaining unrelated source fields', () {
    final city = BirthCity.fromJson({
      'id': 1642911,
      'name': 'Jakarta',
      'regionCode': '04',
      'latitude': -6.2088,
      'longitude': 106.8456,
      'timeZone': 'Asia/Jakarta',
      'population': 8540121,
      'unusedSourceField': 'ignored',
    });

    expect(city.name, 'Jakarta');
    expect(city.timeZone, 'Asia/Jakarta');
    expect(city.latitude, -6.2088);
  });

  test('rejects missing timezone or out-of-range coordinates', () {
    expect(
      () => BirthCity.fromJson({
        'id': 1,
        'name': 'Invalid',
        'regionCode': '00',
        'latitude': -6.2,
        'longitude': 999,
        'timeZone': '',
      }),
      throwsFormatException,
    );
  });
}
