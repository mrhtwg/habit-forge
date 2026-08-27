// This is a generated file - do not edit.
//
// Generated from shop/v1/shop.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// ShopCurrency — purchase currency.
class ShopCurrency extends $pb.ProtobufEnum {
  static const ShopCurrency SHOP_CURRENCY_UNSPECIFIED =
      ShopCurrency._(0, _omitEnumNames ? '' : 'SHOP_CURRENCY_UNSPECIFIED');
  static const ShopCurrency SHOP_CURRENCY_GOLD =
      ShopCurrency._(1, _omitEnumNames ? '' : 'SHOP_CURRENCY_GOLD');
  static const ShopCurrency SHOP_CURRENCY_GEMS =
      ShopCurrency._(2, _omitEnumNames ? '' : 'SHOP_CURRENCY_GEMS');

  static const $core.List<ShopCurrency> values = <ShopCurrency>[
    SHOP_CURRENCY_UNSPECIFIED,
    SHOP_CURRENCY_GOLD,
    SHOP_CURRENCY_GEMS,
  ];

  static final $core.List<ShopCurrency?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ShopCurrency? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ShopCurrency._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
