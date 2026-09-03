import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
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
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';
import 'package:habit_forge_app/generated/protos/auth/v1/auth.pb.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class NetworkHiveImpl implements NetworkInterface {
  @override
  Future<bool> allocateStatPoint(StatType stat) async {
    final char = CharacterBox.ins.getCharacter();
    if (char == null || char.availableStatPoints <= 0) return false;
    CharacterBox.ins.updateCharacter(GameLogic.allocateStat(char, stat));
    return true;
  }

  // ── Character ──
  @override
  Future<ApiResponse<CreateCharacterReply>> createCharacter(CharacterClass characterClass) async {
    if (await CharacterBox.ins.getCharacter() != null) {
      return ApiResponse.failure(
        code: StatusCode.alreadyExists,
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
    final reason = _invalidTaskShape(task);
    if (reason != null) {
      return ApiResponse.failure(code: StatusCode.invalidArgument, message: reason);
    }
    final t = await TaskBox.ins.createTask(task);
    return ApiResponse.success(CreateTaskReply(task: t));
  }

  /// Task-shape rules shared by create/update (both ends must enforce them):
  /// dailies need at least one repeat day, todos need a due date.
  static String? _invalidTaskShape(Task t) {
    if (t.title.trim().isEmpty ||
        t.type.value == TaskType.TASK_TYPE_UNSPECIFIED ||
        t.difficulty == TaskDifficulty.TASK_DIFFICULTY_UNSPECIFIED) {
      return 'Title, type and difficulty are required';
    }
    if (t.type == TaskType.TASK_TYPE_DAILY && t.repeatDays.isEmpty) {
      return 'Daily tasks require at least one repeat day';
    }
    if (t.type == TaskType.TASK_TYPE_TODO && t.dueDate.toInt() <= 0) {
      return 'Todo tasks require a due date';
    }
    return null;
  }

  @override
  Future<ApiResponse<CompleteTaskReply>> completeTask(String id) async {
    final task = TaskBox.ins.getTask(id);
    if (task == null) {
      return ApiResponse.failure(code: StatusCode.notFound, message: 'Task not found');
    }
    if (task.isCompleted) {
      return ApiResponse.failure(code: StatusCode.failedPrecondition, message: 'Task already completed');
    }

    final character = CharacterBox.ins.getCharacter();
    if (character == null) {
      return ApiResponse.failure(code: StatusCode.notFound, message: 'Character not found');
    }
    if (character.isDead) {
      return ApiResponse.failure(
        code: StatusCode.failedPrecondition,
        message: 'Character is dead — revive first',
      );
    }

    // Rewards (streak-aware EXP + gold).
    final _gainExp = GameLogic.expReward(task);
    final _gainGold = GameLogic.goldReward(task);

    // Wallet + lifetime completed-task counter.
    final _userFreezon = UserBox.ins.getUserPrefs()..freeze();
    final _newUserPrefs = _userFreezon.rebuild(
      (user) => user
        ..currentGold = user.currentGold + _gainGold
        ..todayTasksCompleted = user.todayTasksCompleted + 1
        ..totalTasksCompleted = user.totalTasksCompleted + 1
        ..firstTaskDate =
            user.firstTaskDate == Int64(0) ? Int64(DateTime.now().millisecondsSinceEpoch) : user.firstTaskDate,
    );
    UserBox.ins.updateUserPrefs(_newUserPrefs);

    final _charClone = character.deepCopy()..freeze();

    // Leveling: currentExp is the character's cumulative EXP and is never
    // deducted on level-up — the UI shows the raw total over the EXP needed
    // for the next level (currentExp / expForLevel(level), e.g. 110/160).
    // The character levels up once the cumulative total reaches the next
    // level's requirement (expForLevel(level)); maxExp mirrors that
    // requirement so the frontend can refresh both values.
    final levelBefore = _charClone.level;
    final newTotalExp = _charClone.currentExp.toInt() + _gainExp;
    var newLevel = levelBefore;
    while (newLevel < GameConstants.maxLevel && newTotalExp >= GameConstants.expForLevel(newLevel)) {
      newLevel++;
    }
    final leveledUp = newLevel > levelBefore;
    final newHp = leveledUp
        ? (_charClone.currentHp + GameConstants.completeTaskAddHp).clamp(0, GameConstants.maxHp)
        : _charClone.currentHp;
    final _newCharacter = _charClone.rebuild(
      (char) => char
        ..currentExp = Int64(newTotalExp.clamp(0, GameConstants.expForLevel(GameConstants.maxLevel)))
        ..level = newLevel
        ..maxExp = Int64(GameConstants.expForLevel(newLevel))
        ..currentHp = newHp
        ..availableStatPoints = char.availableStatPoints + (newLevel - levelBefore) * GameConstants.statPointsPerLevel,
    );

    CharacterBox.ins.updateCharacter(_newCharacter);

    // Mark the task complete (streak / completedAt) and persist.
    final newTask = await TaskBox.ins.completeTask(task);

    // Achievements: total_tasks / streak / level conditions.
    await _unlockEligibleAchievements(
      totalTasks: _newUserPrefs.totalTasksCompleted.toInt(),
      streak: newTask.streak,
      level: _newCharacter.level,
    );

    return ApiResponse.success(
      CompleteTaskReply(
        task: newTask,
        prefs: _newUserPrefs,
        character: _newCharacter,
      ),
    );
  }

  /// Unlocks every achievement whose condition is met by the given metrics,
  /// granting its gem reward. Runs after task completion.
  Future<void> _unlockEligibleAchievements({
    required int totalTasks,
    required int streak,
    required int level,
  }) async {
    final unlockedIds = UserBox.ins.getAchievements().map((a) => a.id).toSet();
    for (final def in ShopConfig.achievementDefs) {
      if (unlockedIds.contains(def.id)) continue;
      final met = switch (def.conditionType) {
        'total_tasks' => totalTasks >= def.threshold,
        'streak' => streak >= def.threshold,
        'level' => level >= def.threshold,
        _ => false,
      };
      if (!met) continue;

      final unlocked = def.deepCopy()
        ..isUnlocked = true
        ..unlockedAt = Int64(DateTime.now().millisecondsSinceEpoch);
      UserBox.ins.updateAchievement(unlocked);
      if (unlocked.gemReward > 0) {
        final prefs = UserBox.ins.getUserPrefs();
        UserBox.ins.updateUserPrefs(GameLogic.addGems(prefs, unlocked.gemReward.toInt()));
      }
    }
  }

  @override
  Future<ApiResponse<DeleteTaskReply>> deleteTask(String id) async {
    // _tasksBox.delete('task_$id');
    TaskBox.ins.deleteTask(id);
    return ApiResponse.success(DeleteTaskReply());
  }

  @override
  Future<ApiResponse<EquipItemReply>> equipItem(String itemId, EquipmentSlot slot) async {
    final char = CharacterBox.ins.getCharacter();
    if (char == null) {
      return ApiResponse.failure(code: StatusCode.notFound, message: 'Character not found');
    }
    final owned = UserBox.ins.getOwnedItemIds();
    if (itemId.isNotEmpty && !owned.contains(itemId)) {
      return ApiResponse.failure(code: StatusCode.failedPrecondition, message: 'Item not owned');
    }
    final slotKey = _slotKey(slot);
    CharacterBox.ins.updateCharacter(GameLogic.equip(char, slotKey, itemId));
    return ApiResponse.success(EquipItemReply(), 'Equipped');
  }

  /// Maps an [EquipmentSlot] to the equipment-map key used on the character.
  static String _slotKey(EquipmentSlot slot) => switch (slot) {
        EquipmentSlot.EQUIPMENT_SLOT_WEAPON => 'weapon',
        EquipmentSlot.EQUIPMENT_SLOT_HELMET => 'helmet',
        EquipmentSlot.EQUIPMENT_SLOT_ARMOR => 'armor',
        EquipmentSlot.EQUIPMENT_SLOT_ACCESSORY => 'accessory',
        EquipmentSlot.EQUIPMENT_SLOT_UNSPECIFIED => 'unspecified',
        _ => 'unspecified',
      };

  @override
  Future<ApiResponse<GetCharacterReply>> getCharacter() async {
    final char = await CharacterBox.ins.getCharacter();
    if (char == null) {
      return ApiResponse.fromGrpcError(
        StatusCode.notFound,
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

    // Hive mode: settle overdue-task HP penalties at startup (once per day).
    final penalty = TaskBox.ins.collectOverduePenalty();
    if (penalty > 0) {
      final character = CharacterBox.ins.getCharacter();
      if (character != null && !character.isDead) {
        CharacterBox.ins.updateCharacter(GameLogic.takeDamage(character, penalty));
      }
    }

    return this;
  }

  // ── Auth ──

  /// Guest auto-login: hive mints a local session token immediately.
  @override
  Future<ApiResponse<LoginReply>> login(String provider) async {
    final token = Uuid().v4();
    await UserService.to.setSessionToken(token);
    return ApiResponse.success(LoginReply(token: token), 'Signed in');
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
  Future<void> reviveCharacter() async {
    final char = CharacterBox.ins.getCharacter();
    if (char == null || !char.isDead) return;
    final recoveryAt = DateTime.fromMillisecondsSinceEpoch(char.deathRecoveryUntil.toInt());
    if (DateTime.now().isBefore(recoveryAt)) return; // still recovering
    CharacterBox.ins.updateCharacter(GameLogic.revive(char));
  }

  @override
  Future<ApiResponse<SkipTaskReply>> skipTask(String id) async {
    final task = TaskBox.ins.getTask(id);
    if (task == null) {
      return ApiResponse.failure(code: StatusCode.notFound, message: 'Task not found');
    }
    final updated = await TaskBox.ins.skipTask(task);
    return ApiResponse.success(SkipTaskReply(task: updated));
  }

  @override
  Future<ApiResponse<UpdateTaskReply>> updateTask(String id, Task task) async {
    final current = TaskBox.ins.getTask(id);
    if (current == null) {
      return ApiResponse.failure(code: StatusCode.notFound, message: 'Task not found');
    }
    final reason = _invalidTaskShape(task);
    if (reason != null) {
      return ApiResponse.failure(code: StatusCode.invalidArgument, message: reason);
    }
    final now = Int64(DateTime.now().millisecondsSinceEpoch);
    final updated = (current.deepCopy()..freeze()).rebuild((t) {
      t.title = task.title;
      t.description = task.description;
      t.type = task.type;
      t.difficulty = task.difficulty;
      t.tags.clear();
      t.tags.addAll(task.tags);
      t.dueDate = task.dueDate;
      t.repeatDays.clear();
      t.repeatDays.addAll(task.repeatDays);
      t.priority = task.priority;
      t.hpPenalty = task.hpPenalty;
      t.updatedAt = now;
    });
    await TaskBox.ins.updateTask(updated);
    return ApiResponse.success(UpdateTaskReply(task: updated));
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

  @override
  Future<ApiResponse<ListOwnedItemsReply>> listOwnedItems() async {
    return ApiResponse.success(ListOwnedItemsReply(itemIds: UserBox.ins.getOwnedItemIds()));
  }

  @override
  Future<ApiResponse<DailyDeal>> getDailyDeal() async {
    return ApiResponse.success(
      DailyDeal(
        itemId: 'sword_flame',
        discountPercent: 30,
        expiresAt: Int64(DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch),
      ),
    );
  }

  @override
  Future<ApiResponse<ListAchievementsReply>> listAchievements() async {
    final unlocked = UserBox.ins.getAchievements();
    final merged = <Achievement>[];
    for (final def in ShopConfig.achievementDefs) {
      final match = unlocked.where((a) => a.id == def.id);
      merged.add(match.isNotEmpty ? match.first : def);
    }
    return ApiResponse.success(ListAchievementsReply(achievements: merged));
  }
}
