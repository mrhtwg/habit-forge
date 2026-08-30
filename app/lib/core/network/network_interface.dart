import 'package:fixnum/fixnum.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';

/// The only fields the caller may supply when creating/editing a task.
/// Everything else (id, timestamps, streak, completion state) is owned by the
/// implementation.
class CreateTaskParams {
  final String title;
  final String? description;
  final TaskType type;
  final TaskDifficulty difficulty;
  final List<String> tags;
  final Int64? dueDate;
  final List<int> repeatDays;
  final String priority;
  final int hpPenalty;

  const CreateTaskParams({
    required this.title,
    this.description,
    this.type = TaskType.TASK_TYPE_HABIT,
    this.difficulty = TaskDifficulty.TASK_DIFFICULTY_MEDIUM,
    this.tags = const [],
    this.dueDate,
    this.repeatDays = const [],
    this.priority = '',
    this.hpPenalty = 10,
  });

  /// Applies the editable fields onto a base task (used when editing).
  Task applyTo(Task task) {
    final now = Int64(DateTime.now().millisecondsSinceEpoch);
    return task.rebuild((t) {
      t.title = title;
      t.description = description ?? '';
      t.type = type;
      t.difficulty = difficulty;
      t.tags.clear();
      t.tags.addAll(tags);
      t.dueDate = dueDate ?? Int64.ZERO;
      t.repeatDays.clear();
      t.repeatDays.addAll(repeatDays);
      t.priority = priority;
      t.hpPenalty = hpPenalty;
      t.updatedAt = now;
    });
  }
}

/// Domain-operation abstraction shared by all modes (hive / firebase / server).
///
/// This interface expresses **intent**, not data writes. Each behavior method
/// takes only the few key fields the caller knows (a title, a task id, a stat
/// name...) and returns an [ApiResponse]; the implementation owns everything
/// else — ids, timestamps, rewards, level-ups, wallet mutations and achievement
/// unlocks. The UI can never inject raw data (no "give me gold" or "store this
/// Task object"): gold only appears as the result of completing a task or
/// buying something.
///
///     final reply = await NetworkRegistry.ins.completeTask(taskId);
///     final created = await NetworkRegistry.ins.createTask(
///       CreateTaskParams(title: 'Read 20 pages', type: TaskType.TASK_TYPE_HABIT, difficulty: ...),
///     );
abstract class NetworkInterface {
  /// Achievement definitions served by the backend (display catalog).
  List<Achievement> get achievementDefs;
  // ── Reactive state (read-only views for the UI) ──

  RxList<Achievement> get achievements;
  String get authMethod;
  String? get authToken;
  Rxn<Character> get character;
  Rxn<DailyDeal> get dailyDeal;
  RxList<String> get ownedItemIds;

  /// Shop catalog served by the backend (display catalog + prices).
  List<ShopItem> get shopItems;

  RxList<Task> get tasks;

  Rxn<UserPrefs> get userPrefs;

  /// Spends one available stat point; returns false when none are left.
  Future<bool> allocateStatPoint(StatType stat);

  /// Marks the task complete and grants EXP/gold rewards (streak-aware),
  /// updating the wallet, leveling up the character and checking achievements.
  /// Returns the reward summary for UI feedback.
  Future<TaskCompleteResult> completeTask(String id);

  /// Creates/replaces the initial character (onboarding).
  Future<ApiResponse<GetCharacterReply>> createCharacter(CharacterClass characterClass);

  /// Creates a task from the caller-supplied fields; the implementation
  /// assigns the id, timestamps and any derived state.
  Future<ApiResponse<Task>> createTask(CreateTaskParams params);
  Future<void> deleteTask(String id);

  // ── Character ──

  /// Equips [itemId] into [slot] (empty itemId unequips).
  void equipItem(String itemId, {String slot = 'weapon'});

  Future<ApiResponse<GetCharacterReply>> getCharacter();

  // ── Lifecycle ──

  Future<NetworkInterface> init();

  /// Skips the task and (for todos) pushes the due date to tomorrow.
  Future<void> postponeTask(String id);

  /// Purchases the item with the catalog price in the given currency; the
  /// implementation validates the balance, charges the wallet, marks the item
  /// as owned and checks the first-purchase achievement.
  Future<ApiResponse<BuyItemReply>> purchaseItem(
    String itemId, {
    ShopCurrency currency = ShopCurrency.SHOP_CURRENCY_GOLD,
  });

  Future<void> refreshAll();

  // ── Tasks ──

  /// Returns the current daily deal, generating a fresh one when the previous
  /// has expired.
  Future<DailyDeal> refreshDailyDeal();

  /// Wipes all user data (used by "Reset All Data").
  Future<void> resetAllData();

  /// Revives a dead character and may unlock the death-recovery achievement.
  Future<void> reviveCharacter();

  // ── Auth ──

  void saveAuthToken(String? token);

  void setLoggedIn(bool value, {String method = ''});

  /// Toggles the skipped flag.
  Future<void> skipTask(String id);

  // ── Shop ──

  /// Applies damage; the character dies at 0 HP and schedules recovery.
  Future<void> takeDamage(int amount);

  /// Updates the editable fields of an existing task (full replace of the
  /// editable fields; timestamps are maintained by the implementation).
  Future<ApiResponse<Task>> updateTask(String id, CreateTaskParams params);
}

/// Reward summary returned by [NetworkInterface.completeTask].
class TaskCompleteResult {
  final int expGained;

  final int goldGained;

  /// Set when the character leveled up (for the celebration UI).
  final int? newLevel;

  const TaskCompleteResult({required this.expGained, required this.goldGained, this.newLevel});
}
