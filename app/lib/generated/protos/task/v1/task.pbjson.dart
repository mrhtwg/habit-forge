// This is a generated file - do not edit.
//
// Generated from task/v1/task.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use taskTypeDescriptor instead')
const TaskType$json = {
  '1': 'TaskType',
  '2': [
    {'1': 'TASK_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'TASK_TYPE_HABIT', '2': 1},
    {'1': 'TASK_TYPE_DAILY', '2': 2},
    {'1': 'TASK_TYPE_TODO', '2': 3},
  ],
};

/// Descriptor for `TaskType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List taskTypeDescriptor = $convert.base64Decode(
    'CghUYXNrVHlwZRIZChVUQVNLX1RZUEVfVU5TUEVDSUZJRUQQABITCg9UQVNLX1RZUEVfSEFCSV'
    'QQARITCg9UQVNLX1RZUEVfREFJTFkQAhISCg5UQVNLX1RZUEVfVE9ETxAD');

@$core.Deprecated('Use taskDifficultyDescriptor instead')
const TaskDifficulty$json = {
  '1': 'TaskDifficulty',
  '2': [
    {'1': 'TASK_DIFFICULTY_UNSPECIFIED', '2': 0},
    {'1': 'TASK_DIFFICULTY_EASY', '2': 1},
    {'1': 'TASK_DIFFICULTY_MEDIUM', '2': 2},
    {'1': 'TASK_DIFFICULTY_HARD', '2': 3},
  ],
};

/// Descriptor for `TaskDifficulty`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List taskDifficultyDescriptor = $convert.base64Decode(
    'Cg5UYXNrRGlmZmljdWx0eRIfChtUQVNLX0RJRkZJQ1VMVFlfVU5TUEVDSUZJRUQQABIYChRUQV'
    'NLX0RJRkZJQ1VMVFlfRUFTWRABEhoKFlRBU0tfRElGRklDVUxUWV9NRURJVU0QAhIYChRUQVNL'
    'X0RJRkZJQ1VMVFlfSEFSRBAD');

@$core.Deprecated('Use taskDescriptor instead')
const Task$json = {
  '1': 'Task',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.api.task.v1.TaskType',
      '10': 'type'
    },
    {
      '1': 'difficulty',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.api.task.v1.TaskDifficulty',
      '10': 'difficulty'
    },
    {'1': 'tags', '3': 6, '4': 3, '5': 9, '10': 'tags'},
    {'1': 'is_completed', '3': 7, '4': 1, '5': 8, '10': 'isCompleted'},
    {'1': 'completed_at', '3': 8, '4': 1, '5': 3, '10': 'completedAt'},
    {'1': 'due_date', '3': 9, '4': 1, '5': 3, '10': 'dueDate'},
    {'1': 'repeat_days', '3': 10, '4': 3, '5': 5, '10': 'repeatDays'},
    {'1': 'streak', '3': 11, '4': 1, '5': 5, '10': 'streak'},
    {'1': 'last_streak_date', '3': 12, '4': 1, '5': 3, '10': 'lastStreakDate'},
    {
      '1': 'custom_exp_reward',
      '3': 13,
      '4': 1,
      '5': 5,
      '10': 'customExpReward'
    },
    {
      '1': 'custom_gold_reward',
      '3': 14,
      '4': 1,
      '5': 5,
      '10': 'customGoldReward'
    },
    {'1': 'priority', '3': 15, '4': 1, '5': 9, '10': 'priority'},
    {'1': 'hp_penalty', '3': 16, '4': 1, '5': 5, '10': 'hpPenalty'},
    {'1': 'is_skipped', '3': 17, '4': 1, '5': 8, '10': 'isSkipped'},
    {'1': 'created_at', '3': 18, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'updated_at', '3': 19, '4': 1, '5': 3, '10': 'updatedAt'},
  ],
};

