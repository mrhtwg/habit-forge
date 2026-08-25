import 'dart:convert';

import 'package:get/get.dart';
import 'package:habit_forge_app/models/achievement/achievement.dart';
import 'package:habit_forge_app/models/character/character_model.dart';
import 'package:habit_forge_app/models/shop/daily_deal.dart';
import 'package:habit_forge_app/models/task/task_model.dart';
import 'package:habit_forge_app/models/user/user_prefs.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class HiveService extends GetxService {
  static HiveService get to => Get.find();

  late Box _userBox;
  late Box _characterBox;
  late Box _tasksBox;
  late Box _shopBox;
  late Box _achievementBox;

  // Observable state
  final userPrefs = Rxn<UserPrefs>();
  final character = Rxn<CharacterModel>();
  final tasks = <TaskModel>[].obs;
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

  // ── Shop ──
  void addOwnedItem(String itemId) {
    if (!ownedItemIds.contains(itemId)) {
      ownedItemIds.add(itemId);
      _shopBox.put('ownedItems', ownedItemIds.toList());
    }
  }

  String createTask(TaskModel task) {
    final id = _uuid.v4();
    final t = task.copyWith(id: id);
    _tasksBox.put('task_$id', _json.encode(t.toJson()));
    _loadTasks();
    return id;
  }

  void deleteTask(String id) {
    _tasksBox.delete('task_$id');
    _loadTasks();
  }

  Future<HiveService> init() async {
    _userBox = await Hive.openBox('userBox');
    _characterBox = await Hive.openBox('characterBox');
    _tasksBox = await Hive.openBox('tasksBox');
    _shopBox = await Hive.openBox('shopBox');
    _achievementBox = await Hive.openBox('achievementBox');

    userPrefs.value = _readJson(_userBox, 'userPrefs', (m) => UserPrefs.fromJson(m));
    character.value = _readJson(_characterBox, 'character', (m) => CharacterModel.fromJson(m));
    _loadTasks();
    ownedItemIds.value = _shopBox.get('ownedItems', defaultValue: <String>[]).cast<String>();
    _loadAchievements();
    dailyDeal.value = _readJson(_shopBox, 'dailyDeal', (m) => DailyDeal.fromJson(m));
    return this;
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

  void saveAchievement(Achievement a) {
    _achievementBox.put('ach_${a.id}', _json.encode(a.toJson()));
    _loadAchievements();
  }

  void saveAuthToken(String? token) {
    if (token == null) {
      _userBox.delete('serverToken');
    } else {
      _userBox.put('serverToken', token);
    }
  }

  // ── Character ──
  void saveCharacter(CharacterModel c) {
    character.value = c;
    _writeJson(_characterBox, 'character', c.toJson());
  }

  void saveDailyDeal(DailyDeal deal) {
    dailyDeal.value = deal;
    _shopBox.put('dailyDeal', _json.encode(deal.toJson()));
  }

  // ── User Prefs ──
  void saveUserPrefs(UserPrefs prefs) {
    userPrefs.value = prefs;
    _writeJson(_userBox, 'userPrefs', prefs.toJson());
  }

  void setLoggedIn(bool value, {String method = ''}) {
    _userBox.put('isLoggedIn', value);
    if (method.isNotEmpty) _userBox.put('authMethod', method);
  }

  void updateTask(TaskModel task) {
    _tasksBox.put('task_${task.id}', _json.encode(task.toJson()));
    _loadTasks();
  }

  // ── Achievements ──
  void _loadAchievements() {
    final all = <Achievement>[];
    for (final key in _achievementBox.keys) {
      final raw = _achievementBox.get(key) as String?;
      if (raw == null) continue;
      try {
        final map = _json.decode(raw) as Map<String, dynamic>;
        all.add(Achievement.fromJson(map));
      } catch (_) {}
    }
    achievements.value = all;
  }

  // ── Tasks ──
  void _loadTasks() {
    final all = <TaskModel>[];
    for (final key in _tasksBox.keys) {
      final raw = _tasksBox.get(key) as String?;
      if (raw == null) continue;
      try {
        final map = _json.decode(raw) as Map<String, dynamic>;
        all.add(TaskModel.fromJson(map));
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
