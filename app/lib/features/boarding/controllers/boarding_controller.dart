import 'package:carousel_slider/carousel_controller.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/interface/network_registry.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/widgets/toast_widget.dart';

class BoardingController extends GetxController {
  final totalStepsCount = 4;
  final _step = 0.obs;
  final selectedClass = CharacterClass.CHARACTER_CLASS_WARRIOR.obs;
  final firstHabitTitle = ''.obs;
  final CarouselSliderController carouselController = CarouselSliderController();

  final showLevelUpOnReadyStep = false.obs;

  int get currentStep => _step.value;

  void complete() async {
    final character = await NetworkRegistry.ins.createCharacter(selectedClass.value);
    if (!character.$2) {
      Toast.show('character_creation_failed'.tr); //TODO: Localize
      return;
    }
    UserService.to.saveCharacter(character.$1);

    if (firstHabitTitle.value.isNotEmpty) {
      final task = Task(
        title: firstHabitTitle.value,
        type: TaskType.TASK_TYPE_HABIT,
        difficulty: TaskDifficulty.TASK_DIFFICULTY_EASY,
      );
      await NetworkRegistry.ins.createTask(task);
    }

    Get.offNamed(Routers.main);
  }

  void nextStep() {
    if (_step.value < totalStepsCount - 1) {
      _step.value++;
    }
  }

  void preStep() {
    if (_step.value > 0) {
      _step.value--;
    }
  }

  void selectClass(CharacterClass c) => selectedClass.value = c;

  void selectHabit(String title) => firstHabitTitle.value = title;

  void skip() {
    NetworkRegistry.ins.createCharacter(CharacterClass.CHARACTER_CLASS_WARRIOR);
    Get.offNamed(Routers.main);
  }
}
