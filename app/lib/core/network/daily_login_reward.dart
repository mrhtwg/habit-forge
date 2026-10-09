import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';

/// The result of checking the current calendar day's login reward.
class DailyLoginReward {
  const DailyLoginReward({
    required this.isNewClaim,
    required this.day,
    required this.streak,
    required this.gold,
    required this.gems,
    required this.date,
    this.unlockedAchievements = const <Achievement>[],
  });

  final bool isNewClaim;
  final int day;
  final int streak;
  final int gold;
  final int gems;
  final String date;
  final List<Achievement> unlockedAchievements;
}

/// Login reward balance. The third day intentionally follows the requested
/// mixed reward shape: 2 gold + 1 gem. Day 30 is the final tier.
abstract final class DailyLoginRewardSchedule {
  static const maxDay = 30;

  static DailyLoginReward rewardFor(int streak, String date, {List<Achievement> unlocked = const []}) {
    final day = streak.clamp(1, maxDay).toInt();
    final gold = day <= 2 ? day : (day - 1).clamp(1, maxDay - 1).toInt();
    final gems = day < 3 ? 0 : (1 + ((day - 3) ~/ 7)).clamp(1, 4).toInt();
    return DailyLoginReward(
      isNewClaim: true,
      day: day,
      streak: streak,
      gold: gold,
      gems: gems,
      date: date,
      unlockedAchievements: unlocked,
    );
  }

  static DailyLoginReward alreadyClaimed({required int streak, required String date}) {
    final day = streak.clamp(1, maxDay).toInt();
    return DailyLoginReward(
      isNewClaim: false,
      day: day,
      streak: streak,
      gold: 0,
      gems: 0,
      date: date,
    );
  }
}
