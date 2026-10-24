// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({
    required this.currentThemeMode,
    required this.currentLocale,
    required this.onThemeModeChanged,
    required this.onLocaleChanged,
    super.key,
  });

  final ThemeMode currentThemeMode;
  final Locale? currentLocale;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<Locale?> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AstroPalette.plum,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AstroPalette.gold, width: 1.5),
      ),
      title: Row(
        children: const [
          Icon(Icons.settings, color: AstroPalette.gold, size: 24),
          SizedBox(width: 10),
          Text(
            'Pengaturan Aplikasi',
            style: TextStyle(
              color: AstroPalette.parchment,
              fontFamily: 'serif',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '1. Tema Tampilan',
              style: TextStyle(
                color: AstroPalette.gold,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            _themeOption(context, ThemeMode.dark, '🌙 Tema Gelap (Dark)'),
            _themeOption(context, ThemeMode.light, '☀️ Tema Terang (Light)'),
            _themeOption(context, ThemeMode.system, '📱 Ikuti Sistem (System)'),

            const SizedBox(height: 20),
            const Divider(color: AstroPalette.line),
            const SizedBox(height: 14),

            const Text(
              '2. Bahasa Aplikasi (Language)',
              style: TextStyle(
                color: AstroPalette.gold,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            _langOption(context, null, '🌐 Bahasa Sistem (System Default)'),
            _langOption(context, const Locale('id'), '🇮🇩 Bahasa Indonesia'),
            _langOption(context, const Locale('en'), '🇬🇧 English (Inggris)'),
            _langOption(context, const Locale('ms'), '🇲🇾 Bahasa Melayu'),
            _langOption(context, const Locale('ar'), '🇸🇦 العربية (Arab)'),
            _langOption(context, const Locale('zh'), '🇨🇳 中文 (China)'),
            _langOption(context, const Locale('ja'), '🇯🇵 日本語 (Jepang)'),
            _langOption(context, const Locale('ko'), '🇰🇷 한국어 (Korea)'),

            const SizedBox(height: 20),
            const Divider(color: AstroPalette.line),
            const SizedBox(height: 14),

            const Text(
              '3. Informasi Aplikasi',
              style: TextStyle(
                color: AstroPalette.gold,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info_outline, color: AstroPalette.gold),
              title: const Text(
                'Tentang AstroNusa (Vraboo)',
                style: TextStyle(color: AstroPalette.parchment, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Versi 1.0.0 • Kebijakan Privasi & Lisensi',
                style: TextStyle(color: AstroPalette.muted, fontSize: 12),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const AboutAstroNusaDialog(),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Tutup',
            style: TextStyle(color: AstroPalette.gold, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _themeOption(BuildContext context, ThemeMode mode, String label) {
    final isSelected = currentThemeMode == mode;
    return RadioListTile<ThemeMode>(
      value: mode,
      groupValue: currentThemeMode,
      activeColor: AstroPalette.gold,
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AstroPalette.gold : AstroPalette.parchment,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      onChanged: (val) {
        if (val != null) {
          onThemeModeChanged(val);
        }
      },
    );
  }

  Widget _langOption(BuildContext context, Locale? locale, String label) {
    final isSelected = currentLocale == locale;
    return RadioListTile<Locale?>(
      value: locale,
      groupValue: currentLocale,
      activeColor: AstroPalette.gold,
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AstroPalette.gold : AstroPalette.parchment,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      onChanged: (val) {
        onLocaleChanged(val);
      },
    );
  }
}

class AboutAstroNusaDialog extends StatelessWidget {
  const AboutAstroNusaDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AstroPalette.plum,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AstroPalette.gold, width: 1.5),
      ),
      title: Row(
        children: const [
          Icon(Icons.auto_awesome, color: AstroPalette.gold, size: 26),
          SizedBox(width: 10),
          Text(
            'Tentang AstroNusa',
            style: TextStyle(
              color: AstroPalette.parchment,
              fontFamily: 'serif',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(
              child: Text(
                'AstroNusa v1.0.0 (Build 1)',
                style: TextStyle(
                  color: AstroPalette.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Dikembangkan oleh Vraboo',
                style: TextStyle(color: AstroPalette.muted, fontSize: 13),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'AstroNusa adalah aplikasi spiritual, astrologi, Human Design, dan Primbon Nusantara profesional yang dirancang untuk membantu Anda merefleksikan potensi diri, energi batin, dan keselarasan hidup.',
              style: TextStyle(color: AstroPalette.parchment, fontSize: 13.5, height: 1.45),
            ),
            const SizedBox(height: 14),
            const Text(
              '✨ Fitur Utama:',
              style: TextStyle(color: AstroPalette.gold, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            const Text(
              '• Peta Langit & Zodiak Presisi\n'
              '• Human Design Bodygraph 3 Kolom\n'
              '• Primbon Nusantara & Shio 5 Kategori\n'
              '• Kalkulator Kecocokan Jodoh & Pasangan\n'
              '• AI Coach & Penelusuran Reflektif\n'
              '• Ekspor Master Laporan PDF Lengkap',
              style: TextStyle(color: AstroPalette.parchment, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Divider(color: AstroPalette.line),
            const SizedBox(height: 12),

            // Privacy Policy & License Accordion
            ExpansionTile(
              title: const Text(
                '🔒 Kebijakan Privasi (Data Safety)',
                style: TextStyle(color: AstroPalette.gold, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              children: const [
                Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'AstroNusa menghargai privasi dan keamanan data Anda:\n\n'
                    '1. Penyimpanan Lokal: Data profil kelahiran (nama, tanggal, waktu, dan kota lahir) disimpan secara terenkripsi dan aman secara lokal di perangkat Anda menggunakan Secure Storage.\n\n'
                    '2. Pemrosesan AI Coach: Saat Anda menggunakan fitur "Buat Bacaan AI Coach", parameter astrologi (zodiak dan numerologi) dikirimkan secara aman melalui API backend terenkripsi ke layanan Google Gemini AI semata-mata untuk menghasilkan analisis teks reflektif real-time tanpa menyimpan identitas mentah Anda.',
                    style: TextStyle(color: AstroPalette.muted, fontSize: 12.5, height: 1.45),
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text(
                '📜 Lisensi & Atribusi Resmi',
                style: TextStyle(color: AstroPalette.gold, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              children: const [
                Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'AstroNusa dikembangkan oleh Vraboo.\n\n'
                    '• Swiss Ephemeris (sweph): Perhitungan posisi benda langit dan astrologi presisi tinggi dilisensikan di bawah ketentuan AGPL-3.0 dari Astrodienst (www.astro.com).\n\n'
                    '• GeoNames Database: Data geolokasi, koordinat, dan daftar kabupaten/kota menggunakan data dari GeoNames di bawah lisensi Creative Commons Attribution 4.0 (CC BY 4.0).\n\n'
                    '• Flutter & Pustaka Terbuka: Menggunakan framework Flutter dan pustaka open-source terkemuka lainnya.',
                    style: TextStyle(color: AstroPalette.muted, fontSize: 12.5, height: 1.45),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: AstroPalette.line),
            const SizedBox(height: 12),
            Center(
              child: Column(
                children: const [
                  Text(
                    'Developed with ❤️ by Vraboo',
                    style: TextStyle(
                      color: AstroPalette.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '© 2025 Vraboo. All rights reserved.',
                    style: TextStyle(color: AstroPalette.muted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Kembali',
            style: TextStyle(color: AstroPalette.gold, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
