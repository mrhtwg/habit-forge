import 'dart:convert';

import 'package:fixnum/fixnum.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/storage/game_logic.dart';
import 'package:habit_forge_app/core/storage/storage_service.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

/// Local on-device storage (hive mode).
///
/// Game logic runs locally through [GameLogic] and the results are persisted
/// in Hive boxes.
class HiveService extends GetxService implements StorageService {
  static HiveService get to => Get.find();

  late Box _userBox;
  late Box _characterBox;
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
  bool get isLoggedIn => _userBox.get('isLoggedIn', defaultValue: false);

  // ── Lifecycle ──
  Future<HiveService> init() async {
    _userBox = await Hive.openBox('userBox');
    _characterBox = await Hive.openBox('characterBox');
    _tasksBox = await Hive.openBox('tasksBox');
    _shopBox = await Hive.openBox('shopBox');
    _achievementBox = await Hive.openBox('achievementBox');

    await refreshAll();
    return this;
  }

  @override
  Future<void> refreshAll() async {
    userPrefs.value = _readJson(_userBox, 'userPrefs', (m) => UserPrefs()..mergeFromJsonMap(m));
    character.value = _readJson(_characterBox, 'character', (m) => Character.fromJson(m.toString()));
    _loadTasks();
    ownedItemIds.value = _shopBox.get('ownedItems', defaultValue: <String>[]).cast<String>();
    _loadAchievements();
    dailyDeal.value = _readJson(_shopBox, 'dailyDeal', (m) => DailyDeal()..mergeFromJsonMap(m));
  }

  Future<void> resetAllData() async {
    await _userBox.clear();
    await _characterBox.clear();
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

  // ── Task operations ──
  String createTask(Task task) {
    final id = _uuid.v4();
    final t = task..id = id;
    _tasksBox.put('task_$id', _json.encode(t.writeToJson()));
    _loadTasks();
    return id;
  }

  void updateTask(Task task) {
    _tasksBox.put('task_${task.id}', _json.encode(task.writeToJson()));
    _loadTasks();
  }

  void deleteTask(String id) {
    _tasksBox.delete('task_$id');
    _loadTasks();
  }

  void skipTask(Task task) => updateTask(task.rebuild((t) => t..isSkipped = !task.isSkipped));

  void postponeTask(Task task) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    updateTask(task.rebuild((t) => t
      ..isSkipped = true
      ..dueDate = task.type == TaskType.TASK_TYPE_TODO ? Int64(tomorrow.millisecondsSinceEpoch) : task.dueDate,
    ),
    );
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
  Future<void> createCharacter(Character c) async {
    saveCharacter(c);
  }

  Future<bool> allocateStatPoint(StatType stat) async {
    final char = character.value;
    if (char == null || char.availableStatPoints <= 0) return false;
    saveCharacter(GameLogic.allocateStat(char, stat));
    return true;
  }

  Future<void> takeDamage(int amount) async {
    final char = character.value;
    if (char != null) saveCharacter(GameLogic.takeDamage(char, amount));
  }

  Future<void> reviveCharacter() async {
    final char = character.value;
    if (char != null && char.isDead) saveCharacter(GameLogic.revive(char));
  }

  void equipItem(String itemId, {String slot = 'weapon'}) {
    final char = character.value;
    if (char != null) saveCharacter(GameLogic.equip(char, slot, itemId));
  }

  // ── Character persistence (used by the operations above) ──
  void saveCharacter(Character c) {
    character.value = c;
    _writeJson(_characterBox, 'character', c.writeToJson());
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

  Future<void> addGold(int amount) async {
    final prefs = userPrefs.value ?? UserPrefs();
    saveUserPrefs(GameLogic.addGold(prefs, amount));
  }

  Future<void> addGems(int amount) async {
    final prefs = userPrefs.value ?? UserPrefs();
    saveUserPrefs(GameLogic.addGems(prefs, amount));
  }

  // ── Achievements ──
  Future<bool> unlockAchievement(Achievement def) async {
    if (achievements.any((a) => a.id == def.id && a.isUnlocked)) return false;
    final unlocked = def.rebuild((a) => a
      ..isUnlocked = true
      ..unlockedAt = Int64(DateTime.now().millisecondsSinceEpoch),
    );
    _saveAchievement(unlocked);
    if (unlocked.gemReward > 0) {
      await addGems(unlocked.gemReward.toInt());
    }
    return true;
  }

  // ── User prefs ──
  void saveUserPrefs(UserPrefs prefs) {
    userPrefs.value = prefs;
    _writeJson(_userBox, 'userPrefs', prefs.writeToJson());
  }

  void saveDailyDeal(DailyDeal deal) {
    dailyDeal.value = deal;
    _shopBox.put('dailyDeal', _json.encode(deal.writeToJson()));
  }

  // ── Auth ──
  void setLoggedIn(bool value, {String method = ''}) {
    _userBox.put('isLoggedIn', value);
    if (method.isNotEmpty) _userBox.put('authMethod', method);
  }

  void saveAuthToken(String? token) {
    if (token == null) {
      _userBox.delete('serverToken');
    } else {
      _userBox.put('serverToken', token);
    }
  }

  // ── Internal ──
  void _addOwnedItem(String itemId) {
    if (!ownedItemIds.contains(itemId)) {
      ownedItemIds.add(itemId);
      _shopBox.put('ownedItems', ownedItemIds.toList());
    }
  }

  void _saveAchievement(Achievement a) {
    _achievementBox.put('ach_${a.id}', _json.encode(a.writeToJson()));
    _loadAchievements();
  }

  void _loadAchievements() {
    final all = <Achievement>[];
    for (final key in _achievementBox.keys) {
      final raw = _achievementBox.get(key) as String?;
      if (raw == null) continue;
      try {
        final map = _json.decode(raw) as Map<String, dynamic>;
        all.add(Achievement()..mergeFromJsonMap(map));
      } catch (_) {}
    }
    achievements.value = all;
  }

  void _loadTasks() {
    final all = <Task>[];
    for (final key in _tasksBox.keys) {
      final raw = _tasksBox.get(key) as String?;
      if (raw == null) continue;
      try {
        final map = _json.decode(raw) as Map<String, dynamic>;
        all.add(Task()..mergeFromJsonMap(map));
      } catch (_) {}
    }
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    tasks.value = all;
  }

  T? _readJson<T>(Box box, String key, T Function(Map<String, dynamic>) fromJson) {
    final raw = box.get(key) as String?;
    if (raw == null) return null;
    try {
      final map = _json.decode(raw) as Map<String, dynamic>;
      return fromJson(map);
    } catch (_) {
      return null;
    }
  }

  void _writeJson(Box box, String key, Object obj) {
    box.put(key, _json.encode(obj));
  }
}
