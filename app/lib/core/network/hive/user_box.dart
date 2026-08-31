import 'package:habit_forge_app/core/di/injection_container.dart';
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

  void clear() {
    _userBox.clear();
  }
}
