import 'package:get/get.dart';
import 'package:habit_forge_app/features/forge/controllers/forge_controller.dart';

class ForgeBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<ForgeController>(() => ForgeController());
}
