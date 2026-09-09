import 'package:flutter/material.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Shop item icon. Shows the generated PNG/webp asset when [iconFile] is
/// given (falls back to a Phosphor vector on missing/broken assets), so
/// items without a finished icon never break the grid.
class ShopItemIcon extends StatelessWidget {
  final String itemId;

  /// Optional asset filename inside `assets/images/equipments/`.
  final String? iconFile;
  final double size;

  const ShopItemIcon({super.key, required this.itemId, this.iconFile, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final file = iconFile;
    if (file == null || file.isEmpty) return _vector(size);
    return Image.asset(
      'assets/images/equipments/$file',
      width: size,
      height: size,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => _vector(size),
    );
  }

  Widget _vector(double s) => Icon(icon(itemId), size: s, color: AppColors.primaryDark);

  /// Solid rarity accent color (tile border / labels). The tile background
  /// uses the same hue as a gradient (see [rarityGradient]).
  static Color rarityColor(EquipmentRarity rarity) => switch (rarity) {
        EquipmentRarity.EQUIPMENT_RARITY_COMMON => AppColors.textSecondary,
        EquipmentRarity.EQUIPMENT_RARITY_RARE => AppColors.info,
        EquipmentRarity.EQUIPMENT_RARITY_EPIC => AppColors.primaryDark,
        EquipmentRarity.EQUIPMENT_RARITY_LEGENDARY => const Color(0xFFE09A2E),
        _ => AppColors.textSecondary,
      };

  /// Soft rarity-tinted gradient for the icon tile background.
  static Gradient rarityGradient(EquipmentRarity rarity) {
    final c = rarityColor(rarity);
    return RadialGradient(
      colors: [
        c.withValues(alpha: 0.10),
        c.withValues(alpha: 0.42),
      ],
    );
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
