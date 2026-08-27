// This is a generated file - do not edit.
//
// Generated from character/v1/character.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'character.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'character.pbenum.dart';

class CharacterStats extends $pb.GeneratedMessage {
  factory CharacterStats({
    $core.int? strength,
    $core.int? intelligence,
    $core.int? agility,
    $core.int? defense,
    $core.int? vitality,
    $core.int? luck,
  }) {
    final result = create();
    if (strength != null) result.strength = strength;
    if (intelligence != null) result.intelligence = intelligence;
    if (agility != null) result.agility = agility;
    if (defense != null) result.defense = defense;
    if (vitality != null) result.vitality = vitality;
    if (luck != null) result.luck = luck;
    return result;
  }

  CharacterStats._();

  factory CharacterStats.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CharacterStats.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CharacterStats',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'api.character.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'strength')
    ..aI(2, _omitFieldNames ? '' : 'intelligence')
    ..aI(3, _omitFieldNames ? '' : 'agility')
    ..aI(4, _omitFieldNames ? '' : 'defense')
    ..aI(5, _omitFieldNames ? '' : 'vitality')
    ..aI(6, _omitFieldNames ? '' : 'luck')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CharacterStats clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CharacterStats copyWith(void Function(CharacterStats) updates) =>
      super.copyWith((message) => updates(message as CharacterStats))
          as CharacterStats;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CharacterStats create() => CharacterStats._();
  @$core.override
  CharacterStats createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CharacterStats getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CharacterStats>(create);
  static CharacterStats? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get strength => $_getIZ(0);
  @$pb.TagNumber(1)
  set strength($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStrength() => $_has(0);
  @$pb.TagNumber(1)
  void clearStrength() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get intelligence => $_getIZ(1);
  @$pb.TagNumber(2)
  set intelligence($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIntelligence() => $_has(1);
  @$pb.TagNumber(2)
  void clearIntelligence() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get agility => $_getIZ(2);
  @$pb.TagNumber(3)
  set agility($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAgility() => $_has(2);
  @$pb.TagNumber(3)
  void clearAgility() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get defense => $_getIZ(3);
  @$pb.TagNumber(4)
  set defense($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDefense() => $_has(3);
  @$pb.TagNumber(4)
  void clearDefense() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get vitality => $_getIZ(4);
  @$pb.TagNumber(5)
  set vitality($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVitality() => $_has(4);
  @$pb.TagNumber(5)
  void clearVitality() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get luck => $_getIZ(5);
  @$pb.TagNumber(6)
  set luck($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLuck() => $_has(5);
  @$pb.TagNumber(6)
  void clearLuck() => $_clearField(6);
}

class Character extends $pb.GeneratedMessage {
  factory Character({
    $core.String? id,
    CharacterClass? characterClass,
    $core.int? level,
    $fixnum.Int64? currentExp,
    $core.int? currentHp,
    CharacterStats? baseStats,
    $core.int? availableStatPoints,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? equipment,
    $core.bool? isDead,
    $fixnum.Int64? deathRecoveryUntil,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (characterClass != null) result.characterClass = characterClass;
    if (level != null) result.level = level;
    if (currentExp != null) result.currentExp = currentExp;
    if (currentHp != null) result.currentHp = currentHp;
    if (baseStats != null) result.baseStats = baseStats;
    if (availableStatPoints != null)
      result.availableStatPoints = availableStatPoints;
    if (equipment != null) result.equipment.addEntries(equipment);
    if (isDead != null) result.isDead = isDead;
    if (deathRecoveryUntil != null)
      result.deathRecoveryUntil = deathRecoveryUntil;
    return result;
  }

  Character._();

  factory Character.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Character.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Character',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'api.character.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aE<CharacterClass>(2, _omitFieldNames ? '' : 'characterClass',
        protoName: 'character_Class', enumValues: CharacterClass.values)
    ..aI(3, _omitFieldNames ? '' : 'level')
    ..aInt64(4, _omitFieldNames ? '' : 'currentExp')
    ..aI(5, _omitFieldNames ? '' : 'currentHp')
    ..aOM<CharacterStats>(6, _omitFieldNames ? '' : 'baseStats',
        subBuilder: CharacterStats.create)
    ..aI(7, _omitFieldNames ? '' : 'availableStatPoints')
    ..m<$core.String, $core.String>(8, _omitFieldNames ? '' : 'equipment',
        entryClassName: 'Character.EquipmentEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('api.character.v1'))
    ..aOB(9, _omitFieldNames ? '' : 'isDead')
    ..aInt64(10, _omitFieldNames ? '' : 'deathRecoveryUntil')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Character clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Character copyWith(void Function(Character) updates) =>
      super.copyWith((message) => updates(message as Character)) as Character;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Character create() => Character._();
  @$core.override
  Character createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Character getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Character>(create);
  static Character? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  CharacterClass get characterClass => $_getN(1);
  @$pb.TagNumber(2)
  set characterClass(CharacterClass value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCharacterClass() => $_has(1);
  @$pb.TagNumber(2)
  void clearCharacterClass() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get level => $_getIZ(2);
  @$pb.TagNumber(3)
  set level($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLevel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLevel() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get currentExp => $_getI64(3);
  @$pb.TagNumber(4)
  set currentExp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCurrentExp() => $_has(3);
  @$pb.TagNumber(4)
  void clearCurrentExp() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get currentHp => $_getIZ(4);
  @$pb.TagNumber(5)
  set currentHp($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCurrentHp() => $_has(4);
  @$pb.TagNumber(5)
  void clearCurrentHp() => $_clearField(5);

  @$pb.TagNumber(6)
  CharacterStats get baseStats => $_getN(5);
  @$pb.TagNumber(6)
  set baseStats(CharacterStats value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasBaseStats() => $_has(5);
  @$pb.TagNumber(6)
  void clearBaseStats() => $_clearField(6);
  @$pb.TagNumber(6)
  CharacterStats ensureBaseStats() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.int get availableStatPoints => $_getIZ(6);
  @$pb.TagNumber(7)
  set availableStatPoints($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAvailableStatPoints() => $_has(6);
  @$pb.TagNumber(7)
  void clearAvailableStatPoints() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbMap<$core.String, $core.String> get equipment => $_getMap(7);

  @$pb.TagNumber(9)
  $core.bool get isDead => $_getBF(8);
  @$pb.TagNumber(9)
  set isDead($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasIsDead() => $_has(8);
  @$pb.TagNumber(9)
  void clearIsDead() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get deathRecoveryUntil => $_getI64(9);
  @$pb.TagNumber(10)
  set deathRecoveryUntil($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasDeathRecoveryUntil() => $_has(9);
  @$pb.TagNumber(10)
  void clearDeathRecoveryUntil() => $_clearField(10);
}

class GetCharacterRequest extends $pb.GeneratedMessage {
  factory GetCharacterRequest() => create();

  GetCharacterRequest._();

  factory GetCharacterRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCharacterRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCharacterRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'api.character.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCharacterRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCharacterRequest copyWith(void Function(GetCharacterRequest) updates) =>
      super.copyWith((message) => updates(message as GetCharacterRequest))
          as GetCharacterRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCharacterRequest create() => GetCharacterRequest._();
  @$core.override
  GetCharacterRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCharacterRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCharacterRequest>(create);
  static GetCharacterRequest? _defaultInstance;
}

class GetCharacterReply extends $pb.GeneratedMessage {
  factory GetCharacterReply({
    Character? character,
  }) {
    final result = create();
    if (character != null) result.character = character;
    return result;
  }

  GetCharacterReply._();

  factory GetCharacterReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCharacterReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCharacterReply',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'api.character.v1'),
      createEmptyInstance: create)
    ..aOM<Character>(1, _omitFieldNames ? '' : 'character',
        subBuilder: Character.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCharacterReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCharacterReply copyWith(void Function(GetCharacterReply) updates) =>
      super.copyWith((message) => updates(message as GetCharacterReply))
          as GetCharacterReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCharacterReply create() => GetCharacterReply._();
  @$core.override
  GetCharacterReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCharacterReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCharacterReply>(create);
  static GetCharacterReply? _defaultInstance;

  @$pb.TagNumber(1)
  Character get character => $_getN(0);
  @$pb.TagNumber(1)
  set character(Character value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCharacter() => $_has(0);
  @$pb.TagNumber(1)
  void clearCharacter() => $_clearField(1);
  @$pb.TagNumber(1)
  Character ensureCharacter() => $_ensure(0);
}

class UpdateCharacterRequest extends $pb.GeneratedMessage {
  factory UpdateCharacterRequest({
    Character? character,
  }) {
    final result = create();
    if (character != null) result.character = character;
    return result;
  }

  UpdateCharacterRequest._();

  factory UpdateCharacterRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateCharacterRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateCharacterRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'api.character.v1'),
      createEmptyInstance: create)
    ..aOM<Character>(1, _omitFieldNames ? '' : 'character',
        subBuilder: Character.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateCharacterRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateCharacterRequest copyWith(
          void Function(UpdateCharacterRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateCharacterRequest))
          as UpdateCharacterRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateCharacterRequest create() => UpdateCharacterRequest._();
  @$core.override
  UpdateCharacterRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateCharacterRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateCharacterRequest>(create);
  static UpdateCharacterRequest? _defaultInstance;

  @$pb.TagNumber(1)
  Character get character => $_getN(0);
  @$pb.TagNumber(1)
  set character(Character value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCharacter() => $_has(0);
  @$pb.TagNumber(1)
  void clearCharacter() => $_clearField(1);
  @$pb.TagNumber(1)
  Character ensureCharacter() => $_ensure(0);
}

class UpdateCharacterReply extends $pb.GeneratedMessage {
  factory UpdateCharacterReply({
    Character? character,
  }) {
    final result = create();
    if (character != null) result.character = character;
    return result;
  }

  UpdateCharacterReply._();

  factory UpdateCharacterReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateCharacterReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateCharacterReply',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'api.character.v1'),
      createEmptyInstance: create)
    ..aOM<Character>(1, _omitFieldNames ? '' : 'character',
        subBuilder: Character.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateCharacterReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateCharacterReply copyWith(void Function(UpdateCharacterReply) updates) =>
      super.copyWith((message) => updates(message as UpdateCharacterReply))
          as UpdateCharacterReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateCharacterReply create() => UpdateCharacterReply._();
  @$core.override
  UpdateCharacterReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateCharacterReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateCharacterReply>(create);
  static UpdateCharacterReply? _defaultInstance;

  @$pb.TagNumber(1)
  Character get character => $_getN(0);
  @$pb.TagNumber(1)
  set character(Character value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCharacter() => $_has(0);
  @$pb.TagNumber(1)
  void clearCharacter() => $_clearField(1);
  @$pb.TagNumber(1)
  Character ensureCharacter() => $_ensure(0);
}

class AllocateStatPointRequest extends $pb.GeneratedMessage {
  factory AllocateStatPointRequest({
    StatType? stat,
  }) {
    final result = create();
    if (stat != null) result.stat = stat;
    return result;
  }

  AllocateStatPointRequest._();

  factory AllocateStatPointRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AllocateStatPointRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AllocateStatPointRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'api.character.v1'),
      createEmptyInstance: create)
    ..aE<StatType>(1, _omitFieldNames ? '' : 'stat',
        enumValues: StatType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AllocateStatPointRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AllocateStatPointRequest copyWith(
          void Function(AllocateStatPointRequest) updates) =>
      super.copyWith((message) => updates(message as AllocateStatPointRequest))
          as AllocateStatPointRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AllocateStatPointRequest create() => AllocateStatPointRequest._();
  @$core.override
  AllocateStatPointRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AllocateStatPointRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AllocateStatPointRequest>(create);
  static AllocateStatPointRequest? _defaultInstance;

  @$pb.TagNumber(1)
  StatType get stat => $_getN(0);
  @$pb.TagNumber(1)
  set stat(StatType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStat() => $_has(0);
  @$pb.TagNumber(1)
  void clearStat() => $_clearField(1);
}

class AllocateStatPointReply extends $pb.GeneratedMessage {
  factory AllocateStatPointReply({
    Character? character,
  }) {
    final result = create();
    if (character != null) result.character = character;
    return result;
  }

  AllocateStatPointReply._();

  factory AllocateStatPointReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AllocateStatPointReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AllocateStatPointReply',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'api.character.v1'),
      createEmptyInstance: create)
    ..aOM<Character>(1, _omitFieldNames ? '' : 'character',
        subBuilder: Character.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AllocateStatPointReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AllocateStatPointReply copyWith(
          void Function(AllocateStatPointReply) updates) =>
      super.copyWith((message) => updates(message as AllocateStatPointReply))
          as AllocateStatPointReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AllocateStatPointReply create() => AllocateStatPointReply._();
  @$core.override
  AllocateStatPointReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AllocateStatPointReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AllocateStatPointReply>(create);
  static AllocateStatPointReply? _defaultInstance;

  @$pb.TagNumber(1)
  Character get character => $_getN(0);
  @$pb.TagNumber(1)
  set character(Character value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCharacter() => $_has(0);
  @$pb.TagNumber(1)
  void clearCharacter() => $_clearField(1);
  @$pb.TagNumber(1)
  Character ensureCharacter() => $_ensure(0);
}

class ReviveRequest extends $pb.GeneratedMessage {
  factory ReviveRequest() => create();

  ReviveRequest._();

  factory ReviveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReviveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReviveRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'api.character.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReviveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReviveRequest copyWith(void Function(ReviveRequest) updates) =>
      super.copyWith((message) => updates(message as ReviveRequest))
          as ReviveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReviveRequest create() => ReviveRequest._();
  @$core.override
  ReviveRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReviveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReviveRequest>(create);
  static ReviveRequest? _defaultInstance;
}

class ReviveReply extends $pb.GeneratedMessage {
  factory ReviveReply({
    Character? character,
  }) {
    final result = create();
    if (character != null) result.character = character;
    return result;
  }

  ReviveReply._();

  factory ReviveReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReviveReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReviveReply',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'api.character.v1'),
      createEmptyInstance: create)
    ..aOM<Character>(1, _omitFieldNames ? '' : 'character',
        subBuilder: Character.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReviveReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReviveReply copyWith(void Function(ReviveReply) updates) =>
      super.copyWith((message) => updates(message as ReviveReply))
          as ReviveReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReviveReply create() => ReviveReply._();
  @$core.override
  ReviveReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReviveReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReviveReply>(create);
  static ReviveReply? _defaultInstance;

  @$pb.TagNumber(1)
  Character get character => $_getN(0);
  @$pb.TagNumber(1)
  set character(Character value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCharacter() => $_has(0);
  @$pb.TagNumber(1)
  void clearCharacter() => $_clearField(1);
  @$pb.TagNumber(1)
  Character ensureCharacter() => $_ensure(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
