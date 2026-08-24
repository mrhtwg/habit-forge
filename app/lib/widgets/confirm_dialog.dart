import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final VoidCallback onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final confirmColor = isDestructive ? AppColors.red : const Color(0xFF6C5CE7);

    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
        builder: (context, t, child) {
          final scale = 0.8 + t * 0.2;
          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: Container(
          width: 280.w,
          padding: EdgeInsets.all(24.dg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.border, width: 2.5),
            boxShadow: const [BoxShadow(color: Color(0x443A2A4E), blurRadius: 20, offset: Offset(0, 8))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: textStyleBold(
                  fontSize: 18.sp,
                  color: AppColors.textPrimary,
                ).copyWith(decoration: TextDecoration.none),
              ),
              SizedBox(height: 24.h),
              Text(
                message,
                style: textStyleMedium(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ).copyWith(decoration: TextDecoration.none),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        cancelLabel,
                        style: textStyleNormal(color: AppColors.textMuted, fontSize: 14.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextButton(
                      onPressed: onConfirm,
                      child: Text(
                        confirmLabel,
                        style: textStyleMedium(color: confirmColor, fontSize: 14.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(ctx).pop(true),
      ),
    );
  }
}
