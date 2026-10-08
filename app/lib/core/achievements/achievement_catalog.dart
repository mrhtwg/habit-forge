import 'package:flutter/material.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';

abstract final class AchievementCatalog {
  static const taskThresholds = <int>[
    1,
    2,
    3,
    4,
    5,
    6,
    8,
    10,
    12,
    15,
    18,
    20,
    25,
    30,
    35,
    40,
    50,
    60,
    75,
    80,
    100,
    125,
    150,
    175,
    200,
    225,
    250,
    275,
    300,
    350,
    400,
    450,
    500,
    600,
    650,
    700,
    750,
    850,
    900,
    1000,
    1250,
    1500,
    1750,
    2000,
    2500,
    3000,
    3500,
    4000,
    5000,
    6000,
    7500,
    9000,
    10000,
    12500,
    15000,
    20000,
    25000,
    30000,
    40000,
    50000,
  ];

  static const streakThresholds = <int>[
    2,
    3,
    5,
    7,
    10,
    14,
    21,
    30,
    45,
    60,
    75,
    90,
    120,
    150,
    180,
    210,
    240,
    270,
    300,
    365,
    450,
    500,
    600,
    730,
    1000,
  ];

  static const levelThresholds = <int>[
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    24,
    25,
    28,
    30,
    32,
    35,
    40,
    45,
    50,
  ];
  static const purchaseThresholds = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];

  static List<Achievement> definitions() => <Achievement>[
        ..._group('total_tasks', taskThresholds),
        ..._group('streak', streakThresholds),
        ..._group('level', levelThresholds),
        ..._group('purchases', purchaseThresholds),
        ..._group('deaths', const [1]),
      ];

  static List<Achievement> _group(String type, List<int> thresholds) {
    return [
      for (final threshold in thresholds)
        Achievement(
          id: _id(type, threshold),
          title: _englishTitle(type, threshold),
          description: _englishDescription(type, threshold),
          conditionType: type,
          threshold: threshold,
          gemReward: _gemReward(thresholds.indexOf(threshold)),
        ),
    ];
  }

  static String _id(String type, int threshold) => switch ((type, threshold)) {
        ('total_tasks', 1) => 'first_task',
        ('purchases', 1) => 'first_purchase',
        _ => '${type == 'total_tasks' ? 'tasks' : type}_$threshold',
      };

  static int _gemReward(int index) => index >= 19
      ? 25
      : index >= 9
          ? 15
          : index >= 4
              ? 10
              : 5;

  static String title(Achievement achievement) => switch (achievement.conditionType) {
        'total_tasks' => LanKey.achievementTasksTitle.trParams({'n': '${achievement.threshold}'}),
        'streak' => LanKey.achievementStreakTitle.trParams({'n': '${achievement.threshold}'}),
        'level' => LanKey.achievementLevelTitle.trParams({'n': '${achievement.threshold}'}),
        'purchases' => LanKey.achievementPurchaseTitle.trParams({'n': '${achievement.threshold}'}),
        _ => LanKey.achievementRecoveryTitle.tr,
      };

  static String description(Achievement achievement) => switch (achievement.conditionType) {
        'total_tasks' => LanKey.achievementTasksDescription.trParams({'n': '${achievement.threshold}'}),
        'streak' => LanKey.achievementStreakDescription.trParams({'n': '${achievement.threshold}'}),
        'level' => LanKey.achievementLevelDescription.trParams({'n': '${achievement.threshold}'}),
        'purchases' => LanKey.achievementPurchaseDescription.trParams({'n': '${achievement.threshold}'}),
        _ => LanKey.achievementRecoveryDescription.tr,
      };

  static String iconPath(String id) {
    final extension = id == 'first_task' || id.startsWith('tasks_') || id.startsWith('level_') || id.startsWith('streak_')
        ? 'webp'
        : 'png';
    return 'assets/images/achievements/icons/$id.$extension';
  }

  /// Greyscale filter for locked achievements.
  ///
  /// Deliberately a **matrix** filter rather than
  /// `ColorFilter.mode(Color(...), BlendMode.saturation)`: a blend-mode filter
  /// paints through a `saveLayer` whose bounds are the canvas clip, so it tints
  /// everything in that clip, not just the artwork it wraps. Because the locked
  /// icon is mostly transparent, blending an opaque colour onto transparent
  /// pixels yields that colour — the whole achievements grid came out as a solid
  /// #9C9588 slab. The matrix form maps transparent pixels to transparent, so it
  /// only desaturates what is actually drawn.
  static const ColorFilter lockedFilter = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, // R
    0.2126, 0.7152, 0.0722, 0, 0, // G
    0.2126, 0.7152, 0.0722, 0, 0, // B
    0, 0, 0, 1, 0, // A — preserved, so empty pixels stay empty
  ]);

  static Color colorFor(String type) => switch (type) {
        'streak' => const Color(0xFFFF7A32),
        'level' => const Color(0xFF3D9BE9),
        'purchases' => const Color(0xFF2DB96D),
        'deaths' => const Color(0xFFE85B69),
        _ => const Color(0xFF7658D8),
      };

  static String _englishTitle(String type, int threshold) => switch (type) {
        'total_tasks' => 'Quest Master · $threshold',
        'streak' => 'Flame Keeper · $threshold',
        'level' => 'Rising Hero · Lv.$threshold',
        'purchases' => 'Forge Patron · $threshold',
        _ => 'Phoenix Soul',
      };

  static String _englishDescription(String type, int threshold) => switch (type) {
        'total_tasks' => 'Complete $threshold quests',
        'streak' => 'Reach a $threshold-day streak',
        'level' => 'Reach hero level $threshold',
        'purchases' => 'Own $threshold Forge items',
        _ => 'Recover after falling in battle',
      };
}
