import 'package:get/get.dart';
import 'package:habit_forge_app/features/statistics/controllers/statistics_controller.dart';

class StatisticsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<StatisticsController>(() => StatisticsController());
}
