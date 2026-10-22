import 'birth_profile.dart';

abstract interface class ChartService {
  Future<AstroChart> calculate(BirthProfile profile);
}

class AstroChart {
  const AstroChart({
    required this.ayanamsha,
    required this.birthTimeKnown,
    required this.sun,
    required this.moon,
    required this.rising,
    required this.mars,
    required this.venus,
  });

  final Ayanamsha ayanamsha;
  final bool birthTimeKnown;
  final String? sun;
  final String? moon;
  final String? rising;
  final String? mars;
  final String? venus;

  Map<String, Object?> toReadingJson() => {
    'ayanamsha': ayanamsha.apiValue,
    'birthTimeKnown': birthTimeKnown,
    'positions': {
      'sun': sun,
      'moon': moon,
      'rising': rising,
      'mars': mars,
      'venus': venus,
    },
  };
}
