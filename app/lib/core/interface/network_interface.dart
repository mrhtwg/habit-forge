import 'package:get/get.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';

/// Domain-operation abstraction shared by all modes.
///
/// Unlike a plain data store, this interface expresses **intent** — completing
/// a task, spending a stat point, taking damage — and each implementation owns
/// the game logic for its backend:
///
///  - [HiveService]      — computes locally ([GameLogic]) and persists to Hive
///  - FirebaseStorage    — computes locally and persists to Firestore
///  - ServerStorage      — delegates to the Go backend over gRPC
///
/// Business code depends on this interface only (never a concrete class):
///
///     await NetworkRegistry.ins.completeTask(task);
///     await NetworkRegistry.ins.allocateStatPoint(StatType.STAT_TYPE_STRENGTH);
abstract class NetworkInterface {
  /// Resolves the active implementation registered in Get.
  static NetworkInterface get to => Get.find<NetworkInterface>();

  RxList<Achievement> get achievements;
  String get authMethod;
  String? get authToken;
  Rxn<Character> get character;
  Rxn<DailyDeal> get dailyDeal;

  // ── Auth state ──

  RxList<String> get ownedItemIds;
  RxList<Task> get tasks;
  // ── Reactive state ──
  Rxn<UserPrefs> get userPrefs;
  Future<void> addGems(int amount);
  Future<void> addGold(int amount);

  /// Spends one available stat point; returns false when none are left.
  Future<bool> allocateStatPoint(StatType stat);

  /// Marks the task complete and grants EXP/gold rewards (streak-aware),
  /// updating the wallet and leveling up the character when applicable.
  /// Returns the reward summary for UI feedback.
  Future<TaskCompleteResult> completeTask(Task task);

  /// Creates/replaces the initial character (onboarding).
  Future<(Character, bool)> createCharacter(CharacterClass characterClass);
  // ── Task operations ──
  String createTask(Task task);
  void deleteTask(String id);

  /// Equips [itemId] into [slot] (empty itemId unequips).
  void equipItem(String itemId, {String slot = 'weapon'});

  // ── Lifecycle ──
  Future<NetworkInterface> init();
  Future<Character?> loadCharacter();
  void postponeTask(Task task);

  /// Purchases an item with the given currency; returns whether it succeeded.
  Future<bool> purchaseItem(String itemId, int price, {ShopCurrency currency = ShopCurrency.SHOP_CURRENCY_GOLD});

  // ── Character operations ──
  Future<void> refreshAll();

  /// Wipes all user data (used by "Reset All Data").
  Future<void> resetAllData();
  Future<void> reviveCharacter();
  void saveAuthToken(String? token);
  void saveDailyDeal(DailyDeal deal);

  // ── Economy ──
  // ── User prefs (settings etc.) ──
  void saveUserPrefs(UserPrefs prefs);
  void setLoggedIn(bool value, {String method = ''});
  void skipTask(Task task);

  // ── Achievements ──
  Future<void> takeDamage(int amount);

  /// Unlocks an achievement and grants its gem reward.
  Future<bool> unlockAchievement(Achievement def);
  void updateTask(Task task);
}

/// Reward summary returned by [NetworkInterface.completeTask].
class TaskCompleteResult {
  final int expGained;

  final int goldGained;

  /// Set when the character leveled up (for the celebration UI).
  final int? newLevel;

  const TaskCompleteResult({required this.expGained, required this.goldGained, this.newLevel});
}
