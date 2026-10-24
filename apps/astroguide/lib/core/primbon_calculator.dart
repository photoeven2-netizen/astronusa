import 'birth_profile.dart';

class PrimbonJawa {
  const PrimbonJawa({
    required this.hari,
    required this.pasaran,
    required this.neptuHari,
    required this.neptuPasaran,
    required this.neptuTotal,
    required this.wuku,
    required this.watak,
    required this.kelebihan,
    required this.kekurangan,
    required this.jodohCocok,
    required this.hariBaikNikah,
    required this.prediksiRezeki,
    required this.arahKejayaan,
    required this.hariBaikUsaha,
    required this.hariBaikPindah,
    required this.hariSial,
    required this.tafsirKedutan,
    required this.tafsirMimpi,
  });

  final String hari;
  final String pasaran;
  final int neptuHari;
  final int neptuPasaran;
  final int neptuTotal;
  final String wuku;
  final String watak;
  final String kelebihan;
  final String kekurangan;
  final String jodohCocok;
  final String hariBaikNikah;
  final String prediksiRezeki;
  final String arahKejayaan;
  final String hariBaikUsaha;
  final String hariBaikPindah;
  final String hariSial;
  final String tafsirKedutan;
  final String tafsirMimpi;

  String get wetonLabel => '$hari $pasaran (Neptu $neptuTotal)';
}

class PrimbonBali {
  const PrimbonBali({
    required this.wuku,
    required this.saptawara,
    required this.pancawara,
    required this.triwara,
    required this.sadwara,
    required this.dasawara,
    required this.uripTotal,
    required this.sasih,
    required this.pembawaan,
    required this.makna,
    required this.dewasaAyu,
    required this.catatanSunrise,
  });

  final String wuku;
  final String saptawara; // Redite, Soma, Anggara, Buda, Wraspati, Sukra, Saniscara
  final String pancawara; // Umanis, Paing, Pon, Wage, Kliwon
  final String triwara;   // Pasah, Tegeh, Beteng
  final String sadwara;   // Tungleh, Aryang, Urukung, Paniron, Was, Maulu
  final String dasawara;  // Pandita, Pati, Kanta, Natha, Dora, Wieka, Guru, Yama, Ludra, Brahma
  final int uripTotal;
  final String sasih;
  final String pembawaan;
  final String makna;
  final String dewasaAyu;
  final String catatanSunrise;

  String get dinaLabel => 'Dina $saptawara $pancawara (Wuku $wuku, Urip $uripTotal)';
}

class PrimbonChina {
  const PrimbonChina({
    required this.shio,
    required this.elemen,
    required this.simbol,
    required this.karakter,
    required this.kecocokanShio,
    required this.arahKeberuntungan,
  });

  final String shio;
  final String elemen;
  final String simbol;
  final String karakter;
  final String kecocokanShio;
  final String arahKeberuntungan;

  String get label => 'Shio $shio ($elemen)';
}

class PrimbonResult {
  const PrimbonResult({
    required this.jawa,
    required this.bali,
    required this.china,
  });

  final PrimbonJawa jawa;
  final PrimbonBali bali;
  final PrimbonChina china;
}

class PrimbonCalculator {
  static const List<String> _hariJawa = [
    'Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'
  ];

  static const List<int> _neptuHari = [5, 4, 3, 7, 8, 6, 9];

  static const List<String> _pasaranJawa = [
    'Legi', 'Pahing', 'Pon', 'Wage', 'Kliwon'
  ];

  static const List<int> _neptuPasaran = [5, 9, 7, 4, 8];

  static const List<String> _wukuNames = [
    'Sinta', 'Landep', 'Wukir', 'Kurantil', 'Tolu', 'Gumbreg', 'Warigalit', 'Warigagung',
    'Julungwangi', 'Sungsang', 'Galungan', 'Kuningan', 'Langkir', 'Mandasiya', 'Julungpujut',
    'Pahang', 'Kuruwelut', 'Marakeh', 'Tambir', 'Medangkungan', 'Maktal', 'Wuye', 'Manahil',
    'Prangbakat', 'Bala', 'Wugu', 'Wayang', 'Kulawu', 'Dukut', 'Watugunung'
  ];

