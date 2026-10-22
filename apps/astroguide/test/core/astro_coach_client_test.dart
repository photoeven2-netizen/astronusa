import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:astro_guide/core/astro_chart.dart';
import 'package:astro_guide/core/astro_coach_client.dart';
import 'package:astro_guide/core/birth_profile.dart';
import 'package:astro_guide/core/numerology.dart';

void main() {
  const chart = AstroChart(
    ayanamsha: Ayanamsha.lahiri,
    birthTimeKnown: false,
    sun: 'Leo',
    moon: 'Virgo',
    rising: null,
    mars: 'Gemini',
    venus: 'Cancer',
  );
  const numerology = NumerologyNumbers(
    expression: 7,
    soulUrge: 11,
    personality: 5,
  );
  final responseBody = {
    'opening':
        'Energi namamu dan langitmu mengajakmu tumbuh dengan caramu sendiri.',
    'nameInsight': 'Angka ekspresi 7 memancarkan rasa ingin tahu.',
    'sunInsight': 'Leo memberi keberanian untuk bersinar.',
    'moonInsight': 'Virgo mencari rasa aman lewat hal sederhana.',
    'risingInsight': null,
    'careerLoveInsight': 'Mars di Gemini menyukai ide segar; Venus di Cancer mendambakan kedekatan.',
    'advice': 'Percayai langkah kecil yang kamu pilih hari ini.',
    'questions': [
      'Bagian mana yang paling terasa dekat?',
      'Mau membahas area lain?',
    ],
  };

  test(
    'sends only calculated chart, numerology, and a voluntary question',
    () async {
      late http.Request sentRequest;
      final client = AstroCoachClient(
        baseUrl: 'https://coach.example',
        client: MockClient((request) async {
          sentRequest = request;
          return http.Response(
            jsonEncode(responseBody),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.close);

      final reading = await client.read(
        chart: chart,
        numerology: numerology,
        question: 'Bagaimana dengan pekerjaanku?',
      );

      final body = jsonDecode(sentRequest.body) as Map<String, dynamic>;
      expect(sentRequest.url.path, '/v1/readings');
      expect(body.keys.toSet(), {'chart', 'numerology', 'question'});
      expect(body['chart']['positions']['rising'], isNull);
      expect(body, isNot(contains('fullName')));
      expect(sentRequest.body, isNot(contains('birthDate')));
      expect(sentRequest.body, isNot(contains('latitude')));
      expect(sentRequest.body, contains('Bagaimana dengan pekerjaanku?'));
      expect(reading.risingInsight, isNull);
      expect(reading.questions, hasLength(2));
    },
  );

  test(
    'surfaces a clear configuration error instead of a fallback reading',
    () async {
      final client = AstroCoachClient(
        baseUrl: '',
        client: MockClient((_) async => http.Response('', 500)),
      );
      addTearDown(client.close);

      await expectLater(
        client.read(chart: chart, numerology: numerology),
        throwsA(isA<CoachException>()),
      );
    },
  );

  test('rejects insecure non-local API URLs', () async {
    final client = AstroCoachClient(
      baseUrl: 'http://coach.example',
      client: MockClient((_) async => http.Response('', 200)),
    );
    addTearDown(client.close);

    await expectLater(
      client.read(chart: chart, numerology: numerology),
      throwsA(isA<CoachException>()),
    );
  });

  test(
    'maps service configuration failures into a user-facing exception',
    () async {
      final client = AstroCoachClient(
        baseUrl: 'https://coach.example',
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'error': {
                'code': 'SERVICE_NOT_CONFIGURED',
                'message': 'AI readings are not configured.',
              },
            }),
            503,
          ),
        ),
      );
      addTearDown(client.close);

      await expectLater(
        client.read(chart: chart, numerology: numerology),
        throwsA(
          isA<CoachException>().having(
            (error) => error.message,
            'message',
            contains('belum dikonfigurasi'),
          ),
        ),
      );
    },
  );
}
