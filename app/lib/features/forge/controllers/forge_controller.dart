import 'dart:async';

import 'package:get/get.dart';
import 'package:habit_forge_app/core/services/hive_service.dart';
import 'package:habit_forge_app/models/shop/daily_deal.dart';
import 'package:habit_forge_app/models/shop/shop_item.dart';
import 'package:habit_forge_app/models/user/user_prefs.dart';

class ForgeController extends GetxController {
  /// Emoji icon mapping per item id.
  static const _itemEmojis = <String, String>{
    'sword_flame': '🗡️',
    'armor_golden': '🛡️',
    'helm_dragon': '👑',
    'cloak_shadow': '🧙',
    'amulet_star': '⭐',
    'staff_arcane': '🔮',
  };
  final _hive = HiveService.to;

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
        price: 500,
        category: 'equipment',
        rarity: 'epic',
        glbAssetPath: null,),
    ShopItem(
        id: 'armor_golden',
        name: 'Golden Armor',
        description: 'Shining golden plate armor',
        price: 300,
        category: 'equipment',
        rarity: 'rare',
        glbAssetPath: null,),
    ShopItem(
        id: 'helm_dragon',
        name: 'Dragon Helm',
        description: 'Helm forged from dragon scales',
        price: 250,
        category: 'equipment',
        rarity: 'rare',
        glbAssetPath: null,),
    ShopItem(
        id: 'cloak_shadow',
        name: 'Shadow Cloak',
        description: 'Cloak woven from shadow',
        price: 150,
        category: 'appearance',
        rarity: 'common',
        glbAssetPath: null,),
    ShopItem(
        id: 'amulet_star',
        name: 'Star Amulet',
        description: 'Amulet that glows like starlight',
        price: 200,
        category: 'appearance',
        rarity: 'common',
        glbAssetPath: null,),
    ShopItem(
        id: 'staff_arcane',
        name: 'Arcane Staff',
        description: 'A staff crackling with arcane energy',
        price: 350,
        category: 'equipment',
        rarity: 'epic',
        glbAssetPath: null,),
  ];

  int get currentGold => _hive.userPrefs.value?.currentGold ?? 0;

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
    final prefs = _hive.userPrefs.value ?? const UserPrefs();
    return prefs.currentGold >= price;
  }

  String emojiFor(String itemId) => _itemEmojis[itemId] ?? '📦';

  void equip(String itemId) {
    final char = _hive.character.value;
    if (char == null) return;
    final equipment = Map<String, String>.from(char.equipment);
    if (equipment['weapon'] == itemId) {
      equipment.remove('weapon');
    } else {
      equipment['weapon'] = itemId;
    }
    _hive.saveCharacter(char.copyWith(equipment: equipment));
  }

  int goldShortfall(int price) {
    final prefs = _hive.userPrefs.value ?? const UserPrefs();
    final needed = price - prefs.currentGold;
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

  /// Returns true if the purchase was successful.
  bool purchase(ShopItem item) {
    final prefs = _hive.userPrefs.value ?? const UserPrefs();
    if (prefs.currentGold < item.price) return false;
    if (isOwned(item.id)) return false;

    _hive.saveUserPrefs(prefs.copyWith(currentGold: prefs.currentGold - item.price));
    _hive.addOwnedItem(item.id);
    return true;
  }

  void _initDailyDeal() {
    final saved = _hive.dailyDeal.value;
    if (saved != null && saved.expiresAt.isAfter(DateTime.now())) {
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
      expiresAt: expiresAt,
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
    final remaining = deal.expiresAt.difference(DateTime.now());
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
