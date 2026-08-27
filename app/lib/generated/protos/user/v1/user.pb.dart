// This is a generated file - do not edit.
//
// Generated from user/v1/user.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class UserPrefs extends $pb.GeneratedMessage {
  factory UserPrefs({
    $core.bool? onboardingCompleted,
    $core.int? lastOnboardingStep,
    $fixnum.Int64? currentGold,
    $fixnum.Int64? currentGems,
    $core.bool? soundEnabled,
    $core.bool? hapticEnabled,
    $core.bool? notificationsEnabled,
    $fixnum.Int64? totalTasksCompleted,
    $fixnum.Int64? firstTaskDate,
  }) {
    final result = create();
    if (onboardingCompleted != null)
      result.onboardingCompleted = onboardingCompleted;
    if (lastOnboardingStep != null)
      result.lastOnboardingStep = lastOnboardingStep;
    if (currentGold != null) result.currentGold = currentGold;
    if (currentGems != null) result.currentGems = currentGems;
    if (soundEnabled != null) result.soundEnabled = soundEnabled;
    if (hapticEnabled != null) result.hapticEnabled = hapticEnabled;
    if (notificationsEnabled != null)
      result.notificationsEnabled = notificationsEnabled;
    if (totalTasksCompleted != null)
      result.totalTasksCompleted = totalTasksCompleted;
    if (firstTaskDate != null) result.firstTaskDate = firstTaskDate;
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
    ..aOB(1, _omitFieldNames ? '' : 'onboardingCompleted')
    ..aI(2, _omitFieldNames ? '' : 'lastOnboardingStep')
    ..aInt64(3, _omitFieldNames ? '' : 'currentGold')
    ..aInt64(4, _omitFieldNames ? '' : 'currentGems')
    ..aOB(5, _omitFieldNames ? '' : 'soundEnabled')
    ..aOB(6, _omitFieldNames ? '' : 'hapticEnabled')
    ..aOB(7, _omitFieldNames ? '' : 'notificationsEnabled')
    ..aInt64(8, _omitFieldNames ? '' : 'totalTasksCompleted')
    ..aInt64(9, _omitFieldNames ? '' : 'firstTaskDate')
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

  @$pb.TagNumber(1)
  $core.bool get onboardingCompleted => $_getBF(0);
  @$pb.TagNumber(1)
  set onboardingCompleted($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOnboardingCompleted() => $_has(0);
  @$pb.TagNumber(1)
  void clearOnboardingCompleted() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get lastOnboardingStep => $_getIZ(1);
  @$pb.TagNumber(2)
  set lastOnboardingStep($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLastOnboardingStep() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastOnboardingStep() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get currentGold => $_getI64(2);
  @$pb.TagNumber(3)
  set currentGold($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCurrentGold() => $_has(2);
  @$pb.TagNumber(3)
  void clearCurrentGold() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get currentGems => $_getI64(3);
  @$pb.TagNumber(4)
  set currentGems($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCurrentGems() => $_has(3);
  @$pb.TagNumber(4)
  void clearCurrentGems() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get soundEnabled => $_getBF(4);
  @$pb.TagNumber(5)
  set soundEnabled($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSoundEnabled() => $_has(4);
  @$pb.TagNumber(5)
  void clearSoundEnabled() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get hapticEnabled => $_getBF(5);
  @$pb.TagNumber(6)
  set hapticEnabled($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHapticEnabled() => $_has(5);
  @$pb.TagNumber(6)
  void clearHapticEnabled() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get notificationsEnabled => $_getBF(6);
  @$pb.TagNumber(7)
  set notificationsEnabled($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasNotificationsEnabled() => $_has(6);
  @$pb.TagNumber(7)
  void clearNotificationsEnabled() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get totalTasksCompleted => $_getI64(7);
  @$pb.TagNumber(8)
  set totalTasksCompleted($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTotalTasksCompleted() => $_has(7);
  @$pb.TagNumber(8)
  void clearTotalTasksCompleted() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get firstTaskDate => $_getI64(8);
  @$pb.TagNumber(9)
  set firstTaskDate($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasFirstTaskDate() => $_has(8);
  @$pb.TagNumber(9)
  void clearFirstTaskDate() => $_clearField(9);
}

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
