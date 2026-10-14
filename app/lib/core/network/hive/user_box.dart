import 'package:habit_forge_app/core/di/injection_container.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

@singleton
class UserBox {
  static UserBox get ins => getIt<UserBox>();

  UserBox();

  final _boxKey = 'userBox';

  late Box _userBox;

  Future init() async {
    _userBox = await Hive.openBox(_boxKey);
  }

  UserPrefs getUserPrefs() {
    final raw = _userBox.get(_boxKey);
    if (raw == null) {
      return UserPrefs();
    }
    final userPrefs = raw == null ? null : UserPrefs()
      ?..mergeFromBuffer(raw);
    return userPrefs ?? UserPrefs();
  }

  void updateUserPrefs(UserPrefs userPrefs) async {
    _userBox.put(_boxKey, userPrefs.writeToBuffer());
  }

  static const _ownedKey = 'ownedItemIds';
  static const _dailyLoginKey = 'dailyLogin';
  static const _taskBudgetKey = 'taskBudget';

  Map<String, dynamic> getDailyLoginState() {
    final raw = _userBox.get(_dailyLoginKey);
    if (raw is! Map) return <String, dynamic>{};
    return raw.map((key, value) => MapEntry('$key', value));
  }

  void updateDailyLoginState({required String date, required int streak}) {
    _userBox.put(_dailyLoginKey, <String, dynamic>{'date': date, 'streak': streak});
  }

  Map<String, dynamic> getTaskBudget(String date) {
    final raw = _userBox.get(_taskBudgetKey);
    if (raw is! Map || raw['date'] != date) return <String, dynamic>{'date': date, 'exp': 0, 'gold': 0};
    return <String, dynamic>{
      'date': date,
      'exp': raw['exp'] is num ? (raw['exp'] as num).toInt() : 0,
      'gold': raw['gold'] is num ? (raw['gold'] as num).toInt() : 0,
    };
  }

  void updateTaskBudget({required String date, required int exp, required int gold}) {
    final raw = _userBox.get(_taskBudgetKey);
    _userBox.put(
      _taskBudgetKey,
      <String, dynamic>{
        'date': date,
        'exp': exp,
        'gold': gold,
        if (raw is Map && raw['date'] == date && raw['firstCompletionDate'] == date) 'firstCompletionDate': date,
      },
    );
  }

  bool hasFirstCompletionFor(String date) {
    final raw = _userBox.get(_taskBudgetKey);
    return raw is Map && raw['date'] == date && raw['firstCompletionDate'] == date;
  }

  void markFirstCompletionFor(String date) {
    final budget = getTaskBudget(date);
    budget['firstCompletionDate'] = date;
    _userBox.put(_taskBudgetKey, budget);
  }

  List<String> getOwnedItemIds() {
    final raw = _userBox.get(_ownedKey);
    if (raw == null) return <String>[];
    return (raw as List).cast<String>();
  }

  void updateOwnedItemIds(List<String> ids) {
    _userBox.put(_ownedKey, ids);
  }

  static const _achievementsKey = 'achievements';

  /// Unlocked achievements (with unlock timestamps and gem rewards granted).
  List<Achievement> getAchievements() {
    final raw = _userBox.get(_achievementsKey);
    if (raw == null) return <Achievement>[];
    return (raw as List).map((e) => Achievement()..mergeFromBuffer(e as List<int>)).toList();
  }

  /// Adds (or replaces) an unlocked achievement.
  void updateAchievement(Achievement achievement) {
    final all = getAchievements();
    all.removeWhere((a) => a.id == achievement.id);
    all.add(achievement);
    _userBox.put(_achievementsKey, all.map((a) => a.writeToBuffer()).toList());
  }

  void clear() {
    _userBox.clear();
  }
}
