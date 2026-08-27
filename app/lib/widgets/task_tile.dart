import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habit_forge_app/core/i18n/app_locale.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_spacing.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/generated/assets.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.dart';
import 'package:intl/intl.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;
  final VoidCallback? onPostpone;
  final VoidCallback? onDelete;

  const TaskTile({
    super.key,
    required this.task,
    this.onComplete,
    this.onSkip,
    this.onPostpone,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isHabit = task.type == 'habit';

    final card = Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.elevated, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isHabit ? _buildHabitContent() : _buildRegularContent(),
    );

    if (!task.isCompleted) {
      return Slidable(
        key: ValueKey('task_${task.id}'),
        // Left swipe → Complete (green)
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) => onComplete?.call(),
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              icon: Icons.check_rounded,
              label: LanKey.done.tr,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
          ],
        ),
        // Right swipe → Skip (orange) + Postpone (gray)
        startActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.5,
          children: [
            SlidableAction(
              onPressed: (_) => onSkip?.call(),
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              icon: Icons.skip_next_rounded,
              label: LanKey.skip.tr,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.cardRadius),
                bottomLeft: Radius.circular(AppSpacing.cardRadius),
              ),
            ),
            SlidableAction(
              onPressed: (_) => onPostpone?.call(),
              backgroundColor: AppColors.textMuted,
              foregroundColor: Colors.white,
              icon: Icons.schedule_rounded,
              label: LanKey.postpone.tr,
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => _showBottomSheet(context),
          child: card,
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showBottomSheet(context),
      child: card,
    );
  }

  int _baseExp(TaskDifficulty diff) {
    switch (diff) {
      case TaskDifficulty.TASK_DIFFICULTY_EASY:
        return 15;
      case TaskDifficulty.TASK_DIFFICULTY_MEDIUM:
        return 30;
      case TaskDifficulty.TASK_DIFFICULTY_HARD:
        return 50;
      default:
        return 15;
    }
  }

  int _baseGold(TaskDifficulty diff) {
    switch (diff) {
      case TaskDifficulty.TASK_DIFFICULTY_EASY:
        return 5;
      case TaskDifficulty.TASK_DIFFICULTY_MEDIUM:
        return 10;
      case TaskDifficulty.TASK_DIFFICULTY_HARD:
        return 20;
      default:
        return 5;
    }
  }

  Widget _buildDifficultyDots() {
    if (task.isCompleted) {
      return _dotRow(AppColors.border, AppColors.border, AppColors.border);
    }

    switch (task.difficulty) {
      case TaskDifficulty.TASK_DIFFICULTY_EASY:
        return _dotRow(AppColors.green.withValues(alpha: 0.8), AppColors.border, AppColors.border);
      case TaskDifficulty.TASK_DIFFICULTY_MEDIUM:
        return _dotRow(
          AppColors.warning.withValues(alpha: 0.8),
          AppColors.warning.withValues(alpha: 0.8),
          AppColors.border,
        );
      case TaskDifficulty.TASK_DIFFICULTY_HARD:
        return _dotRow(
          AppColors.red.withValues(alpha: 0.8),
          AppColors.red.withValues(alpha: 0.8),
          AppColors.red.withValues(alpha: 0.8),
        );
      default:
        return _dotRow(AppColors.border, AppColors.border, AppColors.border);
    }
  }

  Widget _buildHabitContent() {
    return Row(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onComplete,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.green, width: 2),
                  color: task.isCompleted ? AppColors.green : Colors.transparent,
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                    : const Icon(Icons.add, size: 16, color: AppColors.green),
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: onSkip,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.red, width: 2),
                ),
                child: const Icon(Icons.remove, size: 16, color: AppColors.red),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: textStyleRegular(color: task.isCompleted ? AppColors.textMuted : AppColors.textPrimary)
                    .copyWith(decoration: task.isCompleted ? TextDecoration.lineThrough : null),
              ),
              const SizedBox(height: 4),
              _buildDifficultyDots(),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '+${_expReward()} EXP',
          style: textStyleRegular(fontSize: 11, color: AppColors.gold),
        ),
      ],
    );
  }

  Widget _buildPriorityChip() {
    Color chipColor;
    switch (task.priority) {
      case 'P1':
        chipColor = AppColors.red;
        break;
      case 'P2':
        chipColor = AppColors.warning;
        break;
      case 'P3':
        chipColor = AppColors.textMuted;
        break;
      default:
        chipColor = AppColors.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        task.priority,
        style: textStyleBold(fontSize: 9, color: chipColor),
      ),
    );
  }

  Widget _buildPriorityRow() {
    final children = <Widget>[
      _buildDifficultyDots(),
    ];

    if (task.priority.isNotEmpty) {
      children.add(const SizedBox(width: 8));
      children.add(_buildPriorityChip());
    }

    if (task.type != 'habit') {
      children.add(const SizedBox(width: 8));
      children.add(
        Text(
          '📅 ${DateFormat('MMM d', AppLocale.languageCode()).format(DateTime(task.dueDate.toInt()))}',
          style: textStyleRegular(fontSize: 10, color: AppColors.textMuted),
        ),
      );
    }

    return Row(
      children: children,
    );
  }

  Widget _buildRegularContent() {
    return Row(
      children: [
        GestureDetector(
          onTap: onComplete,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: task.isCompleted ? AppColors.green : AppColors.textMuted,
                width: 2,
              ),
              color: task.isCompleted ? AppColors.green : Colors.transparent,
            ),
            child: task.isCompleted ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: textStyleRegular(color: task.isCompleted ? AppColors.textMuted : AppColors.textPrimary)
                    .copyWith(decoration: task.isCompleted ? TextDecoration.lineThrough : null),
              ),
              const SizedBox(height: 4),
              _buildPriorityRow(),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildRewardColumn(),
      ],
    );
  }

  Widget _buildRewardColumn() {
    final exp = _expReward();
    final gold = _goldReward();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '+$exp EXP',
          style: textStyleRegular(fontSize: 11, color: AppColors.gold),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(Assets.imagesSharedIcGold, width: 11, height: 11),
            const SizedBox(width: 3),
            Text(
              '+$gold',
              style: textStyleRegular(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _dotRow(Color first, Color second, Color third) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dot(first),
        const SizedBox(width: 4),
        _dot(second),
        const SizedBox(width: 4),
        _dot(third),
      ],
    );
  }

  int _expReward() {
    if (task.customExpReward > 0) return task.customExpReward;
    return _baseExp(task.difficulty);
  }

  int _goldReward() {
    if (task.customGoldReward > 0) return task.customGoldReward;
    return _baseGold(task.difficulty);
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _TaskDetailSheet(
        task: task,
        onDelete: onDelete,
      ),
    );
  }
}

