import 'package:flutter_test/flutter_test.dart';
import 'package:astro_guide/core/birth_time_converter.dart';

void main() {
  group('BirthTimeConverter', () {
    test(
      'converts Indonesian local clock time to the matching UTC instant',
      () {
        final utc = BirthTimeConverter.toUtc(
          date: DateTime(2000, 1, 1),
          minutesAfterMidnight: 12 * 60,
          timeZone: 'Asia/Jakarta',
        );

        expect(utc, DateTime.utc(2000, 1, 1, 5));
      },
    );

    test('uses the selected city time zone rather than the device zone', () {
      final utc = BirthTimeConverter.toUtc(
        date: DateTime(2000, 1, 1),
        minutesAfterMidnight: 12 * 60,
        timeZone: 'Asia/Jayapura',
      );

      expect(utc, DateTime.utc(2000, 1, 1, 3));
    });

    test('rejects nonexistent IANA time-zone identifiers', () {
      expect(
        () => BirthTimeConverter.toUtc(
          date: DateTime(2000, 1, 1),
          minutesAfterMidnight: 12 * 60,
          timeZone: 'Not/A_Time_Zone',
        ),
        throwsArgumentError,
      );
    });

    test(
      'rejects invalid times rather than silently rolling into another day',
      () {
        expect(
          () => BirthTimeConverter.toUtc(
            date: DateTime(2000, 1, 1),
            minutesAfterMidnight: 1440,
            timeZone: 'Asia/Jakarta',
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'rejects a local time that is skipped by a daylight-saving change',
      () {
        expect(
          () => BirthTimeConverter.toUtc(
            date: DateTime(2021, 3, 14),
            minutesAfterMidnight: 2 * 60 + 30,
            timeZone: 'America/New_York',
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'rejects an ambiguous local time instead of guessing its UTC offset',
      () {
        expect(
          () => BirthTimeConverter.toUtc(
            date: DateTime(2021, 11, 7),
            minutesAfterMidnight: 60 + 30,
            timeZone: 'America/New_York',
          ),
          throwsArgumentError,
        );
      },
    );
  });
}
