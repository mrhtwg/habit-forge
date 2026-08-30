import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fixnum/fixnum.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/network_interface.dart';
import 'package:habit_forge_app/core/storage/game_logic.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';
import 'package:uuid/uuid.dart';

/// Firestore-backed storage (firebase mode).
///
/// Game logic runs locally through [GameLogic]; results are persisted per
/// authenticated user in Firestore and mirrored into reactive state.
class NetworkFirebaseImpl implements NetworkInterface {
  final userPrefs = Rxn<UserPrefs>();
  final character = Rxn<Character>();
  final tasks = <Task>[].obs;
  final ownedItemIds = <String>[].obs;
  final achievements = <Achievement>[].obs;
  final dailyDeal = Rxn<DailyDeal>();

  List<StreamSubscription<Object?>> _subscriptions = [];

  @override
  String get authMethod => 'firebase';

  @override
  String? get authToken => null;

  // Firebase manages its own session — auth state derives from FirebaseAuth.

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  Future<void> addGems(int amount) async {
    final prefs = userPrefs.value ?? UserPrefs();
    await _savePrefs(GameLogic.addGems(prefs, amount));
  }

  @override
  Future<void> addGold(int amount) async {
    final prefs = userPrefs.value ?? UserPrefs();
    await _savePrefs(GameLogic.addGold(prefs, amount));
  }

  @override
  Future<bool> allocateStatPoint(StatType stat) async {
    final char = character.value;
    if (char == null || char.availableStatPoints <= 0) return false;
    await _saveCharacter(GameLogic.allocateStat(char, stat));
    return true;
  }

  @override
  Future<TaskCompleteResult> completeTask(Task task) async {
    final completed = GameLogic.completeTask(task);
    await _col('tasks').doc(task.id).set(completed.writeToJsonMap());

    final exp = GameLogic.expReward(task);
    final gold = GameLogic.goldReward(task);

    final prefs = userPrefs.value ?? UserPrefs();
    await _savePrefs(GameLogic.addGold(GameLogic.addCompletedTask(prefs), gold));

    var newLevel = -1;
    final char = character.value;
    if (char != null) {
      final (updated, level) = GameLogic.gainExp(char, exp);
      await _saveCharacter(updated);
      newLevel = level;
    }
    return TaskCompleteResult(expGained: exp, goldGained: gold, newLevel: newLevel > 0 ? newLevel : null);
  }

  // ── Character operations ──
  @override
  Future<ApiResponse<GetCharacterReply>> createCharacter(CharacterClass characterClass) async {
    await _saveCharacter(Character(characterClass: characterClass));
    return ApiResponse.success(GetCharacterReply(character: Character()), 'Character created');
  }

  // ── Task operations ──
  @override
  String createTask(Task task) {
    final id = task.id.isEmpty ? const Uuid().v4() : task.id;
    _col('tasks').doc(id).set((task..id = id).writeToJsonMap()).ignore();
    return id;
  }

  @override
  void deleteTask(String id) {
    _col('tasks').doc(id).delete().ignore();
  }

  @override
  void equipItem(String itemId, {String slot = 'weapon'}) {
    final char = character.value;
    if (char != null) _saveCharacter(GameLogic.equip(char, slot, itemId));
  }

  @override
  Future<NetworkInterface> init() async {
    if (_uid == null) return this;
    await refreshAll();
    _listen();
    return this;
  }

  Future<Character?> loadCharacter() async {
    final char = await _col('character').doc('self').get();
    character.value = char.exists ? (Character()..mergeFromJsonMap(char.data() ?? {})) : null;
    return character.value;
  }

  @override
  void postponeTask(Task task) => updateTask(GameLogic.postpone(task));

  // ── Economy ──
  @override
  Future<bool> purchaseItem(String itemId, int price, {ShopCurrency currency = ShopCurrency.SHOP_CURRENCY_GOLD}) async {
    final prefs = userPrefs.value ?? UserPrefs();
    if (prefs.currentGold < price) return false;
    if (ownedItemIds.contains(itemId)) return false;
    await _savePrefs(GameLogic.addGold(prefs, -price));
    await _addOwnedItem(itemId);
    return true;
  }

  @override
  Future<void> refreshAll() async {
    if (_uid == null) return;

    final prefs = await _col('prefs').doc('self').get();
    userPrefs.value = prefs.exists ? (UserPrefs()..mergeFromJsonMap(prefs.data() ?? {})) : UserPrefs();

    // final char = await _col('character').doc('self').get();
    // character.value = char.exists ? (Character()..mergeFromJsonMap(char.data() ?? {})) : null;

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
    if (char != null && char.isDead) await _saveCharacter(GameLogic.revive(char));
  }

  // ── Auth (Firebase manages its own session) ──
  @override
  void saveAuthToken(String? token) {
    // No local token to store; FirebaseAuth owns the session.
  }

  @override
  void saveDailyDeal(DailyDeal deal) {
    dailyDeal.value = deal;
    _col('shop').doc('dailyDeal').set(deal.writeToJsonMap()).ignore();
  }

  // ── User prefs / deal ──
  @override
  void saveUserPrefs(UserPrefs prefs) {
    userPrefs.value = prefs;
    _col('prefs').doc('self').set(prefs.writeToJsonMap()).ignore();
  }

  @override
  void setLoggedIn(bool value, {String method = ''}) {
    // Login state derives from FirebaseAuth; ignore local calls.
  }

  @override
  void skipTask(Task task) => updateTask(GameLogic.skip(task));

  @override
  Future<void> takeDamage(int amount) async {
    final char = character.value;
    if (char != null) await _saveCharacter(GameLogic.takeDamage(char, amount));
  }

  // ── Achievements ──
  @override
  Future<bool> unlockAchievement(Achievement def) async {
    if (achievements.any((a) => a.id == def.id && a.isUnlocked)) return false;
    final unlocked = def.rebuild(
      (a) => a
        ..isUnlocked = true
        ..unlockedAt = Int64(DateTime.now().millisecondsSinceEpoch),
    );
    await _col('achievements').doc(unlocked.id).set(unlocked.writeToJsonMap());
    if (unlocked.gemReward > 0) {
      await addGems(unlocked.gemReward.toInt());
    }
    return true;
  }

  @override
  void updateTask(Task task) {
    _col('tasks').doc(task.id).set(task.writeToJsonMap()).ignore();
  }

  Future<void> _addOwnedItem(String itemId) async {
    if (!ownedItemIds.contains(itemId)) {
      ownedItemIds.add(itemId);
      await _col('owned').doc('self').set({'ids': ownedItemIds.toList()}, SetOptions(merge: true));
    }
  }

  CollectionReference<Map<String, dynamic>> _col(String name) =>
      FirebaseFirestore.instance.collection('users/${_uid ?? 'anonymous'}/$name');

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

  // ── Internal helpers ──
  Future<void> _savePrefs(UserPrefs prefs) async {
    userPrefs.value = prefs;
    await _col('prefs').doc('self').set(prefs.writeToJsonMap());
  }
}
