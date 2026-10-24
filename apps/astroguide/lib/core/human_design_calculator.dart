import 'package:sweph/sweph.dart';

import 'birth_profile.dart';

/// Represents a single Human Design Gate & Line placement.
class HdGatePlacement {
  const HdGatePlacement({
    required this.planetName,
    required this.gate,
    required this.line,
    required this.longitude,
    required this.isDesign,
  });

  final String planetName;
  final int gate;
  final int line;
  final double longitude;
  final bool isDesign; // true = Tubuh (Bawah Sadar / Merah), false = Jiwa (Sadar / Hitam)

  String get label => '$gate.$line';
}

/// Represents a Human Design Channel.
class HdChannel {
  const HdChannel({
    required this.gateA,
    required this.gateB,
    required this.name,
    required this.centerA,
    required this.centerB,
  });

  final int gateA;
  final int gateB;
  final String name;
  final HdCenter centerA;
  final HdCenter centerB;

  bool contains(int gate) => gateA == gate || gateB == gate;
  int otherGate(int gate) => gate == gateA ? gateB : gateA;
}

/// The 9 Centers in Human Design Bodygraph.
enum HdCenter {
  head('Head', 'Pikiran / Inspirasi'),
  ajna('Ajna', 'Konseptualisasi / Analisis'),
  throat('Throat', 'Ekspresi / Manifestasi'),
  gCenter('G Center', 'Identitas / Arah / Cinta'),
  heart('Heart / Ego', 'Willpower / Daya Saing'),
  solarPlexus('Solar Plexus', 'Emosi / Gelombang Emosi'),
  sacral('Sacral', 'Energi Kerja / Vitalitas'),
  spleen('Spleen', 'Insting / Kesehatan / Rasa Aman'),
  root('Root', 'Tekanan / Dorongan Aksi');

  const HdCenter(this.title, this.subtitle);
  final String title;
  final String subtitle;
}

/// Complete Human Design Chart result.
class HumanDesignChart {
  HumanDesignChart({
    required this.profileName,
    required this.personalityPlacements,
    required this.designPlacements,
    required this.definedCenters,
    required this.activeChannels,
    required this.activeGates,
    required this.hangingGates,
    required this.type,
    required this.strategy,
    required this.authority,
    required this.profileLabel,
    required this.definitionType,
    required this.incarnationCross,
  });

  final String profileName;
  final List<HdGatePlacement> personalityPlacements; // Jiwa (Hitam)
  final List<HdGatePlacement> designPlacements;      // Tubuh (Merah)
  final Set<HdCenter> definedCenters;
  final List<HdChannel> activeChannels;
  final Set<int> activeGates;
  final Set<int> hangingGates;
  final String type;
  final String strategy;
  final String authority;
  final String profileLabel;
  final String definitionType;
  final String incarnationCross;

  bool isCenterDefined(HdCenter center) => definedCenters.contains(center);

  String get typeLabel => type;
  String get definitionLabel => definitionType;
  String get signatureTheme => switch (type) {
    'Generator' || 'Manifesting Generator' => 'Kepuasan (Satisfaction)',
    'Projector' => 'Keberhasilan (Success)',
    'Manifestor' => 'Kedamaian (Peace)',
    _ => 'Kejelasan (Clarity)',
  };
  String get notSelfTheme => switch (type) {
    'Generator' || 'Manifesting Generator' => 'Frustrasi (Frustration)',
    'Projector' => 'Kepahitan (Bitterness)',
    'Manifestor' => 'Kemarahan (Anger)',
    _ => 'Kekecewaan (Disappointment)',
  };

  Map<String, bool> get centersMap => {
    'Kepala (Head)': isCenterDefined(HdCenter.head),
    'Ajna': isCenterDefined(HdCenter.ajna),
    'Tenggorokan (Throat)': isCenterDefined(HdCenter.throat),
    'G Center (Identitas)': isCenterDefined(HdCenter.gCenter),
    'Jantung (Heart/Ego)': isCenterDefined(HdCenter.heart),
    'Solar Plexus (Emosi)': isCenterDefined(HdCenter.solarPlexus),
    'Sakral (Sacral)': isCenterDefined(HdCenter.sacral),
    'Limpa (Spleen)': isCenterDefined(HdCenter.spleen),
    'Akar (Root)': isCenterDefined(HdCenter.root),
  };
}

