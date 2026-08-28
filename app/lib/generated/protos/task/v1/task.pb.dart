// This is a generated file - do not edit.
//
// Generated from api/task/v1/task.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'task.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'task.pbenum.dart';

/// Task — a habit, daily or todo task owned by the current user.
class Task extends $pb.GeneratedMessage {
  factory Task({
    $core.String? id,
    $core.String? title,
    $core.String? description,
    TaskType? type,
    TaskDifficulty? difficulty,
    $core.Iterable<$core.String>? tags,
    $core.bool? isCompleted,
    $fixnum.Int64? completedAt,
    $fixnum.Int64? dueDate,
    $core.Iterable<$core.int>? repeatDays,
    $core.int? streak,
    $fixnum.Int64? lastStreakDate,
    $core.int? customExpReward,
    $core.int? customGoldReward,
    $core.String? priority,
    $core.int? hpPenalty,
    $core.bool? isSkipped,
    $fixnum.Int64? createdAt,
    $fixnum.Int64? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (title != null) result.title = title;
    if (description != null) result.description = description;
    if (type != null) result.type = type;
    if (difficulty != null) result.difficulty = difficulty;
    if (tags != null) result.tags.addAll(tags);
    if (isCompleted != null) result.isCompleted = isCompleted;
    if (completedAt != null) result.completedAt = completedAt;
    if (dueDate != null) result.dueDate = dueDate;
    if (repeatDays != null) result.repeatDays.addAll(repeatDays);
    if (streak != null) result.streak = streak;
    if (lastStreakDate != null) result.lastStreakDate = lastStreakDate;
    if (customExpReward != null) result.customExpReward = customExpReward;
    if (customGoldReward != null) result.customGoldReward = customGoldReward;
    if (priority != null) result.priority = priority;
    if (hpPenalty != null) result.hpPenalty = hpPenalty;
    if (isSkipped != null) result.isSkipped = isSkipped;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  Task._();

  factory Task.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Task.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Task',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.task.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aE<TaskType>(4, _omitFieldNames ? '' : 'type',
        enumValues: TaskType.values)
    ..aE<TaskDifficulty>(5, _omitFieldNames ? '' : 'difficulty',
        enumValues: TaskDifficulty.values)
    ..pPS(6, _omitFieldNames ? '' : 'tags')
    ..aOB(7, _omitFieldNames ? '' : 'isCompleted')
    ..aInt64(8, _omitFieldNames ? '' : 'completedAt')
    ..aInt64(9, _omitFieldNames ? '' : 'dueDate')
    ..p<$core.int>(10, _omitFieldNames ? '' : 'repeatDays', $pb.PbFieldType.K3)
    ..aI(11, _omitFieldNames ? '' : 'streak')
    ..aInt64(12, _omitFieldNames ? '' : 'lastStreakDate')
    ..aI(13, _omitFieldNames ? '' : 'customExpReward')
    ..aI(14, _omitFieldNames ? '' : 'customGoldReward')
    ..aOS(15, _omitFieldNames ? '' : 'priority')
    ..aI(16, _omitFieldNames ? '' : 'hpPenalty')
    ..aOB(17, _omitFieldNames ? '' : 'isSkipped')
    ..aInt64(18, _omitFieldNames ? '' : 'createdAt')
    ..aInt64(19, _omitFieldNames ? '' : 'updatedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Task clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Task copyWith(void Function(Task) updates) =>
      super.copyWith((message) => updates(message as Task)) as Task;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Task create() => Task._();
  @$core.override
  Task createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Task getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Task>(create);
  static Task? _defaultInstance;

  /// Unique task id.
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  /// Short display title.
  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => $_clearField(2);

  /// Optional longer description.
  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  /// Task kind (habit / daily / todo).
  @$pb.TagNumber(4)
  TaskType get type => $_getN(3);
  @$pb.TagNumber(4)
  set type(TaskType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasType() => $_has(3);
  @$pb.TagNumber(4)
  void clearType() => $_clearField(4);

  /// Difficulty that drives the base EXP/gold reward.
  @$pb.TagNumber(5)
  TaskDifficulty get difficulty => $_getN(4);
  @$pb.TagNumber(5)
  set difficulty(TaskDifficulty value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasDifficulty() => $_has(4);
  @$pb.TagNumber(5)
  void clearDifficulty() => $_clearField(5);

  /// Free-form tags used for filtering.
  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get tags => $_getList(5);

  /// Whether the task is currently completed.
  @$pb.TagNumber(7)
  $core.bool get isCompleted => $_getBF(6);
  @$pb.TagNumber(7)
  set isCompleted($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIsCompleted() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsCompleted() => $_clearField(7);

  /// Completion time, unix millis; zero when not completed.
  @$pb.TagNumber(8)
  $fixnum.Int64 get completedAt => $_getI64(7);
  @$pb.TagNumber(8)
  set completedAt($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCompletedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearCompletedAt() => $_clearField(8);

  /// Due date, unix millis; zero when there is no due date.
  @$pb.TagNumber(9)
  $fixnum.Int64 get dueDate => $_getI64(8);
  @$pb.TagNumber(9)
  set dueDate($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDueDate() => $_has(8);
  @$pb.TagNumber(9)
  void clearDueDate() => $_clearField(9);

  /// Weekday repeat mask for dailies: 0=Mon .. 6=Sun.
  @$pb.TagNumber(10)
  $pb.PbList<$core.int> get repeatDays => $_getList(9);

  /// Consecutive completion streak (one bump per day).
  @$pb.TagNumber(11)
  $core.int get streak => $_getIZ(10);
  @$pb.TagNumber(11)
  set streak($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasStreak() => $_has(10);
  @$pb.TagNumber(11)
  void clearStreak() => $_clearField(11);

  /// Date of the last day counted into the streak, unix millis.
  @$pb.TagNumber(12)
  $fixnum.Int64 get lastStreakDate => $_getI64(11);
  @$pb.TagNumber(12)
  set lastStreakDate($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(12)
  $core.bool hasLastStreakDate() => $_has(11);
  @$pb.TagNumber(12)
  void clearLastStreakDate() => $_clearField(12);

  /// Optional custom EXP reward overriding the difficulty-based value.
  @$pb.TagNumber(13)
  $core.int get customExpReward => $_getIZ(12);
  @$pb.TagNumber(13)
  set customExpReward($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasCustomExpReward() => $_has(12);
  @$pb.TagNumber(13)
  void clearCustomExpReward() => $_clearField(13);

  /// Optional custom gold reward overriding the difficulty-based value.
  @$pb.TagNumber(14)
  $core.int get customGoldReward => $_getIZ(13);
  @$pb.TagNumber(14)
  set customGoldReward($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(14)
  $core.bool hasCustomGoldReward() => $_has(13);
  @$pb.TagNumber(14)
  void clearCustomGoldReward() => $_clearField(14);

  /// Optional priority label (e.g. "high" | "medium" | "low").
  @$pb.TagNumber(15)
  $core.String get priority => $_getSZ(14);
  @$pb.TagNumber(15)
  set priority($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasPriority() => $_has(14);
  @$pb.TagNumber(15)
  void clearPriority() => $_clearField(15);

  /// HP penalty applied to the character when the task is missed.
  @$pb.TagNumber(16)
  $core.int get hpPenalty => $_getIZ(15);
  @$pb.TagNumber(16)
  set hpPenalty($core.int value) => $_setSignedInt32(15, value);
  @$pb.TagNumber(16)
  $core.bool hasHpPenalty() => $_has(15);
  @$pb.TagNumber(16)
  void clearHpPenalty() => $_clearField(16);

  /// Whether the task was skipped for the current period.
  @$pb.TagNumber(17)
  $core.bool get isSkipped => $_getBF(16);
  @$pb.TagNumber(17)
  set isSkipped($core.bool value) => $_setBool(16, value);
  @$pb.TagNumber(17)
  $core.bool hasIsSkipped() => $_has(16);
  @$pb.TagNumber(17)
  void clearIsSkipped() => $_clearField(17);

  /// Creation time, unix millis.
  @$pb.TagNumber(18)
  $fixnum.Int64 get createdAt => $_getI64(17);
  @$pb.TagNumber(18)
  set createdAt($fixnum.Int64 value) => $_setInt64(17, value);
  @$pb.TagNumber(18)
  $core.bool hasCreatedAt() => $_has(17);
  @$pb.TagNumber(18)
  void clearCreatedAt() => $_clearField(18);

  /// Last update time, unix millis.
  @$pb.TagNumber(19)
  $fixnum.Int64 get updatedAt => $_getI64(18);
  @$pb.TagNumber(19)
  set updatedAt($fixnum.Int64 value) => $_setInt64(18, value);
  @$pb.TagNumber(19)
  $core.bool hasUpdatedAt() => $_has(18);
  @$pb.TagNumber(19)
  void clearUpdatedAt() => $_clearField(19);
}

/// ListTasksRequest — filters for listing tasks.
class ListTasksRequest extends $pb.GeneratedMessage {
  factory ListTasksRequest({
    TaskType? type,
    TaskDifficulty? difficulty,
    $core.Iterable<$core.String>? tags,
    $core.bool? onlyDueToday,
    $core.bool? includeCompleted,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (difficulty != null) result.difficulty = difficulty;
    if (tags != null) result.tags.addAll(tags);
    if (onlyDueToday != null) result.onlyDueToday = onlyDueToday;
    if (includeCompleted != null) result.includeCompleted = includeCompleted;
    return result;
  }

  ListTasksRequest._();

  factory ListTasksRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListTasksRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListTasksRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.task.v1'),
      createEmptyInstance: create)
    ..aE<TaskType>(1, _omitFieldNames ? '' : 'type',
        enumValues: TaskType.values)
    ..aE<TaskDifficulty>(2, _omitFieldNames ? '' : 'difficulty',
        enumValues: TaskDifficulty.values)
    ..pPS(3, _omitFieldNames ? '' : 'tags')
    ..aOB(4, _omitFieldNames ? '' : 'onlyDueToday')
    ..aOB(5, _omitFieldNames ? '' : 'includeCompleted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTasksRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTasksRequest copyWith(void Function(ListTasksRequest) updates) =>
      super.copyWith((message) => updates(message as ListTasksRequest))
          as ListTasksRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTasksRequest create() => ListTasksRequest._();
  @$core.override
  ListTasksRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListTasksRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTasksRequest>(create);
  static ListTasksRequest? _defaultInstance;

  /// Optional filter by task type.
  @$pb.TagNumber(1)
  TaskType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(TaskType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  /// Optional filter by difficulty.
  @$pb.TagNumber(2)
  TaskDifficulty get difficulty => $_getN(1);
  @$pb.TagNumber(2)
  set difficulty(TaskDifficulty value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDifficulty() => $_has(1);
  @$pb.TagNumber(2)
  void clearDifficulty() => $_clearField(2);

  /// Optional filter by tags (matches any tag).
  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get tags => $_getList(2);

  /// When true, only tasks due today are returned.
  @$pb.TagNumber(4)
  $core.bool get onlyDueToday => $_getBF(3);
  @$pb.TagNumber(4)
  set onlyDueToday($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOnlyDueToday() => $_has(3);
  @$pb.TagNumber(4)
  void clearOnlyDueToday() => $_clearField(4);

  /// When true, completed tasks are included in the results.
  @$pb.TagNumber(5)
  $core.bool get includeCompleted => $_getBF(4);
  @$pb.TagNumber(5)
  set includeCompleted($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIncludeCompleted() => $_has(4);
  @$pb.TagNumber(5)
  void clearIncludeCompleted() => $_clearField(5);
}

/// ListTasksReply — the matching tasks.
class ListTasksReply extends $pb.GeneratedMessage {
  factory ListTasksReply({
    $core.Iterable<Task>? tasks,
  }) {
    final result = create();
    if (tasks != null) result.tasks.addAll(tasks);
    return result;
  }

  ListTasksReply._();

  factory ListTasksReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListTasksReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListTasksReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.task.v1'),
      createEmptyInstance: create)
    ..pPM<Task>(1, _omitFieldNames ? '' : 'tasks', subBuilder: Task.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTasksReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTasksReply copyWith(void Function(ListTasksReply) updates) =>
      super.copyWith((message) => updates(message as ListTasksReply))
          as ListTasksReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTasksReply create() => ListTasksReply._();
  @$core.override
  ListTasksReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListTasksReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTasksReply>(create);
  static ListTasksReply? _defaultInstance;

  /// The matching tasks.
  @$pb.TagNumber(1)
  $pb.PbList<Task> get tasks => $_getList(0);
}

/// GetTaskRequest — id of the task to fetch.
class GetTaskRequest extends $pb.GeneratedMessage {
  factory GetTaskRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetTaskRequest._();

  factory GetTaskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTaskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTaskRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.task.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTaskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTaskRequest copyWith(void Function(GetTaskRequest) updates) =>
      super.copyWith((message) => updates(message as GetTaskRequest))
          as GetTaskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTaskRequest create() => GetTaskRequest._();
  @$core.override
  GetTaskRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTaskRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTaskRequest>(create);
  static GetTaskRequest? _defaultInstance;

  /// Task id.
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

/// GetTaskReply — the requested task.
class GetTaskReply extends $pb.GeneratedMessage {
  factory GetTaskReply({
    Task? task,
  }) {
    final result = create();
    if (task != null) result.task = task;
    return result;
  }

  GetTaskReply._();

  factory GetTaskReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTaskReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTaskReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.task.v1'),
      createEmptyInstance: create)
    ..aOM<Task>(1, _omitFieldNames ? '' : 'task', subBuilder: Task.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTaskReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTaskReply copyWith(void Function(GetTaskReply) updates) =>
      super.copyWith((message) => updates(message as GetTaskReply))
          as GetTaskReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTaskReply create() => GetTaskReply._();
  @$core.override
  GetTaskReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTaskReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTaskReply>(create);
  static GetTaskReply? _defaultInstance;

  /// The requested task.
  @$pb.TagNumber(1)
  Task get task => $_getN(0);
  @$pb.TagNumber(1)
  set task(Task value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);
  @$pb.TagNumber(1)
  Task ensureTask() => $_ensure(0);
}

/// CreateTaskRequest — task payload to create.
class CreateTaskRequest extends $pb.GeneratedMessage {
  factory CreateTaskRequest({
    Task? task,
  }) {
    final result = create();
    if (task != null) result.task = task;
    return result;
  }

  CreateTaskRequest._();

  factory CreateTaskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateTaskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateTaskRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.task.v1'),
      createEmptyInstance: create)
    ..aOM<Task>(1, _omitFieldNames ? '' : 'task', subBuilder: Task.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTaskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTaskRequest copyWith(void Function(CreateTaskRequest) updates) =>
      super.copyWith((message) => updates(message as CreateTaskRequest))
          as CreateTaskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateTaskRequest create() => CreateTaskRequest._();
  @$core.override
  CreateTaskRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateTaskRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateTaskRequest>(create);
  static CreateTaskRequest? _defaultInstance;

  /// The task to create; the server assigns the id.
  @$pb.TagNumber(1)
  Task get task => $_getN(0);
  @$pb.TagNumber(1)
  set task(Task value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);
  @$pb.TagNumber(1)
  Task ensureTask() => $_ensure(0);
}

/// CreateTaskReply — the created task with server-assigned fields.
class CreateTaskReply extends $pb.GeneratedMessage {
  factory CreateTaskReply({
    Task? task,
  }) {
    final result = create();
    if (task != null) result.task = task;
    return result;
  }

  CreateTaskReply._();

  factory CreateTaskReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateTaskReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateTaskReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.task.v1'),
      createEmptyInstance: create)
    ..aOM<Task>(1, _omitFieldNames ? '' : 'task', subBuilder: Task.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTaskReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTaskReply copyWith(void Function(CreateTaskReply) updates) =>
      super.copyWith((message) => updates(message as CreateTaskReply))
          as CreateTaskReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateTaskReply create() => CreateTaskReply._();
  @$core.override
  CreateTaskReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateTaskReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateTaskReply>(create);
  static CreateTaskReply? _defaultInstance;

  /// The created task.
  @$pb.TagNumber(1)
  Task get task => $_getN(0);
  @$pb.TagNumber(1)
  set task(Task value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);
  @$pb.TagNumber(1)
  Task ensureTask() => $_ensure(0);
}

/// UpdateTaskRequest — id plus the full task payload to persist.
class UpdateTaskRequest extends $pb.GeneratedMessage {
  factory UpdateTaskRequest({
    $core.String? id,
    Task? task,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (task != null) result.task = task;
    return result;
  }

  UpdateTaskRequest._();

  factory UpdateTaskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateTaskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateTaskRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.task.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<Task>(2, _omitFieldNames ? '' : 'task', subBuilder: Task.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateTaskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateTaskRequest copyWith(void Function(UpdateTaskRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateTaskRequest))
          as UpdateTaskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateTaskRequest create() => UpdateTaskRequest._();
  @$core.override
  UpdateTaskRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateTaskRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateTaskRequest>(create);
  static UpdateTaskRequest? _defaultInstance;

  /// Task id.
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  /// Updated task payload (full replace).
  @$pb.TagNumber(2)
  Task get task => $_getN(1);
  @$pb.TagNumber(2)
  set task(Task value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTask() => $_has(1);
  @$pb.TagNumber(2)
  void clearTask() => $_clearField(2);
  @$pb.TagNumber(2)
  Task ensureTask() => $_ensure(1);
}

/// UpdateTaskReply — the updated task.
class UpdateTaskReply extends $pb.GeneratedMessage {
  factory UpdateTaskReply({
    Task? task,
  }) {
    final result = create();
    if (task != null) result.task = task;
    return result;
  }

  UpdateTaskReply._();

  factory UpdateTaskReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateTaskReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateTaskReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.task.v1'),
      createEmptyInstance: create)
    ..aOM<Task>(1, _omitFieldNames ? '' : 'task', subBuilder: Task.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateTaskReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateTaskReply copyWith(void Function(UpdateTaskReply) updates) =>
      super.copyWith((message) => updates(message as UpdateTaskReply))
          as UpdateTaskReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateTaskReply create() => UpdateTaskReply._();
  @$core.override
  UpdateTaskReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateTaskReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateTaskReply>(create);
  static UpdateTaskReply? _defaultInstance;

  /// The updated task.
  @$pb.TagNumber(1)
  Task get task => $_getN(0);
  @$pb.TagNumber(1)
  set task(Task value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);
  @$pb.TagNumber(1)
  Task ensureTask() => $_ensure(0);
}

/// DeleteTaskRequest — id of the task to delete.
class DeleteTaskRequest extends $pb.GeneratedMessage {
  factory DeleteTaskRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  DeleteTaskRequest._();

  factory DeleteTaskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteTaskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteTaskRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.task.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTaskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTaskRequest copyWith(void Function(DeleteTaskRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteTaskRequest))
          as DeleteTaskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteTaskRequest create() => DeleteTaskRequest._();
  @$core.override
  DeleteTaskRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteTaskRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteTaskRequest>(create);
  static DeleteTaskRequest? _defaultInstance;

  /// Task id.
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

/// DeleteTaskReply — empty response for a successful delete.
class DeleteTaskReply extends $pb.GeneratedMessage {
  factory DeleteTaskReply() => create();

  DeleteTaskReply._();

  factory DeleteTaskReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteTaskReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteTaskReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.task.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTaskReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTaskReply copyWith(void Function(DeleteTaskReply) updates) =>
      super.copyWith((message) => updates(message as DeleteTaskReply))
          as DeleteTaskReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteTaskReply create() => DeleteTaskReply._();
  @$core.override
  DeleteTaskReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteTaskReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteTaskReply>(create);
  static DeleteTaskReply? _defaultInstance;
}

/// CompleteTaskRequest — id of the task to mark completed.
class CompleteTaskRequest extends $pb.GeneratedMessage {
  factory CompleteTaskRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  CompleteTaskRequest._();

  factory CompleteTaskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CompleteTaskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CompleteTaskRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.task.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CompleteTaskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CompleteTaskRequest copyWith(void Function(CompleteTaskRequest) updates) =>
      super.copyWith((message) => updates(message as CompleteTaskRequest))
          as CompleteTaskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CompleteTaskRequest create() => CompleteTaskRequest._();
  @$core.override
  CompleteTaskRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CompleteTaskRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CompleteTaskRequest>(create);
  static CompleteTaskRequest? _defaultInstance;

  /// Task id.
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

/// CompleteTaskReply — completion result and granted rewards.
class CompleteTaskReply extends $pb.GeneratedMessage {
  factory CompleteTaskReply({
    Task? task,
    $core.int? expReward,
    $core.int? goldReward,
    $core.int? hpChange,
  }) {
    final result = create();
    if (task != null) result.task = task;
    if (expReward != null) result.expReward = expReward;
    if (goldReward != null) result.goldReward = goldReward;
    if (hpChange != null) result.hpChange = hpChange;
    return result;
  }

  CompleteTaskReply._();

  factory CompleteTaskReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CompleteTaskReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CompleteTaskReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.task.v1'),
      createEmptyInstance: create)
    ..aOM<Task>(1, _omitFieldNames ? '' : 'task', subBuilder: Task.create)
    ..aI(2, _omitFieldNames ? '' : 'expReward')
    ..aI(3, _omitFieldNames ? '' : 'goldReward')
    ..aI(4, _omitFieldNames ? '' : 'hpChange')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CompleteTaskReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CompleteTaskReply copyWith(void Function(CompleteTaskReply) updates) =>
      super.copyWith((message) => updates(message as CompleteTaskReply))
          as CompleteTaskReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CompleteTaskReply create() => CompleteTaskReply._();
  @$core.override
  CompleteTaskReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CompleteTaskReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CompleteTaskReply>(create);
  static CompleteTaskReply? _defaultInstance;

  /// The task with updated completion state.
  @$pb.TagNumber(1)
  Task get task => $_getN(0);
  @$pb.TagNumber(1)
  set task(Task value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);
  @$pb.TagNumber(1)
  Task ensureTask() => $_ensure(0);

  /// EXP granted for completing this task (includes streak multiplier).
  @$pb.TagNumber(2)
  $core.int get expReward => $_getIZ(1);
  @$pb.TagNumber(2)
  set expReward($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpReward() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpReward() => $_clearField(2);

  /// Gold granted for completing this task.
  @$pb.TagNumber(3)
  $core.int get goldReward => $_getIZ(2);
  @$pb.TagNumber(3)
  set goldReward($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGoldReward() => $_has(2);
  @$pb.TagNumber(3)
  void clearGoldReward() => $_clearField(3);

  /// HP change applied on completion (positive heals, negative damages).
  @$pb.TagNumber(4)
  $core.int get hpChange => $_getIZ(3);
  @$pb.TagNumber(4)
  set hpChange($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHpChange() => $_has(3);
  @$pb.TagNumber(4)
  void clearHpChange() => $_clearField(4);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
