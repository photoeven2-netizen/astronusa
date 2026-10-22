import 'package:timezone/data/latest_all.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

class BirthTimeConverter {
  BirthTimeConverter._();

  static bool _initialized = false;

  static DateTime toUtc({
    required DateTime date,
    required int minutesAfterMidnight,
    required String timeZone,
  }) {
    if (minutesAfterMidnight < 0 || minutesAfterMidnight >= 1440) {
      throw ArgumentError.value(
        minutesAfterMidnight,
        'minutesAfterMidnight',
        'Expected a time within one local day.',
      );
    }
    if (!_initialized) {
      timezone_data.initializeTimeZones();
      _initialized = true;
    }

    late final timezone.Location location;
    try {
      location = timezone.getLocation(timeZone);
    } on timezone.LocationNotFoundException {
      throw ArgumentError.value(
        timeZone,
        'timeZone',
        'Unknown IANA time-zone identifier.',
      );
    }
    final hour = minutesAfterMidnight ~/ 60;
    final minute = minutesAfterMidnight % 60;
    final localWallTime = DateTime.utc(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );

    final candidates = <DateTime>{};
    for (final zone in location.zones) {
      final candidate = DateTime.fromMillisecondsSinceEpoch(
        localWallTime.millisecondsSinceEpoch - zone.offset.inMilliseconds,
        isUtc: true,
      );
      final asLocalTime = timezone.TZDateTime.from(candidate, location);
      if (asLocalTime.year == date.year &&
          asLocalTime.month == date.month &&
          asLocalTime.day == date.day &&
          asLocalTime.hour == hour &&
          asLocalTime.minute == minute) {
        candidates.add(candidate);
      }
    }

    if (candidates.isEmpty) {
      throw ArgumentError(
        'That local birth time does not exist in the selected time zone.',
      );
    }
    if (candidates.length > 1) {
      throw ArgumentError(
        'That local birth time is ambiguous in the selected time zone.',
      );
    }
    return candidates.single;
  }
}
