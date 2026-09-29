import 'package:habit_forge_app/core/network/hive/game_constants.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';

/// Stats that currently have an in-game effect, in the order the onboarding
/// card shows them. AGI / LUK are deliberately absent: nothing reads them yet.
enum ClassStat { strength, intelligence, defense, vitality }

/// Starting stats and perks of one hero class.
class ClassProfile {
  const ClassProfile({
    required this.strength,
    required this.intelligence,
    required this.defense,
    required this.vitality,
    required this.recoveryHp,
    required this.recoveryMinutes,
    required this.streakGrowth,
    required this.hpPenaltyScale,
    this.agility = 0,
    this.luck = 0,
  });

  /// Starting base stats, before equipment and level-up points.
  final int strength;
  final int intelligence;
  final int defense;
  final int vitality;
  final int agility;
  final int luck;

  /// HP restored when the hero revives after defeat.
  final int recoveryHp;

  /// Minutes of forced recovery after defeat.
  final int recoveryMinutes;

  /// Streak-bonus growth per streak day (see [GameConstants.streakMultiplier]).
  final double streakGrowth;

  /// Multiplier on missed-daily HP damage (1.0 = full damage).
  final double hpPenaltyScale;

  /// Stats with a live effect, in display order.
  List<(ClassStat, int)> get spread => [
        (ClassStat.strength, strength),
        (ClassStat.intelligence, intelligence),
        (ClassStat.defense, defense),
        (ClassStat.vitality, vitality),
      ];

  /// Bar widths for [spread], against [ClassProfiles.barScale] so the classes
  /// stay comparable at a glance. Derived from the stats themselves, so the
  /// bars can never contradict the numbers shown under the list.
  List<double> get barRatios => [
        for (final (_, value) in spread) (value / ClassProfiles.barScale).clamp(0.0, 1.0),
      ];

  CharacterStats toStats() => CharacterStats()
    ..strength = strength
    ..intelligence = intelligence
    ..agility = agility
    ..defense = defense
    ..vitality = vitality
    ..luck = luck;
}

/// The single source of truth for how the three classes actually differ.
///
/// Both the onboarding cards and `GameLogic` read this table, so the numbers a
/// player is shown on the class screen are exactly the numbers the game
/// applies. Never hardcode a class bonus anywhere else.
///
/// Balance note: defensive points (DEF / VIT) are worth less to a player than
/// income points (INT / STR), so the Warrior carries the largest total on
/// purpose. No class may be strictly better than another — INT and STR are the
/// only income stats, VIT/DEF only soften setbacks, and each class owns exactly
/// one perk.
class ClassProfiles {
  ClassProfiles._();

  /// Value a full bar represents — the largest stat any class starts with.
  static const int barScale = 7;

  /// Tanky: highest HP pool, cheapest comeback after defeat.
  static const warrior = ClassProfile(
    strength: 3,
    intelligence: 0,
    defense: 3,
    vitality: 5,
    recoveryHp: 75,
    recoveryMinutes: 20,
    streakGrowth: 0.02,
    hpPenaltyScale: 1.0,
  );

  /// Growth: more EXP per point spent, and streaks pay off twice as fast.
  static const mage = ClassProfile(
    strength: 0,
    intelligence: 7,
    defense: 0,
    vitality: 2,
    recoveryHp: GameConstants.deathRecoveryHp,
    recoveryMinutes: GameConstants.deathRecoveryMinutes,
    streakGrowth: 0.04,
    hpPenaltyScale: 1.0,
  );

  /// Steady: balanced spread and half the damage when a daily slips.
  static const ranger = ClassProfile(
    strength: 3,
    intelligence: 2,
    defense: 1,
    vitality: 3,
    recoveryHp: GameConstants.deathRecoveryHp,
    recoveryMinutes: GameConstants.deathRecoveryMinutes,
    streakGrowth: 0.02,
    hpPenaltyScale: 0.5,
  );

  /// Profile of [value]; unknown / unspecified classes fall back to the Warrior
  /// spread so corrupt or legacy saves never end up with zero stats.
  static ClassProfile of(CharacterClass? value) => switch (value) {
        CharacterClass.CHARACTER_CLASS_MAGE => mage,
        CharacterClass.CHARACTER_CLASS_RANGER => ranger,
        _ => warrior,
      };
}
