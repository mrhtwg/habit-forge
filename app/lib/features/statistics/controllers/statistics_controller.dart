import 'package:get/get.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';

class StatisticsController extends GetxController {
  final allTasks = <Task>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  /// Pulls every task once so the stats page has data to aggregate.
  Future<void> loadTasks() async {
    final result = await NetworkRegistry.ins.listTasks();
    if (result.isSuccess) {
      allTasks.value = result.data!.tasks;
    }
  }
}

enum TimePeriod { week, month, all }
