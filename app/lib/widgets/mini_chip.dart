import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/generated/assets.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';

class MiniChip extends StatelessWidget {
  final SysMaterial sysMaterial;

  const MiniChip({
    super.key,
    required this.sysMaterial,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            switch (sysMaterial) {
              SysMaterial.SYSMATERIAL_GOLD => Assets.imagesSharedIcGold,
              SysMaterial.SYSMATERIAL_GEM => Assets.imagesSharedIcGem,
              _ => Assets.imagesSharedIcGold
            },
            width: 13.w,
            height: 13.w,
          ),
          SizedBox(width: 4.w),
          Text(
            switch (sysMaterial) {
              SysMaterial.SYSMATERIAL_GOLD => UserService.to.gold.value.toString(),
              SysMaterial.SYSMATERIAL_GEM => UserService.to.gem.value.toString(),
              _ => '0'
            },
            style: textStyleBold(fontSize: 12.sp, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
