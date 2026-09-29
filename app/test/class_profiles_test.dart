import 'package:flutter_test/flutter_test.dart';
import 'package:habit_forge_app/core/network/hive/class_profiles.dart';
import 'package:habit_forge_app/core/network/hive/game_logic.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pbenum.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';

/// The class screen promises per-class stats and perks, so those differences
/// must exist in the rules. These tests pin them.
void main() {
  const warrior = CharacterClass.CHARACTER_CLASS_WARRIOR;
  const mage = CharacterClass.CHARACTER_CLASS_MAGE;
  const ranger = CharacterClass.CHARACTER_CLASS_RANGER;

  Task easyTask({int streak = 0}) => Task()
    ..difficulty = TaskDifficulty.TASK_DIFFICULTY_EASY
    ..streak = streak;

  test('each class starts with its own stats at full class HP', () {
    final w = GameLogic.newCharacter(warrior);
    final m = GameLogic.newCharacter(mage);
    final r = GameLogic.newCharacter(ranger);

    for (final c in [w, m, r]) {
      final total = c.baseStats.strength +
          c.baseStats.intelligence +
          c.baseStats.defense +
          c.baseStats.vitality;
      expect(total, greaterThan(0), reason: 'a class must never start from zero stats');
      expect(c.currentHp, GameLogic.maxHpOf(c), reason: 'starts at full class HP');
    }
    expect(GameLogic.maxHpOf(w), greaterThan(GameLogic.maxHpOf(m)));
    expect(m.baseStats.intelligence, greaterThan(w.baseStats.intelligence));
    expect(r.baseStats.strength, greaterThan(0));
  });

  test('mage earns more EXP than warrior for the same task', () {
    final task = easyTask(streak: 10);
    final mageExp = GameLogic.expReward(task, GameLogic.newCharacter(mage));
    final warriorExp = GameLogic.expReward(task, GameLogic.newCharacter(warrior));
    expect(mageExp, greaterThan(warriorExp));
  });

  test('ranger loses less HP to a missed daily', () {
    final w = GameLogic.newCharacter(warrior);
    final r = GameLogic.newCharacter(ranger);
    final warriorLoss = w.currentHp - GameLogic.applyOverduePenalty(w, 10).currentHp;
    final rangerLoss = r.currentHp - GameLogic.applyOverduePenalty(r, 10).currentHp;
    expect(rangerLoss, lessThan(warriorLoss));
  });

  test('warrior revives with more HP, sooner', () {
    final dead = GameLogic.newCharacter(warrior)
      ..isDead = true
      ..currentHp = 0;
    final revived = GameLogic.revive(dead);
    expect(revived.isDead, isFalse);
    expect(revived.currentHp, ClassProfiles.warrior.recoveryHp);
    expect(ClassProfiles.warrior.recoveryHp, greaterThan(ClassProfiles.mage.recoveryHp));
    expect(ClassProfiles.warrior.recoveryMinutes, lessThan(ClassProfiles.mage.recoveryMinutes));
  });

  test('class baseline patch fills legacy saves once and keeps invested points', () {
    // Pre-fix save: created when every class had all-zero base stats.
    final legacy = Character()
      ..id = 'legacy'
      ..characterClass = mage
      ..level = 5
      ..currentHp = 90
      ..baseStats = CharacterStats();
    final patched = GameLogic.classBaselinePatch(legacy);
    expect(patched, isNotNull);
    expect(patched!.baseStats.intelligence, ClassProfiles.mage.intelligence);
    expect(patched.currentHp, 90, reason: 'the migration must not heal the hero');
    expect(GameLogic.classBaselinePatch(patched), isNull, reason: 'idempotent');

    // A player who already invested above the class floor keeps those points.
    final invested = Character()
      ..id = 'invested'
      ..characterClass = mage
      ..level = 5
      ..baseStats = (CharacterStats()..strength = 9);
    final fixed = GameLogic.classBaselinePatch(invested)!;
    expect(fixed.baseStats.strength, 9);
    expect(fixed.baseStats.intelligence, ClassProfiles.mage.intelligence);
  });
}
