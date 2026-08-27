// This is a generated file - do not edit.
//
// Generated from stats/v1/stats.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'stats.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'stats.pbenum.dart';

class TimeSegment extends $pb.GeneratedMessage {
  factory TimeSegment({
    $core.String? label,
    $fixnum.Int64? completedCount,
  }) {
    final result = create();
    if (label != null) result.label = label;
    if (completedCount != null) result.completedCount = completedCount;
    return result;
  }

  TimeSegment._();

  factory TimeSegment.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TimeSegment.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimeSegment',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.stats.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'label')
    ..aInt64(2, _omitFieldNames ? '' : 'completedCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeSegment clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeSegment copyWith(void Function(TimeSegment) updates) =>
      super.copyWith((message) => updates(message as TimeSegment))
          as TimeSegment;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TimeSegment create() => TimeSegment._();
  @$core.override
  TimeSegment createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TimeSegment getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TimeSegment>(create);
  static TimeSegment? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get label => $_getSZ(0);
  @$pb.TagNumber(1)
  set label($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLabel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLabel() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get completedCount => $_getI64(1);
  @$pb.TagNumber(2)
  set completedCount($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCompletedCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearCompletedCount() => $_clearField(2);
}

class StreakEntry extends $pb.GeneratedMessage {
  factory StreakEntry({
    $core.String? taskId,
    $core.String? title,
    $core.int? streak,
  }) {
    final result = create();
    if (taskId != null) result.taskId = taskId;
    if (title != null) result.title = title;
    if (streak != null) result.streak = streak;
    return result;
  }

  StreakEntry._();

  factory StreakEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreakEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreakEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.stats.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'taskId')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aI(3, _omitFieldNames ? '' : 'streak')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreakEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreakEntry copyWith(void Function(StreakEntry) updates) =>
      super.copyWith((message) => updates(message as StreakEntry))
          as StreakEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreakEntry create() => StreakEntry._();
  @$core.override
  StreakEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreakEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreakEntry>(create);
  static StreakEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get taskId => $_getSZ(0);
  @$pb.TagNumber(1)
  set taskId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTaskId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTaskId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get streak => $_getIZ(2);
  @$pb.TagNumber(3)
  set streak($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStreak() => $_has(2);
  @$pb.TagNumber(3)
  void clearStreak() => $_clearField(3);
}

class StatsReply extends $pb.GeneratedMessage {
  factory StatsReply({
    StatsRange? range,
    $core.Iterable<TimeSegment>? segments,
    $core.Iterable<StreakEntry>? streakLeaderboard,
    $fixnum.Int64? totalTasksCompleted,
    $fixnum.Int64? totalGoldEarned,
    $fixnum.Int64? totalExpEarned,
  }) {
    final result = create();
    if (range != null) result.range = range;
    if (segments != null) result.segments.addAll(segments);
    if (streakLeaderboard != null)
      result.streakLeaderboard.addAll(streakLeaderboard);
    if (totalTasksCompleted != null)
      result.totalTasksCompleted = totalTasksCompleted;
    if (totalGoldEarned != null) result.totalGoldEarned = totalGoldEarned;
    if (totalExpEarned != null) result.totalExpEarned = totalExpEarned;
    return result;
  }

  StatsReply._();

  factory StatsReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StatsReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StatsReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.stats.v1'),
      createEmptyInstance: create)
    ..aE<StatsRange>(1, _omitFieldNames ? '' : 'range',
        enumValues: StatsRange.values)
    ..pPM<TimeSegment>(2, _omitFieldNames ? '' : 'segments',
        subBuilder: TimeSegment.create)
    ..pPM<StreakEntry>(3, _omitFieldNames ? '' : 'streakLeaderboard',
        subBuilder: StreakEntry.create)
    ..aInt64(4, _omitFieldNames ? '' : 'totalTasksCompleted')
    ..aInt64(5, _omitFieldNames ? '' : 'totalGoldEarned')
    ..aInt64(6, _omitFieldNames ? '' : 'totalExpEarned')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatsReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatsReply copyWith(void Function(StatsReply) updates) =>
      super.copyWith((message) => updates(message as StatsReply)) as StatsReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StatsReply create() => StatsReply._();
  @$core.override
  StatsReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StatsReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StatsReply>(create);
  static StatsReply? _defaultInstance;

  @$pb.TagNumber(1)
  StatsRange get range => $_getN(0);
  @$pb.TagNumber(1)
  set range(StatsRange value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRange() => $_has(0);
  @$pb.TagNumber(1)
  void clearRange() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<TimeSegment> get segments => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<StreakEntry> get streakLeaderboard => $_getList(2);

  @$pb.TagNumber(4)
  $fixnum.Int64 get totalTasksCompleted => $_getI64(3);
  @$pb.TagNumber(4)
  set totalTasksCompleted($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTotalTasksCompleted() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalTasksCompleted() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get totalGoldEarned => $_getI64(4);
  @$pb.TagNumber(5)
  set totalGoldEarned($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTotalGoldEarned() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalGoldEarned() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get totalExpEarned => $_getI64(5);
  @$pb.TagNumber(6)
  set totalExpEarned($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTotalExpEarned() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotalExpEarned() => $_clearField(6);
}

class GetStatsRequest extends $pb.GeneratedMessage {
  factory GetStatsRequest({
    StatsRange? range,
  }) {
    final result = create();
    if (range != null) result.range = range;
    return result;
  }

  GetStatsRequest._();

  factory GetStatsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetStatsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetStatsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.stats.v1'),
      createEmptyInstance: create)
    ..aE<StatsRange>(1, _omitFieldNames ? '' : 'range',
        enumValues: StatsRange.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatsRequest copyWith(void Function(GetStatsRequest) updates) =>
      super.copyWith((message) => updates(message as GetStatsRequest))
          as GetStatsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStatsRequest create() => GetStatsRequest._();
  @$core.override
  GetStatsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetStatsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetStatsRequest>(create);
  static GetStatsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  StatsRange get range => $_getN(0);
  @$pb.TagNumber(1)
  set range(StatsRange value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRange() => $_has(0);
  @$pb.TagNumber(1)
  void clearRange() => $_clearField(1);
}

class GetStatsReply extends $pb.GeneratedMessage {
  factory GetStatsReply({
    StatsReply? stats,
  }) {
    final result = create();
    if (stats != null) result.stats = stats;
    return result;
  }

  GetStatsReply._();

  factory GetStatsReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetStatsReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetStatsReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.stats.v1'),
      createEmptyInstance: create)
    ..aOM<StatsReply>(1, _omitFieldNames ? '' : 'stats',
        subBuilder: StatsReply.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatsReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatsReply copyWith(void Function(GetStatsReply) updates) =>
      super.copyWith((message) => updates(message as GetStatsReply))
          as GetStatsReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStatsReply create() => GetStatsReply._();
  @$core.override
  GetStatsReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetStatsReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetStatsReply>(create);
  static GetStatsReply? _defaultInstance;

  @$pb.TagNumber(1)
  StatsReply get stats => $_getN(0);
  @$pb.TagNumber(1)
  set stats(StatsReply value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStats() => $_has(0);
  @$pb.TagNumber(1)
  void clearStats() => $_clearField(1);
  @$pb.TagNumber(1)
  StatsReply ensureStats() => $_ensure(0);
}

/// StatsService — completion statistics and streak leaderboard.
class StatsServiceApi {
  final $pb.RpcClient _client;

  StatsServiceApi(this._client);

  /// GetStats returns task statistics over a time range.
  $async.Future<GetStatsReply> getStats(
          $pb.ClientContext? ctx, GetStatsRequest request) =>
      _client.invoke<GetStatsReply>(
          ctx, 'StatsService', 'GetStats', request, GetStatsReply());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
