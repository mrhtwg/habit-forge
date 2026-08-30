import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:get/get.dart';
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

  // All available shop items (hardcoded MVP items)
  final allItems = <ShopItem>[
    ShopItem(
      id: 'sword_flame',
      name: 'Flame Sword',
      description: 'A sword wreathed in eternal flame',
      price: Int64(500),
      category: 'equipment',
      rarity: 'epic',
      glbAssetPath: null,
    ),
    ShopItem(
      id: 'armor_golden',
      name: 'Golden Armor',
      description: 'Shining golden plate armor',
      price: Int64(300),
      category: 'equipment',
      rarity: 'rare',
      glbAssetPath: null,
    ),
    ShopItem(
      id: 'helm_dragon',
      name: 'Dragon Helm',
      description: 'Helm forged from dragon scales',
      price: Int64(250),
      category: 'equipment',
      rarity: 'rare',
      glbAssetPath: null,
    ),
    ShopItem(
      id: 'cloak_shadow',
      name: 'Shadow Cloak',
      description: 'Cloak woven from shadow',
      price: Int64(150),
      category: 'appearance',
      rarity: 'common',
      glbAssetPath: null,
    ),
    ShopItem(
      id: 'amulet_star',
      name: 'Star Amulet',
      description: 'Amulet that glows like starlight',
      price: Int64(200),
      category: 'appearance',
      rarity: 'common',
      glbAssetPath: null,
    ),
    ShopItem(
      id: 'staff_arcane',
      name: 'Arcane Staff',
      description: 'A staff crackling with arcane energy',
      price: Int64(350),
      category: 'equipment',
      rarity: 'epic',
      glbAssetPath: null,
    ),
  ];

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

  /// Returns true if the purchase was successful (delegated to the storage layer).
  Future<bool> purchase(ShopItem item) {
    return _hive.purchaseItem(item.id, item.price.toInt(), currency: ShopCurrency.SHOP_CURRENCY_GOLD);
  }

  void _initDailyDeal() {
    final saved = _hive.dailyDeal.value;
    if (saved != null && DateTime(saved.expiresAt.toInt()).isAfter(DateTime.now())) {
      dailyDeal.value = saved;
      return;
    }
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final expiresAt = now.isAfter(endOfDay)
        ? DateTime(now.year, now.month, now.day, 23, 59, 59).add(const Duration(days: 1))
        : endOfDay;
    final deal = DailyDeal(
      itemId: 'staff_arcane',
      discountPercent: 40,
      expiresAt: Int64(expiresAt.millisecondsSinceEpoch),
    );
    dailyDeal.value = deal;
    _hive.saveDailyDeal(deal);
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
