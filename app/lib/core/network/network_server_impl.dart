import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/grpc/achievement_api.dart';
import 'package:habit_forge_app/core/network/grpc/character_api.dart';
import 'package:habit_forge_app/core/network/grpc/shop_api.dart';
import 'package:habit_forge_app/core/network/grpc/task_api.dart';
import 'package:habit_forge_app/core/network/grpc/user_api.dart';
import 'package:habit_forge_app/core/network/network_interface.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';
import 'package:habit_forge_app/generated/protos/auth/v1/auth.pb.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';

/// gRPC-backed storage (server mode). Talks to the self-hosted Go backend,
/// which owns all game logic (rewards, level-ups, purchases, penalties).
class NetworkServerImpl implements NetworkInterface {
  final _character = CharacterApi();
  final _task = TaskApi();
  final _shop = ShopApi();
  final _user = UserApi();
  final _achievement = AchievementApi();

  // ── Auth ──

  @override
  Future<ApiResponse<LoginReply>> login(String provider) async {
    // Email sessions are established by ServerAuthService (HTTP). Google OAuth
    // via gRPC is not wired yet — keep the existing local JWT if present.
    final token = UserService.to.token.value;
    if (token.isEmpty) {
      return ApiResponse.failure(code: 16, message: 'Not signed in — use email login');
    }
    return ApiResponse.success(LoginReply(token: token), 'Signed in');
  }

  // ── Character ──

  @override
  Future<ApiResponse<CreateCharacterReply>> createCharacter(CharacterClass characterClass) async =>
      _character.createCharacter(characterClass);

  @override
  Future<ApiResponse<GetCharacterReply>> getCharacter() async => _character.getCharacter();

  @override
  Future<bool> allocateStatPoint(StatType stat) async {
    final reply = await _character.allocateStatPoint(stat);
    return reply.isSuccess;
  }

  @override
  Future<void> reviveCharacter() async {
    await _character.revive();
  }

  @override
  Future<ApiResponse<EquipItemReply>> equipItem(String itemId, EquipmentSlot slot) async =>
      _character.equipItem(itemId, slot);

  // ── Tasks ──

  @override
  Future<ApiResponse<CreateTaskReply>> createTask(Task task) async => _task.createTask(task);

  @override
  Future<ApiResponse<UpdateTaskReply>> updateTask(String id, Task task) async => _task.updateTask(id, task);

  @override
  Future<ApiResponse<DeleteTaskReply>> deleteTask(String id) async => _task.deleteTask(id);

  @override
  Future<ApiResponse<ListTasksReply>> listTasks({
    TaskType? type,
    TaskDifficulty? difficulty,
    List<String>? tags,
    bool? onlyDueToday,
  }) async =>
      _task.listTasks(type: type, difficulty: difficulty, tags: tags, onlyDueToday: onlyDueToday);

  @override
  Future<ApiResponse<CompleteTaskReply>> completeTask(String id) async => _task.completeTask(id);

  @override
  Future<ApiResponse<SkipTaskReply>> skipTask(String id) async => _task.skipTask(id);

  // ── User profile ──

  @override
  Future<ApiResponse<GetPrefsReply>> getPrefs() async => _user.getPrefs();

  // ── Shop ──

  @override
  Future<ApiResponse<ListShopItemsReply>> listShopItems() async => _shop.listShopItems();

  @override
  Future<ApiResponse<ListOwnedItemsReply>> listOwnedItems() async => _shop.listOwnedItems();

  @override
  Future<ApiResponse<BuyItemReply>> purchaseItem(String itemId, ShopCurrency currency) async =>
      _shop.buyItem(itemId, currency);

  @override
  Future<ApiResponse<DailyDeal>> getDailyDeal() async {
    final reply = await _shop.getDailyDeal();
    if (reply.isFailure || reply.data?.deal == null) {
      return ApiResponse.failure(code: reply.code, message: reply.message);
    }
    return ApiResponse.success(reply.data!.deal);
  }

  // ── Achievements ──

  @override
  Future<ApiResponse<ListAchievementsReply>> listAchievements() async => _achievement.listAchievements();

  // ── Lifecycle ──

  @override
  Future<NetworkInterface> init() async => this;
}
