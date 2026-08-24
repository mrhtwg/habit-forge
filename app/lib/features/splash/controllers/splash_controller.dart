import 'package:get/get.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/services/hive_service.dart';

class SplashController extends GetxController {
  void awaitJump() async {
    await Get.putAsync(() => HiveService().init());

    await Future.delayed(const Duration(seconds: 1));

    final hive = HiveService.to;

    // Not logged in → login page
    if (!hive.isLoggedIn) {
      Get.offAllNamed(Routers.login);
      return;
    }

    // Logged in, check onboarding
    final prefs = hive.userPrefs.value;
    if (prefs == null || !prefs.onboardingCompleted) {
      Get.offAllNamed(Routers.boarding);
    } else {
      Get.offAllNamed(Routers.main);
    }
  }

  @override
  void onInit() {
    super.onInit();
    awaitJump();
  }
}
