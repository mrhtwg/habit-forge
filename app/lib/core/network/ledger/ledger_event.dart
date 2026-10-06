/// Append-only game ledger (`docs/data-ledger-plan.md` §6).
///
/// The plan's rule, in one line: **余额是缓存，流水是真相。任何改动余额的代码，
/// 必须同时落一条流水** — every write that changes EXP / gold / gems / HP must
/// append exactly one row here, in the same atomic operation as the balance
/// update, and rows are never changed or deleted afterwards (the Firestore rules
/// enforce append-only, see `firebase/firestore.rules`).
///
/// Field names match the plan's §6.2 table exactly so a future server-side
/// recompute and the web console see the same schema.
library;

import 'package:habit_forge_app/core/network/hive/game_constants.dart';

/// Structure version of a ledger row. Bump only together with a migration:
/// the rules pin this value, so a mismatched client fails loudly instead of
/// writing rows a future reader cannot interpret.
const int kLedgerSchemaVersion = 1;

/// Event types — the closed list from plan §6.3 ("第一版就这些，别多写").
enum LedgerEventType {
  /// First row of a ledger: the balance snapshot the ledger starts from.
  openingBalance('opening_balance'),

  /// A task was completed: +EXP, +gold (and the level-up heal shows up as +HP).
  taskCompleted('task_completed'),

  /// A **negative habit** was logged ("I slipped"): −HP and no rewards at all.
  ///
  /// Not part of the plan's original §6.3 list — it is the ledger side of the
  /// negative-habit feature, and it has to be its own type because a
  /// `task_completed` row with negative HP and zero rewards would read as a bug
  /// to anyone auditing the books.
  habitSlipped('habit_slipped'),

  /// A device (guest) save was merged into this account (`ProgressMergeService`).
  ///
  /// One row carrying the deltas that were actually applied, so the books stay
  /// additive even though the merged progress came from a save with its own
  /// history. Deltas are always against what this device already contributed, so
  /// re-merging the same device adds nothing.
  accountMerged('account_merged'),

  /// Missed dailies were settled: −HP.
  dailyPenalty('daily_penalty'),

  /// Death recovery: HP back to the class recovery value.
  revive('revive'),

  /// Shop purchase: −gold or −gems, +item.
  purchase('purchase'),

  /// One attribute point spent (no currency moves; recorded so a replay can
  /// verify the stat total).
  statAllocated('stat_allocated'),

  /// An achievement unlocked, paying out gems.
  achievementUnlocked('achievement_unlocked');

  const LedgerEventType(this.wire);

  /// Value stored in the row's `type` field.
  final String wire;

  static LedgerEventType? fromWire(Object? raw) {
    for (final type in values) {
      if (type.wire == raw) return type;
    }
    return null;
  }
}

/// Hard bounds for a single row's deltas.
///
/// The plan asks for absolute caps so that "写一条 +999999" needs to actively
/// bypass the rules (§6.5). The numbers below are derived from the shipped
/// content — they must never reject a legitimate action, because a rejected row
/// aborts the whole atomic write and would break the game action itself:
///
///  - gold: dearest shop item is 1 400 gold; the richest task reward is
///    `20 base × 2.0 streak × STR bonus` ≈ 90.
///  - gems: dearest gem item is 120; the largest achievement payout is 10.
///  - hp: the daily penalty settles a whole day at once, and the applied delta
///    can never exceed the HP cap itself (damage clamps at 0 HP), i.e. 100 +
///    2 × VIT.
///  - exp: `50 base × 2.0 streak × INT bonus` ≈ 210.
///
/// `opening_balance` is exempt from the per-event caps — it snapshots whatever a
/// long-lived save already holds — and gets its own, far larger bound instead.
class LedgerLimits {
  LedgerLimits._();

  static const int exp = 1000;
  static const int gold = 2000;
  static const int gems = 500;
  static const int hp = 500;
  static const int openingBalance = 10000000;
  static const int refKeys = 8;
  static const int maxIdLength = 200;
}

