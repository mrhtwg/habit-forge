import 'package:fixnum/fixnum.dart';
import 'package:habit_forge_app/core/di/injection_container.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences-backed key/value store.
///
/// Registered as a singleton in the GetIt container (see
/// `core/di/injection_container.dart`); access it via [SpUtils.ins] or
/// `getIt<SpUtils>()`. Call [SpUtils.init] once at startup so the backing
/// [SharedPreferences] instance is ready before first use.
@singleton
class SpUtils {
  static SpUtils get ins => getIt<SpUtils>();

  SharedPreferences? _prefs;

  SpUtils();

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
    getIt<SpUtils>()._prefs ??= await SharedPreferences.getInstance();
  }
}
