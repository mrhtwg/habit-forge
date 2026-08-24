import 'package:get/get.dart';
import 'package:habit_forge_app/features/boarding/controllers/boarding_controller.dart';

class BoardBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<BoardingController>(() => BoardingController());
}
