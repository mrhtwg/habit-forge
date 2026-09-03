import 'package:flutter/material.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Shop item icon (Phosphor vector, replacing emoji).
class ShopItemIcon extends StatelessWidget {
  final String itemId;
  final double size;

  const ShopItemIcon({super.key, required this.itemId, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Icon(icon(itemId), size: size, color: AppColors.primaryDark);
  }

  static Color bg(String id) {
    switch (id) {
      case 'sword_flame':
        return AppColors.goldLight;
      case 'armor_golden':
        return const Color(0xFFEAF4FF);
      case 'helm_dragon':
        return const Color(0xFFEAF0FF);
      case 'cloak_shadow':
        return const Color(0xFFF1E8FF);
      case 'amulet_star':
        return AppColors.goldLight;
      case 'skin_shadow':
        return const Color(0xFFE3E0F5);
      case 'skin_golden':
        return AppColors.goldLight;
      case 'skin_forest':
        return const Color(0xFFE1F3E4);
      case 'skin_dragon':
        return const Color(0xFFFFE5E0);
      default:
        return const Color(0xFFEAF0FF);
    }
  }

  static IconData icon(String id) {
    switch (id) {
      case 'sword_flame':
        return PhosphorIcons.sword(PhosphorIconsStyle.fill);
      case 'armor_golden':
        return PhosphorIcons.shield(PhosphorIconsStyle.fill);
      case 'helm_dragon':
        return PhosphorIcons.crown(PhosphorIconsStyle.fill);
      case 'cloak_shadow':
        return PhosphorIcons.moonStars(PhosphorIconsStyle.fill);
      case 'amulet_star':
        return PhosphorIcons.star(PhosphorIconsStyle.fill);
      case 'staff_arcane':
        return PhosphorIcons.sparkle(PhosphorIconsStyle.fill);
      case 'skin_shadow':
        return PhosphorIcons.user(PhosphorIconsStyle.fill);
      case 'skin_golden':
        return PhosphorIcons.user(PhosphorIconsStyle.fill);
      case 'skin_forest':
        return PhosphorIcons.user(PhosphorIconsStyle.fill);
      case 'skin_dragon':
        return PhosphorIcons.user(PhosphorIconsStyle.fill);
      default:
        return PhosphorIcons.package(PhosphorIconsStyle.fill);
    }
  }
}
