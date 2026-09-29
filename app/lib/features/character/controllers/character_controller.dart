import 'package:get/get.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';

/// Character-page actions.
///
/// Death recovery is owned by `DeathRecoveryService` (app-wide, so it also runs
/// while this page is closed) — do not re-implement a recovery timer here.
class CharacterController extends GetxController {
  String currentAnimation = 'idle';

  /// Spends one available stat point (delegated to the storage layer), then
  /// refreshes the shared character mirror so other pages see the change.
  Future<void> allocateStat(String statName) async {
    await NetworkRegistry.ins.allocateStatPoint(_statType(statName));
    await UserService.to.loadCharacter();
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
