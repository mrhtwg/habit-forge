import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixnum/fixnum.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/network_interface.dart';
import 'package:habit_forge_app/core/storage/catalog.dart';
import 'package:habit_forge_app/core/storage/game_logic.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character_error.pbenum.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';
import 'package:uuid/uuid.dart';

/// Firestore-backed storage (firebase mode).
///
/// Game logic runs locally through [GameLogic]; results are persisted per
/// authenticated user in Firestore and mirrored into reactive state. All
/// mutations happen inside this class — the UI only calls intent methods.
class NetworkFirebaseImpl implements NetworkInterface {
  final userPrefs = Rxn<UserPrefs>();
  final character = Rxn<Character>();
  final tasks = <Task>[].obs;
  final ownedItemIds = <String>[].obs;
  final achievements = <Achievement>[].obs;
  final dailyDeal = Rxn<DailyDeal>();

  List<StreamSubscription<Object?>> _subscriptions = [];

  @override
  List<Achievement> get achievementDefs => GameCatalog.achievementDefs;

  @override
  String get authMethod => 'firebase';

  @override
  String? get authToken => null;

  @override
  List<ShopItem> get shopItems => GameCatalog.shopItems;

  // Firebase manages its own session — auth state derives from FirebaseAuth.

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  Future<bool> allocateStatPoint(StatType stat) async {
    final char = character.value;
    if (char == null || char.availableStatPoints <= 0) return false;
    await _saveCharacter(GameLogic.allocateStat(char, stat));
    return true;
  }

  @override
  Future<TaskCompleteResult> completeTask(String id) async {
    final task = _findTask(id);
    if (task == null) {
      return const TaskCompleteResult(expGained: 0, goldGained: 0);
    }
    final completed = GameLogic.completeTask(task);
    await _col('tasks').doc(id).set(completed.writeToJsonMap());

    final exp = GameLogic.expReward(completed);
    final gold = GameLogic.goldReward(completed);

    var prefs = userPrefs.value ?? UserPrefs();
    prefs = GameLogic.addGold(GameLogic.addCompletedTask(prefs), gold);
    await _savePrefs(prefs);

    var newLevel = -1;
    final char = character.value;
    if (char != null) {
      final (updated, level) = GameLogic.gainExp(char, exp);
      await _saveCharacter(updated);
      newLevel = level;
    }

    await _checkAchievements(
      tasksCompleted: prefs.totalTasksCompleted.toInt(),
      streak: completed.streak,
      level: character.value?.level ?? 0,
    );

    return TaskCompleteResult(expGained: exp, goldGained: gold, newLevel: newLevel > 0 ? newLevel : null);
  }

  // ── Character operations ──

  @override
  Future<ApiResponse<GetCharacterReply>> createCharacter(CharacterClass characterClass) async {
    final c = Character()..characterClass = characterClass;
    await _saveCharacter(c);
    return ApiResponse.success(GetCharacterReply(character: c), 'Character created');
  }

  // ── Task operations ──

  @override
  Future<ApiResponse<Task>> createTask(CreateTaskParams params) async {
    if (params.title.trim().isEmpty) {
      return ApiResponse.failure(code: 400, message: 'Title is required');
    }
    final now = Int64(DateTime.now().millisecondsSinceEpoch);
    final task = Task(
      id: const Uuid().v4(),
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
    await _col('tasks').doc(task.id).set(task.writeToJsonMap());
    return ApiResponse.success(task, 'Task created');
  }

  @override
  Future<void> deleteTask(String id) async {
    await _col('tasks').doc(id).delete();
  }

  @override
  void equipItem(String itemId, {String slot = 'weapon'}) {
    final char = character.value;
    if (char != null) _saveCharacter(GameLogic.equip(char, slot, itemId));
  }

  Future<ApiResponse<GetCharacterReply>> getCharacter() async {
    return ApiResponse.fromGrpcError(
      CharacterErrorReason.CHARACTER_NOT_FOUND.value,
      'Character not found',
      errorReasonValue: null,
      reason: null,
    );
  }

  @override
  Future<NetworkInterface> init() async {
    if (_uid == null) return this;
    await refreshAll();
    _listen();
    return this;
  }

  @override
  Future<void> postponeTask(String id) async {
    final task = _findTask(id);
    if (task == null) return;
    await _col('tasks').doc(id).set(GameLogic.postpone(task).writeToJsonMap());
  }

  // ── Economy ──

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

    await _savePrefs(GameLogic.addGold(prefs, -item.price.toInt()));
    await _addOwnedItem(itemId);
    await _checkAchievements(purchases: 1);

    return ApiResponse.success(
      BuyItemReply(item: item, balance: (userPrefs.value ?? UserPrefs()).currentGold),
      'Purchase successful',
    );
  }

