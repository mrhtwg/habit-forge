// This is a generated file - do not edit.
//
// Generated from api/task/v1/task_error.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// TaskErrorReason — business error codes for the task domain.
class TaskErrorReason extends $pb.ProtobufEnum {
  static const TaskErrorReason TASK_ALREADY_EXISTS =
      TaskErrorReason._(0, _omitEnumNames ? '' : 'TASK_ALREADY_EXISTS');
  static const TaskErrorReason TASK_NOT_FOUND =
      TaskErrorReason._(1, _omitEnumNames ? '' : 'TASK_NOT_FOUND');
  static const TaskErrorReason TASK_ALREADY_COMPLETED =
      TaskErrorReason._(2, _omitEnumNames ? '' : 'TASK_ALREADY_COMPLETED');

  static const $core.List<TaskErrorReason> values = <TaskErrorReason>[
    TASK_ALREADY_EXISTS,
    TASK_NOT_FOUND,
    TASK_ALREADY_COMPLETED,
  ];

  static final $core.List<TaskErrorReason?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static TaskErrorReason? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TaskErrorReason._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
