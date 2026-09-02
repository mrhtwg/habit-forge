import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:habit_forge_app/core/common/utils/sp_keys.dart';
import 'package:habit_forge_app/core/common/utils/sp_utils.dart';
import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/hive/character_box.dart';
import 'package:habit_forge_app/core/network/hive/game_constants.dart';
import 'package:habit_forge_app/core/network/hive/game_logic.dart';
import 'package:habit_forge_app/core/network/hive/shop_box.dart';
import 'package:habit_forge_app/core/network/hive/shop_config.dart';
import 'package:habit_forge_app/core/network/hive/task_box.dart';
import 'package:habit_forge_app/core/network/hive/user_box.dart';
import 'package:habit_forge_app/core/network/network_interface.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character_error.pbenum.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';
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

  // ── Character ──
  @override
  Future<ApiResponse<CreateCharacterReply>> createCharacter(CharacterClass characterClass) async {
    if (await CharacterBox.ins.getCharacter() != null) {
      return ApiResponse.failure(
        code: CharacterErrorReason.CHARACTER_ALREADY_EXISTS.value,
        message: 'Character already exists',
      );
    }

    Character character = Character()
      ..id = Uuid().v4()
      ..characterClass = characterClass
      ..level = 1
      ..currentExp = Int64(0)
      ..currentHp = GameConstants.initialHp
      ..maxExp = Int64(GameConstants.expForLevel(1))
      ..baseStats = CharacterStats()
      ..availableStatPoints = 0
      ..isDead = false;
    CharacterBox.ins.createCharacter(character);
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
  Future<ApiResponse<CompleteTaskReply>> completeTask(String id) async {
    final task = TaskBox.ins.getTask(id);
    if (task == null) {
      return ApiResponse.failure(code: TaskErrorReason.TASK_NOT_FOUND.value, message: 'Task not found');
    }
    if (task.isCompleted) {
      return ApiResponse.failure(code: TaskErrorReason.TASK_ALREADY_COMPLETED.value, message: 'Task already completed');
    }

    final character = CharacterBox.ins.getCharacter();
    if (character == null) {
      return ApiResponse.failure(code: CharacterErrorReason.CHARACTER_NOT_FOUND.value, message: 'Character not found');
    }

    // Rewards (streak-aware EXP + gold).
    final exp = GameLogic.expReward(task);
    final gold = GameLogic.goldReward(task);

    // Mark the task complete (streak / completedAt) and persist.
    final completed = await TaskBox.ins.completeTask(task);

    // Wallet + lifetime completed-task counter.
    final userPrefs = UserBox.ins.getUserPrefs();
    UserBox.ins.updateUserPrefs(GameLogic.addGold(GameLogic.addCompletedTask(userPrefs), gold));

    // Character: gain EXP and level up (stat points + HP heal on level-up).
    final (updated, level) = GameLogic.gainExp(character, exp);
    final frozen = updated.clone()..freeze();
    CharacterBox.ins.updateCharacter(
      frozen.rebuild(
        (c) => c
          ..level = level
          ..maxExp = Int64(GameConstants.expForLevel(level)),
      ),
    );
    final hpChange = level > 0 ? 20 : 0;

    return ApiResponse.success(
      CompleteTaskReply(
        task: completed,
        expReward: exp,
        goldReward: gold,
        hpChange: hpChange,
      ),
    );
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
    await UserBox.ins.init();
    await ShopBox.ins.init();

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
  Future<void> postponeTask(String id) async {
    // final task = _findTask(id);
    // if (task == null) return;
    // _tasksBox.put('task_$id', _json.encode(GameLogic.postpone(task).writeToJsonMap()));
    // _loadTasks();
  }

  @override
  Future<ApiResponse<BuyItemReply>> purchaseItem(String itemId, ShopCurrency currency) async {
    final item = ShopConfig.shopItems.where((i) => i.id == itemId).firstOrNull;
    if (item == null) {
      return ApiResponse.failure(code: StatusCode.notFound, message: 'Item not found');
    }
    final owned = UserBox.ins.getOwnedItemIds();
    if (owned.contains(itemId)) {
      return ApiResponse.failure(code: StatusCode.alreadyExists, message: 'Item already owned');
    }
    final userPrefs = UserBox.ins.getUserPrefs();
    if (userPrefs.currentGold < item.price) {
      return ApiResponse.failure(code: StatusCode.failedPrecondition, message: 'Not enough gold');
    }

    UserBox.ins.updateUserPrefs(GameLogic.addGold(userPrefs, -item.price.toInt()));
    UserBox.ins.updateOwnedItemIds([...owned, itemId]);
    return ApiResponse.success(
      BuyItemReply(item: item, balance: userPrefs.currentGold - item.price),
    );
  }

  @override
  Future<ApiResponse<DailyDeal>> refreshDailyDeal() async {
    return ApiResponse.success(
      DailyDeal(
        itemId: 'sword_flame',
        discountPercent: 30,
        expiresAt: Int64(DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch),
      ),
    );
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

  @override
  Future<ApiResponse<GetPrefsReply>> getPrefs() async {
    return ApiResponse.success(GetPrefsReply(prefs: UserBox.ins.getUserPrefs()));
  }

  @override
  Future<ApiResponse<ListShopItemsReply>> listShopItems() async {
    final items = await ShopBox.ins.listItems();
    return ApiResponse.success(ListShopItemsReply(items: items));
  }
}
