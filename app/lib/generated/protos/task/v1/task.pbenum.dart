// This is a generated file - do not edit.
//
// Generated from task/v1/task.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// TaskType — habit (daily repeat), daily (weekday repeat), todo (due date).
class TaskType extends $pb.ProtobufEnum {
  /// Unspecified type; used as the zero value.
  static const TaskType TASK_TYPE_UNSPECIFIED =
      TaskType._(0, _omitEnumNames ? '' : 'TASK_TYPE_UNSPECIFIED');

  /// Habit — repeats every day.
  static const TaskType TASK_TYPE_HABIT =
      TaskType._(1, _omitEnumNames ? '' : 'TASK_TYPE_HABIT');

  /// Daily — repeats on the selected weekdays.
  static const TaskType TASK_TYPE_DAILY =
      TaskType._(2, _omitEnumNames ? '' : 'TASK_TYPE_DAILY');

  /// Todo — one-off task with an optional due date.
  static const TaskType TASK_TYPE_TODO =
      TaskType._(3, _omitEnumNames ? '' : 'TASK_TYPE_TODO');

  static const $core.List<TaskType> values = <TaskType>[
    TASK_TYPE_UNSPECIFIED,
    TASK_TYPE_HABIT,
    TASK_TYPE_DAILY,
    TASK_TYPE_TODO,
  ];

  static final $core.List<TaskType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static TaskType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TaskType._(super.value, super.name);
}

/// TaskDifficulty — drives base EXP/gold rewards.
class TaskDifficulty extends $pb.ProtobufEnum {
  /// Unspecified difficulty; used as the zero value.
  static const TaskDifficulty TASK_DIFFICULTY_UNSPECIFIED =
      TaskDifficulty._(0, _omitEnumNames ? '' : 'TASK_DIFFICULTY_UNSPECIFIED');

  /// Easy — lowest base reward (15 EXP / 5 gold).
  static const TaskDifficulty TASK_DIFFICULTY_EASY =
      TaskDifficulty._(1, _omitEnumNames ? '' : 'TASK_DIFFICULTY_EASY');

  /// Medium — default difficulty (30 EXP / 10 gold).
  static const TaskDifficulty TASK_DIFFICULTY_MEDIUM =
      TaskDifficulty._(2, _omitEnumNames ? '' : 'TASK_DIFFICULTY_MEDIUM');

  /// Hard — highest base reward (50 EXP / 20 gold).
  static const TaskDifficulty TASK_DIFFICULTY_HARD =
      TaskDifficulty._(3, _omitEnumNames ? '' : 'TASK_DIFFICULTY_HARD');

  static const $core.List<TaskDifficulty> values = <TaskDifficulty>[
    TASK_DIFFICULTY_UNSPECIFIED,
    TASK_DIFFICULTY_EASY,
    TASK_DIFFICULTY_MEDIUM,
    TASK_DIFFICULTY_HARD,
  ];

  static final $core.List<TaskDifficulty?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static TaskDifficulty? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TaskDifficulty._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
