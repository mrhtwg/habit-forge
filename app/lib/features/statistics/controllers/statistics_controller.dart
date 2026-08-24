import 'package:get/get.dart';

class StatisticsController extends GetxController {
  TimePeriod period = TimePeriod.week;

  void changePeriod(TimePeriod newPeriod) {
    period = newPeriod;
    update();
  }
}

enum TimePeriod { week, month, all }
