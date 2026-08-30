import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/features/profile/controllers/profile_controller.dart';
import 'package:habit_forge_app/features/statistics/controllers/statistics_controller.dart';

class StatisticsPage extends GetView<StatisticsController> {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Obx(() {
                final allTasks = NetworkRegistry.ins.tasks;
                final now = DateTime.now();

                final DateTime currentCutoff = switch (controller.period) {
                  TimePeriod.week => now.subtract(const Duration(days: 7)),
                  TimePeriod.month => now.subtract(const Duration(days: 30)),
                  TimePeriod.all => DateTime(2000),
                };
                final Duration periodDuration = switch (controller.period) {
                  TimePeriod.week => const Duration(days: 7),
                  TimePeriod.month => const Duration(days: 30),
                  TimePeriod.all => const Duration(days: 0),
                };
                final prevCutoff = periodDuration.inDays > 0 ? currentCutoff.subtract(periodDuration) : currentCutoff;

                final currentCompleted =
                    allTasks.where((t) => DateTime(t.completedAt.toInt()).isAfter(currentCutoff)).toList();
                final prevCompleted = allTasks
                    .where(
                      (t) =>
                          DateTime(t.completedAt.toInt()).isAfter(prevCutoff) &&
                          DateTime(t.completedAt.toInt()).isBefore(currentCutoff),
                    )
                    .toList();
                final totalCompleted = currentCompleted.length;
                final rateChange = prevCompleted.length > 0
                    ? ((totalCompleted - prevCompleted.length) / prevCompleted.length * 100).round()
                    : 0;

                const weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                final weekdayCounts = List.filled(7, 0);
                for (final t in currentCompleted) {
                  weekdayCounts[(DateTime(t.completedAt.toInt()).weekday - 1) % 7]++;
                }
                final maxCount = weekdayCounts.reduce((a, b) => a > b ? a : b);

                final streaks = allTasks.where((t) => t.streak > 0).toList()
                  ..sort((a, b) => b.streak.compareTo(a.streak));
                final topStreaks = streaks.take(5).toList();

                final profile = Get.find<ProfileController>();
                final char = NetworkRegistry.ins.character.value;
                final totalXp = char?.currentExp ?? 0;

                return ListView(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                  children: [
                    // Time segment
                    _buildTimeToggle(),
                    SizedBox(height: 16.h),
                    // KPI
                    Row(
                      children: [
                        _kpiCard(
                          '$totalCompleted',
                          LanKey.tasksDONE.tr,
                          controller.period != TimePeriod.all && rateChange != 0
                              ? '${rateChange >= 0 ? '↑' : '↓'} ${rateChange.abs()}%'
                              : null,
                          AppColors.greenDark,
                        ),
                        SizedBox(width: 10.w),
                        _kpiCard(
                          '${(profile.totalTasksCompleted / (allTasks.length == 0 ? 1 : allTasks.length) * 100).round()}%',
                          LanKey.completion.tr,
                          null,
                          AppColors.info,
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        _kpiCard(
                          '${profile.maxStreak}d',
                          LanKey.daySTREAK.tr,
                          LanKey.bestYet.tr,
                          const Color(0xFFE9852C),
                        ),
                        SizedBox(width: 10.w),
                        _kpiCard(
                          '$totalXp',
                          LanKey.totalXP.tr,
                          LanKey.levelHeroLabel.trParams({'level': '${char?.level ?? 1}'}),
                          AppColors.primaryDark,
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    // Bar chart
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border, width: 2),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Color(0xFFEFDFC4), offset: Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(LanKey.questsCompleted.tr, style: textStyleBold(fontSize: 15.sp)),
                              const Spacer(),
                              Text(
                                LanKey.last7Days.tr,
                                style: textStyleBold(fontSize: 11.sp, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          SizedBox(
                            height: 130.h,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(7, (i) {
                                final count = weekdayCounts[i];
                                final h = maxCount == 0 ? 0.04 : count / maxCount;
                                final isHot = weekdayCounts[i] == maxCount && maxCount > 0;
                                return Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                                        height: 130.h * h,
                                        decoration: BoxDecoration(
                                          color: isHot ? AppColors.primary : AppColors.gold,
                                          border: Border.all(color: AppColors.border, width: 2),
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        weekdayLabels[i],
                                        style: textStyleBold(fontSize: 10.sp, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // Streak leaderboard
                    Text(LanKey.streaks.tr, style: textStyleBold(fontSize: 18.sp)),
                    SizedBox(height: 10.h),
                    if (topStreaks.isEmpty)
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.border, width: 2),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            LanKey.noStreaksYet.tr,
                            style: textStyleMedium(fontSize: 13.sp, color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      ...topStreaks.map(
                        (t) => Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: AppColors.border, width: 2),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [BoxShadow(color: Color(0xFFEFDFC4), offset: Offset(0, 3))],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 38.w,
                                  height: 38.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.goldLight,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border, width: 1.5),
                                  ),
                                  child: const Icon(
                                    Icons.local_fire_department_rounded,
                                    size: 20,
                                    color: Color(0xFFE9852C),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    t.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textStyleBold(fontSize: 14.sp, color: AppColors.textPrimary),
                                  ),
                                ),
                                Text(
                                  '${t.streak}d',
                                  style: textStyleBold(fontSize: 16.sp, color: const Color(0xFFE9852C)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 18.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: AppColors.border, width: 2.5),
                boxShadow: const [BoxShadow(color: Color(0xFFD6C3A4), offset: Offset(0, 3))],
              ),
              child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textPrimary),
            ),
          ),
          SizedBox(width: 10.w),
          Text(LanKey.statistics.tr, style: textStyleBlack(fontSize: 22.sp, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildTimeToggle() {
    final options = [
      (TimePeriod.week, LanKey.week.tr),
      (TimePeriod.month, LanKey.month.tr),
      (TimePeriod.all, LanKey.all.tr),
    ];
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E7CE),
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: options.map((opt) {
          final isActive = controller.period == opt.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.changePeriod(opt.$1),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: isActive ? const [BoxShadow(color: Color(0xFFE4D2B0), offset: Offset(0, 2))] : null,
                ),
                child: Text(
                  opt.$2,
                  textAlign: TextAlign.center,
                  style: textStyleBold(
                    fontSize: 13.sp,
                    color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _kpiCard(String value, String label, String? extra, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Color(0xFFEFDFC4), offset: Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: textStyleBold(fontSize: 22.sp, color: AppColors.textPrimary)),
            SizedBox(height: 2.h),
            Text(label, style: textStyleBold(fontSize: 10.sp, color: AppColors.textSecondary)),
            if (extra != null) ...[
              SizedBox(height: 2.h),
              Text(extra, style: textStyleBold(fontSize: 10.sp, color: color)),
            ],
          ],
        ),
      ),
    );
  }
}
