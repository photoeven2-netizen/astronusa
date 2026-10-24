import 'package:flutter_test/flutter_test.dart';
import 'package:astro_guide/core/birth_profile.dart';
import 'package:astro_guide/core/primbon_calculator.dart';

void main() {
  test('calculates Primbon Jawa, Bali, and China accurately for benchmark dates', () {
    // 17 Agustus 1945 = Jumat Legi
    final profileProklamasi = BirthProfile(
      fullName: 'Soekarno',
      birthDate: DateTime(1945, 8, 17),
      birthTimeMinutes: 10 * 60,
      cityName: 'Jakarta',
      latitude: -6.20,
      longitude: 106.84,
      timeZone: 'Asia/Jakarta',
      ayanamsha: Ayanamsha.tropical,
    );

    final calculator = PrimbonCalculator();
    final primbon1945 = calculator.calculate(profileProklamasi);

    expect(primbon1945.jawa.hari, 'Jumat');
    expect(primbon1945.jawa.pasaran, 'Legi');
    expect(primbon1945.jawa.neptuTotal, 11); // Jumat 6 + Legi 5 = 11

    // 25 Oktober 1999 = Senin Pon
    final profile1999 = BirthProfile(
      fullName: 'Arief Wibowo',
      birthDate: DateTime(1999, 10, 25),
      birthTimeMinutes: 12 * 60,
      cityName: 'Klaten',
      latitude: -7.70,
      longitude: 110.60,
      timeZone: 'Asia/Jakarta',
      ayanamsha: Ayanamsha.tropical,
    );

    final primbon1999 = calculator.calculate(profile1999);

    expect(primbon1999.jawa.hari, 'Senin');
    expect(primbon1999.jawa.pasaran, 'Pon');
    expect(primbon1999.jawa.neptuTotal, 11); // Senin 4 + Pon 7 = 11
    expect(primbon1999.china.shio, 'Kelinci'); // 1999 = Shio Kelinci
    expect(primbon1999.china.elemen, 'Tanah'); // 1999 (last digit 9) = Tanah
  });
}
