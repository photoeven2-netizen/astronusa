import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../features/human_design_chart_view.dart';
import 'astro_coach_client.dart';
import 'birth_profile.dart';
import 'human_design_calculator.dart';
import 'matchmaking_calculator.dart';
import 'primbon_calculator.dart';

class HumanDesignPdfExporter {
  static Future<Uint8List> generatePdf({
    required HumanDesignChart hdChart,
    required BirthProfile profile,
    MatchmakingResult? matchmaking,
    AstroReading? reading,
  }) async {
    final pdf = pw.Document(
      title: 'AstroNusa Master Personal Report - ${profile.fullName}',
      author: 'AstroNusa',
    );

    final fontRegular = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    final dateStr = _formatDate(profile.birthDate);
    final timeStr = profile.birthTimeMinutes != null
        ? _formatTime(profile.birthTimeMinutes!)
        : 'Waktu Tidak Diketahui';

    final primaryColor = PdfColor.fromHex('#1B122C');
    final goldColor = PdfColor.fromHex('#D4AF37');
    final darkBg = PdfColor.fromHex('#231838');

    // Render Bodygraph PNG Image Bytes (3-Column Layout: Tubuh | Diagram | Jiwa)
    final bodygraphPngBytes = await BodygraphImageRenderer.renderPngBytes(hdChart);
    final bodygraphImage = pw.MemoryImage(bodygraphPngBytes);

    // Calculate Primbon
    final primbon = PrimbonCalculator().calculate(profile);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 6),
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: goldColor, width: 1.5)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'AstroNusa Master Personal Reading Report',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              pw.Text(
                'Laporan Analisis Resmi Lengkap',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'AstroNusa - Privacy-First Indonesian Astrology, Primbon & Human Design',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
              pw.Text(
                'Halaman ${context.pageNumber} dari ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
            ],
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 10),

          // User Bio Header Card
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: darkBg,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      profile.fullName,
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: goldColor,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Lahir: $dateStr • $timeStr • ${profile.cityName}',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.white),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: pw.BoxDecoration(
                    color: goldColor,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    'ASTRONUSA',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 12),

          // Bodygraph Visual Chart & Summary Side-by-Side
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Human Design Chart Diagram Image (3-Column Layout: Tubuh | Diagram | Jiwa)
              pw.Container(
                width: 240,
                height: 250,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: primaryColor, width: 1),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.ClipRRect(
                  horizontalRadius: 8,
                  verticalRadius: 8,
                  child: pw.Image(bodygraphImage, fit: pw.BoxFit.contain),
                ),
              ),
              pw.SizedBox(width: 12),

              // Human Design Core Highlights
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'RINGKASAN HUMAN DESIGN',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    _summaryRow('Tipe Energi', hdChart.typeLabel),
                    _summaryRow('Otoritas', hdChart.authority),
                    _summaryRow('Profil', hdChart.profileLabel),
                    _summaryRow('Strategi', hdChart.strategy),
                    _summaryRow('Definisi', hdChart.definitionLabel),
                    _summaryRow('Tema Diri Sejati', hdChart.signatureTheme),
                    _summaryRow('Tema Bukan Diri', hdChart.notSelfTheme),
                    _summaryRow('Saluran Aktif', hdChart.activeChannels.map((c) => c.name).join(', ')),
                  ],
                ),
              ),
            ],
          ),

          // HASIL BACAAN & PENELUSURAN AI COACH SECTION (Printed in Full Unabridged Text)
          if (reading != null) ...[
            pw.SizedBox(height: 14),
            pw.Text(
              '✨ HASIL BACAAN & PENELUSURAN ASTRONUSA',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.purple50,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColors.purple300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(reading.opening, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey900)),
                  pw.SizedBox(height: 6),
                  _pdfDetailRow('• Persona & Sinergi Nama:', reading.nameInsight),
                  if (reading.sunInsight != null) _pdfDetailRow('• Analisis Bintang Utama:', reading.sunInsight!),
                  if (reading.moonInsight != null) _pdfDetailRow('• Kedalaman Batin:', reading.moonInsight!),
                  if (reading.risingInsight != null) _pdfDetailRow('• Topeng Sosial:', reading.risingInsight!),
                  if (reading.careerLoveInsight != null) _pdfDetailRow('• Potensi Karir & Cinta:', reading.careerLoveInsight!),
                  pw.SizedBox(height: 4),
                  _pdfDetailRow('• Astro-Advice Utama:', reading.advice),
                ],
              ),
            ),
          ],

          // PERHITUNGAN JODOH & PASANGAN SECTION (If calculated)
          if (matchmaking != null) ...[
            pw.SizedBox(height: 14),
            pw.Text(
              '💖 HASIL PERHITUNGAN JODOH & KECOCOKAN PASANGAN',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.pink50,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColors.pink300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Pasangan: ${matchmaking.profileB.fullName} (Lahir: ${_formatDate(matchmaking.profileB.birthDate)} • ${matchmaking.profileB.cityName})', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey900)),
                  pw.SizedBox(height: 4),
                  _pdfDetailRow('• Wetnan Jawa (Neptu ${matchmaking.wetnan.totalNeptu}):', 'Kategori: ${matchmaking.wetnan.kategori}\n${matchmaking.wetnan.penjelasan}\nSaran: ${matchmaking.wetnan.saran}'),
                  _pdfDetailRow('• Sinergi Zodiak (${matchmaking.zodiac.persentase}% Cocok):', '${matchmaking.zodiac.signA} (${matchmaking.zodiac.elemenA}) ❤️ ${matchmaking.zodiac.signB} (${matchmaking.zodiac.elemenB}) - ${matchmaking.zodiac.penjelasan}'),
                  _pdfDetailRow('• Harmoni Nama & HD (${matchmaking.numerologyScore}%):', '${matchmaking.numerologyInsight}\nSinergi HD: ${matchmaking.humanDesignSynergy}'),
                ],
              ),
            ),
          ],

          pw.SizedBox(height: 14),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 10),

          // PRIMBON NUSANTARA & SHIO SECTION (Full Unabridged Details)
          pw.Text(
            'PRIMBON NUSANTARA & SHIO (5 KATEGORI LENGKAP)',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
            ),
          ),
          pw.SizedBox(height: 8),

          // 1. Primbon Jawa Card (Full Unabridged Details)
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.amber50,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: PdfColors.amber300),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '🌺 Primbon Jawa (Betaljemur Adammakna)',
                  style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold, color: primaryColor),
                ),
                pw.SizedBox(height: 4),
                pw.Text('Weton: ${primbon.jawa.wetonLabel} • Wuku: ${primbon.jawa.wuku}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey900)),
                pw.SizedBox(height: 6),
                _pdfDetailRow('1. Watak & Karakter Kelahiran:', '${primbon.jawa.watak}\n• Kelebihan: ${primbon.jawa.kelebihan}\n• Kekurangan & Solusi: ${primbon.jawa.kekurangan}'),
                _pdfDetailRow('2. Jodoh & Pernikahan (Wetnan):', '${primbon.jawa.jodohCocok}\n• ${primbon.jawa.hariBaikNikah}'),
                _pdfDetailRow('3. Rezeki & Arah Kejayaan:', '${primbon.jawa.prediksiRezeki}\n• Arah Kejayaan: ${primbon.jawa.arahKejayaan}'),
                _pdfDetailRow('4. Penentuan Hari Baik & Naas:', '• ${primbon.jawa.hariBaikUsaha}\n• ${primbon.jawa.hariBaikPindah}\n• ${primbon.jawa.hariSial}'),
                _pdfDetailRow('5. Tafsir Firasat & Mimpi:', '${primbon.jawa.tafsirKedutan}\n• ${primbon.jawa.tafsirMimpi}'),
              ],
            ),
          ),

          pw.SizedBox(height: 8),

          // 2. Primbon Bali & China Side-by-Side (Full Unabridged Details)
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green50,
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: PdfColors.green300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('🌴 Primbon Bali (Wariga / Pawukon)', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                      pw.SizedBox(height: 4),
                      pw.Text(primbon.bali.dinaLabel, style: const pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
                      pw.SizedBox(height: 4),
                      _pdfDetailRow('Wewaran:', 'Triwara: ${primbon.bali.triwara} • Sadwara: ${primbon.bali.sadwara} • Dasawara: ${primbon.bali.dasawara}'),
                      _pdfDetailRow('Sasih:', primbon.bali.sasih),
                      _pdfDetailRow('Perantian Rahina:', primbon.bali.catatanSunrise),
                      _pdfDetailRow('Pembawaan:', primbon.bali.pembawaan),
                      _pdfDetailRow('Makna Energi:', primbon.bali.makna),
                      _pdfDetailRow('Dewasa Ayu:', primbon.bali.dewasaAyu),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.orange50,
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: PdfColors.orange300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('🐉 Primbon China (Shio & Elemen)', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                      pw.SizedBox(height: 4),
                      pw.Text('${primbon.china.simbol} ${primbon.china.label}', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey900)),
                      pw.SizedBox(height: 4),
                      _pdfDetailRow('Sifat Utama:', primbon.china.karakter),
                      _pdfDetailRow('Kecocokan Shio:', primbon.china.kecocokanShio),
                      _pdfDetailRow('Arah Hoki:', primbon.china.arahKeberuntungan),
                    ],
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 14),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 10),

          // 14 DETAILED HUMAN DESIGN ANALYSIS SECTIONS
          pw.Text(
            'LAPORAN ANALISIS MENDALAM HUMAN DESIGN (14 BAGIAN)',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
            ),
          ),
          pw.SizedBox(height: 10),

          ..._build14ReportSections(hdChart, profile),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _summaryRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 85,
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
            ),
          ),
          pw.Text(': ', style: const pw.TextStyle(fontSize: 8.5)),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1B122C')),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _pdfDetailRow(String title, String body) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.RichText(
        text: pw.TextSpan(
          style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey900),
          children: [
            pw.TextSpan(text: '$title ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1B122C'))),
            pw.TextSpan(text: body),
          ],
        ),
      ),
    );
  }

  static List<pw.Widget> _build14ReportSections(
    HumanDesignChart hdChart,
    BirthProfile profile,
  ) {
    final name = profile.fullName;
    final sections = [
      (
        '1. Tipe Energi & Strategi Alami',
        '$name adalah seorang ${hdChart.typeLabel}. Strategi alami untuk berinteraksi dengan dunia '
            'dan mengambil langkah hidup adalah "${hdChart.strategy}". Saat hidup selaras dengan strategi ini, '
            'kamu merasakan "${hdChart.signatureTheme}", namun jika memaksakan tanpa menyelaraskan strategi, '
            'kamu akan merasakan "${hdChart.notSelfTheme}".'
      ),
      (
        '2. Otoritas Pengambilan Keputusan',
        'Otoritas kompas batinmu adalah "${hdChart.authority}". Jangan mengandalkan logika '
            'kepala untuk keputusan besar. Berikan waktu bagi tubuhmu untuk merasakan kejelasan dari kompas otoritas ini.'
      ),
      (
        '3. Profil Kepribadian (${hdChart.profileLabel})',
        'Profil ${hdChart.profileLabel} menggambarkan peran dan dinamika pembelajaran hidupmu. Kombinasi '
            'jalur sadar dan bawah sadar ini membentuk cara unikmu berinteraksi, beradaptasi, dan berbagi karya dengan masyarakat.'
      ),
      (
        '4. Pusat Energi Terdefinisi (Aktif)',
        'Pusat-pusat energi aktif yang terdefinisi padamu adalah tempat di mana kamu memiliki '
            'energi yang konsisten, stabil, dan menjadi pancaran pengaruh positif bagi orang-orang di sekitarmu.'
      ),
      (
        '5. Pusat Energi Terbuka (Kebijaksanaan)',
        'Pusat-pusat energi terbuka adalah tempat di mana kamu menyerap dan mengamplifikasi energi sekitar. '
            'Di sinilah letak potensi pembelajaran dan kebijaksanaan terbesar dalam hidupmu.'
      ),
      (
        '6. Saluran & Gerbang (Channels & Gates)',
        'Saluran aktifmu (${hdChart.activeChannels.map((c) => c.name).join(", ")}) menghubungkan pusat energi dan membentuk bakat alami, '
            'aliran kreativitas, serta dorongan jiwa yang konsisten.'
      ),
      (
        '7. Tema Diri Sejati vs Bukan Diri',
        'Navigasikan hidup dengan peka terhadap sinyal batinmu: jika merasakan ${hdChart.signatureTheme}, '
            'kamu berada di jalur Diri Sejati. Jika merasakan ${hdChart.notSelfTheme}, saatnya berhenti sejenak dan mengevaluasi.'
      ),
      (
        '8. Dinamika Hubungan & Komunikasi',
        'Dalam relasi sosial dan asmara, gaya energimu yang terbuka membutuhkan pemahaman bahwa tidak semua hal '
            'harus dipaksakan secara tergesa-gesa. Berikan ruang komunikasi yang saling menghargai.'
      ),
      (
        '9. Potensi Karier & Lingkungan Kerja',
        'Lingkungan kerja ideal bagi $name adalah tempat yang menghargai tipe ${hdChart.typeLabel}, memberikan kebebasan '
            'berkarya, serta tidak memaksakan ritme kerja yang bertentangan dengan otoritas batinmu.'
      ),
      (
        '10. Kesehatan, Nutrisi, & Energi Vital',
        'Dengarkan sinyal tubuh dengan cermat. Istirahat sebelum tubuh merasa lelah total dan konsumsi makanan '
            'serta lingkungan yang mendukung ketenangan batinmu.'
      ),
      (
        '11. Siklus Pembelajaran & Tantangan',
        'Tantangan hidup bukan hambatan, melainkan tempat mengasah ketangguhan dan pemahaman diri yang lebih mendalam.'
      ),
      (
        '12. Panduan Intuisi & Kesadaran',
        'Latihlah keheningan batin untuk selalu terhubung dengan Otoritas ${hdChart.authority} agar setiap keputusan membawa ketenangan.'
      ),
      (
        '13. Tujuan Hidup & Misi Jiwa',
        'Misi jiwamu adalah mengekspresikan potensi alami secara tulus, menginspirasi lingkungan sekitar, dan membawa keberkahan.'
      ),
      (
        '14. Afirmasi & Langkah Praktis Harian',
        'Afirmasi: "Saya percaya pada ritme alamiah tubuh saya. Saya melangkah dengan Otoritas ${hdChart.authority} '
            'dan hidup penuh keharmonisan sebagai ${hdChart.typeLabel}."'
      ),
    ];

    return sections
        .map(
          (s) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey50,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  s.$1,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#1B122C'),
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  s.$2,
                  style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey900),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String _formatTime(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m WIB';
  }
}
