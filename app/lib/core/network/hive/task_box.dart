import 'package:fixnum/fixnum.dart';
import 'package:habit_forge_app/core/common/utils/log.dart';
import 'package:habit_forge_app/core/di/injection_container.dart';
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
    Log.d('listTasks $type $difficulty $tags $onlyDueToday');
    final _tasks = _taskBox.values.map((e) => Task()..mergeFromBuffer(e)).where((task) {
      return true;
    }).toList();

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

  Future completeTask(Task task) async {
    task.isCompleted = true;
    task.completedAt = Int64(DateTime.now().millisecondsSinceEpoch);
    task.updatedAt = Int64(DateTime.now().millisecondsSinceEpoch);
    _taskBox.put(task.id, task.writeToBuffer());
  }

  Future deleteTask(String taskId) async {
    _taskBox.delete(taskId);
  }

  void clear() {
    _taskBox.clear();
  }
}
