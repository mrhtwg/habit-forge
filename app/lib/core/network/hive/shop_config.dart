import 'package:fixnum/fixnum.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:habit_forge_app/core/common/utils/log.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:yaml/yaml.dart';

/// Initial shop/achievement configuration loaded from `assets/config/config.yml`
/// (the same file lives at the repo root as `config/config.yml`).
///
/// Call [ShopConfig.load] once at startup; on failure the built-in defaults
/// are kept so the app still works.
class ShopConfig {
  ShopConfig._();

  static List<Achievement> achievementDefs = _defaultAchievements();
  static List<ShopItem> shopItems = _defaultShopItems();

  /// Ids of diamond-bought character skins (from the `skins` section).
  static final Set<String> _skinIds = <String>{};

  /// itemId -> UI category: 'equipment' | 'appearance'.
  static final Map<String, String> _categories = <String, String>{};

  /// itemId -> attribute bonus granted while equipped. Equipment only;
  /// appearance items (cosmetics / skins) grant no stats.
  static final Map<String, CharacterStats> _bonus = <String, CharacterStats>{};

  /// itemId -> icon asset filename (from the `icon` field in config).
  static final Map<String, String> _icons = <String, String>{};

  /// itemIds of equipment sold for gems (config `currency: "gems"`).
  static final Set<String> _gemItemIds = <String>{};

  /// Whether the item is bought with gems (skins and gem-priced equipment).
  static bool isGemItem(String itemId) => _skinIds.contains(itemId) || _gemItemIds.contains(itemId);

  /// The stat bonus an item grants while equipped (all zeros for appearance).
  static CharacterStats bonusStatsOf(String itemId) => _bonus[itemId] ?? CharacterStats();

  /// Asset filename of the item's icon (e.g. `sword_flame.webp`), or '' when
  /// the item has no icon file configured.
  static String iconOf(String itemId) => _icons[itemId] ?? '';

  /// The UI category of an item. Appearance/skin items were deferred until the
  /// skeletal-animation character system lands, so everything is equipment now.
  static String categoryOf(String itemId) => _categories[itemId] ?? 'equipment';

  /// Whether [itemId] is a character skin (bought with gems).
  static bool isSkin(String itemId) => _skinIds.contains(itemId);

  /// The currency a shop item is bought with (skins & gem-priced equipment ->
  /// gems, everything else gold).
  static ShopCurrency currencyOf(String itemId) =>
      isGemItem(itemId) ? ShopCurrency.SHOP_CURRENCY_GEMS : ShopCurrency.SHOP_CURRENCY_GOLD;

  // ── Rotating picks (refreshes every 2 hours) ──

  /// Index of the current 2-hour rotation window (minutes since local
  /// midnight divided by 120): windows start at local 00:00 / 02:00 / 04:00…
  static int rotationWindowOf(DateTime now) => (now.hour * 60 + now.minute) ~/ 120;

  /// The next rotation boundary after [now].
  static DateTime nextRotationAt(DateTime now) {
    final midnight = DateTime(now.year, now.month, now.day);
    return midnight.add(Duration(minutes: (rotationWindowOf(now) + 1) * 120));
  }

  /// Deterministic rotating batch for the current 2-hour window: up to [size]
  /// picks from [catalog], with at least one epic/legendary when the catalog
  /// has any. The same window always yields the same picks, so the shop stays
  /// stable across restarts and only changes at the boundary.
  static List<ShopItem> rotatingBatch(List<ShopItem> catalog, DateTime now, {int size = 6}) {
    if (catalog.isEmpty || size <= 0) return const [];
    var seed = (rotationWindowOf(now) + 1) * 0x9E3779B9 ^ 0x85EBCA6B;
    int nextRand(int n) {
      seed = (seed * 1103515245 + 12345) & 0x7FFFFFFF;
      return seed % n;
    }

    final pool = List<ShopItem>.of(catalog);
    final take = size < pool.length ? size : pool.length;
    // Partial Fisher–Yates with the deterministic PRNG.
    for (var i = 0; i < take; i++) {
      final j = i + nextRand(pool.length - i);
      final tmp = pool[i];
      pool[i] = pool[j];
      pool[j] = tmp;
    }
    final picks = pool.sublist(0, take);
    final hasHigh = picks.any(
      (p) =>
          p.rarity == EquipmentRarity.EQUIPMENT_RARITY_EPIC || p.rarity == EquipmentRarity.EQUIPMENT_RARITY_LEGENDARY,
    );
    if (!hasHigh) {
      final highs = catalog
          .where(
            (p) =>
                p.rarity == EquipmentRarity.EQUIPMENT_RARITY_EPIC ||
                p.rarity == EquipmentRarity.EQUIPMENT_RARITY_LEGENDARY,
          )
          .where((p) => !picks.contains(p))
          .toList();
      if (highs.isNotEmpty) {
        final last = picks.length - 1;
        picks[last] = highs[nextRand(highs.length)];
      }
    }
    return picks;
  }

