const TaskTypeDaily = 2;

const TaskTypeHabit = 1;

const TaskTypeTodo = 3;

class AppConstants {
  static List<String> taskTags = [
    'Health',
    'Work',
    'Learn',
    'Personal',
    'Fitness',
  ];
  AppConstants._();

  static TaskType taskTypeFromInt(int type) {
    switch (type) {
      case TaskTypeHabit:
        return TaskType.habit;
      case TaskTypeDaily:
        return TaskType.daily;
      case TaskTypeTodo:
        return TaskType.todo;
      default:
        return TaskType.habit;
    }
  }
}

enum Character {
  warrior,
  mage,
  ranger,
  // adventurer,
}

enum TaskType {
  habit,
  daily,
  todo,
}

extension CharacterExtension on Character {
  String get str {
    switch (this) {
      case Character.warrior:
        return 'Warrior';
      case Character.mage:
        return 'Mage';
      case Character.ranger:
        return 'Ranger';
      // case Character.adventurer:
      //   return 'Adventurer';
    }
  }
}

extension TaskTypeExtension on TaskType {
  String get str {
    switch (this) {
      case TaskType.habit:
        return 'Habit';
      case TaskType.daily:
        return 'Daily';
      case TaskType.todo:
        return 'Todo';
    }
  }

  int get value {
    switch (this) {
      case TaskType.habit:
        return TaskTypeHabit;
      case TaskType.daily:
        return TaskTypeDaily;
      case TaskType.todo:
        return TaskTypeTodo;
    }
  }
}
