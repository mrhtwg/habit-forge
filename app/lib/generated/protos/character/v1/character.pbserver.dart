// This is a generated file - do not edit.
//
// Generated from character/v1/character.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'character.pb.dart' as $0;
import 'character.pbjson.dart';

export 'character.pb.dart';

abstract class CharacterServiceBase extends $pb.GeneratedService {
  $async.Future<$0.GetCharacterReply> getCharacter(
      $pb.ServerContext ctx, $0.GetCharacterRequest request);
  $async.Future<$0.UpdateCharacterReply> updateCharacter(
      $pb.ServerContext ctx, $0.UpdateCharacterRequest request);
  $async.Future<$0.AllocateStatPointReply> allocateStatPoint(
      $pb.ServerContext ctx, $0.AllocateStatPointRequest request);
  $async.Future<$0.ReviveReply> revive(
      $pb.ServerContext ctx, $0.ReviveRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetCharacter':
        return $0.GetCharacterRequest();
      case 'UpdateCharacter':
        return $0.UpdateCharacterRequest();
      case 'AllocateStatPoint':
        return $0.AllocateStatPointRequest();
      case 'Revive':
        return $0.ReviveRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetCharacter':
        return getCharacter(ctx, request as $0.GetCharacterRequest);
      case 'UpdateCharacter':
        return updateCharacter(ctx, request as $0.UpdateCharacterRequest);
      case 'AllocateStatPoint':
        return allocateStatPoint(ctx, request as $0.AllocateStatPointRequest);
      case 'Revive':
        return revive(ctx, request as $0.ReviveRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => CharacterServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => CharacterServiceBase$messageJson;
}
