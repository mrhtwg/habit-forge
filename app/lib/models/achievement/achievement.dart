class Achievement {
  final String id;
  final String title;
  final String description;
  final String conditionType;
  final int threshold;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int gemReward;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.conditionType,
    required this.threshold,
    this.isUnlocked = false,
    this.unlockedAt,
    this.gemReward = 0,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['desc'] as String,
        conditionType: json['cond'] as String,
        threshold: json['thresh'] as int,
        isUnlocked: json['unlocked'] as bool? ?? false,
        unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt'] as String) : null,
        gemReward: json['gems'] as int? ?? 0,
      );

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? gemReward,
  }) =>
      Achievement(
        id: id,
        title: title,
        description: description,
        conditionType: conditionType,
        threshold: threshold,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        unlockedAt: unlockedAt ?? this.unlockedAt,
        gemReward: gemReward ?? this.gemReward,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'desc': description,
        'cond': conditionType,
        'thresh': threshold,
        'unlocked': isUnlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
        'gems': gemReward,
      };
}
