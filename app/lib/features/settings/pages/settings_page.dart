import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/constants/env_constants.dart';
import 'package:habit_forge_app/core/i18n/app_locale.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/services/audio_service.dart';
import 'package:habit_forge_app/core/services/haptic_service.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/features/auth/controllers/auth_controller.dart';
import 'package:habit_forge_app/features/settings/controllers/settings_controller.dart';
import 'package:habit_forge_app/widgets/confirm_dialog.dart';

Widget _buildHeader() {
  return Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF8FD4FF), Color(0xFFC8ECFF), Color(0xFFE4F6FF)],
      ),
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
    ),
    padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 18.h),
    child: Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(Get.context!).padding.top),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: AppColors.border, width: 2.5),
                boxShadow: const [BoxShadow(color: Color(0xFFD6C3A4), offset: Offset(0, 3))],
              ),
              child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textPrimary),
            ),
          ),
          SizedBox(width: 10.w),
          Text(LanKey.settings.tr, style: textStyleBlack(fontSize: 22.sp, color: AppColors.textPrimary)),
        ],
      ),
    ),
  );
}

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account section
                  ...[
                    _SectionHeader(LanKey.account.tr),
                    _SettingsCard(
                      child: Column(
                        children: [
                          ListTile(
                            dense: true,
                            leading: const Icon(Icons.person_outline, color: AppColors.textSecondary),
                            title: Text(
                              LanKey.guest.tr,
                              style: textStyleRegular(color: AppColors.textPrimary),
                            ),
                            subtitle: Text(
                              LanKey.signedIn.tr,
                              style: textStyleRegular(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ),
                          const Divider(color: AppColors.elevated, height: 1, thickness: 1),
                          ListTile(
                            dense: true,
                            leading: const Icon(Icons.logout, color: AppColors.red),
                            title: Text(
                              LanKey.signOut.tr,
                              style: textStyleRegular(color: AppColors.red),
                            ),
                            onTap: () async {
                              final confirmed = await ConfirmDialog.show(
                                context,
                                title: LanKey.signOut.tr,
                                message: LanKey.signOutConfirm.tr,
                                confirmLabel: LanKey.signOut.tr,
                                isDestructive: true,
                              );
                              if (confirmed == true) {
                                await AuthController.to.logout();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Preferences section
                  _SectionHeader(LanKey.preferences.tr),
                  _SettingsCard(
                    child: Column(
                      children: [
                        _PreferenceRow(
                          label: LanKey.sound.tr,
                          value: Get.find<AudioService>().enabled,
                          onChanged: (v) => Get.find<AudioService>().setEnabled(v),
                        ),
                        const Divider(color: AppColors.elevated, height: 1, thickness: 1),
                        _PreferenceRow(
                          label: LanKey.haptic.tr,
                          value: Get.find<HapticService>().enabled,
                          onChanged: (v) => Get.find<HapticService>().setEnabled(v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Language section
                  _SectionHeader(LanKey.language.tr),
                  _SettingsCard(
                    child: Column(
                      children: [
                        _LanguageOption(label: 'English', value: AppLocale.en),
                        const Divider(color: AppColors.elevated, height: 1, thickness: 1),
                        _LanguageOption(label: '中文', value: AppLocale.zh),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Data section — wiping local data only makes sense in hive
                  // mode (server/firebase sessions live on the backend).
                  if (EnvConstants.isHive()) ...[
                    _SectionHeader(LanKey.data.tr),
                    _SettingsCard(
                      child: ListTile(
                        leading: Icon(Icons.recycling_outlined, color: AppColors.textPrimary.withValues(alpha: 0.5)),
                        title: Text(
                          LanKey.resetAllData.tr,
                          style: textStyleRegular(color: AppColors.red),
                        ),
                        onTap: () async {
                          final confirmed = await ConfirmDialog.show(
                            context,
                            title: LanKey.resetGame.tr,
                            message: LanKey.resetAllConfirm.tr,
                            confirmLabel: LanKey.reset.tr,
                            isDestructive: true,
                          );
                          if (confirmed == true) {
                            controller.resetAllData();
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ── Custom Toggle (44x24 pill, purple on / gray off, white circle thumb) ──

class _CustomToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CustomToggle({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: value ? AppColors.primary : AppColors.elevated,
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 22 : 2,
              top: 2,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Language Option (label + check when active) ──

class _LanguageOption extends StatelessWidget {
  final String label;
  final String value;

  const _LanguageOption({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(
        label,
        style: textStyleRegular(color: AppColors.textPrimary),
      ),
      trailing:
          AppLocale.current() == value ? const Icon(Icons.check_rounded, color: AppColors.primary, size: 20) : null,
      onTap: () => AppLocale.set(value),
    );
  }
}

// ── Preference Row (label + custom toggle) ──

class _PreferenceRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PreferenceRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textStyleRegular(
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
          ),
          _CustomToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ── Section Header (uppercase 12px label) ──

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: textStyleBold(
          color: AppColors.textMuted,
          fontSize: 12,
        ).copyWith(letterSpacing: 0.5),
      ),
    );
  }
}

// ── Settings Card (surface bg, 12px radius, 1px elevated border) ──

class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: child,
    );
  }
}
