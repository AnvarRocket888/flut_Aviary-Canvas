import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/aviary_scheme.dart';
import '../models/user_profile.dart';

/// Low-level persistence via shared_preferences.
class StorageService {
  static final StorageService instance = StorageService._();
  StorageService._();

  late SharedPreferences _prefs;

  // Demo override – set by DemoData.inject(), never persisted.
  List<AviaryScheme>? _demoSchemes;

  /// Injects demo schemes in-memory only (never saved to SharedPreferences).
  void injectDemoSchemes(List<AviaryScheme> schemes) => _demoSchemes = schemes;

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
    if (_demoSchemes != null) return List<AviaryScheme>.unmodifiable(_demoSchemes!);
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

  // ── Backup / Restore ──────────────────────────────────────

  /// Returns a JSON string containing all schemes and the user profile.
  Future<String> exportBackupJson() async {
    final profile = await loadUserProfile();
    final schemes = await loadAllSchemes();
    return jsonEncode({
      'version':    1,
      'exportedAt': DateTime.now().toIso8601String(),
      'profile':    profile.toJson(),
      'schemes':    schemes.map((s) => s.toJson()).toList(),
    });
  }

  /// Restores all schemes and the user profile from a backup JSON string.
  /// Merges with existing data (schemes with the same id are overwritten).
  Future<void> importBackupJson(String json) async {
    final data = jsonDecode(json) as Map<String, dynamic>;
    if (data['profile'] != null) {
      final p = UserProfile.fromJson(data['profile'] as Map<String, dynamic>);
      await saveUserProfile(p);
    }
    if (data['schemes'] != null) {
      for (final raw in data['schemes'] as List) {
        final scheme = AviaryScheme.fromJson(raw as Map<String, dynamic>);
        await saveScheme(scheme);
      }
    }
  }

  /// Imports a single scheme from a JSON string (either a scheme or a backup).
  Future<AviaryScheme?> importSchemeJson(String json) async {
    final data = jsonDecode(json) as Map<String, dynamic>;
    // Support single-scheme JSON or backup JSON (take first scheme)
    if (data.containsKey('schemes')) {
      final list = data['schemes'] as List;
      if (list.isEmpty) return null;
      final scheme = AviaryScheme.fromJson(list.first as Map<String, dynamic>);
      await saveScheme(scheme);
      return scheme;
    }
    if (data.containsKey('id')) {
      final scheme = AviaryScheme.fromJson(data);
      await saveScheme(scheme);
      return scheme;
    }
    return null;
  }
}
