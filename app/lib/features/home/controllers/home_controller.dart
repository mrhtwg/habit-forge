import 'package:get/get.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
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
    final result = await NetworkRegistry.ins.completeTask(task.id);
    result.when(
      onSuccess: (reply) {
        // Refresh wallet / character / list so the home header (gold chip,
        // EXP bar) animates to the new values.
        UserService.to.loadUserPrefs();
        UserService.to.loadCharacter();
        loadTodayTasks();
      },
      onFailure: (code, msg) => Toast.error(msg),
    );
  }

  void onTaskDelete(String id) {
    NetworkRegistry.ins.deleteTask(id);
  }

  void onTaskPostpone(Task task) {
    NetworkRegistry.ins.postponeTask(task.id);
  }

  void onTaskSkip(Task task) {
    NetworkRegistry.ins.skipTask(task.id);
  }
}
