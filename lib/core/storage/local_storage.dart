import 'package:shared_preferences/shared_preferences.dart';

/// Thin abstraction over [SharedPreferences] so datasources depend on this
/// interface (easy to fake in tests) instead of the plugin directly.
abstract class LocalStorage {
  Future<String?> getString(String key);
  Future<bool> setString(String key, String value);
  Future<bool> remove(String key);
}

class SharedPreferencesStorage implements LocalStorage {
  SharedPreferencesStorage(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<String?> getString(String key) async => _prefs.getString(key);

  @override
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);

  @override
  Future<bool> remove(String key) => _prefs.remove(key);
}
