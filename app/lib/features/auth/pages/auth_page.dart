import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/animation/frame_sequence_player.dart';
import 'package:habit_forge_app/core/constants/env_constants.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/features/auth/controllers/auth_controller.dart';
import 'package:habit_forge_app/features/auth/pages/email_login_sheet.dart';
import 'package:habit_forge_app/widgets/terms_privacy_footer.dart';

/// Legacy full-screen auth. Prefer Settings in-place sign-in.
/// Kept for deep links / older builds; hive mode should never land here.
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
                FrameSequencePlayer(
                  frames: FrameSequencePlayer.knightIdleFrames(),
                  preferredSize: Size(180.h, 200.h),
                ),
                SizedBox(height: 10.h),
                Text('HABIT FORGE', style: textStyleBlack(fontSize: 28.sp, color: AppColors.textPrimary)),
                SizedBox(height: 8.h),
                Text(
                  LanKey.yourHabitsYourLegend.tr,
                  style: textStyleHand(fontSize: 18.sp, color: AppColors.textSecondary),
                ),
                SizedBox(height: 50.h),
                if (EnvConstants.isAuthFirebase())
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => controller.signInWithGoogleFromSettings(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.textPrimary,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(48.r),
                          side: BorderSide(color: AppColors.border, width: 2),
                        ),
                      ),
                      child: Text(LanKey.continueWithGoogle.tr, style: textStyleBold(fontSize: 15.sp)),
                    ),
                  ),
                if (EnvConstants.isAuthServer())
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => EmailLoginSheet.show(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(48.r),
                          side: BorderSide(color: AppColors.border, width: 2),
                        ),
                      ),
                      child: Text(LanKey.continueWithEmail.tr, style: textStyleBold(fontSize: 15.sp, color: Colors.white)),
                    ),
                  ),
                const Spacer(),
                const TermsPrivacyFooter(),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