  /// Parses the YAML config into [achievementDefs] and [shopItems].
  static Future<void> load() async {
    try {
      final raw = await rootBundle.loadString('assets/config/config.yml');
      final doc = loadYaml(raw) as Map;

      _skinIds.clear();
      _categories.clear();
      _bonus.clear();
      _icons.clear();
      _gemItemIds.clear();
      for (final entry in (doc['skins'] as List? ?? const [])) {
        final m = (entry as Map).cast<String, dynamic>();
        final id = m['id'] as String?;
        if (id != null && id.isNotEmpty) {
          _skinIds.add(id);
          _categories[id] = 'appearance';
        }
      }
      for (final entry in (doc['equipment'] as List? ?? const [])) {
        final m = (entry as Map).cast<String, dynamic>();
        final id = m['id'] as String?;
        if (id != null && id.isNotEmpty) {
          _categories[id] = 'equipment';
          final stats = _statsFrom(m['stats']);
          if (stats != null) _bonus[id] = stats;
          final icon = m['icon'] as String?;
          if (icon != null && icon.isNotEmpty) _icons[id] = icon;
          if (m['currency'] == 'gems') _gemItemIds.add(id);
        }
      }
      for (final entry in (doc['appearance'] as List? ?? const [])) {
        final m = (entry as Map).cast<String, dynamic>();
        final id = m['id'] as String?;
        if (id != null && id.isNotEmpty) _categories[id] = 'appearance';
      }

      final defs = <Achievement>[];
      for (final entry in (doc['achievement_defs'] as List? ?? const [])) {
        final m = (entry as Map).cast<String, dynamic>();
        defs.add(
          Achievement(
            id: m['id'] as String? ?? '',
            title: m['title'] as String? ?? '',
            description: m['description'] as String? ?? '',
            conditionType: m['condition_type'] as String? ?? '',
            threshold: m['threshold'] as int? ?? 0,
            gemReward: m['gem_reward'] as int? ?? 0,
          ),
        );
      }
      if (defs.isNotEmpty) achievementDefs = defs;

      final items = <ShopItem>[
        ..._parseItems(doc['equipment']),
        ..._parseItems(doc['appearance']),
        ..._parseItems(doc['skins']),
      ];
      if (items.isNotEmpty) shopItems = items;

      Log.d('ShopConfig loaded: ${achievementDefs.length} achievements, ${shopItems.length} items');
    } catch (e) {
      Log.w('ShopConfig load failed, keeping built-in defaults: $e');
    }
  }

  static List<ShopItem> _parseItems(dynamic section) {
    final items = <ShopItem>[];
    for (final entry in (section as List? ?? const [])) {
      final m = (entry as Map).cast<String, dynamic>();
      items.add(
        ShopItem(
          id: m['id'] as String? ?? '',
          name: m['name'] as String? ?? '',
          description: m['description'] as String? ?? '',
          price: Int64(m['price'] as int? ?? 0),
          slot: _slotFor(m['slot'] as String?),
          rarity: _rarityFor(m['rarity'] as String?),
        ),
      );
    }
    return items;
  }

  /// Parses an optional `stats` map (keys: str/int/agi/def/vit/luk) into a
  /// [CharacterStats]; returns null when the item has no stats block.
  static CharacterStats? _statsFrom(dynamic raw) {
    if (raw is! Map) return null;
    final m = raw.cast<String, dynamic>();
    int stat(String k) => m[k] as int? ?? 0;
    return CharacterStats(
      strength: stat('str'),
      intelligence: stat('int'),
      agility: stat('agi'),
      defense: stat('def'),
      vitality: stat('vit'),
      luck: stat('luk'),
    );
  }

