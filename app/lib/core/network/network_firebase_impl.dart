import 'package:firebase_auth/firebase_auth.dart' hide UserInfo;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:habit_forge_app/core/extensions/date_extensions.dart';
import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/hive/game_logic.dart';
import 'package:habit_forge_app/core/network/hive/shop_config.dart';
import 'package:habit_forge_app/core/network/ledger/game_ledger.dart';
import 'package:habit_forge_app/core/network/ledger/ledger_event.dart';
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
///
/// ## Ledger (code-review rule — `docs/data-ledger-plan.md` §3.2)
///
/// The numbers under `prefs` (gold, gems) and `character` (level, EXP, HP) are
/// **caches**: they must always equal `opening_balance + Σ users/{uid}/events`.
/// Therefore:
///
/// > **任何改动余额的代码，必须同时落一条流水。**
///
/// Concretely, every write that moves a number goes through [_appendEvents] in
/// the *same* transaction that writes the new balance, and the row's numbers
/// come from [GameLedger] so the recording decision lives in one place. A row
/// without a balance change, or a balance change without a row, is a bug.
/// Rows are append-only, enforced by `firebase/firestore.rules`.
class NetworkFirebaseImpl implements NetworkInterface {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  User? get _user => _auth.currentUser;
  String? get _uid => _user?.uid;

  /// Uid whose ledger we know is open (plan §7 migration already ran), so the
  /// hot paths do not re-read the user document on every call.
  String? _ledgerOpenForUid;

  DocumentReference<Map<String, dynamic>> _userRef() => _db.collection('users').doc(_uid!);

  CollectionReference<Map<String, dynamic>> _tasksCol() => _userRef().collection('tasks');

  CollectionReference<Map<String, dynamic>> _achievementsCol() => _userRef().collection('achievements');

  /// The append-only ledger (plan §6.1). Never updated, never deleted.
  CollectionReference<Map<String, dynamic>> _eventsCol() => _userRef().collection('events');

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

  // ── Ledger plumbing ──

  /// Appends [events] to the ledger **inside the caller's transaction** and
  /// returns the user-document fields to merge into the same `tx.update` call.
  ///
  /// Two plan rules are enforced here, in one place:
  ///  - append-only + deterministic ids: `set` on an id derived from the event
  ///    itself, so a replayed write is a no-op instead of a second row (§6.4);
  ///  - balance and ledger move together: the returned fields join the *same*
  ///    atomic write as the new balance, so a crash or an offline retry can
  ///    never leave one without the other (§10.2, §10.3).
  Map<String, dynamic> _appendEvents(
    Transaction tx,
    Map<String, dynamic>? userData,
    Iterable<LedgerEvent> events,
  ) {
    final rows = events.toList();
    for (final event in rows) {
      final reason = event.validate();
      if (reason != null) {
        // Abort everything: a balance change without its row is exactly the
        // "two sources of truth" failure the ledger exists to prevent (§10.1).
        throw _Biz('Ledger row ${event.eventId} rejected: $reason', StatusCode.internal);
      }
      tx.set(_eventsCol().doc(event.eventId), event.toMap());
    }
    return <String, dynamic>{
      'ledgerSchemaVersion': kLedgerSchemaVersion,
      'ledgerSeq': ((userData?['ledgerSeq'] as num?)?.toInt() ?? 0) + rows.length,
    };
  }

  /// Opens the ledger for a save that predates it (plan §7).
  ///
  /// Writes one `opening_balance` row holding the balance *at that moment* and
  /// pins `ledgerStartedAt` in the same transaction — atomic, so a retry can
  /// never leave two opening rows, and the row id is derived from the start
  /// timestamp it records. Everything before `ledgerStartedAt` is documented as
  /// unverifiable; everything after it must add up exactly.
  ///
  /// Deferred while no character exists: the snapshot has to carry HP, and a
  /// brand-new save creates its character during onboarding.
  Future<void> _ensureLedgerOpen() async {
    final uid = _uid;
    if (uid == null) return;
    if (_ledgerOpenForUid == uid) return;

    final userRef = _userRef();
    final cached = (await userRef.get()).data();
    if (cached == null) return;
    if ((cached['ledgerStartedAt'] as num?)?.toInt() != null) {
      _ledgerOpenForUid = uid;
      return;
    }
    if (_characterFrom(cached) == null) return;

    final now = DateTime.now();
    await _db.runTransaction((tx) async {
      final data = (await tx.get(userRef)).data();
      if (data == null) return;
      if ((data['ledgerStartedAt'] as num?)?.toInt() != null) return;
      final character = _characterFrom(data);
      if (character == null) return;
      final startedAt = now.millisecondsSinceEpoch;
      final opening = GameLedger.openingBalance(
        prefs: _prefsFrom(data),
        character: character,
        now: now,
        ledgerStartedAt: startedAt,
      );
      tx.update(userRef, <String, dynamic>{
        'ledgerStartedAt': startedAt,
        ..._appendEvents(tx, data, <LedgerEvent>[opening]),
      });
    });
    _ledgerOpenForUid = uid;
  }

