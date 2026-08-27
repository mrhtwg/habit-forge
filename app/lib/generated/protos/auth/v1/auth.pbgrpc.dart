// This is a generated file - do not edit.
//
// Generated from auth/v1/auth.proto.

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

import 'auth.pb.dart' as $0;

export 'auth.pb.dart';

/// AuthService — email/password register & login, OAuth login, current user.
@$pb.GrpcServiceName('api.auth.v1.AuthService')
class AuthServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  AuthServiceClient(super.channel, {super.options, super.interceptors});

  /// Register a new email account. No email verification required.
  $grpc.ResponseFuture<$0.RegisterReply> register(
    $0.RegisterRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$register, request, options: options);
  }

  /// Login with email and password.
  $grpc.ResponseFuture<$0.LoginReply> login(
    $0.LoginRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$login, request, options: options);
  }

  /// OAuth login (google / apple), auto-creates the user when missing.
  $grpc.ResponseFuture<$0.LoginReply> oAuthLogin(
    $0.OAuthLoginRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$oAuthLogin, request, options: options);
  }

  /// Me returns the current authenticated user (JWT required).
  $grpc.ResponseFuture<$0.MeReply> me(
    $0.MeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$me, request, options: options);
  }

  // method descriptors

  static final _$register =
      $grpc.ClientMethod<$0.RegisterRequest, $0.RegisterReply>(
          '/api.auth.v1.AuthService/Register',
          ($0.RegisterRequest value) => value.writeToBuffer(),
          $0.RegisterReply.fromBuffer);
  static final _$login = $grpc.ClientMethod<$0.LoginRequest, $0.LoginReply>(
      '/api.auth.v1.AuthService/Login',
      ($0.LoginRequest value) => value.writeToBuffer(),
      $0.LoginReply.fromBuffer);
  static final _$oAuthLogin =
      $grpc.ClientMethod<$0.OAuthLoginRequest, $0.LoginReply>(
          '/api.auth.v1.AuthService/OAuthLogin',
          ($0.OAuthLoginRequest value) => value.writeToBuffer(),
          $0.LoginReply.fromBuffer);
  static final _$me = $grpc.ClientMethod<$0.MeRequest, $0.MeReply>(
      '/api.auth.v1.AuthService/Me',
      ($0.MeRequest value) => value.writeToBuffer(),
      $0.MeReply.fromBuffer);
}

@$pb.GrpcServiceName('api.auth.v1.AuthService')
abstract class AuthServiceBase extends $grpc.Service {
  $core.String get $name => 'api.auth.v1.AuthService';

  AuthServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.RegisterRequest, $0.RegisterReply>(
        'Register',
        register_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RegisterRequest.fromBuffer(value),
        ($0.RegisterReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LoginRequest, $0.LoginReply>(
        'Login',
        login_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LoginRequest.fromBuffer(value),
        ($0.LoginReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.OAuthLoginRequest, $0.LoginReply>(
        'OAuthLogin',
        oAuthLogin_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.OAuthLoginRequest.fromBuffer(value),
        ($0.LoginReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.MeRequest, $0.MeReply>(
        'Me',
        me_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.MeRequest.fromBuffer(value),
        ($0.MeReply value) => value.writeToBuffer()));
  }

  $async.Future<$0.RegisterReply> register_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RegisterRequest> $request) async {
    return register($call, await $request);
  }

  $async.Future<$0.RegisterReply> register(
      $grpc.ServiceCall call, $0.RegisterRequest request);

  $async.Future<$0.LoginReply> login_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.LoginRequest> $request) async {
    return login($call, await $request);
  }

  $async.Future<$0.LoginReply> login(
      $grpc.ServiceCall call, $0.LoginRequest request);

  $async.Future<$0.LoginReply> oAuthLogin_Pre($grpc.ServiceCall $call,
      $async.Future<$0.OAuthLoginRequest> $request) async {
    return oAuthLogin($call, await $request);
  }

  $async.Future<$0.LoginReply> oAuthLogin(
      $grpc.ServiceCall call, $0.OAuthLoginRequest request);

  $async.Future<$0.MeReply> me_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.MeRequest> $request) async {
    return me($call, await $request);
  }

  $async.Future<$0.MeReply> me($grpc.ServiceCall call, $0.MeRequest request);
}
