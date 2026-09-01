// This is a generated file - do not edit.
//
// Generated from api/task/v1/task_error.proto.

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

@$core.Deprecated('Use taskErrorReasonDescriptor instead')
const TaskErrorReason$json = {
  '1': 'TaskErrorReason',
  '2': [
    {'1': 'TASK_ALREADY_EXISTS', '2': 0, '3': {}},
    {'1': 'TASK_NOT_FOUND', '2': 1, '3': {}},
    {'1': 'TASK_ALREADY_COMPLETED', '2': 2, '3': {}},
  ],
  '3': {},
};

/// Descriptor for `TaskErrorReason`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List taskErrorReasonDescriptor = $convert.base64Decode(
    'Cg9UYXNrRXJyb3JSZWFzb24SHQoTVEFTS19BTFJFQURZX0VYSVNUUxAAGgSoRZkDEhgKDlRBU0'
    'tfTk9UX0ZPVU5EEAEaBKhFlAMSIAoWVEFTS19BTFJFQURZX0NPTVBMRVRFRBACGgSoRZADGgSg'
    'RfQD');