  static const List<(String shio, String simbol, String karakter, String jodoh, String arah)> _shioData = [
    (
      'Tikus', '🐀',
      'Karakter: Cerdas, periang, cepat tanggap, kreatif, dan pandai melihat peluang bisnis serta investasi.\n'
      '• Karier: Sangat cermat mengelola keuangan, inovatif, dan sukses di bidang wirausaha maupun manajemen strategis.\n'
      '• Asmara: Setia dan penuh perhatian pada keluarga, sangat cocok berdampingan dengan Shio Naga, Monyet, atau Kerbau.',
      'Naga, Monyet, Kerbau', 'Utara & Timur'
    ),
    (
      'Kerbau', '🐂',
      'Karakter: Tekun, pekerja keras, jujur, setia, sabar, dan memiliki tanggung jawab moral yang sangat tinggi.\n'
      '• Karier: Sangat diandalkan dalam pekerjaan jangka panjang, konsisten, teliti, dan memegang prinsip teguh.\n'
      '• Asmara: Pasangan yang dapat diandalkan dan memberikan rasa aman, sangat harmonis dengan Shio Tikus, Ular, atau Ayam.',
      'Tikus, Ular, Ayam', 'Timur Laut & Selatan'
    ),
    (
      'Macan', '🐅',
      'Karakter: Berani, percaya diri, penuh semangat, magnetis, dan memiliki jiwa kepemimpinan alami yang disegani.\n'
      '• Karier: Pemimpin yang berani mengambil risiko besar, inovatif, dan visioner dalam memajukan organisasi.\n'
      '• Asmara: Romantis dan penuh gairah, sangat cocok berpasangan dengan Shio Kuda, Anjing, atau Babi.',
      'Kuda, Anjing, Babi', 'Timur & Selatan'
    ),
    (
      'Kelinci', '🐇',
      'Karakter: Lembut, peka, sopan, diplomatis, menyukai kedamaian, dan memiliki estetika serta selera seni tinggi.\n'
      '• Karier: Unggul di bidang diplomasi, seni, konseling, dan hubungan masyarakat karena kemampuannya mencairkan suasana.\n'
      '• Asmara: Sangat penyayang dan setia, pasanga ideal bagi Shio Kambing, Anjing, atau Babi.',
      'Kambing, Anjing, Babi', 'Timur & Tenggara'
    ),
    (
      'Naga', '🐉',
      'Karakter: Karismatik, ambisius, penuh energi, beruntung secara alami, dan menginspirasi banyak orang di sekitar.\n'
      '• Karier: Menjadi pusat perhatian, memiliki visi besar, dan sukses besar di bidang kepemimpinan serta inovasi.\n'
      '• Asmara: Penuh gairah dan karismatik, sangat cocok berdampingan dengan Shio Tikus, Monyet, atau Ayam.',
      'Tikus, Monyet, Ayam', 'Tenggara & Barat'
    ),
    (
      'Ular', '🐍',
      'Karakter: Bijaksana, intuitif, tenang, misterius, dan memiliki kedalaman berpikir serta analisis yang tajam.\n'
      '• Karier: Pemikir strategis yang handal, mampu melihat solusi di balik masalah pelik, serta cermat dalam keuangan.\n'
      '• Asmara: Sangat setia dan mendalam dalam mencintai, paling cocok dengan Shio Kerbau, Ayam, atau Monyet.',
      'Kerbau, Ayam, Monyet', 'Selatan & Barat'
    ),
    (
      'Kuda', '🐎',
      'Karakter: Penuh energi, mandiri, menyukai kebebasan, ramah, dan antusias dalam mengejar target hidup.\n'
      '• Karier: Pekerja yang dinamis, menyukai tantangan lapangan, dan cepat beradaptasi dengan perubahan.\n'
      '• Asmara: Hangat dan menyenangkan, sangat cocok berpasangan dengan Shio Macan, Kambing, atau Anjing.',
      'Macan, Kambing, Anjing', 'Selatan & Barat Daya'
    ),
    (
      'Kambing', '🐐',
      'Karakter: Kreatif, penuh kasih, empatik, artistik, tenang, dan memiliki kelembutan hati yang tulus.\n'
      '• Karier: Unggul dalam bidang seni, desainer, psikologi, dan bidang kemanusiaan karena empati yang tinggi.\n'
      '• Asmara: Sangat romantis dan penuh pengertian, sangat harmonis dengan Shio Kelinci, Kuda, atau Babi.',
      'Kelinci, Kuda, Babi', 'Barat Daya & Selatan'
    ),
    (
      'Monyet', '🐒',
      'Karakter: Cerdik, inovatif, humoris, serba bisa, dan pandai menyelesaikan masalah rumit dengan cepat.\n'
      '• Karier: Pemecah masalah ulung, cerdas dalam negosiasi, dan memiliki banyak ide cemerlang.\n'
      '• Asmara: Menyenangkan dan penuh kejutan, sangat cocok bersanding dengan Shio Tikus, Naga, atau Ular.',
      'Tikus, Naga, Ular', 'Barat & Utara'
    ),
    (
      'Ayam', '🐓',
      'Karakter: Teliti, teratur, pekerja keras, jujur, perfeksionis, dan berpegang teguh pada prinsip hidup.\n'
      '• Karier: Manajemen waktu dan detail yang sangat baik, teliti, serta sukses di bidang administrasi dan profesionalisme.\n'
      '• Asmara: Terus terang dan bertanggung jawab, sangat cocok berpasangan dengan Shio Kerbau, Ular, atau Naga.',
      'Kerbau, Ular, Naga', 'Barat & Barat Laut'
    ),
    (
      'Anjing', '🐕',
      'Karakter: Setia, jujur, memiliki rasa keadilan yang tinggi, pelindung, dan sangat dapat diandalkan.\n'
      '• Karier: Pembela kebenaran, dapat dipercaya dalam tim, serta loyal terhadap visi perusahaan.\n'
      '• Asmara: Pasangan paling setia dan pelindung keluarga, sangat harmonis dengan Shio Macan, Kelinci, atau Kuda.',
      'Macan, Kelinci, Kuda', 'Barat Laut & Timur'
    ),
    (
      'Babi', '🐖',
      'Karakter: Dermawan, tulus, tenang, menyukai kenyamanan hidup, optimis, dan berhati mulia.\n'
      '• Karier: Jujur dalam berbisnis, dermawan, serta menikmati hasil kerja keras dengan bijaksana.\n'
      '• Asmara: Penyayang dan hangat, sangat cocok berdampingan dengan Shio Kambing, Kelinci, atau Macan.',
      'Kambing, Kelinci, Macan', 'Barat Laut & Utara'
    ),
  ];

