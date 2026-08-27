// This is a generated file - do not edit.
//
// Generated from shop/v1/shop.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'shop.pb.dart' as $0;
import 'shop.pbjson.dart';

export 'shop.pb.dart';

abstract class ShopServiceBase extends $pb.GeneratedService {
  $async.Future<$0.ListShopItemsReply> listShopItems(
      $pb.ServerContext ctx, $0.ListShopItemsRequest request);
  $async.Future<$0.GetDailyDealReply> getDailyDeal(
      $pb.ServerContext ctx, $0.GetDailyDealRequest request);
  $async.Future<$0.BuyItemReply> buyItem(
      $pb.ServerContext ctx, $0.BuyItemRequest request);
  $async.Future<$0.ListOwnedItemsReply> listOwnedItems(
      $pb.ServerContext ctx, $0.ListOwnedItemsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListShopItems':
        return $0.ListShopItemsRequest();
      case 'GetDailyDeal':
        return $0.GetDailyDealRequest();
      case 'BuyItem':
        return $0.BuyItemRequest();
      case 'ListOwnedItems':
        return $0.ListOwnedItemsRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListShopItems':
        return listShopItems(ctx, request as $0.ListShopItemsRequest);
      case 'GetDailyDeal':
        return getDailyDeal(ctx, request as $0.GetDailyDealRequest);
      case 'BuyItem':
        return buyItem(ctx, request as $0.BuyItemRequest);
      case 'ListOwnedItems':
        return listOwnedItems(ctx, request as $0.ListOwnedItemsRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ShopServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => ShopServiceBase$messageJson;
}
