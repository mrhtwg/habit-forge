import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';

extension TaskX on Task {
  bool get isDueToday {
    if (type == TaskType.TASK_TYPE_DAILY) {
      final today = DateTime.now().weekday - 1;
      return repeatDays.contains(today);
    }
    if (type == TaskType.TASK_TYPE_TODO) {
      final now = DateTime.now();
      return DateTime(dueDate.toInt()).isBefore(now.add(const Duration(days: 1)));
    }
    return type == TaskType.TASK_TYPE_HABIT;
  }
}
