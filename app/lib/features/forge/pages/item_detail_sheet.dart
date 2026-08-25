import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/features/forge/controllers/forge_controller.dart';
import 'package:habit_forge_app/models/shop/shop_item.dart';
import 'package:habit_forge_app/widgets/shop_item_icon.dart';

class ItemDetailSheet extends StatelessWidget {
  final ShopItem item;
  const ItemDetailSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ForgeController>();
    final owned = controller.isOwned(item.id);
    final affordable = controller.canAfford(item.price);
    final shortfall = controller.goldShortfall(item.price);
    final rarityColor = _rarityColor(item.rarity);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          // Icon frame
          Container(
            width: 88.w,
            height: 88.w,
            decoration: BoxDecoration(
              color: ShopItemIcon.bg(item.id),
              border: Border.all(color: AppColors.border, width: 3),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Color(0xFFEFDFC4), offset: Offset(0, 5))],
            ),
            child: ShopItemIcon(itemId: item.id, size: 48.w),
          ),
          SizedBox(height: 14.h),
          Text(item.name, style: textStyleBold(fontSize: 20.sp, color: AppColors.textPrimary)),
          SizedBox(height: 8.h),
          // Rarity pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: rarityColor.withValues(alpha: 0.15),
              border: Border.all(color: rarityColor, width: 1.2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              item.rarity.tr.toUpperCase(),
              style: textStyleBold(fontSize: 11.sp, color: rarityColor).copyWith(letterSpacing: 0.5),
            ),
          ),
          SizedBox(height: 14.h),
          // Description
          if (item.description != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                item.description!,
                textAlign: TextAlign.center,
                style: textStyleRegular(fontSize: 14.sp, color: AppColors.textSecondary).copyWith(height: 1.4),
              ),
            ),
          SizedBox(height: 24.h),
          // Action button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SizedBox(
              width: double.infinity,
              height: 52.h,
              child: _buildActionButton(controller, owned, affordable, shortfall),
            ),
          ),
          SizedBox(height: 28.h),
        ],
      ),
    );
  }

  Widget _buildActionButton(ForgeController controller, bool owned, bool affordable, int shortfall) {
    final VoidCallback? onTap;
    final Color bg;
    final Color fg;
    final String label;
    final bool showPrice;

    if (owned) {
      onTap = () {
        controller.equip(item.id);
        Get.back();
      };
      bg = AppColors.primary;
      fg = Colors.white;
      label = LanKey.equip.tr;
      showPrice = false;
    } else if (!affordable) {
      onTap = () {
        Get.snackbar(
          '',
          LanKey.notEnoughGold.trParams({'shortfall': '$shortfall'}),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.surface,
          colorText: AppColors.red,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      };
      bg = AppColors.coral;
      fg = Colors.white;
      label = LanKey.needMoreGold.trParams({'shortfall': '$shortfall'});
      showPrice = false;
    } else {
      onTap = () {
        final success = controller.purchase(item);
        if (success) Get.back();
      };
      bg = AppColors.gold;
      fg = AppColors.textPrimary;
      label = LanKey.buy.tr;
      showPrice = true;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: AppColors.border, width: 2.5),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [BoxShadow(color: bg.withValues(alpha: 0.5), offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showPrice) ...[
              Container(
                width: 16.w,
                height: 16.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold,
                  border: Border.all(color: AppColors.border, width: 1.2),
                ),
              ),
              SizedBox(width: 5.w),
            ],
            Text(
              showPrice ? '$label · ${item.price}' : label,
              style: textStyleBold(fontSize: 15.sp, color: fg),
            ),
          ],
        ),
      ),
    );
  }

  Color _rarityColor(String rarity) {
    switch (rarity) {
      case 'common':
        return AppColors.textSecondary;
      case 'rare':
        return AppColors.info;
      case 'epic':
        return AppColors.primaryDark;
      default:
        return AppColors.textSecondary;
    }
  }

  static void show(BuildContext context, ShopItem item) {
    Get.bottomSheet(
      ItemDetailSheet(item: item),
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
    );
  }
}
