import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/animation/frame_sequence_player.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/network/hive/class_profiles.dart';
import 'package:habit_forge_app/core/network/hive/game_constants.dart';
import 'package:habit_forge_app/core/network/hive/game_logic.dart';
import 'package:habit_forge_app/core/network/hive/shop_config.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/services/death_recovery_service.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_spacing.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/features/character/controllers/character_controller.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/widgets/hud_bar.dart';
import 'package:habit_forge_app/widgets/toast_widget.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CharacterPage extends GetView<CharacterController> {
  const CharacterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        top: false,
        child: Obx(() {
          final char = UserService.to.character.value;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LanKey.equipment.tr, style: textStyleBold(fontSize: 18.sp)),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: EquipmentSlot.values
              .where((slot) => slot.value != EquipmentSlot.EQUIPMENT_SLOT_UNSPECIFIED.value)
              .map((slot) {
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
    final perk = ClassProfiles.of(char.characterClass);
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
          SizedBox(height: MediaQuery.of(Get.context!).padding.top),
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
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        switch (char.characterClass) {
                          CharacterClass.CHARACTER_CLASS_WARRIOR => LanKey.warrior.tr.toUpperCase(),
                          CharacterClass.CHARACTER_CLASS_MAGE => LanKey.mage.tr.toUpperCase(),
                          CharacterClass.CHARACTER_CLASS_RANGER => LanKey.ranger.tr.toUpperCase(),
                          _ => '',
                        },
                        style: textStyleBold(fontSize: 16.sp, color: AppColors.textSecondary),
                      ),
                      SizedBox(height: 2.h),
                      // The perk the player was promised when picking the class.
                      Text(
                        LanKey.classPerkFor(char.characterClass).trParams({
                          'hp': '${perk.recoveryHp}',
                          'min': '${perk.recoveryMinutes}',
                        }),
                        textAlign: TextAlign.center,
                        style: textStyleMedium(fontSize: 10.sp, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                // Attribute help (right side mirrors the back button).
                GestureDetector(
                  onTap: _showAttributesHelp,
                  child: Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: AppColors.border, width: 2.5),
                      boxShadow: const [BoxShadow(color: Color(0xFFD6C3A4), offset: Offset(0, 3))],
                    ),
                    child: const Icon(Icons.question_mark_rounded, size: 20, color: AppColors.textPrimary),
                  ),
                ),
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
              ],
            ),
          ),
          // EXP + HP progress
          Padding(
            padding: EdgeInsets.fromLTRB(6.w, 16.h, 6.w, 8.h),
            child: HudBar(label: 'EXP', color: AppColors.gold, text: _xpText()),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(6.w, 0, 6.w, 12.h),
            child: HudBar(label: 'HP', color: AppColors.coral, text: _hpText()),
          ),
          _buildRecoveryNotice(),
        ],
      ),
    );
  }

  String _xpText() {
    final char = UserService.to.character.value;
    final level = char?.level ?? 1;
    final needed = GameConstants.expForLevel(level);
    return '${char?.currentExp ?? 0}/$needed';
  }

  String _hpText() {
    final char = UserService.to.character.value;
    final max = GameLogic.maxHpOf(char);
    return '${char?.currentHp ?? max}/$max';
  }

  /// Recovery countdown, shown only while the hero is dead.
  Widget _buildRecoveryNotice() {
    return Obx(() {
      final char = UserService.to.character.value;
      if (char == null || !char.isDead) return const SizedBox.shrink();
      final countdown = DeathRecoveryService.formatRemaining(DeathRecoveryService.to.secondsLeft.value);
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 6.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.redLight,
          border: Border.all(color: AppColors.coralDark, width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIcons.skull(PhosphorIconsStyle.fill), size: 16.w, color: AppColors.coralDark),
            SizedBox(width: 8.w),
            Text(
              LanKey.deathCountdown.trParams({'t': countdown}),
              style: textStyleBold(fontSize: 12.sp, color: AppColors.coralDark),
            ),
          ],
        ),
      );
    });
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

  /// Bottom-sheet explaining what each attribute does.
  void _showAttributesHelp() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            Text(LanKey.attributes.tr, style: textStyleBold(fontSize: 18.sp, color: AppColors.textPrimary)),
            SizedBox(height: 4.h),
            Text(
              LanKey.statHelpHint.tr,
              style: textStyleMedium(fontSize: 12.5.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 14.h),
            _statHelpRow(
              icon: Icons.fitness_center_rounded,
              color: const Color(0xFFE0644A),
              name: LanKey.statStr.tr,
              effect: LanKey.statEffectStr.tr,
            ),
            _statHelpRow(
              icon: Icons.psychology_rounded,
              color: const Color(0xFF5B8DEF),
              name: LanKey.statInt.tr,
              effect: LanKey.statEffectInt.tr,
            ),
            _statHelpRow(
              icon: Icons.bolt_rounded,
              color: const Color(0xFFE9B44C),
              name: LanKey.statAgi.tr,
              effect: LanKey.statEffectAgi.tr,
            ),
            _statHelpRow(
              icon: Icons.shield_rounded,
              color: const Color(0xFF4CA6A8),
              name: LanKey.statDef.tr,
              effect: LanKey.statEffectDef.tr,
            ),
            _statHelpRow(
              icon: Icons.favorite_rounded,
              color: const Color(0xFFE0527A),
              name: LanKey.statVit.tr,
              effect: LanKey.statEffectVit.tr,
            ),
            _statHelpRow(
              icon: Icons.auto_awesome_rounded,
              color: const Color(0xFF9B6BFF),
              name: LanKey.statLuk.tr,
              effect: LanKey.statEffectLuk.tr,
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Widget _statHelpRow({required IconData icon, required Color color, required String name, required String effect}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.14),
              border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Icon(icon, size: 20.w, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: textStyleBold(fontSize: 15.sp, color: AppColors.textPrimary)),
                SizedBox(height: 2.h),
                Text(
                  effect,
                  style: textStyleMedium(fontSize: 12.5.sp, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEquipSheet(BuildContext context, EquipmentSlot slot) async {
    try {
      await _loadEquipSheet(context, slot);
    } catch (_) {
      Toast.error(LanKey.actionFailed.tr);
    }
  }

  Future<void> _loadEquipSheet(BuildContext context, EquipmentSlot slot) async {
    final char = UserService.to.character.value;
    if (char == null) return;

    final result = await NetworkRegistry.ins.listOwnedItems();
    if (!context.mounted) return;
    if (result.isFailure) {
      Toast.error(result.message);
      return;
    }
    final ids = result.data!.itemIds.toSet();
    final owned = ShopConfig.shopItems.where((item) => ids.contains(item.id) && item.slot == slot).toList();

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.sheetRadius)),
        ),
        child: SingleChildScrollView(
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
                onTap: () async {
                  Get.back();
                  await _equipItem('', slot);
                },
              ),
              ...owned.map(
                (item) => ListTile(
                  leading: const Icon(Icons.shield_rounded, color: AppColors.primary, size: 24),
                  title: Text(
                    item.id.replaceAll('_', ' ').toUpperCase(),
                    style: textStyleRegular(color: AppColors.textPrimary),
                  ),
                  trailing: char.equipment[GameLogic.slotKey(slot)] == item.id
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 20)
                      : null,
                  onTap: () async {
                    Get.back();
                    await _equipItem(item.id, slot);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _equipItem(String id, EquipmentSlot slot) async {
    try {
      final result = await NetworkRegistry.ins.equipItem(id, slot);
      if (result.isFailure) {
        Toast.error(result.message);
        return;
      }
      await UserService.to.loadCharacter();
    } catch (_) {
      Toast.error(LanKey.actionFailed.tr);
    }
  }

  IconData _slotIcon(EquipmentSlot slot) {
    switch (slot) {
      case EquipmentSlot.EQUIPMENT_SLOT_WEAPON:
        return Icons.gavel_rounded;
      case EquipmentSlot.EQUIPMENT_SLOT_HELMET:
        return Icons.military_tech_rounded;
      case EquipmentSlot.EQUIPMENT_SLOT_ARMOR:
        return Icons.shield_rounded;
      default:
        return Icons.diamond_rounded;
    }
  }

  String _slotLabel(EquipmentSlot slot) {
    switch (slot) {
      case EquipmentSlot.EQUIPMENT_SLOT_WEAPON:
        return LanKey.weapon.tr;
      case EquipmentSlot.EQUIPMENT_SLOT_HELMET:
        return LanKey.helmet.tr;
      case EquipmentSlot.EQUIPMENT_SLOT_ARMOR:
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
