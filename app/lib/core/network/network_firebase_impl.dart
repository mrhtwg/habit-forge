import 'package:firebase_auth/firebase_auth.dart' hide UserInfo;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:habit_forge_app/core/extensions/date_extensions.dart';
import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/hive/game_constants.dart';
import 'package:habit_forge_app/core/network/hive/game_logic.dart';
import 'package:habit_forge_app/core/network/hive/shop_config.dart';
import 'package:habit_forge_app/core/network/network_interface.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';
import 'package:habit_forge_app/generated/protos/auth/v1/auth.pb.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';
import 'package:protobuf/protobuf.dart';
import 'package:uuid/uuid.dart';

/// Firestore-backed storage (firebase mode).
///
/// Auth is owned by [FirebaseAuth] (Google Sign-In on Android). Game rules run
/// on-device via [GameLogic] — the same engine as hive — and the resulting
/// state is written under `users/{uid}/...`.
class NetworkFirebaseImpl implements NetworkInterface {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  User? get _user => _auth.currentUser;
  String? get _uid => _user?.uid;

  DocumentReference<Map<String, dynamic>> _userRef() => _db.collection('users').doc(_uid!);

  CollectionReference<Map<String, dynamic>> _tasksCol() => _userRef().collection('tasks');

  CollectionReference<Map<String, dynamic>> _achievementsCol() => _userRef().collection('achievements');

  ApiResponse<T> _unauthenticated<T>() =>
      ApiResponse.failure(code: StatusCode.unauthenticated, message: 'Not signed in');

  // ── Codec ──

  static Map<String, dynamic> _toMap(GeneratedMessage m) => Map<String, dynamic>.from(m.toProto3Json() as Map);

  static T _fromMap<T extends GeneratedMessage>(T empty, Object? raw) {
    if (raw is Map) {
      empty.mergeFromProto3Json(Map<String, dynamic>.from(raw), ignoreUnknownFields: true);
    }
    return empty;
  }

  static UserPrefs _prefsFrom(Map<String, dynamic>? data) => _fromMap(UserPrefs(), data?['prefs']);

  static Character? _characterFrom(Map<String, dynamic>? data) {
    final raw = data?['character'];
    if (raw is! Map) return null;
    return _fromMap(Character(), raw);
  }

  static List<String> _ownedFrom(Map<String, dynamic>? data) {
    final raw = data?['ownedItemIds'];
    if (raw is! List) return <String>[];
    return raw.map((e) => e.toString()).toList();
  }

  static Set<String> _unlockedFrom(Map<String, dynamic>? data) {
    final raw = data?['unlockedAchievementIds'];
    if (raw is! List) return <String>{};
    return raw.map((e) => e.toString()).toSet();
  }

  // ── Lifecycle ──

  @override
  Future<NetworkInterface> init() async {
    await ShopConfig.load();
    if (_uid != null) {
      await _ensureUserDoc();
      await _settleOverduePenalty();
    }
    return this;
  }

  /// Signs the Firebase user into the game layer: persists the ID token,
  /// creates the Firestore user document when missing, and settles daily HP.
  @override
  Future<ApiResponse<LoginReply>> login(String provider) async {
    final user = _user;
    if (user == null) return _unauthenticated();

    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      return ApiResponse.failure(code: StatusCode.internal, message: 'Failed to obtain ID token');
    }
    await UserService.to.setSessionToken(token);
    await _ensureUserDoc();
    await _settleOverduePenalty();

