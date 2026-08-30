import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/features/achievements/controllers/achievements_controller.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pb.dart';

class AchievementsPage extends GetView<AchievementsController> {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Color _achievementColor(String id) {
    switch (id) {
      case 'streak_7':
      case 'streak_30':
        return const Color(0xFFFF8A3D);
      case 'level_5':
      case 'level_10':
        return AppColors.goldDark;
      case 'tasks_50':
      case 'tasks_100':
        return AppColors.info;
      case 'first_purchase':
        return const Color(0xFF3FBE6B);
      case 'death_1':
        return AppColors.coralDark;
      default:
        return AppColors.primary;
    }
  }

  IconData _achievementIcon(String id) {
    switch (id) {
      case 'first_task':
        return Icons.adjust_rounded;
      case 'streak_7':
        return Icons.local_fire_department_rounded;
      case 'streak_30':
        return Icons.fitness_center_rounded;
      case 'level_5':
        return Icons.star_rounded;
      case 'level_10':
        return Icons.auto_awesome_rounded;
      case 'tasks_50':
        return Icons.checklist_rounded;
      case 'tasks_100':
        return Icons.emoji_events_rounded;
      case 'first_purchase':
        return Icons.shopping_cart_rounded;
      default:
        return Icons.sick_rounded;
    }
  }

  Widget _buildHeader() {
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
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 20.w, 18.h),
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
          Text(LanKey.achievements.tr, style: textStyleBlack(fontSize: 22.sp, color: AppColors.textPrimary)),
          const Spacer(),
          Obx(() {
            final n = NetworkRegistry.ins.achievements.where((a) => a.isUnlocked).length;
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.border, width: 2),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(color: Color(0xFFD6C3A4), offset: Offset(0, 3))],
              ),
              child: Text(
                '$n / ${controller.achievementDefs.length}',
                style: textStyleBold(fontSize: 13.sp, color: AppColors.textSecondary),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      itemCount: controller.achievementDefs.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final def = controller.achievementDefs[index];
        Achievement? saved;
        for (final a in NetworkRegistry.ins.achievements) {
          if (a.id == def.id) {
            saved = a;
            break;
          }
        }
        final unlocked = saved?.isUnlocked ?? false;
        return Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: unlocked ? Colors.white : const Color(0xFFF4EFE2),
            border: Border.all(color: unlocked ? AppColors.border : AppColors.textMuted, width: 2),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Color(0xFFEFDFC4), offset: Offset(0, 4))],
          ),
          child: Row(
            children: [
              // Icon badge
              Container(
                width: 54.w,
                height: 54.w,
                decoration: BoxDecoration(
                  color: unlocked ? _achievementColor(def.id).withValues(alpha: 0.2) : const Color(0xFFE8E0CE),
                  border: Border.all(color: AppColors.border, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  unlocked ? _achievementIcon(def.id) : Icons.lock_rounded,
                  size: 30.w,
                  color: unlocked ? _achievementColor(def.id) : AppColors.textMuted,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unlocked ? LanKey.achievementTitle(def.id).tr : '???',
                      style: textStyleBold(
                        fontSize: 14.sp,
                        color: unlocked ? AppColors.textPrimary : AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      LanKey.achievementDescription(def.id).tr,
                      style: textStyleMedium(fontSize: 11.5.sp, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              // Gem reward
              if (unlocked)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FF),
                    border: Border.all(color: AppColors.border, width: 1.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF7ED0FF),
                          border: Border.all(color: AppColors.border, width: 1),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        '+${def.gemReward}',
                        style: textStyleBold(fontSize: 11.sp, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
