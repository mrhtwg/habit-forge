import 'package:flutter_test/flutter_test.dart';
import 'package:habit_forge_app/core/network/hive/game_constants.dart';
import 'package:habit_forge_app/core/network/ledger/ledger_event.dart';
import 'package:habit_forge_app/core/network/ledger/ledger_reconcile.dart';

/// T5 of the plan: "opening_balance + 全部流水 == 当前余额, 误差 0".
///
/// These tests are the specification of what "balanced" means — including the
/// two fields that are not a simple sum: EXP is consumed by level-ups, and HP
/// only adds up because every row stores the delta that was *applied*.
void main() {
  group('balanced ledgers', () {
    test('gold, gems and hp are a straight sum over the rows', () {
      final audit = auditLedger(
        events: [
          _opening(gold: 100, gems: 5, hp: 100),
          _task(exp: 30, gold: 10, hpDelta: 20),
          _purchase(gold: -350, gems: 0),
          _achievement(gems: 5),
          _penalty(hp: -30),
        ],
        cached: const CachedBalance(gold: -240, gems: 10, hp: 90, exp: 30, level: 1),
      );
      expect(audit.problems, isEmpty);
      expect(audit.balanced, isTrue, reason: audit.describe());
      expect(audit.eventCount, 5);
      expect(audit.openingBalanceAt, _openingAt);
    });

    test('a level-up is handled through the level curve, not by adding EXP blindly', () {
      // 90 + 15 = 105 lifetime EXP: level 1 costs 100, so the hero is level 2
      // with 5 EXP on the bar — and the level-up heal is inside the row.
      final audit = auditLedger(
        events: [_opening(exp: 90, hp: 100), _task(exp: 15, gold: 5, hpDelta: 20)],
        cached: const CachedBalance(gold: 5, gems: 0, hp: 120, exp: 5, level: 2),
      );
      expect(audit.balanced, isTrue, reason: audit.describe());
    });

    test('a full bar at max level still reconciles', () {
      // Walk to level 50, fill the bar, then keep earning: the engine clamps the
      // bar at one level and the derivation clamps identically — so the check
      // stays exact instead of degrading into a guess.
      var lifetime = 0;
      for (var level = 1; level < GameConstants.maxLevel; level++) {
        lifetime += GameConstants.expForLevel(level);
      }
      final fullBar = lifetime + GameConstants.expForLevel(GameConstants.maxLevel);
      final audit = auditLedger(
        events: [_opening(exp: fullBar, hp: 100), _task(exp: 1000, gold: 20, hpDelta: 0)],
        cached: CachedBalance(
          gold: 20,
          gems: 0,
          hp: 100,
          exp: GameConstants.expForLevel(GameConstants.maxLevel),
          level: GameConstants.maxLevel,
        ),
      );
      expect(audit.balanced, isTrue, reason: audit.describe());
      expect(audit.checks.firstWhere((c) => c.field == 'exp').note, contains('max level'));
    });

    test('rows that were written by the client validate through the audit', () {
      final row = _task(exp: 30, gold: 10, hpDelta: 0).toMap();
      expect(row['eventId'], isNotNull);
      final audit = auditLedger(
        events: [_opening(gold: 10, hp: 100).toMap(), row],
        cached: const CachedBalance(gold: 20, gems: 0, hp: 100, exp: 30, level: 1),
      );
      expect(audit.balanced, isTrue, reason: audit.describe());
    });
  });

  group('detection', () {
    test('a missing reward row shows up as a gold mismatch', () {
      final audit = auditLedger(
        events: [_opening(gold: 100, hp: 100), _task(exp: 30, gold: 10, hpDelta: 0)],
        cached: const CachedBalance(gold: 120, gems: 0, hp: 100, exp: 30, level: 1),
      );
      expect(audit.balanced, isFalse);
      final gold = audit.checks.firstWhere((c) => c.field == 'gold');
      expect(gold.expected, 110);
      expect(gold.actual, 120);
      expect(audit.describe(), contains('OUT OF BALANCE'));
    });

    test('an unexplained HP change is caught', () {
      final audit = auditLedger(
        events: [_opening(hp: 100)],
        cached: const CachedBalance(gold: 0, gems: 0, hp: 110, exp: 0, level: 1),
      );
      expect(audit.checks.firstWhere((c) => c.field == 'hp').ok, isFalse);
    });

    test('a ledger without an opening row is flagged, not silently trusted', () {
      final audit = auditLedger(
        events: [_task(exp: 30, gold: 10, hpDelta: 0)],
        cached: const CachedBalance(gold: 10, gems: 0, hp: 0, exp: 30, level: 1),
      );
      expect(audit.problems.single, contains('no opening_balance row'));
      expect(audit.balanced, isFalse);
    });

    test('a duplicated row id is detected (the ledger is append-only)', () {
      final row = _task(exp: 30, gold: 10, hpDelta: 0);
      final audit = auditLedger(
        events: [_opening(gold: 10, hp: 0), row, row],
        cached: const CachedBalance(gold: 20, gems: 0, hp: 0, exp: 30, level: 1),
      );
      expect(audit.problems.single, contains('duplicate row id'));
      expect(audit.eventCount, 3);
    });

    test('a second opening row is detected', () {
      final audit = auditLedger(
        events: [_opening(gold: 10), _opening(gold: 20, at: _openingAt + 1)],
        cached: const CachedBalance(gold: 20, gems: 0, hp: 0, exp: 0, level: 1),
      );
      expect(audit.problems.single, contains('opening_balance rows'));
    });

    test('unreadable rows are reported instead of crashing the tool', () {
      final audit = auditLedger(
        events: [
          _opening(gold: 10),
          {'type': 'free_gold', 'eventId': 'x', 'localDate': '2026-09-29'},
        ],
        cached: const CachedBalance(gold: 10, gems: 0, hp: 0, exp: 0, level: 1),
      );
      expect(audit.problems.single, contains('could not be parsed'));
      expect(audit.eventCount, 1);
    });

    test('ledgerSeq is cross-checked against the number of rows', () {
      final audit = auditLedger(
        events: [_opening(gold: 10)],
        cached: const CachedBalance(gold: 10, gems: 0, hp: 0, exp: 0, level: 1),
        ledgerSeq: 4,
      );
      expect(audit.checks.firstWhere((c) => c.field == 'rows').ok, isFalse);
      expect(audit.balanced, isFalse);
    });
  });

  group('level curve', () {
    test('agrees with GameConstants.calculateLevel across the curve', () {
      for (var lifetime = 0; lifetime <= 4000; lifetime += 37) {
        expect(deriveProgress(lifetime).level, GameConstants.calculateLevel(lifetime), reason: 'lifetime $lifetime');
      }
    });

    test('the first level boundary is exact', () {
      expect(deriveProgress(0), (level: 1, inLevelExp: 0, capped: false));
      expect(deriveProgress(99), (level: 1, inLevelExp: 99, capped: false));
      expect(deriveProgress(100), (level: 2, inLevelExp: 0, capped: false));
      expect(deriveProgress(100 + GameConstants.expForLevel(2)), (level: 3, inLevelExp: 0, capped: false));
    });
  });

  group('input coercion (exports and REST payloads)', () {
    test('asInt accepts the encodings Firestore and proto3 JSON use', () {
      expect(asInt(5), 5);
      expect(asInt('5'), 5);
      expect(asInt(5.0), 5);
      expect(asInt({'integerValue': '5'}), 5);
      expect(asInt(null), 0);
      expect(asInt('not a number'), 0);
    });

    test('unwrapFirestoreValue flattens the REST encoding', () {
      final wrapped = {
        'mapValue': {
          'fields': {
            'gold': {'integerValue': '42'},
            'localDate': {'stringValue': '2026-09-29'},
            'refs': {
              'mapValue': {
                'fields': {
                  'streak': {'integerValue': '3'},
                },
              },
            },
          },
        },
      };
      final unwrapped = unwrapFirestoreValue(wrapped)! as Map;
      expect(unwrapped['gold'], '42');
      expect(unwrapped['localDate'], '2026-09-29');
      expect((unwrapped['refs']! as Map)['streak'], '3');
    });
  });
}

