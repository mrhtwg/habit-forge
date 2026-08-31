import 'package:get/get.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/services/audio_service.dart';
import 'package:habit_forge_app/core/services/haptic_service.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';

class QuestsController extends GetxController {
  final _hive = NetworkRegistry.ins;

  final activeType = TaskType.TASK_TYPE_HABIT.obs;
  final activeTag = 'all'.obs;
  final showAll = false.obs;
  final selectedTask = Rxn<Task>();

  final tasks = <Task>[].obs;

  void getTasks() async {
    final result = await NetworkRegistry.ins.listTasks();
  }

  List<String> get availableTags {
    final tags = <String>{};
    for (final t in tasks) {
      tags.addAll(t.tags);
    }
    return tags.toList()..sort();
  }

  List<Task> get filteredTasks {
    Iterable<Task> list = showAll.value ? tasks : tasks.where((t) => t.type == activeType.value);
    if (activeTag.value != 'all') {
      list = list.where((t) => t.tags.contains(activeTag.value));
    }
    return list.toList();
  }

  Future<void> createTask(Task task) async {
    await NetworkRegistry.ins.createTask(task);
  }

  Future<void> deleteTask(String id) async {
    await _hive.deleteTask(id);
  }

  Future<void> onTaskPostpone(Task task) async {
    await _hive.postponeTask(task.id);
  }

  Future<void> toggleComplete(Task task) async {
    if (task.isCompleted) return;
    final result = await _hive.completeTask(task.id);

    // Trigger audio/haptic feedback
    final audio = Get.find<AudioService>();
    final haptic = Get.find<HapticService>();
    audio.playComplete();
    haptic.success();

    // RewardPopup.show(
    //   expGained: result.expGained,
    //   goldGained: result.goldGained,
    //   newLevel: result.newLevel,
    // );
    // if (result.newLevel != null) {
    //   audio.playLevelUp();
    //   haptic.heavy();
    // }
  }

  Future<void> toggleSkip(Task task) async {
    await _hive.skipTask(task.id);
  }

  Future<void> updateTask(String id, Task task) async {
    await _hive.updateTask(id, task);
  }
}
