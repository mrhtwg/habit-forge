import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/animation/frame_sequence_player.dart';
import 'package:habit_forge_app/core/constants/env_constants.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/services/firebase_auth_service.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/features/auth/controllers/auth_controller.dart';

class AuthPage extends GetView<AuthController> {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8FD4FF), Color(0xFFC8ECFF), Color(0xFFE4F6FF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 160.h),
                // Knight idle animation
                FrameSequencePlayer(
                  frames: FrameSequencePlayer.knightIdleFrames(),
                  preferredSize: Size(180.h, 200.h),
                ),
                SizedBox(height: 10.h),
                Text(
                  'HABIT FORGE',
                  style: textStyleBlack(fontSize: 28.sp, color: AppColors.textPrimary),
                ),
                SizedBox(height: 8.h),
                Text(
                  LanKey.yourHabitsYourLegend.tr,
                  style: textStyleHand(fontSize: 18.sp, color: AppColors.textSecondary),
                ),
                SizedBox(height: 50.h),

                // Firebase mode: Google Sign-In only (other methods come later)
                if (EnvConstants.isAuthFirebase())
                  _SocialButton(
                    icon: Icons.g_mobiledata_rounded,
                    label: LanKey.continueWithGoogle.tr,
                    onTap: () => controller.loginWithGoogle(),
                    textColor: AppColors.textPrimary,
                    backgroundColor: Colors.white,
                  ),
                if (EnvConstants.isAuthFirebase()) SizedBox(height: 14.h),

                // Server mode: email/password login (registration inside the form)
                if (EnvConstants.isAuthServer())
                  _SocialButton(
                    icon: Icons.email_rounded,
                    label: LanKey.continueWithEmail.tr,
                    onTap: () => Get.toNamed(Routers.emailLogin),
                    textColor: Colors.white,
                    backgroundColor: AppColors.primary,
                  ),

                // Guest skip
                if (!FirebaseAuthService.to.isAvailable)
                  Padding(
                    padding: EdgeInsets.only(top: 20.h),
                    child: TextButton(
                      onPressed: () => controller.skipLogin(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            LanKey.skipForNow.tr,
                            style: textStyleBold(fontSize: 14.sp, color: AppColors.textSecondary),
                          ),
                          SizedBox(width: 4.w),
                          Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),

                // SizedBox(height: 24.h),
                const Spacer(),
                Text(
                  LanKey.termsAndPrivacy.tr,
                  textAlign: TextAlign.center,
                  style: textStyleRegular(fontSize: 11.sp, color: AppColors.textSecondary),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color textColor;
  final Color backgroundColor;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.textColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Obx(() {
        final loading = AuthController.to.isLoading.value;
        return ElevatedButton(
          onPressed: loading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            disabledBackgroundColor: AppColors.surface.withValues(alpha: 0.5),
            padding: EdgeInsets.symmetric(vertical: 15.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(48.r),
              side: BorderSide(color: AppColors.border, width: 2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20.w, color: textColor),
              SizedBox(width: 10.w),
              Text(
                label,
                style: textStyleBold(fontSize: 15.sp, color: textColor),
              ),
            ],
          ),
        );
      }),
    );
  }
}
