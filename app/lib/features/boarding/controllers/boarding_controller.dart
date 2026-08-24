import 'package:carousel_slider/carousel_controller.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/constants/app_constants.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/services/hive_service.dart';
import 'package:habit_forge_app/generated/assets.dart';
import 'package:habit_forge_app/models/character/character_model.dart';
import 'package:habit_forge_app/models/task/task_model.dart';
import 'package:habit_forge_app/models/user/user_prefs.dart';

class BoardingController extends GetxController {
  final _step = 0.obs;
  final selectedClass = CharacterClass.warrior.obs;
  final firstHabitTitle = ''.obs;
  final CarouselSliderController carouselController = CarouselSliderController();

  final showLevelUpOnReadyStep = false.obs;

  final List<String> classImages = [
    Assets.imagesSharedWarrior,
    Assets.imagesSharedMage,
    Assets.imagesSharedRanger,
  ];
  int get currentStep => _step.value;

  void complete() {
    final prefs = UserPrefs(onboardingCompleted: true);
    HiveService.to.saveUserPrefs(prefs);

    final character = CharacterModel(
      id: 'default',
      characterClass: selectedClass.value,
      baseStats: _classStats(selectedClass.value.name),
    );
    HiveService.to.saveCharacter(character);

    if (firstHabitTitle.value.isNotEmpty) {
      final task = TaskModel(
        id: '',
        title: firstHabitTitle.value,
        type: TaskType.habit,
        difficulty: 'easy',
        createdAt: DateTime.now(),
      );
      HiveService.to.createTask(task);
    }

    Get.offNamed(Routers.main);
  }

  void nextStep() {
    if (_step.value < 3) {
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
    HiveService.to.saveUserPrefs(prefs);

    final character = CharacterModel(
      id: 'default',
      characterClass: selectedClass.value,
      baseStats: _classStats(selectedClass.value.name),
    );
    HiveService.to.saveCharacter(character);

    Get.offNamed(Routers.main);
  }

  CharacterStats _classStats(String cls) {
    switch (cls) {
      case 'warrior':
        return const CharacterStats(
          strength: 15,
          defense: 13,
          vitality: 12,
          intelligence: 8,
          agility: 10,
          luck: 8,
        );
      case 'mage':
        return const CharacterStats(
          strength: 7,
          defense: 8,
          vitality: 9,
          intelligence: 16,
          agility: 10,
          luck: 12,
        );
      case 'ranger':
        return const CharacterStats(
          strength: 10,
          defense: 9,
          vitality: 10,
          intelligence: 10,
          agility: 15,
          luck: 12,
        );
      default:
        return const CharacterStats();
    }
  }
}
