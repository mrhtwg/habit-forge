// This is a generated file - do not edit.
//
// Generated from api/character/v1/character_error.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use characterErrorReasonDescriptor instead')
const CharacterErrorReason$json = {
  '1': 'CharacterErrorReason',
  '2': [
    {'1': 'CHARACTER_ALREADY_EXISTS', '2': 0, '3': {}},
    {'1': 'CHARACTER_NOT_FOUND', '2': 1, '3': {}},
  ],
  '3': {},
};

/// Descriptor for `CharacterErrorReason`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List characterErrorReasonDescriptor = $convert.base64Decode(
    'ChRDaGFyYWN0ZXJFcnJvclJlYXNvbhIiChhDSEFSQUNURVJfQUxSRUFEWV9FWElTVFMQABoEqE'
    'WZAxIdChNDSEFSQUNURVJfTk9UX0ZPVU5EEAEaBKhFlAMaBKBF9AM=');
