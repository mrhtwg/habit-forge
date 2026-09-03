import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/network_interface.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';
import 'package:habit_forge_app/generated/protos/auth/v1/auth.pb.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';

/// Firestore-backed storage (firebase mode).
///
/// NOTE: this mode is being phased out — the final app targets the Go backend
/// (server mode). The methods below are placeholders until Firebase support is
/// either finished or removed.
class NetworkFirebaseImpl implements NetworkInterface {
  @override
  Future<ApiResponse<LoginReply>> login(String provider) {
    // Auth is owned by FirebaseAuthService; this facade login is unused here.
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<bool> allocateStatPoint(StatType stat) {
    // TODO: implement allocateStatPoint
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<CompleteTaskReply>> completeTask(String id) {
    // TODO: implement completeTask
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<CreateCharacterReply>> createCharacter(CharacterClass characterClass) {
    // TODO: implement createCharacter
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<CreateTaskReply>> createTask(Task task) {
    // TODO: implement createTask
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<DeleteTaskReply>> deleteTask(String id) {
    // TODO: implement deleteTask
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<EquipItemReply>> equipItem(String itemId, EquipmentSlot slot) {
    // TODO: implement equipItem
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<GetCharacterReply>> getCharacter() {
    // TODO: implement getCharacter
    throw UnimplementedError();
  }

  @override
  Future<NetworkInterface> init() {
    // TODO: implement init
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<ListTasksReply>> listTasks({
    TaskType? type,
    TaskDifficulty? difficulty,
    List<String>? tags,
    bool? onlyDueToday,
  }) {
    // TODO: implement listTasks
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<BuyItemReply>> purchaseItem(String itemId, ShopCurrency currency) {
    // TODO: implement purchaseItem
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<DailyDeal>> getDailyDeal() {
    // TODO: implement getDailyDeal
    throw UnimplementedError();
  }

  @override
  Future<void> reviveCharacter() {
    // TODO: implement reviveCharacter
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<SkipTaskReply>> skipTask(String id) {
    // TODO: implement skipTask
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<UpdateTaskReply>> updateTask(String id, Task task) {
    // TODO: implement updateTask
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<GetPrefsReply>> getPrefs() {
    // TODO: implement getPrefs
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<ListShopItemsReply>> listShopItems() {
    // TODO: implement listShopItems
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<ListOwnedItemsReply>> listOwnedItems() {
    // TODO: implement listOwnedItems
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<ListAchievementsReply>> listAchievements() {
    // TODO: implement listAchievements
    throw UnimplementedError();
  }
}
