import 'package:fixnum/fixnum.dart';
import 'package:habit_forge_app/core/extensions/date_extensions.dart';
import 'package:habit_forge_app/core/network/hive/game_constants.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';

/// Pure game rules shared by the local storage implementations (hive/firebase).
///
/// The server implementation delegates the same operations to the backend via
/// gRPC, so the rules below only run when the backend is not in charge.
///
/// Every input message is cloned and frozen first: protobuf's `rebuild` only
/// works on frozen messages, and we must never freeze (or mutate) the caller's
/// instance.
class GameLogic {
  GameLogic._();

  // ── Rewards ──

  static UserPrefs addCompletedTask(UserPrefs p) =>
      (p.deepCopy()..freeze()).rebuild((x) => x..totalTasksCompleted = x.totalTasksCompleted + 1);

  static UserPrefs addGems(UserPrefs p, int amount) =>
      (p.deepCopy()..freeze()).rebuild((x) => x..currentGems = x.currentGems + amount);

  // ── Task ──

  // ── Economy ──

  static UserPrefs addGold(UserPrefs p, int amount) =>
      (p.deepCopy()..freeze()).rebuild((x) => x..currentGold = x.currentGold + amount);

  /// Spends one available point on the given attribute.
  static Character allocateStat(Character c, StatType stat) {
    if (c.availableStatPoints <= 0) return c;
    final frozen = c.deepCopy()..freeze();
    final s = frozen.baseStats;
    return frozen.rebuild(
      (x) => x
        ..availableStatPoints = frozen.availableStatPoints - 1
        ..baseStats = switch (stat) {
          StatType.STAT_TYPE_STRENGTH => s.rebuild((v) => v..strength = s.strength + 1),
          StatType.STAT_TYPE_INTELLIGENCE => s.rebuild((v) => v..intelligence = s.intelligence + 1),
          StatType.STAT_TYPE_AGILITY => s.rebuild((v) => v..agility = s.agility + 1),
          StatType.STAT_TYPE_DEFENSE => s.rebuild((v) => v..defense = s.defense + 1),
          StatType.STAT_TYPE_VITALITY => s.rebuild((v) => v..vitality = s.vitality + 1),
          StatType.STAT_TYPE_LUCK => s.rebuild((v) => v..luck = s.luck + 1),
          _ => s,
        },
    );
  }

  /// Marks the task complete and bumps the streak (once per day).
  static Task completeTask(Task task) {
    final now = DateTime.now();
    final frozen = task.deepCopy()..freeze();
    final newStreak =
        DateTime.fromMillisecondsSinceEpoch(frozen.lastStreakDate.toInt()).isToday ? frozen.streak : frozen.streak + 1;
    return frozen.rebuild(
      (t) => t
        ..isCompleted = true
        ..streak = newStreak
        ..lastStreakDate = Int64(now.millisecondsSinceEpoch)
        ..completedAt = Int64(now.millisecondsSinceEpoch)
        ..updatedAt = Int64(now.millisecondsSinceEpoch),
    );
  }

  // ── Character ──

  /// Equips [itemId] into [slot]; an empty [itemId] (or re-equipping the same
  /// item) unequips the slot.
  static Character equip(Character c, String slot, String itemId) {
    final frozen = c.deepCopy()..freeze();
    final equipment = Map<String, String>.from(frozen.equipment);
    if (itemId.isEmpty || equipment[slot] == itemId) {
      equipment.remove(slot);
    } else {
      equipment[slot] = itemId;
    }
    return frozen.rebuild((x) => x..equipment.addAll(equipment));
  }

  /// Base EXP reward for a task, including the streak multiplier.
  static int expReward(Task task) {
    if (task.customExpReward > 0) return task.customExpReward;
    return (GameConstants.baseExpReward(task.difficulty) * GameConstants.streakMultiplier(task.streak)).round();
  }

  /// Applies exp and returns (character, newLevel or -1).
  static (Character, int) gainExp(Character c, int exp) {
    final frozen = c.deepCopy()..freeze();
    final newExp = frozen.currentExp + exp;
    final newLevel = levelForExp(newExp.toInt());
    if (newLevel <= frozen.level) {
      return (frozen.rebuild((x) => x..currentExp = newExp), -1);
    }
    final gained = (newLevel - frozen.level) * GameConstants.statPointsPerLevel;
    return (
      frozen.rebuild(
        (x) => x
          ..currentExp = newExp
          ..level = newLevel
          ..availableStatPoints = x.availableStatPoints + gained
          ..currentHp = (x.currentHp + 20).clamp(0, GameConstants.maxHp),
      ),
      newLevel,
    );
  }

  /// Base gold reward for a task.
  static int goldReward(Task task) {
    if (task.customGoldReward > 0) return task.customGoldReward;
    return GameConstants.baseGoldReward(task.difficulty);
  }

  static int levelForExp(int totalExp) {
    var remaining = totalExp;
    for (var i = 1; i <= GameConstants.maxLevel; i++) {
      if (remaining < GameConstants.expForLevel(i)) return i;
      remaining -= GameConstants.expForLevel(i);
    }
    return GameConstants.maxLevel;
  }

  /// Skips the task and (for todos) pushes the due date to tomorrow.
  static Task postpone(Task task) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final frozen = task.deepCopy()..freeze();
    return frozen.rebuild(
      (t) => t
        ..isSkipped = true
        ..dueDate = frozen.type == TaskType.TASK_TYPE_TODO ? Int64(tomorrow.millisecondsSinceEpoch) : frozen.dueDate,
    );
  }

  /// Revives a dead character with the recovery HP.
  static Character revive(Character c) => (c.deepCopy()..freeze()).rebuild(
        (x) => x
          ..isDead = false
          ..currentHp = GameConstants.deathRecoveryHp
          ..deathRecoveryUntil = Int64.ZERO,
      );

  /// Toggles the skipped flag.
  static Task skip(Task task) => (task.deepCopy()..freeze()).rebuild((t) => t..isSkipped = !t.isSkipped);

  /// Applies damage; the character dies at 0 HP and schedules recovery.
  static Character takeDamage(Character c, int amount) {
    if (c.isDead) return c;
    final frozen = c.deepCopy()..freeze();
    final newHp = (frozen.currentHp - amount).clamp(0, GameConstants.maxHp);
    final dead = newHp <= 0;
    return frozen.rebuild(
      (x) => x
        ..currentHp = newHp
        ..isDead = dead
        ..deathRecoveryUntil = dead
            ? Int64(
                DateTime.now().add(const Duration(minutes: GameConstants.deathRecoveryMinutes)).millisecondsSinceEpoch,
              )
            : Int64.ZERO,
    );
  }
}