class _TaskDetailSheet extends StatelessWidget {
  final Task task;
  final VoidCallback? onDelete;

  const _TaskDetailSheet({
    required this.task,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title + type badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: textStyleBold(fontSize: 18, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
              _buildTypeBadge(),
            ],
          ),

          // Description
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              task.description,
              style: textStyleRegular(fontSize: 14, color: AppColors.textSecondary).copyWith(height: 1.4),
            ),
          ],

          const SizedBox(height: 16),

          // Detail chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (task.priority.isNotEmpty)
                _detailChip(
                  _priorityColor(task.priority),
                  LanKey.priorityLabel.trParams({'value': task.priority}),
                  Icons.flag_rounded,
                ),
              _detailChip(
                _difficultyColor(task.difficulty),
                LanKey.difficultyFor(task.difficulty).tr,
                Icons.speed_rounded,
              ),
              if (task.type != TaskType.TASK_TYPE_HABIT)
                _detailChip(
                  AppColors.info,
                  DateFormat('MMM d, yyyy', AppLocale.languageCode()).format(DateTime(task.dueDate.toInt())),
                  Icons.calendar_today_rounded,
                ),
              _detailChip(
                AppColors.textMuted,
                LanKey.taskType(task.type.name).tr,
                task.type == TaskType.TASK_TYPE_HABIT ? Icons.loop_rounded : Icons.task_alt_rounded,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Rewards
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.elevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _rewardItem(
                  '+${_calcExp(task)} EXP',
                  AppColors.gold,
                  const Icon(Icons.star_rounded, size: 16, color: AppColors.gold),
                ),
                _rewardItem(
                  '+${_calcGold(task)}',
                  AppColors.textSecondary,
                  Image.asset(Assets.imagesSharedIcGold, width: 16, height: 16),
                ),
                if (task.hpPenalty > 0)
                  _rewardItem(
                    '-${task.hpPenalty} HP',
                    AppColors.red,
                    const Icon(Icons.favorite_border_rounded, size: 16, color: AppColors.red),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Delete button
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _confirmDelete(context);
              },
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
              label: Text(
                LanKey.deleteTask.tr,
                style: textStyleSemiBold(color: AppColors.error),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge() {
    final color = task.type == 'habit' ? AppColors.green : AppColors.primary;
    final label = task.type == 'habit'
        ? LanKey.habit.tr
        : task.type == 'daily'
            ? LanKey.daily.tr
            : LanKey.todo.tr;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: textStyleSemiBold(fontSize: 11, color: color),
      ),
    );
  }

  int _calcExp(Task t) {
    if (t.customExpReward > 0) return t.customExpReward;
    switch (t.difficulty) {
      case TaskDifficulty.TASK_DIFFICULTY_EASY:
        return 15;
      case TaskDifficulty.TASK_DIFFICULTY_MEDIUM:
        return 30;
      case TaskDifficulty.TASK_DIFFICULTY_HARD:
        return 50;
      default:
        return 15;
    }
  }

  int _calcGold(Task t) {
    if (t.customGoldReward > 0) return t.customGoldReward;
    switch (t.difficulty) {
      case TaskDifficulty.TASK_DIFFICULTY_EASY:
        return 5;
      case TaskDifficulty.TASK_DIFFICULTY_MEDIUM:
        return 10;
      case TaskDifficulty.TASK_DIFFICULTY_HARD:
        return 20;
      default:
        return 5;
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(LanKey.deleteTask.tr, style: textStyleRegular(color: AppColors.textPrimary)),
        content: Text(
          LanKey.deleteConfirm.trParams({'title': task.title}),
          style: textStyleRegular(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(LanKey.cancel.tr),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete?.call();
            },
            child: Text(LanKey.delete.tr, style: textStyleBold(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _detailChip(Color color, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: textStyleMedium(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }

  Color _difficultyColor(TaskDifficulty diff) {
    switch (diff) {
      case TaskDifficulty.TASK_DIFFICULTY_EASY:
        return AppColors.green;
      case TaskDifficulty.TASK_DIFFICULTY_MEDIUM:
        return AppColors.warning;
      case TaskDifficulty.TASK_DIFFICULTY_HARD:
        return AppColors.red;
      default:
        return AppColors.textMuted;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'P1':
        return AppColors.red;
      case 'P2':
        return AppColors.warning;
      case 'P3':
        return AppColors.textMuted;
      default:
        return AppColors.textMuted;
    }
  }

  Widget _rewardItem(String text, Color color, Widget icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 6),
        Text(
          text,
          style: textStyleSemiBold(fontSize: 13, color: color),
        ),
      ],
    );
  }
}
