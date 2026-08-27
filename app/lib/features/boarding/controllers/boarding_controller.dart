import 'package:carousel_slider/carousel_controller.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/storage/storage_service.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';

class BoardingController extends GetxController {
  final totalStepsCount = 4;
  final _step = 0.obs;
  final selectedClass = CharacterClass.CHARACTER_CLASS_WARRIOR.obs;
  final firstHabitTitle = ''.obs;
  final CarouselSliderController carouselController = CarouselSliderController();

  final showLevelUpOnReadyStep = false.obs;

  int get currentStep => _step.value;

  void complete() {
    final prefs = UserPrefs(onboardingCompleted: true);
    StorageService.to.saveUserPrefs(prefs);

    final character = Character(
      id: 'default',
      characterClass: selectedClass.value,
    );
    StorageService.to.createCharacter(character);

    if (firstHabitTitle.value.isNotEmpty) {
      final task = Task(
        id: '',
        title: firstHabitTitle.value,
        type: TaskType.TASK_TYPE_HABIT,
        difficulty: TaskDifficulty.TASK_DIFFICULTY_EASY,
        // createdAt: DateTime.now(),
      );
      StorageService.to.createTask(task);
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
    final prefs = UserPrefs(onboardingCompleted: true);
    StorageService.to.saveUserPrefs(prefs);

    final character = Character(
      id: 'default',
      characterClass: selectedClass.value,
    );
    StorageService.to.createCharacter(character);

    Get.offNamed(Routers.main);
  }
}