  static const Map<int, (int, int)> _imlekDates = {
    1970: (2, 6), 1971: (1, 27), 1972: (2, 15), 1973: (2, 3), 1974: (1, 23),
    1975: (2, 11), 1976: (1, 31), 1977: (2, 18), 1978: (2, 7), 1979: (1, 28),
    1980: (2, 16), 1981: (2, 5), 1982: (1, 25), 1983: (2, 13), 1984: (2, 2),
    1985: (2, 20), 1986: (2, 9), 1987: (1, 29), 1988: (2, 17), 1989: (2, 6),
    1990: (1, 27), 1991: (2, 15), 1992: (2, 4), 1993: (1, 23), 1994: (2, 10),
    1995: (1, 31), 1996: (2, 19), 1997: (2, 7), 1998: (1, 28), 1999: (2, 16),
    2000: (2, 5), 2001: (1, 24), 2002: (2, 12), 2003: (2, 1), 2004: (1, 22),
    2005: (2, 9), 2006: (1, 29), 2007: (2, 18), 2008: (2, 7), 2009: (1, 26),
    2010: (2, 14), 2011: (2, 3), 2012: (1, 23), 2013: (2, 10), 2014: (1, 31),
    2015: (2, 19), 2016: (2, 8), 2017: (1, 28), 2018: (2, 16), 2019: (2, 5),
    2020: (1, 25), 2021: (2, 12), 2022: (2, 1), 2023: (1, 22), 2024: (2, 10),
    2025: (1, 29), 2026: (2, 17), 2027: (2, 6), 2028: (1, 26), 2029: (2, 13),
    2030: (2, 3),
  };

