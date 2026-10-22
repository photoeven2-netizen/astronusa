import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/astro_chart.dart';
import 'core/astro_coach_client.dart';
import 'core/birth_profile.dart';
import 'core/city_catalog.dart';
import 'core/profile_repository.dart';
import 'features/dashboard_screen.dart';
import 'features/onboarding_screen.dart';
import 'theme/app_theme.dart';

class AstroGuideApp extends StatefulWidget {
  const AstroGuideApp({
    required this.profileRepository,
    required this.cityCatalog,
    required this.chartService,
    required this.coachService,
    super.key,
  });

  final ProfileRepository profileRepository;
  final Future<CityCatalog> cityCatalog;
  final ChartService chartService;
  final CoachService coachService;

  @override
  State<AstroGuideApp> createState() => _AstroGuideAppState();
}

class _AstroGuideAppState extends State<AstroGuideApp> {
  late Future<BirthProfile?> _profileFuture;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = widget.profileRepository.load();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'AstroGuide',
    debugShowCheckedModeBanner: false,
    theme: buildAstroTheme(),
    locale: const Locale('id'),
    supportedLocales: const [Locale('id')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: FutureBuilder<BirthProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _StartupScreen(
            title: 'Menyiapkan AstroGuide',
            message: 'Membuka profil yang tersimpan di ponselmu.',
            showProgress: true,
          );
        }
        if (snapshot.hasError) {
          return _StartupScreen(
            title: 'Profil belum bisa dibuka',
            message: 'Penyimpanan aman belum merespons. Coba buka lagi.',
            onRetry: () => setState(
              () => _profileFuture = widget.profileRepository.load(),
            ),
          );
        }

        final profile = snapshot.data;
        if (profile == null || _isEditing) {
          return FutureBuilder<CityCatalog>(
            future: widget.cityCatalog,
            builder: (context, citySnapshot) {
              if (citySnapshot.connectionState != ConnectionState.done) {
                return const _StartupScreen(
                  title: 'Menyiapkan AstroGuide',
                  message:
                      'Memuat daftar kota Indonesia untuk pencarian offline.',
                  showProgress: true,
                );
              }
              if (citySnapshot.hasError || citySnapshot.data == null) {
                return _StartupScreen(
                  title: 'Daftar kota belum tersedia',
                  message: 'Kota lahir tidak bisa dicari. Periksa instalasi aplikasi.',
                  onRetry: () => setState(
                    () => _profileFuture = widget.profileRepository.load(),
                  ),
                );
              }

              return OnboardingScreen(
                cityCatalog: citySnapshot.data!,
                initialProfile: profile,
                onSave: _saveProfile,
              );
            },
          );
        }

        return DashboardScreen(
          key: ValueKey(profile),
          profile: profile,
          chartService: widget.chartService,
          coachService: widget.coachService,
          onEditProfile: () => setState(() => _isEditing = true),
        );
      },
    ),
  );

  Future<void> _saveProfile(BirthProfile profile) async {
    await widget.profileRepository.save(profile);
    if (mounted) {
      setState(() {
        _profileFuture = Future.value(profile);
        _isEditing = false;
      });
    }
  }
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen({
    required this.title,
    required this.message,
    this.onRetry,
    this.showProgress = false,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final bool showProgress;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showProgress) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AstroPalette.parchment,
                  fontFamily: 'serif',
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AstroPalette.muted),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Coba lagi'),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
