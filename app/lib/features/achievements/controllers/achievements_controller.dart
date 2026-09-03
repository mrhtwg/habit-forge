import 'package:get/get.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';

class AchievementsController extends GetxController {
  final achievements = <Achievement>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  /// Pulls the full achievement list (definitions + unlock state) from the
  /// storage layer.
  Future<void> load() async {
    final result = await NetworkRegistry.ins.listAchievements();
    if (result.isSuccess) {
      achievements.value = result.data!.achievements;
    }
  }
}

enum TimePeriod { week, month, all }