const int _openingAt = 1700000000000;

LedgerEvent _opening({int exp = 0, int gold = 0, int gems = 0, int hp = 0, int at = _openingAt}) => LedgerEvent(
      eventId: LedgerEvent.openingBalanceId(at),
      type: LedgerEventType.openingBalance,
      at: at,
      localDate: '2026-09-29',
      exp: exp,
      gold: gold,
      gems: gems,
      hp: hp,
      refs: const {'note': 'pre-ledger snapshot'},
    );

LedgerEvent _task({required int exp, required int gold, required int hpDelta, int at = _openingAt + 1000}) => LedgerEvent(
      eventId: 'complete_t1_2026-09-29',
      type: LedgerEventType.taskCompleted,
      at: at,
      localDate: '2026-09-29',
      exp: exp,
      gold: gold,
      hp: hpDelta,
      taskId: 't1',
    );

LedgerEvent _purchase({required int gold, required int gems}) => LedgerEvent(
      eventId: 'purchase_sword_flame',
      type: LedgerEventType.purchase,
      at: _openingAt + 2000,
      localDate: '2026-09-29',
      gold: gold,
      gems: gems,
      itemId: 'sword_flame',
    );

LedgerEvent _achievement({required int gems}) => LedgerEvent(
      eventId: 'achv_streak_7',
      type: LedgerEventType.achievementUnlocked,
      at: _openingAt + 3000,
      localDate: '2026-09-29',
      gems: gems,
    );

LedgerEvent _penalty({required int hp}) => LedgerEvent(
      eventId: 'penalty_u1_2026-09-29',
      type: LedgerEventType.dailyPenalty,
      at: _openingAt + 4000,
      localDate: '2026-09-29',
      hp: hp,
    );
