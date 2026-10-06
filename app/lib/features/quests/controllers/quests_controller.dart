import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/utils/log.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/network/hive/game_logic.dart';
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
    final result = await NetworkRegistry.ins.createTask(task);
    if (result.isFailure) {
      Toast.error(result.message);
      return false;
    }
    getTasks();
    return true;
  }

  Future<void> deleteTask(String id) async {
    final result = await _hive.deleteTask(id);
    if (result.isFailure) {
      Toast.error(result.message);
      return;
    }
    getTasks();
  }

  Future<void> onTaskPostpone(Task task) async {
    await toggleSkip(task);
  }

  Future<void> toggleComplete(Task task) async {
    if (task.isCompleted) return;
    if (UserService.to.character.value?.isDead ?? false) {
      Toast.warning(LanKey.deathBlocked.tr);
      return;
    }
    // A negative habit is a "bad habit": tapping it logs a slip, which costs HP
    // instead of granting a reward (see GameLogic.isNegative).
    final isSlip = GameLogic.isNegative(task);
    final hpBefore = UserService.to.character.value?.currentHp ?? 0;
    final levelBefore = UserService.to.character.value?.level ?? 1;
    final unlockedBefore = await AchievementUnlockService.snapshotUnlockedIds();
    final result = await _hive.completeTask(task.id);
    if (result.isFailure) {
      Toast.error(result.message);
      return;
    }

    UserService.to.loadUserPrefs();
    UserService.to.loadCharacter();
    getTasks();

    final audio = Get.find<AudioService>();
    final haptic = Get.find<HapticService>();

    if (isSlip) {
      // No reward popup and no achievement sweep: nothing was earned. A fatal slip
      // is handled by the death overlay (DeathRecoveryService) on top of this.
      final lost = hpBefore - result.data!.character.currentHp;
      audio.playHpDamage();
      haptic.error();
      Toast.warning(LanKey.slipLogged.trParams({'hp': '$lost'}));
      return;
    }

    final reply = result.data!;
    final leveledUp = reply.character.level > levelBefore;
    if (leveledUp) {
      audio.playLevelUp();
      haptic.heavy();
    } else {
      audio.playComplete();
      haptic.success();
    }
    await RewardPopup.showTaskReward(reply, levelBefore);

    final unlocked = await AchievementUnlockService.newlyUnlockedSince(unlockedBefore);
    // Gem rewards may have been applied — refresh wallet chips.
    if (unlocked.isNotEmpty) await UserService.to.loadUserPrefs();
    await AchievementUnlockService.presentUnlocks(unlocked);
  }

  Future<void> toggleSkip(Task task) async {
    final result = await _hive.skipTask(task.id);
    if (result.isFailure) {
      Toast.error(result.message);
      return;
    }
    await UserService.to.loadCharacter();
    await UserService.to.loadUserPrefs();
    getTasks();
  }

  Future<bool> updateTask(String id, Task task) async {
    final current = tasks.firstWhereOrNull((candidate) => candidate.id == id);
    if (task.type == TaskType.TASK_TYPE_HABIT &&
        current?.type != TaskType.TASK_TYPE_HABIT &&
        !SubscriptionService.to.canCreateHabit(habitCount)) {
      Toast.warning(LanKey.habitLimitReached.trParams({'n': '${SubscriptionLimits.freeHabitSlots}'}));
      return false;
    }
    final result = await _hive.updateTask(id, task);
    if (result.isFailure) {
      Toast.error(result.message);
      return false;
    }
    getTasks();
    return true;
  }
}
