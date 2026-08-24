import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';

class RewardPopup {
  static void show({
    required int expGained,
    required int goldGained,
    String? achievementName,
    int? newLevel,
    String type = 'task', // 'task' | 'levelUp' | 'achievement'
  }) {
    Get.dialog(
      Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (context, t, child) {
            return Transform.scale(
              scale: 0.5 + t * 0.5,
              child: Opacity(opacity: t, child: child),
            );
          },
          child: type == 'levelUp'
              ? _buildLevelUpCard(expGained, goldGained, newLevel)
              : _buildCard(expGained, goldGained, achievementName, type),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 200),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (Get.isDialogOpen ?? false) Get.back();
    });
  }

  // ─────────── Task/achievement reward card ───────────
  static Widget _buildCard(int expGained, int goldGained, String? achievementName, String type) {
    final isAchievement = type == 'achievement';
    return Container(
      width: 300.w,
      padding: EdgeInsets.fromLTRB(22.w, 28.h, 22.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border, width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0x663A2A4E), blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top gold badge
          Container(
            margin: EdgeInsets.only(top: -52.h),
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAchievement ? AppColors.gold : AppColors.green,
              border: Border.all(color: AppColors.border, width: 3),
              boxShadow: const [BoxShadow(color: Color(0xFFE7B93F), offset: Offset(0, 4))],
            ),
            child: Icon(
              isAchievement ? Icons.emoji_events_rounded : Icons.check_rounded,
              color: Colors.white,
              size: 44.w,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            isAchievement ? 'Achievement unlocked!' : 'Quest complete!',
            style: textStyleBold(fontSize: 14.sp, color: AppColors.primaryDark),
          ),
          SizedBox(height: 4.h),
          Text(
            isAchievement ? (achievementName ?? 'New achievement') : 'Nice work!',
            style: textStyleHand(fontSize: 30.sp, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 14.h),
          // Reward chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _rewardChip(icon: Icons.bolt_rounded, text: '+$expGained XP', bg: AppColors.goldLight),
              SizedBox(width: 10.w),
              _rewardChip(
                icon: Icons.star_rounded,
                text: isAchievement ? '+$goldGained gems' : '+$goldGained gold',
                bg: AppColors.goldLight,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Continue button
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.gold, AppColors.goldDark]),
              border: Border.all(color: AppColors.border, width: 2.5),
              borderRadius: BorderRadius.circular(999),
              boxShadow: const [BoxShadow(color: AppColors.goldDark, offset: Offset(0, 4))],
            ),
            child: Text(
              'Continue',
              textAlign: TextAlign.center,
              style: textStyleBold(fontSize: 15.sp, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────── Level-up card ───────────
  static Widget _buildLevelUpCard(int expGained, int goldGained, int? newLevel) {
    return Container(
      width: 300.w,
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment(0, -0.3),
          colors: [Color(0xFFFFE38A), AppColors.gold, AppColors.goldDark],
          stops: [0, 0.55, 1],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border, width: 3),
        boxShadow: const [BoxShadow(color: Color(0x663A2A4E), blurRadius: 24, offset: Offset(0, 10))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Your hero reached', style: textStyleBold(fontSize: 16.sp, color: const Color(0xFF7A4A00))),
          SizedBox(height: 6.h),
          Text(
            'LEVEL ${newLevel ?? ''}',
            style: textStyleBlack(fontSize: 44.sp, color: const Color(0xFF7A4A00)),
          ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _rewardChip(icon: Icons.bolt_rounded, text: '+$expGained XP', bg: Colors.white),
              SizedBox(width: 10.w),
              _rewardChip(icon: Icons.star_rounded, text: '+$goldGained gold', bg: Colors.white),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border, width: 2.5),
              borderRadius: BorderRadius.circular(999),
              boxShadow: const [BoxShadow(color: Color(0x55B56A00), offset: Offset(0, 4))],
            ),
            child: Text(
              'Awesome!',
              textAlign: TextAlign.center,
              style: textStyleBold(fontSize: 15.sp, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _rewardChip({required IconData icon, required String text, required Color bg}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: AppColors.border, width: 2.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0xFFEFDFC4), offset: Offset(0, 3))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20.w, color: AppColors.goldDark),
          SizedBox(width: 5.w),
          Text(text, style: textStyleBold(fontSize: 16.sp, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
