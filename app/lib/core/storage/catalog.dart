import 'package:fixnum/fixnum.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';

/// Static game catalog served by the storage layer, mimicking a backend that
/// ships the achievement definitions and the shop catalog.
///
/// The UI never mutates these — purchases, unlocks and rewards are all driven
/// by the behavior methods on [NetworkInterface].
class GameCatalog {
  /// Achievement definitions (the "server-side" rule set).
  static final List<Achievement> achievementDefs = [
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

  /// The shop catalog (the "server-side" item list with prices).
  static final List<ShopItem> shopItems = [
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

  GameCatalog._();
}
