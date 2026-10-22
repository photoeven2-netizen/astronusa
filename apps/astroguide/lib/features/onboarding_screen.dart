import 'package:flutter/material.dart';

import '../core/birth_city.dart';
import '../core/birth_profile.dart';
import '../core/city_catalog.dart';
import '../core/numerology.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    required this.cityCatalog,
    required this.onSave,
    this.initialProfile,
    super.key,
  });

  final CityCatalog cityCatalog;
  final Future<void> Function(BirthProfile) onSave;
  final BirthProfile? initialProfile;

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
  Ayanamsha _ayanamsha = Ayanamsha.lahiri;
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
    _ayanamsha = profile?.ayanamsha ?? Ayanamsha.lahiri;
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
    final query = _cityController.text.trim();
    final suggestions = _selectedCity == null && query.length >= 2
        ? widget.cityCatalog.search(query)
        : const <BirthCity>[];

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
            children: [
              _brandMark(),
              const SizedBox(height: 32),
              Text(
                'Langitmu punya cerita',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AstroPalette.parchment,
                  fontFamily: 'serif',
                  fontSize: 34,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Isi detail ini untuk melihat peta energi dan pola yang mungkin terasa dekat dengan dirimu.',
                style: TextStyle(color: AstroPalette.muted, fontSize: 15),
              ),
              const SizedBox(height: 30),
              TextFormField(
                key: const ValueKey('full-name'),
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nama lengkap',
                  hintText: 'Nama yang biasa kamu pakai',
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
              const SizedBox(height: 18),
              _fieldLabel('Tanggal lahir'),
              OutlinedButton(
                key: const ValueKey('birth-date'),
                onPressed: _isSaving ? null : _chooseDate,
                style: _choiceButtonStyle(),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _birthDate == null
                          ? 'Pilih tanggal lahir'
                          : _formatDate(_birthDate!),
                    ),
                  ],
                ),
              ),
              if (_birthDate == null)
                const Padding(
                  padding: EdgeInsets.only(left: 12, top: 6),
                  child: Text(
                    'Tanggal lahir diperlukan untuk menghitung chart.',
                    style: TextStyle(color: AstroPalette.muted, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 18),
              _fieldLabel('Jam lahir'),
              CheckboxListTile(
                key: const ValueKey('unknown-birth-time'),
                value: _birthTimeUnknown,
                onChanged: _isSaving
                    ? null
                    : (value) {
                        setState(() {
                          _birthTimeUnknown = value ?? true;
                        });
                      },
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'Jam lahir tidak diketahui',
                  style: TextStyle(color: AstroPalette.parchment, fontSize: 14),
                ),
              ),
              if (!_birthTimeUnknown) ...[
                OutlinedButton(
                  key: const ValueKey('birth-time'),
                  onPressed: _isSaving ? null : _chooseTime,
                  style: _choiceButtonStyle(),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule_outlined, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _birthTimeMinutes == null
                            ? 'Pilih jam lahir'
                            : _formatTime(_birthTimeMinutes!),
                      ),
                    ],
                  ),
                ),
                if (_birthTimeMinutes == null)
                  const Padding(
                    padding: EdgeInsets.only(left: 12, top: 6),
                    child: Text(
                      'Pilih jam yang tercatat, bukan perkiraan.',
                      style: TextStyle(color: AstroPalette.muted, fontSize: 12),
                    ),
                  ),
              ],
              const SizedBox(height: 18),
              TextFormField(
                key: const ValueKey('city-query'),
                controller: _cityController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: 'Kota lahir',
                  hintText: 'Cari kota di Indonesia',
                  suffixIcon: _selectedCity == null
                      ? const Icon(Icons.search)
                      : IconButton(
                          tooltip: 'Ganti kota',
                          onPressed: _clearCity,
                          icon: const Icon(Icons.close),
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
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AstroPalette.plum,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AstroPalette.line),
                    ),
                    child: Column(
                      children: suggestions
                          .map(
                            (city) => ListTile(
                              dense: true,
                              title: Text(city.name),
                              subtitle: Text(city.timeZone),
                              onTap: () => _selectCity(city),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              if (_selectedCity == null)
                const Padding(
                  padding: EdgeInsets.only(left: 12, top: 6),
                  child: Text(
                    'Pilih kota dari daftar agar zona waktunya tepat.',
                    style: TextStyle(color: AstroPalette.muted, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 18),
              _fieldLabel('Metode zodiak sidereal'),
              DropdownButtonFormField<Ayanamsha>(
                key: const ValueKey('ayanamsha'),
                initialValue: _ayanamsha,
                decoration: const InputDecoration(),
                dropdownColor: AstroPalette.plum,
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
              const SizedBox(height: 26),
              if (_saveError != null) ...[
                Text(
                  _saveError!,
                  style: const TextStyle(color: AstroPalette.danger),
                ),
                const SizedBox(height: 12),
              ],
              FilledButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor: AstroPalette.gold,
                  foregroundColor: AstroPalette.ink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Lihat peta energiku'),
              ),
              const SizedBox(height: 14),
              const Text(
                'Data lahir disimpan aman di ponsel.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AstroPalette.muted, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _brandMark() => Row(
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AstroPalette.gold),
        ),
        child: const Icon(
          Icons.auto_awesome,
          size: 17,
          color: AstroPalette.gold,
        ),
      ),
      const SizedBox(width: 10),
      const Text(
        'AstroGuide',
        style: TextStyle(
          color: AstroPalette.parchment,
          fontFamily: 'serif',
          fontSize: 20,
        ),
      ),
    ],
  );

  Widget _fieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      label,
      style: const TextStyle(
        color: AstroPalette.parchment,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  ButtonStyle _choiceButtonStyle() => OutlinedButton.styleFrom(
    alignment: Alignment.centerLeft,
    minimumSize: const Size.fromHeight(52),
    foregroundColor: AstroPalette.parchment,
    side: const BorderSide(color: AstroPalette.line),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
      _cityController.text = city.name;
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