  static int _julianDayNumber(DateTime date) {
    final year = date.year;
    final month = date.month;
    final day = date.day;

    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;

    return day + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;
  }

  PrimbonResult calculate(BirthProfile profile) {
    final date = profile.birthDate;
    final jdn = _julianDayNumber(date);

    // Saptawara (Hari): JDN % 7
    final hariIdx = (jdn + 1) % 7;
    final hari = _hariJawa[hariIdx];
    final nepHari = _neptuHari[hariIdx];

    // Pancawara (Pasaran): JDN % 5
    final pasaranIdx = jdn % 5;
    final pasaran = _pasaranJawa[pasaranIdx];
    final nepPasaran = _neptuPasaran[pasaranIdx];

    final totalNeptu = nepHari + nepPasaran;

    // Wuku Cycle (210 days cycle) - Anchor: Galungan JDN % 210 = 9 -> Wuku Dungulan (10)
    final wukuIdx = (((jdn - 146) % 210 + 210) % 210) ~/ 7;
    final wuku = _wukuNames[wukuIdx];

    final (watak, kelebihan, kekurangan) = _getWatakLengkap(totalNeptu, pasaran);
    final (jodohCocok, hariBaikNikah) = _getJodohPernikahan(totalNeptu);
    final (prediksiRezeki, arahKejayaan) = _getRezekiKeberuntungan(totalNeptu, pasaran);
    final (hariBaikUsaha, hariBaikPindah, hariSial) = _getHariBaikSial(totalNeptu, hari, pasaran);
    final (tafsirKedutan, tafsirMimpi) = _getTafsirFirasat(totalNeptu);

    final jawa = PrimbonJawa(
      hari: hari,
      pasaran: pasaran,
      neptuHari: nepHari,
      neptuPasaran: nepPasaran,
      neptuTotal: totalNeptu,
      wuku: wuku,
      watak: watak,
      kelebihan: kelebihan,
      kekurangan: kekurangan,
      jodohCocok: jodohCocok,
      hariBaikNikah: hariBaikNikah,
      prediksiRezeki: prediksiRezeki,
      arahKejayaan: arahKejayaan,
      hariBaikUsaha: hariBaikUsaha,
      hariBaikPindah: hariBaikPindah,
      hariSial: hariSial,
      tafsirKedutan: tafsirKedutan,
      tafsirMimpi: tafsirMimpi,
    );

    // Primbon Bali (Wariga & Pawukon Bali)
    // BALINESE WARIGA DAY TURNOVER RULE:
    // A Balinese Wariga day (Rahina) starts at Sunrise (06:00 AM local time / 06:00 WITA).
    // If born before 06:00 AM (00:00 - 05:59 AM), in Wariga Bali the day is count as the previous day!
    final bool isBeforeBaliSunrise = profile.birthTimeMinutes != null && profile.birthTimeMinutes! < 360;
    final baliDate = isBeforeBaliSunrise
        ? date.subtract(const Duration(days: 1))
        : date;
    final baliJdn = _julianDayNumber(baliDate);

    final baliHariIdx = (baliJdn + 1) % 7;
    final baliPasaranIdx = baliJdn % 5;
    final baliWukuIdx = (((baliJdn - 146) % 210 + 210) % 210) ~/ 7;

    const saptawaraBali = ['Redite', 'Soma', 'Anggara', 'Buda', 'Wraspati', 'Sukra', 'Saniscara'];
    const pancawaraBali = ['Umanis', 'Paing', 'Pon', 'Wage', 'Kliwon'];
    const wukuBaliList = [
      'Sinta', 'Landep', 'Ukir', 'Kulantir', 'Tolu', 'Gumbreg', 'Wariga', 'Warigade',
      'Julungwangi', 'Sungsang', 'Dungulan', 'Kuningan', 'Langkir', 'Medangsia', 'Pujut',
      'Pahang', 'Krulut', 'Merrakih', 'Tambir', 'Medangkungan', 'Matal', 'Uye', 'Menail',
      'Prangbakat', 'Bala', 'Ugu', 'Wayang', 'Klawu', 'Dukut', 'Watugunung'
    ];
    const triwaraList = ['Pasah', 'Tegeh', 'Beteng'];
    const sadwaraList = ['Tungleh', 'Aryang', 'Urukung', 'Paniron', 'Was', 'Maulu'];
    const dasawaraList = ['Pandita', 'Pati', 'Kanta', 'Natha', 'Dora', 'Wieka', 'Guru', 'Yama', 'Ludra', 'Brahma'];

    final saptawaraName = saptawaraBali[baliHariIdx];
    final pancawaraName = pancawaraBali[baliPasaranIdx];
    final wukuNameBali = wukuBaliList[baliWukuIdx];

    final triwaraIdx = ((baliJdn + 2) % 3 + 3) % 3;
    final triwaraName = triwaraList[triwaraIdx];

    final sadwaraIdx = ((baliJdn % 6) + 6) % 6;
    final sadwaraName = sadwaraList[sadwaraIdx];

    final uripSaptawara = _neptuHari[baliHariIdx];
    final uripPancawara = _neptuPasaran[baliPasaranIdx];
    final uripTotal = uripSaptawara + uripPancawara;

    final dasawaraIdx = (uripTotal + 1) % 10;
    final dasawaraName = dasawaraList[dasawaraIdx];

    final sasihList = [
      'Sasih Kasa (Bulan 1)', 'Sasih Karo (Bulan 2)', 'Sasih Katiga (Bulan 3)',
      'Sasih Kapat (Bulan 4)', 'Sasih Kalima (Bulan 5)', 'Sasih Kanem (Bulan 6)',
      'Sasih Kapitu (Bulan 7)', 'Sasih Kaulu (Bulan 8)', 'Sasih Kasanga (Bulan 9)',
      'Sasih Kadasa (Bulan 10)', 'Sasih Jyestha (Bulan 11)', 'Sasih Sadha (Bulan 12)'
    ];
    final sasihName = sasihList[(baliDate.month - 1) % 12];

    final pembawaanBali = _getPembawaanWarigaBali(uripTotal, wukuNameBali, saptawaraName);
    final maknaBali = 'Padewasan Wariga: Dina $saptawaraName $pancawaraName (Wuku $wukuNameBali, Urip $uripTotal, $triwaraName, Dasawara $dasawaraName) membawa vibrasi keselarasan batin.';
    final dewasaAyuBali = 'Dewasa Ayu: Rahayu untuk upacara Ngekeb, Dewa Yadnya, memulai usaha baru, dan mohon keselamatan batin.';

    final catatanSunrise = isBeforeBaliSunrise
        ? 'Perantian Rahina Wariga Bali dihitung sejak Terbit Matahari (06.00 WITA). Karena lahir sebelum 06.00 WITA, Rahina Wariga mengikuti hari sebelumnya ($saptawaraName $pancawaraName).'
        : 'Perantian Rahina Wariga Bali dihitung sejak Terbit Matahari (06.00 WITA).';

    final bali = PrimbonBali(
      wuku: wukuNameBali,
      saptawara: saptawaraName,
      pancawara: pancawaraName,
      triwara: triwaraName,
      sadwara: sadwaraName,
      dasawara: dasawaraName,
      uripTotal: uripTotal,
      sasih: sasihName,
      pembawaan: pembawaanBali,
      makna: maknaBali,
      dewasaAyu: dewasaAyuBali,
      catatanSunrise: catatanSunrise,
    );

    // Primbon China (Shio & Elemen)
    final lunarYear = _getLunarYear(date);
    final shioIdx = ((lunarYear - 4) % 12 + 12) % 12;
    final (shioName, simbol, karakter, jodohShio, arahShio) = _shioData[shioIdx];

    final lastDigit = lunarYear % 10;
    final elemen = switch (lastDigit) {
      0 || 1 => 'Logam',
      2 || 3 => 'Air',
      4 || 5 => 'Kayu',
      6 || 7 => 'Api',
      8 || 9 => 'Tanah',
      _ => 'Kayu',
    };

    final china = PrimbonChina(
      shio: shioName,
      elemen: elemen,
      simbol: simbol,
      karakter: karakter,
      kecocokanShio: jodohShio,
      arahKeberuntungan: arahShio,
    );

    return PrimbonResult(jawa: jawa, bali: bali, china: china);
  }

