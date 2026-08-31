import 'package:get/get.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';

class AchievementsController extends GetxController {
  final achievements = <Achievement>[].obs;
}

enum TimePeriod { week, month, all }
