import 'package:get/get.dart';

import 'en_us.dart';
import 'zh_cn.dart';

/// App translations (tata-style): enum keys with per-language maps.
/// en/zh copy lives in en_us.dart / zh_cn.dart.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': enUS.map((key, value) => MapEntry(key.name, value)),
        'zh': zhCN.map((key, value) => MapEntry(key.name, value)),
      };
}
