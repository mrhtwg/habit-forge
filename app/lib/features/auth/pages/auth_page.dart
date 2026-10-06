import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/animation/frame_sequence_player.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/features/auth/controllers/auth_controller.dart';
import 'package:habit_forge_app/widgets/terms_privacy_footer.dart';

/// Full-screen sign-in, used as the **startup gate** in cloud builds.
///
/// The gate exists because a returning player must be able to reach their
/// account without hunting for Settings — the app used to start straight into
/// guest mode and bury sign-in one screen deep. Signing in is still optional:
/// `Continue as guest` keeps the local-first path untouched.
///
/// Also reachable from the legacy boarding back-button (hence [asGate] is a
/// parameter rather than a separate page).
class AuthPage extends GetView<AuthController> {
  const AuthPage({super.key, this.asGate = false});

  /// True when this page is the app's entry point (startup gate).
  final bool asGate;

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
                // As the startup gate there is nothing behind this page; when it is
                // opened from the legacy boarding flow, offer a way back out.
                SizedBox(
                  height: 44.h,
                  child: asGate
                      ? null
                      : Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              width: 36.w,
                              height: 36.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: AppColors.border, width: 2),
                              ),
                              child: const Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.textPrimary),
                            ),
                          ),
                        ),
                ),
                SizedBox(height: 116.h),
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
                // Disabled while a flow is running: a second tap would ask
                // Credential Manager for a second sheet while the first one is
                // closing, which Android reports as
                // "onCancelled at PHASE_CLIENT_ALREADY_HIDDEN".
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          controller.isLoading.value ? null : () => controller.signInWithGoogleFromSettings(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.textPrimary,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(48.r),
                          side: BorderSide(color: AppColors.border, width: 2),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: const CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(LanKey.continueWithGoogle.tr, style: textStyleBold(fontSize: 15.sp)),
                    ),
                  ),
                ),
                // Guest path: no account, progress stays on this device. Kept as a
                // first-class option (not a hidden skip) because optional sign-in
                // is a retention feature — but the note says plainly what it costs.
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          key: const ValueKey('continue-as-guest'),
                          onPressed: controller.isLoading.value ? null : () => controller.continueAsGuest(context),
                          child: Text(
                            LanKey.continueAsGuest.tr,
                            style: textStyleBold(fontSize: 14.sp, color: AppColors.textPrimary),
                          ),
                        ),
                      ),
                      Text(
                        LanKey.guestModeNote.tr,
                        textAlign: TextAlign.center,
                        style: textStyleRegular(fontSize: 11.sp, color: AppColors.textSecondary),
                      ),
                    ],
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
