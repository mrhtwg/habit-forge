import 'package:get/get.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/services/audio_service.dart';
import 'package:habit_forge_app/core/services/haptic_service.dart';
import 'package:habit_forge_app/features/rewards/reward_popup.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';

class QuestsController extends GetxController {
  final _hive = NetworkRegistry.ins;
  final activeType = TaskType.TASK_TYPE_HABIT.obs;
  final activeTag = 'all'.obs;
  final showAll = false.obs;
  final selectedTask = Rxn<Task>();

  List<String> get availableTags {
    final tags = <String>{};
    for (final t in _hive.tasks) {
      tags.addAll(t.tags);
    }
    return tags.toList()..sort();
  }

  List<Task> get filteredTasks {
    Iterable<Task> list = showAll.value ? _hive.tasks : _hive.tasks.where((t) => t.type == activeType.value);
    if (activeTag.value != 'all') {
      list = list.where((t) => t.tags.contains(activeTag.value));
    }
    return list.toList();
  }

  void createTask(Task task) {
    NetworkRegistry.ins.createTask(task);
  }

  void deleteTask(String id) {
    _hive.deleteTask(id);
  }

  void onTaskPostpone(Task task) {
    _hive.postponeTask(task);
  }

  Future<void> toggleComplete(Task task) async {
    if (task.isCompleted) return;
    final result = await _hive.completeTask(task);

    // Trigger audio/haptic feedback
    final audio = Get.find<AudioService>();
    final haptic = Get.find<HapticService>();
    audio.playComplete();
    haptic.success();

    RewardPopup.show(
      expGained: result.expGained,
      goldGained: result.goldGained,
      newLevel: result.newLevel,
    );
    if (result.newLevel != null) {
      audio.playLevelUp();
      haptic.heavy();
    }
  }

  void toggleSkip(Task task) {
    _hive.skipTask(task);
  }

  void updateTask(Task task) {
    _hive.updateTask(task);
  }
}
