enum Ayanamsha {
  tropical,
  lahiri,
  raman,
  kp;

  String get label => switch (this) {
    Ayanamsha.tropical => 'Tropikal (Zodiak Barat)',
    Ayanamsha.lahiri => 'Sidereal Lahiri (Veda)',
    Ayanamsha.raman => 'Sidereal Raman (Veda)',
    Ayanamsha.kp => 'Sidereal KP (Veda)',
  };

  String get apiValue => name;
}

class BirthProfile {
  const BirthProfile({
    required this.fullName,
    required this.birthDate,
    required this.birthTimeMinutes,
    required this.cityName,
    required this.latitude,
    required this.longitude,
    required this.timeZone,
    required this.ayanamsha,
  });

  final String fullName;
  final DateTime birthDate;
  final int? birthTimeMinutes;
  final String cityName;
  final double latitude;
  final double longitude;
  final String timeZone;
  final Ayanamsha ayanamsha;

  String get nickname => fullName.trim().split(RegExp(r'\s+')).first;

  BirthProfile copyWith({
    String? fullName,
    DateTime? birthDate,
    int? birthTimeMinutes,
    bool clearBirthTime = false,
    String? cityName,
    double? latitude,
    double? longitude,
    String? timeZone,
    Ayanamsha? ayanamsha,
  }) {
    return BirthProfile(
      fullName: fullName ?? this.fullName,
      birthDate: birthDate ?? this.birthDate,
      birthTimeMinutes: clearBirthTime
          ? null
          : birthTimeMinutes ?? this.birthTimeMinutes,
      cityName: cityName ?? this.cityName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timeZone: timeZone ?? this.timeZone,
      ayanamsha: ayanamsha ?? this.ayanamsha,
    );
  }

  Map<String, Object?> toJson() => {
    'fullName': fullName,
    'birthDate': _dateKey(birthDate),
    'birthTimeMinutes': birthTimeMinutes,
    'cityName': cityName,
    'latitude': latitude,
    'longitude': longitude,
    'timeZone': timeZone,
    'ayanamsha': ayanamsha.apiValue,
  };

  factory BirthProfile.fromJson(Map<String, Object?> json) {
    final name = json['fullName'];
    final dateValue = json['birthDate'];
    final time = json['birthTimeMinutes'];
    final city = json['cityName'];
    final latitude = json['latitude'];
    final longitude = json['longitude'];
    final timeZone = json['timeZone'];
    final methodValue = json['ayanamsha'];

    if (name is! String ||
        name.trim().isEmpty ||
        dateValue is! String ||
        city is! String ||
        city.trim().isEmpty ||
        latitude is! num ||
        longitude is! num ||
        timeZone is! String ||
        timeZone.trim().isEmpty ||
        methodValue is! String) {
      throw const FormatException('Stored birth profile is incomplete.');
    }

    final date = DateTime.tryParse(dateValue);
    if (date == null ||
        dateValue.length != 10 ||
        _dateKey(date) != dateValue ||
        (time != null && (time is! int || time < 0 || time >= 1440)) ||
        !latitude.toDouble().isFinite ||
        !longitude.toDouble().isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      throw const FormatException(
        'Stored birth profile contains invalid values.',
      );
    }

    final method = Ayanamsha.values.where(
      (value) => value.apiValue == methodValue,
    );
    if (method.isEmpty) {
      throw const FormatException(
        'Stored birth profile uses an unknown ayanamsha.',
      );
    }

    return BirthProfile(
      fullName: name.trim(),
      birthDate: date,
      birthTimeMinutes: time as int?,
      cityName: city.trim(),
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      timeZone: timeZone.trim(),
      ayanamsha: method.first,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BirthProfile &&
      other.fullName == fullName &&
      _dateKey(other.birthDate) == _dateKey(birthDate) &&
      other.birthTimeMinutes == birthTimeMinutes &&
      other.cityName == cityName &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.timeZone == timeZone &&
      other.ayanamsha == ayanamsha;

  @override
  int get hashCode => Object.hash(
    fullName,
    _dateKey(birthDate),
    birthTimeMinutes,
    cityName,
    latitude,
    longitude,
    timeZone,
    ayanamsha,
  );

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
