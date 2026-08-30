import 'dart:convert';

import 'package:fixnum/fixnum.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/utils/sp_utils.dart';
import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/hive/character_box.dart';
import 'package:habit_forge_app/core/network/network_interface.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/core/storage/catalog.dart';
import 'package:habit_forge_app/core/storage/game_logic.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character_error.pbenum.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

/// Local on-device storage (hive mode).
///
/// Game logic runs locally through [GameLogic] and the results are persisted
/// in Hive boxes. All mutations happen inside this class — the UI only ever
/// calls intent methods, never writes raw data.
class NetworkHiveImpl implements NetworkInterface {
  static NetworkHiveImpl get to => Get.find();

  late Box _userBox;
  late Box _tasksBox;
  late Box _shopBox;
  late Box _achievementBox;

  // Observable state
  final userPrefs = Rxn<UserPrefs>();
  final character = Rxn<Character>();
  final tasks = <Task>[].obs;
  final ownedItemIds = <String>[].obs;
  final achievements = <Achievement>[].obs;
  final dailyDeal = Rxn<DailyDeal>();

  final _uuid = const Uuid();
  final _json = const JsonCodec();

  @override
  List<Achievement> get achievementDefs => GameCatalog.achievementDefs;

  @override
  String get authMethod => _userBox.get('authMethod', defaultValue: '');

  @override
  String? get authToken => _userBox.get('serverToken') as String?;

  @override
  List<ShopItem> get shopItems => GameCatalog.shopItems;

  @override
  Future<bool> allocateStatPoint(StatType stat) async {
    final char = character.value;
    if (char == null || char.availableStatPoints <= 0) return false;
    saveCharacter(GameLogic.allocateStat(char, stat));
    return true;
  }

  @override
  Future<TaskCompleteResult> completeTask(String id) async {
    final task = _findTask(id);
    if (task == null) {
      return const TaskCompleteResult(expGained: 0, goldGained: 0);
    }
    final completed = GameLogic.completeTask(task);
    _tasksBox.put('task_$id', _json.encode(completed.writeToJsonMap()));
    _loadTasks();

    final exp = GameLogic.expReward(completed);
    final gold = GameLogic.goldReward(completed);

    var prefs = userPrefs.value ?? UserPrefs();
    prefs = GameLogic.addGold(GameLogic.addCompletedTask(prefs), gold);
    _savePrefs(prefs);

    var newLevel = -1;
    final char = character.value;
    if (char != null) {
      final (updated, level) = GameLogic.gainExp(char, exp);
      saveCharacter(updated);
      newLevel = level;
    }

    await _checkAchievements(
      tasksCompleted: prefs.totalTasksCompleted.toInt(),
      streak: completed.streak,
      level: character.value?.level ?? 0,
    );

    return TaskCompleteResult(expGained: exp, goldGained: gold, newLevel: newLevel > 0 ? newLevel : null);
  }

  // ── Character ──

  @override
  Future<ApiResponse<GetCharacterReply>> createCharacter(CharacterClass characterClass) async {
    if (await CharacterBox.ins.getCharacter() == null) {
      return ApiResponse.fromGrpcError(
        CharacterErrorReason.CHARACTER_ALREADY_EXISTS.value,
        'Character already exists',
        errorReasonValue: null,
        reason: null,
      );
    }
    final character = await CharacterBox.ins.createCharacter(characterClass);
    return ApiResponse.success(GetCharacterReply(character: character), 'Character created');
  }

  // ── Tasks ──

  @override
  Future<ApiResponse<Task>> createTask(CreateTaskParams params) async {
    if (params.title.trim().isEmpty) {
      return ApiResponse.failure(code: 400, message: 'Title is required');
    }
    final now = Int64(DateTime.now().millisecondsSinceEpoch);
    final task = Task(
      id: _uuid.v4(),
      title: params.title.trim(),
      description: params.description?.trim().isNotEmpty == true ? params.description!.trim() : null,
      type: params.type,
      difficulty: params.difficulty,
      tags: params.tags,
      dueDate: params.dueDate ?? Int64.ZERO,
      repeatDays: params.repeatDays,
      priority: params.priority,
      hpPenalty: params.hpPenalty,
      createdAt: now,
      updatedAt: now,
    );
    _tasksBox.put('task_${task.id}', _json.encode(task.writeToJsonMap()));
    _loadTasks();
    return ApiResponse.success(task, 'Task created');
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasksBox.delete('task_$id');
    _loadTasks();
  }

