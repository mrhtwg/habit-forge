import 'package:fixnum/fixnum.dart';
import 'package:habit_forge_app/core/di/injection_container.dart';
import 'package:habit_forge_app/core/extensions/date_extensions.dart';
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
  static const _metaBoxKey = 'taskMetaBox';
  static const _penaltyDateKey = 'lastPenaltyDate';

  late Box _taskBox;
  late Box _metaBox;

  Future init() async {
    _taskBox = await Hive.openBox(_boxKey);
    _metaBox = await Hive.openBox(_metaBoxKey);
  }

  Task? getTask(String taskId) {
    _rolloverDay();
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
    _rolloverDay();
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
  /// Persists an edited task (id/timestamps kept by the caller's payload).
  Future<Task> updateTask(Task task) async {
    _taskBox.put(task.id, task.writeToBuffer());
    return task;
  }

  Future<Task> completeTask(Task task) async {
    final updated = GameLogic.completeTask(task);
    _taskBox.put(task.id, updated.writeToBuffer());
    return updated;
  }

  /// Skips the task (marked skipped; todos get their due date pushed to
  /// tomorrow) and persists it. Returns the updated task.
  Future<Task> skipTask(Task task) async {
    final updated = GameLogic.postpone(task);
    _taskBox.put(task.id, updated.writeToBuffer());
    return updated;
  }

  Future deleteTask(String taskId) async {
    _taskBox.delete(taskId);
  }

  /// Hive-mode overdue-penalty sweep, invoked once per calendar day at
  /// startup (the sweep date is persisted in the meta box). Every task that
  /// was due and left uncompleted *yesterday* deals its [Task.hpPenalty]
  /// damage; tasks completed yesterday and tasks explicitly skipped are
  /// exempt. One-off todos only count once their due date has passed.
  /// Missed days before yesterday (multi-day gaps) are forgiven. Returns the
  /// total damage to apply to the character (0 when already swept today).
  int collectOverduePenalty() {
    final now = DateTime.now();
    final today = now.dateOnly;
    if (_metaBox.get(_penaltyDateKey) == today.millisecondsSinceEpoch) return 0;
    _metaBox.put(_penaltyDateKey, today.millisecondsSinceEpoch);

    final yesterday = today.subtract(const Duration(days: 1));
    var damage = 0;
    for (final value in _taskBox.values) {
      final task = Task()..mergeFromBuffer(value);
      if (task.isSkipped) continue; // explicitly handled → exempt
      final completedAt = DateTime.fromMillisecondsSinceEpoch(task.completedAt.toInt()).dateOnly;
      if (task.isCompleted && completedAt.isSameDay(yesterday)) continue; // done yesterday
      if (task.type == TaskType.TASK_TYPE_TODO) {
        if (task.isCompleted) continue; // one-off, already done
        final dueDay = DateTime.fromMillisecondsSinceEpoch(task.dueDate.toInt()).dateOnly;
        final overdue = dueDay.isBefore(yesterday) || dueDay.isSameDay(yesterday);
        if (!overdue) continue;
      } else {
        final due = task.type == TaskType.TASK_TYPE_HABIT ||
            (task.type == TaskType.TASK_TYPE_DAILY && task.repeatDays.contains(yesterday.weekday));
        if (!due) continue;
      }
      damage += task.hpPenalty;
    }
    return damage;
  }

  /// Daily rollover: repeatable tasks (habits, and dailies due today) that
  /// were completed on a previous day are re-armed (isCompleted = false) so
  /// they can be completed again. Idempotent — runs lazily on every read;
  /// one-off todos keep their completion forever.
  void _rolloverDay() {
    final now = DateTime.now();
    for (final key in _taskBox.keys) {
      final task = Task()..mergeFromBuffer(_taskBox.get(key));
      if (!task.isCompleted) continue;
      if (DateTime.fromMillisecondsSinceEpoch(task.completedAt.toInt()).isToday) continue;
      final repeatable = task.type == TaskType.TASK_TYPE_HABIT ||
          (task.type == TaskType.TASK_TYPE_DAILY && task.repeatDays.contains(now.weekday));
      if (!repeatable) continue;
      final reset = (task.deepCopy()..freeze()).rebuild((t) => t..isCompleted = false);
      _taskBox.put(key, reset.writeToBuffer());
    }
  }

  void clear() {
    _taskBox.clear();
    _metaBox.clear();
  }
}
