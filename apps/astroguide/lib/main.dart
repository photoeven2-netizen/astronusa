import 'package:flutter/material.dart';

import 'app.dart';
import 'core/birth_chart_calculator.dart';
import 'core/astro_coach_client.dart';
import 'core/city_catalog.dart';
import 'core/profile_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  const apiBaseUrl = String.fromEnvironment(
    'ASTRONUSA_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3000',
  );

  runApp(
    AstroNusaApp(
      profileRepository: SecureProfileRepository(),
      cityCatalog: CityCatalog.load(),
      chartService: BirthChartCalculator(),
      coachService: AstroCoachClient(
        baseUrl: apiBaseUrl,
      ),
    ),
  );
}
