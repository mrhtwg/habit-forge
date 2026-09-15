import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/utils/log.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/services/audio_service.dart';
import 'package:habit_forge_app/core/services/achievement_unlock_service.dart';
import 'package:habit_forge_app/core/services/haptic_service.dart';
import 'package:habit_forge_app/core/services/subscription_service.dart';
import 'package:habit_forge_app/core/services/subscription_tier.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/features/rewards/reward_popup.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/widgets/toast_widget.dart';

class QuestsController extends GetxController {
  final _hive = NetworkRegistry.ins;

  final activeType = TaskType.TASK_TYPE_HABIT.obs;
  final activeTag = 'all'.obs;
  final showAll = false.obs;
  final selectedTask = Rxn<Task>();

  final tasks = <Task>[].obs;

  int get habitCount => tasks.where((t) => t.type == TaskType.TASK_TYPE_HABIT).length;

  @override
  void onInit() {
    super.onInit();
    getTasks();
  }

  void getTasks() async {
    final result = await NetworkRegistry.ins.listTasks();
    result.when(
      onSuccess: (reply) => tasks.value = reply.tasks,
      onFailure: (code, msg) => Log.w('getTasks failed: $msg'),
    );
  }

  List<String> get availableTags {
    final tags = <String>{};
    for (final t in tasks) {
      tags.addAll(t.tags);
    }
    return tags.toList()..sort();
  }

  List<Task> tasksFor(TaskType? type) {
    Iterable<Task> list = type == null ? tasks : tasks.where((t) => t.type == type);
    if (activeTag.value != 'all') {
      list = list.where((t) => t.tags.contains(activeTag.value));
    }
    return list.toList();
  }

  /// Returns false when freemium habit-slot gate blocks creation.
  Future<bool> createTask(Task task) async {
    if (task.type == TaskType.TASK_TYPE_HABIT) {
      if (!SubscriptionService.to.canCreateHabit(habitCount)) {
        Toast.warning(
          LanKey.habitLimitReached.trParams({'n': '${SubscriptionLimits.freeHabitSlots}'}),
        );
        Get.toNamed(Routers.subscription);
        return false;
      }
    }
    await NetworkRegistry.ins.createTask(task);
    getTasks();
    return true;
  }

  Future<void> deleteTask(String id) async {
    await _hive.deleteTask(id);
    getTasks();
  }

  Future<void> onTaskPostpone(Task task) async {
    await _hive.skipTask(task.id);
    getTasks();
  }

  Future<void> toggleComplete(Task task) async {
    if (task.isCompleted) return;
    final levelBefore = UserService.to.character.value?.level ?? 1;
    final unlockedBefore = await AchievementUnlockService.snapshotUnlockedIds();
    final result = await _hive.completeTask(task.id);
    if (result.isFailure) return;

    UserService.to.loadUserPrefs();
    UserService.to.loadCharacter();
    getTasks();

    final audio = Get.find<AudioService>();
    final haptic = Get.find<HapticService>();
    audio.playComplete();
    haptic.success();

    final reply = result.data!;
    final leveledUp = reply.character.level > levelBefore;
    await RewardPopup.showTaskReward(reply, levelBefore);
    if (leveledUp) {
      audio.playLevelUp();
      haptic.heavy();
    }

    final unlocked = await AchievementUnlockService.newlyUnlockedSince(unlockedBefore);
    // Gem rewards may have been applied — refresh wallet chips.
    if (unlocked.isNotEmpty) await UserService.to.loadUserPrefs();
    await AchievementUnlockService.presentUnlocks(unlocked);
  }

  Future<void> toggleSkip(Task task) async {
    await _hive.skipTask(task.id);
    getTasks();
  }

  Future<void> updateTask(String id, Task task) async {
    await _hive.updateTask(id, task);
    getTasks();
  }
}
