/// Subscription tiers from Freemium plan
/// (docs: RPG习惯管理应用_可行性分析报告 §8.1).
enum SubscriptionTier {
  /// Free: core loop, 3 habit slots, basic stats, ads allowed.
  free,

  /// \$4.99/mo — unlimited habits, all classes, advanced stats,
  /// exclusive gear, no ads.
  monthly,

  /// \$29.99/yr — monthly perks + yearly exclusive rewards.
  yearly,

  /// \$49.99 one-time — all features forever.
  lifetime,
}

extension SubscriptionTierX on SubscriptionTier {
  bool get isPremium => this != SubscriptionTier.free;

  /// Yearly exclusives (and lifetime).
  bool get hasYearlyExtras => this == SubscriptionTier.yearly || this == SubscriptionTier.lifetime;

  int get rank => switch (this) {
        SubscriptionTier.free => 0,
        SubscriptionTier.monthly => 1,
        SubscriptionTier.yearly => 2,
        SubscriptionTier.lifetime => 3,
      };
}

/// Google Play / App Store product ids (configure in Play Console).
class SubscriptionProducts {
  SubscriptionProducts._();

  static const monthly = 'habitforge_premium_monthly';
  static const yearly = 'habitforge_premium_yearly';
  static const lifetime = 'habitforge_premium_lifetime';

  static const all = [monthly, yearly, lifetime];

  static SubscriptionTier? tierForProduct(String productId) => switch (productId) {
        monthly => SubscriptionTier.monthly,
        yearly => SubscriptionTier.yearly,
        lifetime => SubscriptionTier.lifetime,
        _ => null,
      };
}

/// Soft limits for free tier.
class SubscriptionLimits {
  SubscriptionLimits._();

  /// Free users may keep at most this many TASK_TYPE_HABIT quests.
  static const int freeHabitSlots = 3;
}
