import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astro_guide/app.dart';
import 'package:astro_guide/core/astro_chart.dart';
import 'package:astro_guide/core/astro_coach_client.dart';
import 'package:astro_guide/core/birth_profile.dart';
import 'package:astro_guide/core/city_catalog.dart';
import 'package:astro_guide/core/numerology.dart';
import 'package:astro_guide/core/profile_repository.dart';

final _profile = BirthProfile(
  fullName: 'Nadia Putri',
  birthDate: DateTime(1995, 8, 14),
  birthTimeMinutes: null,
  cityName: 'Jakarta',
  latitude: -6.2088,
  longitude: 106.8456,
  timeZone: 'Asia/Jakarta',
  ayanamsha: Ayanamsha.lahiri,
);

const _chart = AstroChart(
  ayanamsha: Ayanamsha.lahiri,
  birthTimeKnown: false,
  sun: 'Leo',
  moon: 'Virgo',
  rising: null,
  mars: 'Gemini',
  venus: 'Cancer',
);

class _MemoryProfileRepository implements ProfileRepository {
  _MemoryProfileRepository(this.profile);

  BirthProfile? profile;

  @override
  Future<void> delete() async => profile = null;

  @override
  Future<BirthProfile?> load() async => profile;

  @override
  Future<void> save(BirthProfile profile) async => this.profile = profile;
}

class _FakeChartService implements ChartService {
  @override
  Future<AstroChart> calculate(BirthProfile profile) async => _chart;
}

class _FakeCoachService implements CoachService {
  @override
  Future<AstroReading> read({
    required AstroChart chart,
    required NumerologyNumbers numerology,
    String? question,
  }) async => const AstroReading(
    opening: 'Energi hari ini terasa hangat dan berani.',
    nameInsight: 'Namamu membawa rasa ingin tahu.',
    sunInsight: 'Leo menyukai ruang untuk berkarya.',
    moonInsight: 'Virgo merasa aman lewat keteraturan.',
    risingInsight: null,
    careerLoveInsight: 'Mars di Gemini suka ide baru.',
    advice: 'Rayakan proses kecilmu.',
    questions: ['Apa yang terasa paling dekat?', 'Mau membahas bagian lain?'],
  );
}

CityCatalog _cityCatalog() => CityCatalog.fromRecords([
  const {
    'id': 1642911,
    'name': 'Jakarta',
    'regionCode': '04',
    'latitude': -6.2088,
    'longitude': 106.8456,
    'timeZone': 'Asia/Jakarta',
    'population': 8540121,
  },
]);

Widget _app({BirthProfile? profile}) => AstroNusaApp(
  profileRepository: _MemoryProfileRepository(profile),
  cityCatalog: Future.value(_cityCatalog()),
  chartService: _FakeChartService(),
  coachService: _FakeCoachService(),
);

void main() {
  testWidgets('welcomes a new user with the profile form and privacy note', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Langitmu punya cerita'), findsOneWidget);
    expect(find.byKey(const ValueKey('full-name')), findsOneWidget);
    expect(find.text('Kota lahir'), findsOneWidget);
    expect(find.text('Jam lahir tidak diketahui'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.text('Data lahir disimpan aman di ponsel.'),
    );
    expect(find.text('Data lahir disimpan aman di ponsel.'), findsOneWidget);
  });

  testWidgets(
    'loads a saved profile and explains when Rising cannot be known',
    (tester) async {
      await tester.pumpWidget(_app(profile: _profile));
      await tester.pumpAndSettle();

      expect(find.text('Peta energimu'), findsOneWidget);
      expect(
        find.text(
          'Halo Nadia. Kenali polamu dengan rasa ingin tahu, bukan dengan batasan.',
        ),
        findsOneWidget,
      );
      expect(find.text('Belum cukup data untuk memastikan'), findsOneWidget);
      expect(find.text('Buat bacaan AstroNusa'), findsOneWidget);
    },
  );

  testWidgets('renders the required visual structure after an AI reading', (
    tester,
  ) async {
    await tester.pumpWidget(_app(profile: _profile));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Buat bacaan AstroNusa'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buat bacaan AstroNusa'));
    await tester.pumpAndSettle();

    expect(find.text('✨ PROFILE ENERGI UTAMAMU ✨'), findsOneWidget);
    expect(find.text('🔮 ANALISIS MENDALAM (THE BIG THREE)'), findsOneWidget);
    expect(find.textContaining('Persona & Sinergi Nama'), findsOneWidget);
    expect(find.textContaining('Kedalaman Emosi'), findsOneWidget);
    expect(find.textContaining('Potensi Karir & Cinta'), findsOneWidget);
    expect(find.textContaining('ASTRO-ADVICE UNTUK NADIA'), findsOneWidget);
    expect(find.text('Apa yang terasa paling dekat?'), findsOneWidget);
    expect(find.text('Mau membahas bagian lain?'), findsOneWidget);
  });
}
