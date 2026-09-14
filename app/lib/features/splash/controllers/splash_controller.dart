import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/constants/env_constants.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/services/firebase_auth_service.dart';
import 'package:habit_forge_app/core/services/user_service.dart';

class SplashController extends GetxController {
  void loadAndRouteEntry() async {
    await NetworkRegistry.ins.init();

    if (EnvConstants.isHive()) {
      // Local-only: guest session, never Firebase/server login.
      if (!UserService.to.isLoggedIn()) {
        await NetworkRegistry.ins.login('guest');
      }
    } else if (EnvConstants.isFirebase()) {
      // Restore Google/email session, otherwise anonymous guest (no login page).
      if (Get.isRegistered<FirebaseAuthService>() && FirebaseAuthService.to.isAvailable) {
        if (FirebaseAuth.instance.currentUser == null) {
          await FirebaseAuthService.to.ensureAnonymousSession();
        }
        final current = FirebaseAuth.instance.currentUser;
        await NetworkRegistry.ins.login(
          current != null && !current.isAnonymous ? 'google' : 'guest',
        );
      }
    } else if (EnvConstants.isServer()) {
      // Keep JWT if present; otherwise continue without forcing AuthPage.
      if (UserService.to.isLoggedIn()) {
        await NetworkRegistry.ins.login('email');
      }
    }

    await Future.delayed(const Duration(milliseconds: 1000));

    // Never route to AuthPage — cloud sign-in lives in Settings.
    if ((EnvConstants.isHive() || EnvConstants.isFirebase()) && !UserService.to.isLoggedIn()) {
      await NetworkRegistry.ins.login('guest');
    }

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
