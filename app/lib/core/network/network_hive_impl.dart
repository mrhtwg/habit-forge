import 'package:grpc/grpc.dart';
import 'package:habit_forge_app/core/common/utils/sp_keys.dart';
import 'package:habit_forge_app/core/common/utils/sp_utils.dart';
import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/hive/character_box.dart';
import 'package:habit_forge_app/core/network/hive/task_box.dart';
import 'package:habit_forge_app/core/network/network_interface.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character_error.pbenum.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class NetworkHiveImpl implements NetworkInterface {
  @override
  Future<bool> allocateStatPoint(StatType stat) async {
    // final char = character.value;
    // if (char == null || char.availableStatPoints <= 0) return false;
    // saveCharacter(GameLogic.allocateStat(char, stat));
    return true;
  }

  @override
  Future<ApiResponse<CompleteTaskReply>> completeTask(String id) async {
    final task = TaskBox.ins.getTask(id);
    if (task == null) {
      return ApiResponse.failure(code: TaskErrorReason.TASK_NOT_FOUND.value, message: 'Task not found');
    }
    TaskBox.ins.completeTask(task);

    return ApiResponse.success(CompleteTaskReply());
  }

  // ── Character ──

  @override
  Future<ApiResponse<CreateCharacterReply>> createCharacter(CharacterClass characterClass) async {
    if (await CharacterBox.ins.getCharacter() != null) {
      return ApiResponse.failure(
        code: CharacterErrorReason.CHARACTER_ALREADY_EXISTS.value,
        message: 'Character already exists',
      );
    }
    final character = CharacterBox.ins.createCharacter(characterClass);
    return ApiResponse.success(CreateCharacterReply(character: character));
  }

  // ── Tasks ──

  @override
  Future<ApiResponse<CreateTaskReply>> createTask(Task task) async {
    if (task.title.trim().isEmpty ||
        task.type.value == TaskType.TASK_TYPE_UNSPECIFIED ||
        task.difficulty == TaskDifficulty.TASK_DIFFICULTY_UNSPECIFIED) {
      return ApiResponse.failure(
        code: StatusCode.invalidArgument,
        message: StatusCode.name(StatusCode.invalidArgument)!,
      );
    }
    final t = await TaskBox.ins.createTask(task);
    return ApiResponse.success(CreateTaskReply(task: t));
  }

  @override
  Future<ApiResponse<ListTasksReply>> listTasks({
    TaskType? type,
    TaskDifficulty? difficulty,
    List<String>? tags,
    bool? onlyDueToday,
  }) async {
    final _tasks = TaskBox.ins.listTasks(
      type: type,
      difficulty: difficulty,
      tags: tags,
      onlyDueToday: onlyDueToday,
    );
    return ApiResponse.success(ListTasksReply(tasks: _tasks));
  }

  @override
  Future<ApiResponse<DeleteTaskReply>> deleteTask(String id) async {
    // _tasksBox.delete('task_$id');
    TaskBox.ins.deleteTask(id);
    return ApiResponse.success(DeleteTaskReply());
  }

  @override
  Future<ApiResponse<EquipItemReply>> equipItem(String itemId, EquipmentSlot slot) {
    // final char = character.value;
    // if (char != null) saveCharacter(GameLogic.equip(char, slot, itemId));
    // TODO: implement equipItem
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<GetCharacterReply>> getCharacter() async {
    final char = await CharacterBox.ins.getCharacter();
    if (char == null) {
      return ApiResponse.fromGrpcError(
        CharacterErrorReason.CHARACTER_NOT_FOUND.value,
        'Character not found',
        errorReasonValue: null,
        reason: null,
      );
    }
    return ApiResponse.success(GetCharacterReply(character: char));
  }

  // ── Lifecycle ──

  @override
  Future<NetworkHiveImpl> init() async {
    await Hive.initFlutter();
    await CharacterBox.ins.init();
    await TaskBox.ins.init();
    // _userBox = await Hive.openBox('userBox');
    // _tasksBox = await Hive.openBox('tasksBox');
    // _shopBox = await Hive.openBox('shopBox');
    // _achievementBox = await Hive.openBox('achievementBox');

    if (!UserService.to.isLoggedIn()) {
      final token = Uuid().v4();
      await SpUtils.ins.putString(SpKeys.token, token);
      // Keep the in-memory token in sync: UserService.token was loaded in
      // main() before this init ran, so without this the splash login check
      // (which reads the in-memory value) would still see an empty token.
      UserService.to.token.value = token;
    }
    return this;
  }

  @override
  Future<void> postponeTask(String id) async {
    // final task = _findTask(id);
    // if (task == null) return;
    // _tasksBox.put('task_$id', _json.encode(GameLogic.postpone(task).writeToJsonMap()));
    // _loadTasks();
  }

  @override
  Future<ApiResponse<BuyItemReply>> purchaseItem(String itemId, ShopCurrency currency) {
    // TODO: implement purchaseItem
    throw UnimplementedError();
  }

  @override
  Future<DailyDeal> refreshDailyDeal() {
    // TODO: implement refreshDailyDeal
    throw UnimplementedError();
  }

  @override
  Future<void> resetAllData() async {
    CharacterBox.ins.clear();
    TaskBox.ins.clear();
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
}
