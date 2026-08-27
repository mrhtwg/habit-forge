import 'package:fixnum/fixnum.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/extensions/task_extensions.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/services/hive_service.dart';
import 'package:habit_forge_app/features/main/controllers/main_controller.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';

class HomeController extends GetxController {
  final _hive = HiveService.to;

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
    final updated = task.rebuild((t) => t..isCompleted = true);
    _hive.updateTask(updated);
  }

  void onTaskDelete(String id) {
    _hive.deleteTask(id);
  }

  void onTaskPostpone(Task task) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final updated = task.rebuild(
      (t) => t
        ..isSkipped = true
        ..dueDate = task.type == TaskType.TASK_TYPE_TODO ? Int64(tomorrow.millisecondsSinceEpoch) : task.dueDate,
    );
    _hive.updateTask(updated);
  }

  void onTaskSkip(Task task) {
    final updated = task.rebuild((t) => t..isSkipped = true);
    _hive.updateTask(updated);
  }
}
