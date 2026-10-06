import 'package:habit_forge_app/core/network/ledger/ledger_event.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';

/// Builds the ledger rows for each thing that moves a number
/// (`docs/data-ledger-plan.md` §6.3).
///
/// This is the single place that decides *what* gets recorded, so both the
/// Firestore write paths and the tests produce byte-identical rows — the same
/// trick that keeps the class screen and the class stats from drifting (see
/// `ClassProfiles`). Impls only decide *when* to append.
///
/// Recording rule used throughout: a row stores the **actual delta** that was
/// applied, not a nominal reward. A task completion that levels the hero up also
/// heals HP, so that heal belongs to the same row (`hp`) — otherwise
/// "opening + Σ rows = balance" could never hold for HP.
class GameLedger {
  GameLedger._();

  /// First row of a ledger (§7): the snapshot the books start from.
  ///
  /// `at` and the document id both come from [ledgerStartedAt], so the row can
  /// be written at most once per start timestamp — and the start timestamp is
  /// stored in the same atomic write, which makes the migration idempotent.
  static LedgerEvent openingBalance({
    required UserPrefs prefs,
    required Character? character,
    required DateTime now,
    required int ledgerStartedAt,
    String note = 'pre-ledger snapshot',
  }) =>
      LedgerEvent(
        eventId: LedgerEvent.openingBalanceId(ledgerStartedAt),
        type: LedgerEventType.openingBalance,
        at: ledgerStartedAt,
        localDate: LedgerEvent.localDateKey(now),
        exp: character?.currentExp.toInt() ?? 0,
        gold: prefs.currentGold.toInt(),
        gems: prefs.currentGems.toInt(),
        hp: character?.currentHp ?? 0,
        refs: <String, Object>{'note': note},
      );

  /// Completing a task: the EXP and gold awarded, plus any incidental HP change
  /// (the level-up heal).
  static LedgerEvent taskCompleted({
    required Task task,
    required int exp,
    required int gold,
    required int hpDelta,
    required DateTime now,
    int? leveledTo,
  }) =>
      LedgerEvent(
        eventId: LedgerEvent.taskCompletedId(task.id, LedgerEvent.localDateKey(now)),
        type: LedgerEventType.taskCompleted,
        at: now.millisecondsSinceEpoch,
        localDate: LedgerEvent.localDateKey(now),
        exp: exp,
        gold: gold,
        hp: hpDelta,
        taskId: task.id,
        refs: <String, Object>{
          'taskType': taskTypeKey(task.type),
          'difficulty': difficultyKey(task.difficulty),
          'streak': task.streak,
          if (leveledTo != null) 'leveledTo': leveledTo,
        },
      );

  /// A negative habit was logged: HP is lost and nothing is earned.
  ///
  /// `hp` is the delta that was **actually applied** — DEF has already absorbed
  /// its part and the damage is clamped at 0 HP — so the reconciliation invariant
  /// ("opening + Σ rows = balance") keeps holding for a slip too.
  static LedgerEvent habitSlipped({
    required Task task,
    required int hpDelta,
    required DateTime now,
  }) =>
      LedgerEvent(
        eventId: LedgerEvent.habitSlippedId(task.id, LedgerEvent.localDateKey(now)),
        type: LedgerEventType.habitSlipped,
        at: now.millisecondsSinceEpoch,
        localDate: LedgerEvent.localDateKey(now),
        hp: hpDelta,
        taskId: task.id,
        refs: <String, Object>{
          'taskType': taskTypeKey(task.type),
          'difficulty': difficultyKey(task.difficulty),
        },
      );

  /// A device (guest) save was merged into the account.
  ///
  /// Carries the deltas **actually applied by this merge** (never a re-statement
  /// of the device's totals), so re-merging the same device — or merging after
  /// playing more on it — keeps `opening + Σ rows = balance` exact. HP is not
  /// merged on purpose: HP is a momentary state, not progress.
  static LedgerEvent accountMerged({
    required int goldDelta,
    required int gemsDelta,
    required int expDelta,
    required String deviceId,
    required DateTime now,
    int hpDelta = 0,
  }) =>
      LedgerEvent(
        eventId: LedgerEvent.accountMergedId(deviceId, now.millisecondsSinceEpoch),
        type: LedgerEventType.accountMerged,
        at: now.millisecondsSinceEpoch,
        localDate: LedgerEvent.localDateKey(now),
        exp: expDelta,
        gold: goldDelta,
        gems: gemsDelta,
        hp: hpDelta,
        refs: <String, Object>{'source': 'device', 'device': deviceId},
      );