/// Descriptor for `Task`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskDescriptor = $convert.base64Decode(
    'CgRUYXNrEg4KAmlkGAEgASgJUgJpZBIUCgV0aXRsZRgCIAEoCVIFdGl0bGUSIAoLZGVzY3JpcH'
    'Rpb24YAyABKAlSC2Rlc2NyaXB0aW9uEikKBHR5cGUYBCABKA4yFS5hcGkudGFzay52MS5UYXNr'
    'VHlwZVIEdHlwZRI7CgpkaWZmaWN1bHR5GAUgASgOMhsuYXBpLnRhc2sudjEuVGFza0RpZmZpY3'
    'VsdHlSCmRpZmZpY3VsdHkSEgoEdGFncxgGIAMoCVIEdGFncxIhCgxpc19jb21wbGV0ZWQYByAB'
    'KAhSC2lzQ29tcGxldGVkEiEKDGNvbXBsZXRlZF9hdBgIIAEoA1ILY29tcGxldGVkQXQSGQoIZH'
    'VlX2RhdGUYCSABKANSB2R1ZURhdGUSHwoLcmVwZWF0X2RheXMYCiADKAVSCnJlcGVhdERheXMS'
    'FgoGc3RyZWFrGAsgASgFUgZzdHJlYWsSKAoQbGFzdF9zdHJlYWtfZGF0ZRgMIAEoA1IObGFzdF'
    'N0cmVha0RhdGUSKgoRY3VzdG9tX2V4cF9yZXdhcmQYDSABKAVSD2N1c3RvbUV4cFJld2FyZBIs'
    'ChJjdXN0b21fZ29sZF9yZXdhcmQYDiABKAVSEGN1c3RvbUdvbGRSZXdhcmQSGgoIcHJpb3JpdH'
    'kYDyABKAlSCHByaW9yaXR5Eh0KCmhwX3BlbmFsdHkYECABKAVSCWhwUGVuYWx0eRIdCgppc19z'
    'a2lwcGVkGBEgASgIUglpc1NraXBwZWQSHQoKY3JlYXRlZF9hdBgSIAEoA1IJY3JlYXRlZEF0Eh'
    '0KCnVwZGF0ZWRfYXQYEyABKANSCXVwZGF0ZWRBdA==');

@$core.Deprecated('Use listTasksRequestDescriptor instead')
const ListTasksRequest$json = {
  '1': 'ListTasksRequest',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.api.task.v1.TaskType',
      '10': 'type'
    },
    {
      '1': 'difficulty',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.api.task.v1.TaskDifficulty',
      '10': 'difficulty'
    },
    {'1': 'tags', '3': 3, '4': 3, '5': 9, '10': 'tags'},
    {'1': 'only_due_today', '3': 4, '4': 1, '5': 8, '10': 'onlyDueToday'},
    {
      '1': 'include_completed',
      '3': 5,
      '4': 1,
      '5': 8,
      '10': 'includeCompleted'
    },
  ],
};

/// Descriptor for `ListTasksRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTasksRequestDescriptor = $convert.base64Decode(
    'ChBMaXN0VGFza3NSZXF1ZXN0EikKBHR5cGUYASABKA4yFS5hcGkudGFzay52MS5UYXNrVHlwZV'
    'IEdHlwZRI7CgpkaWZmaWN1bHR5GAIgASgOMhsuYXBpLnRhc2sudjEuVGFza0RpZmZpY3VsdHlS'
    'CmRpZmZpY3VsdHkSEgoEdGFncxgDIAMoCVIEdGFncxIkCg5vbmx5X2R1ZV90b2RheRgEIAEoCF'
    'IMb25seUR1ZVRvZGF5EisKEWluY2x1ZGVfY29tcGxldGVkGAUgASgIUhBpbmNsdWRlQ29tcGxl'
    'dGVk');

@$core.Deprecated('Use listTasksReplyDescriptor instead')
const ListTasksReply$json = {
  '1': 'ListTasksReply',
  '2': [
    {
      '1': 'tasks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.api.task.v1.Task',
      '10': 'tasks'
    },
  ],
};

/// Descriptor for `ListTasksReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTasksReplyDescriptor = $convert.base64Decode(
    'Cg5MaXN0VGFza3NSZXBseRInCgV0YXNrcxgBIAMoCzIRLmFwaS50YXNrLnYxLlRhc2tSBXRhc2'
    'tz');

@$core.Deprecated('Use getTaskRequestDescriptor instead')
const GetTaskRequest$json = {
  '1': 'GetTaskRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetTaskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTaskRequestDescriptor =
    $convert.base64Decode('Cg5HZXRUYXNrUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use getTaskReplyDescriptor instead')
const GetTaskReply$json = {
  '1': 'GetTaskReply',
  '2': [
    {
      '1': 'task',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.api.task.v1.Task',
      '10': 'task'
    },
  ],
};

/// Descriptor for `GetTaskReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTaskReplyDescriptor = $convert.base64Decode(
    'CgxHZXRUYXNrUmVwbHkSJQoEdGFzaxgBIAEoCzIRLmFwaS50YXNrLnYxLlRhc2tSBHRhc2s=');

