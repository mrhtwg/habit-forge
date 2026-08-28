// This is a generated file - do not edit.
//
// Generated from api/stats/v1/stats.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'stats.pb.dart' as $0;

export 'stats.pb.dart';

/// StatsService — completion statistics and streak leaderboard.
@$pb.GrpcServiceName('api.stats.v1.StatsService')
class StatsServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  StatsServiceClient(super.channel, {super.options, super.interceptors});

  /// GetStats returns task statistics over a time range.
  $grpc.ResponseFuture<$0.GetStatsReply> getStats(
    $0.GetStatsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getStats, request, options: options);
  }

  // method descriptors

  static final _$getStats =
      $grpc.ClientMethod<$0.GetStatsRequest, $0.GetStatsReply>(
          '/api.stats.v1.StatsService/GetStats',
          ($0.GetStatsRequest value) => value.writeToBuffer(),
          $0.GetStatsReply.fromBuffer);
}

@$pb.GrpcServiceName('api.stats.v1.StatsService')
abstract class StatsServiceBase extends $grpc.Service {
  $core.String get $name => 'api.stats.v1.StatsService';

  StatsServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GetStatsRequest, $0.GetStatsReply>(
        'GetStats',
        getStats_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetStatsRequest.fromBuffer(value),
        ($0.GetStatsReply value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetStatsReply> getStats_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetStatsRequest> $request) async {
    return getStats($call, await $request);
  }

  $async.Future<$0.GetStatsReply> getStats(
      $grpc.ServiceCall call, $0.GetStatsRequest request);
}
