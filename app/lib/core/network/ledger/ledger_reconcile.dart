import 'package:habit_forge_app/core/network/hive/game_constants.dart';
import 'package:habit_forge_app/core/network/ledger/ledger_event.dart';

/// The cached balances the ledger must add up to
/// (`docs/data-ledger-plan.md` §8, T5).
///
/// Read straight from the user document (`prefs.current_gold` /
/// `prefs.current_gems`, `character.current_hp` / `current_exp` / `level`), with
/// proto3-JSON strings already coerced to int by [asInt].
class CachedBalance {
  const CachedBalance({
    required this.gold,
    required this.gems,
    required this.hp,
    required this.exp,
    required this.level,
  });

  final int gold;
  final int gems;
  final int hp;

  /// EXP inside the current level (not lifetime EXP).
  final int exp;
  final int level;
}

/// One `expected == actual` comparison.
class BalanceCheck {
  const BalanceCheck({
    required this.field,
    required this.expected,
    required this.actual,
    this.note = '',
  });

  final String field;
  final int expected;
  final int actual;
  final String note;

  bool get ok => expected == actual;
}

/// Result of replaying a ledger against the cached balances.
class LedgerAudit {
  const LedgerAudit({
    required this.checks,
    required this.problems,
    required this.eventCount,
    this.openingBalanceAt,
  });

  final List<BalanceCheck> checks;

  /// Structural problems (missing/duplicate opening row, unreadable rows …).
  final List<String> problems;

  final int eventCount;
  final int? openingBalanceAt;

  bool get balanced => problems.isEmpty && checks.every((c) => c.ok);

  /// Human-readable report, printed by `tool/reconcile_ledger.dart`.
  String describe() {
    final buffer = StringBuffer()
      ..writeln('ledger rows: $eventCount')
      ..writeln(
        openingBalanceAt == null
            ? 'opening_balance: MISSING (rows before the ledger started are unverifiable)'
            : 'ledgerStartedAt: $openingBalanceAt',
      )
      ..writeln('');
    for (final check in checks) {
      final mark = check.ok ? 'ok  ' : 'FAIL';
      buffer.writeln(
        '$mark ${check.field.padRight(6)} expected=${check.expected} actual=${check.actual}'
        '${check.note.isEmpty ? '' : '  (${check.note})'}',
      );
    }
    if (problems.isNotEmpty) {
      buffer.writeln('');
      for (final problem in problems) {
        buffer.writeln('problem: $problem');
      }
    }
    buffer.writeln('');
    buffer.writeln(balanced ? 'BALANCED — opening + Σ rows == cached balance' : 'OUT OF BALANCE');
    return buffer.toString();
  }
}