  static EquipmentSlot _slotFor(String? slot) => switch (slot) {
        'weapon' => EquipmentSlot.EQUIPMENT_SLOT_WEAPON,
        'helmet' => EquipmentSlot.EQUIPMENT_SLOT_HELMET,
        'armor' => EquipmentSlot.EQUIPMENT_SLOT_ARMOR,
        'accessory' => EquipmentSlot.EQUIPMENT_SLOT_ACCESSORY,
        _ => EquipmentSlot.EQUIPMENT_SLOT_UNSPECIFIED,
      };

  static EquipmentRarity _rarityFor(String? rarity) => switch (rarity) {
        'common' => EquipmentRarity.EQUIPMENT_RARITY_COMMON,
        'rare' => EquipmentRarity.EQUIPMENT_RARITY_RARE,
        'epic' => EquipmentRarity.EQUIPMENT_RARITY_EPIC,
        'legendary' => EquipmentRarity.EQUIPMENT_RARITY_LEGENDARY,
        _ => EquipmentRarity.EQUIPMENT_RARITY_COMMON,
      };

  static List<Achievement> _defaultAchievements() {
    return [
      Achievement(
        id: 'first_task',
        title: 'First Blood',
        description: 'Complete your first task',
        conditionType: 'total_tasks',
        threshold: 1,
        gemReward: 5,
      ),
      Achievement(
        id: 'streak_7',
        title: 'Hot Streak',
        description: '7-day streak',
        conditionType: 'streak',
        threshold: 7,
        gemReward: 5,
      ),
      Achievement(
        id: 'streak_30',
        title: 'Unstoppable',
        description: '30-day streak',
        conditionType: 'streak',
        threshold: 30,
        gemReward: 10,
      ),
      Achievement(
        id: 'level_5',
        title: 'Growing Strong',
        description: 'Reach level 5',
        conditionType: 'level',
        threshold: 5,
        gemReward: 5,
      ),
      Achievement(
        id: 'level_10',
        title: 'Double Digits',
        description: 'Reach level 10',
        conditionType: 'level',
        threshold: 10,
        gemReward: 10,
      ),
      Achievement(
        id: 'tasks_50',
        title: 'Getting Things Done',
        description: 'Complete 50 tasks',
        conditionType: 'total_tasks',
        threshold: 50,
        gemReward: 5,
      ),
      Achievement(
        id: 'tasks_100',
        title: 'Task Master',
        description: 'Complete 100 tasks',
        conditionType: 'total_tasks',
        threshold: 100,
        gemReward: 10,
      ),
      Achievement(
        id: 'first_purchase',
        title: 'Shopaholic',
        description: 'Buy first shop item',
        conditionType: 'purchases',
        threshold: 1,
        gemReward: 5,
      ),
      Achievement(
        id: 'death_1',
        title: 'Back from the Dead',
        description: 'Die and recover',
        conditionType: 'deaths',
        threshold: 1,
        gemReward: 5,
      ),
    ];
  }

  static List<ShopItem> _defaultShopItems() {
    return [
      ShopItem(
        id: 'sword_flame',
        name: 'Flame Sword',
        description: 'A sword wreathed in eternal flame',
        price: Int64(500),
        slot: EquipmentSlot.EQUIPMENT_SLOT_WEAPON,
        rarity: EquipmentRarity.EQUIPMENT_RARITY_EPIC,
      ),
      ShopItem(
        id: 'armor_golden',
        name: 'Golden Armor',
        description: 'Shining golden plate armor',
        price: Int64(300),
        slot: EquipmentSlot.EQUIPMENT_SLOT_ARMOR,
        rarity: EquipmentRarity.EQUIPMENT_RARITY_RARE,
      ),
      ShopItem(
        id: 'helm_dragon',
        name: 'Dragon Helm',
        description: 'Helm forged from dragon scales',
        price: Int64(250),
        slot: EquipmentSlot.EQUIPMENT_SLOT_HELMET,
        rarity: EquipmentRarity.EQUIPMENT_RARITY_RARE,
      ),
      ShopItem(
        id: 'staff_arcane',
        name: 'Arcane Staff',
        description: 'A staff crackling with arcane energy',
        price: Int64(350),
        slot: EquipmentSlot.EQUIPMENT_SLOT_WEAPON,
        rarity: EquipmentRarity.EQUIPMENT_RARITY_EPIC,
      ),
    ];
  }
}
