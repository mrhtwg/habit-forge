// This is a generated file - do not edit.
//
// Generated from api/shared/v1/shared.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// SysMaterial — in-game currency types shown in the wallet.
class SysMaterial extends $pb.ProtobufEnum {
  /// Gold — earned by completing tasks.
  static const SysMaterial SYSMATERIAL_GOLD =
      SysMaterial._(0, _omitEnumNames ? '' : 'SYSMATERIAL_GOLD');

  /// Gem — earned by completing achievements.
  static const SysMaterial SYSMATERIAL_GEM =
      SysMaterial._(1, _omitEnumNames ? '' : 'SYSMATERIAL_GEM');

  /// Exp — earned by completing tasks, can be spent on character upgrades.
  static const SysMaterial SYSMATERIAL_EXP =
      SysMaterial._(2, _omitEnumNames ? '' : 'SYSMATERIAL_EXP');

  static const $core.List<SysMaterial> values = <SysMaterial>[
    SYSMATERIAL_GOLD,
    SYSMATERIAL_GEM,
    SYSMATERIAL_EXP,
  ];

  static final $core.List<SysMaterial?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static SysMaterial? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SysMaterial._(super.value, super.name);
}

/// EquipmentSlot — equipment slots a shop item can occupy.
class EquipmentSlot extends $pb.ProtobufEnum {
  /// Unspecified slot; used as the zero value.
  static const EquipmentSlot EQUIPMENT_SLOT_UNSPECIFIED =
      EquipmentSlot._(0, _omitEnumNames ? '' : 'EQUIPMENT_SLOT_UNSPECIFIED');

  /// Weapon slot.
  static const EquipmentSlot EQUIPMENT_SLOT_WEAPON =
      EquipmentSlot._(1, _omitEnumNames ? '' : 'EQUIPMENT_SLOT_WEAPON');

  /// Helmet slot.
  static const EquipmentSlot EQUIPMENT_SLOT_HELMET =
      EquipmentSlot._(2, _omitEnumNames ? '' : 'EQUIPMENT_SLOT_HELMET');

  /// Armor slot.
  static const EquipmentSlot EQUIPMENT_SLOT_ARMOR =
      EquipmentSlot._(3, _omitEnumNames ? '' : 'EQUIPMENT_SLOT_ARMOR');

  /// Accessory slot.
  static const EquipmentSlot EQUIPMENT_SLOT_ACCESSORY =
      EquipmentSlot._(4, _omitEnumNames ? '' : 'EQUIPMENT_SLOT_ACCESSORY');

  static const $core.List<EquipmentSlot> values = <EquipmentSlot>[
    EQUIPMENT_SLOT_UNSPECIFIED,
    EQUIPMENT_SLOT_WEAPON,
    EQUIPMENT_SLOT_HELMET,
    EQUIPMENT_SLOT_ARMOR,
    EQUIPMENT_SLOT_ACCESSORY,
  ];

  static final $core.List<EquipmentSlot?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static EquipmentSlot? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const EquipmentSlot._(super.value, super.name);
}

class EquipmentRarity extends $pb.ProtobufEnum {
  static const EquipmentRarity EQUIPMENT_RARITY_COMMON =
      EquipmentRarity._(0, _omitEnumNames ? '' : 'EQUIPMENT_RARITY_COMMON');
  static const EquipmentRarity EQUIPMENT_RARITY_RARE =
      EquipmentRarity._(1, _omitEnumNames ? '' : 'EQUIPMENT_RARITY_RARE');
  static const EquipmentRarity EQUIPMENT_RARITY_EPIC =
      EquipmentRarity._(2, _omitEnumNames ? '' : 'EQUIPMENT_RARITY_EPIC');
  static const EquipmentRarity EQUIPMENT_RARITY_LEGENDARY =
      EquipmentRarity._(3, _omitEnumNames ? '' : 'EQUIPMENT_RARITY_LEGENDARY');

  static const $core.List<EquipmentRarity> values = <EquipmentRarity>[
    EQUIPMENT_RARITY_COMMON,
    EQUIPMENT_RARITY_RARE,
    EQUIPMENT_RARITY_EPIC,
    EQUIPMENT_RARITY_LEGENDARY,
  ];

  static final $core.List<EquipmentRarity?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static EquipmentRarity? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const EquipmentRarity._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
