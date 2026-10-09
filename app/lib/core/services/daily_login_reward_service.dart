import 'package:get/get.dart';
import 'package:habit_forge_app/core/network/daily_login_reward.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/services/achievement_unlock_service.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/features/rewards/reward_popup.dart';

class DailyLoginRewardService extends GetxService {
  static DailyLoginRewardService get to => Get.find();

  final currentStreak = 0.obs;
  final pendingReward = Rxn<DailyLoginReward>();
  bool _claiming = false;
  bool _presenting = false;

  Future<DailyLoginReward?> claimIfNeeded() async {
    if (_claiming) return pendingReward.value;
    _claiming = true;
    try {
      final result = await NetworkRegistry.ins.claimDailyLoginReward();
      final reward = result.data;
      if (reward == null) return null;
      await UserService.to.loadUserPrefs();
      currentStreak.value = reward.streak;
      if (reward.isNewClaim && pendingReward.value == null) {
        pendingReward.value = reward;
      }
      return reward;
    } finally {
      _claiming = false;
    }
  }

  Future<void> presentPending() async {
    if (_presenting) return;
    final reward = pendingReward.value;
    if (reward == null) return;
    _presenting = true;
    pendingReward.value = null;
    try {
      await RewardPopup.showDailyLoginReward(reward);
      await AchievementUnlockService.presentUnlocks(reward.unlockedAchievements);
    } finally {
      _presenting = false;
    }
  }
}
