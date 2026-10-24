import 'dart:convert';
import 'package:flutter/foundation.dart';
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

@immutable
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
      opening: requiredText('opening', 2000),
      nameInsight: requiredText('nameInsight', 2000),
      sunInsight: optionalText('sunInsight', 2000),
      moonInsight: optionalText('moonInsight', 2000),
      risingInsight: optionalText('risingInsight', 2000),
      careerLoveInsight: optionalText('careerLoveInsight', 2000),
      advice: requiredText('advice', 2000),
      questions: List<String>.unmodifiable(questionsValue.cast<String>()),
    );
  }
}

class AstroCoachClient implements CoachService {
  AstroCoachClient({
    required this.baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final Duration timeout;
  final http.Client _client;

  String _messageForStatus(int statusCode) {
    switch (statusCode) {
      case 429:
        return 'Terlalu banyak permintaan (Rate limit). Coba beberapa saat lagi.';
      case 503:
        return 'Coach AI belum dikonfigurasi oleh pengelola server.';
      case 500:
      case 502:
      case 504:
        return 'Server AI mengalami gangguan. Coba beberapa saat lagi.';
      default:
        return 'Gagal menghubungi server AI (Kode error: $statusCode).';
    }
  }

  Uri _endpointFor(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      throw const CoachException(
        'Coach AI belum dikonfigurasi. Tambahkan alamat API saat menyiapkan server.',
      );
    }
    final parsed = Uri.tryParse(trimmed);
    if (parsed == null || !parsed.hasScheme) {
      throw const CoachException('Alamat server AI tidak valid.');
    }
    if (parsed.scheme == 'http' &&
        parsed.host != '127.0.0.1' &&
        parsed.host != 'localhost' &&
        parsed.host != '10.0.2.2') {
      throw const CoachException(
        'Alamat server HTTP tidak aman (harus HTTPS atau localhost).',
      );
    }
    return parsed.resolve('/v1/readings');
  }

  @override
  Future<AstroReading> read({
    required AstroChart chart,
    required NumerologyNumbers numerology,
    String? question,
  }) async {
    if (question != null && question.length > 1000) {
      throw const CoachException(
        'Pertanyaan terlalu panjang. Batasi hingga 1.000 karakter.',
      );
    }

    final endpoint = _endpointFor(baseUrl);

    try {
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

      final response = await _client
          .post(
            endpoint,
            headers: const {'content-type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(timeout);

      if (response.statusCode != 200) {
        throw CoachException(_messageForStatus(response.statusCode));
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Respon server tidak valid.');
      }

      return AstroReading.fromJson(Map<String, Object?>.from(decoded));
    } on CoachException {
      rethrow;
    } catch (_) {
      throw const CoachException('Gagal terhubung ke server AI. Periksa koneksi internet Anda.');
    }
  }

  void close() => _client.close();
}
