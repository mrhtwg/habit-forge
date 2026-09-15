import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/features/rewards/reward_popup.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';

/// Snapshots / diffs achievement unlocks around gameplay events (task complete,
/// purchase, revive) and presents the unlock celebration UI.
class AchievementUnlockService {
  AchievementUnlockService._();

  static Future<Set<String>> snapshotUnlockedIds() async {
    final result = await NetworkRegistry.ins.listAchievements();
    if (result.isFailure || result.data == null) return {};
    return {
      for (final a in result.data!.achievements)
        if (a.isUnlocked) a.id,
    };
  }

  static Future<List<Achievement>> newlyUnlockedSince(Set<String> before) async {
    final result = await NetworkRegistry.ins.listAchievements();
    if (result.isFailure || result.data == null) return const [];
    return [
      for (final a in result.data!.achievements)
        if (a.isUnlocked && !before.contains(a.id)) a,
    ];
  }

  /// Shows one celebratory dialog per newly unlocked achievement (sequential).
  static Future<void> presentUnlocks(List<Achievement> unlocked) async {
    if (unlocked.isEmpty) return;
    await RewardPopup.showUnlockedAchievements(unlocked);
  }
}
