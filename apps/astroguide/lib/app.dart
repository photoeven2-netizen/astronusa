import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_localizations.dart';
import 'core/astro_chart.dart';
import 'core/astro_logo.dart';
import 'core/astro_coach_client.dart';
import 'core/birth_profile.dart';
import 'core/city_catalog.dart';
import 'core/profile_repository.dart';
import 'features/dashboard_screen.dart';
import 'features/onboarding_screen.dart';
import 'theme/app_theme.dart';

class AstroNusaApp extends StatefulWidget {
  const AstroNusaApp({
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
  State<AstroNusaApp> createState() => _AstroNusaAppState();
}

class _AstroNusaAppState extends State<AstroNusaApp> {
  late Future<BirthProfile?> _profileFuture;
  bool _isEditing = false;
  ThemeMode _themeMode = ThemeMode.dark;
  Locale? _locale;

  void _updateThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  void _updateLocale(Locale? locale) {
    setState(() => _locale = locale);
  }

  @override
  void initState() {
    super.initState();
    _profileFuture = widget.profileRepository.load();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'AstroNusa',
    debugShowCheckedModeBanner: false,
    theme: buildAstroTheme(Brightness.light),
    darkTheme: buildAstroTheme(Brightness.dark),
    themeMode: _themeMode,
    locale: _locale ?? const Locale('id'),
    supportedLocales: const [
      Locale('id'),
      Locale('en'),
      Locale('ms'),
      Locale('ar'),
      Locale('zh'),
      Locale('ja'),
      Locale('ko'),
    ],
    localizationsDelegates: const [
      AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: FutureBuilder<BirthProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _StartupScreen(
            title: 'Menyiapkan AstroNusa',
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
                  title: 'Menyiapkan AstroNusa',
                  message:
                      'Memuat daftar kota Indonesia & Dunia untuk pencarian offline.',
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
                currentThemeMode: _themeMode,
                currentLocale: _locale,
                onThemeModeChanged: _updateThemeMode,
                onLocaleChanged: _updateLocale,
              );
            },
          );
        }

        return DashboardScreen(
          key: ValueKey(profile),
          profile: profile,
          cityCatalogFuture: widget.cityCatalog,
          chartService: widget.chartService,
          coachService: widget.coachService,
          onEditProfile: () => setState(() => _isEditing = true),
          currentThemeMode: _themeMode,
          currentLocale: _locale,
          onThemeModeChanged: _updateThemeMode,
          onLocaleChanged: _updateLocale,
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

class _StartupScreen extends StatefulWidget {
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
  State<_StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<_StartupScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: AstroPalette.cosmicGradient,
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: const AstroLogoWidget(size: 76),
                ),
                const SizedBox(height: 28),
                const Text(
                  'AstroNusa',
                  style: TextStyle(
                    color: AstroPalette.gold,
                    fontFamily: 'serif',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Menyelaraskan Peta Energi Nusantara & Semesta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AstroPalette.muted,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 36),
                if (widget.showProgress) ...[
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AstroPalette.gold),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AstroPalette.parchment,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AstroPalette.muted, fontSize: 13),
                ),
                if (widget.onRetry != null) ...[
                  const SizedBox(height: 22),
                  ElevatedButton(
                    onPressed: widget.onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AstroPalette.gold,
                      foregroundColor: AstroPalette.ink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
