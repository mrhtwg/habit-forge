// This is a generated file - do not edit.
//
// Generated from shop/v1/shop.proto.

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

@$core.Deprecated('Use shopCurrencyDescriptor instead')
const ShopCurrency$json = {
  '1': 'ShopCurrency',
  '2': [
    {'1': 'SHOP_CURRENCY_UNSPECIFIED', '2': 0},
    {'1': 'SHOP_CURRENCY_GOLD', '2': 1},
    {'1': 'SHOP_CURRENCY_GEMS', '2': 2},
  ],
};

/// Descriptor for `ShopCurrency`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List shopCurrencyDescriptor = $convert.base64Decode(
    'CgxTaG9wQ3VycmVuY3kSHQoZU0hPUF9DVVJSRU5DWV9VTlNQRUNJRklFRBAAEhYKElNIT1BfQ1'
    'VSUkVOQ1lfR09MRBABEhYKElNIT1BfQ1VSUkVOQ1lfR0VNUxAC');

@$core.Deprecated('Use shopItemDescriptor instead')
const ShopItem$json = {
  '1': 'ShopItem',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'price', '3': 4, '4': 1, '5': 3, '10': 'price'},
    {'1': 'category', '3': 5, '4': 1, '5': 9, '10': 'category'},
    {'1': 'rarity', '3': 6, '4': 1, '5': 9, '10': 'rarity'},
    {'1': 'glb_asset_path', '3': 7, '4': 1, '5': 9, '10': 'glbAssetPath'},
    {'1': 'is_owned', '3': 8, '4': 1, '5': 8, '10': 'isOwned'},
  ],
};

/// Descriptor for `ShopItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List shopItemDescriptor = $convert.base64Decode(
    'CghTaG9wSXRlbRIOCgJpZBgBIAEoCVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRIgCgtkZXNjcm'
    'lwdGlvbhgDIAEoCVILZGVzY3JpcHRpb24SFAoFcHJpY2UYBCABKANSBXByaWNlEhoKCGNhdGVn'
    'b3J5GAUgASgJUghjYXRlZ29yeRIWCgZyYXJpdHkYBiABKAlSBnJhcml0eRIkCg5nbGJfYXNzZX'
    'RfcGF0aBgHIAEoCVIMZ2xiQXNzZXRQYXRoEhkKCGlzX293bmVkGAggASgIUgdpc093bmVk');

@$core.Deprecated('Use dailyDealDescriptor instead')
const DailyDeal$json = {
  '1': 'DailyDeal',
  '2': [
    {'1': 'item_id', '3': 1, '4': 1, '5': 9, '10': 'itemId'},
    {'1': 'discount_percent', '3': 2, '4': 1, '5': 5, '10': 'discountPercent'},
    {'1': 'expires_at', '3': 3, '4': 1, '5': 3, '10': 'expiresAt'},
  ],
};

/// Descriptor for `DailyDeal`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dailyDealDescriptor = $convert.base64Decode(
    'CglEYWlseURlYWwSFwoHaXRlbV9pZBgBIAEoCVIGaXRlbUlkEikKEGRpc2NvdW50X3BlcmNlbn'
    'QYAiABKAVSD2Rpc2NvdW50UGVyY2VudBIdCgpleHBpcmVzX2F0GAMgASgDUglleHBpcmVzQXQ=');

@$core.Deprecated('Use listShopItemsRequestDescriptor instead')
const ListShopItemsRequest$json = {
  '1': 'ListShopItemsRequest',
  '2': [
    {'1': 'category', '3': 1, '4': 1, '5': 9, '10': 'category'},
  ],
};

/// Descriptor for `ListShopItemsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listShopItemsRequestDescriptor =
    $convert.base64Decode(
        'ChRMaXN0U2hvcEl0ZW1zUmVxdWVzdBIaCghjYXRlZ29yeRgBIAEoCVIIY2F0ZWdvcnk=');

@$core.Deprecated('Use listShopItemsReplyDescriptor instead')
const ListShopItemsReply$json = {
  '1': 'ListShopItemsReply',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.api.shop.v1.ShopItem',
      '10': 'items'
    },
  ],
};

/// Descriptor for `ListShopItemsReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listShopItemsReplyDescriptor = $convert.base64Decode(
    'ChJMaXN0U2hvcEl0ZW1zUmVwbHkSKwoFaXRlbXMYASADKAsyFS5hcGkuc2hvcC52MS5TaG9wSX'
    'RlbVIFaXRlbXM=');

@$core.Deprecated('Use getDailyDealRequestDescriptor instead')
const GetDailyDealRequest$json = {
  '1': 'GetDailyDealRequest',
};

/// Descriptor for `GetDailyDealRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDailyDealRequestDescriptor =
    $convert.base64Decode('ChNHZXREYWlseURlYWxSZXF1ZXN0');

@$core.Deprecated('Use getDailyDealReplyDescriptor instead')
const GetDailyDealReply$json = {
  '1': 'GetDailyDealReply',
  '2': [
    {
      '1': 'deal',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.api.shop.v1.DailyDeal',
      '10': 'deal'
    },
  ],
};

/// Descriptor for `GetDailyDealReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDailyDealReplyDescriptor = $convert.base64Decode(
    'ChFHZXREYWlseURlYWxSZXBseRIqCgRkZWFsGAEgASgLMhYuYXBpLnNob3AudjEuRGFpbHlEZW'
    'FsUgRkZWFs');

@$core.Deprecated('Use buyItemRequestDescriptor instead')
const BuyItemRequest$json = {
  '1': 'BuyItemRequest',
  '2': [
    {'1': 'item_id', '3': 1, '4': 1, '5': 9, '10': 'itemId'},
    {
      '1': 'currency',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.api.shop.v1.ShopCurrency',
      '10': 'currency'
    },
  ],
};