/// Replays [events] and compares the result with [cached].
///
/// Invariant under test (plan §7.3): `opening_balance + Σ rows == current
/// balance`, exactly. Two fields need care:
///
///  * **EXP** is stored per level, so a level-up *consumes* EXP. The check puts
///    the rows back into lifetime EXP, walks the level curve and compares the
///    derived level and in-level progress. At max level the engine clamps the bar
///    to one level and discards the overflow — the derivation clamps identically,
///    so the comparison stays exact and just carries a note.
///  * **HP** is compared exactly, which only works because every row carries the
///    *applied* delta — the level-up heal included (see `GameLedger`).
///
/// [events] may be raw maps (Firestore export / REST payload already unwrapped
/// to plain JSON) or [LedgerEvent] instances.
LedgerAudit auditLedger({
  required Iterable<Object?> events,
  required CachedBalance cached,
  int? ledgerSeq,
}) {
  final rows = <LedgerEvent>[];
  final problems = <String>[];
  var unreadable = 0;

  for (final raw in events) {
    if (raw is LedgerEvent) {
      rows.add(raw);
      continue;
    }
    final parsed = LedgerEvent.fromMap(raw);
    if (parsed == null) {
      unreadable++;
      continue;
    }
    rows.add(parsed);
  }
  if (unreadable > 0) problems.add('$unreadable row(s) could not be parsed as ledger rows');

  final seen = <String>{};
  for (final row in rows) {
    if (!seen.add(row.eventId)) problems.add('duplicate row id ${row.eventId} (the ledger is append-only)');
  }

  rows.sort((a, b) => a.at.compareTo(b.at));

  final openings = rows.where((r) => r.isOpeningBalance).toList();
  if (openings.length > 1) {
    problems.add('${openings.length} opening_balance rows — a ledger may only be opened once');
  }
  final opening = openings.isEmpty ? null : openings.first;
  if (opening == null && rows.isNotEmpty) {
    problems.add('no opening_balance row: rows written before the ledger started cannot be verified');
  }

  var exp = opening?.exp ?? 0;
  var gold = opening?.gold ?? 0;
  var gems = opening?.gems ?? 0;
  var hp = opening?.hp ?? 0;
  for (final row in rows) {
    if (identical(row, opening)) continue;
    exp += row.exp;
    gold += row.gold;
    gems += row.gems;
    hp += row.hp;
  }

  final derived = deriveProgress(exp);
  final checks = <BalanceCheck>[
    BalanceCheck(field: 'gold', expected: gold, actual: cached.gold),
    BalanceCheck(field: 'gems', expected: gems, actual: cached.gems),
    BalanceCheck(field: 'hp', expected: hp, actual: cached.hp),
    BalanceCheck(
      field: 'level',
      expected: derived.level,
      actual: cached.level,
      note: derived.capped ? 'max level' : '',
    ),
    BalanceCheck(
      field: 'exp',
      expected: derived.inLevelExp,
      actual: cached.exp,
      note:
          derived.capped ? 'max level: the bar stays clamped at one level' : 'in-level EXP after level-up consumption',
    ),
  ];

  if (ledgerSeq != null) {
    checks.add(BalanceCheck(field: 'rows', expected: ledgerSeq, actual: rows.length, note: 'user.ledgerSeq'));
  }

  return LedgerAudit(
    checks: checks,
    problems: problems,
    eventCount: rows.length,
    openingBalanceAt: opening?.at,
  );
}

/// Level and in-level progress for [lifetimeExp], mirroring
/// `GameLogic.gainExp` exactly (including the max-level clamp).
///
/// Thin alias of [GameConstants.progressForLifetimeExp] so the game, the account
/// merge and this audit all read the same curve — kept under this name because it
/// reads better at the call sites below.
({int level, int inLevelExp, bool capped}) deriveProgress(int lifetimeExp) =>
    GameConstants.progressForLifetimeExp(lifetimeExp);

/// Coerces a JSON value to `int`. Firestore's own REST payload encodes integers
/// as strings (`{"integerValue": "5"}`), and proto3 JSON encodes int64 the same
/// way, so both spellings have to be accepted.
int asInt(Object? raw) {
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  if (raw is String) return int.tryParse(raw) ?? 0;
  if (raw is Map) {
    // Firestore REST: {"integerValue": "5"} / {"doubleValue": 5.0}
    final integer = raw['integerValue'] ?? raw['doubleValue'];
    if (integer != null) return asInt(integer);
  }
  return 0;
}

/// Unwraps Firestore's REST encoding (`{"stringValue": …}`, `{"mapValue":
/// {"fields": …}}`, `{"arrayValue": {"values": […]}}`) into plain JSON, so the
/// reconciliation tool can be pointed at an export or at the emulator's REST
/// endpoint without a converter in between. Plain JSON passes through unchanged.
Object? unwrapFirestoreValue(Object? raw) {
  if (raw is! Map) return raw;
  if (raw.containsKey('mapValue')) {
    final fields = (raw['mapValue'] as Map)['fields'];
    return unwrapFirestoreFields(fields);
  }
  if (raw.containsKey('arrayValue')) {
    final values = (raw['arrayValue'] as Map)['values'];
    if (values is! List) return <Object?>[];
    return values.map(unwrapFirestoreValue).toList();
  }
  for (final key in const ['stringValue', 'integerValue', 'doubleValue', 'booleanValue', 'timestampValue']) {
    if (raw.containsKey(key)) return raw[key];
  }
  if (raw.containsKey('nullValue')) return null;
  return raw;
}

/// Unwraps a Firestore REST `fields` map into plain JSON.
Map<String, Object?> unwrapFirestoreFields(Object? fields) {
  final out = <String, Object?>{};
  if (fields is! Map) return out;
  for (final entry in fields.entries) {
    out['${entry.key}'] = unwrapFirestoreValue(entry.value);
  }
  return out;
}
