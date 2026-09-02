// This is a generated file - do not edit.
//
// Generated from api/user/v1/user.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import '../../character/v1/character.pbenum.dart' as $2;
import '../../shop/v1/shop.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// UserPrefs
class UserPrefs extends $pb.GeneratedMessage {
  factory UserPrefs({
    $2.CharacterClass? charactorClass,
    $fixnum.Int64? currentGold,
    $fixnum.Int64? currentGems,
    $core.bool? notificationsEnabled,
    $fixnum.Int64? totalTasksCompleted,
    $fixnum.Int64? totalTasks,
    $fixnum.Int64? todayTasksCompleted,
    $fixnum.Int64? todayTasks,
    $fixnum.Int64? firstTaskDate,
    $core.Iterable<$1.ShopItem>? items,
  }) {
    final result = create();
    if (charactorClass != null) result.charactorClass = charactorClass;
    if (currentGold != null) result.currentGold = currentGold;
    if (currentGems != null) result.currentGems = currentGems;
    if (notificationsEnabled != null)
      result.notificationsEnabled = notificationsEnabled;
    if (totalTasksCompleted != null)
      result.totalTasksCompleted = totalTasksCompleted;
    if (totalTasks != null) result.totalTasks = totalTasks;
    if (todayTasksCompleted != null)
      result.todayTasksCompleted = todayTasksCompleted;
    if (todayTasks != null) result.todayTasks = todayTasks;
    if (firstTaskDate != null) result.firstTaskDate = firstTaskDate;
    if (items != null) result.items.addAll(items);
    return result;
  }

  UserPrefs._();

