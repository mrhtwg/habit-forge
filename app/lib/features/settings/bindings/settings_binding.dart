import 'package:get/get.dart';
import 'package:habit_forge_app/features/settings/controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<SettingsController>(() => SettingsController());
}
