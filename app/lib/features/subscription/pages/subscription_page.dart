import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/features/auth/controllers/auth_controller.dart';
import 'package:habit_forge_app/core/services/subscription_service.dart';
import 'package:habit_forge_app/core/services/subscription_tier.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/widgets/toast_widget.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sub = SubscriptionService.to;
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _header(),
            Expanded(
              child: Obx(() {
                final tier = sub.tier.value;
                return ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                  children: [
                    Text(
                      LanKey.premiumHeadline.tr,
                      style: textStyleBlack(fontSize: 22.sp, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      LanKey.premiumSubtitle.tr,
                      style: textStyleMedium(fontSize: 13.sp, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 16.h),
                    _perk(LanKey.premiumPerkHabits.tr),
                    _perk(LanKey.premiumPerkClasses.tr),
                    _perk(LanKey.premiumPerkStats.tr),
                    _perk(LanKey.premiumPerkGear.tr),
                    _perk(LanKey.premiumPerkAds.tr),
                    if (sub.purchaseState.value != PurchaseFlowState.idle) ...[
                      SizedBox(height: 12.h),
                      _purchaseStatus(sub.purchaseState.value),
                    ],
                    SizedBox(height: 20.h),
                    _planCard(
                      title: LanKey.planMonthly.tr,
                      price: _priceOf(sub, SubscriptionTier.monthly),
                      badge: null,
                      active: tier == SubscriptionTier.monthly,
                      enabled: !sub.isProcessing,
                      onTap: () => _buy(context, sub, SubscriptionTier.monthly),
                    ),
                    SizedBox(height: 10.h),
                    _planCard(
                      title: LanKey.planYearly.tr,
                      price: _priceOf(sub, SubscriptionTier.yearly),
                      badge: LanKey.bestValue.tr,
                      active: tier == SubscriptionTier.yearly,
                      enabled: !sub.isProcessing,
                      onTap: () => _buy(context, sub, SubscriptionTier.yearly),
                    ),
                    SizedBox(height: 10.h),
                    _planCard(
                      title: LanKey.planLifetime.tr,
                      price: _priceOf(sub, SubscriptionTier.lifetime),
                      badge: null,
                      active: tier == SubscriptionTier.lifetime,
                      enabled: !sub.isProcessing,
                      onTap: () => _buy(context, sub, SubscriptionTier.lifetime),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      LanKey.billingDisclosure.tr,
                      textAlign: TextAlign.center,
                      style: textStyleMedium(fontSize: 11.sp, color: AppColors.textMuted),
                    ),
                    SizedBox(height: 16.h),
                    TextButton(
                      onPressed: sub.isProcessing
                          ? null
                          : () async {
                              if (!await _ensureSignedIn(context)) return;
                              final requested = await sub.restorePurchases();
                              if (requested) {
                                Toast.show(LanKey.restoreRequested.tr);
                              } else {
                                Toast.warning(LanKey.purchaseUnavailable.tr);
                              }
                            },
                      child: Text(
                        LanKey.restorePurchases.tr,
                        style: textStyleBold(fontSize: 14.sp, color: AppColors.primaryDark),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _buy(BuildContext context, SubscriptionService sub, SubscriptionTier tier) async {
    if (!await _ensureSignedIn(context)) return;
    final result = await sub.buy(tier);
    switch (result) {
      case PurchaseFlowResult.started:
        return;
      case PurchaseFlowResult.signInRequired:
        Toast.warning(LanKey.purchaseSignInRequired.tr);
        return;
      case PurchaseFlowResult.cancelSubscriptionFirst:
        Toast.warning(LanKey.lifetimeRequiresCancel.tr);
        return;
      case PurchaseFlowResult.unavailable || PurchaseFlowResult.failed:
        Toast.warning(LanKey.purchaseUnavailable.tr);
        return;
      case PurchaseFlowResult.canceled:
        return;
    }
  }

  Future<bool> _ensureSignedIn(BuildContext context) async {
    if (AuthController.to.hasCloudIdentity) return true;
    Toast.show(LanKey.purchaseSignInRequired.tr);
    return AuthController.to.signInWithGoogleFromSettings(context);
  }

  String _priceOf(SubscriptionService sub, SubscriptionTier tier) {
    final id = switch (tier) {
      SubscriptionTier.monthly => SubscriptionProducts.monthly,
      SubscriptionTier.yearly => SubscriptionProducts.yearly,
      SubscriptionTier.lifetime => SubscriptionProducts.lifetime,
      _ => '',
    };
    for (final ProductDetails p in sub.products) {
      if (p.id == id) return p.price;
    }
    return '—';
  }

  Widget _purchaseStatus(PurchaseFlowState state) {
    final (text, color, icon) = switch (state) {
      PurchaseFlowState.verified => (LanKey.purchaseSuccess.tr, AppColors.greenDark, Icons.verified_rounded),
      PurchaseFlowState.pending => (LanKey.purchasePending.tr, AppColors.warning, Icons.schedule_rounded),
      PurchaseFlowState.failed => (LanKey.purchaseUnavailable.tr, AppColors.error, Icons.error_outline_rounded),
      _ => (LanKey.purchaseVerifying.tr, AppColors.primaryDark, Icons.sync_rounded),
    };
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20.w),
          SizedBox(width: 8.w),
          Expanded(child: Text(text, style: textStyleMedium(fontSize: 12.sp, color: color))),
        ],
      ),
    );
  }

  Widget _header() {
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
            Text(LanKey.premium.tr, style: textStyleBlack(fontSize: 22.sp, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _perk(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 18.w, color: AppColors.greenDark),
          SizedBox(width: 8.w),
          Expanded(child: Text(text, style: textStyleMedium(fontSize: 14.sp, color: AppColors.textPrimary))),
        ],
      ),
    );
  }

  Widget _planCard({
    required String title,
    required String price,
    required String? badge,
    required bool active,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: active || !enabled ? null : onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: active ? AppColors.primaryDark : AppColors.border, width: active ? 3 : 2),
          boxShadow: const [BoxShadow(color: Color(0xFFEFDFC4), offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: textStyleBold(fontSize: 16.sp, color: AppColors.textPrimary)),
                      if (badge != null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(badge, style: textStyleBold(fontSize: 10.sp, color: AppColors.textPrimary)),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(price, style: textStyleMedium(fontSize: 13.sp, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Text(
              active ? LanKey.currentPlan.tr : LanKey.subscribe.tr,
              style: textStyleBold(fontSize: 13.sp, color: active ? AppColors.greenDark : AppColors.primaryDark),
            ),
          ],
        ),
      ),
    );
  }
}
