import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_forge_app/core/network/hive/game_constants.dart';
import 'package:habit_forge_app/core/network/hive/shop_config.dart';
import 'package:habit_forge_app/core/network/ledger/game_ledger.dart';
import 'package:habit_forge_app/core/network/ledger/ledger_event.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pbenum.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:yaml/yaml.dart';

/// The ledger row is the contract between three places that must agree: the
/// Dart writer, the Firestore rules and the future server-side replay. These
/// tests pin the parts that are cheap to get wrong and expensive to discover
/// later: idempotency ids, the caps, and the payload shape.
void main() {
  group('idempotency ids (plan §6.4)', () {
    test('are derived from the event, so a replay is a no-op', () {
      expect(LedgerEvent.taskCompletedId('t1', '2026-09-29'), 'complete_t1_2026-09-29');
      expect(LedgerEvent.purchaseId('sword_flame'), 'purchase_sword_flame');
      expect(LedgerEvent.dailyPenaltyId('u1', '2026-09-29'), 'penalty_u1_2026-09-29');
      expect(LedgerEvent.reviveId(1700000000000), 'revive_1700000000000');
      expect(LedgerEvent.statAllocatedId('u1', 3, 'strength'), 'stat_u1_3_strength');
      expect(LedgerEvent.achievementId('streak_7'), 'achv_streak_7');
      expect(LedgerEvent.openingBalanceId(42), 'opening_balance_42');
    });

    test('repeat completions on different days get different rows', () {
      expect(
        LedgerEvent.taskCompletedId('t1', '2026-09-29'),
        isNot(LedgerEvent.taskCompletedId('t1', '2026-09-30')),
      );
    });

    test('localDateKey is a zero-padded local date', () {
      expect(LedgerEvent.localDateKey(DateTime(2026, 1, 5, 23, 59)), '2026-01-05');
      expect(LedgerEvent.localDateKey(DateTime(2026, 12, 31)), '2026-12-31');
    });
  });

  group('caps never reject legitimate content', () {
    test('every shipped shop price fits its currency cap', () {
      final doc = loadYaml(File('assets/config/config.yml').readAsStringSync()) as YamlMap;
      final items = doc['equipment'] as YamlList;
      expect(items, isNotEmpty);
      for (final raw in items) {
        final item = raw as YamlMap;
        final price = item['price'] as int;
        final gems = '${item['currency'] ?? 'gold'}' == 'gems';
        final cap = gems ? LedgerLimits.gems : LedgerLimits.gold;
        expect(price, lessThanOrEqualTo(cap), reason: '${item['id']} costs $price, cap $cap');
      }
    });

    test('every shipped achievement payout fits the gem cap', () {
      final doc = loadYaml(File('assets/config/config.yml').readAsStringSync()) as YamlMap;
      for (final raw in doc['achievement_defs'] as YamlList) {
        final reward = (raw as YamlMap)['gem_reward'] as int? ?? 0;
        expect(reward, lessThanOrEqualTo(LedgerLimits.gems));
      }
    });

    test('the built-in shop fallback fits too (used when config.yml is missing)', () {
      expect(ShopConfig.shopItems, isNotEmpty);
      for (final item in ShopConfig.shopItems) {
        final cap = ShopConfig.currencyOf(item.id) == ShopCurrency.SHOP_CURRENCY_GEMS
            ? LedgerLimits.gems
            : LedgerLimits.gold;
        expect(item.price.toInt(), lessThanOrEqualTo(cap), reason: item.id);
      }
      for (final def in ShopConfig.achievementDefs) {
        expect(def.gemReward, lessThanOrEqualTo(LedgerLimits.gems));
      }
    });

    test('one day of missed dailies cannot exceed the hp cap', () {
      // The applied delta is bounded by the character's HP cap (damage clamps at
      // 0 HP), and the cap grows with VIT — 7 base + 49 level points is the
      // reachable ceiling before equipment.
      const highestReachableVitality = 7 + GameConstants.maxLevel + 40;
      expect(
        GameConstants.maxHpFor(highestReachableVitality),
        lessThanOrEqualTo(LedgerLimits.hp),
        reason: 'a legitimate penalty settlement must never be rejected',
      );
    });

    test('the richest possible task reward fits the exp and gold caps', () {
      // base 50 × streak cap 2.0 × (+1% per point of the effective stat).
      const highestReachableStat = 7 + GameConstants.maxLevel + 40;
      final richestExp = (GameConstants.baseExpReward(TaskDifficulty.TASK_DIFFICULTY_HARD) *
              2.0 *
              (1 + highestReachableStat * 0.01))
          .round();
      final richestGold = (GameConstants.baseGoldReward(TaskDifficulty.TASK_DIFFICULTY_HARD) *
              2.0 *
              (1 + highestReachableStat * 0.01))
          .round();
      expect(richestExp, lessThanOrEqualTo(LedgerLimits.exp));
      expect(richestGold, lessThanOrEqualTo(LedgerLimits.gold));
    });
  });

  group('validation', () {
    test('accepts a well-formed row', () {
      expect(_row().validate(), isNull);
    });

    test('rejects a delta above the cap', () {
      expect(_row(gold: LedgerLimits.gold + 1).validate(), contains('out of range'));
      expect(_row(exp: -(LedgerLimits.exp + 1)).validate(), contains('out of range'));
    });

    test('opening_balance is exempt from the per-event caps but not unbounded', () {
      final opening = _row(type: LedgerEventType.openingBalance, gold: 500000, exp: 90000);
      expect(opening.validate(), isNull);
      expect(
        _row(type: LedgerEventType.openingBalance, gold: LedgerLimits.openingBalance + 1).validate(),
        contains('opening balance out of range'),
      );
    });

    test('rejects rows whose id cannot be a document id, or that mismatch the event', () {
      expect(_row(eventId: 'bad/id').validate(), contains('"/"'));
      expect(_row(eventId: '').validate(), contains('empty'));
      expect(_row(type: LedgerEventType.taskCompleted, taskId: '').validate(), contains('taskId'));
      expect(_row(type: LedgerEventType.purchase, itemId: '').validate(), contains('itemId'));
    });

    test('rejects a malformed localDate, timestamp or schema version', () {
      expect(_row(localDate: '29/09/2026').validate(), contains('YYYY-MM-DD'));
      expect(_row(at: 0).validate(), contains('positive timestamp'));
      expect(_row(schemaVersion: 99).validate(), contains('schemaVersion'));
    });

    test('refs stays small and machine-readable', () {
      expect(_row(refs: {for (var i = 0; i <= LedgerLimits.refKeys; i++) 'k$i': i}).validate(), contains('refs'));
      expect(_row(refs: {'note': Object()}).validate(), contains('string or number'));
      expect(_row(refs: {'note': 'snapshot', 'at': 5}).validate(), isNull);
    });
  });

  group('payload', () {
    test('round-trips through the Firestore map', () {
      final row = _row(refs: {'taskType': 'daily', 'streak': 3});
      final parsed = LedgerEvent.fromMap(row.toMap());
      expect(parsed, isNotNull);
      expect(parsed!.eventId, row.eventId);
      expect(parsed.type, row.type);
      expect(parsed.exp, row.exp);
      expect(parsed.gold, row.gold);
      expect(parsed.gems, row.gems);
      expect(parsed.hp, row.hp);
      expect(parsed.localDate, row.localDate);
      expect(parsed.refs['streak'], 3);
      expect(parsed.schemaVersion, kLedgerSchemaVersion);
    });

    test('stores plain numbers, never Int64 wrappers', () {
      // The rules range-check the numbers, and Firestore rejects unknown types.
      for (final value in _row().toMap().values) {
        expect(value, isNot(isA<Int64>()));
      }
    });

    test('fromMap returns null instead of throwing on junk', () {
      expect(LedgerEvent.fromMap(null), isNull);
      expect(LedgerEvent.fromMap('nope'), isNull);
      expect(LedgerEvent.fromMap({'type': 'free_gold', 'eventId': 'x', 'localDate': '2026-09-29'}), isNull);
    });
  });

  group('GameLedger factories', () {
    test('a completion row carries the awarded exp/gold and the applied hp delta', () {
      final task = Task()
        ..id = 't1'
        ..type = TaskType.TASK_TYPE_DAILY
        ..difficulty = TaskDifficulty.TASK_DIFFICULTY_HARD
        ..streak = 10;
      final now = DateTime(2026, 9, 29, 9);
      final row = GameLedger.taskCompleted(task: task, exp: 44, gold: 21, hpDelta: 20, now: now, leveledTo: 3);
      expect(row.type, LedgerEventType.taskCompleted);
      expect(row.eventId, LedgerEvent.taskCompletedId('t1', '2026-09-29'));
      expect(row.taskId, 't1');
      expect(row.exp, 44);
      expect(row.gold, 21);
      expect(row.hp, 20);
      expect(row.refs['taskType'], 'daily');
      expect(row.refs['difficulty'], 'hard');
      expect(row.refs['streak'], 10);
      expect(row.refs['leveledTo'], 3);
      expect(row.validate(), isNull);
    });

    test('a purchase row charges the currency that was used', () {
      final now = DateTime(2026, 9, 29);
      final gold = GameLedger.purchase(
        itemId: 'sword_flame',
        currency: ShopCurrency.SHOP_CURRENCY_GOLD,
        price: 350,
        discountPercent: 30,
        now: now,
      );
      expect(gold.gold, -350);
      expect(gold.gems, 0);
      expect(gold.refs['discountPercent'], 30);
      expect(gold.eventId, 'purchase_sword_flame');

      final gems = GameLedger.purchase(
        itemId: 'armor_void',
        currency: ShopCurrency.SHOP_CURRENCY_GEMS,
        price: 90,
        discountPercent: 0,
        now: now,
      );
      expect(gems.gold, 0);
      expect(gems.gems, -90);
      expect(gems.validate(), isNull);
    });

    test('the opening row snapshots the cached balance', () {
      final prefs = UserPrefs()
        ..currentGold = Int64(1234)
        ..currentGems = Int64(7);
      final character = Character()
        ..level = 6
        ..currentExp = Int64(42)
        ..currentHp = 88;
      final row = GameLedger.openingBalance(
        prefs: prefs,
        character: character,
        now: DateTime(2026, 9, 29),
        ledgerStartedAt: 1700000000000,
      );
      expect(row.isOpeningBalance, isTrue);
      expect(row.eventId, 'opening_balance_1700000000000');
      expect(row.at, 1700000000000);
      expect(row.gold, 1234);
      expect(row.gems, 7);
      expect(row.exp, 42);
      expect(row.hp, 88);
      expect(row.refs['note'], 'pre-ledger snapshot');
      expect(row.validate(), isNull);
    });

    test('an achievement row pays the gems the definition declares', () {
      final def = Achievement()
        ..id = 'streak_30'
        ..conditionType = 'streak'
        ..threshold = 30
        ..gemReward = 10;
      final row = GameLedger.achievementUnlocked(achievement: def, now: DateTime(2026, 9, 29));
      expect(row.gems, 10);
      expect(row.eventId, 'achv_streak_30');
      expect(row.refs['achievementId'], 'streak_30');
      expect(row.validate(), isNull);
    });

    test('a stat allocation row moves no currency but records the spend', () {
      final row = GameLedger.statAllocated(
        uid: 'u1',
        stat: StatType.STAT_TYPE_VITALITY,
        pointsBefore: 2,
        now: DateTime(2026, 9, 29),
      );
      expect(row.isZeroDelta, isTrue);
      expect(row.eventId, 'stat_u1_2_vitality');
      expect(row.validate(), isNull);
    });

    test('a penalty row stores the hp that was actually applied', () {
      final row = GameLedger.dailyPenalty(uid: 'u1', hpDelta: -30, now: DateTime(2026, 9, 29));
      expect(row.hp, -30);
      expect(row.eventId, 'penalty_u1_2026-09-29');
      expect(row.validate(), isNull);
    });

    test('a slip row records the HP lost and no rewards at all', () {
      final bad = Task()
        ..id = 'bad1'
        ..type = TaskType.TASK_TYPE_HABIT
        ..difficulty = TaskDifficulty.TASK_DIFFICULTY_MEDIUM
        ..isNegative = true;
      final row = GameLedger.habitSlipped(task: bad, hpDelta: -10, now: DateTime(2026, 9, 29));

      expect(row.type, LedgerEventType.habitSlipped);
      expect(row.eventId, 'slip_bad1_2026-09-29');
      expect(row.hp, -10);
      expect(row.exp, 0);
      expect(row.gold, 0);
      expect(row.gems, 0);
      expect(row.taskId, 'bad1');
      expect(row.refs['taskType'], 'habit');
      expect(row.validate(), isNull);
      // Same once-per-day keying as a completion, under its own prefix.
      expect(LedgerEvent.habitSlippedId('bad1', '2026-09-30'), isNot(row.eventId));
    });

    test('a slip without a task id is rejected', () {
      final row = LedgerEvent(
        eventId: 'slip_x_2026-09-29',
        type: LedgerEventType.habitSlipped,
        at: 1700000000000,
        localDate: '2026-09-29',
        hp: -10,
      );
      expect(row.validate(), contains('taskId'));
    });

    test('a merge row carries the deltas applied for one device', () {
      final row = GameLedger.accountMerged(
        goldDelta: 250,
        gemsDelta: 5,
        expDelta: 120,
        deviceId: 'dev1',
        now: DateTime(2026, 9, 29),
      );

      expect(row.type, LedgerEventType.accountMerged);
      expect(row.eventId, startsWith('merge_dev1_'));
      expect(row.gold, 250);
      expect(row.gems, 5);
      expect(row.exp, 120);
      expect(row.hp, 0, reason: 'HP is not merged');
      expect(row.refs['device'], 'dev1');
      expect(row.validate(), isNull);
    });

    test('a merge may import a whole save, so it uses the opening-balance caps', () {
      final big = GameLedger.accountMerged(
        goldDelta: 500000,
        gemsDelta: 12000,
        expDelta: 900000,
        deviceId: 'dev1',
        now: DateTime(2026, 9, 29),
      );
      expect(big.validate(), isNull, reason: 'a long local save must be importable');

      final absurd = GameLedger.accountMerged(
        goldDelta: LedgerLimits.openingBalance + 1,
        gemsDelta: 0,
        expDelta: 0,
        deviceId: 'dev1',
        now: DateTime(2026, 9, 29),
      );
      expect(absurd.validate(), contains('out of range'));
    });
  });
}

LedgerEvent _row({
  String eventId = 'complete_t1_2026-09-29',
  LedgerEventType type = LedgerEventType.taskCompleted,
  int at = 1700000000000,
  String localDate = '2026-09-29',
  int exp = 30,
  int gold = 10,
  int gems = 0,
  int hp = 0,
  String taskId = 't1',
  String itemId = '',
  Map<String, Object> refs = const <String, Object>{},
  int schemaVersion = kLedgerSchemaVersion,
}) =>
    LedgerEvent(
      eventId: eventId,
      type: type,
      at: at,
      localDate: localDate,
      exp: exp,
      gold: gold,
      gems: gems,
      hp: hp,
      taskId: taskId,
      itemId: itemId,
      refs: refs,
      schemaVersion: schemaVersion,
    );
