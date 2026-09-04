import 'package:shared_preferences/shared_preferences.dart';

/// handles interaction with NSUserDefaults (on iOS) and SharedPreferences (on Android),
/// providing a persistent store for simple data.
class SharedPreferenceManager {
  SharedPreferences? _prefs;

  SharedPreferenceManager() {
    initPref();
  }
  get pref => _prefs;
  Future<void> initPref() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool?> setStringData(String key, String value) async =>
      await _prefs?.setString(key, value);

  Future<bool?> setBoolData(String key, bool value) async {
    if (_prefs == null) await initPref();
    return await _prefs?.setBool(key, value);
  }

  Future<bool> getBoolData(String key, [bool defaultValue = false]) async {
    if (_prefs == null) await initPref();
    try {
      return _prefs?.getBool(key) ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  String? getStringData(String key) => _prefs?.getString(key);

  Future<bool?> setIntData(String key, int value) async =>
      await _prefs?.setInt(key, value);

  Future<bool?> deleteIntData(String key) async => await _prefs?.remove(key);

  int? getIntData(String key) => _prefs?.getInt(key);
}
