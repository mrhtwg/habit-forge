import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/grpc/character_api.dart';
import 'package:habit_forge_app/core/network/grpc/shop_api.dart';
import 'package:habit_forge_app/core/network/grpc/task_api.dart';
import 'package:habit_forge_app/core/network/network_interface.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pbgrpc.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pbgrpc.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pbgrpc.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';

class NetworkServerImpl implements NetworkInterface {
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
  Future<ApiResponse<CreateCharacterReply>> createCharacter(CharacterClass characterClass) async {
    return await CharacterApi().createCharacter(characterClass);
  }

  // ── Task operations ──

  @override
  Future<ApiResponse<CreateTaskReply>> createTask(Task task) async {
    return TaskApi().createTask(task);
  }

  @override
  Future<ApiResponse<DeleteTaskReply>> deleteTask(String id) async {
    return await NetworkRegistry.ins.deleteTask(id);
  }

  @override
  Future<ApiResponse<EquipItemReply>> equipItem(String itemId, EquipmentSlot slot) {
    return NetworkRegistry.ins.equipItem(itemId, slot);
  }

  Future<ApiResponse<GetCharacterReply>> getCharacter() async => await CharacterApi().getCharacter();

  @override
  Future<NetworkInterface> init() async {
    // final (host, port) = _parseEndpoint(EnvConstants.grpcUrl);
    // final _channel = ClientChannel(
    //   host,
    //   port: port,
    //   options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    // );

    return this;
  }

  @override
  Future<ApiResponse<ListTasksReply>> listTasks({
    TaskType? type,
    TaskDifficulty? difficulty,
    List<String>? tags,
    bool? onlyDueToday,
  }) {
    // TODO: implement getTodayTasks
    throw UnimplementedError();
  }

  @override
  Future<void> postponeTask(String id) {
    // TODO: implement postponeTask
    throw UnimplementedError();
  }

  // ── Economy ──

  @override
  Future<ApiResponse<BuyItemReply>> purchaseItem(String itemId, ShopCurrency currency) async =>
      await ShopApi().buyItem(itemId, currency);

  @override
  Future<ApiResponse<DailyDeal>> refreshDailyDeal() {
    // TODO: implement refreshDailyDeal
    throw UnimplementedError();
  }

  @override
  Future<void> resetAllData() async {}

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
  Future<ApiResponse<SkipTaskReply>> skipTask(String id) async => await TaskApi().skipTask(id);

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
