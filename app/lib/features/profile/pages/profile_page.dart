import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/animation/frame_sequence_player.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/interface/network_registry.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/features/profile/controllers/profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Column(
        children: [
          _buildSkyHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
              children: [
                _buildStatsRow(),
                SizedBox(height: 16.h),
                _buildQuickLink(
                  icon: Icons.military_tech_rounded,
                  color: AppColors.primary,
                  title: LanKey.viewCharacter.tr,
                  onTap: () => Get.toNamed(Routers.character),
                ),
                SizedBox(height: 10.h),
                _buildQuickLink(
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.goldDark,
                  title: LanKey.achievements.tr,
                  onTap: () => Get.toNamed(Routers.achievements),
                ),
                SizedBox(height: 10.h),
                _buildQuickLink(
                  icon: Icons.bar_chart_rounded,
                  color: AppColors.info,
                  title: LanKey.statistics.tr,
                  onTap: () => Get.toNamed(Routers.statistics),
                ),
                SizedBox(height: 10.h),
                _buildQuickLink(
                  icon: Icons.settings_rounded,
                  color: AppColors.textSecondary,
                  title: LanKey.settings.tr,
                  onTap: () => Get.toNamed(Routers.settings),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────── Quick links ───────────
  Widget _buildQuickLink({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Color(0xFFEFDFC4), offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Icon(icon, size: 22.w, color: color),
            ),
            SizedBox(width: 12.w),
            Expanded(child: Text(title, style: textStyleBold(fontSize: 15.sp, color: AppColors.textPrimary))),
            Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 22.w),
          ],
        ),
      ),
    );
  }

  // ─────────── Sky header: user card ───────────
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
      padding: EdgeInsets.fromLTRB(20.w, 14.h + MediaQuery.of(Get.context!).padding.top, 20.w, 20.h),
      child: Obx(() {
        final char = NetworkRegistry.ins.character.value;
        final prefs = NetworkRegistry.ins.userPrefs.value;
        return Row(
          children: [
            // Knight circular frame (idle animation)
            Container(
              width: 84.w,
              height: 84.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 3),
                gradient: const RadialGradient(
                  colors: [Color(0xFFEFE6FF), Color(0xFFCDB7FF), Color(0xFF9B6BFF)],
                  stops: [0, 0.48, 1],
                ),
                boxShadow: const [BoxShadow(color: Color(0xFFE7B93F), offset: Offset(0, 5))],
              ),
              child: ClipOval(
                child: FrameSequencePlayer(
                  frames: UserService.to.getCharacterFrame(),
                  preferredSize: Size(62.w, 78.h),
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(LanKey.adventurer.tr, style: textStyleBlack(fontSize: 20.sp, color: AppColors.textPrimary)),
                  SizedBox(height: 3.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      LanKey.profileLevelClass.trParams({
                        'level': '${char?.level ?? 1}',
                        'className': LanKey.characterClass(char?.characterClass.name ?? 'warrior').tr,
                      }),
                      style: textStyleBold(fontSize: 12.sp, color: AppColors.primaryDark),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      _miniWallet(color: AppColors.gold, value: prefs?.currentGold.toInt() ?? 0),
                      SizedBox(width: 8.w),
                      _miniWallet(color: const Color(0xFF7ED0FF), value: prefs?.currentGems.toInt() ?? 0),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // ─────────── Stats row ───────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        _statCard('${(controller.completionRate * 100).round()}%', LanKey.rate.tr),
        SizedBox(width: 10.w),
        _statCard('${controller.maxStreak}d', LanKey.streak.tr),
        SizedBox(width: 10.w),
        _statCard('${controller.totalTasksCompleted}', LanKey.tasks.tr),
      ],
    );
  }

  Widget _miniWallet({required Color color, required int value}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 13.w,
            height: 13.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: AppColors.border, width: 1.2),
            ),
          ),
          SizedBox(width: 4.w),
          Text('$value', style: textStyleBold(fontSize: 12.sp, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0xFFEFDFC4), offset: Offset(0, 3))],
        ),
        child: Column(
          children: [
            Text(value, style: textStyleBold(fontSize: 20.sp, color: AppColors.textPrimary)),
            SizedBox(height: 2.h),
            Text(label, style: textStyleBold(fontSize: 11.sp, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
