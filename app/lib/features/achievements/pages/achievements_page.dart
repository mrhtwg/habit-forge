import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/achievements/achievement_catalog.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/features/achievements/controllers/achievements_controller.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';

class AchievementsPage extends GetView<AchievementsController> {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildWaterfall()),
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
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 20.w, 18.h),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(Get.context!).padding.top),
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
            Text(LanKey.achievements.tr, style: textStyleBlack(fontSize: 22.sp, color: AppColors.textPrimary)),
            const Spacer(),
            Obx(() {
              final n = controller.achievements.where((a) => a.isUnlocked).length;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.border, width: 2),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [BoxShadow(color: Color(0xFFD6C3A4), offset: Offset(0, 3))],
                ),
                child: Text(
                  '$n / ${controller.achievements.length}',
                  style: textStyleBold(fontSize: 13.sp, color: AppColors.textSecondary),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterfall() {
    return Obx(
      () => RefreshIndicator(
        onRefresh: controller.load,
        color: AppColors.primary,
        child: MasonryGridView.builder(
          gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          mainAxisSpacing: 10.h,
          crossAxisSpacing: 10.w,
          itemCount: controller.achievements.length,
          itemBuilder: (context, index) => Align(
            alignment: Alignment.topCenter,
            child: _achievementCard(controller.achievements[index]),
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 28.h),
        ),
      ),
    );
  }

  Widget _achievementCard(Achievement achievement) {
    final unlocked = achievement.isUnlocked;
    final color = AchievementCatalog.colorFor(achievement.conditionType);
    final progress = achievement.progress.clamp(0, achievement.threshold).toInt();
    final ratio = achievement.threshold == 0 ? 0.0 : progress / achievement.threshold;
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 12.h),
      decoration: BoxDecoration(
        color: unlocked ? Colors.white : const Color(0xFFF4EFE2),
        border: Border.all(color: unlocked ? color.withValues(alpha: 0.8) : AppColors.textMuted, width: 2),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: const [BoxShadow(color: Color(0xFFEFDFC4), offset: Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 142.w,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: unlocked ? 0.15 : 0.07),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Align(
                alignment: Alignment.center,
                child: unlocked
                    ? _buildIcon(achievement, color)
                    : Icon(
                        Icons.question_mark_rounded,
                        size: 82.w,
                        color: color.withValues(alpha: 0.6),
                      ),
              ),
            ),
          ),
          if (unlocked) ...[
            SizedBox(height: 9.h),
            Text(
              AchievementCatalog.title(achievement),
              style: textStyleBold(fontSize: 13.sp, color: unlocked ? AppColors.textPrimary : AppColors.textSecondary),
            ),
            SizedBox(height: 3.h),
            Text(
              AchievementCatalog.description(achievement),
              style: textStyleMedium(fontSize: 10.5.sp, color: AppColors.textSecondary).copyWith(height: 1.3),
            ),
            SizedBox(height: 9.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                minHeight: 6.h,
                value: ratio,
                backgroundColor: const Color(0xFFE4DCCF),
                valueColor: AlwaysStoppedAnimation(unlocked ? const Color(0xFF3FBE6B) : color),
              ),
            ),
            SizedBox(height: 5.h),
            Row(
              children: [
                Text(
                  '$progress / ${achievement.threshold}',
                  style: textStyleBold(fontSize: 9.5.sp, color: AppColors.textMuted),
                ),
                const Spacer(),
                Icon(Icons.diamond_rounded, size: 12.w, color: const Color(0xFF58B9E8)),
                SizedBox(width: 2.w),
                Text(
                  '+${achievement.gemReward}',
                  style: textStyleBold(fontSize: 9.5.sp, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon(Achievement achievement, Color color) {
    return Image.asset(
      AchievementCatalog.iconPath(achievement.id),
      width: 126.w,
      height: 126.w,
      alignment: Alignment.center,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(Icons.emoji_events_rounded, size: 42.w, color: color),
    );
  }
}
