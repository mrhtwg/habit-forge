import 'package:get/get.dart';
import 'package:habit_forge_app/features/webview/controllers/habit_webview_controller.dart';

class HabitWebViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HabitWebviewController>(() => HabitWebviewController());
  }
}
