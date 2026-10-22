import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'astro_chart.dart';
import 'numerology.dart';

abstract interface class CoachService {
  Future<AstroReading> read({
    required AstroChart chart,
    required NumerologyNumbers numerology,
    String? question,
  });
}

class CoachException implements Exception {
  const CoachException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AstroReading {
  const AstroReading({
    required this.opening,
    required this.nameInsight,
    required this.sunInsight,
    required this.moonInsight,
    required this.risingInsight,
    required this.careerLoveInsight,
    required this.advice,
    required this.questions,
  });

  final String opening;
  final String nameInsight;
  final String? sunInsight;
  final String? moonInsight;
  final String? risingInsight;
  final String? careerLoveInsight;
  final String advice;
  final List<String> questions;

  factory AstroReading.fromJson(Map<String, Object?> json) {
    const expectedKeys = {
      'opening',
      'nameInsight',
      'sunInsight',
      'moonInsight',
      'risingInsight',
      'careerLoveInsight',
      'advice',
      'questions',
    };
    if (json.keys.toSet().length != expectedKeys.length ||
        !json.keys.toSet().containsAll(expectedKeys)) {
      throw const FormatException('The coach returned an unsupported reading.');
    }

    String requiredText(String key, int maxLength) {
      final value = json[key];
      if (value is! String ||
          value.trim().isEmpty ||
          value.length > maxLength) {
        throw const FormatException(
          'The coach returned an incomplete reading.',
        );
      }
      return value;
    }

    String? optionalText(String key, int maxLength) {
      final value = json[key];
      if (value == null) {
        return null;
      }
      if (value is! String ||
          value.trim().isEmpty ||
          value.length > maxLength) {
        throw const FormatException(
          'The coach returned an invalid chart insight.',
        );
      }
      return value;
    }

    final questionsValue = json['questions'];
    if (questionsValue is! List ||
        questionsValue.length != 2 ||
        questionsValue.any(
          (question) =>
              question is! String ||
              question.trim().isEmpty ||
              question.length > 240,
        )) {
      throw const FormatException(
        'The coach returned invalid follow-up questions.',
      );
    }

    return AstroReading(
      opening: requiredText('opening', 400),
      nameInsight: requiredText('nameInsight', 800),
      sunInsight: optionalText('sunInsight', 800),
      moonInsight: optionalText('moonInsight', 800),
      risingInsight: optionalText('risingInsight', 800),
      careerLoveInsight: optionalText('careerLoveInsight', 800),
      advice: requiredText('advice', 800),
      questions: List<String>.unmodifiable(questionsValue.cast<String>()),
    );
  }
}

class AstroCoachClient implements CoachService {
  AstroCoachClient({
    required this.baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 25),
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final Duration timeout;
  final http.Client _client;

  @override
  Future<AstroReading> read({
    required AstroChart chart,
    required NumerologyNumbers numerology,
    String? question,
  }) async {
    final endpoint = _endpoint();
    if (question != null && question.length > 1000) {
      throw const CoachException(
        'Pertanyaan terlalu panjang. Batasi hingga 1.000 karakter.',
      );
    }
    final body = <String, Object?>{
      'chart': chart.toReadingJson(),
      'numerology': {
        'expression': numerology.expression,
        'soulUrge': numerology.soulUrge,
        'personality': numerology.personality,
      },
      if (question != null && question.trim().isNotEmpty)
        'question': question.trim(),
    };

    late final http.Response response;
    try {
      response = await _client
          .post(
            endpoint,
            headers: const {'content-type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const CoachException(
        'Coach AI terlalu lama merespons. Coba lagi sebentar.',
      );
    } on http.ClientException {
      throw const CoachException(
        'Server coach belum bisa dijangkau. Periksa alamat server dan koneksi internet.',
      );
    }

    if (response.statusCode != 200) {
      throw CoachException(_messageForStatus(response.statusCode));
    }

    late final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const CoachException(
        'Server mengirim bacaan dengan format yang tidak dikenal.',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const CoachException(
        'Server mengirim bacaan dengan format yang tidak dikenal.',
      );
    }

    try {
      final reading = AstroReading.fromJson(Map<String, Object?>.from(decoded));
      if ((chart.sun == null) != (reading.sunInsight == null) ||
          (chart.moon == null) != (reading.moonInsight == null) ||
          (chart.rising == null) != (reading.risingInsight == null) ||
          ((chart.mars != null || chart.venus != null) !=
              (reading.careerLoveInsight != null))) {
        throw const FormatException(
          'The coach guessed an unavailable chart placement.',
        );
      }
      return reading;
    } on FormatException {
      throw const CoachException(
        'Bacaan dari server belum lengkap. Coba buat bacaan baru.',
      );
    }
  }

  void close() => _client.close();

  Uri _endpoint() {
    if (baseUrl.trim().isEmpty) {
      throw const CoachException(
        'Coach AI belum dikonfigurasi. Tambahkan alamat API saat menyiapkan server.',
      );
    }

    final uri = Uri.tryParse(baseUrl.trim());
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.query.isNotEmpty ||
        uri.fragment.isNotEmpty ||
        !_isSecureOrLocal(uri)) {
      throw const CoachException(
        'Alamat server coach tidak aman atau tidak valid.',
      );
    }

    return uri.resolve('/v1/readings');
  }

  bool _isSecureOrLocal(Uri uri) {
    if (uri.scheme == 'https') {
      return true;
    }
    return uri.scheme == 'http' &&
        const {'localhost', '127.0.0.1', '10.0.2.2', '::1'}.contains(uri.host);
  }

  String _messageForStatus(int statusCode) => switch (statusCode) {
    400 => 'Data bacaan tidak dapat diproses. Periksa profil dan coba lagi.',
    429 => 'Kamu sudah meminta banyak bacaan. Tunggu sebentar lalu coba lagi.',
    503 => 'Coach AI belum dikonfigurasi oleh pengelola server.',
    >= 500 => 'Server coach sedang bermasalah. Coba lagi nanti.',
    _ => 'Server menolak permintaan bacaan. Periksa pengaturan server.',
  };
}
