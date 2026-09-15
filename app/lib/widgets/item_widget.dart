import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:habit_forge_app/core/network/hive/shop_config.dart';
import 'package:habit_forge_app/core/services/subscription_service.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/generated/protos/shop/v1/shop.pb.dart';
import 'package:habit_forge_app/widgets/shop_item_icon.dart';

class ItemWidget extends StatelessWidget {
  final ShopItem item;

  const ItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.w,
      height: 64.w,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        gradient: ShopItemIcon.rarityGradient(item.rarity),
        border: Border.all(color: ShopItemIcon.rarityColor(item.rarity), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Center(
            child: ShopItemIcon(itemId: item.id, iconFile: ShopConfig.iconOf(item.id), size: 36.w),
          ),
          if (!SubscriptionService.to.canAccessShopItem(item))
            Positioned(
              right: 0,
              top: 0,
              child: Icon(Icons.lock_rounded, size: 14.w, color: AppColors.goldDark),
            ),
        ],
      ),
    );
  }
}
