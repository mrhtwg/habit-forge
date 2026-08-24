import 'package:get/get.dart';
import 'package:habit_forge_app/models/achievement/achievement.dart';

class AchievementsController extends GetxController {
  // Achievement definitions
  final achievementDefs = [
    Achievement(
      id: 'first_task',
      title: 'First Blood',
      description: 'Complete your first task',
      conditionType: 'total_tasks',
      threshold: 1,
      gemReward: 5,
    ),
    Achievement(
      id: 'streak_7',
      title: 'Hot Streak',
      description: '7-day streak',
      conditionType: 'streak',
      threshold: 7,
      gemReward: 5,
    ),
    Achievement(
      id: 'streak_30',
      title: 'Unstoppable',
      description: '30-day streak',
      conditionType: 'streak',
      threshold: 30,
      gemReward: 10,
    ),
    Achievement(
      id: 'level_5',
      title: 'Growing Strong',
      description: 'Reach level 5',
      conditionType: 'level',
      threshold: 5,
      gemReward: 5,
    ),
    Achievement(
      id: 'level_10',
      title: 'Double Digits',
      description: 'Reach level 10',
      conditionType: 'level',
      threshold: 10,
      gemReward: 10,
    ),
    Achievement(
      id: 'tasks_50',
      title: 'Getting Things Done',
      description: 'Complete 50 tasks',
      conditionType: 'total_tasks',
      threshold: 50,
      gemReward: 5,
    ),
    Achievement(
      id: 'tasks_100',
      title: 'Task Master',
      description: 'Complete 100 tasks',
      conditionType: 'total_tasks',
      threshold: 100,
      gemReward: 10,
    ),
    Achievement(
      id: 'first_purchase',
      title: 'Shopaholic',
      description: 'Buy first shop item',
      conditionType: 'purchases',
      threshold: 1,
      gemReward: 5,
    ),
    Achievement(
      id: 'death_1',
      title: 'Back from the Dead',
      description: 'Die and recover',
      conditionType: 'deaths',
      threshold: 1,
      gemReward: 5,
    ),
  ];
}

enum TimePeriod { week, month, all }