  // ── Lifecycle ──

  @override
  Future<NetworkInterface> init() async {
    await ShopConfig.load();
    if (_uid != null) {
      await _ensureUserDoc();
      await _ensureLedgerOpen();
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
    await _ensureLedgerOpen();
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
    final now = DateTime.now();
    final today = now.dateOnly.millisecondsSinceEpoch;
    final userRef = _userRef();
    final taskSnaps = await _tasksCol().get();
    final tasks = taskSnaps.docs.map((d) => _fromMap(Task(), d.data())).toList();
    final yesterday = now.dateOnly.subtract(const Duration(days: 1));
    final damage = GameLogic.overduePenalty(tasks, yesterday);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      final data = snap.data();
      if (data == null) return;
      if ((data['lastPenaltyDate'] as num?)?.toInt() == today) return;
      var character = _characterFrom(data);
      final rows = <LedgerEvent>[];
      if (character != null) {
        final settled = GameLogic.applyOverduePenalty(character, damage);
        final hpDelta = settled.currentHp - character.currentHp;
        character = settled;
        // The applied delta (not the raw damage) is what the ledger stores: HP
        // clamps at 0, so the row can never disagree with the balance. A day
        // that dealt no damage still advances lastPenaltyDate, but an all-zero
        // row would only be noise.
        if (hpDelta != 0) {
          rows.add(GameLedger.dailyPenalty(uid: _uid!, hpDelta: hpDelta, now: now));
        }
      }
      tx.update(userRef, <String, dynamic>{
        'lastPenaltyDate': today,
        if (character != null) 'character': _toMap(character),
        ..._appendEvents(tx, data, rows),
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

        final character = GameLogic.newCharacter(characterClass);

        final prefs = _prefsFrom(data)..charactorClass = characterClass;
        tx.update(_userRef(), {
          'character': _toMap(character),
          'prefs': _toMap(prefs),
        });
        return character;
      });
      // The ledger starts from the freshly created hero (full HP), so a new save
      // reconciles from day one instead of showing an unexplained HP jump.
      await _ensureLedgerOpen();
      return ApiResponse.success(CreateCharacterReply(character: created));
    } on _Biz catch (e) {
      return ApiResponse.failure(code: e.code, message: e.message);
    }
  }

  @override
  Future<ApiResponse<GetCharacterReply>> getCharacter() async {
    if (_uid == null) return _unauthenticated();
    final snap = await _userRef().get();
    var character = _characterFrom(snap.data());
    if (character == null) {
      return ApiResponse.failure(code: StatusCode.notFound, message: 'Character not found');
    }
    // One-time class baseline for saves created before classes had stats
    // (idempotent: returns null once the class floor is met). Stats are not a
    // balance and are not part of the ledger's opening snapshot.
    final patched = GameLogic.classBaselinePatch(character);
    if (patched != null) {
      await _userRef().update({'character': _toMap(patched)});
      character = patched;
    }
    await _ensureLedgerOpen();
    return ApiResponse.success(GetCharacterReply(character: character));
  }

