import 'package:get/get.dart';
import 'package:habit_forge_app/core/extensions/task_extensions.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/storage/storage_service.dart';
import 'package:habit_forge_app/features/main/controllers/main_controller.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';

class HomeController extends GetxController {
  final _hive = StorageService.to;

  // Completed tasks stay in the list, rendered ticked — the checkmark is the only
  // completion feedback (no popup/message).
  List<Task> get todayTasks => _hive.tasks.where((t) => !t.isSkipped && t.isDueToday).toList();

  get tasktype => null;

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
    _hive.completeTask(task);
  }

  void onTaskDelete(String id) {
    _hive.deleteTask(id);
  }

  void onTaskPostpone(Task task) {
    _hive.postponeTask(task);
  }

  void onTaskSkip(Task task) {
    _hive.skipTask(task);
  }
}
