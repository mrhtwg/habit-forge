import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';

abstract class NetworkInterface {
  // ── Character ──
  Future<ApiResponse<CreateCharacterReply>> createCharacter(CharacterClass characterClass);
  Future<ApiResponse<GetCharacterReply>> getCharacter();
  Future<ApiResponse<EquipItemReply>> equipItem(String itemId, EquipmentSlot slot);

  // ── Tasks ──
  Future<ApiResponse<CreateTaskReply>> createTask(Task task);
  Future<ApiResponse<DeleteTaskReply>> deleteTask(String id);
  Future<ApiResponse<CompleteTaskReply>> completeTask(String id);
  Future<ApiResponse<SkipTaskReply>> skipTask(String id);
  Future<ApiResponse<UpdateTaskReply>> updateTask(String id, Task task);
  Future<ApiResponse<ListTasksReply>> listTasks({
    TaskType? type,
    TaskDifficulty? difficulty,
    List<String>? tags,
    bool? onlyDueToday,
  });

  /// Skips the task and (for todos) pushes the due date to tomorrow.
  Future<void> postponeTask(String id);

  /// Spends one available stat point; returns false when none are left.
  Future<bool> allocateStatPoint(StatType stat);

  // ── Shop ──
  Future<ApiResponse<BuyItemReply>> purchaseItem(String itemId, ShopCurrency currency);

  // ── Lifecycle ──

  Future<NetworkInterface> init();

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

  // ── Shop ──

  /// Applies damage; the character dies at 0 HP and schedules recovery.
  Future<void> takeDamage(int amount);
}
