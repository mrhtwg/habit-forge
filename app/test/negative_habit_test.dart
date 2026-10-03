import 'package:flutter_test/flutter_test.dart';
import 'package:habit_forge_app/core/network/hive/class_profiles.dart';
import 'package:habit_forge_app/core/network/hive/game_constants.dart';
import 'package:habit_forge_app/core/network/hive/game_logic.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:fixnum/fixnum.dart';

/// Negative habits ("bad habits").
///
/// The loop is inverted: the player tracks something they want to *reduce*, so
/// logging a slip costs HP and earns nothing, and *not* logging one is the good
/// outcome. That last part is why a habit — either polarity — is never punished
/// for a missed day, which is exactly what separates it from a daily.
void main() {
  Task habit({
    bool negative = false,
    int hpPenalty = 0,
    TaskDifficulty difficulty = TaskDifficulty.TASK_DIFFICULTY_MEDIUM,
  }) =>
      Task()
        ..id = negative ? 'bad' : 'good'
        ..title = negative ? 'No late-night scrolling' : 'Read 30 minutes'
        ..type = TaskType.TASK_TYPE_HABIT
        ..difficulty = difficulty
        ..hpPenalty = hpPenalty
        ..isNegative = negative;

  group('polarity', () {
    test('only habits can be negative', () {
      expect(GameLogic.isNegative(habit(negative: true)), isTrue);
      expect(GameLogic.isNegative(habit()), isFalse);

      for (final type in [TaskType.TASK_TYPE_DAILY, TaskType.TASK_TYPE_TODO]) {
        final task = Task()
          ..type = type
          ..isNegative = true;
        expect(GameLogic.isNegative(task), isFalse, reason: '$type must ignore the flag');
      }
    });

    test('a slip earns nothing, not even a custom reward', () {
      final mage = GameLogic.newCharacter(CharacterClass.CHARACTER_CLASS_MAGE);
      final negative = habit(negative: true);
      negative.customExpReward = 99;
      negative.customGoldReward = 99;

      expect(GameLogic.expReward(negative, mage), 0);
      expect(GameLogic.goldReward(negative, mage), 0);
      // …while a plain habit still pays out.
      expect(GameLogic.expReward(habit(), mage), greaterThan(0));
      expect(GameLogic.goldReward(habit(), mage), greaterThan(0));
    });
  });

  group('slip damage', () {
    test('uses the task penalty when set, the difficulty default otherwise', () {
      expect(GameLogic.slipDamage(habit(negative: true, hpPenalty: 7)), 7);
      expect(
        GameLogic.slipDamage(habit(negative: true, difficulty: TaskDifficulty.TASK_DIFFICULTY_EASY)),
        GameConstants.defaultHpPenalty(TaskDifficulty.TASK_DIFFICULTY_EASY),
      );
      expect(
        GameLogic.slipDamage(habit(negative: true, difficulty: TaskDifficulty.TASK_DIFFICULTY_HARD)),
        GameConstants.defaultHpPenalty(TaskDifficulty.TASK_DIFFICULTY_HARD),
      );
      expect(GameLogic.slipDamage(habit(negative: true, hpPenalty: -5)), GameConstants.defaultHpPenalty(TaskDifficulty.TASK_DIFFICULTY_MEDIUM));
    });

    test('effective DEF absorbs part of it', () {
      // Mage has DEF 0, so the whole penalty lands.
      final mage = GameLogic.newCharacter(CharacterClass.CHARACTER_CLASS_MAGE);
      expect(mage.baseStats.defense, 0);
      final mageAfter = GameLogic.applySlip(mage, habit(negative: true, hpPenalty: 10));
      expect(mage.currentHp - mageAfter.currentHp, 10);

      // Ranger has DEF 1 — and its "half penalty for missed dailies" perk must
      // NOT apply here: a slip is something the player deliberately logged.
      final ranger = GameLogic.newCharacter(CharacterClass.CHARACTER_CLASS_RANGER);
      final defender = ranger.baseStats.defense;
      expect(defender, ClassProfiles.of(CharacterClass.CHARACTER_CLASS_RANGER).defense);
      final rangerAfter = GameLogic.applySlip(ranger, habit(negative: true, hpPenalty: 10));
      expect(ranger.currentHp - rangerAfter.currentHp, 10 - defender);
    });

    test('a fatal slip kills the hero and schedules the recovery window', () {
      final mage = GameLogic.newCharacter(CharacterClass.CHARACTER_CLASS_MAGE);
      final nearlyDead = (mage.deepCopy()..freeze()).rebuild((c) => c..currentHp = 3);
      final after = GameLogic.applySlip(nearlyDead, habit(negative: true, hpPenalty: 10));

      expect(after.currentHp, 0);
      expect(after.isDead, isTrue);
      expect(after.deathRecoveryUntil.toInt(), greaterThan(DateTime.now().millisecondsSinceEpoch));
    });
  });

  group('habits are never punished for a missed day', () {
    final yesterday = DateTime(2026, 9, 28);

    test('a plain habit deals no damage when left undone', () {
      expect(GameLogic.overduePenalty([habit(hpPenalty: 30)], yesterday), 0);
    });

    test('a negative habit deals no damage either — not logging it is the win', () {
      expect(GameLogic.overduePenalty([habit(negative: true, hpPenalty: 30)], yesterday), 0);
    });

    test('dailies and overdue todos still cost HP', () {
      final daily = Task()
        ..type = TaskType.TASK_TYPE_DAILY
        ..difficulty = TaskDifficulty.TASK_DIFFICULTY_MEDIUM
        ..hpPenalty = 10
        ..repeatDays.add(GameLogic.weekdayIndex(yesterday));
      final todo = Task()
        ..type = TaskType.TASK_TYPE_TODO
        ..difficulty = TaskDifficulty.TASK_DIFFICULTY_MEDIUM
        ..hpPenalty = 20
        ..dueDate = Int64(yesterday.millisecondsSinceEpoch);

      expect(GameLogic.overduePenalty([daily, todo], yesterday), 30);
    });

    test('a todo that is not due yet is forgiven', () {
      final future = Task()
        ..type = TaskType.TASK_TYPE_TODO
        ..hpPenalty = 20
        ..dueDate = Int64(yesterday.add(const Duration(days: 3)).millisecondsSinceEpoch);

      expect(GameLogic.overduePenalty([future], yesterday), 0);
    });
  });

  group('completion semantics', () {
    test('logging a slip marks the day without building a streak', () {
      final logged = GameLogic.completeTask(habit(negative: true));

      expect(logged.isCompleted, isTrue);
      expect(logged.streak, 0, reason: 'a streak of slips would be perverse');
      expect(logged.lastStreakDate.toInt(), 0);
      expect(logged.completedAt.toInt(), greaterThan(0));
    });

    test('logging a slip resets an existing streak (PRD FR-TSK-02)', () {
      final withStreak = habit(negative: true)..streak = 5;
      final logged = GameLogic.completeTask(withStreak);

      expect(logged.streak, 0);
      expect(logged.lastStreakDate.toInt(), 0);
    });

    test('a good habit still builds its streak', () {
      expect(GameLogic.completeTask(habit()).streak, 1);
    });

    test('a logged slip re-arms the next day so it can be logged again', () {
      // `rolloverIfNeeded` compares `completedAt` against the real clock (see the
      // date extension), so simulate a slip logged *yesterday* instead of passing
      // a future date.
      final yesterday = DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;
      final loggedYesterday = habit(negative: true);
      loggedYesterday.isCompleted = true;
      loggedYesterday.completedAt = Int64(yesterday);

      expect(GameLogic.rolloverIfNeeded(loggedYesterday, DateTime.now()), isNotNull);
      // …and the same day it was logged it stays done: one log per day.
      expect(
        GameLogic.rolloverIfNeeded(GameLogic.completeTask(habit(negative: true)), DateTime.now()),
        isNull,
      );
    });
  });
}
