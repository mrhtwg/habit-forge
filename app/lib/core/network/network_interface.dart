import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';
import 'package:habit_forge_app/generated/protos/auth/v1/auth.pb.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';

/// Network facade: a 1:1 mapping to backend business RPCs (see `proto/`).
///
/// Design rules:
///  - Methods express **behavior**, never raw data writes. There is no
///    "give gold", "add EXP" or "apply damage" endpoint — gold/EXP/HP only
///    change as side effects of business calls the backend implements
///    (completeTask settles rewards, missed-task settlement applies HP loss,
///    the server owns level-ups and achievement unlocks).
///  - Numbers are computed by the backend inside those behaviors; clients
///    pass ids / choices, not computed values.
///  - Client-side concerns (session token persistence, wiping local data)
///    live outside this interface: the auth flow goes through [login] and
///    DataResetService handles local resets.
abstract class NetworkInterface {
  // ── Auth ──

  /// Signs the user in with [provider] ('guest' | 'google' | ...).
  ///
  ///  - hive: mints a local session token immediately (guest auto-login);
  ///  - server: will exchange a Google credential via OAuthLogin
  ///    (**not implemented yet**);
  ///  - firebase: auth is owned by FirebaseAuthService, so this is unused.
  Future<ApiResponse<LoginReply>> login(String provider);

  // ── Character ──

  /// Creates the initial character (onboarding).
  Future<ApiResponse<CreateCharacterReply>> createCharacter(CharacterClass characterClass);

  Future<ApiResponse<GetCharacterReply>> getCharacter();

  /// Spends one available stat point.
  Future<bool> allocateStatPoint(StatType stat);

  /// Revives a dead character once the recovery time has elapsed.
  Future<void> reviveCharacter();

  /// Equips [itemId] into [slot].
  Future<ApiResponse<EquipItemReply>> equipItem(String itemId, EquipmentSlot slot);

  // ── Tasks ──

  Future<ApiResponse<CreateTaskReply>> createTask(Task task);
  Future<ApiResponse<UpdateTaskReply>> updateTask(String id, Task task);
  Future<ApiResponse<DeleteTaskReply>> deleteTask(String id);
  Future<ApiResponse<ListTasksReply>> listTasks({
    TaskType? type,
    TaskDifficulty? difficulty,
    List<String>? tags,
    bool? onlyDueToday,
  });

  /// Marks the task complete; the backend settles EXP/gold rewards,
  /// level-ups and achievements, and returns the updated state.
  Future<ApiResponse<CompleteTaskReply>> completeTask(String id);

  /// Skips the task and (for todos) pushes the due date to tomorrow.
  Future<ApiResponse<SkipTaskReply>> skipTask(String id);

  // ── User profile ──

  Future<ApiResponse<GetPrefsReply>> getPrefs();

  // ── Shop ──

  Future<ApiResponse<ListShopItemsReply>> listShopItems();
  Future<ApiResponse<ListOwnedItemsReply>> listOwnedItems();
  Future<ApiResponse<BuyItemReply>> purchaseItem(String itemId, ShopCurrency currency);
  Future<ApiResponse<DailyDeal>> getDailyDeal();

  // ── Achievements ──

  Future<ApiResponse<ListAchievementsReply>> listAchievements();

  // ── Lifecycle ──

  /// Initializes the transport/session for the active backend.
  Future<NetworkInterface> init();
}
