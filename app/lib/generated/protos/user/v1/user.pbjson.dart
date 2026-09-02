// This is a generated file - do not edit.
//
// Generated from api/user/v1/user.proto.

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

@$core.Deprecated('Use userPrefsDescriptor instead')
const UserPrefs$json = {
  '1': 'UserPrefs',
  '2': [
    {
      '1': 'charactor_class',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.api.character.v1.CharacterClass',
      '10': 'charactorClass'
    },
    {'1': 'current_gold', '3': 2, '4': 1, '5': 3, '10': 'currentGold'},
    {'1': 'current_gems', '3': 3, '4': 1, '5': 3, '10': 'currentGems'},
    {
      '1': 'notifications_enabled',
      '3': 4,
      '4': 1,
      '5': 8,
      '10': 'notificationsEnabled'
    },
    {
      '1': 'total_tasks_completed',
      '3': 5,
      '4': 1,
      '5': 3,
      '10': 'totalTasksCompleted'
    },
    {'1': 'total_tasks', '3': 6, '4': 1, '5': 3, '10': 'totalTasks'},
    {
      '1': 'today_tasks_completed',
      '3': 7,
      '4': 1,
      '5': 3,
      '10': 'todayTasksCompleted'
    },
    {'1': 'today_tasks', '3': 8, '4': 1, '5': 3, '10': 'todayTasks'},
    {'1': 'first_task_date', '3': 9, '4': 1, '5': 3, '10': 'firstTaskDate'},
    {
      '1': 'items',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.api.shop.v1.ShopItem',
      '10': 'items'
    },
  ],
};

/// Descriptor for `UserPrefs`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userPrefsDescriptor = $convert.base64Decode(
    'CglVc2VyUHJlZnMSSQoPY2hhcmFjdG9yX2NsYXNzGAEgASgOMiAuYXBpLmNoYXJhY3Rlci52MS'
    '5DaGFyYWN0ZXJDbGFzc1IOY2hhcmFjdG9yQ2xhc3MSIQoMY3VycmVudF9nb2xkGAIgASgDUgtj'
    'dXJyZW50R29sZBIhCgxjdXJyZW50X2dlbXMYAyABKANSC2N1cnJlbnRHZW1zEjMKFW5vdGlmaW'
    'NhdGlvbnNfZW5hYmxlZBgEIAEoCFIUbm90aWZpY2F0aW9uc0VuYWJsZWQSMgoVdG90YWxfdGFz'
    'a3NfY29tcGxldGVkGAUgASgDUhN0b3RhbFRhc2tzQ29tcGxldGVkEh8KC3RvdGFsX3Rhc2tzGA'
    'YgASgDUgp0b3RhbFRhc2tzEjIKFXRvZGF5X3Rhc2tzX2NvbXBsZXRlZBgHIAEoA1ITdG9kYXlU'
    'YXNrc0NvbXBsZXRlZBIfCgt0b2RheV90YXNrcxgIIAEoA1IKdG9kYXlUYXNrcxImCg9maXJzdF'
    '90YXNrX2RhdGUYCSABKANSDWZpcnN0VGFza0RhdGUSKwoFaXRlbXMYCiADKAsyFS5hcGkuc2hv'
    'cC52MS5TaG9wSXRlbVIFaXRlbXM=');

@$core.Deprecated('Use getPrefsRequestDescriptor instead')
const GetPrefsRequest$json = {
  '1': 'GetPrefsRequest',
};

/// Descriptor for `GetPrefsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPrefsRequestDescriptor =
    $convert.base64Decode('Cg9HZXRQcmVmc1JlcXVlc3Q=');

@$core.Deprecated('Use getPrefsReplyDescriptor instead')
const GetPrefsReply$json = {
  '1': 'GetPrefsReply',
  '2': [
    {
      '1': 'prefs',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.api.user.v1.UserPrefs',
      '10': 'prefs'
    },
  ],
};

/// Descriptor for `GetPrefsReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPrefsReplyDescriptor = $convert.base64Decode(
    'Cg1HZXRQcmVmc1JlcGx5EiwKBXByZWZzGAEgASgLMhYuYXBpLnVzZXIudjEuVXNlclByZWZzUg'
    'VwcmVmcw==');

@$core.Deprecated('Use updatePrefsRequestDescriptor instead')
const UpdatePrefsRequest$json = {
  '1': 'UpdatePrefsRequest',
  '2': [
    {
      '1': 'prefs',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.api.user.v1.UserPrefs',
      '10': 'prefs'
    },
  ],
};

/// Descriptor for `UpdatePrefsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updatePrefsRequestDescriptor = $convert.base64Decode(
    'ChJVcGRhdGVQcmVmc1JlcXVlc3QSLAoFcHJlZnMYASABKAsyFi5hcGkudXNlci52MS5Vc2VyUH'
    'JlZnNSBXByZWZz');

@$core.Deprecated('Use updatePrefsReplyDescriptor instead')
const UpdatePrefsReply$json = {
  '1': 'UpdatePrefsReply',
  '2': [
    {
      '1': 'prefs',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.api.user.v1.UserPrefs',
      '10': 'prefs'
    },
  ],
};

/// Descriptor for `UpdatePrefsReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updatePrefsReplyDescriptor = $convert.base64Decode(
    'ChBVcGRhdGVQcmVmc1JlcGx5EiwKBXByZWZzGAEgASgLMhYuYXBpLnVzZXIudjEuVXNlclByZW'
    'ZzUgVwcmVmcw==');
