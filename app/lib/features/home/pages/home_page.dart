import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/animation/frame_sequence_player.dart';
import 'package:habit_forge_app/core/constants/game_constants.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/features/home/controllers/home_controller.dart';
import 'package:habit_forge_app/features/quests/pages/task_form_sheet.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';
import 'package:habit_forge_app/widgets/pressable_button.dart';
import 'package:habit_forge_app/widgets/task_ticket.dart';
import 'package:habit_forge_app/widgets/wallet_chip.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Column(
        children: [
          _buildSkyHeader(),
          Expanded(child: _buildQuestsSection()),
        ],
      ),
    );
  }

  // ─────────────── Today's quests ───────────────
  Widget _buildQuestsSection() {
    return Obx(() {
      final tasks = controller.todayTasks;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 10.h),
            child: Row(
              children: [
                Text(LanKey.todaysQuests.tr, style: textStyleBold(fontSize: 18.sp, color: AppColors.textPrimary)),
                const Spacer(),
                if (tasks.isNotEmpty)
                  GestureDetector(
                    onTap: () async {
                      await TaskFormSheet.show(Get.context!);
                      controller.loadTodayTasks();
                    },
                    child:
                        Text(LanKey.addQuest.tr, style: textStyleBold(fontSize: 18.sp, color: AppColors.primaryDark)),
                  ),
              ],
            ),
          ),
          if (tasks.isEmpty)
            Expanded(child: _emptyState())
          else
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                itemCount: tasks.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (context, index) => TaskTicket(
                  task: tasks[index],
                  onComplete: () => controller.onTaskComplete(tasks[index]),
                ),
              ),
            ),
        ],
      );
    });
  }

  // ─────────────── Sky header: greeting + wallet + hero + status bars ───────────────
  Widget _buildSkyHeader() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(Get.context!).padding.top),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8FD4FF), Color(0xFFC8ECFF), Color(0xFFE4F6FF)],
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(34), bottomRight: Radius.circular(34)),
      ),
      child: Column(
        children: [
          // Greeting + wallet
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LanKey.goodMorningAdventurer.tr,
                        style: textStyleHand(fontSize: 19.sp, color: AppColors.textPrimary),
                      ),
                      Obx(() {
                        final n = controller.todayTasks.length;
                        return Text(
                          n > 0 ? LanKey.questsReadyCount.trParams({'n': '$n'}) : LanKey.aFreshDayAwaits.tr,
                          style: textStyleMedium(fontSize: 12.sp, color: AppColors.textSecondary),
                        );
                      }),
                    ],
                  ),
                ),
                WalletChip(sysMaterial: SysMaterial.SYSMATERIAL_GOLD),
                SizedBox(width: 8.w),
                WalletChip(sysMaterial: SysMaterial.SYSMATERIAL_GEM),
              ],
            ),
          ),
          // Hero circular frame + level badge + idle animation
          Obx(() {
            final char = UserService.to.character.value;
            return GestureDetector(
              onTap: controller.onCharacterTap,
              child: SizedBox(
                width: 160.w,
                height: 160.w,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 140.w,
                      height: 140.w,
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border, width: 3),
                        gradient: const RadialGradient(
                          colors: [Color(0xFFEFE6FF), Color(0xFFCDB7FF), Color(0xFF9B6BFF)],
                          stops: [0, 0.48, 1],
                        ),
                        boxShadow: const [
                          BoxShadow(color: Color(0xFFE7B93F), offset: Offset(0, 6), blurRadius: 0),
                        ],
                      ),
                      child: ClipOval(
                        child: FrameSequencePlayer(
                          frames: UserService.to.getCharacterFrame(),
                          preferredSize: Size(112.w, 142.h),
                        ),
                      ),
                    ),
                    // Lv badge (riding on top of the circular frame)
                    Positioned(
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.border, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [BoxShadow(color: Color(0xFFE9D9BE), offset: Offset(0, 2))],
                        ),
                        child: Text(
                          LanKey.levelLabel.trParams({'level': '${char?.level ?? 1}'}),
                          style: textStyleBold(fontSize: 12.sp, color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          // XP / HP
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 18.h),
            child: Column(
              children: [
                _hudBar(label: LanKey.exp.tr, color: AppColors.gold, text: _xpText()),
                SizedBox(height: 8.h),
                _hudBar(label: LanKey.hp.tr, color: AppColors.coral, text: _hpText()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96.w,
            height: 96.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.goldLight,
              border: Border.all(color: AppColors.border, width: 3),
            ),
            child: Icon(Icons.auto_stories_rounded, size: 44.w, color: AppColors.goldDark),
          ),
          SizedBox(height: 14.h),
          Text(LanKey.noQuestsToday.tr, style: textStyleBold(fontSize: 20.sp)),
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              LanKey.dayClearAddFirstQuest.tr,
              textAlign: TextAlign.center,
              style: textStyleMedium(fontSize: 13.sp, color: AppColors.textSecondary),
            ),
          ),
          SizedBox(height: 18.h),
          PressableButton(
            onTap: () => TaskFormSheet.show(Get.context!),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                SizedBox(width: 6.w),
                Text(LanKey.createQuest.tr, style: textStyleBold(fontSize: 15.sp, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _hpText() {
    final char = UserService.to.character.value;
    return '${char?.currentHp ?? 100}/${GameConstants.maxHp}';
  }

  Widget _hudBar({required String label, required Color color, required String text}) {
    return Obx(() {
      final ratio = _ratioFor(label);
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.w,
            child: Text(label, style: textStyleBold(fontSize: 11.sp, color: AppColors.textSecondary)),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Container(
              height: 14.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E7CE),
                border: Border.all(color: AppColors.border, width: 2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: ratio,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: 50.w,
            child: Text(text, style: textStyleBold(fontSize: 12.sp, color: AppColors.textPrimary)),
          ),
        ],
      );
    });
  }

  double _ratioFor(String label) {
    final char = UserService.to.character.value;
    if (label == 'HP') {
      return ((char?.currentHp ?? 100) / GameConstants.maxHp).clamp(0.0, 1.0).toDouble();
    }
    final level = char?.level ?? 1;
    final needed = GameConstants.expForLevel(level).toDouble();
    return ((char?.currentExp.toInt() ?? 0) / needed).clamp(0.0, 1.0).toDouble();
  }

  String _xpText() {
    final char = UserService.to.character.value;
    final level = char?.level ?? 1;
    final needed = GameConstants.expForLevel(level);
    return '${char?.currentExp ?? 0}/$needed';
  }
}
