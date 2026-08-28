import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/storage/storage_service.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/features/forge/controllers/forge_controller.dart';
import 'package:habit_forge_app/features/forge/pages/item_detail_sheet.dart';
import 'package:habit_forge_app/widgets/shop_item_icon.dart';

class ForgePage extends GetView<ForgeController> {
  const ForgePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Column(
        children: [
          _buildSkyHeader(),
          _buildDealBanner(context),
          _buildSegmented(),
          Expanded(child: _buildItemGrid(context)),
        ],
      ),
    );
  }

  // ─────────── Daily deal ───────────
  Widget _buildDealBanner(BuildContext context) {
    return Obx(() {
      final deal = controller.dailyDeal.value;
      final item = controller.dailyDealItem;
      if (deal == null || item == null) return const SizedBox.shrink();
      final original = item.price;
      final discounted = original - (original * deal.discountPercent ~/ 100);
      return Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
        child: GestureDetector(
          onTap: () => ItemDetailSheet.show(context, item),
          child: Container(
            padding: EdgeInsets.only(
              left: 14.w,
              right: 14.w,
              bottom: 14.w,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFE9B8), Color(0xFFFFD180)]),
              border: Border.all(color: AppColors.border, width: 2.5),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [BoxShadow(color: Color(0xFFE7B93F), offset: Offset(0, 5))],
            ),
            child: Stack(
              children: [
                // 40% OFF badge
                Positioned(
                  top: 6.h,
                  right: 12.w,
                  child: Transform.rotate(
                    angle: 0.07,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: AppColors.coral,
                        border: Border.all(color: AppColors.border, width: 2),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: AppColors.coralDark, offset: Offset(0, 3))],
                      ),
                      child: Text(
                        LanKey.forgeOff.trParams({'percent': '${deal.discountPercent}'}),
                        style: textStyleBold(fontSize: 12.sp, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 14.w,
                  ),
                  child: Row(
                    children: [
                      // Item icon
                      Container(
                        width: 68.w,
                        height: 68.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.border, width: 2.5),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ShopItemIcon(itemId: item.id, size: 40.w),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: textStyleBold(fontSize: 16.sp, color: AppColors.textPrimary)),
                            SizedBox(height: 6.h),
                            // Countdown segment
                            Row(
                              children: [
                                Icon(Icons.timer_outlined, size: 14.w, color: const Color(0xFFC97700)),
                                SizedBox(width: 4.w),
                                ...controller.countdown.value.split(':').map(
                                      (seg) => Padding(
                                        padding: EdgeInsets.only(right: 3.w),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(color: AppColors.border, width: 2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            seg,
                                            style: textStyleBold(fontSize: 12.sp, color: AppColors.textPrimary),
                                          ),
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            // Price
                            Row(
                              children: [
                                Text(
                                  '$original',
                                  style: textStyleBold(fontSize: 13.sp, color: AppColors.textMuted)
                                      .copyWith(decoration: TextDecoration.lineThrough),
                                ),
                                SizedBox(width: 8.w),
                                Container(
                                  width: 14.w,
                                  height: 14.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.gold,
                                    border: Border.all(color: AppColors.border, width: 1.5),
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  '$discounted',
                                  style: textStyleBold(fontSize: 18.sp, color: const Color(0xFFC97700)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ─────────── Item grid ───────────
  Widget _buildItemGrid(BuildContext context) {
    return Obx(() {
      final items = controller.filteredItems;
      return GridView.builder(
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.78,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final owned = controller.isOwned(item.id);
          return GestureDetector(
            onTap: () => ItemDetailSheet.show(context, item),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.border, width: 2),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Color(0xFFEFDFC4), offset: Offset(0, 4))],
              ),
              child: Column(
                children: [
                  // Icon frame
                  Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: BoxDecoration(
                      color: ShopItemIcon.bg(item.id),
                      border: Border.all(color: AppColors.border, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ShopItemIcon(itemId: item.id, size: 36.w),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyleBold(fontSize: 13.sp, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 6.h),
                  if (owned)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF8EF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.green, width: 1.2),
                      ),
                      child: Text(
                        LanKey.owned.tr,
                        style: textStyleBold(fontSize: 10.sp, color: AppColors.greenDark),
                      ),
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14.w,
                          height: 14.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.gold,
                            border: Border.all(color: AppColors.border, width: 1.5),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${item.price}',
                          style: textStyleBold(fontSize: 14.sp, color: const Color(0xFFC97700)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  // ─────────── Category segment ───────────
  Widget _buildSegmented() {
    const options = [(LanKey.appearance, 'appearance'), (LanKey.equipment, 'equipment')];
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E7CE),
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: options.map((opt) {
            return Expanded(
              child: Obx(() {
                final isActive = controller.activeCategory.value == opt.$2;
                return GestureDetector(
                  onTap: () => controller.activeCategory.value = opt.$2,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: isActive ? const [BoxShadow(color: Color(0xFFE4D2B0), offset: Offset(0, 2))] : null,
                    ),
                    child: Text(
                      opt.$1.tr,
                      textAlign: TextAlign.center,
                      style: textStyleBold(
                        fontSize: 13.sp,
                        color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─────────── Sky header: title + coins ───────────
  Widget _buildSkyHeader() {
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
      padding: EdgeInsets.fromLTRB(20.w, 12.h + MediaQuery.of(Get.context!).padding.top, 20.w, 18.h),
      child: Row(
        children: [
          Text(LanKey.forge.tr, style: textStyleBlack(fontSize: 26.sp, color: AppColors.textPrimary)),
          const Spacer(),
          Obx(() {
            final gold = StorageService.to.userPrefs.value?.currentGold ?? 0;
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.border, width: 2),
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [BoxShadow(color: Color(0xFFE9D9BE), offset: Offset(0, 3))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16.w,
                    height: 16.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold,
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text('$gold', style: textStyleBold(fontSize: 14.sp, color: AppColors.textPrimary)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
