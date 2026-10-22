class BirthCity {
  const BirthCity({
    required this.id,
    required this.name,
    required this.regionCode,
    required this.latitude,
    required this.longitude,
    required this.timeZone,
    required this.population,
  });

  final int id;
  final String name;
  final String regionCode;
  final double latitude;
  final double longitude;
  final String timeZone;
  final int population;

  factory BirthCity.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final name = json['name'];
    final regionCode = json['regionCode'];
    final latitude = json['latitude'];
    final longitude = json['longitude'];
    final timeZone = json['timeZone'];
    final population = json['population'];

    if (id is! int ||
        name is! String ||
        name.trim().isEmpty ||
        regionCode is! String ||
        latitude is! num ||
        longitude is! num ||
        timeZone is! String ||
        timeZone.trim().isEmpty ||
        population is! int ||
        !latitude.toDouble().isFinite ||
        !longitude.toDouble().isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      throw const FormatException('City record is invalid.');
    }

    return BirthCity(
      id: id,
      name: name.trim(),
      regionCode: regionCode,
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      timeZone: timeZone.trim(),
      population: population,
    );
  }
}
