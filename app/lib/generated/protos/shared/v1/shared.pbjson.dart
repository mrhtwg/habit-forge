// This is a generated file - do not edit.
//
// Generated from api/shared/v1/shared.proto.

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

@$core.Deprecated('Use sysMaterialDescriptor instead')
const SysMaterial$json = {
  '1': 'SysMaterial',
  '2': [
    {'1': 'SYSMATERIAL_GOLD', '2': 0},
    {'1': 'SYSMATERIAL_GEM', '2': 1},
    {'1': 'SYSMATERIAL_EXP', '2': 2},
  ],
};

/// Descriptor for `SysMaterial`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sysMaterialDescriptor = $convert.base64Decode(
    'CgtTeXNNYXRlcmlhbBIUChBTWVNNQVRFUklBTF9HT0xEEAASEwoPU1lTTUFURVJJQUxfR0VNEA'
    'ESEwoPU1lTTUFURVJJQUxfRVhQEAI=');

@$core.Deprecated('Use equipmentSlotDescriptor instead')
const EquipmentSlot$json = {
  '1': 'EquipmentSlot',
  '2': [
    {'1': 'EQUIPMENT_SLOT_UNSPECIFIED', '2': 0},
    {'1': 'EQUIPMENT_SLOT_WEAPON', '2': 1},
    {'1': 'EQUIPMENT_SLOT_HELMET', '2': 2},
    {'1': 'EQUIPMENT_SLOT_ARMOR', '2': 3},
    {'1': 'EQUIPMENT_SLOT_ACCESSORY', '2': 4},
  ],
};

/// Descriptor for `EquipmentSlot`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List equipmentSlotDescriptor = $convert.base64Decode(
    'Cg1FcXVpcG1lbnRTbG90Eh4KGkVRVUlQTUVOVF9TTE9UX1VOU1BFQ0lGSUVEEAASGQoVRVFVSV'
    'BNRU5UX1NMT1RfV0VBUE9OEAESGQoVRVFVSVBNRU5UX1NMT1RfSEVMTUVUEAISGAoURVFVSVBN'
    'RU5UX1NMT1RfQVJNT1IQAxIcChhFUVVJUE1FTlRfU0xPVF9BQ0NFU1NPUlkQBA==');

@$core.Deprecated('Use equipmentRarityDescriptor instead')
const EquipmentRarity$json = {
  '1': 'EquipmentRarity',
  '2': [
    {'1': 'EQUIPMENT_RARITY_COMMON', '2': 0},
    {'1': 'EQUIPMENT_RARITY_RARE', '2': 1},
    {'1': 'EQUIPMENT_RARITY_EPIC', '2': 2},
    {'1': 'EQUIPMENT_RARITY_LEGENDARY', '2': 3},
  ],
};

/// Descriptor for `EquipmentRarity`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List equipmentRarityDescriptor = $convert.base64Decode(
    'Cg9FcXVpcG1lbnRSYXJpdHkSGwoXRVFVSVBNRU5UX1JBUklUWV9DT01NT04QABIZChVFUVVJUE'
    '1FTlRfUkFSSVRZX1JBUkUQARIZChVFUVVJUE1FTlRfUkFSSVRZX0VQSUMQAhIeChpFUVVJUE1F'
    'TlRfUkFSSVRZX0xFR0VOREFSWRAD');
