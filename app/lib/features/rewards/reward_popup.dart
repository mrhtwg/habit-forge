import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/animation/frame_sequence_player.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/services/haptic_service.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/generated/assets.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/widgets/gain_exp_sheet.dart';

class RewardPopup {
  /// Task rewards → bottom sheet; level-ups → centered dialog.
  /// Returns when the player dismisses the UI.
  static Future<void> showTaskReward(CompleteTaskReply reply, int levelBefore) async {
    final leveledUp = reply.character.level > levelBefore;
    if (leveledUp) {
      await _showLevelUp(
        expGained: reply.expReward.toInt(),
        goldGained: reply.goldReward.toInt(),
        newLevel: reply.character.level,
      );
    } else {
      await Get.bottomSheet(
        GainExpSheet(expGained: reply.expReward.toInt(), goldGained: reply.goldReward.toInt()),
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.45),
        isScrollControlled: true,
      );
    }
  }

  /// Full-screen style unlock celebration (PRD FR-ACH-01 / mockup 22).
  static Future<void> showUnlockedAchievements(List<Achievement> unlocked) async {
    for (final achievement in unlocked) {
      if (Get.isRegistered<HapticService>()) {
        Get.find<HapticService>().heavy();
      }
      await Get.dialog(
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, t, child) {
              return Transform.scale(
                scale: 0.5 + t * 0.5,
                child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
              );
            },
            child: _buildAchievementCard(achievement),
          ),
        ),
        barrierColor: const Color(0xCC2E1A4E),
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 200),
      );
    }
  }

  static Future<void> _showLevelUp({
    required int expGained,
    required int goldGained,
    required int newLevel,
  }) {
    return Get.dialog(
      Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (context, t, child) {
            return Transform.scale(
              scale: 0.5 + t * 0.5,
              child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
            );
          },
          child: _buildLevelUpCard(expGained, goldGained, newLevel),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  // ─────────── Achievement unlock card ───────────
  static Widget _buildAchievementCard(Achievement achievement) {
    final gems = achievement.gemReward;
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
          Container(
            width: 88.w,
            height: 88.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.border, width: 3),
              boxShadow: const [BoxShadow(color: Color(0x55B56A00), offset: Offset(0, 5))],
            ),
            child: Icon(Icons.emoji_events_rounded, size: 48.w, color: AppColors.goldDark),
          ),
          SizedBox(height: 16.h),
          Text(
            LanKey.achievementUnlocked.tr,
            style: textStyleBold(fontSize: 14.sp, color: const Color(0xFF7A4A00))
                .copyWith(decoration: TextDecoration.none),
          ),
          SizedBox(height: 6.h),
          Text(
            LanKey.achievementTitle(achievement.id).tr,
            textAlign: TextAlign.center,
            style: textStyleBlack(fontSize: 26.sp, color: const Color(0xFF7A4A00))
                .copyWith(decoration: TextDecoration.none),
          ),
          SizedBox(height: 8.h),
          Text(
            LanKey.achievementDescription(achievement.id).tr,
            textAlign: TextAlign.center,
            style: textStyleMedium(fontSize: 13.sp, color: const Color(0xFF7A4A00))
                .copyWith(decoration: TextDecoration.none, height: 1.35),
          ),
          if (gems > 0) ...[
            SizedBox(height: 16.h),
            _rewardChip(
              icon: Assets.imagesSharedIcGem,
              text: LanKey.gemsGained.trParams({'n': '$gems'}),
              bg: Colors.white,
            ),
          ],
          SizedBox(height: 18.h),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.border, width: 2.5),
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [BoxShadow(color: Color(0x55B56A00), offset: Offset(0, 4))],
              ),
              child: Text(
                LanKey.awesome.tr,
                textAlign: TextAlign.center,
                style: textStyleBold(fontSize: 15.sp, color: AppColors.textPrimary)
                    .copyWith(decoration: TextDecoration.none),
              ),
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
          FrameSequencePlayer(
            frames: UserService.to.getCharacterFrame(),
            preferredSize: const Size(84, 92),
          ),
          SizedBox(height: 8.h),
          Text(
            LanKey.yourHeroReached.tr,
            style: textStyleBold(fontSize: 16.sp, color: const Color(0xFF7A4A00))
                .copyWith(decoration: TextDecoration.none),
          ),
          SizedBox(height: 6.h),
          Text(
            LanKey.levelValue.trParams({'n': '${newLevel ?? ''}'}),
            style: textStyleBlack(fontSize: 44.sp, color: const Color(0xFF7A4A00))
                .copyWith(decoration: TextDecoration.none),
          ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _rewardChip(
                icon: Assets.imagesSharedIcExp,
                text: LanKey.xpGained.trParams({'n': '$expGained'}),
                bg: Colors.white,
              ),
              SizedBox(width: 10.w),
              _rewardChip(
                icon: Assets.imagesSharedIcGold,
                text: LanKey.goldGained.trParams({'n': '$goldGained'}),
                bg: Colors.white,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.border, width: 2.5),
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [BoxShadow(color: Color(0x55B56A00), offset: Offset(0, 4))],
              ),
              child: Text(
                LanKey.awesome.tr,
                textAlign: TextAlign.center,
                style: textStyleBold(fontSize: 15.sp, color: AppColors.textPrimary)
                    .copyWith(decoration: TextDecoration.none),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _rewardChip({required String icon, required String text, required Color bg}) {
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
          Image.asset(icon, width: 20.w, height: 20.w),
          SizedBox(width: 5.w),
          Text(
            text,
            style:
                textStyleBold(fontSize: 16.sp, color: AppColors.textPrimary).copyWith(decoration: TextDecoration.none),
          ),
        ],
      ),
    );
  }
}
