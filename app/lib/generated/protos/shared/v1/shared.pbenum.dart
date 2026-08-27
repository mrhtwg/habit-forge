// This is a generated file - do not edit.
//
// Generated from shared/v1/shared.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// SysMaterial — gold, diamond, exp.
class SysMaterial extends $pb.ProtobufEnum {
  static const SysMaterial SYSMATERIAL_GOLD =
      SysMaterial._(0, _omitEnumNames ? '' : 'SYSMATERIAL_GOLD');
  static const SysMaterial SYSMATERIAL_DIAMOND =
      SysMaterial._(1, _omitEnumNames ? '' : 'SYSMATERIAL_DIAMOND');

  static const $core.List<SysMaterial> values = <SysMaterial>[
    SYSMATERIAL_GOLD,
    SYSMATERIAL_DIAMOND,
  ];

  static final $core.List<SysMaterial?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static SysMaterial? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SysMaterial._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
