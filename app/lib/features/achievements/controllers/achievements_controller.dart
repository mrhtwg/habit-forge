import 'package:get/get.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';

class AchievementsController extends GetxController {
  // Achievement definitions are served by the storage layer (simulating a
  // backend rule set); the UI only renders them and the unlock state.
  List<Achievement> get achievementDefs => NetworkRegistry.ins.achievementDefs;
}

enum TimePeriod { week, month, all }
