import 'package:carousel_slider/carousel_controller.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
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
    final result = await NetworkRegistry.ins.createCharacter(selectedClass.value);
    if (result.isFailure) {
      Toast.error(result.message);
      return;
    }
    UserService.to.saveCharacter(result.data!.character);

    if (firstHabitTitle.value.isNotEmpty) {
      final result = await NetworkRegistry.ins.createTask(
        Task(
          title: firstHabitTitle.value,
          type: TaskType.TASK_TYPE_HABIT,
          difficulty: TaskDifficulty.TASK_DIFFICULTY_EASY,
        ),
      );
      if (result.isFailure) {
        Toast.error(result.message);
        return;
      }
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
