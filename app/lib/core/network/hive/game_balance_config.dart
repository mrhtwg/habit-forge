import 'package:habit_forge_app/generated/protos/task/v1/task.pbenum.dart';

/// Versioned balance table loaded from `assets/config/config.yml`.
///
/// The defaults intentionally mirror the shipped v1 table so an old or
/// partially migrated save remains playable, but production values should be
/// edited in the asset table rather than in Dart formulas.
class GameBalanceConfig {
  GameBalanceConfig._();

  static const rulesVersion = 'hf.balance.1';
  static const catalogVersion = 'hf.catalog.1';
  static const maxLevel = 50;
  static const maxHp = 100;
  static const deathRecoveryMinutes = 20;
  static const taskDailyExpCap = 500;
  static const taskDailyGoldCap = 180;
  static const adGems = 2;
  static const adClaimsPerDay = 1;
  static const dealDiscountPercent = 20;
  static const streakBonusBps = 100;
  static const streakBonusCapBps = 1000;
  static const incomeBpsPerPoint = 50;
  static const incomeCapBps = 3000;
  static const defenseCapBps = 5000;
  static const vitalityHpPerPoint = 2;
  static const firstCompletionHeal = 5;
  static const levelUpHeal = 20;
  static const dailyDamageCap = 20;

  static const List<int> levelExp = <int>[
    60,
    70,
    80,
    90,
    100,
    120,
    130,
    150,
    160,
    180,
    190,
    210,
    230,
    250,
    270,
    300,
    320,
    350,
    370,
    400,
    420,
    450,
    480,
    510,
    540,
    580,
    610,
    650,
    680,
    720,
    750,
    790,
    830,
    870,
    910,
    960,
    1000,
    1050,
    1090,
    1140,
    1180,
    1230,
    1280,
    1330,
    1380,
    1440,
    1490,
    1550,
    1600,
  ];

  static const Map<TaskDifficulty, int> taskExp = <TaskDifficulty, int>{
    TaskDifficulty.TASK_DIFFICULTY_EASY: 15,
    TaskDifficulty.TASK_DIFFICULTY_MEDIUM: 30,
    TaskDifficulty.TASK_DIFFICULTY_HARD: 50,
  };

  static const Map<TaskDifficulty, int> taskGold = <TaskDifficulty, int>{
    TaskDifficulty.TASK_DIFFICULTY_EASY: 5,
    TaskDifficulty.TASK_DIFFICULTY_MEDIUM: 10,
    TaskDifficulty.TASK_DIFFICULTY_HARD: 20,
  };

  static const Map<TaskDifficulty, int> hpDamage = <TaskDifficulty, int>{
    TaskDifficulty.TASK_DIFFICULTY_EASY: 5,
    TaskDifficulty.TASK_DIFFICULTY_MEDIUM: 10,
    TaskDifficulty.TASK_DIFFICULTY_HARD: 15,
  };

  static int _readInt(Object? value, int fallback) => value is num ? value.toInt() : fallback;

  /// Applies values from YAML without allowing missing keys to erase the
  /// embedded safe defaults. Level thresholds are always read as a table.
  static void load(Map? raw) {
    if (raw == null) return;
    final map = raw.cast<Object?, Object?>();
    _loadedLevelExp = _readIntList(map['level_exp'], levelExp);
    _loadedTaskExp = _readDifficultyMap(map['task_exp'], taskExp);
    _loadedTaskGold = _readDifficultyMap(map['task_gold'], taskGold);
    _loadedHpDamage = _readDifficultyMap(map['hp_damage'], hpDamage);
    _loadedMaxLevel = _readInt(map['max_level'], maxLevel);
    _loadedTaskDailyExpCap =
        _readInt(map['task_daily_cap'] is Map ? (map['task_daily_cap'] as Map)['exp'] : null, taskDailyExpCap);
    _loadedTaskDailyGoldCap =
        _readInt(map['task_daily_cap'] is Map ? (map['task_daily_cap'] as Map)['gold'] : null, taskDailyGoldCap);
    _loadedAdGems = _readInt(map['ads'] is Map ? (map['ads'] as Map)['gems_per_claim'] : null, adGems);
    _loadedAdClaimsPerDay = _readInt(map['ads'] is Map ? (map['ads'] as Map)['claims_per_day'] : null, adClaimsPerDay);
    _loadedDealDiscountPercent =
        _readInt(map['deal'] is Map ? (map['deal'] as Map)['discount_percent'] : null, dealDiscountPercent);
  }

  static List<int> _readIntList(Object? value, List<int> fallback) {
    if (value is! List || value.length != fallback.length || value.any((v) => v is! num)) return fallback;
    return value.map((v) => (v as num).toInt()).toList(growable: false);
  }

  static Map<TaskDifficulty, int> _readDifficultyMap(Object? value, Map<TaskDifficulty, int> fallback) {
    if (value is! Map) return fallback;
    int read(String key, TaskDifficulty difficulty) => _readInt(value[key], fallback[difficulty]!);
    return <TaskDifficulty, int>{
      TaskDifficulty.TASK_DIFFICULTY_EASY: read('easy', TaskDifficulty.TASK_DIFFICULTY_EASY),
      TaskDifficulty.TASK_DIFFICULTY_MEDIUM: read('medium', TaskDifficulty.TASK_DIFFICULTY_MEDIUM),
      TaskDifficulty.TASK_DIFFICULTY_HARD: read('hard', TaskDifficulty.TASK_DIFFICULTY_HARD),
    };
  }

  static List<int> _loadedLevelExp = levelExp;
  static Map<TaskDifficulty, int> _loadedTaskExp = taskExp;
  static Map<TaskDifficulty, int> _loadedTaskGold = taskGold;
  static Map<TaskDifficulty, int> _loadedHpDamage = hpDamage;
  static int _loadedMaxLevel = maxLevel;
  static int _loadedTaskDailyExpCap = taskDailyExpCap;
  static int _loadedTaskDailyGoldCap = taskDailyGoldCap;
  static int _loadedAdGems = adGems;
  static int _loadedAdClaimsPerDay = adClaimsPerDay;
  static int _loadedDealDiscountPercent = dealDiscountPercent;

  static List<int> get configuredLevelExp => _loadedLevelExp;
  static int get configuredMaxLevel => _loadedMaxLevel.clamp(1, levelExp.length).toInt();
  static int get configuredTaskDailyExpCap => _loadedTaskDailyExpCap;
  static int get configuredTaskDailyGoldCap => _loadedTaskDailyGoldCap;
  static int get configuredAdGems => _loadedAdGems;
  static int get configuredAdClaimsPerDay => _loadedAdClaimsPerDay;
  static int get configuredDealDiscountPercent => _loadedDealDiscountPercent;
  static int baseExp(TaskDifficulty difficulty) => _loadedTaskExp[difficulty] ?? taskExp[difficulty] ?? 15;
  static int baseGold(TaskDifficulty difficulty) => _loadedTaskGold[difficulty] ?? taskGold[difficulty] ?? 5;
  static int baseDamage(TaskDifficulty difficulty) => _loadedHpDamage[difficulty] ?? hpDamage[difficulty] ?? 5;
}
