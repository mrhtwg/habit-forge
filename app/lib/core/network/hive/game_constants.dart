import 'dart:math';

import 'package:habit_forge_app/generated/protos/task/v1/task.pbenum.dart';

class GameConstants {
  static const int maxLevel = 50;
  static const int maxHp = 100;
  static const int initialHp = 100;
  static const int deathRecoveryMinutes = 30;
  static const int deathRecoveryHp = 50;
  static const int statPointsPerLevel = 1;
  GameConstants._();

  static int baseExpReward(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.TASK_DIFFICULTY_EASY:
        return 15;
      case TaskDifficulty.TASK_DIFFICULTY_MEDIUM:
        return 30;
      case TaskDifficulty.TASK_DIFFICULTY_HARD:
        return 50;
      default:
        return 15;
    }
  }

  static int baseGoldReward(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.TASK_DIFFICULTY_EASY:
        return 5;
      case TaskDifficulty.TASK_DIFFICULTY_MEDIUM:
        return 10;
      case TaskDifficulty.TASK_DIFFICULTY_HARD:
        return 20;
      default:
        return 5;
    }
  }

  static int calculateLevel(int totalExp) {
    int level = 1;
    for (int i = 1; i <= maxLevel; i++) {
      final needed = expForLevel(i);
      if (totalExp < needed) return level;
      totalExp -= needed;
      level = i + 1;
    }
    return maxLevel;
  }

  static int expForLevel(int level) {
    return 100 + (level - 1) * 50 + pow(level - 1, 2).toInt() * 10;
  }

  static int expProgress(int currentExp, int level) {
    final needed = expForLevel(level);
    return (currentExp * 100 / needed).round();
  }

  static double streakMultiplier(int streak) {
    return min(2.0, 1.0 + streak * 0.02);
  }
}
