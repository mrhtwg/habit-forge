import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/network/hive/game_constants.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/generated/assets.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.dart';

/// Bright cartoon "task ticket" card (shared by the home / tasks pages).
class TaskTicket extends StatelessWidget {
  final Task task;
  final VoidCallback onComplete;
  final VoidCallback? onLongPress;

  const TaskTicket({
    super.key,
    required this.task,
    required this.onComplete,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final done = task.isCompleted;
    final tagColor = _tagColors();
    final exp = task.customExpReward > 0 ? task.customExpReward : GameConstants.baseExpReward(task.difficulty);
    final gold = task.customGoldReward > 0 ? task.customGoldReward : GameConstants.baseGoldReward(task.difficulty);

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: done ? const Color(0xFFEAF8EF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 2),
          boxShadow: const [BoxShadow(color: Color(0xFFEFDFC4), offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            // Complete check button
            GestureDetector(
              onTap: done ? null : onComplete,
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? AppColors.green : Colors.white,
                  border: Border.all(color: AppColors.border, width: 2.5),
                  boxShadow: const [BoxShadow(color: Color(0xFFE9D9BE), offset: Offset(0, 3))],
                ),
                child: done ? const Icon(Icons.check_rounded, color: Colors.white, size: 24) : null,
              ),
            ),
            SizedBox(width: 12.w),
            // Title + metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textStyleBold(
                      fontSize: 14.sp,
                      color: done ? AppColors.textMuted : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: tagColor.$1,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(_typeLabel(), style: textStyleBold(fontSize: 10.sp, color: tagColor.$2)),
                      ),
                      if (task.streak > 0) ...[
                        SizedBox(width: 8.w),
                        Text(
                          '🔥 ${task.streak}',
                          style: textStyleBold(fontSize: 11.sp, color: const Color(0xFFE9852C)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Rewards
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _rewardChip(icon: Assets.imagesSharedIcExp, text: '+$exp', color: AppColors.goldLight),
                SizedBox(height: 5.h),
                _rewardChip(icon: Assets.imagesSharedIcGold, text: '+$gold', color: AppColors.goldLight),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rewardChip({required icon, required String text, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            icon,
            width: 12.w,
            height: 12.w,
          ),
          SizedBox(width: 2.w),
          Text(text, style: textStyleBold(fontSize: 11.sp, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  (Color, Color) _tagColors() {
    switch (task.type) {
      case TaskType.TASK_TYPE_DAILY:
        return (const Color(0xFFD9F0FF), const Color(0xFF2673C9));
      case TaskType.TASK_TYPE_TODO:
        return (const Color(0xFFFFE3E3), const Color(0xFFD34F4F));
      default:
        return (AppColors.violetLight, AppColors.primaryDark);
    }
  }

  String _typeLabel() {
    switch (task.type) {
      case TaskType.TASK_TYPE_DAILY:
        return LanKey.dailyBadge.tr;
      case TaskType.TASK_TYPE_TODO:
        return LanKey.todoBadge.tr;
      default:
        return LanKey.habitBadge.tr;
    }
  }
}
