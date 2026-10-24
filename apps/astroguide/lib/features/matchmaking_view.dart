import 'package:flutter/material.dart';

import '../core/birth_city.dart';
import '../core/birth_profile.dart';
import '../core/city_catalog.dart';
import '../core/matchmaking_calculator.dart';
import '../theme/app_theme.dart';

class MatchmakingView extends StatefulWidget {
  const MatchmakingView({
    required this.userProfile,
    required this.cityCatalogFuture,
    this.onMatchmakingCalculated,
    super.key,
  });

  final BirthProfile userProfile;
  final Future<CityCatalog> cityCatalogFuture;
  final ValueChanged<MatchmakingResult>? onMatchmakingCalculated;

  @override
  State<MatchmakingView> createState() => _MatchmakingViewState();
}

class _MatchmakingViewState extends State<MatchmakingView> {
  bool _isExpanded = false;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _partnerNameController;
  late final TextEditingController _partnerCityController;

  DateTime? _partnerBirthDate;
  BirthCity? _partnerSelectedCity;
  MatchmakingResult? _result;
  CityCatalog? _loadedCatalog;
  String? _error;

  @override
  void initState() {
    super.initState();
    _partnerNameController = TextEditingController();
    _partnerCityController = TextEditingController();
    widget.cityCatalogFuture.then((catalog) {
      if (mounted) {
        setState(() {
          _loadedCatalog = catalog;
        });
      }
    });
  }

