import 'package:get/get.dart';
import 'package:habit_forge_app/core/constants/app_constants.dart';
import 'package:habit_forge_app/core/constants/game_constants.dart';
import 'package:habit_forge_app/core/extensions/date_extensions.dart';
import 'package:habit_forge_app/core/services/audio_service.dart';
import 'package:habit_forge_app/core/services/haptic_service.dart';
import 'package:habit_forge_app/core/services/hive_service.dart';
import 'package:habit_forge_app/features/character/controllers/character_controller.dart';
import 'package:habit_forge_app/features/rewards/reward_popup.dart';
import 'package:habit_forge_app/models/task/task_model.dart';
import 'package:habit_forge_app/models/user/user_prefs.dart';

class QuestsController extends GetxController {
  final _hive = HiveService.to;
  final activeType = TaskType.habit.obs; // 'habit' | 'daily' | 'todo'
  final activeTag = 'all'.obs;
  final showAll = false.obs;
  final selectedTask = Rxn<TaskModel>();

  List<String> get availableTags {
    final tags = <String>{};
    for (final t in _hive.tasks) {
      tags.addAll(t.tags);
    }
    return tags.toList()..sort();
  }

  List<TaskModel> get filteredTasks {
    Iterable<TaskModel> list =
        showAll.value ? _hive.tasks : _hive.tasks.where((t) => t.type == activeType.value);
    if (activeTag.value != 'all') {
      list = list.where((t) => t.tags.contains(activeTag.value));
    }
    return list.toList();
  }

  void createTask(TaskModel task) {
    _hive.createTask(task);
  }

  void deleteTask(String id) {
    _hive.deleteTask(id);
  }

  void onTaskPostpone(TaskModel task) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final updated = task.copyWith(
      isSkipped: true,
      dueDate: task.type == 'todo' ? tomorrow : task.dueDate,
      updatedAt: DateTime.now(),
    );
    _hive.updateTask(updated);
  }

  int taskRewardExp(TaskModel task) {
    if (task.customExpReward > 0) return task.customExpReward;
    final base = GameConstants.baseExpReward(task.difficulty);
    return (base * GameConstants.streakMultiplier(task.streak)).round();
  }

  int taskRewardGold(TaskModel task) {
    if (task.customGoldReward > 0) return task.customGoldReward;
    return GameConstants.baseGoldReward(task.difficulty);
  }

  void toggleComplete(TaskModel task) {
    if (task.isCompleted) return;
    final now = DateTime.now();
    final expReward = taskRewardExp(task);
    final goldReward = taskRewardGold(task);

    // Update streak
    int newStreak = task.streak;
    if (task.lastStreakDate != null && task.lastStreakDate!.isToday) {
      // Already completed today, maintain streak
    } else {
      newStreak++;
    }

    final updated = task.copyWith(
      isCompleted: true,
      completedAt: now,
      streak: newStreak,
      lastStreakDate: now,
    );
    _hive.updateTask(updated);

    // Apply rewards
    final prefs = _hive.userPrefs.value ?? const UserPrefs();
    _hive.saveUserPrefs(
      prefs.copyWith(
        currentGold: prefs.currentGold + goldReward,
        totalTasksCompleted: prefs.totalTasksCompleted + 1,
      ),
    );

    // Apply exp to character
    final char = _hive.character.value;
    if (char != null) {
      final newExp = char.currentExp + expReward;
      _hive.saveCharacter(char.copyWith(currentExp: newExp));
    }

    // Trigger audio/haptic feedback
    final audio = Get.find<AudioService>();
    final haptic = Get.find<HapticService>();
    audio.playComplete();
    haptic.success();

    // Check level-up and show reward popup
    final charCtrl = Get.find<CharacterController>();
    final newLevel = charCtrl.checkLevelUp();
    RewardPopup.show(
      expGained: expReward,
      goldGained: goldReward,
      newLevel: newLevel > 0 ? newLevel : null,
    );
    if (newLevel > 0) {
      audio.playLevelUp();
      haptic.heavy();
    }
  }

  void toggleSkip(TaskModel task) {
    final updated = task.copyWith(isSkipped: !task.isSkipped, updatedAt: DateTime.now());
    _hive.updateTask(updated);
  }

  void updateTask(TaskModel task) {
    _hive.updateTask(task);
  }
}
