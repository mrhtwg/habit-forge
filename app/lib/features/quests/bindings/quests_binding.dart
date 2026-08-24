import 'package:get/get.dart';
import 'package:habit_forge_app/features/quests/controllers/quests_controller.dart';

class QuestsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<QuestsController>(() => QuestsController());
}
