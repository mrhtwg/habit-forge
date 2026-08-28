// This is a generated file - do not edit.
//
// Generated from api/user/v1/user.proto.

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

import 'user.pb.dart' as $0;

export 'user.pb.dart';

/// UserService — user preferences, wallet and settings.
@$pb.GrpcServiceName('api.user.v1.UserService')
class UserServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  UserServiceClient(super.channel, {super.options, super.interceptors});

  /// GetPrefs returns the current user's preferences and wallet.
  $grpc.ResponseFuture<$0.GetPrefsReply> getPrefs(
    $0.GetPrefsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getPrefs, request, options: options);
  }

  /// UpdatePrefs saves the current user's preferences and wallet.
  $grpc.ResponseFuture<$0.UpdatePrefsReply> updatePrefs(
    $0.UpdatePrefsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updatePrefs, request, options: options);
  }

  // method descriptors

  static final _$getPrefs =
      $grpc.ClientMethod<$0.GetPrefsRequest, $0.GetPrefsReply>(
          '/api.user.v1.UserService/GetPrefs',
          ($0.GetPrefsRequest value) => value.writeToBuffer(),
          $0.GetPrefsReply.fromBuffer);
  static final _$updatePrefs =
      $grpc.ClientMethod<$0.UpdatePrefsRequest, $0.UpdatePrefsReply>(
          '/api.user.v1.UserService/UpdatePrefs',
          ($0.UpdatePrefsRequest value) => value.writeToBuffer(),
          $0.UpdatePrefsReply.fromBuffer);
}

@$pb.GrpcServiceName('api.user.v1.UserService')
abstract class UserServiceBase extends $grpc.Service {
  $core.String get $name => 'api.user.v1.UserService';

  UserServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GetPrefsRequest, $0.GetPrefsReply>(
        'GetPrefs',
        getPrefs_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetPrefsRequest.fromBuffer(value),
        ($0.GetPrefsReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdatePrefsRequest, $0.UpdatePrefsReply>(
        'UpdatePrefs',
        updatePrefs_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdatePrefsRequest.fromBuffer(value),
        ($0.UpdatePrefsReply value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetPrefsReply> getPrefs_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetPrefsRequest> $request) async {
    return getPrefs($call, await $request);
  }

  $async.Future<$0.GetPrefsReply> getPrefs(
      $grpc.ServiceCall call, $0.GetPrefsRequest request);

  $async.Future<$0.UpdatePrefsReply> updatePrefs_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdatePrefsRequest> $request) async {
    return updatePrefs($call, await $request);
  }

  $async.Future<$0.UpdatePrefsReply> updatePrefs(
      $grpc.ServiceCall call, $0.UpdatePrefsRequest request);
}
