// This is a generated file - do not edit.
//
// Generated from api/character/v1/character.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use characterClassDescriptor instead')
const CharacterClass$json = {
  '1': 'CharacterClass',
  '2': [
    {'1': 'CHARACTER_CLASS_UNSPECIFIED', '2': 0},
    {'1': 'CHARACTER_CLASS_WARRIOR', '2': 1},
    {'1': 'CHARACTER_CLASS_MAGE', '2': 2},
    {'1': 'CHARACTER_CLASS_RANGER', '2': 3},
  ],
};

/// Descriptor for `CharacterClass`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List characterClassDescriptor = $convert.base64Decode(
    'Cg5DaGFyYWN0ZXJDbGFzcxIfChtDSEFSQUNURVJfQ0xBU1NfVU5TUEVDSUZJRUQQABIbChdDSE'
    'FSQUNURVJfQ0xBU1NfV0FSUklPUhABEhgKFENIQVJBQ1RFUl9DTEFTU19NQUdFEAISGgoWQ0hB'
    'UkFDVEVSX0NMQVNTX1JBTkdFUhAD');

@$core.Deprecated('Use statTypeDescriptor instead')
const StatType$json = {
  '1': 'StatType',
  '2': [
    {'1': 'STAT_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'STAT_TYPE_STRENGTH', '2': 1},
    {'1': 'STAT_TYPE_INTELLIGENCE', '2': 2},
    {'1': 'STAT_TYPE_AGILITY', '2': 3},
    {'1': 'STAT_TYPE_DEFENSE', '2': 4},
    {'1': 'STAT_TYPE_VITALITY', '2': 5},
    {'1': 'STAT_TYPE_LUCK', '2': 6},
  ],
};

/// Descriptor for `StatType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List statTypeDescriptor = $convert.base64Decode(
    'CghTdGF0VHlwZRIZChVTVEFUX1RZUEVfVU5TUEVDSUZJRUQQABIWChJTVEFUX1RZUEVfU1RSRU'
    '5HVEgQARIaChZTVEFUX1RZUEVfSU5URUxMSUdFTkNFEAISFQoRU1RBVF9UWVBFX0FHSUxJVFkQ'
    'AxIVChFTVEFUX1RZUEVfREVGRU5TRRAEEhYKElNUQVRfVFlQRV9WSVRBTElUWRAFEhIKDlNUQV'
    'RfVFlQRV9MVUNLEAY=');

@$core.Deprecated('Use characterStatsDescriptor instead')
const CharacterStats$json = {
  '1': 'CharacterStats',
  '2': [
    {'1': 'strength', '3': 1, '4': 1, '5': 5, '10': 'strength'},
    {'1': 'intelligence', '3': 2, '4': 1, '5': 5, '10': 'intelligence'},
    {'1': 'agility', '3': 3, '4': 1, '5': 5, '10': 'agility'},
    {'1': 'defense', '3': 4, '4': 1, '5': 5, '10': 'defense'},
    {'1': 'vitality', '3': 5, '4': 1, '5': 5, '10': 'vitality'},
    {'1': 'luck', '3': 6, '4': 1, '5': 5, '10': 'luck'},
  ],
};

/// Descriptor for `CharacterStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List characterStatsDescriptor = $convert.base64Decode(
    'Cg5DaGFyYWN0ZXJTdGF0cxIaCghzdHJlbmd0aBgBIAEoBVIIc3RyZW5ndGgSIgoMaW50ZWxsaW'
    'dlbmNlGAIgASgFUgxpbnRlbGxpZ2VuY2USGAoHYWdpbGl0eRgDIAEoBVIHYWdpbGl0eRIYCgdk'
    'ZWZlbnNlGAQgASgFUgdkZWZlbnNlEhoKCHZpdGFsaXR5GAUgASgFUgh2aXRhbGl0eRISCgRsdW'
    'NrGAYgASgFUgRsdWNr');

