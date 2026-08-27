// This is a generated file - do not edit.
//
// Generated from achievement/v1/achievement.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'achievement.pb.dart' as $0;

export 'achievement.pb.dart';

/// AchievementService — achievement definitions, progress and unlock claiming.
@$pb.GrpcServiceName('api.achievement.v1.AchievementService')
class AchievementServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  AchievementServiceClient(super.channel, {super.options, super.interceptors});

  /// ListAchievements lists all achievements with unlock state.
  $grpc.ResponseFuture<$0.ListAchievementsReply> listAchievements(
    $0.ListAchievementsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listAchievements, request, options: options);
  }

  /// Unlock claims an achievement and grants its gem reward.
  $grpc.ResponseFuture<$0.UnlockReply> unlock(
    $0.UnlockRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unlock, request, options: options);
  }

  // method descriptors

  static final _$listAchievements =
      $grpc.ClientMethod<$0.ListAchievementsRequest, $0.ListAchievementsReply>(
          '/api.achievement.v1.AchievementService/ListAchievements',
          ($0.ListAchievementsRequest value) => value.writeToBuffer(),
          $0.ListAchievementsReply.fromBuffer);
  static final _$unlock = $grpc.ClientMethod<$0.UnlockRequest, $0.UnlockReply>(
      '/api.achievement.v1.AchievementService/Unlock',
      ($0.UnlockRequest value) => value.writeToBuffer(),
      $0.UnlockReply.fromBuffer);
}

@$pb.GrpcServiceName('api.achievement.v1.AchievementService')
abstract class AchievementServiceBase extends $grpc.Service {
  $core.String get $name => 'api.achievement.v1.AchievementService';

  AchievementServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ListAchievementsRequest,
            $0.ListAchievementsReply>(
        'ListAchievements',
        listAchievements_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListAchievementsRequest.fromBuffer(value),
        ($0.ListAchievementsReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UnlockRequest, $0.UnlockReply>(
        'Unlock',
        unlock_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UnlockRequest.fromBuffer(value),
        ($0.UnlockReply value) => value.writeToBuffer()));
  }

  $async.Future<$0.ListAchievementsReply> listAchievements_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListAchievementsRequest> $request) async {
    return listAchievements($call, await $request);
  }

  $async.Future<$0.ListAchievementsReply> listAchievements(
      $grpc.ServiceCall call, $0.ListAchievementsRequest request);

  $async.Future<$0.UnlockReply> unlock_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.UnlockRequest> $request) async {
    return unlock($call, await $request);
  }

  $async.Future<$0.UnlockReply> unlock(
      $grpc.ServiceCall call, $0.UnlockRequest request);
}
