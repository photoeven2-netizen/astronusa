class BirthCity {
  const BirthCity({
    required this.id,
    required this.name,
    this.province = '',
    required this.regionCode,
    required this.latitude,
    required this.longitude,
    required this.timeZone,
    required this.population,
  });

  final int id;
  final String name;
  final String province;
  final String regionCode;
  final double latitude;
  final double longitude;
  final String timeZone;
  final int population;

  bool get isThailand => regionCode.startsWith('TH');
  bool get isSingapore => regionCode.startsWith('SG');
  bool get isMalaysia => regionCode.startsWith('MY');

  String get countryName {
    final code = regionCode.toUpperCase();
    if (code.startsWith('SG')) return 'Singapura';
    if (code.startsWith('MY')) return 'Malaysia';
    if (code.startsWith('TH')) return 'Thailand';
    if (code.startsWith('VN')) return 'Vietnam';
    if (code.startsWith('PH')) return 'Filipina';
    if (code.startsWith('BN')) return 'Brunei Darussalam';
    if (code.startsWith('LA')) return 'Laos';
    if (code.startsWith('MM')) return 'Myanmar';
    if (code.startsWith('TL')) return 'Timor Leste';
    if (code.startsWith('CN')) return 'China';
    if (code.startsWith('JP')) return 'Jepang';
    if (code.startsWith('KR')) return 'Korea Selatan';
    if (code.startsWith('KP')) return 'Korea Utara';
    if (code.startsWith('MN')) return 'Mongolia';
    if (code.startsWith('TW')) return 'Taiwan';
    if (code.startsWith('IN')) return 'India';
    if (code.startsWith('PK')) return 'Pakistan';
    return 'Indonesia';
  }

  String get timeZoneLabel {
    switch (timeZone) {
      case 'Asia/Jakarta':
      case 'Asia/Pontianak':
        return 'WIB (UTC+7)';
      case 'Asia/Makassar':
      case 'Asia/Ujung_Pandang':
        return 'WITA (UTC+8)';
      case 'Asia/Jayapura':
        return 'WIT (UTC+9)';
      case 'Asia/Singapore':
        return 'SGT (UTC+8)';
      case 'Asia/Kuala_Lumpur':
      case 'Asia/Kuching':
        return 'MYT (UTC+8)';
      case 'Asia/Bangkok':
      case 'Asia/Vientiane':
      case 'Asia/Ho_Chi_Minh':
        return 'ICT (UTC+7)';
      case 'Asia/Manila':
        return 'PST (UTC+8)';
      case 'Asia/Brunei':
        return 'BNT (UTC+8)';
      case 'Asia/Yangon':
        return 'MMT (UTC+6:30)';
      case 'Asia/Dili':
        return 'TLT (UTC+9)';
      case 'Asia/Shanghai':
        return 'CST (UTC+8)';
      case 'Asia/Tokyo':
        return 'JST (UTC+9)';
      case 'Asia/Seoul':
      case 'Asia/Pyongyang':
        return 'KST (UTC+9)';
      case 'Asia/Ulaanbaatar':
        return 'ULAT (UTC+8)';
      case 'Asia/Taipei':
        return 'CST (UTC+8)';
      case 'Asia/Kolkata':
        return 'IST (UTC+5:30)';
      case 'Asia/Karachi':
        return 'PKT (UTC+5)';
      default:
        return timeZone;
    }
  }

  String get regionName => province.isNotEmpty ? province : _fallbackRegionName;

  String get _fallbackRegionName {
    switch (regionCode) {
      case '11':
        return 'Aceh';
      case '12':
        return 'Sumatera Utara';
      case '13':
        return 'Sumatera Barat';
      case '14':
        return 'Riau';
      case '15':
        return 'Jambi';
      case '16':
        return 'Sumatera Selatan';
      case '17':
        return 'Bengkulu';
      case '18':
        return 'Lampung';
      case '19':
        return 'Kepulauan Bangka Belitung';
      case '21':
        return 'Kepulauan Riau';
      case '31':
        return 'DKI Jakarta';
      case '32':
        return 'Jawa Barat';
      case '33':
        return 'Jawa Tengah';
      case '34':
        return 'D.I. Yogyakarta';
      case '35':
        return 'Jawa Timur';
      case '36':
        return 'Banten';
      case '51':
        return 'Bali';
      case '52':
        return 'Nusa Tenggara Barat';
      case '53':
        return 'Nusa Tenggara Timur';
      case '61':
        return 'Kalimantan Barat';
      case '62':
        return 'Kalimantan Tengah';
      case '63':
        return 'Kalimantan Selatan';
      case '64':
        return 'Kalimantan Timur';
      case '65':
        return 'Kalimantan Utara';
      case '71':
        return 'Sulawesi Utara';
      case '72':
        return 'Sulawesi Tengah';
      case '73':
        return 'Sulawesi Selatan';
      case '74':
        return 'Sulawesi Tenggara';
      case '75':
        return 'Gorontalo';
      case '76':
        return 'Sulawesi Barat';
      case '81':
        return 'Maluku';
      case '82':
        return 'Maluku Utara';
      case '91':
        return 'Papua';
      case '92':
        return 'Papua Barat';
      case '93':
        return 'Papua Selatan';
      case '94':
        return 'Papua Tengah';
      case '95':
        return 'Papua Pegunungan';
      case '96':
        return 'Papua Barat Daya';
      default:
        return '';
    }
  }

  factory BirthCity.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final name = json['name'];
    final province = json['province'] ?? '';
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
      province: (province is String) ? province.trim() : '',
      regionCode: regionCode,
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      timeZone: timeZone.trim(),
      population: population,
    );
  }
}
