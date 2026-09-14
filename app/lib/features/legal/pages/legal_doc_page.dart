import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/constants/legal_urls.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/widgets/toast_widget.dart';

/// In-app shell for Terms / Privacy. Body is a placeholder; [LegalUrls] holds
/// the reserved public URLs to wire up later (WebView / url_launcher).
class LegalDocPage extends StatelessWidget {
  final LegalDocType type;

  const LegalDocPage({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final title = type == LegalDocType.terms ? LanKey.termsOfService.tr : LanKey.privacyPolicy.tr;
    final url = type.url;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _header(title),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
                children: [
                  Text(
                    LanKey.legalPlaceholderBody.tr,
                    style: textStyleMedium(fontSize: 14.sp, color: AppColors.textPrimary).copyWith(height: 1.5),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    LanKey.legalReservedUrl.tr,
                    style: textStyleBold(fontSize: 12.sp, color: AppColors.textMuted),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onLongPress: () async {
                      await Clipboard.setData(ClipboardData(text: url));
                      Toast.success(LanKey.linkCopied.tr);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: Text(
                        url,
                        style: textStyleMedium(fontSize: 13.sp, color: AppColors.primaryDark).copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    LanKey.legalCopyHint.tr,
                    style: textStyleRegular(fontSize: 12.sp, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(String title) {
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
            Expanded(
              child: Text(
                title,
                style: textStyleBlack(fontSize: 20.sp, color: AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
