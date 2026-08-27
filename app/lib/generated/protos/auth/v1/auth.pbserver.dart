// This is a generated file - do not edit.
//
// Generated from auth/v1/auth.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'auth.pb.dart' as $0;
import 'auth.pbjson.dart';

export 'auth.pb.dart';

abstract class AuthServiceBase extends $pb.GeneratedService {
  $async.Future<$0.RegisterReply> register(
      $pb.ServerContext ctx, $0.RegisterRequest request);
  $async.Future<$0.LoginReply> login(
      $pb.ServerContext ctx, $0.LoginRequest request);
  $async.Future<$0.LoginReply> oAuthLogin(
      $pb.ServerContext ctx, $0.OAuthLoginRequest request);
  $async.Future<$0.MeReply> me($pb.ServerContext ctx, $0.MeRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'Register':
        return $0.RegisterRequest();
      case 'Login':
        return $0.LoginRequest();
      case 'OAuthLogin':
        return $0.OAuthLoginRequest();
      case 'Me':
        return $0.MeRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'Register':
        return register(ctx, request as $0.RegisterRequest);
      case 'Login':
        return login(ctx, request as $0.LoginRequest);
      case 'OAuthLogin':
        return oAuthLogin(ctx, request as $0.OAuthLoginRequest);
      case 'Me':
        return me(ctx, request as $0.MeRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => AuthServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => AuthServiceBase$messageJson;
}
