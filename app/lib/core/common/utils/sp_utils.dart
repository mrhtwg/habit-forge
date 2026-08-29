import 'package:fixnum/fixnum.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpUtils {
  static SpUtils? _instance;

  static SharedPreferences? _prefs;

  static SpUtils get ins {
    if (_instance == null) {
      _instance = SpUtils._();
    }
    return _instance!;
  }

  SpUtils._();

  Future<void> clear() async {
    await _prefs?.clear();
  }

  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  Int64? getInt64(String key, {Int64? defaultValue}) {
    final value = _prefs?.getString(key);
    if (value == null || value.isEmpty) {
      return defaultValue ?? Int64(0);
    }
    try {
      return Int64.parseInt(value);
    } catch (e) {
      return defaultValue ?? Int64(0);
    }
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  Future<void> putBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  Future<void> putInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  Future<void> putInt64(String key, Int64 value) async {
    await _prefs?.setString(key, value.toString());
  }

  Future<void> putString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
}