    return ApiResponse.success(
      LoginReply(
        token: token,
        user: UserInfo(
          id: user.uid,
          email: user.email ?? '',
          nickname: user.displayName ?? '',
          avatarUrl: user.photoURL ?? '',
        ),
      ),
      'Signed in',
    );
  }

  Future<void> _ensureUserDoc() async {
    final user = _user;
    if (user == null) return;
    final ref = _userRef();
    final snap = await ref.get();
    if (snap.exists) return;
    await ref.set({
      'email': user.email ?? '',
      'nickname': user.displayName ?? '',
      'avatarUrl': user.photoURL ?? '',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'prefs': _toMap(UserPrefs()),
      'ownedItemIds': <String>[],
      'unlockedAchievementIds': <String>[],
      'lastPenaltyDate': 0,
    });
  }

  Future<void> _settleOverduePenalty() async {
    if (_uid == null) return;
    final today = DateTime.now().dateOnly.millisecondsSinceEpoch;
    final userRef = _userRef();
    final taskSnaps = await _tasksCol().get();
    final tasks = taskSnaps.docs.map((d) => _fromMap(Task(), d.data())).toList();
    final yesterday = DateTime.now().dateOnly.subtract(const Duration(days: 1));
    final damage = GameLogic.overduePenalty(tasks, yesterday);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      final data = snap.data();
      if (data == null) return;
      if ((data['lastPenaltyDate'] as num?)?.toInt() == today) return;
      var character = _characterFrom(data);
      if (character != null && !character.isDead && damage > 0) {
        character = GameLogic.takeDamage(character, damage);
      }
      tx.update(userRef, {
        'lastPenaltyDate': today,
        if (character != null) 'character': _toMap(character),
      });
    });
  }

  Future<void> _rolloverTasks() async {
    if (_uid == null) return;
    final now = DateTime.now();
    final snaps = await _tasksCol().get();
    final batch = _db.batch();
    var writes = 0;
    for (final doc in snaps.docs) {
      final task = _fromMap(Task(), doc.data());
      final reset = GameLogic.rolloverIfNeeded(task, now);
      if (reset == null) continue;
      batch.set(doc.reference, _toMap(reset));
      writes++;
    }
    if (writes > 0) await batch.commit();
  }

  // ── Character ──

  @override
  Future<ApiResponse<CreateCharacterReply>> createCharacter(CharacterClass characterClass) async {
    if (_uid == null) return _unauthenticated();
    try {
      final created = await _db.runTransaction((tx) async {
        final snap = await tx.get(_userRef());
        final data = snap.data();
        if (data == null) throw _Biz('unauthenticated', StatusCode.unauthenticated);
        if (_characterFrom(data) != null) throw _Biz('Character already exists', StatusCode.alreadyExists);

        final character = Character()
          ..id = const Uuid().v4()
          ..characterClass = characterClass
          ..level = 1
          ..currentExp = Int64(0)
          ..currentHp = GameConstants.initialHp
          ..maxExp = Int64(GameConstants.expForLevel(1))
          ..baseStats = CharacterStats()
          ..availableStatPoints = 0
          ..isDead = false;

        final prefs = _prefsFrom(data)..charactorClass = characterClass;
        tx.update(_userRef(), {
          'character': _toMap(character),
          'prefs': _toMap(prefs),
        });
        return character;
      });
      return ApiResponse.success(CreateCharacterReply(character: created));
    } on _Biz catch (e) {
      return ApiResponse.failure(code: e.code, message: e.message);
    }
  }

  @override
  Future<ApiResponse<GetCharacterReply>> getCharacter() async {
    if (_uid == null) return _unauthenticated();
    final snap = await _userRef().get();
    final character = _characterFrom(snap.data());
    if (character == null) {
      return ApiResponse.failure(code: StatusCode.notFound, message: 'Character not found');
    }
    return ApiResponse.success(GetCharacterReply(character: character));
  }

  @override
  Future<bool> allocateStatPoint(StatType stat) async {
    if (_uid == null) return false;
    try {
      return await _db.runTransaction((tx) async {
        final snap = await tx.get(_userRef());
        final char = _characterFrom(snap.data());
        if (char == null || char.availableStatPoints <= 0) return false;
        tx.update(_userRef(), {'character': _toMap(GameLogic.allocateStat(char, stat))});
        return true;
      });
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> reviveCharacter() async {
    if (_uid == null) return;
    await _db.runTransaction((tx) async {
      final snap = await tx.get(_userRef());
      final data = snap.data();
      final char = _characterFrom(data);
      if (char == null || !char.isDead) return;
      final recoveryAt = DateTime.fromMillisecondsSinceEpoch(char.deathRecoveryUntil.toInt());
      if (DateTime.now().isBefore(recoveryAt)) return;
      final revived = GameLogic.revive(char);
      var prefs = _prefsFrom(data);
      final unlocked = _unlockedFrom(data);
      final fresh = GameLogic.newlyUnlocked(
        defs: ShopConfig.achievementDefs,
        unlockedIds: unlocked,
        totalTasks: prefs.totalTasksCompleted.toInt(),
        streak: 0,
        level: revived.level,
        deaths: 1,
      );
      var gems = 0;
      for (final a in fresh) {
        gems += a.gemReward;
        tx.set(_achievementsCol().doc(a.id), _toMap(a));
        unlocked.add(a.id);
      }
      if (gems > 0) prefs = GameLogic.addGems(prefs, gems);
      tx.update(_userRef(), {
        'character': _toMap(revived),
        'prefs': _toMap(prefs),
        'unlockedAchievementIds': unlocked.toList(),
      });
    });
  }

  @override
  Future<ApiResponse<EquipItemReply>> equipItem(String itemId, EquipmentSlot slot) async {
    if (_uid == null) return _unauthenticated();
    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(_userRef());
        final data = snap.data();
        final char = _characterFrom(data);
        if (char == null) throw _Biz('Character not found', StatusCode.notFound);
        final owned = _ownedFrom(data);
        if (itemId.isNotEmpty && !owned.contains(itemId)) {
          throw _Biz('Item not owned', StatusCode.failedPrecondition);
        }
        tx.update(_userRef(), {'character': _toMap(GameLogic.equip(char, GameLogic.slotKey(slot), itemId))});
      });
      return ApiResponse.success(EquipItemReply(), 'Equipped');
    } on _Biz catch (e) {
      return ApiResponse.failure(code: e.code, message: e.message);
    }
  }

  // ── Tasks ──

  @override
  Future<ApiResponse<CreateTaskReply>> createTask(Task task) async {
    if (_uid == null) return _unauthenticated();
    final reason = GameLogic.invalidTaskShape(task);
    if (reason != null) {
      return ApiResponse.failure(code: StatusCode.invalidArgument, message: reason);
    }
    final now = Int64(DateTime.now().millisecondsSinceEpoch);
    final t = Task()
      ..id = const Uuid().v4()
      ..title = task.title
      ..description = task.description
      ..type = task.type
      ..difficulty = task.difficulty
      ..streak = task.streak
      ..customExpReward = task.customExpReward
      ..customGoldReward = task.customGoldReward
      ..priority = task.priority
      ..hpPenalty = task.hpPenalty
      ..createdAt = now
      ..updatedAt = now;
    t.tags.addAll(task.tags);
    if (task.type == TaskType.TASK_TYPE_DAILY) t.repeatDays.addAll(task.repeatDays);
    if (task.type == TaskType.TASK_TYPE_TODO) t.dueDate = task.dueDate;
    await _tasksCol().doc(t.id).set(_toMap(t));
    return ApiResponse.success(CreateTaskReply(task: t));
  }

  @override
  Future<ApiResponse<UpdateTaskReply>> updateTask(String id, Task task) async {
    if (_uid == null) return _unauthenticated();
    final snap = await _tasksCol().doc(id).get();
    if (!snap.exists) {
      return ApiResponse.failure(code: StatusCode.notFound, message: 'Task not found');
    }
    final reason = GameLogic.invalidTaskShape(task);
    if (reason != null) {
      return ApiResponse.failure(code: StatusCode.invalidArgument, message: reason);
    }
    final current = _fromMap(Task(), snap.data());
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
    await _tasksCol().doc(id).set(_toMap(updated));
    return ApiResponse.success(UpdateTaskReply(task: updated));
  }

  @override
  Future<ApiResponse<DeleteTaskReply>> deleteTask(String id) async {
    if (_uid == null) return _unauthenticated();
    await _tasksCol().doc(id).delete();
    return ApiResponse.success(DeleteTaskReply());
  }

  @override
  Future<ApiResponse<ListTasksReply>> listTasks({
    TaskType? type,
    TaskDifficulty? difficulty,
    List<String>? tags,
    bool? onlyDueToday,
  }) async {
    if (_uid == null) return _unauthenticated();
    await _rolloverTasks();
    final snaps = await _tasksCol().get();
    final tasks = snaps.docs.map((d) => _fromMap(Task(), d.data())).where((task) {
      if (type != null && task.type != type) return false;
      if (difficulty != null && task.difficulty != difficulty) return false;
      if (tags != null && !tags.every(task.tags.contains)) return false;
      if (onlyDueToday == true && !GameLogic.isDueOn(task, DateTime.now())) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return ApiResponse.success(ListTasksReply(tasks: tasks));
  }

  @override
  Future<ApiResponse<CompleteTaskReply>> completeTask(String id) async {
    if (_uid == null) return _unauthenticated();
    try {
      final result = await _db.runTransaction((tx) async {
        final taskRef = _tasksCol().doc(id);
        final userRef = _userRef();
        final taskSnap = await tx.get(taskRef);
        final userSnap = await tx.get(userRef);
        if (!taskSnap.exists) throw _Biz('Task not found', StatusCode.notFound);
        final task = _fromMap(Task(), taskSnap.data());
        if (task.isCompleted) throw _Biz('Task already completed', StatusCode.failedPrecondition);

        final data = userSnap.data();
        final character = _characterFrom(data);
        if (character == null) throw _Biz('Character not found', StatusCode.notFound);
        if (character.isDead) throw _Biz('Character is dead — revive first', StatusCode.failedPrecondition);

        final gainExp = GameLogic.expReward(task, character);
        final gainGold = GameLogic.goldReward(task, character);
        var prefs = _prefsFrom(data);
        prefs = (prefs.deepCopy()..freeze()).rebuild(
          (user) => user
            ..currentGold = user.currentGold + gainGold
            ..todayTasksCompleted = user.todayTasksCompleted + 1
            ..totalTasksCompleted = user.totalTasksCompleted + 1
            ..firstTaskDate =
                user.firstTaskDate == Int64(0) ? Int64(DateTime.now().millisecondsSinceEpoch) : user.firstTaskDate,
        );
        final (newCharacter, _) = GameLogic.gainExp(character, gainExp);
        final newTask = GameLogic.completeTask(task);

        final unlocked = _unlockedFrom(data);
        final fresh = GameLogic.newlyUnlocked(
          defs: ShopConfig.achievementDefs,
          unlockedIds: unlocked,
          totalTasks: prefs.totalTasksCompleted.toInt(),
          streak: newTask.streak,
          level: newCharacter.level,
        );
        var gems = 0;
        for (final a in fresh) {
          gems += a.gemReward;
          tx.set(_achievementsCol().doc(a.id), _toMap(a));
          unlocked.add(a.id);
        }
        if (gems > 0) prefs = GameLogic.addGems(prefs, gems);

        tx.set(taskRef, _toMap(newTask));
        tx.update(userRef, {
          'prefs': _toMap(prefs),
          'character': _toMap(newCharacter),
          'unlockedAchievementIds': unlocked.toList(),
        });
        return (task: newTask, prefs: prefs, character: newCharacter, exp: gainExp, gold: gainGold);
      });
      return ApiResponse.success(
        CompleteTaskReply(
          task: result.task,
          prefs: result.prefs,
          character: result.character,
          expReward: result.exp,
          goldReward: result.gold,
        ),
      );
    } on _Biz catch (e) {
      return ApiResponse.failure(code: e.code, message: e.message);
    }
  }

  @override
  Future<ApiResponse<SkipTaskReply>> skipTask(String id) async {
    if (_uid == null) return _unauthenticated();
    final snap = await _tasksCol().doc(id).get();
    if (!snap.exists) {
      return ApiResponse.failure(code: StatusCode.notFound, message: 'Task not found');
    }
    final updated = GameLogic.postpone(_fromMap(Task(), snap.data()));
    await _tasksCol().doc(id).set(_toMap(updated));
    return ApiResponse.success(SkipTaskReply(task: updated));
  }

  // ── User ──

  @override
  Future<ApiResponse<GetPrefsReply>> getPrefs() async {
    if (_uid == null) return _unauthenticated();
    final snap = await _userRef().get();
    return ApiResponse.success(GetPrefsReply(prefs: _prefsFrom(snap.data())));
  }

  // ── Shop ──

  @override
  Future<ApiResponse<ListShopItemsReply>> listShopItems() async {
    await ShopConfig.load();
    return ApiResponse.success(ListShopItemsReply(items: ShopConfig.shopItems));
  }

  @override
  Future<ApiResponse<ListOwnedItemsReply>> listOwnedItems() async {
    if (_uid == null) return _unauthenticated();
    final snap = await _userRef().get();
    return ApiResponse.success(ListOwnedItemsReply(itemIds: _ownedFrom(snap.data())));
  }

  @override
  Future<ApiResponse<BuyItemReply>> purchaseItem(String itemId, ShopCurrency currency) async {
    if (_uid == null) return _unauthenticated();
    final item = ShopConfig.shopItems.where((i) => i.id == itemId).firstOrNull;
    if (item == null) {
      return ApiResponse.failure(code: StatusCode.notFound, message: 'Item not found');
    }
    try {
      final result = await _db.runTransaction((tx) async {
        final snap = await tx.get(_userRef());
        final data = snap.data();
        if (data == null) throw _Biz('Not signed in', StatusCode.unauthenticated);
        final owned = _ownedFrom(data);
        if (owned.contains(itemId)) throw _Biz('Item already owned', StatusCode.alreadyExists);

        final payWithGems = ShopConfig.currencyOf(itemId) == ShopCurrency.SHOP_CURRENCY_GEMS;
        var prefs = _prefsFrom(data);
        if (payWithGems) {
          if (prefs.currentGems < item.price) throw _Biz('Not enough gems', StatusCode.failedPrecondition);
          prefs = GameLogic.addGems(prefs, -item.price.toInt());
        } else {
          if (prefs.currentGold < item.price) throw _Biz('Not enough gold', StatusCode.failedPrecondition);
          prefs = GameLogic.addGold(prefs, -item.price.toInt());
        }

        final nextOwned = [...owned, itemId];
        final unlocked = _unlockedFrom(data);
        final fresh = GameLogic.newlyUnlocked(
          defs: ShopConfig.achievementDefs,
          unlockedIds: unlocked,
          totalTasks: prefs.totalTasksCompleted.toInt(),
          streak: 0,
          level: _characterFrom(data)?.level ?? 1,
          purchases: nextOwned.length,
        );
        var gems = 0;
        for (final a in fresh) {
          gems += a.gemReward;
          tx.set(_achievementsCol().doc(a.id), _toMap(a));
          unlocked.add(a.id);
        }
        if (gems > 0) prefs = GameLogic.addGems(prefs, gems);

        tx.update(_userRef(), {
          'prefs': _toMap(prefs),
          'ownedItemIds': nextOwned,
          'unlockedAchievementIds': unlocked.toList(),
        });
        final balance = payWithGems ? prefs.currentGems : prefs.currentGold;
        return (item: item, balance: balance);
      });
      return ApiResponse.success(BuyItemReply(item: result.item, balance: result.balance));
    } on _Biz catch (e) {
      return ApiResponse.failure(code: e.code, message: e.message);
    }
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

  // ── Achievements ──

  @override
  Future<ApiResponse<ListAchievementsReply>> listAchievements() async {
    if (_uid == null) return _unauthenticated();
    await ShopConfig.load();
    final snaps = await _achievementsCol().get();
    final unlocked = {for (final d in snaps.docs) d.id: _fromMap(Achievement(), d.data())};
    final merged = <Achievement>[
      for (final def in ShopConfig.achievementDefs) unlocked[def.id] ?? def,
    ];
    return ApiResponse.success(ListAchievementsReply(achievements: merged));
  }
}

class _Biz implements Exception {
  final String message;
  final int code;
  _Biz(this.message, this.code);
}