@$core.Deprecated('Use characterDescriptor instead')
const Character$json = {
  '1': 'Character',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'character_Class',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.api.character.v1.CharacterClass',
      '10': 'characterClass'
    },
    {'1': 'level', '3': 3, '4': 1, '5': 5, '10': 'level'},
    {'1': 'current_exp', '3': 4, '4': 1, '5': 3, '10': 'currentExp'},
    {'1': 'current_hp', '3': 5, '4': 1, '5': 5, '10': 'currentHp'},
    {
      '1': 'base_stats',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.api.character.v1.CharacterStats',
      '10': 'baseStats'
    },
    {
      '1': 'available_stat_points',
      '3': 7,
      '4': 1,
      '5': 5,
      '10': 'availableStatPoints'
    },
    {
      '1': 'equipment',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.api.character.v1.Character.EquipmentEntry',
      '10': 'equipment'
    },
    {'1': 'is_dead', '3': 9, '4': 1, '5': 8, '10': 'isDead'},
    {
      '1': 'death_recovery_until',
      '3': 10,
      '4': 1,
      '5': 3,
      '10': 'deathRecoveryUntil'
    },
  ],
  '3': [Character_EquipmentEntry$json],
};

@$core.Deprecated('Use characterDescriptor instead')
const Character_EquipmentEntry$json = {
  '1': 'EquipmentEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Character`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List characterDescriptor = $convert.base64Decode(
    'CglDaGFyYWN0ZXISDgoCaWQYASABKAlSAmlkEkkKD2NoYXJhY3Rlcl9DbGFzcxgCIAEoDjIgLm'
    'FwaS5jaGFyYWN0ZXIudjEuQ2hhcmFjdGVyQ2xhc3NSDmNoYXJhY3RlckNsYXNzEhQKBWxldmVs'
    'GAMgASgFUgVsZXZlbBIfCgtjdXJyZW50X2V4cBgEIAEoA1IKY3VycmVudEV4cBIdCgpjdXJyZW'
    '50X2hwGAUgASgFUgljdXJyZW50SHASPwoKYmFzZV9zdGF0cxgGIAEoCzIgLmFwaS5jaGFyYWN0'
    'ZXIudjEuQ2hhcmFjdGVyU3RhdHNSCWJhc2VTdGF0cxIyChVhdmFpbGFibGVfc3RhdF9wb2ludH'
    'MYByABKAVSE2F2YWlsYWJsZVN0YXRQb2ludHMSSAoJZXF1aXBtZW50GAggAygLMiouYXBpLmNo'
    'YXJhY3Rlci52MS5DaGFyYWN0ZXIuRXF1aXBtZW50RW50cnlSCWVxdWlwbWVudBIXCgdpc19kZW'
    'FkGAkgASgIUgZpc0RlYWQSMAoUZGVhdGhfcmVjb3ZlcnlfdW50aWwYCiABKANSEmRlYXRoUmVj'
    'b3ZlcnlVbnRpbBo8Cg5FcXVpcG1lbnRFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZR'
    'gCIAEoCVIFdmFsdWU6AjgB');

@$core.Deprecated('Use createCharacterRequestDescriptor instead')
const CreateCharacterRequest$json = {
  '1': 'CreateCharacterRequest',
  '2': [
    {
      '1': 'characterClass',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.api.character.v1.CharacterClass',
      '10': 'characterClass'
    },
  ],
};

/// Descriptor for `CreateCharacterRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createCharacterRequestDescriptor =
    $convert.base64Decode(
        'ChZDcmVhdGVDaGFyYWN0ZXJSZXF1ZXN0EkgKDmNoYXJhY3RlckNsYXNzGAEgASgOMiAuYXBpLm'
        'NoYXJhY3Rlci52MS5DaGFyYWN0ZXJDbGFzc1IOY2hhcmFjdGVyQ2xhc3M=');

@$core.Deprecated('Use createCharacterReplyDescriptor instead')
const CreateCharacterReply$json = {
  '1': 'CreateCharacterReply',
};

/// Descriptor for `CreateCharacterReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createCharacterReplyDescriptor =
    $convert.base64Decode('ChRDcmVhdGVDaGFyYWN0ZXJSZXBseQ==');

@$core.Deprecated('Use getCharacterRequestDescriptor instead')
const GetCharacterRequest$json = {
  '1': 'GetCharacterRequest',
};

/// Descriptor for `GetCharacterRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCharacterRequestDescriptor =
    $convert.base64Decode('ChNHZXRDaGFyYWN0ZXJSZXF1ZXN0');

