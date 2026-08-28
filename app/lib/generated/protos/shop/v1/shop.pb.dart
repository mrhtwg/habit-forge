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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'shop.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'shop.pbenum.dart';

/// ShopItem — a purchasable cosmetic or equipment item.
class ShopItem extends $pb.GeneratedMessage {
  factory ShopItem({
    $core.String? id,
    $core.String? name,
    $core.String? description,
    $fixnum.Int64? price,
    $core.String? category,
    $core.String? rarity,
    $core.String? glbAssetPath,
    $core.bool? isOwned,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (price != null) result.price = price;
    if (category != null) result.category = category;
    if (rarity != null) result.rarity = rarity;
    if (glbAssetPath != null) result.glbAssetPath = glbAssetPath;
    if (isOwned != null) result.isOwned = isOwned;
    return result;
  }

  ShopItem._();

  factory ShopItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ShopItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ShopItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.shop.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aInt64(4, _omitFieldNames ? '' : 'price')
    ..aOS(5, _omitFieldNames ? '' : 'category')
    ..aOS(6, _omitFieldNames ? '' : 'rarity')
    ..aOS(7, _omitFieldNames ? '' : 'glbAssetPath')
    ..aOB(8, _omitFieldNames ? '' : 'isOwned')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ShopItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ShopItem copyWith(void Function(ShopItem) updates) =>
      super.copyWith((message) => updates(message as ShopItem)) as ShopItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ShopItem create() => ShopItem._();
  @$core.override
  ShopItem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ShopItem getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ShopItem>(create);
  static ShopItem? _defaultInstance;

  /// Unique item id.
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  /// Display name.
  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  /// Display description.
  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  /// Price in the currency chosen at purchase time.
  @$pb.TagNumber(4)
  $fixnum.Int64 get price => $_getI64(3);
  @$pb.TagNumber(4)
  set price($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPrice() => $_has(3);
  @$pb.TagNumber(4)
  void clearPrice() => $_clearField(4);

  /// Equipment category: "weapon" | "helmet" | "armor" | "accessory".
  @$pb.TagNumber(5)
  $core.String get category => $_getSZ(4);
  @$pb.TagNumber(5)
  set category($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCategory() => $_has(4);
  @$pb.TagNumber(5)
  void clearCategory() => $_clearField(5);

  /// Rarity tier: "common" | "rare" | "epic" | "legendary".
  @$pb.TagNumber(6)
  $core.String get rarity => $_getSZ(5);
  @$pb.TagNumber(6)
  set rarity($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRarity() => $_has(5);
  @$pb.TagNumber(6)
  void clearRarity() => $_clearField(6);

  /// Path of the 3D model asset (glb) rendered in the app.
  @$pb.TagNumber(7)
  $core.String get glbAssetPath => $_getSZ(6);
  @$pb.TagNumber(7)
  set glbAssetPath($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasGlbAssetPath() => $_has(6);
  @$pb.TagNumber(7)
  void clearGlbAssetPath() => $_clearField(7);

  /// Whether the current user already owns this item.
  @$pb.TagNumber(8)
  $core.bool get isOwned => $_getBF(7);
  @$pb.TagNumber(8)
  set isOwned($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasIsOwned() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsOwned() => $_clearField(8);
}

/// DailyDeal — a rotating discounted item.
class DailyDeal extends $pb.GeneratedMessage {
  factory DailyDeal({
    $core.String? itemId,
    $core.int? discountPercent,
    $fixnum.Int64? expiresAt,
  }) {
    final result = create();
    if (itemId != null) result.itemId = itemId;
    if (discountPercent != null) result.discountPercent = discountPercent;
    if (expiresAt != null) result.expiresAt = expiresAt;
    return result;
  }

  DailyDeal._();

  factory DailyDeal.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DailyDeal.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DailyDeal',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.shop.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'itemId')
    ..aI(2, _omitFieldNames ? '' : 'discountPercent')
    ..aInt64(3, _omitFieldNames ? '' : 'expiresAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DailyDeal clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DailyDeal copyWith(void Function(DailyDeal) updates) =>
      super.copyWith((message) => updates(message as DailyDeal)) as DailyDeal;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DailyDeal create() => DailyDeal._();
  @$core.override
  DailyDeal createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DailyDeal getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DailyDeal>(create);
  static DailyDeal? _defaultInstance;

  /// Id of the discounted item.
  @$pb.TagNumber(1)
  $core.String get itemId => $_getSZ(0);
  @$pb.TagNumber(1)
  set itemId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasItemId() => $_has(0);
  @$pb.TagNumber(1)
  void clearItemId() => $_clearField(1);

  /// Discount percentage (0-100).
  @$pb.TagNumber(2)
  $core.int get discountPercent => $_getIZ(1);
  @$pb.TagNumber(2)
  set discountPercent($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDiscountPercent() => $_has(1);
  @$pb.TagNumber(2)
  void clearDiscountPercent() => $_clearField(2);

  /// Time the deal expires, unix millis.
  @$pb.TagNumber(3)
  $fixnum.Int64 get expiresAt => $_getI64(2);
  @$pb.TagNumber(3)
  set expiresAt($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExpiresAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpiresAt() => $_clearField(3);
}

/// ListShopItemsRequest — optional filtering for the shop catalog.
class ListShopItemsRequest extends $pb.GeneratedMessage {
  factory ListShopItemsRequest({
    $core.String? category,
  }) {
    final result = create();
    if (category != null) result.category = category;
    return result;
  }

  ListShopItemsRequest._();

  factory ListShopItemsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListShopItemsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListShopItemsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.shop.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'category')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListShopItemsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListShopItemsRequest copyWith(void Function(ListShopItemsRequest) updates) =>
      super.copyWith((message) => updates(message as ListShopItemsRequest))
          as ListShopItemsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListShopItemsRequest create() => ListShopItemsRequest._();
  @$core.override
  ListShopItemsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListShopItemsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListShopItemsRequest>(create);
  static ListShopItemsRequest? _defaultInstance;

  /// Optional filter by equipment category.
  @$pb.TagNumber(1)
  $core.String get category => $_getSZ(0);
  @$pb.TagNumber(1)
  set category($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCategory() => $_has(0);
  @$pb.TagNumber(1)
  void clearCategory() => $_clearField(1);
}

/// ListShopItemsReply — the shop catalog.
class ListShopItemsReply extends $pb.GeneratedMessage {
  factory ListShopItemsReply({
    $core.Iterable<ShopItem>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  ListShopItemsReply._();

  factory ListShopItemsReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListShopItemsReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListShopItemsReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.shop.v1'),
      createEmptyInstance: create)
    ..pPM<ShopItem>(1, _omitFieldNames ? '' : 'items',
        subBuilder: ShopItem.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListShopItemsReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListShopItemsReply copyWith(void Function(ListShopItemsReply) updates) =>
      super.copyWith((message) => updates(message as ListShopItemsReply))
          as ListShopItemsReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListShopItemsReply create() => ListShopItemsReply._();
  @$core.override
  ListShopItemsReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListShopItemsReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListShopItemsReply>(create);
  static ListShopItemsReply? _defaultInstance;

  /// The matching shop items.
  @$pb.TagNumber(1)
  $pb.PbList<ShopItem> get items => $_getList(0);
}

/// GetDailyDealRequest — no parameters.
class GetDailyDealRequest extends $pb.GeneratedMessage {
  factory GetDailyDealRequest() => create();

  GetDailyDealRequest._();

  factory GetDailyDealRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDailyDealRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDailyDealRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.shop.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDailyDealRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDailyDealRequest copyWith(void Function(GetDailyDealRequest) updates) =>
      super.copyWith((message) => updates(message as GetDailyDealRequest))
          as GetDailyDealRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDailyDealRequest create() => GetDailyDealRequest._();
  @$core.override
  GetDailyDealRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDailyDealRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDailyDealRequest>(create);
  static GetDailyDealRequest? _defaultInstance;
}

/// GetDailyDealReply — the current daily deal.
class GetDailyDealReply extends $pb.GeneratedMessage {
  factory GetDailyDealReply({
    DailyDeal? deal,
  }) {
    final result = create();
    if (deal != null) result.deal = deal;
    return result;
  }

  GetDailyDealReply._();

  factory GetDailyDealReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDailyDealReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDailyDealReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.shop.v1'),
      createEmptyInstance: create)
    ..aOM<DailyDeal>(1, _omitFieldNames ? '' : 'deal',
        subBuilder: DailyDeal.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDailyDealReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDailyDealReply copyWith(void Function(GetDailyDealReply) updates) =>
      super.copyWith((message) => updates(message as GetDailyDealReply))
          as GetDailyDealReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDailyDealReply create() => GetDailyDealReply._();
  @$core.override
  GetDailyDealReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDailyDealReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDailyDealReply>(create);
  static GetDailyDealReply? _defaultInstance;

  /// The active deal; absent when no deal is running.
  @$pb.TagNumber(1)
  DailyDeal get deal => $_getN(0);
  @$pb.TagNumber(1)
  set deal(DailyDeal value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDeal() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeal() => $_clearField(1);
  @$pb.TagNumber(1)
  DailyDeal ensureDeal() => $_ensure(0);
}

/// BuyItemRequest — the item and currency to spend.
class BuyItemRequest extends $pb.GeneratedMessage {
  factory BuyItemRequest({
    $core.String? itemId,
    ShopCurrency? currency,
  }) {
    final result = create();
    if (itemId != null) result.itemId = itemId;
    if (currency != null) result.currency = currency;
    return result;
  }

  BuyItemRequest._();

  factory BuyItemRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BuyItemRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BuyItemRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.shop.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'itemId')
    ..aE<ShopCurrency>(2, _omitFieldNames ? '' : 'currency',
        enumValues: ShopCurrency.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuyItemRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuyItemRequest copyWith(void Function(BuyItemRequest) updates) =>
      super.copyWith((message) => updates(message as BuyItemRequest))
          as BuyItemRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BuyItemRequest create() => BuyItemRequest._();
  @$core.override
  BuyItemRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BuyItemRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BuyItemRequest>(create);
  static BuyItemRequest? _defaultInstance;

  /// Id of the item to purchase.
  @$pb.TagNumber(1)
  $core.String get itemId => $_getSZ(0);
  @$pb.TagNumber(1)
  set itemId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasItemId() => $_has(0);
  @$pb.TagNumber(1)
  void clearItemId() => $_clearField(1);

  /// Currency used for the payment.
  @$pb.TagNumber(2)
  ShopCurrency get currency => $_getN(1);
  @$pb.TagNumber(2)
  set currency(ShopCurrency value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCurrency() => $_has(1);
  @$pb.TagNumber(2)
  void clearCurrency() => $_clearField(2);
}

/// BuyItemReply — the purchase result.
class BuyItemReply extends $pb.GeneratedMessage {
  factory BuyItemReply({
    ShopItem? item,
    $fixnum.Int64? balance,
  }) {
    final result = create();
    if (item != null) result.item = item;
    if (balance != null) result.balance = balance;
    return result;
  }

  BuyItemReply._();

  factory BuyItemReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BuyItemReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BuyItemReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.shop.v1'),
      createEmptyInstance: create)
    ..aOM<ShopItem>(1, _omitFieldNames ? '' : 'item',
        subBuilder: ShopItem.create)
    ..aInt64(2, _omitFieldNames ? '' : 'balance')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuyItemReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuyItemReply copyWith(void Function(BuyItemReply) updates) =>
      super.copyWith((message) => updates(message as BuyItemReply))
          as BuyItemReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BuyItemReply create() => BuyItemReply._();
  @$core.override
  BuyItemReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BuyItemReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BuyItemReply>(create);
  static BuyItemReply? _defaultInstance;

  /// The purchased item (now owned).
  @$pb.TagNumber(1)
  ShopItem get item => $_getN(0);
  @$pb.TagNumber(1)
  set item(ShopItem value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasItem() => $_has(0);
  @$pb.TagNumber(1)
  void clearItem() => $_clearField(1);
  @$pb.TagNumber(1)
  ShopItem ensureItem() => $_ensure(0);

  /// Remaining balance of the spent currency.
  @$pb.TagNumber(2)
  $fixnum.Int64 get balance => $_getI64(1);
  @$pb.TagNumber(2)
  set balance($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBalance() => $_has(1);
  @$pb.TagNumber(2)
  void clearBalance() => $_clearField(2);
}

/// ListOwnedItemsRequest — no parameters.
class ListOwnedItemsRequest extends $pb.GeneratedMessage {
  factory ListOwnedItemsRequest() => create();

  ListOwnedItemsRequest._();

  factory ListOwnedItemsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListOwnedItemsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListOwnedItemsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.shop.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListOwnedItemsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListOwnedItemsRequest copyWith(
          void Function(ListOwnedItemsRequest) updates) =>
      super.copyWith((message) => updates(message as ListOwnedItemsRequest))
          as ListOwnedItemsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListOwnedItemsRequest create() => ListOwnedItemsRequest._();
  @$core.override
  ListOwnedItemsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListOwnedItemsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListOwnedItemsRequest>(create);
  static ListOwnedItemsRequest? _defaultInstance;
}

/// ListOwnedItemsReply — ids of all items the user owns.
class ListOwnedItemsReply extends $pb.GeneratedMessage {
  factory ListOwnedItemsReply({
    $core.Iterable<$core.String>? itemIds,
  }) {
    final result = create();
    if (itemIds != null) result.itemIds.addAll(itemIds);
    return result;
  }

  ListOwnedItemsReply._();

  factory ListOwnedItemsReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListOwnedItemsReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListOwnedItemsReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'api.shop.v1'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'itemIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListOwnedItemsReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListOwnedItemsReply copyWith(void Function(ListOwnedItemsReply) updates) =>
      super.copyWith((message) => updates(message as ListOwnedItemsReply))
          as ListOwnedItemsReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListOwnedItemsReply create() => ListOwnedItemsReply._();
  @$core.override
  ListOwnedItemsReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListOwnedItemsReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListOwnedItemsReply>(create);
  static ListOwnedItemsReply? _defaultInstance;

  /// Owned item ids.
  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get itemIds => $_getList(0);
}

/// ShopService — Forge shop: items, daily deals, purchases, owned items.
class ShopServiceApi {
  final $pb.RpcClient _client;

  ShopServiceApi(this._client);

  /// ListShopItems lists all purchasable shop items.
  $async.Future<ListShopItemsReply> listShopItems(
          $pb.ClientContext? ctx, ListShopItemsRequest request) =>
      _client.invoke<ListShopItemsReply>(
          ctx, 'ShopService', 'ListShopItems', request, ListShopItemsReply());

  /// GetDailyDeal returns the current rotating discounted item.
  $async.Future<GetDailyDealReply> getDailyDeal(
          $pb.ClientContext? ctx, GetDailyDealRequest request) =>
      _client.invoke<GetDailyDealReply>(
          ctx, 'ShopService', 'GetDailyDeal', request, GetDailyDealReply());

  /// BuyItem purchases an item with gold or gems.
  $async.Future<BuyItemReply> buyItem(
          $pb.ClientContext? ctx, BuyItemRequest request) =>
      _client.invoke<BuyItemReply>(
          ctx, 'ShopService', 'BuyItem', request, BuyItemReply());

  /// ListOwnedItems lists items the current user owns.
  $async.Future<ListOwnedItemsReply> listOwnedItems(
          $pb.ClientContext? ctx, ListOwnedItemsRequest request) =>
      _client.invoke<ListOwnedItemsReply>(
          ctx, 'ShopService', 'ListOwnedItems', request, ListOwnedItemsReply());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
