import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/network/hive/game_logic.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';

extension TaskDifficultyX on TaskDifficulty {
  String get difficultyName {
    switch (this) {
      case TaskDifficulty.TASK_DIFFICULTY_EASY:
        return LanKey.difficultyEasy.tr;
      case TaskDifficulty.TASK_DIFFICULTY_MEDIUM:
        return LanKey.difficultyMedium.tr;
      case TaskDifficulty.TASK_DIFFICULTY_HARD:
        return LanKey.difficultyHard.tr;
      default:
        return 'Unknown';
    }
  }
}

extension TaskTypeX on TaskType {
  String get taskName {
    switch (this) {
      case TaskType.TASK_TYPE_DAILY:
        return LanKey.daily.tr;
      case TaskType.TASK_TYPE_TODO:
        return LanKey.todo.tr;
      case TaskType.TASK_TYPE_HABIT:
        return LanKey.habit.tr;
      default:
        return 'Unknown';
    }
  }
}

extension TaskX on Task {
  bool get isDueToday {
    return GameLogic.isDueOn(this, DateTime.now());
  }
}
