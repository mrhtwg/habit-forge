import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/utils/sp_utils.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/services/data_reset_service.dart';
import 'package:habit_forge_app/core/services/user_service.dart';

class SettingsController extends GetxController {
  /// Wipes all local data (hive mode only) and returns to the splash screen.
  Future<void> resetAllData() async {
    await DataResetService.to.resetAllData();
    SpUtils.ins.clear();
    UserService.to.clearData();
    Get.offAllNamed(Routers.splash);
  }
}
