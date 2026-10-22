import 'package:flutter/services.dart';
import 'package:sweph/sweph.dart';

import 'astro_chart.dart';
import 'birth_profile.dart';
import 'birth_time_converter.dart';
import 'zodiac_position.dart';

class BirthChartCalculator implements ChartService {
  BirthChartCalculator({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  Future<void>? _initialization;

  @override
  Future<AstroChart> calculate(BirthProfile profile) async {
    final initialization = _initialization ??= _initialize();
    try {
      await initialization;
    } catch (_) {
      _initialization = null;
      rethrow;
    }

    final start = _birthInstant(
      profile.birthDate,
      profile.birthTimeMinutes ?? 0,
      profile,
    );
    final end = profile.birthTimeMinutes == null
        ? _birthInstant(
            DateTime(
              profile.birthDate.year,
              profile.birthDate.month,
              profile.birthDate.day + 1,
            ),
            0,
            profile,
          )
        : start;
    _setAyanamsha(profile.ayanamsha);

    final positions = {
      'sun': _stablePosition(profile, start, end, HeavenlyBody.SE_SUN),
      'moon': _stablePosition(profile, start, end, HeavenlyBody.SE_MOON),
      'mars': _stablePosition(profile, start, end, HeavenlyBody.SE_MARS),
      'venus': _stablePosition(profile, start, end, HeavenlyBody.SE_VENUS),
    };

    String? rising;
    if (profile.birthTimeMinutes != null) {
      final julianDay = _julianDay(start);
      final houses = Sweph.swe_houses_ex2(
        julianDay,
        SwephFlag.SEFLG_SIDEREAL,
        profile.latitude,
        profile.longitude,
        Hsys.P,
      );
      rising = ZodiacPosition.fromSiderealLongitude(_normalize(houses.ascmc[0]))
          .sign;
    }

    return AstroChart(
      ayanamsha: profile.ayanamsha,
      birthTimeKnown: profile.birthTimeMinutes != null,
      sun: positions['sun'],
      moon: positions['moon'],
      rising: rising,
      mars: positions['mars'],
      venus: positions['venus'],
    );
  }

  Future<void> _initialize() => Sweph.init(
    epheAssets: const [
      'packages/sweph/assets/ephe/sepl_18.se1',
      'packages/sweph/assets/ephe/semo_18.se1',
      'packages/sweph/assets/ephe/seas_18.se1',
    ],
    assetLoader: _RootBundleAssetLoader(_bundle),
  );

  DateTime _birthInstant(
    DateTime localDate,
    int minutesAfterMidnight,
    BirthProfile profile,
  ) {
    return BirthTimeConverter.toUtc(
      date: localDate,
      minutesAfterMidnight: minutesAfterMidnight,
      timeZone: profile.timeZone,
    );
  }

  String? _stablePosition(
    BirthProfile profile,
    DateTime start,
    DateTime end,
    HeavenlyBody body,
  ) {
    final flags = SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SIDEREAL;
    final startPosition = Sweph.swe_calc_ut(_julianDay(start), body, flags);
    final startSign = ZodiacPosition.fromSiderealLongitude(
      _normalize(startPosition.longitude),
    ).sign;

    if (start == end) {
      return startSign;
    }

    final endPosition = Sweph.swe_calc_ut(_julianDay(end), body, flags);
    final endSign = ZodiacPosition.fromSiderealLongitude(
      _normalize(endPosition.longitude),
    ).sign;
    return startSign == endSign ? startSign : null;
  }

  void _setAyanamsha(Ayanamsha ayanamsha) {
    final mode = switch (ayanamsha) {
      Ayanamsha.lahiri => SiderealMode.SE_SIDM_LAHIRI,
      Ayanamsha.raman => SiderealMode.SE_SIDM_RAMAN,
      Ayanamsha.kp => SiderealMode.SE_SIDM_KRISHNAMURTI,
    };
    Sweph.swe_set_sid_mode(mode, SiderealModeFlag.SE_SIDBIT_NONE, 0, 0);
  }

  double _julianDay(DateTime utc) => Sweph.swe_julday(
    utc.year,
    utc.month,
    utc.day,
    utc.hour + utc.minute / 60 + utc.second / 3600,
    CalendarType.SE_GREG_CAL,
  );

  double _normalize(double longitude) => (longitude % 360 + 360) % 360;
}

class _RootBundleAssetLoader with AssetLoader {
  _RootBundleAssetLoader(this._bundle);

  final AssetBundle _bundle;

  @override
  Future<Uint8List> load(String assetPath) async {
    final data = await _bundle.load(assetPath);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}