  @override
  Future<void> refreshAll() async {
    if (_uid == null) return;

    final prefs = await _col('prefs').doc('self').get();
    userPrefs.value = prefs.exists ? (UserPrefs()..mergeFromJsonMap(prefs.data() ?? {})) : UserPrefs();

    final tasksSnap = await _col('tasks').get();
    tasks.value = tasksSnap.docs.map((d) => Task()..mergeFromJsonMap(d.data())).toList();

    final owned = await _col('owned').doc('self').get();
    ownedItemIds.value = List<String>.from((owned.data()?['ids'] as List?) ?? const []);

    final ach = await _col('achievements').get();
    achievements.value = ach.docs.map((d) => Achievement()..mergeFromJsonMap(d.data())).toList();

    final deal = await _col('shop').doc('dailyDeal').get();
    dailyDeal.value = deal.exists ? (DailyDeal()..mergeFromJsonMap(deal.data() ?? {})) : null;
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
    await _col('shop').doc('dailyDeal').set(deal.writeToJsonMap());
    return deal;
  }

  @override
  Future<void> resetAllData() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions = [];

    final uid = _uid;
    if (uid != null) {
      for (final name in ['prefs', 'character', 'tasks', 'owned', 'shop', 'achievements']) {
        final snap = await _col(name).get();
        for (final doc in snap.docs) {
          await doc.reference.delete();
        }
      }
    }

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
    await _saveCharacter(GameLogic.revive(char));
    await _checkAchievements(deaths: 1);
  }

  // ── Auth (Firebase manages its own session) ──

  @override
  void saveAuthToken(String? token) {
    // No local token to store; FirebaseAuth owns the session.
  }

  @override
  void setLoggedIn(bool value, {String method = ''}) {
    // Login state derives from FirebaseAuth; ignore local calls.
  }

  @override
  Future<void> skipTask(String id) async {
    final task = _findTask(id);
    if (task == null) return;
    await _col('tasks').doc(id).set(GameLogic.skip(task).writeToJsonMap());
  }

  @override
  Future<void> takeDamage(int amount) async {
    final char = character.value;
    if (char != null) await _saveCharacter(GameLogic.takeDamage(char, amount));
  }

  @override
  Future<ApiResponse<Task>> updateTask(String id, CreateTaskParams params) async {
    final current = _findTask(id);
    if (current == null) {
      return ApiResponse.failure(code: 404, message: 'Task not found');
    }
    final updated = params.applyTo(current);
    await _col('tasks').doc(id).set(updated.writeToJsonMap());
    return ApiResponse.success(updated, 'Task updated');
  }

  Future<void> _addOwnedItem(String itemId) async {
    if (!ownedItemIds.contains(itemId)) {
      ownedItemIds.add(itemId);
      await _col('owned').doc('self').set({'ids': ownedItemIds.toList()}, SetOptions(merge: true));
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

  CollectionReference<Map<String, dynamic>> _col(String name) =>
      FirebaseFirestore.instance.collection('users/${_uid ?? 'anonymous'}/$name');

  Task? _findTask(String id) {
    for (final t in tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  bool _isUnlocked(String id) => achievements.any((a) => a.id == id && a.isUnlocked);

  // Keep reactive state in sync with Firestore (multi-device safe).
  void _listen() {
    _subscriptions = [
      _col('prefs').doc('self').snapshots().listen((d) {
        if (d.exists) userPrefs.value = UserPrefs()..mergeFromJsonMap(d.data() ?? {});
      }),
      _col('character').doc('self').snapshots().listen((d) {
        character.value = d.exists ? (Character()..mergeFromJsonMap(d.data() ?? {})) : null;
      }),
      _col('tasks').snapshots().listen((s) {
        tasks.value = s.docs.map((d) => Task()..mergeFromJsonMap(d.data())).toList();
      }),
    ];
  }

  Future<void> _saveCharacter(Character c) async {
    character.value = c;
    await _col('character').doc('self').set(c.writeToJsonMap());
  }

  Future<void> _savePrefs(UserPrefs prefs) async {
    userPrefs.value = prefs;
    await _col('prefs').doc('self').set(prefs.writeToJsonMap());
  }

  Future<void> _unlockAchievement(Achievement def) async {
    final unlocked = def.rebuild(
      (a) => a
        ..isUnlocked = true
        ..progress = def.threshold
        ..unlockedAt = Int64(DateTime.now().millisecondsSinceEpoch),
    );
    await _col('achievements').doc(unlocked.id).set(unlocked.writeToJsonMap());
    if (unlocked.gemReward > 0) {
      final prefs = userPrefs.value ?? UserPrefs();
      await _savePrefs(GameLogic.addGems(prefs, unlocked.gemReward.toInt()));
    }
    achievements.value = [unlocked, ...achievements.where((a) => a.id != unlocked.id)];
  }
}
