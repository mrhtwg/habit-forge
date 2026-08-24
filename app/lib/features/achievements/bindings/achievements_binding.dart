import 'package:get/get.dart';
import 'package:habit_forge_app/features/achievements/controllers/achievements_controller.dart';

class AchievementsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<AchievementsController>(() => AchievementsController());
}
