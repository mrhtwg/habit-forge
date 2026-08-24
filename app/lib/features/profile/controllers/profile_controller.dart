import 'package:get/get.dart';
import 'package:habit_forge_app/core/services/hive_service.dart';

class ProfileController extends GetxController {
  final _hive = HiveService.to;

  double get completionRate {
    final total = _hive.tasks.length;
    if (total == 0) return 0;
    final completed = _hive.tasks.where((t) => t.isCompleted).length;
    return completed / total;
  }

  int get currentGold => _hive.userPrefs.value?.currentGold ?? 0;
  int get currentLevel => _hive.character.value?.level ?? 1;
  int get maxStreak => _hive.tasks.fold(0, (max, t) => t.streak > max ? t.streak : max);

  int get totalTasksCompleted => _hive.userPrefs.value?.totalTasksCompleted ?? 0;
}
