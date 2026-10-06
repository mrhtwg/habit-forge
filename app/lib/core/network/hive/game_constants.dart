import 'dart:math';

import 'package:habit_forge_app/generated/protos/task/v1/task.pbenum.dart';

class GameConstants {
  /// Version of the reward / level / HP formulas in this build.
  ///
  /// Every ledger row records it (`docs/data-ledger-plan.md` §6.2), so a future
  /// server-side replay can tell which rules produced a number: rows written
  /// before a rebalance stay interpretable. Bump it whenever a formula here or
  /// in `ClassProfiles` changes.
  static const String rulesVersion = '2026.09';

  static const int maxLevel = 50;
  static const int maxHp = 100;

  /// HP cap of a character with the given VIT: base 100 + 2 per point.
  static int maxHpFor(int vitality) => maxHp + vitality * 2;

  static const int deathRecoveryMinutes = 30;
  static const int deathRecoveryHp = 50;
  static const int completeTaskAddHp = 20;
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

  /// HP a negative habit costs per logged slip when the task carries no explicit
  /// `hpPenalty`. Mirrors the gold table on purpose: a habit that is twice as
  /// hard to kick should bite twice as hard.
  static int defaultHpPenalty(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.TASK_DIFFICULTY_EASY:
        return 5;
      case TaskDifficulty.TASK_DIFFICULTY_MEDIUM:
        return 10;
      case TaskDifficulty.TASK_DIFFICULTY_HARD:
        return 20;
      default:
        return 10;
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

  /// Lifetime EXP represented by [level] plus the progress inside it — the
  /// inverse of [progressForLifetimeExp].
  ///
  /// Needed wherever two saves' progress has to be added before it can be turned
  /// back into a single level (the account merge, `ProgressMergeService`).
  static int lifetimeExpOf(int level, int currentExp) {
    var total = 0;
    for (var i = 1; i < level && i <= maxLevel; i++) {
      total += expForLevel(i);
    }
    return total + (currentExp < 0 ? 0 : currentExp);
  }

  /// Level and in-level EXP after earning [lifetimeExp] in total.
  ///
  /// This is the level-up rule of `GameLogic.gainExp` expressed once: EXP is
  /// consumed per level, the remainder carries over, and at [maxLevel] the bar
  /// clamps to one level (overflow is discarded). `GameLogic` and the ledger
  /// reconciliation both go through here, so the curve cannot drift between the
  /// game and its books.
  static ({int level, int inLevelExp, bool capped}) progressForLifetimeExp(int lifetimeExp) {
    var level = 1;
    var remaining = lifetimeExp < 0 ? 0 : lifetimeExp;
    while (level < maxLevel && remaining >= expForLevel(level)) {
      remaining -= expForLevel(level);
      level++;
    }
    final capped = level >= maxLevel;
    final inLevel = capped && remaining > expForLevel(level) ? expForLevel(level) : remaining;
    return (level: level, inLevelExp: inLevel, capped: capped);
  }

  static int expProgress(int currentExp, int level) {
    final needed = expForLevel(level);
    return (currentExp * 100 / needed).round();
  }

  /// Streak reward multiplier, capped at 2.0. [perDay] is the growth per
  /// streak day: 0.02 by default, and the Mage class grows twice as fast.
  static double streakMultiplier(int streak, {double perDay = 0.02}) {
    return min(2.0, 1.0 + streak * perDay);
  }
}
