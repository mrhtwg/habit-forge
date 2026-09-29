import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/network/hive/class_profiles.dart';
import 'package:habit_forge_app/core/services/death_recovery_service.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Death-state UI: a red recovery overlay while the hero is down, which the
/// player can dismiss into a compact countdown banner so the rest of the app
/// stays browsable. The revive itself is driven by [DeathRecoveryService].
///
/// Mount it as a child of a [Stack] (e.g. over the main tab shell) so the state
/// is visible from every tab.
class DeathOverlay extends StatefulWidget {
  const DeathOverlay({super.key});

  @override
  State<DeathOverlay> createState() => _DeathOverlayState();
}

class _DeathOverlayState extends State<DeathOverlay> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final char = UserService.to.character.value;
      if (char == null || !char.isDead) {
        // Re-arm for the next death.
        _dismissed = false;
        return const SizedBox.shrink();
      }
      final countdown = DeathRecoveryService.formatRemaining(DeathRecoveryService.to.secondsLeft.value);
      return _dismissed ? _buildBanner(countdown) : _buildOverlay(countdown);
    });
  }

  Widget _buildOverlay(String countdown) {
    final recoveryHp = ClassProfiles.of(UserService.to.character.value?.characterClass).recoveryHp;
    return Positioned.fill(
      child: Container(
        color: AppColors.coralDark.withValues(alpha: 0.94),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 26.w),
                padding: EdgeInsets.fromLTRB(24.w, 26.h, 24.w, 18.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.border, width: 3),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [BoxShadow(color: Color(0xFFB93B45), offset: Offset(0, 6))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PhosphorIcons.skull(PhosphorIconsStyle.fill), size: 54.w, color: AppColors.coralDark),
                    SizedBox(height: 12.h),
                    Text(LanKey.deathTitle.tr, style: textStyleBlack(fontSize: 24.sp)),
                    SizedBox(height: 8.h),
                    Text(
                      LanKey.deathBody.trParams({'hp': '$recoveryHp'}),
                      textAlign: TextAlign.center,
                      style: textStyleRegular(fontSize: 13.sp, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 18.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: AppColors.redLight,
                        border: Border.all(color: AppColors.coralDark, width: 2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer, size: 18.w, color: AppColors.coralDark),
                          SizedBox(width: 8.w),
                          Text(
                            LanKey.deathCountdown.trParams({'t': countdown}),
                            style: textStyleBlack(fontSize: 20.sp, color: AppColors.coralDark),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 6.h),
                    TextButton(
                      onPressed: () => setState(() => _dismissed = true),
                      child: Text(
                        LanKey.deathKeepBrowsing.tr,
                        style: textStyleBold(fontSize: 13.sp, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(String countdown) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          margin: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 0),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: AppColors.coralDark,
            border: Border.all(color: AppColors.border, width: 2),
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [BoxShadow(color: Color(0x33B93B45), offset: Offset(0, 3))],
          ),
          child: Row(
            children: [
              Icon(PhosphorIcons.skull(PhosphorIconsStyle.fill), size: 16.w, color: Colors.white),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  LanKey.deathBanner.trParams({'t': countdown}),
                  style: textStyleBold(fontSize: 12.sp, color: Colors.white),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _dismissed = false),
                child: Icon(Icons.expand_more_rounded, size: 20.w, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
