import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/astro_logo.dart';
import '../core/birth_city.dart';
import '../core/birth_profile.dart';
import '../core/city_catalog.dart';
import '../core/numerology.dart';
import '../theme/app_theme.dart';
import 'settings_dialog.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    required this.cityCatalog,
    required this.onSave,
    required this.currentThemeMode,
    required this.currentLocale,
    required this.onThemeModeChanged,
    required this.onLocaleChanged,
    this.initialProfile,
    super.key,
  });

  final CityCatalog cityCatalog;
  final Future<void> Function(BirthProfile) onSave;
  final BirthProfile? initialProfile;
  final ThemeMode currentThemeMode;
  final Locale? currentLocale;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<Locale?> onLocaleChanged;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  BirthCity? _selectedCity;
  DateTime? _birthDate;
  int? _birthTimeMinutes;
  bool _birthTimeUnknown = true;
  Ayanamsha _ayanamsha = Ayanamsha.tropical;
  bool _isSaving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    final profile = widget.initialProfile;
    _nameController = TextEditingController(text: profile?.fullName ?? '');
    _cityController = TextEditingController(text: profile?.cityName ?? '');
    _birthDate = profile?.birthDate;
    _birthTimeMinutes = profile?.birthTimeMinutes;
    _birthTimeUnknown = profile?.birthTimeMinutes == null;
    _ayanamsha = profile?.ayanamsha ?? Ayanamsha.tropical;
    if (profile != null) {
      _selectedCity = BirthCity(
        id: 0,
        name: profile.cityName,
        regionCode: '',
        latitude: profile.latitude,
        longitude: profile.longitude,
        timeZone: profile.timeZone,
        population: 0,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final query = _cityController.text.trim();
    final suggestions = _selectedCity == null && query.length >= 2
        ? widget.cityCatalog.search(query)
        : const <BirthCity>[];

    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF1A122E) : AstroPalette.parchment;
    final mutedColor = isLight ? const Color(0xFF5E6075) : AstroPalette.muted;

    return Scaffold(
      backgroundColor: isLight ? const Color(0xFFFAF7F2) : AstroPalette.ink,
      body: Container(
        decoration: isLight
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFAF7F2),
                    const Color(0xFFEFE8DA),
                  ],
                ),
              )
            : const BoxDecoration(
                gradient: AstroPalette.cosmicGradient,
              ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
              children: [
                _brandMark(context),
                const SizedBox(height: 28),
                Text(
                  t.translate('tagline'),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: textColor,
                    fontFamily: 'serif',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  t.translate('taglineSub'),
                  style: TextStyle(color: mutedColor, fontSize: 14, height: 1.45),
                ),
                const SizedBox(height: 24),

                // Clay 3D Form Card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: AstroPalette.clay3D(
                    baseColor: isLight ? Colors.white : const Color(0xFF1E1436),
                    isDark: !isLight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Full Name Field
                      _fieldLabel(t.translate('fullName'), Icons.person_outline, textColor),
                      TextFormField(
                        key: const ValueKey('full-name'),
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        style: TextStyle(color: textColor, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: t.translate('nameHint'),
                          prefixIcon: const Icon(Icons.badge_outlined, color: AstroPalette.gold, size: 20),
                          fillColor: isLight ? Colors.grey.shade100 : const Color(0xFF140C24),
                        ),
                        validator: (value) {
                          final name = value?.trim() ?? '';
                          if (name.isEmpty) {
                            return 'Tulis nama lengkapmu dulu.';
                          }
                          try {
                            PythagoreanNumerology.calculate(name);
                          } on ArgumentError {
                            return 'Nama perlu memuat setidaknya satu huruf.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // 2. Birth Date Field
                      _fieldLabel(t.translate('birthDate'), Icons.calendar_today_outlined, textColor),
                      OutlinedButton.icon(
                        key: const ValueKey('birth-date'),
                        onPressed: _isSaving ? null : _chooseDate,
                        style: _choiceButtonStyle(isLight),
                        icon: const Icon(Icons.calendar_month_outlined, color: AstroPalette.gold, size: 20),
                        label: Text(
                          _birthDate == null
                              ? t.translate('chooseDate')
                              : _formatDate(_birthDate!),
                          style: TextStyle(
                            color: _birthDate == null ? mutedColor : textColor,
                            fontSize: 15,
                            fontWeight: _birthDate == null ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_birthDate == null)
                        Padding(
                          padding: const EdgeInsets.only(left: 6, top: 6),
                          child: Text(
                            '• Tanggal lahir diperlukan untuk menghitung Weton & Human Design.',
                            style: TextStyle(color: mutedColor, fontSize: 12),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // 3. Birth Time Field & Toggle
                      _fieldLabel(t.translate('birthTime'), Icons.access_time_outlined, textColor),
                      Container(
                        decoration: BoxDecoration(
                          color: isLight ? Colors.grey.shade100 : const Color(0xFF140C24),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isLight ? Colors.grey.shade300 : AstroPalette.line),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: SwitchListTile(
                            key: const ValueKey('unknown-birth-time'),
                            value: _birthTimeUnknown,
                            activeThumbColor: AstroPalette.gold,
                            activeTrackColor: AstroPalette.gold.withValues(alpha: 0.3),
                            onChanged: _isSaving
                                ? null
                                : (value) {
                                    setState(() {
                                      _birthTimeUnknown = value;
                                    });
                                  },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                            title: Text(
                              t.translate('unknownTime'),
                              style: TextStyle(color: textColor, fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      if (!_birthTimeUnknown) ...[
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          key: const ValueKey('birth-time'),
                          onPressed: _isSaving ? null : _chooseTime,
                          style: _choiceButtonStyle(isLight),
                          icon: const Icon(Icons.schedule_outlined, color: AstroPalette.gold, size: 20),
                          label: Text(
                            _birthTimeMinutes == null
                                ? t.translate('chooseTime')
                                : _formatTime(_birthTimeMinutes!),
                            style: TextStyle(
                              color: _birthTimeMinutes == null ? mutedColor : textColor,
                              fontSize: 15,
                              fontWeight: _birthTimeMinutes == null ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_birthTimeMinutes == null)
                          Padding(
                            padding: const EdgeInsets.only(left: 6, top: 6),
                            child: Text(
                              '• Pilih jam lahir yang tercatat di akta atau surat lahir.',
                              style: TextStyle(color: mutedColor, fontSize: 12),
                            ),
                          ),
                      ],

                      const SizedBox(height: 20),

                      // 4. Birth City Field
                      _fieldLabel(t.translate('birthCityLabel'), Icons.location_on_outlined, textColor),
                      TextFormField(
                        key: const ValueKey('city-query'),
                        controller: _cityController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.search,
                        style: TextStyle(color: textColor, fontSize: 15),
                        decoration: InputDecoration(
                          labelText: t.translate('birthCity'),
                          hintText: t.translate('cityHint'),
                          prefixIcon: const Icon(Icons.search_outlined, color: AstroPalette.gold, size: 20),
                          fillColor: isLight ? Colors.grey.shade100 : const Color(0xFF140C24),
                          suffixIcon: _selectedCity == null
                              ? null
                              : IconButton(
                                  tooltip: 'Ganti kota',
                                  onPressed: _clearCity,
                                  icon: const Icon(Icons.close, color: AstroPalette.gold),
                                ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedCity = null;
                            _saveError = null;
                          });
                        },
                      ),
                      if (suggestions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isLight ? Colors.white : const Color(0xFF140C24),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AstroPalette.gold, width: 1.2),
                            ),
                            child: Column(
                              children: suggestions
                                  .map(
                                    (city) => ListTile(
                                      dense: true,
                                      title: Text(
                                        city.name,
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      subtitle: Text(
                                        city.regionName.isNotEmpty
                                            ? '${city.regionName}, ${city.countryName} • ${city.timeZoneLabel}'
                                            : '${city.countryName} • ${city.timeZoneLabel}',
                                        style: const TextStyle(color: AstroPalette.gold, fontSize: 12),
                                      ),
                                      onTap: () => _selectCity(city),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      if (_selectedCity == null)
                        Padding(
                          padding: const EdgeInsets.only(left: 6, top: 6),
                          child: Text(
                            '• Pilih kota dari daftar agar zona waktu & koordinat akurat.',
                            style: TextStyle(color: mutedColor, fontSize: 12),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // 5. System Zodiac Method
                      _fieldLabel(t.translate('zodiacSystem'), Icons.stars_outlined, textColor),
                      DropdownButtonFormField<Ayanamsha>(
                        key: const ValueKey('ayanamsha'),
                        initialValue: _ayanamsha,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.auto_awesome_outlined, color: AstroPalette.gold, size: 20),
                          fillColor: isLight ? Colors.grey.shade100 : const Color(0xFF140C24),
                        ),
                        dropdownColor: isLight ? Colors.white : const Color(0xFF140C24),
                        style: TextStyle(color: textColor, fontSize: 15),
                        items: Ayanamsha.values
                            .map(
                              (method) => DropdownMenuItem(
                                value: method,
                                child: Text(method.label),
                              ),
                            )
                            .toList(),
                        onChanged: _isSaving
                            ? null
                            : (method) {
                                if (method != null) {
                                  setState(() => _ayanamsha = method);
                                }
                              },
                      ),

                      const SizedBox(height: 24),

                      if (_saveError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AstroPalette.danger.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AstroPalette.danger),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AstroPalette.danger, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _saveError!,
                                  style: const TextStyle(color: AstroPalette.danger, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Main Submit Button
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: AstroPalette.goldGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AstroPalette.gold.withValues(alpha: 0.4),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveProfile,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AstroPalette.ink,
                                  ),
                                )
                              : const Icon(Icons.auto_awesome, color: AstroPalette.ink, size: 20),
                          label: Text(
                            _isSaving ? 'Menghitung Chart...' : t.translate('seeChart'),
                            style: const TextStyle(
                              color: AstroPalette.ink,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline, color: AstroPalette.muted, size: 15),
                    const SizedBox(width: 6),
                    Text(
                      t.translate('privacyNote'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: mutedColor, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _brandMark(BuildContext context) => Row(
    children: [
      const AstroLogoWidget(size: 40),
      const SizedBox(width: 12),
      Text(
        AppLocalizations.of(context).translate('appName'),
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF1A122E) : AstroPalette.parchment,
          fontFamily: 'serif',
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      const Spacer(),
      IconButton(
        tooltip: 'Pengaturan',
        onPressed: () => showDialog(
          context: context,
          builder: (_) => SettingsDialog(
            currentThemeMode: widget.currentThemeMode,
            currentLocale: widget.currentLocale,
            onThemeModeChanged: widget.onThemeModeChanged,
            onLocaleChanged: widget.onLocaleChanged,
          ),
        ),
        icon: const Icon(Icons.settings_outlined, color: AstroPalette.gold, size: 22),
      ),
    ],
  );

  Widget _fieldLabel(String label, IconData icon, Color textColor) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, color: AstroPalette.gold, size: 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );

  ButtonStyle _choiceButtonStyle(bool isLight) => OutlinedButton.styleFrom(
    alignment: Alignment.centerLeft,
    minimumSize: const Size.fromHeight(52),
    foregroundColor: isLight ? const Color(0xFF1A122E) : AstroPalette.parchment,
    backgroundColor: isLight ? Colors.grey.shade100 : const Color(0xFF140C24),
    side: BorderSide(color: isLight ? Colors.grey.shade300 : AstroPalette.line),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );

  Future<void> _chooseDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Pilih tanggal lahir',
    );
    if (date != null && mounted) {
      setState(() {
        _birthDate = DateTime(date.year, date.month, date.day);
        _saveError = null;
      });
    }
  }

  Future<void> _chooseTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _birthTimeMinutes == null
          ? const TimeOfDay(hour: 12, minute: 0)
          : TimeOfDay(
              hour: _birthTimeMinutes! ~/ 60,
              minute: _birthTimeMinutes! % 60,
            ),
      helpText: 'Pilih jam lahir yang tercatat',
    );
    if (time != null && mounted) {
      setState(() {
        _birthTimeMinutes = time.hour * 60 + time.minute;
        _saveError = null;
      });
    }
  }

  void _selectCity(BirthCity city) {
    setState(() {
      _selectedCity = city;
      _cityController.text = city.regionName.isNotEmpty
          ? '${city.name}, ${city.regionName}, ${city.countryName}'
          : '${city.name}, ${city.countryName}';
      _saveError = null;
    });
    FocusScope.of(context).unfocus();
  }

  void _clearCity() {
    setState(() {
      _selectedCity = null;
      _cityController.clear();
      _saveError = null;
    });
  }

  Future<void> _saveProfile() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    if (_birthDate == null ||
        _selectedCity == null ||
        (!_birthTimeUnknown && _birthTimeMinutes == null)) {
      setState(() {
        _saveError = _birthDate == null
            ? 'Pilih tanggal lahir untuk melanjutkan.'
            : _selectedCity == null
            ? 'Pilih kota dari daftar agar waktu lahir dihitung dengan tepat.'
            : 'Pilih jam yang tercatat atau tandai jam lahir tidak diketahui.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
    });
    try {
      await widget.onSave(
        BirthProfile(
          fullName: _nameController.text.trim(),
          birthDate: _birthDate!,
          birthTimeMinutes: _birthTimeUnknown ? null : _birthTimeMinutes,
          cityName: _selectedCity!.name,
          latitude: _selectedCity!.latitude,
          longitude: _selectedCity!.longitude,
          timeZone: _selectedCity!.timeZone,
          ayanamsha: _ayanamsha,
        ),
      );
    } on Exception {
      if (mounted) {
        setState(() {
          _saveError = 'Profil belum bisa disimpan dengan aman. Coba lagi.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';
}
