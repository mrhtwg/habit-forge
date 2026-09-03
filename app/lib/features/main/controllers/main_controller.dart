import 'package:get/get.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/features/forge/controllers/forge_controller.dart';
import 'package:habit_forge_app/features/home/controllers/home_controller.dart';
import 'package:habit_forge_app/features/profile/controllers/profile_controller.dart';
import 'package:habit_forge_app/features/quests/controllers/quests_controller.dart';

class MainController extends GetxController {
  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    Get.put(HomeController());
    Get.put(ForgeController());
    Get.put(QuestsController());
    Get.put(ProfileController());
  }

  @override
  void onClose() {
    // Children belong to this page; dispose them so a later rebuild (e.g.
    // after "Reset All Data") starts with fresh state instead of stale lists.
    Get.delete<HomeController>(force: true);
    Get.delete<ForgeController>(force: true);
    Get.delete<QuestsController>(force: true);
    Get.delete<ProfileController>(force: true);
    super.onClose();
  }

  void onTabChanged(int index) {
    currentIndex.value = index;
    // Refresh the visible tab's data on every switch — anything may have
    // changed on another tab (rewards, wallet, character, tasks).
    switch (index) {
      case 0: // home
        UserService.to.loadCharacter();
        UserService.to.loadUserPrefs();
        Get.find<HomeController>().loadTodayTasks();
      case 1: // quests
        Get.find<QuestsController>().getTasks();
      case 2: // forge
        UserService.to.loadUserPrefs();
        Get.find<ForgeController>().listItems();
      case 3: // profile
        UserService.to.loadCharacter();
        UserService.to.loadUserPrefs();
        Get.find<ProfileController>().getTasks();
    }
  }
}
