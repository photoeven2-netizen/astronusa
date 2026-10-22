import 'package:flutter/material.dart';

import 'app.dart';
import 'core/birth_chart_calculator.dart';
import 'core/astro_coach_client.dart';
import 'core/city_catalog.dart';
import 'core/profile_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    AstroGuideApp(
      profileRepository: SecureProfileRepository(),
      cityCatalog: CityCatalog.load(),
      chartService: BirthChartCalculator(),
      coachService: AstroCoachClient(
        baseUrl: const String.fromEnvironment('ASTROGUIDE_API_BASE_URL'),
      ),
    ),
  );
}
