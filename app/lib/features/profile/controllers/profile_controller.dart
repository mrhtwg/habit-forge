import 'package:get/get.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/widgets/toast_widget.dart';

class ProfileController extends GetxController {
  final tasks = <Task>[].obs;
  final totalTasksCompleted = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getTasks();
  }

  void getTasks() async {
    final result = await NetworkRegistry.ins.listTasks();
    result.when(onSuccess: (reply) => tasks.value = reply.tasks, onFailure: (code, msg) => Toast.error(msg));
  }

  double get completionRate {
    final total = tasks.length;
    if (total == 0) return 0;
    final completed = tasks.where((t) => t.isCompleted).length;
    return completed / total;
  }

  int get currentGold => UserService.to.gold.value;
  int get currentLevel => UserService.to.character.value?.level ?? 1;
  int get maxStreak => tasks.fold(0, (max, t) => t.streak > max ? t.streak : max);
}