  String _getPembawaanWarigaBali(int urip, String wuku, String saptawara) {
    return 'Berdasarkan Lontar Wariga Catur Winasa Sari: Lahir pada $saptawara (Wuku $wuku) bernilai Urip $urip. '
        'Mempunyai pembawaan batin tenang, tutur kata halus, berhati tulus, dikagumi lingkungan, dan dikaruniai kejelian batin.';
  }

  int _getLunarYear(DateTime date) {
    final year = date.year;
    final imlek = _imlekDates[year];
    if (imlek != null) {
      final imlekDate = DateTime(year, imlek.$1, imlek.$2);
      if (date.isBefore(imlekDate)) {
        return year - 1;
      }
    }
    return year;
  }

  (String watak, String kelebihan, String kekurangan) _getWatakLengkap(int neptu, String pasaran) => switch (neptu) {
    7 => (
      'Laku Pandhita Sakti: Rendah hati, bijaksana, pemikir mendalam, dan pencerah.',
      'Sangat bijaksana, berpendidikan tinggi, sabar, dan dihormati.',
      'Kadang terlalu tertutup dan mudah sungkan dalam bertindak.'
    ),
    8 => (
      'Laku Geni: Penuh semangat, hangat, berani, dan berpendirian kuat.',
      'Pekerja keras, tegas, tidak mudah menyerah, dan hangat.',
      'Emosi cepat tersulut jika merasa tidak dihargai.'
    ),
    9 => (
      'Laku Angin: Ramah, fleksibel, mudah bergaul, dan kreatif.',
      'Mudah beradaptasi, disukai banyak orang, cerdas, dan banyak ide.',
      'Cenderung pemaaf tapi kadang tidak konsisten saat mengambil pilihan.'
    ),
    10 => (
      'Laku Setan: Penuh pesona, mandiri, pandai memimpin, dan tangguh.',
      'Berwibawa, karismatik, pekerja keras, dan solutif.',
      'Perlu mengontrol ego agar tidak terkesan dominan.'
    ),
    11 => (
      'Laku Bumi: Pengayom, sabar, murah hati, dan tempat berteduh.',
      'Sangat dermawan, setia, suka membantu, dan berhati tulus.',
      'Kadang terlalu memendam masalah sendiri.'
    ),
    12 => (
      'Laku Lakuning Lintang: Pendiam, mandiri, dan memiliki daya pikat alami.',
      'Mempunyai karisma magis, tekun, dan cermat mengelola keuangan.',
      'Cenderung introver dan memilih memendam perasaan.'
    ),
    13 => (
      'Laku Lakuning Bintang: Bijaksana, tenang, dan dihormati masyarakat.',
      'Jiwa pemimpin tinggi, tenang, pandai menasihati, dan adil.',
      'Memiliki standar tinggi pada diri sendiri dan orang lain.'
    ),
    14 => (
      'Laku Lakuning Bulan: Menyejukkan, penuh empati, dan pencerah.',
      'Memiliki empati tinggi, pandai mencairkan suasana, dan disukai banyak orang.',
      'Mudah perasa jika mendapatkan kata-kata yang keras.'
    ),
    15 => (
      'Laku Lakuning Srengenge: Wibawa tinggi, berani, dan berjiwa pemandu.',
      'Berani mengambil keputusan, berjiwa terang, dan penggerak.',
      'Cenderung keras kepala jika yakin pada suatu prinsip.'
    ),
    16 => (
      'Laku Lakuning Banyu: Sejuk, tenang, rezeki mengalir, dan adaptable.',
      'Tenang menghadapi krisis, murah rezeki, dan murah hati.',
      'Kadang terlalu santai menghadapi hal-hal yang mendesak.'
    ),
    17 => (
      'Laku Lakuning Gunung: Kokoh, mandiri, pendorong semangat, dan pelindung.',
      'Sangat tangguh, dapat diandalkan, dan berwawasan luas.',
      'Keras dalam berprinsip dan kurang fleksibel saat berubah rencana.'
    ),
    18 => (
      'Laku Lakuning Parahyang: Berwibawa, berbudi luhur, dan mudah sukses.',
      'Dikaruniai kemudahan cita-cita, berbudi luhur, dan karismatik.',
      'Perlu menjaga kerendahan hati saat di puncak keberhasilan.'
    ),
    _ => (
      'Energi Seimbang: Membawa daya juang dan kestabilan dalam hidup.',
      'Tangguh dan pekerja keras.',
      'Perlu mengelola fokus dengan baik.'
    ),
  };

