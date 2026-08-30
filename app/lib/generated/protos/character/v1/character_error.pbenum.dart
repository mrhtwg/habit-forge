// This is a generated file - do not edit.
//
// Generated from api/character/v1/character_error.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// CharacterErrorReason — business error codes for the character domain.
class CharacterErrorReason extends $pb.ProtobufEnum {
  static const CharacterErrorReason CHARACTER_ALREADY_EXISTS =
      CharacterErrorReason._(
          0, _omitEnumNames ? '' : 'CHARACTER_ALREADY_EXISTS');

  static const $core.List<CharacterErrorReason> values = <CharacterErrorReason>[
    CHARACTER_ALREADY_EXISTS,
  ];

  static final $core.List<CharacterErrorReason?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 0);
  static CharacterErrorReason? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CharacterErrorReason._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
