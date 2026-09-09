import 'dart:async';

import 'package:get/get.dart';
import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/hive/shop_config.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:habit_forge_app/widgets/toast_widget.dart';

class ForgeController extends GetxController {
  final shopItems = <ShopItem>[].obs;
  final ownedIds = <String>[].obs;
  final activeCategory = 'equipment'.obs;
  // Daily deal
  final dailyDeal = DailyDeal().obs;
  final countdown = ''.obs;
  // 2-hour rotating picks
  final rotating = <ShopItem>[].obs;
  final rotationCountdown = ''.obs;

  Timer? _countdownTimer;
  int _rotationWindow = -1;

  ShopItem? get dailyDealItem {
    final deal = dailyDeal.value;
    final matches = shopItems.where((i) => i.id == deal.itemId);
    return matches.isNotEmpty ? matches.first : null;
  }

  /// The currency this item is bought with (skins -> gems, else gold).
  ShopCurrency currencyOf(ShopItem item) => ShopConfig.currencyOf(item.id);

  /// Whether the item is a character skin (bought with gems, not equipped to a
  /// weapon/helmet/armor/accessory slot).
  bool isSkin(ShopItem item) => ShopConfig.isSkin(item.id);

  /// Current balance in the item's currency.
  int balanceOf(ShopItem item) {
    final prefs = UserService.to.userPrefs.value;
    return currencyOf(item) == ShopCurrency.SHOP_CURRENCY_GEMS ? prefs.currentGems.toInt() : prefs.currentGold.toInt();
  }

  bool canAfford(ShopItem item) => balanceOf(item) >= item.price.toInt();

  int shortfall(ShopItem item) {
    final needed = item.price.toInt() - balanceOf(item);
    return needed > 0 ? needed : 0;
  }

  /// Equips an owned item into its own slot (skins have no equipment slot).
  void equip(ShopItem item) {
    NetworkRegistry.ins.equipItem(item.id, item.slot);
    UserService.to.loadCharacter();
  }

  bool isOwned(String itemId) => ownedIds.contains(itemId);

  /// Items shown in the active category tab.
  List<ShopItem> get filteredItems {
    final category = activeCategory.value;
    return shopItems.where((i) => ShopConfig.categoryOf(i.id) == category).toList();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();

    listItems();
    loadOwned();
    _initDailyDeal();
    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  Future<void> listItems() async {
    final result = await NetworkRegistry.ins.listShopItems();
    if (result.isSuccess) {
      shopItems.value = result.data!.items;
      _refreshRotation();
    }
  }

  /// (Re)computes the rotating batch for the current 2-hour window.
  void _refreshRotation() {
    final now = DateTime.now();
    _rotationWindow = ShopConfig.rotationWindowOf(now);
    rotating.value = ShopConfig.rotatingBatch(shopItems, now, size: 6);
  }

  Future<void> loadOwned() async {
    final result = await NetworkRegistry.ins.listOwnedItems();
    if (result.isSuccess) {
      ownedIds.value = result.data!.itemIds;
    }
  }

  /// Delegates the purchase to the storage layer (the item's own currency
  /// decides gold vs gems), then refreshes wallet + owned + catalog.
  Future<ApiResponse<BuyItemReply>> purchase(ShopItem item) async {
    final result = await NetworkRegistry.ins.purchaseItem(item.id, currencyOf(item));
    if (result.isSuccess) {
      await UserService.to.loadUserPrefs();
      await loadOwned();
      listItems();
    }
    return result;
  }

  Future<void> _initDailyDeal() async {
    final result = await NetworkRegistry.ins.getDailyDeal();
    result.when(onSuccess: (reply) => dailyDeal.value = reply, onFailure: (code, msg) => Toast.error(msg));
  }

  void _updateCountdown() {
    final now = DateTime.now();

    // Daily deal remaining time.
    final deal = dailyDeal.value;
    final remaining = DateTime.fromMillisecondsSinceEpoch(deal.expiresAt.toInt()).difference(now);
    countdown.value = remaining.isNegative ? '00:00:00' : _fmt(remaining);

    // 2-hour rotation: swap the batch the moment a new window starts.
    final window = ShopConfig.rotationWindowOf(now);
    if (window != _rotationWindow) _refreshRotation();
    rotationCountdown.value = _fmt(ShopConfig.nextRotationAt(now).difference(now));
  }

  static String _fmt(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
