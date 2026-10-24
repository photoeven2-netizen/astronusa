import 'birth_profile.dart';
import 'human_design_calculator.dart';
import 'numerology.dart';
import 'primbon_calculator.dart';

class WetnanResult {
  const WetnanResult({
    required this.kategori,
    required this.totalNeptu,
    required this.neptuA,
    required this.neptuB,
    required this.wetonA,
    required this.wetonB,
    required this.penjelasan,
    required this.saran,
  });

  final String kategori;
  final int totalNeptu;
  final int neptuA;
  final int neptuB;
  final String wetonA;
  final String wetonB;
  final String penjelasan;
  final String saran;
}

class ZodiacCompatibility {
  const ZodiacCompatibility({
    required this.signA,
    required this.signB,
    required this.persentase,
    required this.elemenA,
    required this.elemenB,
    required this.penjelasan,
  });

  final String signA;
  final String signB;
  final int persentase;
  final String elemenA;
  final String elemenB;
  final String penjelasan;
}

class MatchmakingResult {
  const MatchmakingResult({
    required this.profileA,
    required this.profileB,
    required this.wetnan,
    required this.zodiac,
    required this.numerologyScore,
    required this.numerologyInsight,
    required this.humanDesignSynergy,
  });

  final BirthProfile profileA;
  final BirthProfile profileB;
  final WetnanResult wetnan;
  final ZodiacCompatibility zodiac;
  final int numerologyScore;
  final String numerologyInsight;
  final String humanDesignSynergy;
}

class MatchmakingCalculator {
  MatchmakingResult calculate({
    required BirthProfile profileA,
    required BirthProfile profileB,
  }) {
    final primbonCalc = PrimbonCalculator();
    final jawaA = primbonCalc.calculate(profileA).jawa;
    final jawaB = primbonCalc.calculate(profileB).jawa;

    final totalNeptu = jawaA.neptuTotal + jawaB.neptuTotal;
    final wetnan = _calculateWetnan(jawaA, jawaB, totalNeptu);

    final zodiac = _calculateZodiacCompatibility(profileA, profileB);

    final numA = PythagoreanNumerology.calculate(profileA.fullName);
    final numB = PythagoreanNumerology.calculate(profileB.fullName);
    final (numScore, numInsight) = _calculateNumerologyHarmony(numA, numB);

    final hdCalc = HumanDesignCalculator();
    final hdA = hdCalc.calculate(profileA);
    final hdB = hdCalc.calculate(profileB);
    final hdSynergy = _calculateHdSynergy(hdA?.type ?? 'Generator', hdB?.type ?? 'Generator');

    return MatchmakingResult(
      profileA: profileA,
      profileB: profileB,
      wetnan: wetnan,
      zodiac: zodiac,
      numerologyScore: numScore,
      numerologyInsight: numInsight,
      humanDesignSynergy: hdSynergy,
    );
  }

  WetnanResult _calculateWetnan(PrimbonJawa jawaA, PrimbonJawa jawaB, int totalNeptu) {
    final remainder = (totalNeptu % 8 == 0) ? 8 : totalNeptu % 8;

    final (kategori, penjelasan, saran) = switch (remainder) {
      1 => (
        'PEGAT',
        'Kemungkinan menghadapi tantangan komunikasi atau dinamika hubungan di awal. Perlu kedewasaan dan kesabaran ekstra.',
        'Saling mendengarkan, hindari emosi saat berdiskusi, dan jaga komitmen serta kepercayaan.'
      ),
      2 => (
        'RATU',
        'Hubungan dihargai, disegani lingkungan sekitar, harmonis, dan membawa keberkahan.',
        'Pertahankan rasa saling menghormati dan terus mendukung karir serta cita-cita bersama.'
      ),
      3 => (
        'JODOH',
        'Pasangan yang sangat cocok, rukun, saling melengkapi, dan memiliki kemudahan dalam membina rumah tangga.',
        'Jaga komunikasi yang jujur dan nikmati setiap momen kebersamaan.'
      ),
      4 => (
        'TOPO',
        'Masa awal hubungan mungkin membutuhkan perjuangan dan penyesuaian, namun berujung pada kejayaan di masa depan.',
        'Bersabar di masa awal, saling menguatkan, dan percaya bahwa hasil manis akan diraih bersama.'
      ),
      5 => (
        'TINARI',
        'Membawa keberuntungan finansial, murah rezeki, dan dilimpahi kemudahan dalam mencari nafkah.',
        'Gunakan rezeki bersama untuk hal-hal bermanfaat dan rutin berbagi dengan sekitar.'
      ),
      6 => (
        'PADU',
        'Memiliki dinamika perbedaan pendapat yang cukup sering, namun bisa diatasi dengan kompromi.',
        'Turunkan ego masing-masing, cari titik tengah saat berargumen, dan saling memaafkan.'
      ),
      7 => (
        'SUJANAN',
        'Membutuhkan keterbukaan dan transparansi penuh untuk menghindari rasa curiga atau salah paham.',
        'Jaga transparansi, hindari menyimpan rahasia, dan saling percaya penuh.'
      ),
      8 || _ => (
        'PESTHI',
        'Rumah tangga tenteram, damai, rukun, dan langgeng hingga usia tua.',
        'Jaga keharmonisan batin dan bersyukur atas ketenangan hubungan yang dimiliki.'
      ),
    };

    return WetnanResult(
      kategori: kategori,
      totalNeptu: totalNeptu,
      neptuA: jawaA.neptuTotal,
      neptuB: jawaB.neptuTotal,
      wetonA: '${jawaA.hari} ${jawaA.pasaran}',
      wetonB: '${jawaB.hari} ${jawaB.pasaran}',
      penjelasan: penjelasan,
      saran: saran,
    );
  }

