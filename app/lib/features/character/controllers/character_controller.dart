import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/constants/game_constants.dart';
import 'package:habit_forge_app/core/services/audio_service.dart';
import 'package:habit_forge_app/core/services/haptic_service.dart';
import 'package:habit_forge_app/core/services/hive_service.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';

class CharacterController extends GetxController {
  final _hive = HiveService.to;
  String currentAnimation = 'idle';
  Timer? _deathTimer;

  void allocateStat(String statName) {
    final char = _hive.character.value;
    if (char == null || char.availableStatPoints <= 0) return;

    final stats = char.baseStats;
    CharacterStats newStats;
    switch (statName) {
      case 'strength':
        newStats = stats.rebuild((s) => s..strength = stats.strength + 1);
        break;
      case 'intelligence':
        newStats = stats.rebuild((s) => s..intelligence = stats.intelligence + 1);
        break;
      case 'agility':
        newStats = stats.rebuild((s) => s..agility = stats.agility + 1);
        break;
      case 'defense':
        newStats = stats.rebuild((s) => s..defense = stats.defense + 1);
        break;
      case 'vitality':
        newStats = stats.rebuild((s) => s..vitality = stats.vitality + 1);
        break;
      case 'luck':
        newStats = stats.rebuild((s) => s..luck = stats.luck + 1);
        break;
      default:
        return;
    }

    _hive.saveCharacter(
      char.rebuild(
        (c) => c
          ..baseStats = newStats
          ..availableStatPoints = char.availableStatPoints - 1,
      ),
    );
  }

  void checkDeathRecovery() {
    final char = _hive.character.value;
    if (char == null || !char.isDead) return;
    if (DateTime.now().isAfter(DateTime(char.deathRecoveryUntil.toInt()))) {
      _hive.saveCharacter(
        char.rebuild(
          (c) => c
            ..isDead = false
            ..currentHp = GameConstants.deathRecoveryHp
            ..deathRecoveryUntil = Int64.ZERO,
        ),
      );
    }
  }

  // Check if character leveled up, returns old level for animation trigger
  int checkLevelUp() {
    final char = _hive.character.value;
    if (char == null) return -1;

    final oldLevel = char.level;
    int remainingExp = char.currentExp.toInt();
    int newLevel = 1;
    for (int i = 1; i <= GameConstants.maxLevel; i++) {
      final needed = GameConstants.expForLevel(i);
      if (remainingExp < needed) {
        newLevel = i;
        break;
      }
      remainingExp -= needed;
      newLevel = i;
    }

    if (newLevel > oldLevel) {
      final statsPointsGained = (newLevel - oldLevel) * GameConstants.statPointsPerLevel;
      _hive.saveCharacter(
        char.rebuild(
          (c) => c
            ..level = newLevel
            ..availableStatPoints = char.availableStatPoints + statsPointsGained
            ..currentHp = (char.currentHp + 20).clamp(0, GameConstants.maxHp),
        ),
      );

      Get.find<AudioService>().playLevelUp();
      Get.find<HapticService>().heavy();

      return newLevel;
    }
    return -1;
  }

  @override
  void dispose() {
    _deathTimer?.cancel();
    super.dispose();
  }

  void takeDamage(int amount) {
    final char = _hive.character.value;
    if (char == null || char.isDead) return;

    final newHp = (char.currentHp - amount).clamp(0, GameConstants.maxHp);
    final isDead = newHp <= 0;

    _hive.saveCharacter(
      char.rebuild(
        (c) => c
          ..currentHp = newHp
          ..isDead = isDead
          ..deathRecoveryUntil = isDead
              ? Int64(DateTime.now().add(Duration(minutes: GameConstants.deathRecoveryMinutes)).millisecondsSinceEpoch)
              : Int64.ZERO,
      ),
    );
  }

  void updateAnimation(String animation) {
    currentAnimation = animation;
    update();
  }
}
