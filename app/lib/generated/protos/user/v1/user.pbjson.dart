// This is a generated file - do not edit.
//
// Generated from user/v1/user.proto.

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
      '1': 'onboarding_completed',
      '3': 1,
      '4': 1,
      '5': 8,
      '10': 'onboardingCompleted'
    },
    {
      '1': 'last_onboarding_step',
      '3': 2,
      '4': 1,
      '5': 5,
      '10': 'lastOnboardingStep'
    },
    {'1': 'current_gold', '3': 3, '4': 1, '5': 3, '10': 'currentGold'},
    {'1': 'current_gems', '3': 4, '4': 1, '5': 3, '10': 'currentGems'},
    {'1': 'sound_enabled', '3': 5, '4': 1, '5': 8, '10': 'soundEnabled'},
    {'1': 'haptic_enabled', '3': 6, '4': 1, '5': 8, '10': 'hapticEnabled'},
    {
      '1': 'notifications_enabled',
      '3': 7,
      '4': 1,
      '5': 8,
      '10': 'notificationsEnabled'
    },
    {
      '1': 'total_tasks_completed',
      '3': 8,
      '4': 1,
      '5': 3,
      '10': 'totalTasksCompleted'
    },
    {'1': 'first_task_date', '3': 9, '4': 1, '5': 3, '10': 'firstTaskDate'},
  ],
};

/// Descriptor for `UserPrefs`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userPrefsDescriptor = $convert.base64Decode(
    'CglVc2VyUHJlZnMSMQoUb25ib2FyZGluZ19jb21wbGV0ZWQYASABKAhSE29uYm9hcmRpbmdDb2'
    '1wbGV0ZWQSMAoUbGFzdF9vbmJvYXJkaW5nX3N0ZXAYAiABKAVSEmxhc3RPbmJvYXJkaW5nU3Rl'
    'cBIhCgxjdXJyZW50X2dvbGQYAyABKANSC2N1cnJlbnRHb2xkEiEKDGN1cnJlbnRfZ2VtcxgEIA'
    'EoA1ILY3VycmVudEdlbXMSIwoNc291bmRfZW5hYmxlZBgFIAEoCFIMc291bmRFbmFibGVkEiUK'
    'DmhhcHRpY19lbmFibGVkGAYgASgIUg1oYXB0aWNFbmFibGVkEjMKFW5vdGlmaWNhdGlvbnNfZW'
    '5hYmxlZBgHIAEoCFIUbm90aWZpY2F0aW9uc0VuYWJsZWQSMgoVdG90YWxfdGFza3NfY29tcGxl'
    'dGVkGAggASgDUhN0b3RhbFRhc2tzQ29tcGxldGVkEiYKD2ZpcnN0X3Rhc2tfZGF0ZRgJIAEoA1'
    'INZmlyc3RUYXNrRGF0ZQ==');

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

const $core.Map<$core.String, $core.dynamic> UserServiceBase$json = {
  '1': 'UserService',
  '2': [
    {
      '1': 'GetPrefs',
      '2': '.api.user.v1.GetPrefsRequest',
      '3': '.api.user.v1.GetPrefsReply',
      '4': {}
    },
    {
      '1': 'UpdatePrefs',
      '2': '.api.user.v1.UpdatePrefsRequest',
      '3': '.api.user.v1.UpdatePrefsReply',
      '4': {}
    },
  ],
};

@$core.Deprecated('Use userServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    UserServiceBase$messageJson = {
  '.api.user.v1.GetPrefsRequest': GetPrefsRequest$json,
  '.api.user.v1.GetPrefsReply': GetPrefsReply$json,
  '.api.user.v1.UserPrefs': UserPrefs$json,
  '.api.user.v1.UpdatePrefsRequest': UpdatePrefsRequest$json,
  '.api.user.v1.UpdatePrefsReply': UpdatePrefsReply$json,
};

/// Descriptor for `UserService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List userServiceDescriptor = $convert.base64Decode(
    'CgtVc2VyU2VydmljZRJgCghHZXRQcmVmcxIcLmFwaS51c2VyLnYxLkdldFByZWZzUmVxdWVzdB'
    'oaLmFwaS51c2VyLnYxLkdldFByZWZzUmVwbHkiGoLT5JMCFBISL2FwaS92MS91c2VyL3ByZWZz'
    'EmwKC1VwZGF0ZVByZWZzEh8uYXBpLnVzZXIudjEuVXBkYXRlUHJlZnNSZXF1ZXN0Gh0uYXBpLn'
    'VzZXIudjEuVXBkYXRlUHJlZnNSZXBseSIdgtPkkwIXGhIvYXBpL3YxL3VzZXIvcHJlZnM6ASo=');
