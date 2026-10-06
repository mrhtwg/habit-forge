import 'package:get/get.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/network/hive/game_logic.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/services/achievement_unlock_service.dart';
import 'package:habit_forge_app/core/services/audio_service.dart';
import 'package:habit_forge_app/core/services/haptic_service.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/features/rewards/reward_popup.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/widgets/toast_widget.dart';

class HomeController extends GetxController {
  final todayTasks = <Task>[].obs;

  void loadTodayTasks() async {
    final result = await NetworkRegistry.ins.listTasks(onlyDueToday: true);
    result.when(onSuccess: (reply) => todayTasks.value = reply.tasks, onFailure: (code, msg) => Toast.error(msg));
  }

  void onCharacterTap() {
    Get.toNamed(Routers.character);
  }

  @override
  void onInit() {
    super.onInit();
    loadTodayTasks();
  }

  Future<void> onTaskComplete(Task task) async {
    if (task.isCompleted) return;
    if (UserService.to.character.value?.isDead ?? false) {
      Toast.warning(LanKey.deathBlocked.tr);
      return;
    }
    // A negative habit ("bad habit") logs a slip: HP lost, nothing earned.
    final isSlip = GameLogic.isNegative(task);
    final hpBefore = UserService.to.character.value?.currentHp ?? 0;
    final levelBefore = UserService.to.character.value?.level ?? 1;
    final unlockedBefore = await AchievementUnlockService.snapshotUnlockedIds();
    final result = await NetworkRegistry.ins.completeTask(task.id);
    if (result.isFailure) {
      Toast.error(result.message);
      return;
    }

    final reply = result.data!;
    UserService.to.loadUserPrefs();
    UserService.to.loadCharacter();
    loadTodayTasks();

    if (isSlip) {
      // No reward popup and no achievement sweep: nothing was earned. A fatal slip
      // is surfaced by the death overlay (DeathRecoveryService).
      Get.find<AudioService>().playHpDamage();
      Get.find<HapticService>().error();
      Toast.warning(LanKey.slipLogged.trParams({'hp': '${hpBefore - reply.character.currentHp}'}));
      return;
    }

    if (reply.character.level > levelBefore) {
      Get.find<AudioService>().playLevelUp();
      Get.find<HapticService>().heavy();
    } else {
      Get.find<AudioService>().playComplete();
      Get.find<HapticService>().success();
    }
    await RewardPopup.showTaskReward(reply, levelBefore);

    final unlocked = await AchievementUnlockService.newlyUnlockedSince(unlockedBefore);
    if (unlocked.isNotEmpty) await UserService.to.loadUserPrefs();
    await AchievementUnlockService.presentUnlocks(unlocked);
  }

  Future<void> onTaskDelete(String id) async {
    final result = await NetworkRegistry.ins.deleteTask(id);
    if (result.isFailure) {
      Toast.error(result.message);
      return;
    }
    loadTodayTasks();
  }

  /// Skips the task (marked skipped; todos get due date pushed to tomorrow).
  Future<void> onTaskPostpone(Task task) async {
    await onTaskSkip(task);
  }

  Future<void> onTaskSkip(Task task) async {
    final result = await NetworkRegistry.ins.skipTask(task.id);
    if (result.isFailure) {
      Toast.error(result.message);
      return;
    }
    await UserService.to.loadCharacter();
    await UserService.to.loadUserPrefs();
    loadTodayTasks();
  }
}
