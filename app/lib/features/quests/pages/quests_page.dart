import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/constants/app_constants.dart';
import 'package:habit_forge_app/core/extensions/task_extensions.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/features/quests/controllers/quests_controller.dart';
import 'package:habit_forge_app/features/quests/pages/task_form_sheet.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/widgets/pressable_button.dart';
import 'package:habit_forge_app/widgets/task_ticket.dart';

class QuestsPage extends GetView<QuestsController> {
  const QuestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Stack(
        children: [
          DefaultTabController(
            length: 4,
            child: Column(
              children: [
                _buildSkyHeader(),
                _buildCategoryTabs(),
                _buildTagChips(),
                Expanded(
                  child: TabBarView(
                    children: List.generate(4, (index) => _buildTaskPage(context, index)),
                  ),
                ),
              ],
            ),
          ),
          // Add task FAB
          Positioned(
            bottom: 24.h,
            right: 20.w,
            child: PressableButton(
              onTap: () => TaskFormSheet.show(context),
              // 14 + 28 icon + 14 = 56 (circular)
              padding: EdgeInsets.all(14.w),
              borderWidth: 2.5,
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96.w,
            height: 96.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.violetLight,
              border: Border.all(color: AppColors.border, width: 3),
            ),
            child: Icon(Icons.checklist_rounded, size: 44.w, color: AppColors.primaryDark),
          ),
          SizedBox(height: 14.h),
          Text(LanKey.noQuestsHereYet.tr, style: textStyleBold(fontSize: 20.sp)),
          SizedBox(height: 6.h),
          Text(
            LanKey.tapToForgeQuest.tr,
            style: textStyleMedium(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ─────────── Category tabs: All / Habit / Daily / ToDo ───────────
  Widget _buildCategoryTabs() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E7CE),
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(999),
        ),
        child: TabBar(
          indicatorSize: TabBarIndicatorSize.tab,
          dividerHeight: 0,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [BoxShadow(color: Color(0xFFE4D2B0), offset: Offset(0, 2))],
          ),
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: textStyleBold(fontSize: 13.sp),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          unselectedLabelStyle: textStyleBold(fontSize: 13.sp, color: AppColors.textSecondary),
          tabs: [
            Tab(text: LanKey.all.tr),
            Tab(text: LanKey.habit.tr),
            Tab(text: LanKey.daily.tr),
            Tab(text: LanKey.todoFilter.tr),
          ],
        ),
      ),
    );
  }

  // ─────────── Sky header: title + today's count ───────────
  Widget _buildSkyHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8FD4FF), Color(0xFFC8ECFF), Color(0xFFE4F6FF)],
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h + MediaQuery.of(Get.context!).padding.top, 20.w, 18.h),
      child: Row(
        children: [
          Text(LanKey.quests.tr, style: textStyleBlack(fontSize: 26.sp, color: AppColors.textPrimary)),
          const Spacer(),
          Obx(() {
            final n = controller.tasks.where((t) => !t.isSkipped && t.isDueToday).length;
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.border, width: 2),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(color: Color(0xFFD6C3A4), offset: Offset(0, 3))],
              ),
              child: Text(
                LanKey.questCountToday.trParams({'n': '$n'}),
                style: textStyleBold(fontSize: 13.sp, color: AppColors.textSecondary),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─────────── Tag filter chips ───────────
  Widget _buildTagChips() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 4.h),
      child: Obx(
        () => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', ...AppConstants.taskTags].map((tag) {
              final tagKey = tag.toLowerCase();
              final isActive = controller.activeTag.value == tagKey;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () => controller.activeTag.value = tagKey,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.border, width: 2),
                    ),
                    child: Text(
                      tag,
                      style: textStyleBold(
                        fontSize: 12.sp,
                        color: isActive ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskPage(BuildContext context, int index) {
    // Page order matches the tabs: all / habit / daily / todo.
    final type = switch (index) {
      1 => TaskType.TASK_TYPE_HABIT,
      2 => TaskType.TASK_TYPE_DAILY,
      3 => TaskType.TASK_TYPE_TODO,
      _ => null,
    };
    return Obx(() {
      final tasks = controller.tasksFor(type);
      if (tasks.isEmpty) return _buildEmptyState(context);
      return ListView.separated(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 90.h),
        itemCount: tasks.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (context, i) {
          final task = tasks[i];
          return TaskTicket(
            task: task,
            onComplete: () => controller.toggleComplete(task),
            onLongPress: () => _showTaskMenu(context, task),
          );
        },
      );
    });
  }

  Widget _menuItem({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.elevated, width: 1)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            SizedBox(width: 12.w),
            Text(label, style: textStyleBold(fontSize: 15.sp, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  void _showTaskMenu(BuildContext context, Task task) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(task.title, style: textStyleBold(fontSize: 18.sp)),
            SizedBox(height: 16.h),
            _menuItem(
              icon: Icons.skip_next_rounded,
              color: AppColors.warning,
              label: LanKey.skip.tr,
              onTap: () {
                Get.back();
                controller.toggleSkip(task);
              },
            ),
            _menuItem(
              icon: Icons.schedule_rounded,
              color: AppColors.info,
              label: LanKey.postponeToTomorrow.tr,
              onTap: () {
                Get.back();
                controller.onTaskPostpone(task);
              },
            ),
            _menuItem(
              icon: Icons.delete_rounded,
              color: AppColors.error,
              label: LanKey.delete.tr,
              onTap: () {
                Get.back();
                controller.deleteTask(task.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
