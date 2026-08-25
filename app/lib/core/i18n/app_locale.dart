import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

/// Language/locale helper for the app.
///
/// The chosen language is persisted in Hive (`userBox` key `locale`):
/// `en` (default), `zh`, or `system` (currently resolves to English).
///
/// Note: GetX's `tr` returns the raw key when `Get.locale` is null, so
/// [initialLocale] / [set] always resolve to a concrete locale (never null).
class AppLocale {
  static const String system = 'system';

  static const String en = 'en';
  static const String zh = 'zh';
  AppLocale._();

  /// Reads the persisted language code (defaults to English).
  static String current() {
    final box = Hive.box('userBox');
    return box.get('locale', defaultValue: en) as String;
  }

  /// Locale to pass to GetMaterialApp on startup (always non-null).
  static Locale initialLocale() {
    return resolve(current()) ?? const Locale('en');
  }

  /// BCP-47 language code for intl date formatting (e.g. 'zh', 'en').
  static String languageCode() => Get.locale?.languageCode ?? 'en';

  /// Maps a saved code to a [Locale]; `system` (and unknown codes) → null.
  static Locale? resolve(String code) {
    switch (code) {
      case en:
        return const Locale('en');
      case zh:
        return const Locale('zh');
      default:
        return null;
    }
  }

  /// Applies a language code immediately and persists it.
  static void set(String code) {
    Hive.box('userBox').put('locale', code);
    Get.updateLocale(resolve(code) ?? const Locale('en'));
  }
}
