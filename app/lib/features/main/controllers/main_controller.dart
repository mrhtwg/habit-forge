import 'package:get/get.dart';
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

  void onTabChanged(int index) => currentIndex.value = index;
}
