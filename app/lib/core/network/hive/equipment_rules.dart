import 'package:habit_forge_app/generated/protos/character/v1/character.pbenum.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';

/// Single source of truth for slot, class, and level compatibility.
class EquipmentRules {
  EquipmentRules._();

  static bool isCompatible(Character character, ShopItem item, {EquipmentSlot? targetSlot}) {
    final slot = targetSlot ?? item.slot;
    if (slot == EquipmentSlot.EQUIPMENT_SLOT_UNSPECIFIED || item.slot != slot) return false;
    if (character.level < item.requiredLevel) return false;
    if (item.allowedClasses.isEmpty) return true;
    return item.allowedClasses.contains(classKey(character.characterClass));
  }

  static String? incompatibilityReason(Character character, ShopItem item, {EquipmentSlot? targetSlot}) {
    final slot = targetSlot ?? item.slot;
    if (slot == EquipmentSlot.EQUIPMENT_SLOT_UNSPECIFIED || item.slot != slot) return 'slot';
    if (character.level < item.requiredLevel) return 'level';
    if (item.allowedClasses.isNotEmpty && !item.allowedClasses.contains(classKey(character.characterClass))) {
      return 'class';
    }
    return null;
  }

  static String classKey(CharacterClass characterClass) => switch (characterClass) {
        CharacterClass.CHARACTER_CLASS_RANGER => 'ranger',
        CharacterClass.CHARACTER_CLASS_MAGE => 'mage',
        _ => 'warrior',
      };
}
