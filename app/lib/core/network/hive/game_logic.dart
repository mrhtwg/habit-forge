import 'dart:math';

import 'package:fixnum/fixnum.dart';
import 'package:habit_forge_app/core/extensions/date_extensions.dart';
import 'package:habit_forge_app/core/network/hive/class_profiles.dart';
import 'package:habit_forge_app/core/network/hive/game_constants.dart';
import 'package:habit_forge_app/core/network/hive/shop_config.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';
import 'package:uuid/uuid.dart';

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

  /// Builds the level-1 character for [characterClass].
  ///
  /// The ONLY place a character is created: both storage implementations call
  /// it, so the class screen and the live character can never drift apart.
  static Character newCharacter(CharacterClass characterClass) {
    final profile = ClassProfiles.of(characterClass);
    return Character()
      ..id = const Uuid().v4()
      ..characterClass = characterClass
      ..level = 1
      ..currentExp = Int64(0)
      ..currentHp = GameConstants.maxHpFor(profile.vitality)
      ..maxExp = Int64(GameConstants.expForLevel(1))
      ..baseStats = profile.toStats()
      ..availableStatPoints = 0
      ..isDead = false;
  }

  /// Raises a save's base stats up to its class floor.
  ///
  /// Characters created before classes had their own stats start from all-zero
  /// stats, which both contradicts the class screen and swallows the first
  /// points the player allocates. Only ever raises a stat to the class value,
  /// so it never removes invested points; returns null when nothing changes so
  /// callers persist exactly once.
  static Character? classBaselinePatch(Character c) {
    final p = ClassProfiles.of(c.characterClass);
    final s = c.baseStats;
    final str = max(s.strength, p.strength);
    final intel = max(s.intelligence, p.intelligence);
    final def = max(s.defense, p.defense);
    final vit = max(s.vitality, p.vitality);
    if (str == s.strength && intel == s.intelligence && def == s.defense && vit == s.vitality) {
      return null;
    }
    return (c.deepCopy()..freeze()).rebuild(
      (x) => x
        ..baseStats = (CharacterStats()
          ..strength = str
          ..intelligence = intel
          ..agility = s.agility
          ..defense = def
          ..vitality = vit
          ..luck = s.luck),
    );
  }

  /// Applies missed-daily HP damage, scaled by the class perk (the Ranger takes
  /// half). Returns [c] untouched when there is no damage or the hero is dead.
  static Character applyOverduePenalty(Character c, int damage) {
    if (damage <= 0 || c.isDead) return c;
    final scaled = (damage * ClassProfiles.of(c.characterClass).hpPenaltyScale).round();
    return takeDamage(c, scaled);
  }

  // ── Rewards ──

  static UserPrefs addCompletedTask(UserPrefs p) =>
      (p.deepCopy()..freeze()).rebuild((x) => x..totalTasksCompleted = x.totalTasksCompleted + 1);

  static UserPrefs addGems(UserPrefs p, int amount) =>
      (p.deepCopy()..freeze()).rebuild((x) => x..currentGems = x.currentGems + amount);

  // ── Task ──

  /// Task-shape rules shared by create/update (hive / firebase / server).
  /// Dailies need at least one repeat day, todos need a due date.
  static String? invalidTaskShape(Task t) {
    if (t.title.trim().isEmpty ||
        t.type.value == TaskType.TASK_TYPE_UNSPECIFIED ||
        t.difficulty == TaskDifficulty.TASK_DIFFICULTY_UNSPECIFIED) {
      return 'Title, type and difficulty are required';
    }
    if (t.type == TaskType.TASK_TYPE_DAILY && t.repeatDays.isEmpty) {
      return 'Daily tasks require at least one repeat day';
    }
    if (t.type == TaskType.TASK_TYPE_TODO && t.dueDate.toInt() <= 0) {
      return 'Todo tasks require a due date';
    }
    return null;
  }

  /// 0=Mon .. 6=Sun — matches the task form and proto comment.
  static int weekdayIndex(DateTime d) => d.weekday - 1;

  /// Whether [task] is a **negative habit** — a "bad habit" the player tracks in
  /// order to reduce it.
  ///
  /// Recording one is a *slip*: it costs HP instead of granting rewards, and
  /// being un-recorded is the good outcome, so it is never treated as a missed
  /// task. Only habits can be negative; the flag is ignored for dailies and
  /// todos so a stray value can never change how an existing task behaves.
  static bool isNegative(Task task) => task.type == TaskType.TASK_TYPE_HABIT && task.isNegative;

  /// HP a logged slip costs: the task's own `hpPenalty` when set, otherwise the
  /// difficulty default.
  ///
  /// Deliberately **not** scaled by the class penalty perk: the Ranger's
  /// reduction is about not being punished for forgetting a task, while a slip is
  /// something the player deliberately logged. Effective DEF still absorbs part of
  /// it inside [takeDamage].
  static int slipDamage(Task task) {
    final configured = task.hpPenalty > 0 ? task.hpPenalty : GameConstants.defaultHpPenalty(task.difficulty);
    return configured < 1 ? 1 : configured;
  }

  /// Applies a logged slip to [c] (DEF applies, minimum 1 damage, death and the
  /// recovery window are handled by [takeDamage]).
  static Character applySlip(Character c, Task task) => takeDamage(c, slipDamage(task));

  /// Whether [task] is scheduled on [day] (calendar date, local).
  static bool isDueOn(Task task, DateTime day) {
    switch (task.type) {
      case TaskType.TASK_TYPE_HABIT:
        return true;
      case TaskType.TASK_TYPE_DAILY:
        return task.repeatDays.contains(weekdayIndex(day));
      case TaskType.TASK_TYPE_TODO:
        if (task.dueDate.toInt() <= 0) return false;
        final due = DateTime.fromMillisecondsSinceEpoch(task.dueDate.toInt()).dateOnly;
        return due.year == day.year && due.month == day.month && due.day == day.day;
      default:
        return false;
    }
  }

  /// Re-arms a repeatable task completed on a previous day. Returns the reset
  /// task, or null when no change is needed.
  static Task? rolloverIfNeeded(Task task, DateTime now) {
    if (!task.isCompleted) return null;
    if (DateTime.fromMillisecondsSinceEpoch(task.completedAt.toInt()).isToday) return null;
    final repeatable =
        task.type == TaskType.TASK_TYPE_HABIT || (task.type == TaskType.TASK_TYPE_DAILY && isDueOn(task, now));
    if (!repeatable) return null;
    return (task.deepCopy()..freeze()).rebuild((t) => t..isCompleted = false);
  }

  /// HP damage from tasks that were due and left uncompleted yesterday.
  /// Skipped tasks and tasks completed yesterday are exempt. Missed days
  /// before yesterday are forgiven.
  ///
  /// **Habits never punish a missed day** (neither polarity): a habit is the
  /// flexible task next to the rigid daily — that is why both exist. Only dailies
  /// and overdue todos cost HP. For a negative habit the reasoning is even
  /// stronger: *not* logging it is the outcome the player wants.
  static int overduePenalty(Iterable<Task> tasks, DateTime yesterday) {
    final y = yesterday.dateOnly;
    var damage = 0;
    for (final task in tasks) {
      if (task.isSkipped) continue;
      if (task.type == TaskType.TASK_TYPE_HABIT) continue;
      final completedAt = DateTime.fromMillisecondsSinceEpoch(task.completedAt.toInt()).dateOnly;
      if (task.isCompleted && completedAt.isSameDay(y)) continue;
      if (task.type == TaskType.TASK_TYPE_TODO) {
        if (task.isCompleted) continue;
        if (task.dueDate.toInt() <= 0) continue;
        final dueDay = DateTime.fromMillisecondsSinceEpoch(task.dueDate.toInt()).dateOnly;
        if (dueDay.isAfter(y)) continue;
      } else if (!isDueOn(task, y)) {
        continue;
      }
      damage += task.hpPenalty;
    }
    return damage;
  }

  /// Maps an [EquipmentSlot] to the equipment-map key used on the character.
  static String slotKey(EquipmentSlot slot) => switch (slot) {
        EquipmentSlot.EQUIPMENT_SLOT_WEAPON => 'weapon',
        EquipmentSlot.EQUIPMENT_SLOT_HELMET => 'helmet',
        EquipmentSlot.EQUIPMENT_SLOT_ARMOR => 'armor',
        EquipmentSlot.EQUIPMENT_SLOT_ACCESSORY => 'accessory',
        EquipmentSlot.EQUIPMENT_SLOT_UNSPECIFIED => 'unspecified',
        _ => 'unspecified',
      };

  /// Achievements whose condition is newly met. Does not mutate [defs].
  static List<Achievement> newlyUnlocked({
    required Iterable<Achievement> defs,
    required Set<String> unlockedIds,
    required int totalTasks,
    required int streak,
    required int level,
    int purchases = 0,
    int deaths = 0,
  }) {
    final now = Int64(DateTime.now().millisecondsSinceEpoch);
    final out = <Achievement>[];
    for (final def in defs) {
      if (unlockedIds.contains(def.id)) continue;
      final met = switch (def.conditionType) {
        'total_tasks' => totalTasks >= def.threshold,
        'streak' => streak >= def.threshold,
        'level' => level >= def.threshold,
        'purchases' => purchases >= def.threshold,
        'deaths' => deaths >= def.threshold,
        _ => false,
      };
      if (!met) continue;
      out.add(
        def.deepCopy()
          ..isUnlocked = true
          ..unlockedAt = now,
      );
    }
    return out;
  }

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
  ///
  /// A negative habit is *recorded*, not achieved: logging a slip **resets** its
  /// streak (PRD FR-TSK-02) instead of building one — a streak of slips would be
  /// perverse and would also feed the "7-day streak" achievement. `isCompleted`
  /// still gates the one-log-per-day rule and is cleared by [rolloverIfNeeded]
  /// tomorrow.
  static Task completeTask(Task task) {
    final now = DateTime.now();
    final frozen = task.deepCopy()..freeze();
    final negative = isNegative(frozen);
    final newStreak = negative
        ? 0
        : DateTime.fromMillisecondsSinceEpoch(frozen.lastStreakDate.toInt()).isToday
            ? frozen.streak
            : frozen.streak + 1;
    return frozen.rebuild(
      (t) => t
        ..isCompleted = true
        ..streak = newStreak
        ..lastStreakDate = negative ? Int64.ZERO : Int64(now.millisecondsSinceEpoch)
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
    return frozen.rebuild((x) {
      // Replace the whole map: addAll alone would leave removed slots behind.
      x.equipment.clear();
      x.equipment.addAll(equipment);
    });
  }

  /// The character's effective attributes: base stats plus the bonuses of all
  /// equipped items. Appearance items grant no stats, so only equipment
  /// contributes. Unknown ids resolve to zero bonus.
  static CharacterStats effectiveStats(Character c) {
    final s = c.baseStats;
    var str = s.strength, intel = s.intelligence, agi = s.agility;
    var def = s.defense, vit = s.vitality, luk = s.luck;
    for (final itemId in c.equipment.values) {
      final b = ShopConfig.bonusStatsOf(itemId);
      str += b.strength;
      intel += b.intelligence;
      agi += b.agility;
      def += b.defense;
      vit += b.vitality;
      luk += b.luck;
    }
    return CharacterStats(
      strength: str,
      intelligence: intel,
      agility: agi,
      defense: def,
      vitality: vit,
      luck: luk,
    );
  }

  /// HP cap of [c] taking equipped VIT bonuses into account (100 when null).
  static int maxHpOf(Character? c) =>
      c == null ? GameConstants.maxHp : GameConstants.maxHpFor(effectiveStats(c).vitality);

  /// Base EXP reward for a task, including the streak multiplier and the
  /// character's effective INT bonus (+1% per point). Custom rewards are
  /// respected verbatim and never scaled by stats.
  ///
  /// A negative habit grants **nothing** — logging a slip is not an achievement
  /// (and its rewards would be perverse anyway).
  static int expReward(Task task, Character character) {
    if (isNegative(task)) return 0;
    if (task.customExpReward > 0) return task.customExpReward;
    final base = GameConstants.baseExpReward(task.difficulty) *
        GameConstants.streakMultiplier(task.streak, perDay: ClassProfiles.of(character.characterClass).streakGrowth);
    return (base * (1 + effectiveStats(character).intelligence * 0.01)).round();
  }

  /// Applies exp and returns (character, newLevel or -1).
  ///
  /// EXP is per-level: the bar always shows the progress inside the current
  /// level ([0, expForLevel(level))), e.g. level 1 needs 100 EXP to reach
  /// level 2, level 2 needs 160, ... Crossing the threshold spends that
  /// amount and the remainder carries into the next level. At max level the
  /// bar is capped full (no overflow).
  static (Character, int) gainExp(Character c, int exp) {
    final frozen = c.deepCopy()..freeze();
    var remaining = frozen.currentExp.toInt() + exp;
    var level = frozen.level;
    while (level < GameConstants.maxLevel && remaining >= GameConstants.expForLevel(level)) {
      remaining -= GameConstants.expForLevel(level);
      level++;
    }
    if (level <= frozen.level) {
      final capped = level >= GameConstants.maxLevel ? remaining.clamp(0, GameConstants.expForLevel(level)) : remaining;
      return (frozen.rebuild((x) => x..currentExp = Int64(capped)), -1);
    }
    final gained = (level - frozen.level) * GameConstants.statPointsPerLevel;
    final maxForLevel = GameConstants.expForLevel(level);
    final cappedExp = level >= GameConstants.maxLevel ? remaining.clamp(0, maxForLevel) : remaining;
    // VIT (base + equipment) raises the HP cap; the level-up heal clamps to
    // the character's own cap.
    final maxHp = GameConstants.maxHpFor(effectiveStats(frozen).vitality);
    return (
      frozen.rebuild(
        (x) => x
          ..currentExp = Int64(cappedExp)
          ..level = level
          ..maxExp = Int64(maxForLevel)
          ..availableStatPoints = x.availableStatPoints + gained
          ..currentHp = (x.currentHp + GameConstants.completeTaskAddHp).clamp(0, maxHp),
      ),
      level,
    );
  }

  /// Base gold reward for a task, scaled by the character's effective STR
  /// bonus (+1% per point). Custom rewards are respected verbatim and never
  /// scaled. A negative habit pays nothing (see [expReward]).
  static int goldReward(Task task, Character character) {
    if (isNegative(task)) return 0;
    if (task.customGoldReward > 0) return task.customGoldReward;
    final base = GameConstants.baseGoldReward(task.difficulty);
    return (base * (1 + effectiveStats(character).strength * 0.01)).round();
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

  /// Revives a dead character with its class recovery HP (the Warrior comes
  /// back with more HP).
  static Character revive(Character c) {
    final hp = ClassProfiles.of(c.characterClass).recoveryHp;
    return (c.deepCopy()..freeze()).rebuild(
      (x) => x
        ..isDead = false
        ..currentHp = min(hp, maxHpOf(c))
        ..deathRecoveryUntil = Int64.ZERO,
    );
  }

  /// Toggles the skipped flag.
  static Task skip(Task task) => (task.deepCopy()..freeze()).rebuild((t) => t..isSkipped = !t.isSkipped);

  /// Applies damage; effective DEF absorbs one HP per point (minimum 1
  /// damage) and effective VIT raises the HP cap. The character dies at
  /// 0 HP and schedules recovery.
  static Character takeDamage(Character c, int amount) {
    if (c.isDead) return c;
    final frozen = c.deepCopy()..freeze();
    final effective = effectiveStats(frozen);
    final reduced = amount - effective.defense;
    final dealt = reduced < 1 ? 1 : reduced;
    final newHp = (frozen.currentHp - dealt).clamp(0, GameConstants.maxHpFor(effective.vitality));
    final dead = newHp <= 0;
    return frozen.rebuild(
      (x) => x
        ..currentHp = newHp
        ..isDead = dead
        ..deathRecoveryUntil = dead
            ? Int64(
                DateTime.now()
                    .add(Duration(minutes: ClassProfiles.of(frozen.characterClass).recoveryMinutes))
                    .millisecondsSinceEpoch,
              )
            : Int64.ZERO,
    );
  }
}