/// Descriptor for `BuyItemRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List buyItemRequestDescriptor = $convert.base64Decode(
    'Cg5CdXlJdGVtUmVxdWVzdBIXCgdpdGVtX2lkGAEgASgJUgZpdGVtSWQSNQoIY3VycmVuY3kYAi'
    'ABKA4yGS5hcGkuc2hvcC52MS5TaG9wQ3VycmVuY3lSCGN1cnJlbmN5');

@$core.Deprecated('Use buyItemReplyDescriptor instead')
const BuyItemReply$json = {
  '1': 'BuyItemReply',
  '2': [
    {
      '1': 'item',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.api.shop.v1.ShopItem',
      '10': 'item'
    },
    {'1': 'balance', '3': 2, '4': 1, '5': 3, '10': 'balance'},
  ],
};

/// Descriptor for `BuyItemReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List buyItemReplyDescriptor = $convert.base64Decode(
    'CgxCdXlJdGVtUmVwbHkSKQoEaXRlbRgBIAEoCzIVLmFwaS5zaG9wLnYxLlNob3BJdGVtUgRpdG'
    'VtEhgKB2JhbGFuY2UYAiABKANSB2JhbGFuY2U=');

@$core.Deprecated('Use listOwnedItemsRequestDescriptor instead')
const ListOwnedItemsRequest$json = {
  '1': 'ListOwnedItemsRequest',
};

/// Descriptor for `ListOwnedItemsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listOwnedItemsRequestDescriptor =
    $convert.base64Decode('ChVMaXN0T3duZWRJdGVtc1JlcXVlc3Q=');

@$core.Deprecated('Use listOwnedItemsReplyDescriptor instead')
const ListOwnedItemsReply$json = {
  '1': 'ListOwnedItemsReply',
  '2': [
    {'1': 'item_ids', '3': 1, '4': 3, '5': 9, '10': 'itemIds'},
  ],
};

/// Descriptor for `ListOwnedItemsReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listOwnedItemsReplyDescriptor =
    $convert.base64Decode(
        'ChNMaXN0T3duZWRJdGVtc1JlcGx5EhkKCGl0ZW1faWRzGAEgAygJUgdpdGVtSWRz');

const $core.Map<$core.String, $core.dynamic> ShopServiceBase$json = {
  '1': 'ShopService',
  '2': [
    {
      '1': 'ListShopItems',
      '2': '.api.shop.v1.ListShopItemsRequest',
      '3': '.api.shop.v1.ListShopItemsReply',
      '4': {}
    },
    {
      '1': 'GetDailyDeal',
      '2': '.api.shop.v1.GetDailyDealRequest',
      '3': '.api.shop.v1.GetDailyDealReply',
      '4': {}
    },
    {
      '1': 'BuyItem',
      '2': '.api.shop.v1.BuyItemRequest',
      '3': '.api.shop.v1.BuyItemReply',
      '4': {}
    },
    {
      '1': 'ListOwnedItems',
      '2': '.api.shop.v1.ListOwnedItemsRequest',
      '3': '.api.shop.v1.ListOwnedItemsReply',
      '4': {}
    },
  ],
};

@$core.Deprecated('Use shopServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    ShopServiceBase$messageJson = {
  '.api.shop.v1.ListShopItemsRequest': ListShopItemsRequest$json,
  '.api.shop.v1.ListShopItemsReply': ListShopItemsReply$json,
  '.api.shop.v1.ShopItem': ShopItem$json,
  '.api.shop.v1.GetDailyDealRequest': GetDailyDealRequest$json,
  '.api.shop.v1.GetDailyDealReply': GetDailyDealReply$json,
  '.api.shop.v1.DailyDeal': DailyDeal$json,
  '.api.shop.v1.BuyItemRequest': BuyItemRequest$json,
  '.api.shop.v1.BuyItemReply': BuyItemReply$json,
  '.api.shop.v1.ListOwnedItemsRequest': ListOwnedItemsRequest$json,
  '.api.shop.v1.ListOwnedItemsReply': ListOwnedItemsReply$json,
};

/// Descriptor for `ShopService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List shopServiceDescriptor = $convert.base64Decode(
    'CgtTaG9wU2VydmljZRJvCg1MaXN0U2hvcEl0ZW1zEiEuYXBpLnNob3AudjEuTGlzdFNob3BJdG'
    'Vtc1JlcXVlc3QaHy5hcGkuc2hvcC52MS5MaXN0U2hvcEl0ZW1zUmVwbHkiGoLT5JMCFBISL2Fw'
    'aS92MS9zaG9wL2l0ZW1zEnEKDEdldERhaWx5RGVhbBIgLmFwaS5zaG9wLnYxLkdldERhaWx5RG'
    'VhbFJlcXVlc3QaHi5hcGkuc2hvcC52MS5HZXREYWlseURlYWxSZXBseSIfgtPkkwIZEhcvYXBp'
    'L3YxL3Nob3AvZGFpbHktZGVhbBJuCgdCdXlJdGVtEhsuYXBpLnNob3AudjEuQnV5SXRlbVJlcX'
    'Vlc3QaGS5hcGkuc2hvcC52MS5CdXlJdGVtUmVwbHkiK4LT5JMCJSIgL2FwaS92MS9zaG9wL2l0'
    'ZW1zL3tpdGVtX2lkfS9idXk6ASoScgoOTGlzdE93bmVkSXRlbXMSIi5hcGkuc2hvcC52MS5MaX'
    'N0T3duZWRJdGVtc1JlcXVlc3QaIC5hcGkuc2hvcC52MS5MaXN0T3duZWRJdGVtc1JlcGx5IhqC'
    '0+STAhQSEi9hcGkvdjEvc2hvcC9vd25lZA==');