  factory UserPrefs.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserPrefs.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserPrefs',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.user.v1'),
      createEmptyInstance: create)
    ..aE<$2.CharacterClass>(1, _omitFieldNames ? '' : 'charactorClass',
        enumValues: $2.CharacterClass.values)
    ..aInt64(2, _omitFieldNames ? '' : 'currentGold')
    ..aInt64(3, _omitFieldNames ? '' : 'currentGems')
    ..aOB(4, _omitFieldNames ? '' : 'notificationsEnabled')
    ..aInt64(5, _omitFieldNames ? '' : 'totalTasksCompleted')
    ..aInt64(6, _omitFieldNames ? '' : 'totalTasks')
    ..aInt64(7, _omitFieldNames ? '' : 'todayTasksCompleted')
    ..aInt64(8, _omitFieldNames ? '' : 'todayTasks')
    ..aInt64(9, _omitFieldNames ? '' : 'firstTaskDate')
    ..pPM<$1.ShopItem>(10, _omitFieldNames ? '' : 'items',
        subBuilder: $1.ShopItem.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserPrefs clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserPrefs copyWith(void Function(UserPrefs) updates) =>
      super.copyWith((message) => updates(message as UserPrefs)) as UserPrefs;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserPrefs create() => UserPrefs._();
  @$core.override
  UserPrefs createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UserPrefs getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserPrefs>(create);
  static UserPrefs? _defaultInstance;

  /// Chosen character class.
  @$pb.TagNumber(1)
  $2.CharacterClass get charactorClass => $_getN(0);
  @$pb.TagNumber(1)
  set charactorClass($2.CharacterClass value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCharactorClass() => $_has(0);
  @$pb.TagNumber(1)
  void clearCharactorClass() => $_clearField(1);

  /// Current gold balance.
  @$pb.TagNumber(2)
  $fixnum.Int64 get currentGold => $_getI64(1);
  @$pb.TagNumber(2)
  set currentGold($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCurrentGold() => $_has(1);
  @$pb.TagNumber(2)
  void clearCurrentGold() => $_clearField(2);

  /// Current gem balance.
  @$pb.TagNumber(3)
  $fixnum.Int64 get currentGems => $_getI64(2);
  @$pb.TagNumber(3)
  set currentGems($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCurrentGems() => $_has(2);
  @$pb.TagNumber(3)
  void clearCurrentGems() => $_clearField(3);

  /// Whether push notifications are enabled.
  @$pb.TagNumber(4)
  $core.bool get notificationsEnabled => $_getBF(3);
  @$pb.TagNumber(4)
  set notificationsEnabled($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNotificationsEnabled() => $_has(3);
  @$pb.TagNumber(4)
  void clearNotificationsEnabled() => $_clearField(4);

  /// Lifetime count of completed tasks.
  @$pb.TagNumber(5)
  $fixnum.Int64 get totalTasksCompleted => $_getI64(4);
  @$pb.TagNumber(5)
  set totalTasksCompleted($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTotalTasksCompleted() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalTasksCompleted() => $_clearField(5);

  /// Total number of tasks.
  @$pb.TagNumber(6)
  $fixnum.Int64 get totalTasks => $_getI64(5);
  @$pb.TagNumber(6)
  set totalTasks($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTotalTasks() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotalTasks() => $_clearField(6);

  /// Today's count of completed tasks.
  @$pb.TagNumber(7)
  $fixnum.Int64 get todayTasksCompleted => $_getI64(6);
  @$pb.TagNumber(7)
  set todayTasksCompleted($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTodayTasksCompleted() => $_has(6);
  @$pb.TagNumber(7)
  void clearTodayTasksCompleted() => $_clearField(7);

  /// Today's number of tasks.
  @$pb.TagNumber(8)
  $fixnum.Int64 get todayTasks => $_getI64(7);
  @$pb.TagNumber(8)
  set todayTasks($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTodayTasks() => $_has(7);
  @$pb.TagNumber(8)
  void clearTodayTasks() => $_clearField(8);

  /// Date of the first completed task, unix millis.
  @$pb.TagNumber(9)
  $fixnum.Int64 get firstTaskDate => $_getI64(8);
  @$pb.TagNumber(9)
  set firstTaskDate($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasFirstTaskDate() => $_has(8);
  @$pb.TagNumber(9)
  void clearFirstTaskDate() => $_clearField(9);

  /// List of item IDs owned by the user.
  @$pb.TagNumber(10)
  $pb.PbList<$1.ShopItem> get items => $_getList(9);
}

/// GetPrefsRequest — no parameters.
class GetPrefsRequest extends $pb.GeneratedMessage {
  factory GetPrefsRequest() => create();

  GetPrefsRequest._();

  factory GetPrefsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPrefsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPrefsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.user.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPrefsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPrefsRequest copyWith(void Function(GetPrefsRequest) updates) =>
      super.copyWith((message) => updates(message as GetPrefsRequest))
          as GetPrefsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPrefsRequest create() => GetPrefsRequest._();
  @$core.override
  GetPrefsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPrefsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPrefsRequest>(create);
  static GetPrefsRequest? _defaultInstance;
}

/// GetPrefsReply — the current user's preferences.
class GetPrefsReply extends $pb.GeneratedMessage {
  factory GetPrefsReply({
    UserPrefs? prefs,
  }) {
    final result = create();
    if (prefs != null) result.prefs = prefs;
    return result;
  }

  GetPrefsReply._();

  factory GetPrefsReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPrefsReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPrefsReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.user.v1'),
      createEmptyInstance: create)
    ..aOM<UserPrefs>(1, _omitFieldNames ? '' : 'prefs',
        subBuilder: UserPrefs.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPrefsReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPrefsReply copyWith(void Function(GetPrefsReply) updates) =>
      super.copyWith((message) => updates(message as GetPrefsReply))
          as GetPrefsReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPrefsReply create() => GetPrefsReply._();
  @$core.override
  GetPrefsReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPrefsReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPrefsReply>(create);
  static GetPrefsReply? _defaultInstance;

  /// The user's preferences and wallet.
  @$pb.TagNumber(1)
  UserPrefs get prefs => $_getN(0);
  @$pb.TagNumber(1)
  set prefs(UserPrefs value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPrefs() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrefs() => $_clearField(1);
  @$pb.TagNumber(1)
  UserPrefs ensurePrefs() => $_ensure(0);
}

/// UpdatePrefsRequest — preferences to persist.
class UpdatePrefsRequest extends $pb.GeneratedMessage {
  factory UpdatePrefsRequest({
    UserPrefs? prefs,
  }) {
    final result = create();
    if (prefs != null) result.prefs = prefs;
    return result;
  }

  UpdatePrefsRequest._();

  factory UpdatePrefsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdatePrefsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdatePrefsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.user.v1'),
      createEmptyInstance: create)
    ..aOM<UserPrefs>(1, _omitFieldNames ? '' : 'prefs',
        subBuilder: UserPrefs.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdatePrefsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdatePrefsRequest copyWith(void Function(UpdatePrefsRequest) updates) =>
      super.copyWith((message) => updates(message as UpdatePrefsRequest))
          as UpdatePrefsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdatePrefsRequest create() => UpdatePrefsRequest._();
  @$core.override
  UpdatePrefsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdatePrefsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdatePrefsRequest>(create);
  static UpdatePrefsRequest? _defaultInstance;

  /// Full preferences payload to save.
  @$pb.TagNumber(1)
  UserPrefs get prefs => $_getN(0);
  @$pb.TagNumber(1)
  set prefs(UserPrefs value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPrefs() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrefs() => $_clearField(1);
  @$pb.TagNumber(1)
  UserPrefs ensurePrefs() => $_ensure(0);
}

/// UpdatePrefsReply — the saved preferences.
class UpdatePrefsReply extends $pb.GeneratedMessage {
  factory UpdatePrefsReply({
    UserPrefs? prefs,
  }) {
    final result = create();
    if (prefs != null) result.prefs = prefs;
    return result;
  }

  UpdatePrefsReply._();

  factory UpdatePrefsReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdatePrefsReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdatePrefsReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.user.v1'),
      createEmptyInstance: create)
    ..aOM<UserPrefs>(1, _omitFieldNames ? '' : 'prefs',
        subBuilder: UserPrefs.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdatePrefsReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdatePrefsReply copyWith(void Function(UpdatePrefsReply) updates) =>
      super.copyWith((message) => updates(message as UpdatePrefsReply))
          as UpdatePrefsReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdatePrefsReply create() => UpdatePrefsReply._();
  @$core.override
  UpdatePrefsReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdatePrefsReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdatePrefsReply>(create);
  static UpdatePrefsReply? _defaultInstance;

  /// The persisted preferences.
  @$pb.TagNumber(1)
  UserPrefs get prefs => $_getN(0);
  @$pb.TagNumber(1)
  set prefs(UserPrefs value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPrefs() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrefs() => $_clearField(1);
  @$pb.TagNumber(1)
  UserPrefs ensurePrefs() => $_ensure(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
