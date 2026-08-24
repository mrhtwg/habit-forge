import 'package:get/get.dart';
import 'package:habit_forge_app/features/character/controllers/character_controller.dart';

class CharacterBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<CharacterController>(() => CharacterController());
}
