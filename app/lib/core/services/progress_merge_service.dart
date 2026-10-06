import 'package:habit_forge_app/core/common/utils/log.dart';
import 'package:habit_forge_app/core/common/utils/sp_keys.dart';
import 'package:habit_forge_app/core/common/utils/sp_utils.dart';
import 'package:habit_forge_app/core/network/network_firebase_impl.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';
import 'package:uuid/uuid.dart';

/// A read-only copy of this device's save.
///
/// Taken while the **local** backend is still registered, so it can be merged
/// into an account right after the switch to the cloud backend.
class LocalProgressSnapshot {
  const LocalProgressSnapshot({
    required this.character,
    required this.prefs,
    required this.tasks,
    required this.ownedItemIds,
    required this.unlockedAchievements,
    required this.deviceId,
  });

  final Character? character;
  final UserPrefs prefs;
  final List<Task> tasks;
  final List<String> ownedItemIds;
  final List<Achievement> unlockedAchievements;

  /// Stable id of this install's save (see [ProgressMergeService.deviceId]).
  final String deviceId;

  bool get isEmpty => character == null && tasks.isEmpty;
  bool get hasCharacter => character != null;
}

/// Guest → account merge, one way, with nothing dropped on either side.
///
/// Why this exists: the guest path deliberately keeps data on the device (no
/// anonymous Firebase user, see `docs/data-ledger-plan.md` §2), and the app used
/// to answer "this account already has a save" with a single non-cancel option
/// that quietly replaced the device's progress. Since a guest may have played for
/// weeks, the merge is the default answer now:
///
///  * **tasks / items / achievements** — union (deduplicated by task id, which
///    also covers the case where the device save came from this very account);
///  * **gold, gems, lifetime EXP, completed-task counters** — the device's
///    contribution is *replaced* by its current totals, so re-merging an
///    unchanged device adds nothing and merging after local play adds only the
///    difference. That is what makes the whole operation idempotent;
///  * **hero identity** (class, equipment, spent stat points) and **HP** — the
///    account's, because identity is not progress and HP is a momentary state;
///  * the device save itself is never touched, so signing out still lands on it.
///
/// Ledger side: an existing ledger gets exactly one `account_merged` row carrying
/// the applied deltas; a fresh account records the merged state as its
/// `opening_balance` instead (see `NetworkFirebaseImpl.mergeLocalProgress`).
class ProgressMergeService {
  ProgressMergeService._();

  /// Guest saves can always be merged into the Firebase account.
  static bool get isSupported => true;

  /// Reads this device's save through the currently registered backend.
  ///
  /// **Call before switching backends**: once the cloud backend is registered,
  /// `NetworkRegistry.ins` no longer sees the local save.
  static Future<LocalProgressSnapshot> snapshotLocal() async {
    final backend = NetworkRegistry.ins;
    final character = (await backend.getCharacter()).data?.character;
    final prefs = (await backend.getPrefs()).data?.prefs ?? UserPrefs();
    final tasks = (await backend.listTasks()).data?.tasks ?? const <Task>[];
    final owned = (await backend.listOwnedItems()).data?.itemIds ?? const <String>[];
    final achievements = (await backend.listAchievements()).data?.achievements ?? const <Achievement>[];

    return LocalProgressSnapshot(
      character: character,
      prefs: prefs,
      tasks: tasks,
      ownedItemIds: owned,
      unlockedAchievements: <Achievement>[
        for (final a in achievements)
          if (a.isUnlocked) a,
      ],
      deviceId: await deviceId(),
    );
  }

  /// Applies [snapshot] to the account that is signed in now. Returns false when
  /// the merge did not run (wrong backend, not signed in, nothing to merge).
  static Future<bool> applyToCloud(LocalProgressSnapshot snapshot) async {
    final backend = NetworkRegistry.ins;
    if (backend is! NetworkFirebaseImpl) {
      Log.w('merge requested on ${backend.runtimeType} — only the cloud backend merges');
      return false;
    }
    return backend.mergeLocalProgress(snapshot);
  }

  /// Stable per-install id. The account stores what this device already
  /// contributed under it, which is what makes merging twice a no-op.
  static Future<String> deviceId() async {
    final existing = SpUtils.ins.getString(SpKeys.mergeDeviceId);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = const Uuid().v4().replaceAll('-', '').substring(0, 10);
    await SpUtils.ins.putString(SpKeys.mergeDeviceId, id);
    return id;
  }
}
