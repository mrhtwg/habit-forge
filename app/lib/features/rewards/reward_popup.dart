import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/animation/frame_sequence_player.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/generated/assets.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/widgets/gain_exp_sheet.dart';

class RewardPopup {
  static void show({
    required int expGained,
    required int goldGained,
    String? achievementName,
    int? newLevel,
    String type = 'task', // 'task' | 'levelUp' | 'achievement'
  }) {
    if (type == 'levelUp') {
      // Level-ups keep the celebratory centered dialog.
      final content = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, t, child) {
          return Transform.scale(
            scale: 0.5 + t * 0.5,
            // elasticOut overshoots above 1.0 during the settling wobble;
            // Opacity must stay within [0, 1], so clamp it.
            child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
          );
        },
        child: _buildLevelUpCard(expGained, goldGained, newLevel),
      );
      Get.dialog(
        Center(child: content),
        barrierColor: Colors.black.withValues(alpha: 0.55),
        transitionDuration: const Duration(milliseconds: 200),
      );
    } else {
      // Task/achievement rewards slide up as a full-width bottom sheet.
      Get.bottomSheet(
        GainExpSheet(expGained: expGained, goldGained: goldGained),
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.45),
        isScrollControlled: true,
      );
    }
  }

  /// Shows the reward after completing a task: task rewards slide up as a
  /// bottom sheet, level-ups keep the centered celebratory dialog.
  static void showTaskReward(CompleteTaskReply reply, int levelBefore) {
    final leveledUp = reply.character.level > levelBefore;
    if (leveledUp) {
      show(
        expGained: reply.expReward.toInt(),
        goldGained: reply.goldReward.toInt(),
        newLevel: reply.character.level,
        type: 'levelUp',
      );
    } else {
      show(
        expGained: reply.expReward.toInt(),
        goldGained: reply.goldReward.toInt(),
        type: 'task',
      );
    }
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
          // TODO(levelup): play a Victory animation once it's ready — the hero
          // stays on its idle frames for now.
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
              LanKey.awesome.tr,
              textAlign: TextAlign.center,
              style: textStyleBold(fontSize: 15.sp, color: AppColors.textPrimary)
                  .copyWith(decoration: TextDecoration.none),
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
          Image.asset(
            icon,
            width: 20.w,
            height: 20.w,
          ),
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
