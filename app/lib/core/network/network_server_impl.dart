import 'package:grpc/grpc.dart';
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

class NetworkServerImpl implements NetworkInterface {
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

  // ── Economy ──

  @override
  Future<ApiResponse<BuyItemReply>> purchaseItem(String itemId, ShopCurrency currency) async =>
      await ShopApi().buyItem(itemId, currency);

  @override
  Future<void> resetAllData() async {}

  @override
  Future<ApiResponse<SkipTaskReply>> skipTask(String id) async => await TaskApi().skipTask(id);

  /// Parses "host:port" (or "http://host:port") into a (host, port) record.
  (String, int) _parseEndpoint(String url) {
    final cleaned = url.replaceAll(RegExp(r'^https?://'), '');
    final parts = cleaned.split(':');
    final host = parts.first;
    final port = parts.length > 1 ? int.tryParse(parts[1]) ?? 9000 : 9000;
    return (host, port);
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
  Future<ApiResponse<ListTasksReply>> getTodayTasks() {
    // TODO: implement getTodayTasks
    throw UnimplementedError();
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

  @override
  Future<DailyDeal> refreshDailyDeal() {
    // TODO: implement refreshDailyDeal
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
  Future<void> takeDamage(int amount) {
    // TODO: implement takeDamage
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<UpdateTaskReply>> updateTask(String id, Task task) {
    // TODO: implement updateTask
    throw UnimplementedError();
  }
}

/// Attaches the current JWT to every outgoing gRPC call.
class _AuthInterceptor extends ClientInterceptor {
  final String? Function() _token;

  _AuthInterceptor(this._token);

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    final token = _token();
    final opts = (token == null || token.isEmpty)
        ? options
        : options.mergedWith(CallOptions(metadata: {'authorization': 'Bearer $token'}));
    return invoker(method, request, opts);
  }
}
