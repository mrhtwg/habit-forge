import 'package:get/get.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';

class StatisticsController extends GetxController {
  final allTasks = <Task>[].obs;
  TimePeriod period = TimePeriod.week;

  void changePeriod(TimePeriod newPeriod) {
    period = newPeriod;
    update();
  }
}

enum TimePeriod { week, month, all }