@$core.Deprecated('Use createTaskRequestDescriptor instead')
const CreateTaskRequest$json = {
  '1': 'CreateTaskRequest',
  '2': [
    {
      '1': 'task',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.api.task.v1.Task',
      '10': 'task'
    },
  ],
};

/// Descriptor for `CreateTaskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createTaskRequestDescriptor = $convert.base64Decode(
    'ChFDcmVhdGVUYXNrUmVxdWVzdBIlCgR0YXNrGAEgASgLMhEuYXBpLnRhc2sudjEuVGFza1IEdG'
    'Fzaw==');

@$core.Deprecated('Use createTaskReplyDescriptor instead')
const CreateTaskReply$json = {
  '1': 'CreateTaskReply',
  '2': [
    {
      '1': 'task',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.api.task.v1.Task',
      '10': 'task'
    },
  ],
};

/// Descriptor for `CreateTaskReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createTaskReplyDescriptor = $convert.base64Decode(
    'Cg9DcmVhdGVUYXNrUmVwbHkSJQoEdGFzaxgBIAEoCzIRLmFwaS50YXNrLnYxLlRhc2tSBHRhc2'
    's=');

@$core.Deprecated('Use updateTaskRequestDescriptor instead')
const UpdateTaskRequest$json = {
  '1': 'UpdateTaskRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'task',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.api.task.v1.Task',
      '10': 'task'
    },
  ],
};

/// Descriptor for `UpdateTaskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateTaskRequestDescriptor = $convert.base64Decode(
    'ChFVcGRhdGVUYXNrUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSJQoEdGFzaxgCIAEoCzIRLmFwaS'
    '50YXNrLnYxLlRhc2tSBHRhc2s=');

@$core.Deprecated('Use updateTaskReplyDescriptor instead')
const UpdateTaskReply$json = {
  '1': 'UpdateTaskReply',
  '2': [
    {
      '1': 'task',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.api.task.v1.Task',
      '10': 'task'
    },
  ],
};

/// Descriptor for `UpdateTaskReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateTaskReplyDescriptor = $convert.base64Decode(
    'Cg9VcGRhdGVUYXNrUmVwbHkSJQoEdGFzaxgBIAEoCzIRLmFwaS50YXNrLnYxLlRhc2tSBHRhc2'
    's=');

@$core.Deprecated('Use deleteTaskRequestDescriptor instead')
const DeleteTaskRequest$json = {
  '1': 'DeleteTaskRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DeleteTaskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteTaskRequestDescriptor =
    $convert.base64Decode('ChFEZWxldGVUYXNrUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use deleteTaskReplyDescriptor instead')
const DeleteTaskReply$json = {
  '1': 'DeleteTaskReply',
};

/// Descriptor for `DeleteTaskReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteTaskReplyDescriptor =
    $convert.base64Decode('Cg9EZWxldGVUYXNrUmVwbHk=');

@$core.Deprecated('Use completeTaskRequestDescriptor instead')
const CompleteTaskRequest$json = {
  '1': 'CompleteTaskRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `CompleteTaskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List completeTaskRequestDescriptor = $convert
    .base64Decode('ChNDb21wbGV0ZVRhc2tSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZA==');

@$core.Deprecated('Use completeTaskReplyDescriptor instead')
const CompleteTaskReply$json = {
  '1': 'CompleteTaskReply',
  '2': [
    {
      '1': 'task',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.api.task.v1.Task',
      '10': 'task'
    },
    {'1': 'exp_reward', '3': 2, '4': 1, '5': 5, '10': 'expReward'},
    {'1': 'gold_reward', '3': 3, '4': 1, '5': 5, '10': 'goldReward'},
    {'1': 'hp_change', '3': 4, '4': 1, '5': 5, '10': 'hpChange'},
  ],
};

/// Descriptor for `CompleteTaskReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List completeTaskReplyDescriptor = $convert.base64Decode(
    'ChFDb21wbGV0ZVRhc2tSZXBseRIlCgR0YXNrGAEgASgLMhEuYXBpLnRhc2sudjEuVGFza1IEdG'
    'FzaxIdCgpleHBfcmV3YXJkGAIgASgFUglleHBSZXdhcmQSHwoLZ29sZF9yZXdhcmQYAyABKAVS'
    'CmdvbGRSZXdhcmQSGwoJaHBfY2hhbmdlGAQgASgFUghocENoYW5nZQ==');
