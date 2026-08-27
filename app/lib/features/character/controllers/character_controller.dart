import 'dart:async';

import 'package:get/get.dart';
import 'package:habit_forge_app/core/storage/storage_service.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';

class CharacterController extends GetxController {
  final _hive = StorageService.to;
  String currentAnimation = 'idle';
  Timer? _deathTimer;

  /// Spends one available stat point (delegated to the storage layer).
  void allocateStat(String statName) {
    _hive.allocateStatPoint(_statType(statName));
  }

  /// Revives the character when the death-recovery timer has elapsed.
  Future<void> checkDeathRecovery() async {
    final char = _hive.character.value;
    if (char == null || !char.isDead) return;
    if (DateTime.now().isAfter(DateTime(char.deathRecoveryUntil.toInt()))) {
      await _hive.reviveCharacter();
    }
  }

  /// Applies damage to the character (delegated to the storage layer).
  void takeDamage(int amount) {
    _hive.takeDamage(amount);
  }

  @override
  void dispose() {
    _deathTimer?.cancel();
    super.dispose();
  }

  void updateAnimation(String animation) {
    currentAnimation = animation;
    update();
  }

  StatType _statType(String name) => switch (name) {
        'strength' => StatType.STAT_TYPE_STRENGTH,
        'intelligence' => StatType.STAT_TYPE_INTELLIGENCE,
        'agility' => StatType.STAT_TYPE_AGILITY,
        'defense' => StatType.STAT_TYPE_DEFENSE,
        'vitality' => StatType.STAT_TYPE_VITALITY,
        'luck' => StatType.STAT_TYPE_LUCK,
        _ => StatType.STAT_TYPE_UNSPECIFIED,
      };
}
