// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/generated/assets.dart';

class GainExpSheet extends StatelessWidget {
  final int expGained;
  final int goldGained;
  const GainExpSheet({
    Key? key,
    required this.expGained,
    required this.goldGained,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 18.h),
              // Status badge
              Container(
                width: 68.w,
                height: 68.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.green,
                  border: Border.all(color: AppColors.border, width: 3),
                  boxShadow: const [BoxShadow(color: Color(0x55E7B93F), blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 38.w,
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                LanKey.questComplete.tr,
                style: textStyleBold(fontSize: 14.sp, color: AppColors.primaryDark)
                    .copyWith(decoration: TextDecoration.none),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              Text(
                LanKey.niceWork.tr,
                style: textStyleHand(fontSize: 30.sp, color: AppColors.textPrimary)
                    .copyWith(decoration: TextDecoration.none),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              // Reward chips
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _rewardChip(
                    icon: Assets.imagesSharedIcExp,
                    text: LanKey.xpGained.trParams({'n': '$expGained'}),
                    bg: AppColors.goldLight,
                  ),
                  SizedBox(width: 10.w),
                  _rewardChip(
                    icon: Assets.imagesSharedIcGold,
                    text: LanKey.goldGained.trParams({'n': '$goldGained'}),
                    bg: AppColors.goldLight,
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rewardChip({required String icon, required String text, required Color bg}) {
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
