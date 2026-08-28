// This is a generated file - do not edit.
//
// Generated from api/character/v1/character.proto.

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

import 'character.pb.dart' as $0;

export 'character.pb.dart';

/// CharacterService — RPG character state: class, level, EXP, HP, stats, equipment.
@$pb.GrpcServiceName('api.character.v1.CharacterService')
class CharacterServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  CharacterServiceClient(super.channel, {super.options, super.interceptors});

  /// GetCharacter returns the current user's character.
  $grpc.ResponseFuture<$0.GetCharacterReply> getCharacter(
    $0.GetCharacterRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getCharacter, request, options: options);
  }

  /// UpdateCharacter replaces the character state (level/exp/hp/stats/equipment).
  $grpc.ResponseFuture<$0.UpdateCharacterReply> updateCharacter(
    $0.UpdateCharacterRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateCharacter, request, options: options);
  }

  /// AllocateStatPoint spends one available stat point on an attribute.
  $grpc.ResponseFuture<$0.AllocateStatPointReply> allocateStatPoint(
    $0.AllocateStatPointRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$allocateStatPoint, request, options: options);
  }

  /// Revive revives a dead character (e.g. after the recovery timer).
  $grpc.ResponseFuture<$0.ReviveReply> revive(
    $0.ReviveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$revive, request, options: options);
  }

  // method descriptors

  static final _$getCharacter =
      $grpc.ClientMethod<$0.GetCharacterRequest, $0.GetCharacterReply>(
          '/api.character.v1.CharacterService/GetCharacter',
          ($0.GetCharacterRequest value) => value.writeToBuffer(),
          $0.GetCharacterReply.fromBuffer);
  static final _$updateCharacter =
      $grpc.ClientMethod<$0.UpdateCharacterRequest, $0.UpdateCharacterReply>(
          '/api.character.v1.CharacterService/UpdateCharacter',
          ($0.UpdateCharacterRequest value) => value.writeToBuffer(),
          $0.UpdateCharacterReply.fromBuffer);
  static final _$allocateStatPoint = $grpc.ClientMethod<
          $0.AllocateStatPointRequest, $0.AllocateStatPointReply>(
      '/api.character.v1.CharacterService/AllocateStatPoint',
      ($0.AllocateStatPointRequest value) => value.writeToBuffer(),
      $0.AllocateStatPointReply.fromBuffer);
  static final _$revive = $grpc.ClientMethod<$0.ReviveRequest, $0.ReviveReply>(
      '/api.character.v1.CharacterService/Revive',
      ($0.ReviveRequest value) => value.writeToBuffer(),
      $0.ReviveReply.fromBuffer);
}

@$pb.GrpcServiceName('api.character.v1.CharacterService')
abstract class CharacterServiceBase extends $grpc.Service {
  $core.String get $name => 'api.character.v1.CharacterService';

  CharacterServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.GetCharacterRequest, $0.GetCharacterReply>(
            'GetCharacter',
            getCharacter_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetCharacterRequest.fromBuffer(value),
            ($0.GetCharacterReply value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.UpdateCharacterRequest, $0.UpdateCharacterReply>(
            'UpdateCharacter',
            updateCharacter_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.UpdateCharacterRequest.fromBuffer(value),
            ($0.UpdateCharacterReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AllocateStatPointRequest,
            $0.AllocateStatPointReply>(
        'AllocateStatPoint',
        allocateStatPoint_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.AllocateStatPointRequest.fromBuffer(value),
        ($0.AllocateStatPointReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ReviveRequest, $0.ReviveReply>(
        'Revive',
        revive_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ReviveRequest.fromBuffer(value),
        ($0.ReviveReply value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetCharacterReply> getCharacter_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetCharacterRequest> $request) async {
    return getCharacter($call, await $request);
  }

  $async.Future<$0.GetCharacterReply> getCharacter(
      $grpc.ServiceCall call, $0.GetCharacterRequest request);

  $async.Future<$0.UpdateCharacterReply> updateCharacter_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UpdateCharacterRequest> $request) async {
    return updateCharacter($call, await $request);
  }

  $async.Future<$0.UpdateCharacterReply> updateCharacter(
      $grpc.ServiceCall call, $0.UpdateCharacterRequest request);

  $async.Future<$0.AllocateStatPointReply> allocateStatPoint_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.AllocateStatPointRequest> $request) async {
    return allocateStatPoint($call, await $request);
  }

  $async.Future<$0.AllocateStatPointReply> allocateStatPoint(
      $grpc.ServiceCall call, $0.AllocateStatPointRequest request);

  $async.Future<$0.ReviveReply> revive_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ReviveRequest> $request) async {
    return revive($call, await $request);
  }

  $async.Future<$0.ReviveReply> revive(
      $grpc.ServiceCall call, $0.ReviveRequest request);
}
