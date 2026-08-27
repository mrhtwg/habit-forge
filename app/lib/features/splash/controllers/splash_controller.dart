import 'package:get/get.dart';
import 'package:habit_forge_app/core/constants/env_constants.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/storage/storage.dart';
import 'package:habit_forge_app/core/storage/storage_service.dart';

class SplashController extends GetxController {
  void awaitJump() async {
    // Create + init the storage implementation for the active mode
    // (hive / firebase / server) and register it under the StorageService type.
    await Get.putAsync<StorageService>(() async {
      final storage = await Storage.create();
      return storage.init();
    });

    await Future.delayed(const Duration(seconds: 1));

    final storage = StorageService.to;

    // Hive (local) mode: no login required — enter directly as guest.
    if (EnvConstants.isHive()) {
      _routeAfterEntry(storage);
      return;
    }

    // Firebase / server mode: not logged in → login page
    if (!storage.isLoggedIn) {
      Get.offAllNamed(Routers.login);
      return;
    }

    _routeAfterEntry(storage);
  }

  @override
  void onInit() {
    super.onInit();
    awaitJump();
  }

  void _routeAfterEntry(StorageService storage) {
    // Logged in, check onboarding
    final prefs = storage.userPrefs.value;
    if (prefs == null || !prefs.onboardingCompleted) {
      Get.offAllNamed(Routers.boarding);
    } else {
      Get.offAllNamed(Routers.main);
    }
  }
}