class HumanDesignCalculator {
  // Rave Mandala 64 Gate wheel order starting at 0° Aries (Gate 25)
  static const List<int> _gateWheel = [
    25, 17, 21, 51, 42, 3, 27, 24, 2, 23, 8, 20, 16, 35, 45, 12,
    15, 52, 39, 53, 62, 56, 31, 33, 7, 4, 29, 59, 40, 64, 47, 6,
    46, 18, 48, 57, 32, 50, 28, 44, 1, 43, 14, 34, 9, 5, 26, 11,
    10, 58, 38, 54, 61, 60, 41, 19, 13, 49, 30, 55, 37, 63, 22, 36
  ];

  // All 36 Human Design Channels
  static const List<HdChannel> allChannels = [
    HdChannel(gateA: 64, gateB: 47, name: 'Abstraction (64-47)', centerA: HdCenter.head, centerB: HdCenter.ajna),
    HdChannel(gateA: 61, gateB: 24, name: 'Awareness (61-24)', centerA: HdCenter.head, centerB: HdCenter.ajna),
    HdChannel(gateA: 63, gateB: 4, name: 'Logic (63-4)', centerA: HdCenter.head, centerB: HdCenter.ajna),
    HdChannel(gateA: 17, gateB: 62, name: 'Acceptance (17-62)', centerA: HdCenter.ajna, centerB: HdCenter.throat),
    HdChannel(gateA: 43, gateB: 23, name: 'Structuring (43-23)', centerA: HdCenter.ajna, centerB: HdCenter.throat),
    HdChannel(gateA: 11, gateB: 56, name: 'Curiosity (11-56)', centerA: HdCenter.ajna, centerB: HdCenter.throat),
    HdChannel(gateA: 31, gateB: 7, name: 'Alpha (31-7)', centerA: HdCenter.throat, centerB: HdCenter.gCenter),
    HdChannel(gateA: 8, gateB: 1, name: 'Inspiration (8-1)', centerA: HdCenter.throat, centerB: HdCenter.gCenter),
    HdChannel(gateA: 33, gateB: 13, name: 'Prodigal (33-13)', centerA: HdCenter.throat, centerB: HdCenter.gCenter),
    HdChannel(gateA: 20, gateB: 10, name: 'Awakening (20-10)', centerA: HdCenter.throat, centerB: HdCenter.gCenter),
    HdChannel(gateA: 45, gateB: 21, name: 'Money (45-21)', centerA: HdCenter.throat, centerB: HdCenter.heart),
    HdChannel(gateA: 12, gateB: 22, name: 'Openness (12-22)', centerA: HdCenter.throat, centerB: HdCenter.solarPlexus),
    HdChannel(gateA: 35, gateB: 36, name: 'Transitoriness (35-36)', centerA: HdCenter.throat, centerB: HdCenter.solarPlexus),
    HdChannel(gateA: 16, gateB: 48, name: 'Wavelength (16-48)', centerA: HdCenter.throat, centerB: HdCenter.spleen),
    HdChannel(gateA: 20, gateB: 57, name: 'Brainwave (20-57)', centerA: HdCenter.throat, centerB: HdCenter.spleen),
    HdChannel(gateA: 34, gateB: 20, name: 'Charisma (34-20)', centerA: HdCenter.sacral, centerB: HdCenter.throat),
    HdChannel(gateA: 25, gateB: 51, name: 'Initiation (25-51)', centerA: HdCenter.gCenter, centerB: HdCenter.heart),
    HdChannel(gateA: 10, gateB: 34, name: 'Exploration (10-34)', centerA: HdCenter.gCenter, centerB: HdCenter.sacral),
    HdChannel(gateA: 15, gateB: 5, name: 'Rhythm (15-5)', centerA: HdCenter.gCenter, centerB: HdCenter.sacral),
    HdChannel(gateA: 2, gateB: 14, name: 'Beat (2-14)', centerA: HdCenter.gCenter, centerB: HdCenter.sacral),
    HdChannel(gateA: 46, gateB: 29, name: 'Discovery (46-29)', centerA: HdCenter.gCenter, centerB: HdCenter.sacral),
    HdChannel(gateA: 57, gateB: 10, name: 'Perfected Form (57-10)', centerA: HdCenter.spleen, centerB: HdCenter.gCenter),
    HdChannel(gateA: 26, gateB: 44, name: 'Surrender (26-44)', centerA: HdCenter.heart, centerB: HdCenter.spleen),
    HdChannel(gateA: 40, gateB: 37, name: 'Community (40-37)', centerA: HdCenter.heart, centerB: HdCenter.solarPlexus),
    HdChannel(gateA: 34, gateB: 57, name: 'Power (34-57)', centerA: HdCenter.sacral, centerB: HdCenter.spleen),
    HdChannel(gateA: 27, gateB: 50, name: 'Preservation (27-50)', centerA: HdCenter.sacral, centerB: HdCenter.spleen),
    HdChannel(gateA: 59, gateB: 6, name: 'Mating (59-6)', centerA: HdCenter.sacral, centerB: HdCenter.solarPlexus),
    HdChannel(gateA: 3, gateB: 60, name: 'Mutation (3-60)', centerA: HdCenter.sacral, centerB: HdCenter.root),
    HdChannel(gateA: 42, gateB: 53, name: 'Maturation (42-53)', centerA: HdCenter.sacral, centerB: HdCenter.root),
    HdChannel(gateA: 9, gateB: 52, name: 'Concentration (9-52)', centerA: HdCenter.sacral, centerB: HdCenter.root),
    HdChannel(gateA: 32, gateB: 54, name: 'Transformation (32-54)', centerA: HdCenter.spleen, centerB: HdCenter.root),
    HdChannel(gateA: 28, gateB: 38, name: 'Struggle (28-38)', centerA: HdCenter.spleen, centerB: HdCenter.root),
    HdChannel(gateA: 18, gateB: 58, name: 'Judgment (18-58)', centerA: HdCenter.spleen, centerB: HdCenter.root),
    HdChannel(gateA: 19, gateB: 49, name: 'Synthesis (19-49)', centerA: HdCenter.root, centerB: HdCenter.solarPlexus),
    HdChannel(gateA: 39, gateB: 55, name: 'Emoting (39-55)', centerA: HdCenter.root, centerB: HdCenter.solarPlexus),
    HdChannel(gateA: 41, gateB: 30, name: 'Recognition (41-30)', centerA: HdCenter.root, centerB: HdCenter.solarPlexus),
  ];

