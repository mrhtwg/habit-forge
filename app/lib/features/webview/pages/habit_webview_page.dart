import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/features/webview/controllers/habit_webview_controller.dart';

/// Generic in-app WebView for local HTML assets or remote URLs.
class HabitWebViewPage extends GetView<HabitWebviewController> {
  const HabitWebViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Obx(() => _header(controller.title.value)),
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    initialFile: controller.initialFile,
                    initialUrlRequest: controller.initialUrlRequest,
                    initialSettings: controller.settings,
                    onWebViewCreated: controller.onWebViewCreated,
                    onLoadStart: controller.onLoadStart,
                    onLoadStop: controller.onLoadStop,
                    onReceivedError: controller.onReceivedError,
                  ),
                  Obx(
                    () => controller.isLoading.value
                        ? const Center(
                            child: CircularProgressIndicator(color: AppColors.primaryDark),
                          )
                        : const SizedBox.shrink(),
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
