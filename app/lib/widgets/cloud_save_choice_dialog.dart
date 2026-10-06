import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';

/// What to do when the account being signed into already has a cloud save while
/// this device has progress of its own.
enum CloudSaveChoice {
  /// Take the account's save, discarding what is on this device.
  useCloud,

  /// Keep both: the device's progress is merged into the account (see
  /// `ProgressMergeService`). Nothing on the account is dropped.
  merge,

  /// Abort the sign-in entirely and stay on this device.
  cancel,
}

/// Three-way conflict dialog for the guest → account sign-in path.
///
/// A two-way "continue / cancel" is what the app had before, and its only
/// non-cancel answer silently threw this device's progress away. Since a guest
/// may have played for weeks, the third option is the one that matters.
class CloudSaveChoiceDialog extends StatelessWidget {
  const CloudSaveChoiceDialog({super.key});

  static Future<CloudSaveChoice> show(BuildContext context) async {
    final choice = await Get.dialog<CloudSaveChoice>(
      const CloudSaveChoiceDialog(),
      barrierDismissible: false,
    );
    return choice ?? CloudSaveChoice.cancel;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [BoxShadow(color: Color(0xFFEFDFC4), offset: Offset(0, 5))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LanKey.cloudSaveChoiceTitle.tr,
              style: textStyleBlack(fontSize: 18.sp, color: AppColors.textPrimary),
            ),
            SizedBox(height: 8.h),
            Text(
              LanKey.cloudSaveChoiceBody.tr,
              style: textStyleRegular(fontSize: 13.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 16.h),
            _option(
              key: const ValueKey('cloud-save-choice-merge'),
              label: LanKey.mergeLocalIntoCloud.tr,
              hint: null,
              color: AppColors.primary,
              textColor: Colors.white,
              onTap: () => Get.back(result: CloudSaveChoice.merge),
            ),
            SizedBox(height: 10.h),
            _option(
              key: const ValueKey('cloud-save-choice-cloud'),
              label: LanKey.useCloudSave.tr,
              hint: null,
              color: const Color(0xFFF3E7CE),
              textColor: AppColors.textPrimary,
              onTap: () => Get.back(result: CloudSaveChoice.useCloud),
            ),
            SizedBox(height: 6.h),
            Center(
              child: TextButton(
                key: const ValueKey('cloud-save-choice-cancel'),
                onPressed: () => Get.back(result: CloudSaveChoice.cancel),
                child: Text(
                  LanKey.cancel.tr,
                  style: textStyleBold(fontSize: 13.sp, color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _option({
    required Key key,
    required String label,
    required String? hint,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: textStyleBold(fontSize: 14.sp, color: textColor)),
            if (hint != null) ...[
              SizedBox(height: 3.h),
              Text(hint, style: textStyleRegular(fontSize: 11.sp, color: textColor.withValues(alpha: 0.8))),
            ],
          ],
        ),
      ),
    );
  }
}
