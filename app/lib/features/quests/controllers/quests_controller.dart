import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/utils/log.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/services/audio_service.dart';
import 'package:habit_forge_app/core/services/haptic_service.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';

class QuestsController extends GetxController {
  final _hive = NetworkRegistry.ins;

  final activeType = TaskType.TASK_TYPE_HABIT.obs;
  final activeTag = 'all'.obs;
  final showAll = false.obs;
  final selectedTask = Rxn<Task>();

  final tasks = <Task>[].obs;

  @override
  void onInit() {
    super.onInit();
    getTasks();
  }

  void getTasks() async {
    final result = await NetworkRegistry.ins.listTasks();
    result.when(
      onSuccess: (reply) => tasks.value = reply.tasks,
      onFailure: (code, msg) => Log.w('getTasks failed: $msg'),
    );
  }

  List<String> get availableTags {
    final tags = <String>{};
    for (final t in tasks) {
      tags.addAll(t.tags);
    }
    return tags.toList()..sort();
  }

  /// Tasks of one category (null = all types), further filtered by the
  /// active tag chip. Used by the swipeable category pages.
  List<Task> tasksFor(TaskType? type) {
    Iterable<Task> list = type == null ? tasks : tasks.where((t) => t.type == type);
    if (activeTag.value != 'all') {
      list = list.where((t) => t.tags.contains(activeTag.value));
    }
    return list.toList();
  }

  Future<void> createTask(Task task) async {
    await NetworkRegistry.ins.createTask(task);
    getTasks();
  }

  Future<void> deleteTask(String id) async {
    await _hive.deleteTask(id);
    getTasks();
  }

  /// Skips the task (marked skipped; todos get due date pushed to tomorrow).
  Future<void> onTaskPostpone(Task task) async {
    await _hive.skipTask(task.id);
    getTasks();
  }

  Future<void> toggleComplete(Task task) async {
    if (task.isCompleted) return;
    final result = await _hive.completeTask(task.id);
    if (result.isFailure) return;

    // Refresh the shared mirrors (wallet + character EXP/level) and the list.
    UserService.to.loadUserPrefs();
    UserService.to.loadCharacter();
    getTasks();

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
    getTasks();
  }

  Future<void> updateTask(String id, Task task) async {
    await _hive.updateTask(id, task);
    getTasks();
  }
}
