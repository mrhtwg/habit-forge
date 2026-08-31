import 'package:get/get.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/features/main/controllers/main_controller.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/widgets/toast_widget.dart';

class HomeController extends GetxController {
  final todayTasks = <Task>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTodayTasks();
  }

  void loadTodayTasks() async {
    final result = await NetworkRegistry.ins.listTasks();
    result.when(onSuccess: (reply) => todayTasks.value = reply.tasks, onFailure: (code, msg) => Toast.error(msg));
  }

  void onCharacterTap() {
    Get.toNamed(Routers.character);
  }

  void onQuickAction(String action) {
    switch (action) {
      case 'shop':
        Get.find<MainController>().onTabChanged(2);
        break;
      case 'stats':
        Get.toNamed(Routers.statistics);
        break;
      case 'achieve':
        Get.toNamed(Routers.achievements);
        break;
    }
  }

  void onTaskComplete(Task task) {
    NetworkRegistry.ins.completeTask(task.id);
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
