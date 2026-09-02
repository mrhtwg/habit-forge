import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/utils/sp_utils.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/services/user_service.dart';

class SettingsController extends GetxController {
  void resetAllData() async {
    await NetworkRegistry.ins.resetAllData();
    SpUtils.ins.clear();
    UserService.to.clearData();
    Get.offAllNamed(Routers.splash);
  }
}
