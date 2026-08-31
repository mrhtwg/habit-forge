import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/utils/sp_utils.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';

class SettingsController extends GetxController {
  Future<void> resetAllData() async {
    await NetworkRegistry.ins.resetAllData();
    SpUtils.ins.clear();
    Get.offAllNamed(Routers.splash);
  }
}
