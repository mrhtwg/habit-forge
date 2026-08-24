import 'package:get/get.dart';
import 'package:habit_forge_app/features/home/controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<HomeController>(() => HomeController());
}
