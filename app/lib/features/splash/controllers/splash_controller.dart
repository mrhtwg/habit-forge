import 'package:get/get.dart';
import 'package:habit_forge_app/core/interface/network_registry.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/services/user_service.dart';

class SplashController extends GetxController {
  void loadAndRouteEntry() async {
    // Initialize network
    await NetworkRegistry.ins.init();

    await Future.delayed(const Duration(milliseconds: 500));

    if (!(await UserService.to.isLoggedIn())) {
      Get.offAllNamed(Routers.login);
      return;
    }

    // Logged in, check character
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
