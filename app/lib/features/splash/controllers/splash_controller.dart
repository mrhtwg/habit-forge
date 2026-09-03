import 'package:get/get.dart';
import 'package:habit_forge_app/core/constants/env_constants.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/services/user_service.dart';

class SplashController extends GetxController {
  void loadAndRouteEntry() async {
    // Initialize network
    await NetworkRegistry.ins.init();

    // Hive mode has no real login: auto sign-in as guest through the auth
    // facade (mints the local session token).
    if (EnvConstants.isHive() && !UserService.to.isLoggedIn()) {
      await NetworkRegistry.ins.login('guest');
    }

    await Future.delayed(const Duration(milliseconds: 1000));

    if (!(await UserService.to.isLoggedIn())) {
      Get.offAllNamed(Routers.login);
      return;
    }

    // Logged in, check character
    await UserService.to.loadUserPrefs();
    await UserService.to.loadCharacter();
    if (UserService.to.character.value == null) {
      Get.offAllNamed(Routers.boarding);
    } else {
      Get.offAllNamed(Routers.main);
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadAndRouteEntry();
  }
}