/// One immutable ledger row ("只增不改不删").
class LedgerEvent {
  const LedgerEvent({
    required this.eventId,
    required this.type,
    required this.at,
    required this.localDate,
    this.exp = 0,
    this.gold = 0,
    this.gems = 0,
    this.hp = 0,
    this.taskId = '',
    this.itemId = '',
    this.refs = const <String, Object>{},
    this.rulesVersion = GameConstants.rulesVersion,
    this.schemaVersion = kLedgerSchemaVersion,
  });

  /// Idempotency id — decided by the event itself, never random (plan §6.4).
  /// Build it with the `*Id` helpers below; re-writing the same row is then a
  /// no-op (`set` on a deterministic document id).
  final String eventId;

  final LedgerEventType type;

  /// Client timestamp in milliseconds.
  final int at;

  /// Client-local date, `YYYY-MM-DD`. Stored now so a future server can settle
  /// by the *user's* timezone (plan §10.5).
  final String localDate;

  /// Deltas of this row — never the resulting balance, so every row can be
  /// validated on its own during a replay.
  final int exp;
  final int gold;
  final int gems;
  final int hp;

  final String taskId;
  final String itemId;

  /// Extra context (`slot`, `achievementId`, `discountPercent`, …).
  final Map<String, Object> refs;

  /// Formula version (`GameConstants.rulesVersion`) that produced this row.
  final String rulesVersion;

  final int schemaVersion;

  bool get isOpeningBalance => type == LedgerEventType.openingBalance;

  /// True when nothing about the balance changed (used to skip pure bookkeeping
  /// rows, e.g. a penalty day that dealt no damage).
  bool get isZeroDelta => exp == 0 && gold == 0 && gems == 0 && hp == 0;

  /// Firestore payload. Plain Dart `int`s on purpose: no `Int64`, so the numbers
  /// are stored as Firestore numbers and the security rules can range-check them.
  Map<String, dynamic> toMap() => <String, dynamic>{
        'eventId': eventId,
        'type': type.wire,
        'at': at,
        'localDate': localDate,
        'exp': exp,
        'gold': gold,
        'gems': gems,
        'hp': hp,
        'taskId': taskId,
        'itemId': itemId,
        'refs': Map<String, Object>.from(refs),
        'rulesVersion': rulesVersion,
        'schemaVersion': schemaVersion,
      };

