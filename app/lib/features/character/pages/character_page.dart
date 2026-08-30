import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/animation/frame_sequence_player.dart';
import 'package:habit_forge_app/core/constants/game_constants.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_spacing.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/features/character/controllers/character_controller.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/widgets/toast_widget.dart';

class CharacterPage extends GetView<CharacterController> {
  const CharacterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Obx(() {
          final char = NetworkRegistry.ins.character.value;
          if (char == null) return const SizedBox();
          return Column(
            children: [
              _buildHeader(char),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                  children: [
                    _buildStatsSection(char),
                    SizedBox(height: 20.h),
                    _buildEquipmentSection(context, char),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ─────────── Equipment ───────────
  Widget _buildEquipmentSection(BuildContext context, Character char) {
    const slots = ['weapon', 'helmet', 'armor', 'accessory'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LanKey.equipment.tr, style: textStyleBold(fontSize: 18.sp)),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: slots.map((slot) {
            final equipped = char.equipment[slot];
            return GestureDetector(
              onTap: () => _showEquipSheet(context, slot),
              child: Column(
                children: [
                  Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: equipped != null ? AppColors.goldLight : Colors.white,
                      border: Border.all(
                        color: equipped != null ? AppColors.goldDark : AppColors.textMuted,
                        width: 2.5,
                      ),
                      boxShadow: const [BoxShadow(color: Color(0xFFE9D9BE), offset: Offset(0, 3))],
                    ),
                    child: Icon(
                      _slotIcon(slot),
                      size: 26.w,
                      color: equipped != null ? AppColors.goldDark : AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(_slotLabel(slot), style: textStyleBold(fontSize: 10.sp, color: AppColors.textSecondary)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─────────── Header: back + name + hero circular frame + idle animation ───────────
  Widget _buildHeader(Character char) {
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
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                const Spacer(),
                Text(
                  '${LanKey.characterClass(char.characterClass.name).tr.toUpperCase()}',
                  style: textStyleBold(fontSize: 16.sp, color: AppColors.textSecondary),
                ),
                const Spacer(),
                SizedBox(width: 38.w),
              ],
            ),
          ),
          SizedBox(
            width: 165.w,
            height: 165.w,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: 152.w,
                  height: 152.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 3),
                    gradient: const RadialGradient(
                      colors: [Color(0xFFEFE6FF), Color(0xFFCDB7FF), Color(0xFF9B6BFF)],
                      stops: [0, 0.48, 1],
                    ),
                    boxShadow: const [BoxShadow(color: Color(0xFFE7B93F), offset: Offset(0, 6), blurRadius: 0)],
                  ),
                  child: ClipOval(
                    child: FrameSequencePlayer(
                      frames: UserService.to.getCharacterFrame(),
                      preferredSize: Size(114.w, 144.h),
                    ),
                  ),
                ),
                Positioned(
                  top: -6,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Color(0xFFE9D9BE), offset: Offset(0, 2))],
                    ),
                    child: Text(
                      LanKey.levelClassLabel.trParams({
                        'level': '${char.level}',
                        'className': LanKey.characterClass(char.characterClass.name).tr,
                      }),
                      style: textStyleBold(fontSize: 12.sp, color: AppColors.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // XP progress
          Padding(
            padding: EdgeInsets.fromLTRB(28.w, 10.h, 28.w, 16.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(LanKey.xp.tr, style: textStyleBold(fontSize: 11.sp, color: AppColors.textSecondary)),
                    const Spacer(),
                    Text(
                      '${char.currentExp}/${GameConstants.expForLevel(char.level)}',
                      style: textStyleBold(fontSize: 12.sp, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Container(
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E7CE),
                    border: Border.all(color: AppColors.border, width: 2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor:
                        (char.currentExp.toInt() / GameConstants.expForLevel(char.level)).clamp(0.0, 1.0).toDouble(),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.gold, AppColors.goldDark]),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────── Attributes ───────────
  Widget _buildStatsSection(Character char) {
    final stats = char.baseStats;
    final items = <(LanKey, int)>[
      (LanKey.statStr, stats.strength),
      (LanKey.statInt, stats.intelligence),
      (LanKey.statAgi, stats.agility),
      (LanKey.statDef, stats.defense),
      (LanKey.statVit, stats.vitality),
      (LanKey.statLuk, stats.luck),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(LanKey.attributes.tr, style: textStyleBold(fontSize: 18.sp)),
            const Spacer(),
            if (char.availableStatPoints > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.goldLight,
                  border: Border.all(color: AppColors.border, width: 1.5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  LanKey.pointsRemaining.trParams({'n': '${char.availableStatPoints}'}),
                  style: textStyleBold(fontSize: 11.sp, color: AppColors.goldDark),
                ),
              ),
          ],
        ),
        SizedBox(height: 10.h),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10.h,
          crossAxisSpacing: 10.w,
          childAspectRatio: 2.1,
          children: items.map((it) {
            final canAdd = char.availableStatPoints > 0;
            return GestureDetector(
              onTap: canAdd ? () => controller.allocateStat(_statKey(it.$1)) : null,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.border, width: 2),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [BoxShadow(color: Color(0xFFEFDFC4), offset: Offset(0, 3))],
                ),
                child: Row(
                  children: [
                    Text(it.$1.tr, style: textStyleBold(fontSize: 12.sp, color: AppColors.textSecondary)),
                    const Spacer(),
                    Text('${it.$2}', style: textStyleBold(fontSize: 18.sp, color: AppColors.textPrimary)),
                    if (canAdd) ...[
                      SizedBox(width: 2.w),
                      const Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showEquipSheet(BuildContext context, String slot) {
    final hive = NetworkRegistry.ins;
    final char = hive.character.value;
    if (char == null) return;

    final owned = hive.ownedItemIds;
    if (owned.isEmpty) {
      Toast.show(LanKey.noItemsForSlot.tr);
      return;
    }

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.sheetRadius)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              LanKey.selectSlot.trParams({'slot': _slotLabel(slot)}),
              style: textStyleBold(fontSize: 16.sp, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
              title: Text(LanKey.noneUnequip.tr, style: textStyleRegular(color: AppColors.textMuted)),
              onTap: () {
                hive.equipItem('', slot: slot);
                Get.back();
              },
            ),
            ...owned.map(
              (itemId) => ListTile(
                leading: const Icon(Icons.shield_rounded, color: AppColors.primary, size: 24),
                title: Text(
                  itemId.replaceAll('_', ' ').toUpperCase(),
                  style: textStyleRegular(color: AppColors.textPrimary),
                ),
                trailing: char.equipment[slot] == itemId
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 20)
                    : null,
                onTap: () {
                  hive.equipItem(itemId, slot: slot);
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _slotIcon(String slot) {
    switch (slot) {
      case 'weapon':
        return Icons.gavel_rounded;
      case 'helmet':
        return Icons.military_tech_rounded;
      case 'armor':
        return Icons.shield_rounded;
      default:
        return Icons.diamond_rounded;
    }
  }

  String _slotLabel(String slot) {
    switch (slot) {
      case 'weapon':
        return LanKey.weapon.tr;
      case 'helmet':
        return LanKey.helmet.tr;
      case 'armor':
        return LanKey.armor.tr;
      default:
        return LanKey.trinket.tr;
    }
  }

  String _statKey(LanKey k) {
    switch (k) {
      case LanKey.statStr:
        return 'strength';
      case LanKey.statInt:
        return 'intelligence';
      case LanKey.statAgi:
        return 'agility';
      case LanKey.statDef:
        return 'defense';
      case LanKey.statVit:
        return 'vitality';
      default:
        return 'luck';
    }
  }
}
