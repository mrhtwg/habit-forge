import 'package:get/get.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';
import 'package:habit_forge_app/widgets/toast_widget.dart';

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

    result.when(
      onSuccess: (data) async {
        final tasksResult = await NetworkRegistry.ins.listTasks();
        final ownedResult = await NetworkRegistry.ins.listOwnedItems();
        final tasks = tasksResult.data?.tasks ?? const [];
        final bestStreak = tasks.fold<int>(0, (best, task) => task.streak > best ? task.streak : best);
        final totalTasks = UserService.to.userPrefs.value.totalTasksCompleted.toInt();
        final level = UserService.to.character.value?.level ?? 1;
        final purchases = ownedResult.data?.itemIds.length ?? 0;

        achievements.value = [
          for (final achievement in data.achievements)
            achievement.deepCopy()
              ..progress = switch (achievement.conditionType) {
                'total_tasks' => totalTasks,
                'streak' => bestStreak,
                'level' => level,
                'purchases' => purchases,
                'deaths' => achievement.isUnlocked ? 1 : 0,
                _ => 0,
              },
        ];
      },
      onFailure: (code, msg) => Toast.show(msg),
    );
    // if (result.isSuccess) {
    //   final tasksResult = await NetworkRegistry.ins.listTasks();
    //   final ownedResult = await NetworkRegistry.ins.listOwnedItems();
    //   final tasks = tasksResult.data?.tasks ?? const [];
    //   final bestStreak = tasks.fold<int>(0, (best, task) => task.streak > best ? task.streak : best);
    //   final totalTasks = UserService.to.userPrefs.value.totalTasksCompleted.toInt();
    //   final level = UserService.to.character.value?.level ?? 1;
    //   final purchases = ownedResult.data?.itemIds.length ?? 0;

    //   achievements.value = [
    //     for (final achievement in result.data!.achievements)
    //       achievement.deepCopy()
    //         ..progress = switch (achievement.conditionType) {
    //           'total_tasks' => totalTasks,
    //           'streak' => bestStreak,
    //           'level' => level,
    //           'purchases' => purchases,
    //           'deaths' => achievement.isUnlocked ? 1 : 0,
    //           _ => 0,
    //         },
    //   ];
    // }
  }
}

enum TimePeriod { week, month, all }
