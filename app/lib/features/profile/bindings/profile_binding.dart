import 'package:get/get.dart';
import 'package:habit_forge_app/features/profile/controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<ProfileController>(() => ProfileController());
}
