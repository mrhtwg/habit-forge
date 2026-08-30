import 'dart:async';

import 'package:get/get.dart';
import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';

class ForgeController extends GetxController {
  final _hive = NetworkRegistry.ins;

  final activeCategory = 'appearance'.obs;
  // Daily deal
  final dailyDeal = Rxn<DailyDeal>();
  final countdown = ''.obs;

  Timer? _countdownTimer;

  // Shop catalog is served by the storage layer (simulating a backend).
  List<ShopItem> get allItems => _hive.shopItems;

  int get currentGold => _hive.userPrefs.value?.currentGold.toInt() ?? 0;

  ShopItem? get dailyDealItem {
    final deal = dailyDeal.value;
    if (deal == null) return null;
    final matches = allItems.where((i) => i.id == deal.itemId);
    return matches.isNotEmpty ? matches.first : null;
  }

  List<ShopItem> get filteredItems {
    return allItems.where((i) => i.category == activeCategory.value).toList();
  }

  bool canAfford(int price) {
    final prefs = _hive.userPrefs.value ?? UserPrefs();
    return prefs.currentGold >= price;
  }

  void equip(String itemId) {
    _hive.equipItem(itemId);
  }

  int goldShortfall(int price) {
    final prefs = _hive.userPrefs.value ?? UserPrefs();
    final needed = price - prefs.currentGold.toInt();
    return needed > 0 ? needed : 0;
  }

  bool isOwned(String itemId) => _hive.ownedItemIds.contains(itemId);

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    _initDailyDeal();
    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  /// Delegates the purchase to the storage layer, which validates the balance,
  /// charges the wallet and marks the item as owned.
  Future<ApiResponse<BuyItemReply>> purchase(ShopItem item) {
    return _hive.purchaseItem(item.id);
  }

  Future<void> _initDailyDeal() async {
    dailyDeal.value = await _hive.refreshDailyDeal();
  }

  void _updateCountdown() {
    final deal = dailyDeal.value;
    if (deal == null) {
      countdown.value = '00:00:00';
      return;
    }
    final remaining = DateTime(deal.expiresAt.toInt()).difference(DateTime.now());
    if (remaining.isNegative) {
      countdown.value = '00:00:00';
      return;
    }
    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    countdown.value = '$hours:$minutes:$seconds';
  }
}