  (String jodoh, String hariNikah) _getJodohPernikahan(int neptu) {
    final cocokNeptu = switch (neptu) {
      7 || 12 || 17 => 'Paling cocok dengan pasangan Neptu 7, 12, atau 17 (misal: Selasa Wage, Senin Kliwon, Minggu Pon, Kamis Pahing, Sabtu Kliwon).',
      8 || 13 || 18 => 'Paling cocok dengan pasangan Neptu 11 atau 16 (misal: Senin Pon, Selasa Kliwon, Rabu Wage, Jumat Legi, Sabtu Pon).',
      9 || 14 => 'Paling cocok dengan pasangan Neptu 10 atau 15 (misal: Minggu Legi, Selasa Pon, Jumat Kliwon, Rabu Kliwon, Kamis Pon).',
      10 || 15 => 'Paling cocok dengan pasangan Neptu 9 atau 14 (misal: Minggu Wage, Senin Legi, Minggu Pahing, Rabu Pon, Jumat Kliwon).',
      11 || 16 => 'Paling cocok dengan pasangan Neptu 8 atau 13 (misal: Selasa Legi, Senin Pahing, Kamis Legi, Jumat Pon, Sabtu Wage).',
      _ => 'Cocok dengan pasangan yang memiliki Neptu seimbang (selisih neptu 3 atau 7).',
    };

    const hariNikah = 'Hari baik pernikahan dihitung pada hari dengan Neptu gabungan berkategori Tinari (rezeki berlimpah), Jodoh (harmonis), atau Ratu (dihormati).';
    return (cocokNeptu, hariNikah);
  }