  ZodiacCompatibility _calculateZodiacCompatibility(BirthProfile a, BirthProfile b) {
    final signA = _getZodiacSign(a.birthDate);
    final signB = _getZodiacSign(b.birthDate);

    final elemA = _getZodiacElement(signA);
    final elemB = _getZodiacElement(signB);

    final (score, text) = switch ((elemA, elemB)) {
      ('Api', 'Api') => (88, 'Kombinasi penuh semangat, antusiasme, dan dorongan karya yang besar.'),
      ('Api', 'Udara') || ('Udara', 'Api') => (92, 'Sangat serasi! Udara memberi inspirasi dan Api memberi energi wujud.'),
      ('Tanah', 'Air') || ('Air', 'Tanah') => (95, 'Kombinasi paling stabil dan subur! Tanah memberi rasa aman, Air memberi empati.'),
      ('Air', 'Air') => (85, 'Sangat peka dan emosional. Kedalaman empati batin yang kuat.'),
      ('Tanah', 'Tanah') => (90, 'Sangat praktis, realistis, dan kokoh dalam membangun masa depan.'),
      ('Udara', 'Udara') => (86, 'Penuh diskusi intelektual, ide-ide segar, dan komunikasi lancar.'),
      ('Api', 'Tanah') || ('Tanah', 'Api') => (78, 'Saling menyeimbangkan jika Api bersabar dan Tanah terbuka pada perubahan.'),
      ('Air', 'Udara') || ('Udara', 'Air') => (80, 'Kombinasi pikiran dan perasaan yang saling memperkaya jika dipahami.'),
      _ => (82, 'Memiliki dinamika energi unik yang saling melengkapi dalam hubungan.'),
    };

    return ZodiacCompatibility(
      signA: signA,
      signB: signB,
      persentase: score,
      elemenA: elemA,
      elemenB: elemB,
      penjelasan: text,
    );
  }

  (int score, String text) _calculateNumerologyHarmony(NumerologyNumbers a, NumerologyNumbers b) {
    final diffExp = (a.expression - b.expression).abs();
    final diffSoul = (a.soulUrge - b.soulUrge).abs();

    final score = (100 - (diffExp * 6 + diffSoul * 4)).clamp(70, 98);
    final text = 'Nilai Ekspresi ${a.expression} & ${b.expression} membawa sinergi karakter '
        'yang saling mengisi tujuan hidup dan ekspresi diri secara harmonis.';

    return (score, text);
  }

  String _calculateHdSynergy(String typeA, String typeB) {
    if (typeA == typeB) {
      return 'Dua $typeA saling memahami ritme kerja dan pemrosesan energi secara alami.';
    }
    if ((typeA.contains('Generator') && typeB == 'Projector') ||
        (typeB.contains('Generator') && typeA == 'Projector')) {
      return 'Sangat ideal! Energi kerja Generator dipandu oleh pandangan jernih Projector.';
    }
    if (typeA == 'Manifestor' || typeB == 'Manifestor') {
      return 'Manifestor memberi dorongan pemicu langkah baru, ideal jika didampingi komunikasi jujur.';
    }
    return 'Perpaduan tipe $typeA dan $typeB membawa dinamika energi yang saling melengkapi.';
  }

  String _getZodiacSign(DateTime date) {
    final month = date.month;
    final day = date.day;

    return switch (month) {
      1 => day <= 19 ? 'Capricorn' : 'Aquarius',
      2 => day <= 18 ? 'Aquarius' : 'Pisces',
      3 => day <= 20 ? 'Pisces' : 'Aries',
      4 => day <= 19 ? 'Aries' : 'Taurus',
      5 => day <= 20 ? 'Taurus' : 'Gemini',
      6 => day <= 20 ? 'Gemini' : 'Cancer',
      7 => day <= 22 ? 'Cancer' : 'Leo',
      8 => day <= 22 ? 'Leo' : 'Virgo',
      9 => day <= 22 ? 'Virgo' : 'Libra',
      10 => day <= 22 ? 'Libra' : 'Scorpio',
      11 => day <= 21 ? 'Scorpio' : 'Sagittarius',
      12 => day <= 21 ? 'Sagittarius' : 'Capricorn',
      _ => 'Scorpio',
    };
  }

  String _getZodiacElement(String sign) => switch (sign) {
    'Aries' || 'Leo' || 'Sagittarius' => 'Api',
    'Taurus' || 'Virgo' || 'Capricorn' => 'Tanah',
    'Gemini' || 'Libra' || 'Aquarius' => 'Udara',
    'Cancer' || 'Scorpio' || 'Pisces' || _ => 'Air',
  };
}
