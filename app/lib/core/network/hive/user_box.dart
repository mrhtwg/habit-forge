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
