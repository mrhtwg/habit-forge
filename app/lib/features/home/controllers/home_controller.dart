import 'package:get/get.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/features/rewards/reward_popup.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/widgets/toast_widget.dart';

class HomeController extends GetxController {
  final todayTasks = <Task>[].obs;

  void loadTodayTasks() async {
    final result = await NetworkRegistry.ins.listTasks();
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

  void onTaskComplete(Task task) async {
    final levelBefore = UserService.to.character.value?.level ?? 1;
    final result = await NetworkRegistry.ins.completeTask(task.id);
    result.when(
      onSuccess: (reply) {
        // Refresh wallet / character / list so the home header (gold chip,
        // EXP bar) animates to the new values.
        UserService.to.loadUserPrefs();
        UserService.to.loadCharacter();
        loadTodayTasks();
        // Congratulate the player (task rewards / level-up card).
        RewardPopup.showTaskReward(reply, levelBefore);
      },
      onFailure: (code, msg) => Toast.error(msg),
    );
  }

  Future<void> onTaskDelete(String id) async {
    await NetworkRegistry.ins.deleteTask(id);
    loadTodayTasks();
  }

  /// Skips the task (marked skipped; todos get due date pushed to tomorrow).
  Future<void> onTaskPostpone(Task task) async {
    await NetworkRegistry.ins.skipTask(task.id);
    loadTodayTasks();
  }

  Future<void> onTaskSkip(Task task) async {
    await NetworkRegistry.ins.skipTask(task.id);
    loadTodayTasks();
  }
}