  /// Parses a stored row; returns null when the row is not a valid ledger row
  /// (unknown type, wrong shape) so the reconciliation tool can report it
  /// instead of crashing.
  static LedgerEvent? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final type = LedgerEventType.fromWire(raw['type']);
    final eventId = raw['eventId'];
    final localDate = raw['localDate'];
    if (type == null || eventId is! String || localDate is! String) return null;
    final refs = <String, Object>{};
    final rawRefs = raw['refs'];
    if (rawRefs is Map) {
      for (final entry in rawRefs.entries) {
        final value = entry.value;
        if (value is String || value is num) refs['${entry.key}'] = value as Object;
      }
    }
    return LedgerEvent(
      eventId: eventId,
      type: type,
      at: _asInt(raw['at']),
      localDate: localDate,
      exp: _asInt(raw['exp']),
      gold: _asInt(raw['gold']),
      gems: _asInt(raw['gems']),
      hp: _asInt(raw['hp']),
      taskId: raw['taskId'] is String ? raw['taskId'] as String : '',
      itemId: raw['itemId'] is String ? raw['itemId'] as String : '',
      refs: refs,
      rulesVersion: raw['rulesVersion'] is String ? raw['rulesVersion'] as String : '',
      schemaVersion: _asInt(raw['schemaVersion']),
    );
  }

  static int _asInt(Object? raw) => raw is num ? raw.toInt() : 0;

  /// Non-null reason when this row must not be written.
  ///
  /// The same invariants are enforced by the Firestore rules; keeping them here
  /// too means a bug is caught while the value is still in hand (with a Dart
  /// stack) instead of as an opaque `permission-denied` from the server.
  String? validate() {
    if (eventId.isEmpty) return 'eventId is empty';
    if (eventId.contains('/')) return 'eventId must not contain "/"';
    if (eventId.length > LedgerLimits.maxIdLength) return 'eventId too long';
    if (schemaVersion != kLedgerSchemaVersion) return 'schemaVersion $schemaVersion != $kLedgerSchemaVersion';
    if (rulesVersion.isEmpty) return 'rulesVersion is empty';
    if (at <= 0) return 'at must be a positive timestamp';
    if (!_localDatePattern.hasMatch(localDate)) return 'localDate must be YYYY-MM-DD';
    if (taskId.contains('/') || itemId.contains('/')) return 'taskId/itemId must not contain "/"';
    if (refs.length > LedgerLimits.refKeys) return 'refs has more than ${LedgerLimits.refKeys} keys';
    for (final entry in refs.entries) {
      if (entry.key.isEmpty) return 'refs has an empty key';
      final value = entry.value;
      if (value is! String && value is! num) return 'refs.${entry.key} must be a string or number';
    }
    if (type == LedgerEventType.taskCompleted && taskId.isEmpty) return 'task_completed needs a taskId';
    if (type == LedgerEventType.habitSlipped && taskId.isEmpty) return 'habit_slipped needs a taskId';
    if (type == LedgerEventType.accountMerged) {
      return _withinOpeningBalance() ?? null;
    }
    if (type == LedgerEventType.purchase && itemId.isEmpty) return 'purchase needs an itemId';
    if (isOpeningBalance) {
      return _withinOpeningBalance() ?? null;
    }
    final over = <String>[
      if (exp.abs() > LedgerLimits.exp) 'exp',
      if (gold.abs() > LedgerLimits.gold) 'gold',
      if (gems.abs() > LedgerLimits.gems) 'gems',
      if (hp.abs() > LedgerLimits.hp) 'hp',
    ];
    if (over.isNotEmpty) return 'delta out of range: ${over.join(', ')}';
    return null;
  }

  String? _withinOpeningBalance() {
    final over = <String>[
      if (exp.abs() > LedgerLimits.openingBalance) 'exp',
      if (gold.abs() > LedgerLimits.openingBalance) 'gold',
      if (gems.abs() > LedgerLimits.openingBalance) 'gems',
      if (hp.abs() > LedgerLimits.openingBalance) 'hp',
    ];
    if (over.isNotEmpty) return 'opening balance out of range: ${over.join(', ')}';
    return null;
  }

  static final RegExp _localDatePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  // ── Idempotency ids (plan §6.4) ──

  /// Daily and habit tasks can only be completed once per local day, so
  /// `taskId + localDate` is a natural key: an offline replay on the next day
  /// (or a double tap) maps onto the same row.
  static String taskCompletedId(String taskId, String localDate) => 'complete_${taskId}_$localDate';

  /// A slip is logged at most once per local day (the habit re-arms on rollover,
  /// exactly like a completion), so it uses the same natural key as
  /// [taskCompletedId] under a different prefix.
  static String habitSlippedId(String taskId, String localDate) => 'slip_${taskId}_$localDate';

  /// A purchase retried after a timeout must reuse the same id. The shop allows
  /// owning an item once, so the item id is that key — and unlike a generated
  /// uuid it survives a process restart without extra plumbing.
  static String purchaseId(String itemId) => 'purchase_$itemId';

  /// One penalty row per user per local day (matches `lastPenaltyDate`).
  static String dailyPenaltyId(String uid, String localDate) => 'penalty_${uid}_$localDate';

  /// Keyed by the scheduled recovery moment: re-running the revive is a no-op,
  /// a later death produces a new row.
  static String reviveId(int deathRecoveryUntilMs) => 'revive_$deathRecoveryUntilMs';

  /// Available points only ever decrease, so `pointsBefore + stat` is unique.
  static String statAllocatedId(String uid, int pointsBefore, String stat) => 'stat_${uid}_${pointsBefore}_$stat';

  static String achievementId(String achievementId) => 'achv_$achievementId';

  /// One merge row per device per applied delta set: re-running a merge that
  /// changed nothing produces no row at all, and a later merge that moved a
  /// number again gets a fresh id (so the books never lose the second
  /// adjustment). Two devices therefore never collide.
  static String accountMergedId(String deviceId, int at) => 'merge_${deviceId}_$at';

  static String openingBalanceId(int ledgerStartedAt) => 'opening_balance_$ledgerStartedAt';

  /// `YYYY-MM-DD` of a local timestamp (plan §6.2 `localDate`).
  static String localDateKey(DateTime local) {
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
