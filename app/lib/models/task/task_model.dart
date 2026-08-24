import 'package:habit_forge_app/core/constants/app_constants.dart';

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final TaskType type;
  final String difficulty;
  final List<String> tags;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime? dueDate;
  final List<int> repeatDays;
  final int streak;
  final DateTime? lastStreakDate;
  final int customExpReward;
  final int customGoldReward;
  final String priority;
  final int hpPenalty;
  final bool isSkipped;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.difficulty,
    this.tags = const [],
    this.isCompleted = false,
    this.completedAt,
    this.dueDate,
    this.repeatDays = const [],
    this.streak = 0,
    this.lastStreakDate,
    this.customExpReward = 0,
    this.customGoldReward = 0,
    this.priority = '',
    this.hpPenalty = 10,
    this.isSkipped = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['desc'] as String?,
        type: AppConstants.taskTypeFromInt(json['type']),
        difficulty: json['diff'] as String,
        tags: (json['tags'] as List?)?.cast<String>() ?? [],
        isCompleted: json['done'] as bool? ?? false,
        completedAt: json['doneAt'] != null ? DateTime.parse(json['doneAt'] as String) : null,
        dueDate: json['due'] != null ? DateTime.parse(json['due'] as String) : null,
        repeatDays: (json['repeat'] as List?)?.cast<int>() ?? [],
        streak: json['streak'] as int? ?? 0,
        lastStreakDate: json['streakDate'] != null ? DateTime.parse(json['streakDate'] as String) : null,
        customExpReward: json['exp'] as int? ?? 0,
        customGoldReward: json['gold'] as int? ?? 0,
        priority: json['prio'] as String? ?? '',
        hpPenalty: json['hpPenalty'] as int? ?? 10,
        isSkipped: json['skipped'] as bool? ?? false,
        createdAt: DateTime.parse(json['created'] as String),
        updatedAt: json['updated'] != null ? DateTime.parse(json['updated'] as String) : null,
      );

  bool get isDueToday {
    if (type == TaskType.daily) {
      final today = DateTime.now().weekday - 1;
      return repeatDays.contains(today);
    }
    if (type == TaskType.todo && dueDate != null) {
      final now = DateTime.now();
      return dueDate!.isBefore(now.add(const Duration(days: 1)));
    }
    return type == TaskType.habit;
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskType? type,
    String? difficulty,
    List<String>? tags,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? dueDate,
    List<int>? repeatDays,
    int? streak,
    DateTime? lastStreakDate,
    int? customExpReward,
    int? customGoldReward,
    String? priority,
    int? hpPenalty,
    bool? isSkipped,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      TaskModel(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        type: type ?? this.type,
        difficulty: difficulty ?? this.difficulty,
        tags: tags ?? this.tags,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: completedAt ?? this.completedAt,
        dueDate: dueDate ?? this.dueDate,
        repeatDays: repeatDays ?? this.repeatDays,
        streak: streak ?? this.streak,
        lastStreakDate: lastStreakDate ?? this.lastStreakDate,
        customExpReward: customExpReward ?? this.customExpReward,
        customGoldReward: customGoldReward ?? this.customGoldReward,
        priority: priority ?? this.priority,
        hpPenalty: hpPenalty ?? this.hpPenalty,
        isSkipped: isSkipped ?? this.isSkipped,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'desc': description,
        'type': type.value,
        'diff': difficulty,
        'tags': tags,
        'done': isCompleted,
        'doneAt': completedAt?.toIso8601String(),
        'due': dueDate?.toIso8601String(),
        'repeat': repeatDays,
        'streak': streak,
        'streakDate': lastStreakDate?.toIso8601String(),
        'exp': customExpReward,
        'gold': customGoldReward,
        'prio': priority,
        'hpPenalty': hpPenalty,
        'skipped': isSkipped,
        'created': createdAt.toIso8601String(),
        'updated': updatedAt?.toIso8601String(),
      };
}
