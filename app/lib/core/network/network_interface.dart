import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';

abstract class NetworkInterface {
  /// Spends one available stat point; returns false when none are left.
  Future<bool> allocateStatPoint(StatType stat);
  Future<ApiResponse<CompleteTaskReply>> completeTask(String id);
  // ── Character ──
  Future<ApiResponse<CreateCharacterReply>> createCharacter(CharacterClass characterClass);

  // ── Tasks ──
  Future<ApiResponse<CreateTaskReply>> createTask(Task task);
  Future<ApiResponse<DeleteTaskReply>> deleteTask(String id);
  Future<ApiResponse<EquipItemReply>> equipItem(String itemId, EquipmentSlot slot);
  Future<ApiResponse<GetCharacterReply>> getCharacter();
  Future<ApiResponse<ListTasksReply>> listTasks({
    TaskType? type,
    TaskDifficulty? difficulty,
    List<String>? tags,
    bool? onlyDueToday,
  });

  // ── User Profile ──
  Future<ApiResponse<GetPrefsReply>> getPrefs();

  // ── Lifecycle ──

  Future<NetworkInterface> init();

  /// Skips the task and (for todos) pushes the due date to tomorrow.
  Future<void> postponeTask(String id);

  // ── Shop ──
  Future<ApiResponse<BuyItemReply>> purchaseItem(String itemId, ShopCurrency currency);

  Future<ApiResponse<DailyDeal>> refreshDailyDeal();

  /// Wipes all user data (used by "Reset All Data").
  Future<void> resetAllData();

  /// Revives a dead character and may unlock the death-recovery achievement.
  Future<void> reviveCharacter();

  // ── Auth ──

  void saveAuthToken(String? token);

  void setLoggedIn(bool value, {String method = ''});

  Future<ApiResponse<SkipTaskReply>> skipTask(String id);

  /// Applies damage; the character dies at 0 HP and schedules recovery.
  Future<void> takeDamage(int amount);

  // ── Shop ──

  Future<ApiResponse<UpdateTaskReply>> updateTask(String id, Task task);
}
