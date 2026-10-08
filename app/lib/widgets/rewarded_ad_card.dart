import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/services/rewarded_ad_service.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/widgets/pressable_button.dart';
import 'package:habit_forge_app/widgets/toast_widget.dart';

class RewardedAdCard extends StatelessWidget {
  const RewardedAdCard({super.key});

  @override
  Widget build(BuildContext context) {
    final service = RewardedAdService.to;
    return Obx(() {
      final ready = service.isReady.value;
      final loading = service.isLoading.value;
      return Container(
        margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 10.h),
        padding: EdgeInsets.fromLTRB(12.w, 10.h, 10.w, 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4CF),
          border: Border.all(color: AppColors.goldDark, width: 2),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: const [BoxShadow(color: Color(0xFFE8C96B), offset: Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: AppColors.goldLight,
                border: Border.all(color: AppColors.goldDark, width: 1.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.ondemand_video_rounded, size: 22.w, color: AppColors.goldDark),
            ),
            SizedBox(width: 9.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(LanKey.rewardedAdTitle.tr, style: textStyleBold(fontSize: 13.sp, color: AppColors.textPrimary)),
                  SizedBox(height: 2.h),
                  Text(
                    LanKey.rewardedAdDescription.tr,
                    style: textStyleMedium(fontSize: 10.5.sp, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            PressableButton(
              onTap: ready
                  ? () async {
                      final granted = await service.showRewarded();
                      if (granted) {
                        Toast.success(LanKey.rewardedAdSuccess.tr);
                      } else {
                        Toast.warning(LanKey.rewardedAdFailed.tr);
                      }
                    }
                  : null,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              backgroundColor: ready ? AppColors.primary : AppColors.textMuted,
              shadowColor: ready ? AppColors.primaryDark : AppColors.textMuted,
              child: Text(
                loading ? LanKey.rewardedAdLoading.tr : LanKey.rewardedAdWatch.tr,
                style: textStyleBold(fontSize: 10.sp, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    });
  }
}