  /// Settling missed dailies: one row per user per local day, carrying the HP
  /// that was actually applied (damage is clamped at 0 HP, so the row can never
  /// exceed the character's cap).
  static LedgerEvent dailyPenalty({
    required String uid,
    required int hpDelta,
    required DateTime now,
    int? tasksMissed,
  }) =>
      LedgerEvent(
        eventId: LedgerEvent.dailyPenaltyId(uid, LedgerEvent.localDateKey(now)),
        type: LedgerEventType.dailyPenalty,
        at: now.millisecondsSinceEpoch,
        localDate: LedgerEvent.localDateKey(now),
        hp: hpDelta,
        refs: <String, Object>{
          'lastPenaltyDate': LedgerEvent.localDateKey(now),
          if (tasksMissed != null) 'tasksMissed': tasksMissed,
        },
      );

  /// Death recovery: HP back to the class recovery value. Keyed by the recovery
  /// deadline so replaying the revive changes nothing, while a later death
  /// produces a fresh row.
  static LedgerEvent revive({
    required Character character,
    required int hpDelta,
    required int deathRecoveryUntilMs,
    required DateTime now,
  }) =>
      LedgerEvent(
        eventId: LedgerEvent.reviveId(deathRecoveryUntilMs),
        type: LedgerEventType.revive,
        at: now.millisecondsSinceEpoch,
        localDate: LedgerEvent.localDateKey(now),
        hp: hpDelta,
        refs: <String, Object>{'deathRecoveryUntil': deathRecoveryUntilMs},
      );

  /// A shop purchase: the currency spent (already discounted) and the item
  /// gained. `discountPercent` is stored because the deal rotates daily — a
  /// replay months later must be able to reproduce the price that was charged.
  static LedgerEvent purchase({
    required String itemId,
    required ShopCurrency currency,
    required int price,
    required int discountPercent,
    required DateTime now,
  }) {
    final withGems = currency == ShopCurrency.SHOP_CURRENCY_GEMS;
    return LedgerEvent(
      eventId: LedgerEvent.purchaseId(itemId),
      type: LedgerEventType.purchase,
      at: now.millisecondsSinceEpoch,
      localDate: LedgerEvent.localDateKey(now),
      gold: withGems ? 0 : -price,
      gems: withGems ? -price : 0,
      itemId: itemId,
      refs: <String, Object>{
        'currency': currencyKey(currency),
        'price': price,
        'discountPercent': discountPercent,
      },
    );
  }

  /// One attribute point spent. No currency moves; the point total and the stat
  /// are recorded so a replay can verify the character's stats.
  static LedgerEvent statAllocated({
    required String uid,
    required StatType stat,
    required int pointsBefore,
    required DateTime now,
  }) =>
      LedgerEvent(
        eventId: LedgerEvent.statAllocatedId(uid, pointsBefore, statKey(stat)),
        type: LedgerEventType.statAllocated,
        at: now.millisecondsSinceEpoch,
        localDate: LedgerEvent.localDateKey(now),
        refs: <String, Object>{'stat': statKey(stat), 'pointsBefore': pointsBefore},
      );

  /// An achievement unlocked and paid out its gems.
  static LedgerEvent achievementUnlocked({
    required Achievement achievement,
    required DateTime now,
  }) =>
      LedgerEvent(
        eventId: LedgerEvent.achievementId(achievement.id),
        type: LedgerEventType.achievementUnlocked,
        at: now.millisecondsSinceEpoch,
        localDate: LedgerEvent.localDateKey(now),
        gems: achievement.gemReward,
        refs: <String, Object>{'achievementId': achievement.id, 'threshold': achievement.threshold},
      );

  // ── Readable keys for `refs` (the console is read by humans) ──

  static String taskTypeKey(TaskType type) => switch (type) {
        TaskType.TASK_TYPE_HABIT => 'habit',
        TaskType.TASK_TYPE_DAILY => 'daily',
        TaskType.TASK_TYPE_TODO => 'todo',
        _ => 'unknown',
      };

  static String difficultyKey(TaskDifficulty difficulty) => switch (difficulty) {
        TaskDifficulty.TASK_DIFFICULTY_EASY => 'easy',
        TaskDifficulty.TASK_DIFFICULTY_MEDIUM => 'medium',
        TaskDifficulty.TASK_DIFFICULTY_HARD => 'hard',
        _ => 'unknown',
      };

  static String currencyKey(ShopCurrency currency) =>
      currency == ShopCurrency.SHOP_CURRENCY_GEMS ? 'gems' : 'gold';

  static String statKey(StatType stat) => switch (stat) {
        StatType.STAT_TYPE_STRENGTH => 'strength',
        StatType.STAT_TYPE_INTELLIGENCE => 'intelligence',
        StatType.STAT_TYPE_AGILITY => 'agility',
        StatType.STAT_TYPE_DEFENSE => 'defense',
        StatType.STAT_TYPE_VITALITY => 'vitality',
        StatType.STAT_TYPE_LUCK => 'luck',
        _ => 'unknown',
      };
}
