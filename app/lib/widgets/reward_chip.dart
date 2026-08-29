import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/generated/assets.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';

class RewardChip extends StatelessWidget {
  final SysMaterial sysMaterial;
  final int value;

  const RewardChip({
    super.key,
    required this.sysMaterial,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.goldLight,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon(icon, size: 14.w, color: AppColors.goldDark),
          Image.asset(
            switch (sysMaterial) {
              SysMaterial.SYSMATERIAL_GOLD => Assets.imagesSharedIcGold,
              SysMaterial.SYSMATERIAL_GEM => Assets.imagesSharedIcGem,
              SysMaterial.SYSMATERIAL_EXP => Assets.imagesSharedIcExp,
              _ => Assets.imagesSharedIcGold
            },
            width: 14.w,
            height: 14.w,
          ),
          SizedBox(width: 3.w),
          Text(value.toString(), style: textStyleBold(fontSize: 12.sp, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
