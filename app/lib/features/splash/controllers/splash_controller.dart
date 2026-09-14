import 'package:get/get.dart';
import 'package:habit_forge_app/core/constants/env_constants.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/services/firebase_session.dart';
import 'package:habit_forge_app/core/services/user_service.dart';

class SplashController extends GetxController {
  void loadAndRouteEntry() async {
    if (EnvConstants.isHive()) {
      await NetworkRegistry.ins.init();
      if (!UserService.to.isLoggedIn()) {
        await NetworkRegistry.ins.login('guest');
      }
    } else if (EnvConstants.isFirebase()) {
      // Local-first: no anonymous Auth / Firestore on cold start.
      // Cloud restore only if the user previously signed in from Settings.
      await FirebaseSession.bootstrapAtSplash();
    } else if (EnvConstants.isServer()) {
      await NetworkRegistry.ins.init();
      if (UserService.to.isLoggedIn()) {
        try {
          await NetworkRegistry.ins.login('email').timeout(FirebaseSession.networkTimeout);
        } catch (_) {
          // Stay on device with existing token cleared path handled below.
        }
      }
    }

    await Future.delayed(const Duration(milliseconds: 800));

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
