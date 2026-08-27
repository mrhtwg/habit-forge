import 'package:get/get.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';

/// Reward summary returned by [StorageService.completeTask].
class TaskCompleteResult {
  const TaskCompleteResult({required this.expGained, required this.goldGained, this.newLevel});

  final int expGained;
  final int goldGained;

  /// Set when the character leveled up (for the celebration UI).
  final int? newLevel;
}

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
///     await StorageService.to.completeTask(task);
///     await StorageService.to.allocateStatPoint(StatType.STAT_TYPE_STRENGTH);
abstract class StorageService {
  /// Resolves the active implementation registered in Get.
  static StorageService get to => Get.find<StorageService>();

  // ── Auth state ──
  bool get isLoggedIn;
  String get authMethod;
  String? get authToken;
  void saveAuthToken(String? token);
  void setLoggedIn(bool value, {String method = ''});

  // ── Reactive state ──
  Rxn<UserPrefs> get userPrefs;
  Rxn<Character> get character;
  RxList<Task> get tasks;
  RxList<String> get ownedItemIds;
  RxList<Achievement> get achievements;
  Rxn<DailyDeal> get dailyDeal;

  // ── Lifecycle ──
  Future<StorageService> init();
  Future<void> refreshAll();

  /// Wipes all user data (used by "Reset All Data").
  Future<void> resetAllData();

  // ── Task operations ──
  String createTask(Task task);
  void updateTask(Task task);
  void deleteTask(String id);
  void skipTask(Task task);
  void postponeTask(Task task);

  /// Marks the task complete and grants EXP/gold rewards (streak-aware),
  /// updating the wallet and leveling up the character when applicable.
  /// Returns the reward summary for UI feedback.
  Future<TaskCompleteResult> completeTask(Task task);

  // ── Character operations ──
  /// Creates/replaces the initial character (onboarding).
  Future<void> createCharacter(Character c);
  /// Spends one available stat point; returns false when none are left.
  Future<bool> allocateStatPoint(StatType stat);
  Future<void> takeDamage(int amount);
  Future<void> reviveCharacter();
  /// Equips [itemId] into [slot] (empty itemId unequips).
  void equipItem(String itemId, {String slot = 'weapon'});

  // ── Economy ──
  /// Purchases an item with the given currency; returns whether it succeeded.
  Future<bool> purchaseItem(String itemId, int price, {ShopCurrency currency = ShopCurrency.SHOP_CURRENCY_GOLD});
  Future<void> addGold(int amount);
  Future<void> addGems(int amount);

  // ── Achievements ──
  /// Unlocks an achievement and grants its gem reward.
  Future<bool> unlockAchievement(Achievement def);

  // ── User prefs (settings etc.) ──
  void saveUserPrefs(UserPrefs prefs);
  void saveDailyDeal(DailyDeal deal);
}
