// This is a generated file - do not edit.
//
// Generated from api/character/v1/character.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// CharacterClass — playable character classes.
class CharacterClass extends $pb.ProtobufEnum {
  /// Unspecified class; used as the zero value.
  static const CharacterClass CHARACTER_CLASS_UNSPECIFIED =
      CharacterClass._(0, _omitEnumNames ? '' : 'CHARACTER_CLASS_UNSPECIFIED');

  /// Warrior — melee combat class.
  static const CharacterClass CHARACTER_CLASS_WARRIOR =
      CharacterClass._(1, _omitEnumNames ? '' : 'CHARACTER_CLASS_WARRIOR');

  /// Mage — spellcasting class.
  static const CharacterClass CHARACTER_CLASS_MAGE =
      CharacterClass._(2, _omitEnumNames ? '' : 'CHARACTER_CLASS_MAGE');

  /// Ranger — ranged combat class.
  static const CharacterClass CHARACTER_CLASS_RANGER =
      CharacterClass._(3, _omitEnumNames ? '' : 'CHARACTER_CLASS_RANGER');

  static const $core.List<CharacterClass> values = <CharacterClass>[
    CHARACTER_CLASS_UNSPECIFIED,
    CHARACTER_CLASS_WARRIOR,
    CHARACTER_CLASS_MAGE,
    CHARACTER_CLASS_RANGER,
  ];

  static final $core.List<CharacterClass?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static CharacterClass? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CharacterClass._(super.value, super.name);
}

/// StatType — character attributes.
class StatType extends $pb.ProtobufEnum {
  /// Unspecified stat; used as the zero value.
  static const StatType STAT_TYPE_UNSPECIFIED =
      StatType._(0, _omitEnumNames ? '' : 'STAT_TYPE_UNSPECIFIED');

  /// Strength — physical power.
  static const StatType STAT_TYPE_STRENGTH =
      StatType._(1, _omitEnumNames ? '' : 'STAT_TYPE_STRENGTH');

  /// Intelligence — magical power.
  static const StatType STAT_TYPE_INTELLIGENCE =
      StatType._(2, _omitEnumNames ? '' : 'STAT_TYPE_INTELLIGENCE');

  /// Agility — speed and precision.
  static const StatType STAT_TYPE_AGILITY =
      StatType._(3, _omitEnumNames ? '' : 'STAT_TYPE_AGILITY');

  /// Defense — reduces damage taken.
  static const StatType STAT_TYPE_DEFENSE =
      StatType._(4, _omitEnumNames ? '' : 'STAT_TYPE_DEFENSE');

  /// Vitality — maximum HP.
  static const StatType STAT_TYPE_VITALITY =
      StatType._(5, _omitEnumNames ? '' : 'STAT_TYPE_VITALITY');

  /// Luck — random outcomes such as criticals and drops.
  static const StatType STAT_TYPE_LUCK =
      StatType._(6, _omitEnumNames ? '' : 'STAT_TYPE_LUCK');

  static const $core.List<StatType> values = <StatType>[
    STAT_TYPE_UNSPECIFIED,
    STAT_TYPE_STRENGTH,
    STAT_TYPE_INTELLIGENCE,
    STAT_TYPE_AGILITY,
    STAT_TYPE_DEFENSE,
    STAT_TYPE_VITALITY,
    STAT_TYPE_LUCK,
  ];

  static final $core.List<StatType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static StatType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const StatType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
