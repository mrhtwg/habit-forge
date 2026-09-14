import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';

/// Compact “agree to Terms & Privacy” footer with tappable links.
class TermsPrivacyFooter extends StatelessWidget {
  const TermsPrivacyFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final base = textStyleRegular(fontSize: 11.sp, color: AppColors.textSecondary);
    final link = textStyleBold(fontSize: 11.sp, color: AppColors.primaryDark).copyWith(
      decoration: TextDecoration.underline,
      decorationColor: AppColors.primaryDark,
    );

    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: LanKey.agreeToTermsPrefix.tr),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () => Get.toNamed(Routers.terms),
              child: Text(LanKey.termsOfService.tr, style: link),
            ),
          ),
          TextSpan(text: LanKey.agreeToTermsAnd.tr),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () => Get.toNamed(Routers.privacy),
              child: Text(LanKey.privacyPolicy.tr, style: link),
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
