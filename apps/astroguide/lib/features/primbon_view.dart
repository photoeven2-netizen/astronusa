import 'package:flutter/material.dart';

import '../core/birth_profile.dart';
import '../core/primbon_calculator.dart';
import '../theme/app_theme.dart';

class PrimbonView extends StatelessWidget {
  const PrimbonView({
    required this.profile,
    super.key,
  });

  final BirthProfile profile;

  @override
  Widget build(BuildContext context) {
    final primbon = PrimbonCalculator().calculate(profile);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.auto_stories, color: AstroPalette.gold, size: 22),
            SizedBox(width: 8),
            Text(
              'Primbon Nusantara & Shio',
              style: TextStyle(
                color: AstroPalette.parchment,
                fontFamily: 'serif',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Pilih salah satu Primbon di bawah untuk membaca detail Weton, Jodoh, '
          'Rezeki, Hari Baik, dan Shio ${profile.fullName}.',
          style: const TextStyle(color: AstroPalette.muted, fontSize: 13, height: 1.35),
        ),
        const SizedBox(height: 16),

        // 1. Primbon Jawa Button & Card
        _ExpandablePrimbonCard(
          title: '🌺 Primbon Jawa (Betaljemur Adammakna)',
          subtitle: primbon.jawa.wetonLabel,
          icon: Icons.brightness_6,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Weton & Watak
              _subSection('1. Weton dan Watak (Karakter)', Icons.person),
              const SizedBox(height: 8),
              Row(
                children: [
                  _Badge('Weton', '${primbon.jawa.hari} ${primbon.jawa.pasaran}'),
                  const SizedBox(width: 8),
                  _Badge('Neptu', '${primbon.jawa.neptuTotal} (${primbon.jawa.neptuHari}+${primbon.jawa.neptuPasaran})'),
                  const SizedBox(width: 8),
                  _Badge('Wuku', primbon.jawa.wuku),
                ],
              ),
              const SizedBox(height: 10),
              _itemBox('Watak Utama:', primbon.jawa.watak),
              _itemBox('Kelebihan:', primbon.jawa.kelebihan),
              _itemBox('Kelemahan & Solusi:', primbon.jawa.kekurangan),

              const SizedBox(height: 16),
              const Divider(color: AstroPalette.line),
              const SizedBox(height: 12),

              // 2. Jodoh & Pernikahan
              _subSection('2. Jodoh dan Pernikahan (Wetnan)', Icons.favorite),
              const SizedBox(height: 8),
              _itemBox('Pasangan Cocok:', primbon.jawa.jodohCocok),
              _itemBox('Hari Baik Pernikahan:', primbon.jawa.hariBaikNikah),

              const SizedBox(height: 16),
              const Divider(color: AstroPalette.line),
              const SizedBox(height: 12),

              // 3. Rezeki & Keberuntungan
              _subSection('3. Rezeki dan Arah Kejayaan', Icons.monetization_on),
              const SizedBox(height: 8),
              _itemBox('Prediksi Rezeki:', primbon.jawa.prediksiRezeki),
              _itemBox('Arah Kejayaan (Mata Angin):', primbon.jawa.arahKejayaan),

              const SizedBox(height: 16),
              const Divider(color: AstroPalette.line),
              const SizedBox(height: 12),

              // 4. Penentuan Hari Baik
              _subSection('4. Penentuan Hari Baik & Naas', Icons.event_available),
              const SizedBox(height: 8),
              _itemBox('Memulai Usaha / Bisnis / Tani:', primbon.jawa.hariBaikUsaha),
              _itemBox('Pindah / Boyongan Rumah:', primbon.jawa.hariBaikPindah),
              _itemBox('Hari Naas (Dihindari):', primbon.jawa.hariSial),

              const SizedBox(height: 16),
              const Divider(color: AstroPalette.line),
              const SizedBox(height: 12),

              // 5. Tafsir Firasat & Kedutan
              _subSection('5. Tafsir Kedutan & Mimpi Sakral', Icons.remove_red_eye),
              const SizedBox(height: 8),
              _itemBox('Arti Kedutan Anggota Tubuh:', primbon.jawa.tafsirKedutan),
              _itemBox('Tafsir Mimpi (Puspo Tajem):', primbon.jawa.tafsirMimpi),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 2. Primbon Bali Button & Card
        _ExpandablePrimbonCard(
          title: '🌴 Primbon Bali (Wariga / Pawukon Bali)',
          subtitle: primbon.bali.dinaLabel,
          icon: Icons.spa,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Badge('Dina', '${primbon.bali.saptawara} ${primbon.bali.pancawara}'),
                  const SizedBox(width: 6),
                  _Badge('Wuku', primbon.bali.wuku),
                  const SizedBox(width: 6),
                  _Badge('Urip', '${primbon.bali.uripTotal}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _Badge('Triwara', primbon.bali.triwara),
                  const SizedBox(width: 6),
                  _Badge('Sadwara', primbon.bali.sadwara),
                  const SizedBox(width: 6),
                  _Badge('Dasawara', primbon.bali.dasawara),
                ],
              ),
              const SizedBox(height: 12),
              _itemBox('Perantian Rahina (06.00):', primbon.bali.catatanSunrise),
              _itemBox('Sasih (Bulan Saka):', primbon.bali.sasih),
              _itemBox('Pembawaan Lontar Wariga:', primbon.bali.pembawaan),
              _itemBox('Padewasan Energi:', primbon.bali.makna),
              _itemBox('Dewasa Ayu (Hari Baik):', primbon.bali.dewasaAyu),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 3. Primbon China Button & Card
        _ExpandablePrimbonCard(
          title: '🐉 Primbon China (Shio & Elemen)',
          subtitle: '${primbon.china.simbol} ${primbon.china.label}',
          icon: Icons.workspace_premium,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Badge('Shio', '${primbon.china.simbol} ${primbon.china.shio}'),
                  const SizedBox(width: 8),
                  _Badge('Elemen', primbon.china.elemen),
                ],
              ),
              const SizedBox(height: 14),
              _itemBox('Analisis & Karakter Shio:', primbon.china.karakter),
              const SizedBox(height: 6),
              _itemBox('Kecocokan Hubungan (Jodoh & Bisnis):', 'Sangat harmonis dan cocok berdampingan dengan Shio ${primbon.china.kecocokanShio}.'),
              const SizedBox(height: 6),
              _itemBox('Arah Keberuntungan & Hoki:', 'Arah mata angin pembawa keberuntungan terbaik: ${primbon.china.arahKeberuntungan}.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _subSection(String title, IconData icon) => Row(
    children: [
      Icon(icon, color: AstroPalette.gold, size: 18),
      const SizedBox(width: 8),
      Text(
        title,
        style: const TextStyle(
          color: AstroPalette.gold,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    ],
  );

  Widget _itemBox(String title, String body) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: AstroPalette.parchment, fontSize: 13, height: 1.4),
        children: [
          TextSpan(text: '$title ', style: const TextStyle(fontWeight: FontWeight.bold, color: AstroPalette.gold)),
          TextSpan(text: body),
        ],
      ),
    ),
  );
}

class _ExpandablePrimbonCard extends StatefulWidget {
  const _ExpandablePrimbonCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.content,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget content;

  @override
  State<_ExpandablePrimbonCard> createState() => _ExpandablePrimbonCardState();
}

class _ExpandablePrimbonCardState extends State<_ExpandablePrimbonCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AstroPalette.plum,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isExpanded ? AstroPalette.gold : AstroPalette.line),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(widget.icon, color: AstroPalette.gold, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: AstroPalette.parchment,
                              fontFamily: 'serif',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            style: const TextStyle(color: AstroPalette.gold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AstroPalette.gold,
                      size: 24,
                    ),
                  ],
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: 14),
                  const Divider(color: AstroPalette.line, height: 1),
                  const SizedBox(height: 14),
                  widget.content,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: AstroPalette.ink,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AstroPalette.line),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(color: AstroPalette.muted, fontSize: 10),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AstroPalette.gold,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
