import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/generated/assets.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/widgets/animated_number_text.dart';

class WalletChip extends StatelessWidget {
  final SysMaterial sysMaterial;

  const WalletChip({
    super.key,
    required this.sysMaterial,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: sysMaterial == SysMaterial.SYSMATERIAL_GOLD ? AppColors.goldLight : const Color(0xFFEAF4FF),
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [BoxShadow(color: Color(0xFFE9D9BE), offset: Offset(0, 3))],
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
            width: 16.w,
            height: 16.w,
          ),
          SizedBox(width: 5.w),
          // Animated count: eases to the new balance whenever the wallet
          // changes (e.g. after completing a task on the home screen).
          Obx(() {
            final target = switch (sysMaterial) {
              SysMaterial.SYSMATERIAL_GOLD => UserService.to.gold.value,
              SysMaterial.SYSMATERIAL_GEM => UserService.to.gem.value,
              _ => 0,
            };
            return AnimatedNumberText(
              target,
              duration: const Duration(milliseconds: 2000),
              style: textStyleBold(fontSize: 14.sp, color: AppColors.textPrimary),
            );
          }),
        ],
      ),
    );
  }
}
