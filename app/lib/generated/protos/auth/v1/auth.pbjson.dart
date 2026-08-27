// This is a generated file - do not edit.
//
// Generated from auth/v1/auth.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use registerRequestDescriptor instead')
const RegisterRequest$json = {
  '1': 'RegisterRequest',
  '2': [
    {'1': 'email', '3': 1, '4': 1, '5': 9, '10': 'email'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
    {'1': 'nickname', '3': 3, '4': 1, '5': 9, '10': 'nickname'},
  ],
};

/// Descriptor for `RegisterRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerRequestDescriptor = $convert.base64Decode(
    'Cg9SZWdpc3RlclJlcXVlc3QSFAoFZW1haWwYASABKAlSBWVtYWlsEhoKCHBhc3N3b3JkGAIgAS'
    'gJUghwYXNzd29yZBIaCghuaWNrbmFtZRgDIAEoCVIIbmlja25hbWU=');

@$core.Deprecated('Use loginRequestDescriptor instead')
const LoginRequest$json = {
  '1': 'LoginRequest',
  '2': [
    {'1': 'email', '3': 1, '4': 1, '5': 9, '10': 'email'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `LoginRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginRequestDescriptor = $convert.base64Decode(
    'CgxMb2dpblJlcXVlc3QSFAoFZW1haWwYASABKAlSBWVtYWlsEhoKCHBhc3N3b3JkGAIgASgJUg'
    'hwYXNzd29yZA==');

@$core.Deprecated('Use oAuthLoginRequestDescriptor instead')
const OAuthLoginRequest$json = {
  '1': 'OAuthLoginRequest',
  '2': [
    {'1': 'provider', '3': 1, '4': 1, '5': 9, '10': 'provider'},
    {'1': 'provider_id', '3': 2, '4': 1, '5': 9, '10': 'providerId'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'nickname', '3': 4, '4': 1, '5': 9, '10': 'nickname'},
  ],
};

/// Descriptor for `OAuthLoginRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List oAuthLoginRequestDescriptor = $convert.base64Decode(
    'ChFPQXV0aExvZ2luUmVxdWVzdBIaCghwcm92aWRlchgBIAEoCVIIcHJvdmlkZXISHwoLcHJvdm'
    'lkZXJfaWQYAiABKAlSCnByb3ZpZGVySWQSFAoFZW1haWwYAyABKAlSBWVtYWlsEhoKCG5pY2tu'
    'YW1lGAQgASgJUghuaWNrbmFtZQ==');

@$core.Deprecated('Use meRequestDescriptor instead')
const MeRequest$json = {
  '1': 'MeRequest',
};

/// Descriptor for `MeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meRequestDescriptor =
    $convert.base64Decode('CglNZVJlcXVlc3Q=');

@$core.Deprecated('Use userInfoDescriptor instead')
const UserInfo$json = {
  '1': 'UserInfo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'email', '3': 2, '4': 1, '5': 9, '10': 'email'},
    {'1': 'nickname', '3': 3, '4': 1, '5': 9, '10': 'nickname'},
    {'1': 'avatar_url', '3': 4, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'created_at', '3': 5, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'updated_at', '3': 6, '4': 1, '5': 3, '10': 'updatedAt'},
  ],
};

/// Descriptor for `UserInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userInfoDescriptor = $convert.base64Decode(
    'CghVc2VySW5mbxIOCgJpZBgBIAEoCVICaWQSFAoFZW1haWwYAiABKAlSBWVtYWlsEhoKCG5pY2'
    'tuYW1lGAMgASgJUghuaWNrbmFtZRIdCgphdmF0YXJfdXJsGAQgASgJUglhdmF0YXJVcmwSHQoK'
    'Y3JlYXRlZF9hdBgFIAEoA1IJY3JlYXRlZEF0Eh0KCnVwZGF0ZWRfYXQYBiABKANSCXVwZGF0ZW'
    'RBdA==');

@$core.Deprecated('Use registerReplyDescriptor instead')
const RegisterReply$json = {
  '1': 'RegisterReply',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '10': 'token'},
    {
      '1': 'user',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.api.auth.v1.UserInfo',
      '10': 'user'
    },
  ],
};

/// Descriptor for `RegisterReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerReplyDescriptor = $convert.base64Decode(
    'Cg1SZWdpc3RlclJlcGx5EhQKBXRva2VuGAEgASgJUgV0b2tlbhIpCgR1c2VyGAIgASgLMhUuYX'
    'BpLmF1dGgudjEuVXNlckluZm9SBHVzZXI=');

@$core.Deprecated('Use loginReplyDescriptor instead')
const LoginReply$json = {
  '1': 'LoginReply',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '10': 'token'},
    {
      '1': 'user',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.api.auth.v1.UserInfo',
      '10': 'user'
    },
  ],
};

/// Descriptor for `LoginReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginReplyDescriptor = $convert.base64Decode(
    'CgpMb2dpblJlcGx5EhQKBXRva2VuGAEgASgJUgV0b2tlbhIpCgR1c2VyGAIgASgLMhUuYXBpLm'
    'F1dGgudjEuVXNlckluZm9SBHVzZXI=');

@$core.Deprecated('Use meReplyDescriptor instead')
const MeReply$json = {
  '1': 'MeReply',
  '2': [
    {
      '1': 'user',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.api.auth.v1.UserInfo',
      '10': 'user'
    },
  ],
};

/// Descriptor for `MeReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meReplyDescriptor = $convert.base64Decode(
    'CgdNZVJlcGx5EikKBHVzZXIYASABKAsyFS5hcGkuYXV0aC52MS5Vc2VySW5mb1IEdXNlcg==');
