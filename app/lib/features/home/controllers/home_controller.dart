import 'package:get/get.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/services/hive_service.dart';
import 'package:habit_forge_app/features/main/controllers/main_controller.dart';
import 'package:habit_forge_app/models/task/task_model.dart';

class HomeController extends GetxController {
  final _hive = HiveService.to;

  // Completed tasks stay in the list, rendered ticked — the checkmark is the only
  // completion feedback (no popup/message).
  List<TaskModel> get todayTasks => _hive.tasks.where((t) => !t.isSkipped && t.isDueToday).toList();

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

  void onTaskComplete(TaskModel task) {
    final updated = task.copyWith(isCompleted: true, completedAt: DateTime.now());
    _hive.updateTask(updated);
  }

  void onTaskDelete(String id) {
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

  void onTaskSkip(TaskModel task) {
    final updated = task.copyWith(isSkipped: true, updatedAt: DateTime.now());
    _hive.updateTask(updated);
  }
}
