import 'package:get/get.dart';
import 'package:habit_forge_app/features/main/controllers/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<MainController>(() => MainController());
}
