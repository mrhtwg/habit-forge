import 'dart:async';

import 'package:get/get.dart';
import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';

class ForgeController extends GetxController {
  final allItems = <ShopItem>[].obs;
  final activeCategory = 'appearance'.obs;
  // Daily deal
  final dailyDeal = Rxn<DailyDeal>();
  final countdown = ''.obs;

  Timer? _countdownTimer;

  ShopItem? get dailyDealItem {
    final deal = dailyDeal.value;
    if (deal == null) return null;
    final matches = allItems.where((i) => i.id == deal.itemId);
    return matches.isNotEmpty ? matches.first : null;
  }

  bool canAfford(int price) {
    return UserService.to.gold >= price;
  }

  void equip(String itemId) {
    NetworkRegistry.ins.equipItem(itemId, EquipmentSlot.EQUIPMENT_SLOT_WEAPON);
  }

  int goldShortfall(int price) {
    final needed = price - UserService.to.gold.value;
    return needed > 0 ? needed : 0;
  }

  bool isOwned(String itemId) => UserService.to.shopItems.contains(itemId);

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
  Future<ApiResponse<BuyItemReply>> purchase(ShopItem item) async =>
      await NetworkRegistry.ins.purchaseItem(item.id, ShopCurrency.SHOP_CURRENCY_GEMS);

  Future<void> _initDailyDeal() async {
    dailyDeal.value = await NetworkRegistry.ins.refreshDailyDeal();
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
