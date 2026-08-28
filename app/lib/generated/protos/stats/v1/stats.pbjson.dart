// This is a generated file - do not edit.
//
// Generated from stats/v1/stats.proto.

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

@$core.Deprecated('Use statsRangeDescriptor instead')
const StatsRange$json = {
  '1': 'StatsRange',
  '2': [
    {'1': 'STATS_RANGE_UNSPECIFIED', '2': 0},
    {'1': 'STATS_RANGE_DAY', '2': 1},
    {'1': 'STATS_RANGE_WEEK', '2': 2},
    {'1': 'STATS_RANGE_MONTH', '2': 3},
    {'1': 'STATS_RANGE_ALL', '2': 4},
  ],
};

/// Descriptor for `StatsRange`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List statsRangeDescriptor = $convert.base64Decode(
    'CgpTdGF0c1JhbmdlEhsKF1NUQVRTX1JBTkdFX1VOU1BFQ0lGSUVEEAASEwoPU1RBVFNfUkFOR0'
    'VfREFZEAESFAoQU1RBVFNfUkFOR0VfV0VFSxACEhUKEVNUQVRTX1JBTkdFX01PTlRIEAMSEwoP'
    'U1RBVFNfUkFOR0VfQUxMEAQ=');

@$core.Deprecated('Use timeSegmentDescriptor instead')
const TimeSegment$json = {
  '1': 'TimeSegment',
  '2': [
    {'1': 'label', '3': 1, '4': 1, '5': 9, '10': 'label'},
    {'1': 'completed_count', '3': 2, '4': 1, '5': 3, '10': 'completedCount'},
  ],
};

/// Descriptor for `TimeSegment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timeSegmentDescriptor = $convert.base64Decode(
    'CgtUaW1lU2VnbWVudBIUCgVsYWJlbBgBIAEoCVIFbGFiZWwSJwoPY29tcGxldGVkX2NvdW50GA'
    'IgASgDUg5jb21wbGV0ZWRDb3VudA==');

@$core.Deprecated('Use streakEntryDescriptor instead')
const StreakEntry$json = {
  '1': 'StreakEntry',
  '2': [
    {'1': 'task_id', '3': 1, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    {'1': 'streak', '3': 3, '4': 1, '5': 5, '10': 'streak'},
  ],
};

/// Descriptor for `StreakEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streakEntryDescriptor = $convert.base64Decode(
    'CgtTdHJlYWtFbnRyeRIXCgd0YXNrX2lkGAEgASgJUgZ0YXNrSWQSFAoFdGl0bGUYAiABKAlSBX'
    'RpdGxlEhYKBnN0cmVhaxgDIAEoBVIGc3RyZWFr');

@$core.Deprecated('Use statsReplyDescriptor instead')
const StatsReply$json = {
  '1': 'StatsReply',
  '2': [
    {
      '1': 'range',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.api.stats.v1.StatsRange',
      '10': 'range'
    },
    {
      '1': 'segments',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.api.stats.v1.TimeSegment',
      '10': 'segments'
    },
    {
      '1': 'streak_leaderboard',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.api.stats.v1.StreakEntry',
      '10': 'streakLeaderboard'
    },
    {
      '1': 'total_tasks_completed',
      '3': 4,
      '4': 1,
      '5': 3,
      '10': 'totalTasksCompleted'
    },
    {'1': 'total_gold_earned', '3': 5, '4': 1, '5': 3, '10': 'totalGoldEarned'},
    {'1': 'total_exp_earned', '3': 6, '4': 1, '5': 3, '10': 'totalExpEarned'},
  ],
};

/// Descriptor for `StatsReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List statsReplyDescriptor = $convert.base64Decode(
    'CgpTdGF0c1JlcGx5Ei4KBXJhbmdlGAEgASgOMhguYXBpLnN0YXRzLnYxLlN0YXRzUmFuZ2VSBX'
    'JhbmdlEjUKCHNlZ21lbnRzGAIgAygLMhkuYXBpLnN0YXRzLnYxLlRpbWVTZWdtZW50UghzZWdt'
    'ZW50cxJIChJzdHJlYWtfbGVhZGVyYm9hcmQYAyADKAsyGS5hcGkuc3RhdHMudjEuU3RyZWFrRW'
    '50cnlSEXN0cmVha0xlYWRlcmJvYXJkEjIKFXRvdGFsX3Rhc2tzX2NvbXBsZXRlZBgEIAEoA1IT'
    'dG90YWxUYXNrc0NvbXBsZXRlZBIqChF0b3RhbF9nb2xkX2Vhcm5lZBgFIAEoA1IPdG90YWxHb2'
    'xkRWFybmVkEigKEHRvdGFsX2V4cF9lYXJuZWQYBiABKANSDnRvdGFsRXhwRWFybmVk');

@$core.Deprecated('Use getStatsRequestDescriptor instead')
const GetStatsRequest$json = {
  '1': 'GetStatsRequest',
  '2': [
    {
      '1': 'range',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.api.stats.v1.StatsRange',
      '10': 'range'
    },
  ],
};

/// Descriptor for `GetStatsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStatsRequestDescriptor = $convert.base64Decode(
    'Cg9HZXRTdGF0c1JlcXVlc3QSLgoFcmFuZ2UYASABKA4yGC5hcGkuc3RhdHMudjEuU3RhdHNSYW'
    '5nZVIFcmFuZ2U=');

@$core.Deprecated('Use getStatsReplyDescriptor instead')
const GetStatsReply$json = {
  '1': 'GetStatsReply',
  '2': [
    {
      '1': 'stats',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.api.stats.v1.StatsReply',
      '10': 'stats'
    },
  ],
};

/// Descriptor for `GetStatsReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStatsReplyDescriptor = $convert.base64Decode(
    'Cg1HZXRTdGF0c1JlcGx5Ei4KBXN0YXRzGAEgASgLMhguYXBpLnN0YXRzLnYxLlN0YXRzUmVwbH'
    'lSBXN0YXRz');

const $core.Map<$core.String, $core.dynamic> StatsServiceBase$json = {
  '1': 'StatsService',
  '2': [
    {
      '1': 'GetStats',
      '2': '.api.stats.v1.GetStatsRequest',
      '3': '.api.stats.v1.GetStatsReply',
      '4': {}
    },
  ],
};

@$core.Deprecated('Use statsServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    StatsServiceBase$messageJson = {
  '.api.stats.v1.GetStatsRequest': GetStatsRequest$json,
  '.api.stats.v1.GetStatsReply': GetStatsReply$json,
  '.api.stats.v1.StatsReply': StatsReply$json,
  '.api.stats.v1.TimeSegment': TimeSegment$json,
  '.api.stats.v1.StreakEntry': StreakEntry$json,
};

/// Descriptor for `StatsService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List statsServiceDescriptor = $convert.base64Decode(
    'CgxTdGF0c1NlcnZpY2USXQoIR2V0U3RhdHMSHS5hcGkuc3RhdHMudjEuR2V0U3RhdHNSZXF1ZX'
    'N0GhsuYXBpLnN0YXRzLnYxLkdldFN0YXRzUmVwbHkiFYLT5JMCDxINL2FwaS92MS9zdGF0cw==');