  HumanDesignChart? calculate(BirthProfile profile) {
    try {
      // 1. Calculate Julian Day for Birth Date & Time
      final birthDate = profile.birthDate;
      final minutes = profile.birthTimeMinutes ?? 12 * 60;
      final utcBirthDate = DateTime.utc(
        birthDate.year,
        birthDate.month,
        birthDate.day,
        minutes ~/ 60,
        minutes % 60,
      );

      final birthJd = Sweph.swe_julday(
        utcBirthDate.year,
        utcBirthDate.month,
        utcBirthDate.day,
        utcBirthDate.hour + utcBirthDate.minute / 60.0,
        CalendarType.SE_GREG_CAL,
      );

      // 2. Compute Personality (Sadar / Hitam) Planet Longitudes (Tropical)
      final personalityPlanets = _calculatePlanetLongitudes(birthJd);

      // 3. Compute Design (Bawah Sadar / Merah) - 88° Solar Arc back
      final birthSunLong = personalityPlanets['Sun']!;
      final designSunLong = (birthSunLong - 88.0 + 360.0) % 360.0;
      final designJd = _findJulianDayForSunLongitude(designSunLong, birthJd - 100, birthJd);
      final designPlanets = _calculatePlanetLongitudes(designJd);

      // 4. Convert Longitudes to Gate Placements
      final personalityPlacements = <HdGatePlacement>[];
      final designPlacements = <HdGatePlacement>[];
      final activeGates = <int>{};

      for (final entry in personalityPlanets.entries) {
        final (gate, line) = _longitudeToGateLine(entry.value);
        personalityPlacements.add(HdGatePlacement(
          planetName: entry.key,
          gate: gate,
          line: line,
          longitude: entry.value,
          isDesign: false,
        ));
        activeGates.add(gate);
      }

      for (final entry in designPlanets.entries) {
        final (gate, line) = _longitudeToGateLine(entry.value);
        designPlacements.add(HdGatePlacement(
          planetName: entry.key,
          gate: gate,
          line: line,
          longitude: entry.value,
          isDesign: true,
        ));
        activeGates.add(gate);
      }

      // 5. Active Channels & Defined Centers
      final activeChannels = <HdChannel>[];
      final definedCenters = <HdCenter>{};

      for (final channel in allChannels) {
        if (activeGates.contains(channel.gateA) && activeGates.contains(channel.gateB)) {
          activeChannels.add(channel);
          definedCenters.add(channel.centerA);
          definedCenters.add(channel.centerB);
        }
      }

      // 6. Hanging Gates
      final hangingGates = <int>{};
      for (final gate in activeGates) {
        final belongsToActiveChannel = activeChannels.any((c) => c.contains(gate));
        if (!belongsToActiveChannel) {
          hangingGates.add(gate);
        }
      }

      // 7. Determine Type, Strategy, Authority, Profile, Definition
      final isSacralDefined = definedCenters.contains(HdCenter.sacral);
      final isThroatDefined = definedCenters.contains(HdCenter.throat);

      final sacralConnectedToThroat = isSacralDefined && isThroatDefined &&
          _hasPath(HdCenter.sacral, HdCenter.throat, activeChannels);

      final anyMotorConnectedToThroat = isThroatDefined && (
        (definedCenters.contains(HdCenter.solarPlexus) && _hasPath(HdCenter.solarPlexus, HdCenter.throat, activeChannels)) ||
        (definedCenters.contains(HdCenter.heart) && _hasPath(HdCenter.heart, HdCenter.throat, activeChannels)) ||
        (definedCenters.contains(HdCenter.root) && _hasPath(HdCenter.root, HdCenter.throat, activeChannels)) ||
        sacralConnectedToThroat
      );

      String type;
      String strategy;
      if (isSacralDefined) {
        if (sacralConnectedToThroat) {
          type = 'Manifesting Generator';
          strategy = 'Tunggu sinyal, respon, lalu kabari';
        } else {
          type = 'Generator';
          strategy = 'Tunggu sinyal, lalu respon';
        }
      } else if (anyMotorConnectedToThroat) {
        type = 'Manifestor';
        strategy = 'Informasikan sebelum melangkah';
      } else if (definedCenters.isNotEmpty) {
        type = 'Projector';
        strategy = 'Tunggu undangan dan pengakuan';
      } else {
        type = 'Reflector';
        strategy = 'Tunggu siklus bulan (28 hari)';
      }

      String authority;
      if (definedCenters.contains(HdCenter.solarPlexus)) {
        authority = 'Emosional — butuh waktu sampai jernih';
      } else if (definedCenters.contains(HdCenter.sacral)) {
        authority = 'Sacral — respon perut langsung';
      } else if (definedCenters.contains(HdCenter.spleen)) {
        authority = 'Splenic — insting spontan saat ini';
      } else if (definedCenters.contains(HdCenter.heart)) {
        authority = 'Ego / Willpower';
      } else if (definedCenters.contains(HdCenter.gCenter)) {
        authority = 'Self-Projected (G Center)';
      } else if (definedCenters.contains(HdCenter.ajna) || definedCenters.contains(HdCenter.head)) {
        authority = 'Mental / Environmental';
      } else {
        authority = 'Lunar (Tanpa Authority Internal)';
      }

      final pSun = personalityPlacements.firstWhere((p) => p.planetName == 'Sun');
      final dSun = designPlacements.firstWhere((p) => p.planetName == 'Sun');
      final profileLabel = '${pSun.line}/${dSun.line}';

      final definitionType = _calculateDefinitionType(definedCenters, activeChannels);

      final pEarth = personalityPlacements.firstWhere((p) => p.planetName == 'Earth');
      final dEarth = designPlacements.firstWhere((p) => p.planetName == 'Earth');
      final incarnationCross = 'Right Angle Cross of Laws (${pSun.gate}/${pEarth.gate} | ${dSun.gate}/${dEarth.gate})';

      return HumanDesignChart(
        profileName: profile.fullName,
        personalityPlacements: personalityPlacements,
        designPlacements: designPlacements,
        definedCenters: definedCenters,
        activeChannels: activeChannels,
        activeGates: activeGates,
        hangingGates: hangingGates,
        type: type,
        strategy: strategy,
        authority: authority,
        profileLabel: profileLabel,
        definitionType: definitionType,
        incarnationCross: incarnationCross,
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, double> _calculatePlanetLongitudes(double julianDay) {
    final planets = <String, HeavenlyBody>{
      'Sun': HeavenlyBody.SE_SUN,
      'Moon': HeavenlyBody.SE_MOON,
      'Mercury': HeavenlyBody.SE_MERCURY,
      'Venus': HeavenlyBody.SE_VENUS,
      'Mars': HeavenlyBody.SE_MARS,
      'Jupiter': HeavenlyBody.SE_JUPITER,
      'Saturn': HeavenlyBody.SE_SATURN,
      'Uranus': HeavenlyBody.SE_URANUS,
      'Neptune': HeavenlyBody.SE_NEPTUNE,
      'Pluto': HeavenlyBody.SE_PLUTO,
      'North Node': HeavenlyBody.SE_TRUE_NODE,
    };

    final result = <String, double>{};
    for (final entry in planets.entries) {
      final res = Sweph.swe_calc_ut(julianDay, entry.value, SwephFlag.SEFLG_SPEED);
      final long = (res.longitude + 360.0) % 360.0;
      result[entry.key] = long;
      if (entry.key == 'Sun') {
        result['Earth'] = (long + 180.0) % 360.0;
      } else if (entry.key == 'North Node') {
        result['South Node'] = (long + 180.0) % 360.0;
      }
    }

    return result;
  }

  (int gate, int line) _longitudeToGateLine(double longitude) {
    final normLong = (longitude + 360.0) % 360.0;
    final gateIndex = (normLong / 5.625).floor() % 64;
    final gate = _gateWheel[gateIndex];
    final remainder = normLong % 5.625;
    final line = ((remainder / 0.9375).floor() % 6) + 1;
    return (gate, line);
  }

  double _findJulianDayForSunLongitude(double targetSunLong, double startJd, double endJd) {
    double low = startJd;
    double high = endJd;
    for (int i = 0; i < 30; i++) {
      final mid = (low + high) / 2.0;
      final res = Sweph.swe_calc_ut(mid, HeavenlyBody.SE_SUN, SwephFlag.SEFLG_SPEED);
      final midLong = (res.longitude + 360.0) % 360.0;

      double diff = (midLong - targetSunLong + 360.0) % 360.0;
      if (diff > 180.0) {
        diff -= 360.0;
      }

      if (diff > 0) {
        high = mid;
      } else {
        low = mid;
      }
    }
    return (low + high) / 2.0;
  }

  bool _hasPath(HdCenter start, HdCenter target, List<HdChannel> channels) {
    if (start == target) return true;
    final visited = <HdCenter>{start};
    final queue = <HdCenter>[start];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (current == target) return true;

      for (final channel in channels) {
        if (channel.centerA == current && !visited.contains(channel.centerB)) {
          visited.add(channel.centerB);
          queue.add(channel.centerB);
        } else if (channel.centerB == current && !visited.contains(channel.centerA)) {
          visited.add(channel.centerA);
          queue.add(channel.centerA);
        }
      }
    }
    return false;
  }

  String _calculateDefinitionType(Set<HdCenter> definedCenters, List<HdChannel> activeChannels) {
    if (definedCenters.isEmpty) return 'No Definition (Reflector)';
    final visited = <HdCenter>{};
    int components = 0;

    for (final center in definedCenters) {
      if (!visited.contains(center)) {
        components++;
        final queue = <HdCenter>[center];
        visited.add(center);

        while (queue.isNotEmpty) {
          final curr = queue.removeAt(0);
          for (final ch in activeChannels) {
            final next = ch.centerA == curr ? ch.centerB : (ch.centerB == curr ? ch.centerA : null);
            if (next != null && !visited.contains(next)) {
              visited.add(next);
              queue.add(next);
            }
          }
        }
      }
    }

    return switch (components) {
      1 => 'Single Definition',
      2 => 'Split Definition',
      3 => 'Triple Split Definition',
      4 => 'Quadruple Split Definition',
      _ => 'Single Definition',
    };
  }
}
