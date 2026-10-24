import 'dart:convert';

import 'package:diacritic/diacritic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'birth_city.dart';

class CityCatalog {
  CityCatalog._(this._cities);

  final List<BirthCity> _cities;

  factory CityCatalog.fromRecords(Iterable<Map<String, Object?>> records) {
    final cities = records.map(BirthCity.fromJson).toList(growable: false);
    return CityCatalog._(cities);
  }

  static Future<CityCatalog> load({
    AssetBundle? bundle,
    String assetPath = 'assets/data/indonesia_cities.json',
  }) async {
    final json = await (bundle ?? rootBundle).loadString(assetPath);
    return compute(_parseJsonCatalog, json);
  }

  static CityCatalog _parseJsonCatalog(String json) {
    final records = jsonDecode(json);
    if (records is! List) {
      throw const FormatException(
        'City catalog must contain a list of places.',
      );
    }

    final cities = records.map((record) {
      if (record is! Map<String, dynamic>) {
        throw const FormatException(
          'City catalog contains an invalid place.',
        );
      }
      return BirthCity.fromJson(Map<String, Object?>.from(record));
    }).toList(growable: false);

    return CityCatalog._(cities);
  }

  List<BirthCity> search(String query, {int limit = 8}) {
    final normalizedQuery = removeDiacritics(query.trim().toLowerCase());
    if (normalizedQuery.isEmpty || limit <= 0) {
      return const [];
    }

    final terms = normalizedQuery.split(RegExp(r'\s+'));

    return _cities
        .where((city) {
          final cityName = removeDiacritics(city.name.toLowerCase());
          final regionName = removeDiacritics(city.regionName.toLowerCase());
          final fullText = '$cityName $regionName';
          return terms.every((term) => fullText.contains(term));
        })
        .take(limit)
        .toList(growable: false);
  }
}