  @override
  void equipItem(String itemId, {String slot = 'weapon'}) {
    final char = character.value;
    if (char != null) saveCharacter(GameLogic.equip(char, slot, itemId));
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
    return ApiResponse.success(GetCharacterReply(character: char), 'success');
  }

  // ── Lifecycle ──

  @override
  Future<NetworkHiveImpl> init() async {
    await Hive.initFlutter();
    await CharacterBox.ins.init();
    _userBox = await Hive.openBox('userBox');
    _tasksBox = await Hive.openBox('tasksBox');
    _shopBox = await Hive.openBox('shopBox');
    _achievementBox = await Hive.openBox('achievementBox');

    if (!UserService.to.isLoggedIn()) {
      final token = Uuid().v4();
      await SpUtils.ins.putString('token', token);
      // Keep the in-memory token in sync: UserService.token was loaded in
      // main() before this init ran, so without this the splash login check
      // (which reads the in-memory value) would still see an empty token.
      UserService.to.token.value = token;
    }
    return this;
  }

  @override
  Future<void> postponeTask(String id) async {
    final task = _findTask(id);
    if (task == null) return;
    _tasksBox.put('task_$id', _json.encode(GameLogic.postpone(task).writeToJsonMap()));
    _loadTasks();
  }

  // ── Shop ──

  @override
  Future<ApiResponse<BuyItemReply>> purchaseItem(
    String itemId, {
    ShopCurrency currency = ShopCurrency.SHOP_CURRENCY_GOLD,
  }) async {
    final item = GameCatalog.shopItems.where((i) => i.id == itemId).firstOrNull;
    if (item == null) {
      return ApiResponse.failure(code: 404, message: 'Item not found');
    }
    if (ownedItemIds.contains(itemId)) {
      return ApiResponse.failure(code: 409, message: 'Item already owned');
    }
    final prefs = userPrefs.value ?? UserPrefs();
    if (prefs.currentGold < item.price) {
      return ApiResponse.failure(code: 400, message: 'Not enough gold');
    }

    _savePrefs(GameLogic.addGold(prefs, -item.price.toInt()));
    _addOwnedItem(itemId);
    await _checkAchievements(purchases: 1);

    return ApiResponse.success(
      BuyItemReply(item: item, balance: (userPrefs.value ?? UserPrefs()).currentGold),
      'Purchase successful',
    );
  }

  @override
  Future<void> refreshAll() async {
    _loadTasks();
    ownedItemIds.value = _shopBox.get('ownedItems', defaultValue: <String>[]).cast<String>();
    _loadAchievements();
    dailyDeal.value = _readJson(_shopBox, 'dailyDeal', (m) => DailyDeal()..mergeFromJsonMap(m));
  }

  @override
  Future<DailyDeal> refreshDailyDeal() async {
    final saved = dailyDeal.value;
    if (saved != null && DateTime(saved.expiresAt.toInt()).isAfter(DateTime.now())) {
      return saved;
    }
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final expiresAt = now.isAfter(endOfDay)
        ? DateTime(now.year, now.month, now.day, 23, 59, 59).add(const Duration(days: 1))
        : endOfDay;
    final deal = DailyDeal(
      itemId: 'staff_arcane',
      discountPercent: 40,
      expiresAt: Int64(expiresAt.millisecondsSinceEpoch),
    );
    dailyDeal.value = deal;
    _shopBox.put('dailyDeal', _json.encode(deal.writeToJsonMap()));
    return deal;
  }

  @override
  Future<void> resetAllData() async {
    await _userBox.clear();
    await _tasksBox.clear();
    await _shopBox.clear();
    await _achievementBox.clear();
    userPrefs.value = null;
    character.value = null;
    tasks.clear();
    ownedItemIds.clear();
    achievements.clear();
    dailyDeal.value = null;
  }

  @override
  Future<void> reviveCharacter() async {
    final char = character.value;
    if (char == null || !char.isDead) return;
    saveCharacter(GameLogic.revive(char));
    await _checkAchievements(deaths: 1);
  }

  // ── Auth ──

  @override
  void saveAuthToken(String? token) {
    if (token == null) {
      _userBox.delete('serverToken');
    } else {
      _userBox.put('serverToken', token);
    }
  }

  // ── Character persistence ──

  void saveCharacter(Character c) {
    character.value = c;
    CharacterBox.ins.save(c);
  }

  @override
  void setLoggedIn(bool value, {String method = ''}) {
    _userBox.put('isLoggedIn', value);
    if (method.isNotEmpty) _userBox.put('authMethod', method);
  }

