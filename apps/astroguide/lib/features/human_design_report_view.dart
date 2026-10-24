import 'package:flutter/material.dart';

import '../core/birth_profile.dart';
import '../core/human_design_calculator.dart';
import '../theme/app_theme.dart';

class HumanDesignReportView extends StatelessWidget {
  const HumanDesignReportView({
    required this.hdChart,
    required this.profile,
    super.key,
  });

  final HumanDesignChart hdChart;
  final BirthProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        _sectionHeader('Isi Dokumen & Panduan Analisis'),
        const SizedBox(height: 12),

        // Section 0: Cara Membaca Dokumen Ini
        _ReportCard(
          number: '0',
          title: 'Cara Membaca Dokumen Ini',
          icon: Icons.menu_book,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Human Design menggabungkan astrologi, I Ching, Kabbalah, dan sistem chakra '
                'menjadi satu peta energi yang disebut Bodygraph. Peta ini adalah alat refleksi diri '
                'untuk mengenali pola energi, cara mengambil keputusan, dan cara berhubungan dengan orang lain.',
                style: TextStyle(color: AstroPalette.parchment, height: 1.4),
              ),
              const SizedBox(height: 10),
              _bullet('Center berwarna (Emas/Merah) berarti Defined: energi konsisten milikmu.'),
              _bullet('Center gelap/transparan berarti Terbuka: tempat kamu menyerap energi orang lain dan membangun kebijaksanaan.'),
              _bullet('Garis Hitam (Sisi Jiwa/Kepribadian) mewakili energi sadar.'),
              _bullet('Garis Merah (Sisi Tubuh/Design) mewakili energi bawah sadar.'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Section 1: Ringkasan Sifat Utama
        _ReportCard(
          number: '1',
          title: 'Ringkasan Sifat Utama',
          icon: Icons.auto_awesome,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _subHeading('Tipe Energi: ${hdChart.typeLabel}'),
              const Text(
                'Penuh energi vital dan dorongan bertindak cepat. Menyukai proses belajar '
                'lewat mencoba langsung (trial & error), siap memecahkan masalah, serta lihai '
                'menyampaikan ide dan menginspirasi lewat cerita.',
                style: TextStyle(color: AstroPalette.parchment, height: 1.4),
              ),
              const SizedBox(height: 12),
              _subHeading('Sifat Positif Utama:'),
              _bullet('Daya dorong kerja dan kreasi yang kuat.'),
              _bullet('Kemampuan komunikasi dan narasi yang menggerakkan orang lain.'),
              _bullet('Inovatif dalam menemukan cara baru.'),
              _bullet('Tangguh dan tahan banting saat menghadapi rintangan.'),
              const SizedBox(height: 12),
              _subHeading('Tantangan / Area Pengembangan:'),
              _bullet('Tergesa-gesa bergerak tanpa memberikan kabar ke orang terkait.'),
              _bullet('Rentan membuat keputusan spontan di puncak emosi.'),
              _bullet('Sulit melepas hal yang tidak lagi produktif karena rasa tanggung jawab.'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Section 2: Ringkasan Cara Kerja Energi
        _ReportCard(
          number: '2',
          title: 'Ringkasan Cara Kerja Energi',
          icon: Icons.bolt,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bullet('Tipe Energi: ${hdChart.typeLabel}'),
              _bullet('Strategi Alami: ${hdChart.strategy}'),
              _bullet('Otoritas Pengambilan Keputusan: ${hdChart.authority}'),
              _bullet('Profil Kepribadian: ${hdChart.profileLabel}'),
              _bullet('Definisi: ${hdChart.definitionLabel}'),
              _bullet('Tema Diri Sejati: ${hdChart.signatureTheme}'),
              _bullet('Tema Bukan Diri (Not-Self): ${hdChart.notSelfTheme}'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Section 3: Cara Kerja Keputusan
        _ReportCard(
          number: '3',
          title: 'Cara Kerja Keputusan',
          icon: Icons.alt_route,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Otoritas: ${hdChart.authority}',
                style: const TextStyle(
                  color: AstroPalette.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Keputusan terbaikmu lahir setelah gelombang emosi kembali jernih dan tenang. '
                'Jangan terburu-buru memutuskan saat merasa sangat gembira, antusias, atau sangat sedih. '
                'Beri waktu pada diri sendiri untuk merasakan keheningan sebelum bertindak.',
                style: TextStyle(color: AstroPalette.parchment, height: 1.4),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Section 4: Panduan 9 Center
        _ReportCard(
          number: '4',
          title: 'Panduan 9 Center Energi',
          icon: Icons.grid_view,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _centerItem('Pusat Tenggorokan (Throat): Defined (Emas)', 'Komunikasi, wacana, dan ekspresi nyata.'),
              _centerItem('Pusat G / Identitas: Defined (Emas)', 'Arah hidup, cinta, dan jati diri yang konsisten.'),
              _centerItem('Pusat Jantung / Ego: Defined (Merah/Emas)', 'Tekad, komitmen, dan daya juang.'),
              _centerItem('Pusat Sakral: Defined (Merah)', 'Energi vital, stamina kerja, dan ketahanan.'),
              _centerItem('Pusat Solar Plexus: Defined (Emas)', 'Gelombang emosi, kedalaman rasa, dan kepekaan.'),
              _centerItem('Pusat Akar (Root): Defined (Merah)', 'Tekanan aksi dan dorongan stamina.'),
              _centerItem('Pusat Kepala (Head): Terbuka', 'Peka pada inspirasi dari luar, bijak memilah ide.'),
              _centerItem('Pusat Ajna: Terbuka', 'Fleksibel dalam pola pikir, tidak kaku pada satu konsep.'),
              _centerItem('Pusat Limpa (Spleen): Terbuka', 'Intuisi keselamatan, bijak melepas hal yang tidak sehat.'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Section 5: Karakteristik Pusat Energi
        _ReportCard(
          number: '5',
          title: 'Karakteristik Pusat Energi',
          icon: Icons.psychology,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _subHeading('Center Terdefinisi (Defined) - Kekuatan Konsisten:'),
              _bullet('Mengomunikasikan gagasan dengan percaya diri dan pengaruh kuat.'),
              _bullet('Memiliki komitmen kerja dan daya tahan di atas rata-rata.'),
              _bullet('Mampu menenangkan dan menginspirasi sekitar lewat stabilitas emosi.'),
              const SizedBox(height: 10),
              _subHeading('Center Terbuka (Open) - Kebijaksanaan & Sensitivitas:'),
              _bullet('Sangat peka terhadap pikiran dan stres dari lingkungan sekitar.'),
              _bullet('Belajar untuk tidak menyerap rasa cemas orang lain menjadi beban pribadi.'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Section 6: Saluran Energi Aktif
        _ReportCard(
          number: '6',
          title: 'Saluran Energi Aktif (Channels)',
          icon: Icons.alt_route,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saluran Aktif: ${hdChart.activeChannels.map((c) => c.name).join(", ")}',
                style: const TextStyle(
                  color: AstroPalette.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              _bullet('Menghubungkan pusat energi menjadi bakat dan karya nyata.'),
              _bullet('Pendorong inovasi, pencetus metode baru, dan perubah pola lama.'),
              _bullet('Menyampaikan nilai dan cerita inspiratif secara alami.'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Section 7: Gerbang Energi
        _ReportCard(
          number: '7',
          title: 'Gerbang Energi (Gates)',
          icon: Icons.vpn_key,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Memiliki gerbang aktif dari 64 Rave Mandala. Gerbang-gerbang ini membentuk '
                'fokus minat, bakat bawaan, serta tema-tema pembelajaran hidupmu.',
                style: TextStyle(color: AstroPalette.parchment, height: 1.4),
              ),
              const SizedBox(height: 8),
              _bullet('Sisi Tubuh (Design/Merah): Bakat instingtif dan respon fisik bawah sadar.'),
              _bullet('Sisi Jiwa (Personality/Hitam): Fokus minat, aspirasi sadar, dan cara berpikir.'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Section 8: Profil Kepribadian
        _ReportCard(
          number: '8',
          title: 'Profil Kepribadian (${hdChart.profileLabel})',
          icon: Icons.account_circle,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Peran & Gaya Belajar: Profil ${hdChart.profileLabel}',
                style: const TextStyle(
                  color: AstroPalette.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              _bullet('Praktisi & Pemecah Masalah: Belajar lewat pengalaman nyata (trial & error), mencoba, memperbaiki, dan memberikan solusi praktis.'),
              _bullet('Perlakukan kesalahan sebagai data berharga untuk membantu orang lain.'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Section 9: Misi Hidup
        _ReportCard(
          number: '9',
          title: 'Misi Hidup (Incarnation Cross)',
          icon: Icons.explore,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hdChart.incarnationCross,
                style: const TextStyle(
                  color: AstroPalette.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Misimu bersifat personal: Jalani takdirmu sendiri, jaga dan perbarui aturan/nilai yang baik, '
                'lalu sampaikan lewat cerita dan tindakan yang bermanfaat bagi sekitar.',
                style: TextStyle(color: AstroPalette.parchment, height: 1.4),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Section 10: Detail Planet
        _ReportCard(
          number: '10',
          title: 'Detail Planet (Tubuh vs Jiwa)',
          icon: Icons.public,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tubuh (Design / Bawah Sadar / Merah) vs Jiwa (Personality / Sadar / Hitam):',
                style: TextStyle(color: AstroPalette.muted, fontSize: 13),
              ),
              const SizedBox(height: 10),
              ...List.generate(hdChart.personalityPlacements.length, (i) {
                final p = hdChart.personalityPlacements[i];
                final d = hdChart.designPlacements[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${d.planetName}:',
                        style: const TextStyle(color: AstroPalette.parchment, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Tubuh ${d.label}  |  Jiwa ${p.label}',
                        style: const TextStyle(color: AstroPalette.gold, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Section 11: Variabel Gaya Hidup
        _ReportCard(
          number: '11',
          title: 'Variabel Gaya Hidup',
          icon: Icons.tungsten,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bullet('Pencernaan: Makan di suasana tenang dan santai tanpa gangguan.'),
              _bullet('Lingkungan: Nyaman di tempat terbuka dan alami.'),
              _bullet('Tidur: Habiskan energi untuk hal positif di siang hari, lalu tidur saat benar-benar lelah.'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Section 12: Dalam Pekerjaan & Kepemimpinan
        _ReportCard(
          number: '12',
          title: 'Pekerjaan & Kepemimpinan',
          icon: Icons.work_outline,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bullet('Kekuatan Alami: Komunikasi, cerita menggugah, inovasi cara baru, serta ketahanan menghadapi tantangan.'),
              _bullet('Hal yang Perlu Dijaga: Jangan ambil keputusan proyek besar saat emosi puncak. Beri tahu tim sebelum bergerak cepat.'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Section 13: Dalam Relasi
        _ReportCard(
          number: '13',
          title: 'Dalam Relasi',
          icon: Icons.favorite_border,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bullet('Cara Mencintai: Lewat keakraban emosional, kejujuran, dan keaslian menjadi diri sendiri.'),
              _bullet('Kebutuhan Pasangan: Pasangan yang sabar dengan gelombang emosimu dan menghargai keunikanmu.'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Section 14: 10 Praktik Harian
        _ReportCard(
          number: '14',
          title: '10 Praktik Harian Konkret',
          icon: Icons.task_alt,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _CheckItem('1. Tunggu sinyal dari luar, cek respon perut, lalu tunda hingga emosi jernih.'),
              _CheckItem('2. Jangan memutuskan hal penting di puncak semangat atau titik terendah.'),
              _CheckItem('3. Kabari orang terkait sebelum bergerak cepat.'),
              _CheckItem('4. Habiskan energi untuk hal positif, lalu tidur saat benar-benar lelah.'),
              _CheckItem('5. Terima ritme on-off. Masa diam adalah persiapan, bukan kegagalan.'),
              _CheckItem('6. Saat sulit melepas: "Aku bertahan karena baik, atau karena takut?"'),
              _CheckItem('7. Perlakukan kesalahan sebagai pengalaman berharga.'),
              _CheckItem('8. Gunakan kemampuan cerita untuk menyampaikan ide dan nilai.'),
              _CheckItem('9. Nikmati makan di suasana tenang dan waktu di alam terbuka.'),
              _CheckItem('10. Saat frustrasi muncul, tanyakan: "Apa yang sedang aku paksakan?"'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) => Text(
    title,
    style: const TextStyle(
      color: AstroPalette.parchment,
      fontFamily: 'serif',
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  );

  Widget _subHeading(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      title,
      style: const TextStyle(
        color: AstroPalette.gold,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
  );

  static Widget _bullet(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(color: AstroPalette.gold, fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AstroPalette.parchment, height: 1.35),
          ),
        ),
      ],
    ),
  );

  static Widget _centerItem(String title, String desc) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: AstroPalette.gold, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          desc,
          style: const TextStyle(color: AstroPalette.parchment, fontSize: 13),
        ),
      ],
    ),
  );
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.number,
    required this.title,
    required this.icon,
    required this.content,
  });

  final String number;
  final String title;
  final IconData icon;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AstroPalette.plum,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AstroPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AstroPalette.gold,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: AstroPalette.ink,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(icon, color: AstroPalette.gold, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AstroPalette.parchment,
                    fontFamily: 'serif',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AstroPalette.line, height: 1),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  const _CheckItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(color: AstroPalette.parchment, fontSize: 13, height: 1.35),
      ),
    );
  }
}
