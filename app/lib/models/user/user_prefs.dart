class UserPrefs {
  final bool onboardingCompleted;
  final int lastOnboardingStep;
  final int currentGold;
  final int currentGems;
  final bool soundEnabled;
  final bool hapticEnabled;
  final bool notificationsEnabled;
  final int totalTasksCompleted;
  final DateTime? firstTaskDate;

  const UserPrefs({
    this.onboardingCompleted = false,
    this.lastOnboardingStep = 1,
    this.currentGold = 0,
    this.currentGems = 0,
    this.soundEnabled = true,
    this.hapticEnabled = true,
    this.notificationsEnabled = true,
    this.totalTasksCompleted = 0,
    this.firstTaskDate,
  });

  factory UserPrefs.fromJson(Map<String, dynamic> json) => UserPrefs(
        onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
        lastOnboardingStep: json['lastOnboardingStep'] as int? ?? 1,
        currentGold: json['currentGold'] as int? ?? 0,
        currentGems: json['currentGems'] as int? ?? 0,
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        hapticEnabled: json['hapticEnabled'] as bool? ?? true,
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
        totalTasksCompleted: json['totalTasksCompleted'] as int? ?? 0,
        firstTaskDate: json['firstTaskDate'] != null ? DateTime.parse(json['firstTaskDate'] as String) : null,
      );

  UserPrefs copyWith({
    bool? onboardingCompleted,
    int? lastOnboardingStep,
    int? currentGold,
    int? currentGems,
    bool? soundEnabled,
    bool? hapticEnabled,
    bool? notificationsEnabled,
    int? totalTasksCompleted,
    DateTime? firstTaskDate,
  }) =>
      UserPrefs(
        onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
        lastOnboardingStep: lastOnboardingStep ?? this.lastOnboardingStep,
        currentGold: currentGold ?? this.currentGold,
        currentGems: currentGems ?? this.currentGems,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        hapticEnabled: hapticEnabled ?? this.hapticEnabled,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
        firstTaskDate: firstTaskDate ?? this.firstTaskDate,
      );

  Map<String, dynamic> toJson() => {
        'onboardingCompleted': onboardingCompleted,
        'lastOnboardingStep': lastOnboardingStep,
        'currentGold': currentGold,
        'currentGems': currentGems,
        'soundEnabled': soundEnabled,
        'hapticEnabled': hapticEnabled,
        'notificationsEnabled': notificationsEnabled,
        'totalTasksCompleted': totalTasksCompleted,
        'firstTaskDate': firstTaskDate?.toIso8601String(),
      };
}
