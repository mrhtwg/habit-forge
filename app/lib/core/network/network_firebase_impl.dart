import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/network_interface.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';

class NetworkFirebaseImpl implements NetworkInterface {
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
    // final char = character.value;
    // if (char != null) saveCharacter(GameLogic.equip(char, slot, itemId));
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
    // TODO: implement getAllTasks
    throw UnimplementedError();
  }

  @override
  Future<void> postponeTask(String id) {
    // TODO: implement postponeTask
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<BuyItemReply>> purchaseItem(String itemId, ShopCurrency currency) {
    // TODO: implement purchaseItem
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<DailyDeal>> refreshDailyDeal() {
    // TODO: implement refreshDailyDeal
    throw UnimplementedError();
  }

  @override
  Future<void> resetAllData() {
    // TODO: implement resetAllData
    throw UnimplementedError();
  }

  @override
  Future<void> reviveCharacter() {
    // TODO: implement reviveCharacter
    throw UnimplementedError();
  }

  @override
  void saveAuthToken(String? token) {
    // TODO: implement saveAuthToken
  }

  @override
  void setLoggedIn(bool value, {String method = ''}) {
    // TODO: implement setLoggedIn
  }

  @override
  Future<ApiResponse<SkipTaskReply>> skipTask(String id) {
    // TODO: implement skipTask
    throw UnimplementedError();
  }

  @override
  Future<void> takeDamage(int amount) {
    // TODO: implement takeDamage
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
}