  (String rezeki, String arah) _getRezekiKeberuntungan(int neptu, String pasaran) {
    final arah = switch (pasaran) {
      'Legi' => 'Timur & Utara (Arah mata angin utama rezeki dan kelancaran usaha).',
      'Pahing' => 'Selatan & Barat (Arah keberuntungan dan pintu rezeki).',
      'Pon' => 'Barat & Selatan (Arah kejayaan dagang dan karir).',
      'Wage' => 'Utara & Timur (Arah kelancaran urusan dan rezeki).',
      'Kliwon' => 'Pusat & Timur (Arah keberkahan dan ketenangan batin).',
      _ => 'Timur & Selatan.',
    };

    final rezeki = 'Siklus rezeki stabil dan cenderung memuncak pada rentang usia 24–30 tahun dan 42–48 tahun. Mengalir lancar jika rutin berbagi dan menjaga hubungan baik.';
    return (rezeki, arah);
  }

  (String usaha, String pindah, String sial) _getHariBaikSial(int neptu, String hari, String pasaran) {
    final usaha = 'Hari baik memulai usaha/bisnis: $hari $pasaran atau hari Selasa/Jumat dengan Neptu 11–14.';
    final pindah = 'Hari baik pindah/boyongan rumah: Cari hari bernilai Guru atau Ratu (misal: Jumat Legi atau Kamis Pahing).';
    final sial = 'Hari naas yang perlu dihindari untuk acara besar: Hari yang bertepatan dengan Naas Wasgede atau Tali Wangke weton kelahiranmu.';
    return (usaha, pindah, sial);
  }

  (String kedutan, String mimpi) _getTafsirFirasat(int neptu) {
    const kedutan = '• Kedutan kelopak mata kanan atas: Firasat akan menerima kabar baik/rezeki tak terduga.\n• Kedutan telapak tangan kanan: Firasat akan menerima rezeki atau kedatangan tamu jauh.';
    const mimpi = 'Tafsir mimpi pada jam sakral (Puspo Tajem 02:00–04:00): Mimpi berada di alam terbuka atau menerima benda pertanda kebaikan dan kemudahan rezeki.';
    return (kedutan, mimpi);
  }
}