  @override
  Future<void> skipTask(String id) async {
    final task = _findTask(id);
    if (task == null) return;
    _tasksBox.put('task_$id', _json.encode(GameLogic.skip(task).writeToJsonMap()));
    _loadTasks();
  }

  @override
  Future<void> takeDamage(int amount) async {
    final char = character.value;
    if (char != null) saveCharacter(GameLogic.takeDamage(char, amount));
  }

  @override
  Future<ApiResponse<Task>> updateTask(String id, CreateTaskParams params) async {
    final current = _findTask(id);
    if (current == null) {
      return ApiResponse.failure(code: 404, message: 'Task not found');
    }
    final updated = params.applyTo(current);
    _tasksBox.put('task_$id', _json.encode(updated.writeToJsonMap()));
    _loadTasks();
    return ApiResponse.success(updated, 'Task updated');
  }

  void _addOwnedItem(String itemId) {
    if (!ownedItemIds.contains(itemId)) {
      ownedItemIds.add(itemId);
      _shopBox.put('ownedItems', ownedItemIds.toList());
    }
  }

  // ── Achievements (unlocked internally, driven by behaviors) ──

  Future<void> _checkAchievements({int? tasksCompleted, int? streak, int? level, int? purchases, int? deaths}) async {
    for (final def in GameCatalog.achievementDefs) {
      if (_isUnlocked(def.id)) continue;
      final progress = switch (def.conditionType) {
        'total_tasks' => tasksCompleted ?? 0,
        'streak' => streak ?? 0,
        'level' => level ?? 0,
        'purchases' => purchases ?? 0,
        'deaths' => deaths ?? 0,
        _ => 0,
      };
      if (progress >= def.threshold) {
        await _unlockAchievement(def);
      }
    }
  }

  /// Decodes a stored JSON value into a map, unwrapping the legacy
  /// double-encoded string format (written by the old `writeToJson()` path).
  Map<String, dynamic>? _decodeMap(String raw) {
    try {
      final decoded = _json.decode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      // Legacy format: the value was json-encoded again after writeToJson()
      // returned a JSON string, so decoding yields a String of JSON.
      final inner = _json.decode(decoded as String);
      return inner is Map<String, dynamic> ? inner : null;
    } catch (_) {
      return null;
    }
  }

  // ── Internal ──

  Task? _findTask(String id) {
    for (final t in tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  bool _isUnlocked(String id) => achievements.any((a) => a.id == id && a.isUnlocked);

  void _loadAchievements() {
    final all = <Achievement>[];
    for (final key in _achievementBox.keys) {
      final raw = _achievementBox.get(key) as String?;
      if (raw == null) continue;
      final map = _decodeMap(raw);
      if (map == null) continue;
      all.add(Achievement()..mergeFromJsonMap(map));
    }
    achievements.value = all;
  }

  void _loadTasks() {
    final all = <Task>[];
    for (final key in _tasksBox.keys) {
      final raw = _tasksBox.get(key) as String?;
      if (raw == null) continue;
      final map = _decodeMap(raw);
      if (map == null) continue;
      all.add(Task()..mergeFromJsonMap(map));
    }
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    tasks.value = all;
  }

  T? _readJson<T>(Box box, String key, T Function(Map<String, dynamic>) fromJson) {
    final raw = box.get(key) as String?;
    if (raw == null) return null;
    final map = _decodeMap(raw);
    if (map == null) return null;
    return fromJson(map);
  }

  void _saveAchievement(Achievement a) {
    _achievementBox.put('ach_${a.id}', _json.encode(a.writeToJsonMap()));
    _loadAchievements();
  }

  // ── User prefs ──

  void _savePrefs(UserPrefs prefs) {
    userPrefs.value = prefs;
    _writeJson(_userBox, 'userPrefs', prefs.writeToJsonMap());
  }

  Future<void> _unlockAchievement(Achievement def) async {
    final unlocked = def.rebuild(
      (a) => a
        ..isUnlocked = true
        ..progress = def.threshold
        ..unlockedAt = Int64(DateTime.now().millisecondsSinceEpoch),
    );
    _saveAchievement(unlocked);
    if (unlocked.gemReward > 0) {
      final prefs = userPrefs.value ?? UserPrefs();
      _savePrefs(GameLogic.addGems(prefs, unlocked.gemReward.toInt()));
    }
  }

  void _writeJson(Box box, String key, Object obj) {
    box.put(key, _json.encode(obj));
  }
}
