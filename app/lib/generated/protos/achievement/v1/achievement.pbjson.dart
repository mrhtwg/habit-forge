// This is a generated file - do not edit.
//
// Generated from achievement/v1/achievement.proto.

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

@$core.Deprecated('Use achievementDescriptor instead')
const Achievement$json = {
  '1': 'Achievement',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'condition_type', '3': 4, '4': 1, '5': 9, '10': 'conditionType'},
    {'1': 'threshold', '3': 5, '4': 1, '5': 5, '10': 'threshold'},
    {'1': 'progress', '3': 6, '4': 1, '5': 5, '10': 'progress'},
    {'1': 'is_unlocked', '3': 7, '4': 1, '5': 8, '10': 'isUnlocked'},
    {'1': 'unlocked_at', '3': 8, '4': 1, '5': 3, '10': 'unlockedAt'},
    {'1': 'gem_reward', '3': 9, '4': 1, '5': 5, '10': 'gemReward'},
  ],
};

/// Descriptor for `Achievement`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List achievementDescriptor = $convert.base64Decode(
    'CgtBY2hpZXZlbWVudBIOCgJpZBgBIAEoCVICaWQSFAoFdGl0bGUYAiABKAlSBXRpdGxlEiAKC2'
    'Rlc2NyaXB0aW9uGAMgASgJUgtkZXNjcmlwdGlvbhIlCg5jb25kaXRpb25fdHlwZRgEIAEoCVIN'
    'Y29uZGl0aW9uVHlwZRIcCgl0aHJlc2hvbGQYBSABKAVSCXRocmVzaG9sZBIaCghwcm9ncmVzcx'
    'gGIAEoBVIIcHJvZ3Jlc3MSHwoLaXNfdW5sb2NrZWQYByABKAhSCmlzVW5sb2NrZWQSHwoLdW5s'
    'b2NrZWRfYXQYCCABKANSCnVubG9ja2VkQXQSHQoKZ2VtX3Jld2FyZBgJIAEoBVIJZ2VtUmV3YX'
    'Jk');

@$core.Deprecated('Use listAchievementsRequestDescriptor instead')
const ListAchievementsRequest$json = {
  '1': 'ListAchievementsRequest',
};

/// Descriptor for `ListAchievementsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAchievementsRequestDescriptor =
    $convert.base64Decode('ChdMaXN0QWNoaWV2ZW1lbnRzUmVxdWVzdA==');

@$core.Deprecated('Use listAchievementsReplyDescriptor instead')
const ListAchievementsReply$json = {
  '1': 'ListAchievementsReply',
  '2': [
    {
      '1': 'achievements',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.api.achievement.v1.Achievement',
      '10': 'achievements'
    },
  ],
};

/// Descriptor for `ListAchievementsReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAchievementsReplyDescriptor = $convert.base64Decode(
    'ChVMaXN0QWNoaWV2ZW1lbnRzUmVwbHkSQwoMYWNoaWV2ZW1lbnRzGAEgAygLMh8uYXBpLmFjaG'
    'lldmVtZW50LnYxLkFjaGlldmVtZW50UgxhY2hpZXZlbWVudHM=');

@$core.Deprecated('Use unlockRequestDescriptor instead')
const UnlockRequest$json = {
  '1': 'UnlockRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `UnlockRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unlockRequestDescriptor =
    $convert.base64Decode('Cg1VbmxvY2tSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZA==');

@$core.Deprecated('Use unlockReplyDescriptor instead')
const UnlockReply$json = {
  '1': 'UnlockReply',
  '2': [
    {
      '1': 'achievement',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.api.achievement.v1.Achievement',
      '10': 'achievement'
    },
    {'1': 'gem_reward', '3': 2, '4': 1, '5': 5, '10': 'gemReward'},
  ],
};

/// Descriptor for `UnlockReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unlockReplyDescriptor = $convert.base64Decode(
    'CgtVbmxvY2tSZXBseRJBCgthY2hpZXZlbWVudBgBIAEoCzIfLmFwaS5hY2hpZXZlbWVudC52MS'
    '5BY2hpZXZlbWVudFILYWNoaWV2ZW1lbnQSHQoKZ2VtX3Jld2FyZBgCIAEoBVIJZ2VtUmV3YXJk');

const $core.Map<$core.String, $core.dynamic> AchievementServiceBase$json = {
  '1': 'AchievementService',
  '2': [
    {
      '1': 'ListAchievements',
      '2': '.api.achievement.v1.ListAchievementsRequest',
      '3': '.api.achievement.v1.ListAchievementsReply',
      '4': {}
    },
    {
      '1': 'Unlock',
      '2': '.api.achievement.v1.UnlockRequest',
      '3': '.api.achievement.v1.UnlockReply',
      '4': {}
    },
  ],
};

@$core.Deprecated('Use achievementServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    AchievementServiceBase$messageJson = {
  '.api.achievement.v1.ListAchievementsRequest': ListAchievementsRequest$json,
  '.api.achievement.v1.ListAchievementsReply': ListAchievementsReply$json,
  '.api.achievement.v1.Achievement': Achievement$json,
  '.api.achievement.v1.UnlockRequest': UnlockRequest$json,
  '.api.achievement.v1.UnlockReply': UnlockReply$json,
};

/// Descriptor for `AchievementService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List achievementServiceDescriptor = $convert.base64Decode(
    'ChJBY2hpZXZlbWVudFNlcnZpY2USiAEKEExpc3RBY2hpZXZlbWVudHMSKy5hcGkuYWNoaWV2ZW'
    '1lbnQudjEuTGlzdEFjaGlldmVtZW50c1JlcXVlc3QaKS5hcGkuYWNoaWV2ZW1lbnQudjEuTGlz'
    'dEFjaGlldmVtZW50c1JlcGx5IhyC0+STAhYSFC9hcGkvdjEvYWNoaWV2ZW1lbnRzEnkKBlVubG'
    '9jaxIhLmFwaS5hY2hpZXZlbWVudC52MS5VbmxvY2tSZXF1ZXN0Gh8uYXBpLmFjaGlldmVtZW50'
    'LnYxLlVubG9ja1JlcGx5IiuC0+STAiUiIC9hcGkvdjEvYWNoaWV2ZW1lbnRzL3tpZH0vdW5sb2'
    'NrOgEq');
