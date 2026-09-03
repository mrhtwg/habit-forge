import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/grpc/character_api.dart';
import 'package:habit_forge_app/core/network/grpc/shop_api.dart';
import 'package:habit_forge_app/core/network/grpc/task_api.dart';
import 'package:habit_forge_app/core/network/network_interface.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';
import 'package:habit_forge_app/generated/protos/auth/v1/auth.pb.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';

/// gRPC-backed storage (server mode). Talks to the self-hosted Go backend,
/// which owns all game logic (rewards, level-ups, purchases, penalties).
///
/// The grpc API stubs are still being filled in (see `core/network/grpc/`);
/// unimplemented methods throw until then.
class NetworkServerImpl implements NetworkInterface {
  // ── Auth ──

  @override
  Future<ApiResponse<LoginReply>> login(String provider) {
    // TODO: Google OAuth — exchange the Google credential for a JWT via the
    // backend's OAuthLogin RPC. Not implemented yet.
    throw UnimplementedError();
  }

  // ── Character ──

  @override
  Future<ApiResponse<CreateCharacterReply>> createCharacter(CharacterClass characterClass) async =>
      await CharacterApi().createCharacter(characterClass);

  @override
  Future<ApiResponse<GetCharacterReply>> getCharacter() async => await CharacterApi().getCharacter();

  @override
  Future<bool> allocateStatPoint(StatType stat) {
    // TODO: implement allocateStatPoint (gRPC)
    throw UnimplementedError();
  }

  @override
  Future<void> reviveCharacter() {
    // TODO: implement reviveCharacter (gRPC)
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<EquipItemReply>> equipItem(String itemId, EquipmentSlot slot) async =>
      await CharacterApi().equipItem(itemId, slot);

  // ── Tasks ──

  @override
  Future<ApiResponse<CreateTaskReply>> createTask(Task task) async => await TaskApi().createTask(task);

  @override
  Future<ApiResponse<UpdateTaskReply>> updateTask(String id, Task task) {
    // TODO: implement updateTask (gRPC)
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<DeleteTaskReply>> deleteTask(String id) {
    // TODO: implement deleteTask (gRPC)
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<ListTasksReply>> listTasks({
    TaskType? type,
    TaskDifficulty? difficulty,
    List<String>? tags,
    bool? onlyDueToday,
  }) {
    // TODO: implement listTasks (gRPC)
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<CompleteTaskReply>> completeTask(String id) {
    // TODO: implement completeTask (gRPC)
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<SkipTaskReply>> skipTask(String id) async => await TaskApi().skipTask(id);

  // ── User profile ──

  @override
  Future<ApiResponse<GetPrefsReply>> getPrefs() {
    // TODO: implement getPrefs (gRPC)
    throw UnimplementedError();
  }

  // ── Shop ──

  @override
  Future<ApiResponse<ListShopItemsReply>> listShopItems() {
    // TODO: implement listShopItems (gRPC)
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<ListOwnedItemsReply>> listOwnedItems() {
    // TODO: implement listOwnedItems (gRPC)
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<BuyItemReply>> purchaseItem(String itemId, ShopCurrency currency) async =>
      await ShopApi().buyItem(itemId, currency);

  @override
  Future<ApiResponse<DailyDeal>> getDailyDeal() {
    // TODO: implement getDailyDeal (gRPC)
    throw UnimplementedError();
  }

  // ── Achievements ──

  @override
  Future<ApiResponse<ListAchievementsReply>> listAchievements() {
    // TODO: implement listAchievements (gRPC)
    throw UnimplementedError();
  }

  // ── Lifecycle ──

  @override
  Future<NetworkInterface> init() {
    // Session token persistence is handled by UserService.setSessionToken.
    return Future.value(this);
  }
}
