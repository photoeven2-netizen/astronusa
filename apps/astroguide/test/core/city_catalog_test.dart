import 'package:flutter_test/flutter_test.dart';
import 'package:astro_guide/core/city_catalog.dart';

void main() {
  test(
    'searches the offline catalog by city name without a network request',
    () {
      final catalog = CityCatalog.fromRecords([
        {
          'id': 1,
          'name': 'Jakarta',
          'regionCode': '04',
          'latitude': -6.2,
          'longitude': 106.8,
          'timeZone': 'Asia/Jakarta',
          'population': 8000000,
        },
        {
          'id': 2,
          'name': 'Surabaya',
          'regionCode': '08',
          'latitude': -7.2,
          'longitude': 112.7,
          'timeZone': 'Asia/Jakarta',
          'population': 2800000,
        },
      ]);

      expect(catalog.search('sura').map((city) => city.name), ['Surabaya']);
      expect(catalog.search('no matching city'), isEmpty);
    },
  );
}
