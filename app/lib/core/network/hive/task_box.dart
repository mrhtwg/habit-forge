import 'package:fixnum/fixnum.dart';
import 'package:habit_forge_app/core/di/injection_container.dart';
import 'package:habit_forge_app/core/network/hive/game_logic.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@singleton
class TaskBox {
  static TaskBox get ins => getIt<TaskBox>();

  TaskBox();

  final _boxKey = 'taskBox';

  late Box _taskBox;

  Future init() async {
    _taskBox = await Hive.openBox(_boxKey);
  }

  Task? getTask(String taskId) {
    final raw = _taskBox.get(taskId);
    if (raw == null) {
      return null;
    }
    final task = raw == null ? null : Task()
      ?..mergeFromBuffer(raw);
    return task;
  }

  List<Task> listTasks({
    TaskType? type,
    TaskDifficulty? difficulty,
    List<String>? tags,
    bool? onlyDueToday,
  }) {
    final _tasks = _taskBox.values.map((e) => Task()..mergeFromBuffer(e)).where((task) {
      if (type != null && task.type != type) {
        return false;
      }
      if (difficulty != null && task.difficulty != difficulty) {
        return false;
      }
      if (tags != null && !tags.every(task.tags.contains)) {
        return false;
      }
      if (onlyDueToday != null && onlyDueToday == true) {
        switch (task.type) {
          case TaskType.TASK_TYPE_HABIT:
            return true;
          case TaskType.TASK_TYPE_DAILY:
            return task.repeatDays.contains(DateTime.now().weekday);
          case TaskType.TASK_TYPE_TODO:
            return DateTime.fromMillisecondsSinceEpoch(task.dueDate.toInt()) == DateTime.now().day &&
                DateTime.fromMillisecondsSinceEpoch(task.dueDate.toInt()).month == DateTime.now().month &&
                DateTime.fromMillisecondsSinceEpoch(task.dueDate.toInt()).year == DateTime.now().year;
        }

        return false;
      }
      return true;
    }).toList();
    _tasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return _tasks;
  }

  Future<Task> createTask(Task task) async {
    Task t = Task()
      ..id = Uuid().v4()
      ..title = task.title
      ..description = task.description
      ..type = task.type
      ..difficulty = task.difficulty
      ..streak = task.streak
      ..customExpReward = task.customExpReward
      ..customGoldReward = task.customGoldReward
      ..priority = task.priority
      ..hpPenalty = task.hpPenalty
      ..createdAt = Int64(DateTime.now().millisecondsSinceEpoch)
      ..updatedAt = Int64(DateTime.now().millisecondsSinceEpoch);

    t.tags.addAll(task.tags);
    if (task.type == TaskType.TASK_TYPE_DAILY) {
      t.repeatDays.addAll(task.repeatDays);
    }
    if (task.type == TaskType.TASK_TYPE_TODO) {
      t.dueDate = task.dueDate;
    }

    _taskBox.put(t.id, t.writeToBuffer());
    return t;
  }

  /// Marks the task complete: applies the streak rule, completion timestamps
  /// and persists the updated task. Returns the completed task.
  Future<Task> completeTask(Task task) async {
    final updated = GameLogic.completeTask(task);
    _taskBox.put(task.id, updated.writeToBuffer());
    return updated;
  }

  Future deleteTask(String taskId) async {
    _taskBox.delete(taskId);
  }

  void clear() {
    _taskBox.clear();
  }
}
