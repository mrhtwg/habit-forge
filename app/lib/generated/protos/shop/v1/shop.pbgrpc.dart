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

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'shop.pb.dart' as $0;

export 'shop.pb.dart';

/// ShopService — Forge shop: items, daily deals, purchases, owned items.
@$pb.GrpcServiceName('api.shop.v1.ShopService')
class ShopServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ShopServiceClient(super.channel, {super.options, super.interceptors});

  /// ListShopItems lists all purchasable shop items.
  $grpc.ResponseFuture<$0.ListShopItemsReply> listShopItems(
    $0.ListShopItemsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listShopItems, request, options: options);
  }

  /// GetDailyDeal returns the current rotating discounted item.
  $grpc.ResponseFuture<$0.GetDailyDealReply> getDailyDeal(
    $0.GetDailyDealRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getDailyDeal, request, options: options);
  }

  /// BuyItem purchases an item with gold or gems.
  $grpc.ResponseFuture<$0.BuyItemReply> buyItem(
    $0.BuyItemRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$buyItem, request, options: options);
  }

  /// ListOwnedItems lists items the current user owns.
  $grpc.ResponseFuture<$0.ListOwnedItemsReply> listOwnedItems(
    $0.ListOwnedItemsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listOwnedItems, request, options: options);
  }

  // method descriptors

  static final _$listShopItems =
      $grpc.ClientMethod<$0.ListShopItemsRequest, $0.ListShopItemsReply>(
          '/api.shop.v1.ShopService/ListShopItems',
          ($0.ListShopItemsRequest value) => value.writeToBuffer(),
          $0.ListShopItemsReply.fromBuffer);
  static final _$getDailyDeal =
      $grpc.ClientMethod<$0.GetDailyDealRequest, $0.GetDailyDealReply>(
          '/api.shop.v1.ShopService/GetDailyDeal',
          ($0.GetDailyDealRequest value) => value.writeToBuffer(),
          $0.GetDailyDealReply.fromBuffer);
  static final _$buyItem =
      $grpc.ClientMethod<$0.BuyItemRequest, $0.BuyItemReply>(
          '/api.shop.v1.ShopService/BuyItem',
          ($0.BuyItemRequest value) => value.writeToBuffer(),
          $0.BuyItemReply.fromBuffer);
  static final _$listOwnedItems =
      $grpc.ClientMethod<$0.ListOwnedItemsRequest, $0.ListOwnedItemsReply>(
          '/api.shop.v1.ShopService/ListOwnedItems',
          ($0.ListOwnedItemsRequest value) => value.writeToBuffer(),
          $0.ListOwnedItemsReply.fromBuffer);
}

@$pb.GrpcServiceName('api.shop.v1.ShopService')
abstract class ShopServiceBase extends $grpc.Service {
  $core.String get $name => 'api.shop.v1.ShopService';

  ShopServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.ListShopItemsRequest, $0.ListShopItemsReply>(
            'ListShopItems',
            listShopItems_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ListShopItemsRequest.fromBuffer(value),
            ($0.ListShopItemsReply value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetDailyDealRequest, $0.GetDailyDealReply>(
            'GetDailyDeal',
            getDailyDeal_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetDailyDealRequest.fromBuffer(value),
            ($0.GetDailyDealReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.BuyItemRequest, $0.BuyItemReply>(
        'BuyItem',
        buyItem_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.BuyItemRequest.fromBuffer(value),
        ($0.BuyItemReply value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ListOwnedItemsRequest, $0.ListOwnedItemsReply>(
            'ListOwnedItems',
            listOwnedItems_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ListOwnedItemsRequest.fromBuffer(value),
            ($0.ListOwnedItemsReply value) => value.writeToBuffer()));
  }

  $async.Future<$0.ListShopItemsReply> listShopItems_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListShopItemsRequest> $request) async {
    return listShopItems($call, await $request);
  }

  $async.Future<$0.ListShopItemsReply> listShopItems(
      $grpc.ServiceCall call, $0.ListShopItemsRequest request);

  $async.Future<$0.GetDailyDealReply> getDailyDeal_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetDailyDealRequest> $request) async {
    return getDailyDeal($call, await $request);
  }

  $async.Future<$0.GetDailyDealReply> getDailyDeal(
      $grpc.ServiceCall call, $0.GetDailyDealRequest request);

  $async.Future<$0.BuyItemReply> buyItem_Pre($grpc.ServiceCall $call,
      $async.Future<$0.BuyItemRequest> $request) async {
    return buyItem($call, await $request);
  }

  $async.Future<$0.BuyItemReply> buyItem(
      $grpc.ServiceCall call, $0.BuyItemRequest request);

  $async.Future<$0.ListOwnedItemsReply> listOwnedItems_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListOwnedItemsRequest> $request) async {
    return listOwnedItems($call, await $request);
  }

  $async.Future<$0.ListOwnedItemsReply> listOwnedItems(
      $grpc.ServiceCall call, $0.ListOwnedItemsRequest request);
}
