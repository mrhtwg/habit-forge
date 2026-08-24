import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/services/audio_service.dart';
import 'package:habit_forge_app/core/services/haptic_service.dart';
import 'package:habit_forge_app/core/services/hive_service.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/features/auth/controllers/auth_controller.dart';
import 'package:habit_forge_app/features/settings/controllers/settings_controller.dart';
import 'package:habit_forge_app/widgets/confirm_dialog.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        final prefs = HiveService.to.userPrefs.value;
        if (prefs == null) return const SizedBox();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Account section
            const _SectionHeader('Account'),
            _SettingsCard(
              child: Column(
                children: [
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.person_outline, color: AppColors.textSecondary),
                    title: Text(
                      HiveService.to.authMethod.isEmpty ? 'Guest' : HiveService.to.authMethod.capitalizeFirst!,
                      style: textStyleRegular(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      'Signed in',
                      style: textStyleRegular(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ),
                  const Divider(color: AppColors.elevated, height: 1, thickness: 1),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.logout, color: AppColors.red),
                    title: Text(
                      'Sign Out',
                      style: textStyleRegular(color: AppColors.red),
                    ),
                    onTap: () async {
                      final confirmed = await ConfirmDialog.show(
                        context,
                        title: 'Sign Out',
                        message: 'Are you sure you want to sign out?',
                        confirmLabel: 'Sign Out',
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

            // Preferences section
            const _SectionHeader('Preferences'),
            _SettingsCard(
              child: Column(
                children: [
                  _PreferenceRow(
                    label: 'Sound',
                    value: prefs.soundEnabled,
                    onChanged: (v) {
                      Get.find<AudioService>().setEnabled(v);
                      HiveService.to.saveUserPrefs(prefs.copyWith(soundEnabled: v));
                    },
                  ),
                  const Divider(color: AppColors.elevated, height: 1, thickness: 1),
                  _PreferenceRow(
                    label: 'Haptic',
                    value: prefs.hapticEnabled,
                    onChanged: (v) {
                      Get.find<HapticService>().setEnabled(v);
                      HiveService.to.saveUserPrefs(prefs.copyWith(hapticEnabled: v));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Data section
            const _SectionHeader('Data'),
            _SettingsCard(
              child: ListTile(
                leading: Text(
                  '\u{1F5D1}\u{FE0F}',
                  style: textStyleRegular(fontSize: 20),
                ),
                title: Text(
                  'Reset All Data',
                  style: textStyleRegular(color: AppColors.red),
                ),
                onTap: () async {
                  final confirmed = await ConfirmDialog.show(
                    context,
                    title: 'Reset Game',
                    message: 'This will delete all your data. Are you sure?',
                    confirmLabel: 'Reset',
                    isDestructive: true,
                  );
                  if (confirmed == true) {
                    await HiveService.to.resetAllData();
                    Get.offAllNamed(Routers.splash);
                  }
                },
              ),
            ),
          ],
        );
      }),
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
