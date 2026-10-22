import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'birth_profile.dart';

abstract interface class ProfileRepository {
  Future<BirthProfile?> load();

  Future<void> save(BirthProfile profile);

  Future<void> delete();
}

class SecureProfileRepository implements ProfileRepository {
  SecureProfileRepository({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _profileKey = 'astroguide.birth-profile.v1';

  final FlutterSecureStorage _storage;

  @override
  Future<BirthProfile?> load() async {
    final encoded = await _storage.read(key: _profileKey);
    if (encoded == null) {
      return null;
    }

    final value = jsonDecode(encoded);
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Saved profile is not a valid object.');
    }
    return BirthProfile.fromJson(Map<String, Object?>.from(value));
  }

  @override
  Future<void> save(BirthProfile profile) =>
      _storage.write(key: _profileKey, value: jsonEncode(profile.toJson()));

  @override
  Future<void> delete() => _storage.delete(key: _profileKey);
}