  @override
  Future<bool> allocateStatPoint(StatType stat) async {
    if (_uid == null) return false;
    try {
      return await _db.runTransaction((tx) async {
        final snap = await tx.get(_userRef());
        final data = snap.data();
        final char = _characterFrom(data);
        if (char == null || char.availableStatPoints <= 0) return false;
        final now = DateTime.now();
        // No currency moves, but the spend is recorded so a replay can verify the
        // stat total and the level-up that granted the point (§6.3).
        final row = GameLedger.statAllocated(
          uid: _uid!,
          stat: stat,
          pointsBefore: char.availableStatPoints,
          now: now,
        );
        tx.update(_userRef(), <String, dynamic>{
          'character': _toMap(GameLogic.allocateStat(char, stat)),
          ..._appendEvents(tx, data, <LedgerEvent>[row]),
        });
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
      final now = DateTime.now();
      if (now.isBefore(recoveryAt)) return;
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
      final rows = <LedgerEvent>[
        // Keyed by the recovery deadline we are acting on, so re-running this
        // while offline cannot book the revival twice.
        GameLedger.revive(
          character: revived,
          hpDelta: revived.currentHp - char.currentHp,
          deathRecoveryUntilMs: char.deathRecoveryUntil.toInt(),
          now: now,
        ),
        for (final a in fresh) GameLedger.achievementUnlocked(achievement: a, now: now),
      ];
      tx.update(_userRef(), <String, dynamic>{
        'character': _toMap(revived),
        'prefs': _toMap(prefs),
        'unlockedAchievementIds': unlocked.toList(),
        ..._appendEvents(tx, data, rows),
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
        // Equipment changes effective stats, not the balances the ledger tracks
        // (plan §6.3: 装备/卸下 does not produce a row).
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
      // Negative habits are the only tasks whose polarity the player chooses.
      ..isNegative = task.isNegative
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
      t.isNegative = task.isNegative;
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
        final now = DateTime.now();
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

        // A negative habit is a *slip*: nothing is earned and HP is lost
        // (GameLogic.isNegative — the flag only ever applies to habits).
        final isSlip = GameLogic.isNegative(task);
        final gainExp = GameLogic.expReward(task, character);
        final gainGold = GameLogic.goldReward(task, character);
        var prefs = _prefsFrom(data);
        if (!isSlip) {
          // Logging a slip is not a completed task: the wallet and the counters
          // (which feed achievements) must not move.
          prefs = (prefs.deepCopy()..freeze()).rebuild(
            (user) => user
              ..currentGold = user.currentGold + gainGold
              ..todayTasksCompleted = user.todayTasksCompleted + 1
              ..totalTasksCompleted = user.totalTasksCompleted + 1
              ..firstTaskDate =
                  user.firstTaskDate == Int64(0) ? Int64(now.millisecondsSinceEpoch) : user.firstTaskDate,
          );
        }
        var newCharacter = character;
        var leveledTo = -1;
        if (isSlip) {
          newCharacter = GameLogic.applySlip(character, task);
        } else {
          final gained = GameLogic.gainExp(character, gainExp);
          newCharacter = gained.$1;
          leveledTo = gained.$2;
        }
        final newTask = GameLogic.completeTask(task);

        final unlocked = _unlockedFrom(data);
        // A slip moves no counter, no level and no streak, so nothing new can
        // unlock — and it must not pay out gems.
        final fresh = isSlip
            ? const <Achievement>[]
            : GameLogic.newlyUnlocked(
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

        final hpDelta = newCharacter.currentHp - character.currentHp;
        final rows = <LedgerEvent>[
          // One row per task per local day: the id is derived from the task and
          // the date, so a double tap or an offline replay books it once. `hp`
          // carries the applied delta (the level-up heal on a completion, the
          // damage on a slip), which is why rows are built from applied deltas
          // rather than nominal rewards.
          if (isSlip)
            GameLedger.habitSlipped(task: newTask, hpDelta: hpDelta, now: now)
          else
            GameLedger.taskCompleted(
              task: newTask,
              exp: gainExp,
              gold: gainGold,
              hpDelta: hpDelta,
              now: now,
              leveledTo: leveledTo < 0 ? null : leveledTo,
            ),
          for (final a in fresh) GameLedger.achievementUnlocked(achievement: a, now: now),
        ];

        tx.set(taskRef, _toMap(newTask));
        tx.update(userRef, <String, dynamic>{
          'prefs': _toMap(prefs),
          'character': _toMap(newCharacter),
          'unlockedAchievementIds': unlocked.toList(),
          ..._appendEvents(tx, data, rows),
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
    // Charge today's deal price when this item is the deal of the day.
    // Recomputed here rather than taken from the UI, so the charge can never
    // disagree with what the shop showed.
    final deal = ShopConfig.dailyDealFor(_uid ?? 'guest', DateTime.now());
    final price = ShopConfig.effectivePrice(item.price.toInt(), itemId, deal);
    final appliedDiscount = deal.itemId == itemId ? deal.discountPercent : 0;
    try {
      final result = await _db.runTransaction((tx) async {
        final now = DateTime.now();
        final snap = await tx.get(_userRef());
        final data = snap.data();
        if (data == null) throw _Biz('Not signed in', StatusCode.unauthenticated);
        final owned = _ownedFrom(data);
        if (owned.contains(itemId)) throw _Biz('Item already owned', StatusCode.alreadyExists);

        final payWithGems = ShopConfig.currencyOf(itemId) == ShopCurrency.SHOP_CURRENCY_GEMS;
        var prefs = _prefsFrom(data);
        if (payWithGems) {
          if (prefs.currentGems < price) throw _Biz('Not enough gems', StatusCode.failedPrecondition);
          prefs = GameLogic.addGems(prefs, -price);
        } else {
          if (prefs.currentGold < price) throw _Biz('Not enough gold', StatusCode.failedPrecondition);
          prefs = GameLogic.addGold(prefs, -price);
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

        final rows = <LedgerEvent>[
          // The shop allows owning an item once, which makes the item id the
          // natural idempotency key for the purchase row; the discount actually
          // applied is stored so the charged price can be reproduced later.
          GameLedger.purchase(
            itemId: itemId,
            currency: currency,
            price: price,
            discountPercent: appliedDiscount,
            now: now,
          ),
          for (final a in fresh) GameLedger.achievementUnlocked(achievement: a, now: now),
        ];

        tx.update(_userRef(), <String, dynamic>{
          'prefs': _toMap(prefs),
          'ownedItemIds': nextOwned,
          'unlockedAchievementIds': unlocked.toList(),
          ..._appendEvents(tx, data, rows),
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
    return ApiResponse.success(ShopConfig.dailyDealFor(_uid ?? 'guest', DateTime.now()));
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
