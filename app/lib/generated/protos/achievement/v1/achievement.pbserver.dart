// This is a generated file - do not edit.
//
// Generated from achievement/v1/achievement.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'achievement.pb.dart' as $0;
import 'achievement.pbjson.dart';

export 'achievement.pb.dart';

abstract class AchievementServiceBase extends $pb.GeneratedService {
  $async.Future<$0.ListAchievementsReply> listAchievements(
      $pb.ServerContext ctx, $0.ListAchievementsRequest request);
  $async.Future<$0.UnlockReply> unlock(
      $pb.ServerContext ctx, $0.UnlockRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListAchievements':
        return $0.ListAchievementsRequest();
      case 'Unlock':
        return $0.UnlockRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListAchievements':
        return listAchievements(ctx, request as $0.ListAchievementsRequest);
      case 'Unlock':
        return unlock(ctx, request as $0.UnlockRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json =>
      AchievementServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => AchievementServiceBase$messageJson;
}
