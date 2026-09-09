import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/network/hive/shop_config.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/features/forge/controllers/forge_controller.dart';
import 'package:habit_forge_app/features/forge/pages/item_detail_sheet.dart';
import 'package:habit_forge_app/generated/assets.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:habit_forge_app/widgets/shop_item_icon.dart';
import 'package:habit_forge_app/widgets/wallet_chip.dart';

class ForgePage extends GetView<ForgeController> {
  const ForgePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            _buildSkyHeader(),
            _buildDealBanner(context),
            _buildShopTabs(),
            Expanded(
              child: TabBarView(
                children: [
                  // Town Shop rack: every piece of equipment, always buyable.
                  _buildPermanentPage(),
                  // Field Shop rack: 6 random picks that refresh every 2 hours.
                  _buildRotatingPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────── Daily deal ───────────
  Widget _buildDealBanner(BuildContext context) {
    return Obx(() {
      final deal = controller.dailyDeal.value;
      final item = controller.dailyDealItem;
      if (item == null) return const SizedBox.shrink();
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
                      // Item icon (rarity-tinted gradient + rarity border)
                      Container(
                        width: 68.w,
                        height: 68.w,
                        decoration: BoxDecoration(
                          gradient: ShopItemIcon.rarityGradient(item.rarity),
                          border: Border.all(color: ShopItemIcon.rarityColor(item.rarity), width: 2.5),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ShopItemIcon(itemId: item.id, iconFile: ShopConfig.iconOf(item.id), size: 40.w),
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

  // ─────────── Shop racks ───────────
  Widget _buildPermanentPage() {
    return Obx(() {
      final items = controller.shopItems.where((i) => ShopConfig.categoryOf(i.id) == 'equipment').toList();
      return _buildGrid(items);
    });
  }

  Widget _buildRotatingPage() {
    return Obx(() {
      // Each Field Shop tile carries its own supermarket-style countdown
      // sticker; the whole rack refreshes together every 2 hours.
      return _buildGrid(controller.rotating.toList(), showSaleTag: true);
    });
  }

  // ─────────── Category pill tabs (Town Shop / Field Shop) ───────────
  Widget _buildShopTabs() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E7CE),
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(999),
        ),
        child: TabBar(
          indicatorSize: TabBarIndicatorSize.tab,
          dividerHeight: 0,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [BoxShadow(color: Color(0xFFE4D2B0), offset: Offset(0, 2))],
          ),
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          labelStyle: textStyleBold(fontSize: 13.sp),
          unselectedLabelStyle: textStyleBold(fontSize: 13.sp, color: AppColors.textSecondary),
          tabs: [
            Tab(text: LanKey.shopPermanent.tr),
            Tab(text: LanKey.shopRandom.tr),
          ],
        ),
      ),
    );
  }

  // ─────────── Item grid ───────────
  Widget _buildGrid(List<ShopItem> items, {bool showSaleTag = false}) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final owned = controller.isOwned(item.id);
        final Widget tile = GestureDetector(
          onTap: () => ItemDetailSheet.show(context, item),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border, width: 2),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Color(0xFFEFDFC4), offset: Offset(0, 4))],
            ),
            child: Column(
              children: [
                // Icon frame (rarity-tinted gradient + rarity border)
                Container(
                  width: 64.w,
                  height: 64.w,
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: ShopItemIcon.rarityGradient(item.rarity),
                    border: Border.all(color: ShopItemIcon.rarityColor(item.rarity), width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ShopItemIcon(itemId: item.id, iconFile: ShopConfig.iconOf(item.id), size: 36.w),
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
                      Image.asset(
                        ShopConfig.currencyOf(item.id) == ShopCurrency.SHOP_CURRENCY_GEMS
                            ? Assets.imagesSharedIcGem
                            : Assets.imagesSharedIcGold,
                        width: 15.w,
                        height: 15.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${item.price}',
                        style: textStyleBold(
                          fontSize: 14.sp,
                          color: ShopConfig.currencyOf(item.id) == ShopCurrency.SHOP_CURRENCY_GEMS
                              ? AppColors.info
                              : const Color(0xFFC97700),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );

        final Widget gridCard = showSaleTag
            ? Stack(
                clipBehavior: Clip.none,
                children: [
                  tile,
                  // Supermarket limited-offer sticker: ticking countdown.
                  Positioned(
                    top: 8.h,
                    right: 0,
                    child: Obx(
                      () => Transform.rotate(
                        angle: -0.06,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppColors.coral, AppColors.coralDark]),
                            border: Border.all(color: Colors.white, width: 1.2),
                            borderRadius: BorderRadius.circular(7),
                            boxShadow: const [
                              BoxShadow(color: Color(0x55222222), blurRadius: 3, offset: Offset(0, 1)),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer_outlined, size: 14, color: Colors.white),
                              SizedBox(width: 3.w),
                              Text(
                                controller.rotationCountdown.value,
                                style: textStyleBold(fontSize: 14.sp, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : tile;
        return gridCard;
      },
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
          WalletChip(sysMaterial: SysMaterial.SYSMATERIAL_GOLD),
          SizedBox(width: 8.w),
          WalletChip(sysMaterial: SysMaterial.SYSMATERIAL_GEM),
        ],
      ),
    );
  }
}
