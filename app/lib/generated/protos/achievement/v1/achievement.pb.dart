// This is a generated file - do not edit.
//
// Generated from api/achievement/v1/achievement.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Achievement — a defined achievement with the user's progress and unlock state.
class Achievement extends $pb.GeneratedMessage {
  factory Achievement({
    $core.String? id,
    $core.String? title,
    $core.String? description,
    $core.String? conditionType,
    $core.int? threshold,
    $core.int? progress,
    $core.bool? isUnlocked,
    $fixnum.Int64? unlockedAt,
    $core.int? gemReward,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (title != null) result.title = title;
    if (description != null) result.description = description;
    if (conditionType != null) result.conditionType = conditionType;
    if (threshold != null) result.threshold = threshold;
    if (progress != null) result.progress = progress;
    if (isUnlocked != null) result.isUnlocked = isUnlocked;
    if (unlockedAt != null) result.unlockedAt = unlockedAt;
    if (gemReward != null) result.gemReward = gemReward;
    return result;
  }

  Achievement._();

  factory Achievement.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Achievement.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Achievement',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'api.achievement.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aOS(4, _omitFieldNames ? '' : 'conditionType')
    ..aI(5, _omitFieldNames ? '' : 'threshold')
    ..aI(6, _omitFieldNames ? '' : 'progress')
    ..aOB(7, _omitFieldNames ? '' : 'isUnlocked')
    ..aInt64(8, _omitFieldNames ? '' : 'unlockedAt')
    ..aI(9, _omitFieldNames ? '' : 'gemReward')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Achievement clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Achievement copyWith(void Function(Achievement) updates) =>
      super.copyWith((message) => updates(message as Achievement))
          as Achievement;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Achievement create() => Achievement._();
  @$core.override
  Achievement createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Achievement getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Achievement>(create);
  static Achievement? _defaultInstance;

  /// Unique achievement id.
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  /// Display title.
  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => $_clearField(2);

  /// Display description.
  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  /// Condition kind: "tasks_completed" | "streak" | "level".
  @$pb.TagNumber(4)
  $core.String get conditionType => $_getSZ(3);
  @$pb.TagNumber(4)
  set conditionType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConditionType() => $_has(3);
  @$pb.TagNumber(4)
  void clearConditionType() => $_clearField(4);

  /// Value the progress must reach to unlock.
  @$pb.TagNumber(5)
  $core.int get threshold => $_getIZ(4);
  @$pb.TagNumber(5)
  set threshold($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasThreshold() => $_has(4);
  @$pb.TagNumber(5)
  void clearThreshold() => $_clearField(5);

  /// Current progress toward the threshold.
  @$pb.TagNumber(6)
  $core.int get progress => $_getIZ(5);
  @$pb.TagNumber(6)
  set progress($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasProgress() => $_has(5);
  @$pb.TagNumber(6)
  void clearProgress() => $_clearField(6);

  /// Whether the achievement has been unlocked.
  @$pb.TagNumber(7)
  $core.bool get isUnlocked => $_getBF(6);
  @$pb.TagNumber(7)
  set isUnlocked($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIsUnlocked() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsUnlocked() => $_clearField(7);

  /// Unlock time, unix millis.
  @$pb.TagNumber(8)
  $fixnum.Int64 get unlockedAt => $_getI64(7);
  @$pb.TagNumber(8)
  set unlockedAt($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasUnlockedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearUnlockedAt() => $_clearField(8);

  /// Gem reward granted when unlocking.
  @$pb.TagNumber(9)
  $core.int get gemReward => $_getIZ(8);
  @$pb.TagNumber(9)
  set gemReward($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasGemReward() => $_has(8);
  @$pb.TagNumber(9)
  void clearGemReward() => $_clearField(9);
}

/// ListAchievementsRequest — no parameters.
class ListAchievementsRequest extends $pb.GeneratedMessage {
  factory ListAchievementsRequest() => create();

  ListAchievementsRequest._();

  factory ListAchievementsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListAchievementsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListAchievementsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'api.achievement.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAchievementsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAchievementsRequest copyWith(
          void Function(ListAchievementsRequest) updates) =>
      super.copyWith((message) => updates(message as ListAchievementsRequest))
          as ListAchievementsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAchievementsRequest create() => ListAchievementsRequest._();
  @$core.override
  ListAchievementsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListAchievementsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListAchievementsRequest>(create);
  static ListAchievementsRequest? _defaultInstance;
}

/// ListAchievementsReply — all achievements with the user's state.
class ListAchievementsReply extends $pb.GeneratedMessage {
  factory ListAchievementsReply({
    $core.Iterable<Achievement>? achievements,
  }) {
    final result = create();
    if (achievements != null) result.achievements.addAll(achievements);
    return result;
  }

  ListAchievementsReply._();

  factory ListAchievementsReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListAchievementsReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListAchievementsReply',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'api.achievement.v1'),
      createEmptyInstance: create)
    ..pPM<Achievement>(1, _omitFieldNames ? '' : 'achievements',
        subBuilder: Achievement.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAchievementsReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAchievementsReply copyWith(
          void Function(ListAchievementsReply) updates) =>
      super.copyWith((message) => updates(message as ListAchievementsReply))
          as ListAchievementsReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAchievementsReply create() => ListAchievementsReply._();
  @$core.override
  ListAchievementsReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListAchievementsReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListAchievementsReply>(create);
  static ListAchievementsReply? _defaultInstance;

  /// All achievements.
  @$pb.TagNumber(1)
  $pb.PbList<Achievement> get achievements => $_getList(0);
}

/// UnlockRequest — the achievement to claim.
class UnlockRequest extends $pb.GeneratedMessage {
  factory UnlockRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  UnlockRequest._();

  factory UnlockRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnlockRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnlockRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'api.achievement.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnlockRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnlockRequest copyWith(void Function(UnlockRequest) updates) =>
      super.copyWith((message) => updates(message as UnlockRequest))
          as UnlockRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnlockRequest create() => UnlockRequest._();
  @$core.override
  UnlockRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnlockRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnlockRequest>(create);
  static UnlockRequest? _defaultInstance;

  /// Achievement id.
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

/// UnlockReply — the unlock result.
class UnlockReply extends $pb.GeneratedMessage {
  factory UnlockReply({
    Achievement? achievement,
    $core.int? gemReward,
  }) {
    final result = create();
    if (achievement != null) result.achievement = achievement;
    if (gemReward != null) result.gemReward = gemReward;
    return result;
  }

  UnlockReply._();

  factory UnlockReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnlockReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnlockReply',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'api.achievement.v1'),
      createEmptyInstance: create)
    ..aOM<Achievement>(1, _omitFieldNames ? '' : 'achievement',
        subBuilder: Achievement.create)
    ..aI(2, _omitFieldNames ? '' : 'gemReward')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnlockReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnlockReply copyWith(void Function(UnlockReply) updates) =>
      super.copyWith((message) => updates(message as UnlockReply))
          as UnlockReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnlockReply create() => UnlockReply._();
  @$core.override
  UnlockReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnlockReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnlockReply>(create);
  static UnlockReply? _defaultInstance;

  /// The unlocked achievement.
  @$pb.TagNumber(1)
  Achievement get achievement => $_getN(0);
  @$pb.TagNumber(1)
  set achievement(Achievement value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAchievement() => $_has(0);
  @$pb.TagNumber(1)
  void clearAchievement() => $_clearField(1);
  @$pb.TagNumber(1)
  Achievement ensureAchievement() => $_ensure(0);

  /// Gem reward granted by the unlock.
  @$pb.TagNumber(2)
  $core.int get gemReward => $_getIZ(1);
  @$pb.TagNumber(2)
  set gemReward($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGemReward() => $_has(1);
  @$pb.TagNumber(2)
  void clearGemReward() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
