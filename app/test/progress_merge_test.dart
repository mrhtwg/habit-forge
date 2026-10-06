import 'package:flutter_test/flutter_test.dart';
import 'package:habit_forge_app/core/network/hive/game_constants.dart';
import 'package:habit_forge_app/core/network/hive/game_logic.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';
import 'package:fixnum/fixnum.dart';

/// Guest → account merge rules (`ProgressMergeService`, plan §13.7).
///
/// The merge has exactly two promises: nothing the player earned on either side
/// disappears, and re-running it changes nothing. These tests pin the math behind
/// the first one; `NetworkFirebaseImpl.mergeLocalProgress` implements the second
/// by replacing — not adding — the contribution a device already made.
void main() {
  group('level curve', () {
    test('lifetimeExpOf inverts progressForLifetimeExp', () {
      for (final level in [1, 2, 5, 20, GameConstants.maxLevel]) {
        final inLevel = GameConstants.expForLevel(level) ~/ 2;
        final lifetime = GameConstants.lifetimeExpOf(level, inLevel);
        final back = GameConstants.progressForLifetimeExp(lifetime);
        expect(back.level, level, reason: 'level $level');
        expect(back.inLevelExp, inLevel, reason: 'level $level');
      }
    });

    test('the derived curve is the same one the game plays', () {
      // Two identical awards must land on the same level a real gainExp would.
      final start = GameLogic.newCharacter(CharacterClass.CHARACTER_CLASS_MAGE);
      final played = GameLogic.gainExp(start, 260).$1;
      final derived = GameConstants.progressForLifetimeExp(260);

      expect(derived.level, played.level);
      expect(derived.inLevelExp, played.currentExp.toInt());
    });
  });

  group('hero merge', () {
    test('sums lifetime EXP of both saves and re-derives the level', () {
      final account = GameLogic.newCharacter(CharacterClass.CHARACTER_CLASS_MAGE);
      final local = GameLogic.newCharacter(CharacterClass.CHARACTER_CLASS_MAGE);

      // 60 EXP each is 120 together: level 1 costs 100, so level 2 with 20 left.
      final a = GameLogic.gainExp(account, 60).$1;
      final b = GameLogic.gainExp(local, 60).$1;
      final merged = GameLogic.mergeProgress(a, b);

      expect(merged.level, 2);
      expect(merged.currentExp.toInt(), 20);
      expect(merged.maxExp.toInt(), GameConstants.expForLevel(2));
      // The level that came out of the merge pays its stat point.
      expect(merged.availableStatPoints, a.availableStatPoints + GameConstants.statPointsPerLevel);
    });

    test('keeps the account identity and its HP', () {
      final account = GameLogic.newCharacter(CharacterClass.CHARACTER_CLASS_WARRIOR);
      final advanced = GameLogic.gainExp(account, 5000).$1;
      final localHero = GameLogic.newCharacter(CharacterClass.CHARACTER_CLASS_MAGE);

      final merged = GameLogic.mergeProgress(advanced, localHero);

      expect(merged.characterClass, CharacterClass.CHARACTER_CLASS_WARRIOR, reason: 'the account keeps its class');
      expect(merged.baseStats.strength, advanced.baseStats.strength, reason: 'stats are identity, not progress');
      expect(merged.currentHp, advanced.currentHp, reason: 'HP is a momentary state — a merge must not heal');
      expect(merged.isDead, advanced.isDead);
    });

    test('never rolls the account back when the device contribution shrinks', () {
      final account = GameLogic.newCharacter(CharacterClass.CHARACTER_CLASS_RANGER);
      final advanced = GameLogic.gainExp(account, 5000).$1;

      // A device whose share dropped to zero (it spent locally) must not de-level
      // the hero or take the points back.
      final lowered = GameLogic.withLifetimeExp(advanced, 0);

      expect(lowered.level, advanced.level);
      expect(lowered.currentExp.toInt(), advanced.currentExp.toInt());
      expect(lowered.availableStatPoints, advanced.availableStatPoints);
    });

    test('a merge of two fresh heroes is a no-op', () {
      final account = GameLogic.newCharacter(CharacterClass.CHARACTER_CLASS_MAGE);
      final local = GameLogic.newCharacter(CharacterClass.CHARACTER_CLASS_MAGE);
      final merged = GameLogic.mergeProgress(account, local);

      expect(merged.level, account.level);
      expect(merged.currentExp.toInt(), account.currentExp.toInt());
    });
  });

  group('wallet and counters', () {
    test('sums gold, gems and lifetime completions, keeps the best of today', () {
      final account = UserPrefs()
        ..currentGold = Int64(100)
        ..currentGems = Int64(3)
        ..totalTasksCompleted = Int64(10)
        ..todayTasksCompleted = Int64(2)
        ..firstTaskDate = Int64(2000);
      final local = UserPrefs()
        ..currentGold = Int64(40)
        ..currentGems = Int64(1)
        ..totalTasksCompleted = Int64(5)
        ..todayTasksCompleted = Int64(7)
        ..firstTaskDate = Int64(1000);

      final merged = GameLogic.mergePrefs(account, local);

      expect(merged.currentGold.toInt(), 140, reason: 'two separate pots');
      expect(merged.currentGems.toInt(), 4);
      expect(merged.totalTasksCompleted.toInt(), 15);
      expect(merged.todayTasksCompleted.toInt(), 7, reason: 'per-day figure: max, never a sum');
      expect(merged.firstTaskDate.toInt(), 1000, reason: 'keep the earlier start');
    });

    test('handles an empty side', () {
      final account = UserPrefs()..currentGold = Int64(50);
      final merged = GameLogic.mergePrefs(account, UserPrefs());
      expect(merged.currentGold.toInt(), 50);
      expect(merged.firstTaskDate.toInt(), 0);
    });
  });
}
