import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
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
                    SizedBox(height: 20.h),
                    _planCard(
                      title: LanKey.planMonthly.tr,
                      price: _priceOf(sub, SubscriptionTier.monthly, '\$4.99'),
                      badge: null,
                      active: tier == SubscriptionTier.monthly,
                      onTap: () => _buy(sub, SubscriptionTier.monthly),
                    ),
                    SizedBox(height: 10.h),
                    _planCard(
                      title: LanKey.planYearly.tr,
                      price: _priceOf(sub, SubscriptionTier.yearly, '\$29.99'),
                      badge: LanKey.bestValue.tr,
                      active: tier == SubscriptionTier.yearly,
                      onTap: () => _buy(sub, SubscriptionTier.yearly),
                    ),
                    SizedBox(height: 10.h),
                    _planCard(
                      title: LanKey.planLifetime.tr,
                      price: _priceOf(sub, SubscriptionTier.lifetime, '\$49.99'),
                      badge: null,
                      active: tier == SubscriptionTier.lifetime,
                      onTap: () => _buy(sub, SubscriptionTier.lifetime),
                    ),
                    SizedBox(height: 16.h),
                    TextButton(
                      onPressed: sub.isBusy.value
                          ? null
                          : () async {
                              await sub.restorePurchases();
                              Toast.success(LanKey.restoreDone.tr);
                            },
                      child: Text(
                        LanKey.restorePurchases.tr,
                        style: textStyleBold(fontSize: 14.sp, color: AppColors.primaryDark),
                      ),
                    ),
                    if (kDebugMode) ...[
                      SizedBox(height: 8.h),
                      Text(
                        'Debug unlock',
                        style: textStyleBold(fontSize: 12.sp, color: AppColors.textMuted),
                      ),
                      SizedBox(height: 6.h),
                      Wrap(
                        spacing: 8.w,
                        children: [
                          for (final t in SubscriptionTier.values)
                            ActionChip(
                              label: Text(t.name),
                              onPressed: () => sub.unlockDebug(t),
                            ),
                        ],
                      ),
                    ],
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _buy(SubscriptionService sub, SubscriptionTier tier) async {
    final ok = await sub.buy(tier);
    if (!ok) {
      Toast.warning(LanKey.purchaseUnavailable.tr);
    } else if (sub.isPremium) {
      Toast.success(LanKey.purchaseSuccess.tr);
    }
  }

  String _priceOf(SubscriptionService sub, SubscriptionTier tier, String fallback) {
    final id = switch (tier) {
      SubscriptionTier.monthly => SubscriptionProducts.monthly,
      SubscriptionTier.yearly => SubscriptionProducts.yearly,
      SubscriptionTier.lifetime => SubscriptionProducts.lifetime,
      _ => '',
    };
    for (final ProductDetails p in sub.products) {
      if (p.id == id) return p.price;
    }
    return fallback;
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: active ? null : onTap,
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
