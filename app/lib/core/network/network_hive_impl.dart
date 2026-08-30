import 'dart:convert';

import 'package:fixnum/fixnum.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/utils/sp_utils.dart';
import 'package:habit_forge_app/core/hive/character_box.dart';
import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/network_interface.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
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
/// in Hive boxes.
class NetworkHiveImpl implements NetworkInterface {
  static NetworkHiveImpl get to => Get.find();

  late Box _userBox;
  // late Box _characterBox;
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

  String get authMethod => _userBox.get('authMethod', defaultValue: '');

  /// JWT token issued by the self-hosted backend (server mode).
  String? get authToken => _userBox.get('serverToken') as String?;

  // ── Auth ──

  Future<void> addGems(int amount) async {
    final prefs = userPrefs.value ?? UserPrefs();
    saveUserPrefs(GameLogic.addGems(prefs, amount));
  }

  Future<void> addGold(int amount) async {
    final prefs = userPrefs.value ?? UserPrefs();
    saveUserPrefs(GameLogic.addGold(prefs, amount));
  }

  Future<bool> allocateStatPoint(StatType stat) async {
    final char = character.value;
    if (char == null || char.availableStatPoints <= 0) return false;
    saveCharacter(GameLogic.allocateStat(char, stat));
    return true;
  }

  Future<TaskCompleteResult> completeTask(Task task) async {
    final completed = GameLogic.completeTask(task);
    updateTask(completed);

    final exp = GameLogic.expReward(task);
    final gold = GameLogic.goldReward(task);

    final prefs = userPrefs.value ?? UserPrefs();
    saveUserPrefs(GameLogic.addGold(GameLogic.addCompletedTask(prefs), gold));

    var newLevel = -1;
    final char = character.value;
    if (char != null) {
      final (updated, level) = GameLogic.gainExp(char, exp);
      saveCharacter(updated);
      newLevel = level;
    }
    return TaskCompleteResult(expGained: exp, goldGained: gold, newLevel: newLevel > 0 ? newLevel : null);
  }

  // ── Character operations ──
  Future<ApiResponse<GetCharacterReply>> createCharacter(CharacterClass characterClass) async {
    if (await loadCharacter() != null) {
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

  // ── Task operations ──
  String createTask(Task task) {
    final id = _uuid.v4();
    final t = task
      ..id = id
      ..createdAt = Int64(DateTime.now().millisecondsSinceEpoch)
      ..updatedAt = Int64(DateTime.now().millisecondsSinceEpoch);

    _tasksBox.put('task_$id', _json.encode(t.writeToJsonMap()));
    // _loadTasks();
    return id;
  }

  void deleteTask(String id) {
    _tasksBox.delete('task_$id');
    _loadTasks();
  }

  void equipItem(String itemId, {String slot = 'weapon'}) {
    final char = character.value;
    if (char != null) saveCharacter(GameLogic.equip(char, slot, itemId));
  }

  // ── Lifecycle ──
  Future<NetworkHiveImpl> init() async {
    await Hive.initFlutter();
    await CharacterBox.ins.init();
    _userBox = await Hive.openBox('userBox');
    // _characterBox = await Hive.openBox('characterBox');
    _tasksBox = await Hive.openBox('tasksBox');
    _shopBox = await Hive.openBox('shopBox');
    _achievementBox = await Hive.openBox('achievementBox');

    if (!UserService.to.isLoggedIn()) {
      final token = Uuid().v4();
      await SpUtils.ins.putString('token', token);
      UserService.to.token.value = token;
    }
    return this;
  }

  @override
  Future<Character?> loadCharacter() async => await CharacterBox.ins.getCharacter();

  void postponeTask(Task task) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    updateTask(
      task.rebuild(
        (t) => t
          ..isSkipped = true
          ..dueDate = task.type == TaskType.TASK_TYPE_TODO ? Int64(tomorrow.millisecondsSinceEpoch) : task.dueDate,
      ),
    );
  }

  // ── Economy ──
  Future<bool> purchaseItem(String itemId, int price, {ShopCurrency currency = ShopCurrency.SHOP_CURRENCY_GOLD}) async {
    final prefs = userPrefs.value ?? UserPrefs();
    if (prefs.currentGold < price) return false;
    if (ownedItemIds.contains(itemId)) return false;
    saveUserPrefs(GameLogic.addGold(prefs, -price));
    _addOwnedItem(itemId);
    return true;
  }

  @override
  Future<void> refreshAll() async {
    // userPrefs.value = _readJson(_userBox, 'userPrefs', (m) => UserPrefs()..mergeFromJsonMap(m));
    // character.value = _readJson(_characterBox, 'character', (m) => Character()..mergeFromJsonMap(m));
    _loadTasks();
    ownedItemIds.value = _shopBox.get('ownedItems', defaultValue: <String>[]).cast<String>();
    _loadAchievements();
    dailyDeal.value = _readJson(_shopBox, 'dailyDeal', (m) => DailyDeal()..mergeFromJsonMap(m));
  }

  Future<void> resetAllData() async {
    await _userBox.clear();
    // await _characterBox.clear();
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

  Future<void> reviveCharacter() async {
    final char = character.value;
    if (char != null && char.isDead) saveCharacter(GameLogic.revive(char));
  }

  void saveAuthToken(String? token) {
    if (token == null) {
      _userBox.delete('serverToken');
    } else {
      _userBox.put('serverToken', token);
    }
  }

  // ── Character persistence (used by the operations above) ──
  void saveCharacter(Character c) {
    // character.value = c;
    // _writeJson(_characterBox, 'character', c.writeToJsonMap());
  }

  void saveDailyDeal(DailyDeal deal) {
    dailyDeal.value = deal;
    _shopBox.put('dailyDeal', _json.encode(deal.writeToJsonMap()));
  }

  // ── User prefs ──
  void saveUserPrefs(UserPrefs prefs) {
    userPrefs.value = prefs;
    _writeJson(_userBox, 'userPrefs', prefs.writeToJsonMap());
  }

  // ── Auth ──
  void setLoggedIn(bool value, {String method = ''}) {
    _userBox.put('isLoggedIn', value);
    if (method.isNotEmpty) _userBox.put('authMethod', method);
  }

  void skipTask(Task task) => updateTask(task.rebuild((t) => t..isSkipped = !task.isSkipped));

  Future<void> takeDamage(int amount) async {
    final char = character.value;
    if (char != null) saveCharacter(GameLogic.takeDamage(char, amount));
  }

  // ── Achievements ──
  Future<bool> unlockAchievement(Achievement def) async {
    if (achievements.any((a) => a.id == def.id && a.isUnlocked)) return false;
    final unlocked = def.rebuild(
      (a) => a
        ..isUnlocked = true
        ..unlockedAt = Int64(DateTime.now().millisecondsSinceEpoch),
    );
    _saveAchievement(unlocked);
    if (unlocked.gemReward > 0) {
      await addGems(unlocked.gemReward.toInt());
    }
    return true;
  }

  void updateTask(Task task) {
    _tasksBox.put('task_${task.id}', _json.encode(task.writeToJsonMap()));
    _loadTasks();
  }

  // ── Internal ──
  void _addOwnedItem(String itemId) {
    if (!ownedItemIds.contains(itemId)) {
      ownedItemIds.add(itemId);
      _shopBox.put('ownedItems', ownedItemIds.toList());
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

  void _writeJson(Box box, String key, Object obj) {
    box.put(key, _json.encode(obj));
  }
}