  @override
  void dispose() {
    _partnerNameController.dispose();
    _partnerCityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _partnerCityController.text.trim();
    final suggestions = _loadedCatalog != null && _partnerSelectedCity == null && query.length >= 2
        ? _loadedCatalog!.search(query)
        : const <BirthCity>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main Trigger Button
        OutlinedButton.icon(
          onPressed: () => setState(() => _isExpanded = !_isExpanded),
          icon: Icon(
            _isExpanded ? Icons.expand_less : Icons.favorite,
            color: AstroPalette.gold,
            size: 20,
          ),
          label: Text(
            _isExpanded
                ? 'Sembunyikan Perhitungan Jodoh'
                : '💖 Hitung Kecocokan Jodoh & Pasangan',
            style: const TextStyle(
              color: AstroPalette.parchment,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            foregroundColor: AstroPalette.parchment,
            side: const BorderSide(color: AstroPalette.gold, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        // Expanded Form & Results
        if (_isExpanded) ...[
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AstroPalette.plum,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AstroPalette.line),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.favorite, color: AstroPalette.gold, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Data Pasangan Kamu',
                        style: TextStyle(
                          color: AstroPalette.parchment,
                          fontFamily: 'serif',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Partner Full Name
                  TextFormField(
                    controller: _partnerNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap Pasangan',
                      hintText: 'Masukkan nama pasanganmu',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Tulis nama pasanganmu dulu.' : null,
                  ),

                  const SizedBox(height: 14),

                  // Partner Birth Date Button
                  const Text(
                    'Tanggal Lahir Pasangan',
                    style: TextStyle(color: AstroPalette.parchment, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    onPressed: _chooseDate,
                    icon: const Icon(Icons.calendar_month_outlined, size: 18),
                    label: Text(
                      _partnerBirthDate == null
                          ? 'Pilih tanggal lahir pasangan'
                          : _formatDate(_partnerBirthDate!),
                    ),
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: AstroPalette.parchment,
                      side: const BorderSide(color: AstroPalette.line),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Partner Birth City
                  TextFormField(
                    controller: _partnerCityController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Kota Lahir Pasangan',
                      hintText: 'Cari kota di Indonesia',
                      suffixIcon: _partnerSelectedCity == null
                          ? const Icon(Icons.search)
                          : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _partnerSelectedCity = null;
                                  _partnerCityController.clear();
                                });
                              },
                            ),
                    ),
                    onChanged: (_) {
                      setState(() {
                        _partnerSelectedCity = null;
                      });
                    },
                  ),
                  if (suggestions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AstroPalette.ink,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AstroPalette.line),
                        ),
                        child: Column(
                          children: suggestions
                              .map(
                                (city) => ListTile(
                                  dense: true,
                                  title: Text(city.name),
                                  subtitle: Text(
                                    city.regionName.isNotEmpty
                                        ? '${city.regionName}, ${city.countryName} • ${city.timeZoneLabel}'
                                        : '${city.countryName} • ${city.timeZoneLabel}',
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _partnerSelectedCity = city;
                                      _partnerCityController.text = city.regionName.isNotEmpty
                                          ? '${city.name}, ${city.regionName}, ${city.countryName}'
                                          : '${city.name}, ${city.countryName}';
                                    });
                                    FocusScope.of(context).unfocus();
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),

                  const SizedBox(height: 18),

                  if (_error != null) ...[
                    Text(_error!, style: const TextStyle(color: AstroPalette.danger, fontSize: 13)),
                    const SizedBox(height: 10),
                  ],

                  // Calculate Button
                  FilledButton.icon(
                    onPressed: _calculateMatchmaking,
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('Hitung Kecocokan Sekarang'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: AstroPalette.gold,
                      foregroundColor: AstroPalette.ink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Display Results
          if (_result != null) ...[
            const SizedBox(height: 18),

            // 1. Primbon Wetnan Result Card
            _ResultCard(
              title: '🌺 Kecocokan Weton Jawa (Wetnan)',
              badge: _result!.wetnan.kategori,
              color: AstroPalette.gold,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kategori Wetnan: ${_result!.wetnan.kategori}',
                    style: const TextStyle(
                      color: AstroPalette.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Total Neptu Jodoh: ${_result!.wetnan.totalNeptu} '
                    '(${widget.userProfile.nickname}: ${_result!.wetnan.neptuA} + '
                    '${_result!.profileB.nickname}: ${_result!.wetnan.neptuB})',
                    style: const TextStyle(color: AstroPalette.parchment, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  _detailBox('Makna Wetnan:', _result!.wetnan.penjelasan),
                  _detailBox('Saran Keharmonisan:', _result!.wetnan.saran),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 2. Zodiac Compatibility Card
            _ResultCard(
              title: '✨ Sinergi Zodiak & Elemen',
              badge: '${_result!.zodiac.persentase}% Cocok',
              color: Colors.amber,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_result!.zodiac.signA} (${_result!.zodiac.elemenA}) ❤️ ${_result!.zodiac.signB} (${_result!.zodiac.elemenB})',
                    style: const TextStyle(
                      color: AstroPalette.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _result!.zodiac.penjelasan,
                    style: const TextStyle(color: AstroPalette.parchment, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 3. Numerology & Human Design Synergy Card
            _ResultCard(
              title: '🔮 Sinergi Nama & Human Design',
              badge: '${_result!.numerologyScore}% Harmonis',
              color: Colors.lightBlueAccent,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailBox('Harmoni Numerologi:', _result!.numerologyInsight),
                  _detailBox('Sinergi Human Design:', _result!.humanDesignSynergy),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  Future<void> _chooseDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _partnerBirthDate ?? DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Pilih tanggal lahir pasangan',
    );
    if (date != null && mounted) {
      setState(() {
        _partnerBirthDate = DateTime(date.year, date.month, date.day);
        _error = null;
      });
    }
  }

  void _calculateMatchmaking() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_partnerBirthDate == null || _partnerSelectedCity == null) {
      setState(() {
        _error = _partnerBirthDate == null
            ? 'Pilih tanggal lahir pasanganmu.'
            : 'Pilih kota lahir pasangan dari daftar.';
      });
      return;
    }

    final partnerProfile = BirthProfile(
      fullName: _partnerNameController.text.trim(),
      birthDate: _partnerBirthDate!,
      birthTimeMinutes: 12 * 60,
      cityName: _partnerSelectedCity!.name,
      latitude: _partnerSelectedCity!.latitude,
      longitude: _partnerSelectedCity!.longitude,
      timeZone: _partnerSelectedCity!.timeZone,
      ayanamsha: widget.userProfile.ayanamsha,
    );

    final calc = MatchmakingCalculator();
    final res = calc.calculate(
      profileA: widget.userProfile,
      profileB: partnerProfile,
    );

    setState(() {
      _result = res;
      _error = null;
    });
    widget.onMatchmakingCalculated?.call(res);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _detailBox(String title, String body) => Padding(
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

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.title,
    required this.badge,
    required this.color,
    required this.content,
  });

  final String title;
  final String badge;
  final Color color;
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AstroPalette.parchment,
                    fontFamily: 'serif',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color),
                ),
                child: Text(
                  badge,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}