@$core.Deprecated('Use getCharacterReplyDescriptor instead')
const GetCharacterReply$json = {
  '1': 'GetCharacterReply',
  '2': [
    {
      '1': 'character',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.api.character.v1.Character',
      '10': 'character'
    },
  ],
};

/// Descriptor for `GetCharacterReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCharacterReplyDescriptor = $convert.base64Decode(
    'ChFHZXRDaGFyYWN0ZXJSZXBseRI5CgljaGFyYWN0ZXIYASABKAsyGy5hcGkuY2hhcmFjdGVyLn'
    'YxLkNoYXJhY3RlclIJY2hhcmFjdGVy');

@$core.Deprecated('Use updateCharacterRequestDescriptor instead')
const UpdateCharacterRequest$json = {
  '1': 'UpdateCharacterRequest',
  '2': [
    {
      '1': 'character',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.api.character.v1.Character',
      '10': 'character'
    },
  ],
};

/// Descriptor for `UpdateCharacterRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateCharacterRequestDescriptor =
    $convert.base64Decode(
        'ChZVcGRhdGVDaGFyYWN0ZXJSZXF1ZXN0EjkKCWNoYXJhY3RlchgBIAEoCzIbLmFwaS5jaGFyYW'
        'N0ZXIudjEuQ2hhcmFjdGVyUgljaGFyYWN0ZXI=');

@$core.Deprecated('Use updateCharacterReplyDescriptor instead')
const UpdateCharacterReply$json = {
  '1': 'UpdateCharacterReply',
  '2': [
    {
      '1': 'character',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.api.character.v1.Character',
      '10': 'character'
    },
  ],
};

/// Descriptor for `UpdateCharacterReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateCharacterReplyDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVDaGFyYWN0ZXJSZXBseRI5CgljaGFyYWN0ZXIYASABKAsyGy5hcGkuY2hhcmFjdG'
    'VyLnYxLkNoYXJhY3RlclIJY2hhcmFjdGVy');

@$core.Deprecated('Use allocateStatPointRequestDescriptor instead')
const AllocateStatPointRequest$json = {
  '1': 'AllocateStatPointRequest',
  '2': [
    {
      '1': 'stat',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.api.character.v1.StatType',
      '10': 'stat'
    },
  ],
};

/// Descriptor for `AllocateStatPointRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List allocateStatPointRequestDescriptor =
    $convert.base64Decode(
        'ChhBbGxvY2F0ZVN0YXRQb2ludFJlcXVlc3QSLgoEc3RhdBgBIAEoDjIaLmFwaS5jaGFyYWN0ZX'
        'IudjEuU3RhdFR5cGVSBHN0YXQ=');

@$core.Deprecated('Use allocateStatPointReplyDescriptor instead')
const AllocateStatPointReply$json = {
  '1': 'AllocateStatPointReply',
  '2': [
    {
      '1': 'character',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.api.character.v1.Character',
      '10': 'character'
    },
  ],
};

/// Descriptor for `AllocateStatPointReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List allocateStatPointReplyDescriptor =
    $convert.base64Decode(
        'ChZBbGxvY2F0ZVN0YXRQb2ludFJlcGx5EjkKCWNoYXJhY3RlchgBIAEoCzIbLmFwaS5jaGFyYW'
        'N0ZXIudjEuQ2hhcmFjdGVyUgljaGFyYWN0ZXI=');

@$core.Deprecated('Use reviveRequestDescriptor instead')
const ReviveRequest$json = {
  '1': 'ReviveRequest',
};

/// Descriptor for `ReviveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reviveRequestDescriptor =
    $convert.base64Decode('Cg1SZXZpdmVSZXF1ZXN0');

@$core.Deprecated('Use reviveReplyDescriptor instead')
const ReviveReply$json = {
  '1': 'ReviveReply',
  '2': [
    {
      '1': 'character',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.api.character.v1.Character',
      '10': 'character'
    },
  ],
};

/// Descriptor for `ReviveReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reviveReplyDescriptor = $convert.base64Decode(
    'CgtSZXZpdmVSZXBseRI5CgljaGFyYWN0ZXIYASABKAsyGy5hcGkuY2hhcmFjdGVyLnYxLkNoYX'
    'JhY3RlclIJY2hhcmFjdGVy');
