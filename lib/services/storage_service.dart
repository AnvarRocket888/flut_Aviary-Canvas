import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/aviary_scheme.dart';
import '../models/user_profile.dart';

/// Low-level persistence via shared_preferences.
class StorageService {
  static final StorageService instance = StorageService._();
  StorageService._();

  late SharedPreferences _prefs;

  static const String _keyProfile       = 'user_profile';
  static const String _keySchemesIndex  = 'schemes_index';
  static const String _schemePrefix     = 'scheme_';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── User profile ──────────────────────────────────────────

  Future<UserProfile> loadUserProfile() async {
    final raw = _prefs.getString(_keyProfile);
    if (raw == null) return const UserProfile();
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const UserProfile();
    }
  }

  Future<void> saveUserProfile(UserProfile p) async {
    await _prefs.setString(_keyProfile, jsonEncode(p.toJson()));
  }

  // ── Schemes ───────────────────────────────────────────────

  Future<List<String>> _loadIndex() async =>
      _prefs.getStringList(_keySchemesIndex) ?? [];

  Future<void> _saveIndex(List<String> ids) async =>
      _prefs.setStringList(_keySchemesIndex, ids);

  Future<List<AviaryScheme>> loadAllSchemes() async {
    final ids = await _loadIndex();
    final result = <AviaryScheme>[];
    for (final id in ids) {
      final s = await loadScheme(id);
      if (s != null) result.add(s);
    }
    return result;
  }

  Future<AviaryScheme?> loadScheme(String id) async {
    final raw = _prefs.getString('$_schemePrefix$id');
    if (raw == null) return null;
    try {
      return AviaryScheme.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveScheme(AviaryScheme scheme) async {
    await _prefs.setString('$_schemePrefix${scheme.id}', scheme.toJsonString());
    final ids = await _loadIndex();
    if (!ids.contains(scheme.id)) {
      ids.add(scheme.id);
      await _saveIndex(ids);
    }
  }

  Future<void> deleteScheme(String id) async {
    await _prefs.remove('$_schemePrefix$id');
    final ids = await _loadIndex();
    ids.remove(id);
    await _saveIndex(ids);
  }

  Future<int> schemeCount() async => (await _loadIndex()).length;
}
