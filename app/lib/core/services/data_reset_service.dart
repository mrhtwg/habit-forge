import 'package:habit_forge_app/core/di/injection_container.dart';
import 'package:habit_forge_app/core/network/hive/character_box.dart';
import 'package:habit_forge_app/core/network/hive/shop_box.dart';
import 'package:habit_forge_app/core/network/hive/task_box.dart';
import 'package:habit_forge_app/core/network/hive/user_box.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:injectable/injectable.dart';

/// Wipes all local game data (hive mode only).
///
/// This is a pure client-side operation (no backend RPC): it clears the Hive
/// boxes and the local session. The settings page only offers it in hive mode.
@singleton
class DataResetService {
  static DataResetService get to => getIt<DataResetService>();

  DataResetService();

  Future<void> resetAllData() async {
    CharacterBox.ins.clear();
    TaskBox.ins.clear();
    UserBox.ins.clear();
    ShopBox.ins.clear();
    await UserService.to.setSessionToken(null);
  }
}
