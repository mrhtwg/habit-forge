import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/features/auth/controllers/auth_controller.dart';

/// "You are playing as a guest" reminder, shown above the tab bar while the
/// game runs on this device only and no account is bound.
///
/// The guest path is deliberately the *cheap* one (no account, no cloud), which
/// also means an uninstall or a new phone loses everything — so the app has to
/// keep saying so, calmly and dismissibly. Tapping it opens the same Google
/// sign-in the login gate uses, which now offers to **merge** local progress
/// instead of overwriting it.
class AccountBindBanner extends StatelessWidget {
  const AccountBindBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Obx(() {
      if (auth.hasCloudIdentity) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 6.h),
        child: GestureDetector(
          key: const ValueKey('account-bind-banner'),
          onTap: auth.isLoading.value ? null : () => auth.signInWithGoogleFromSettings(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.goldLight,
              border: Border.all(color: AppColors.border, width: 2),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: Color(0xFFEFDFC4), offset: Offset(0, 3))],
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_off_rounded, size: 16.w, color: AppColors.goldDark),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    LanKey.bindAccountBanner.tr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textStyleBold(fontSize: 11.sp, color: AppColors.textPrimary),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    LanKey.bindNow.tr,
                    style: textStyleBold(fontSize: 11.sp, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
