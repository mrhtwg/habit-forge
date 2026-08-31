import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/animation/frame_sequence_player.dart';
import 'package:habit_forge_app/core/constants/env_constants.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/features/boarding/controllers/boarding_controller.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pbenum.dart';

class BoardingPage extends GetView<BoardingController> {
  static const _totalSteps = 4;
  const BoardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Obx(() {
            final step = controller.currentStep;
            return Column(
              children: [
                SizedBox(height: 10.h),
                _buildTopBar(step),
                SizedBox(height: 6.h),
                Expanded(child: _buildStepContent(step)),
                SizedBox(height: 10.h),
                _buildBottomButton(step),
                SizedBox(height: 30.h),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ── Bottom button ──
  Widget _buildBottomButton(int step) {
    if (step == 2) {
      // Habit step: Skip + Next
      return Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: controller.skip,
              child: _button(
                label: LanKey.skip.tr,
                bg: Colors.transparent,
                borderColor: AppColors.textMuted,
                textColor: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: Obx(() {
              final enabled = controller.firstHabitTitle.value.isNotEmpty;
              return GestureDetector(
                onTap: enabled ? () => controller.nextStep() : null,
                child: _button(
                  label: LanKey.next.tr,
                  bg: enabled ? AppColors.gold : AppColors.elevated,
                  borderColor: enabled ? AppColors.border : AppColors.elevated,
                  textColor: enabled ? AppColors.textPrimary : AppColors.textMuted,
                ),
              );
            }),
          ),
        ],
      );
    }

    final label = switch (step) {
      0 => LanKey.getStarted.tr,
      1 => LanKey.chooseClass.trParams({
          'class': switch (controller.selectedClass.value) {
            CharacterClass.CHARACTER_CLASS_WARRIOR => LanKey.warrior.tr.toUpperCase(),
            CharacterClass.CHARACTER_CLASS_MAGE => LanKey.mage.tr.toUpperCase(),
            CharacterClass.CHARACTER_CLASS_RANGER => LanKey.ranger.tr.toUpperCase(),
            _ => '',
          },
        }),
      _ => LanKey.enterTheRealm.tr,
    };
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: step == 3 ? controller.complete : controller.nextStep,
        child: _button(
          label: label,
          bg: AppColors.gold,
          borderColor: AppColors.border,
          textColor: AppColors.textPrimary,
        ),
      ),
    );
  }

  // ── Step content ──
  Widget _buildStepContent(int step) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: switch (step) {
        0 => _welcomeContent(),
        1 => _classContent(),
        2 => _habitContent(),
        _ => _readyContent(),
      },
    );
  }

  // ── Top bar: Step X of 4 + Skip ──
  Widget _buildTopBar(int step) {
    return SizedBox(
      height: 44.h,
      child: Row(
        children: [
          if (step > 0)
            GestureDetector(
              onTap: () => controller.preStep(),
              child: Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.textPrimary),
              ),
            )
          else if (!EnvConstants.isHive()) ...[
            GestureDetector(
              onTap: () => Get.offAllNamed(EnvConstants.isHive() ? Routers.main : Routers.login),
              child: Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.textPrimary),
              ),
            ),
          ],
          if (step > 0) SizedBox(width: 10.w),
          Text(
            LanKey.stepOf.trParams({'n': '${step + 1}', 'total': controller.totalStepsCount.toString()}),
            style: textStyleBold(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          const Spacer(),
          if (step < _totalSteps - 1)
            GestureDetector(
              onTap: controller.skip,
              child: Text(LanKey.skip.tr, style: textStyleBold(fontSize: 14.sp, color: AppColors.primaryDark)),
            ),
        ],
      ),
    );
  }

  Widget _button({
    required String label,
    required Color bg,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: borderColor, width: 2.5),
        borderRadius: BorderRadius.circular(999),
        boxShadow:
            borderColor != AppColors.border ? null : const [BoxShadow(color: AppColors.goldDark, offset: Offset(0, 4))],
      ),
      child: Center(
        child: Text(
          label,
          style: textStyleBold(fontSize: 16.sp, color: textColor),
        ),
      ),
    );
  }

  // ── Step 2: Class ──
  Widget _classContent() {
    final classes = <(CharacterClass, LanKey, LanKey, List<double>, Color)>[
      (
        CharacterClass.CHARACTER_CLASS_WARRIOR,
        LanKey.warrior,
        LanKey.braveAndTough,
        [0.92, 0.7, 0.45],
        AppColors.primary,
      ),
      (
        CharacterClass.CHARACTER_CLASS_MAGE,
        LanKey.mage,
        LanKey.cleverAndCurious,
        [0.45, 0.7, 0.95],
        AppColors.primaryDark,
      ),
      (
        CharacterClass.CHARACTER_CLASS_RANGER,
        LanKey.ranger,
        LanKey.swiftAndSteady,
        [0.65, 0.7, 0.85],
        AppColors.greenDark,
      ),
    ];
    return Column(
      key: const ValueKey('class'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LanKey.chooseYourHero.tr, style: textStyleBlack(fontSize: 28.sp, color: AppColors.textPrimary)),
        SizedBox(height: 6.h),
        Text(
          LanKey.classesGrowDifferently.tr,
          style: textStyleMedium(fontSize: 13.sp, color: AppColors.textSecondary),
        ),
        SizedBox(height: 16.h),
        Expanded(
          child: ListView.separated(
            itemCount: classes.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, i) {
              final cls = classes[i];
              return Obx(() {
                final selected = controller.selectedClass.value == cls.$1;
                return GestureDetector(
                  onTap: () => controller.selectClass(cls.$1),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? AppColors.primaryDark : AppColors.border,
                        width: selected ? 3 : 2,
                      ),
                      boxShadow: selected
                          ? const [BoxShadow(color: Color(0xFFD9C6FF), offset: Offset(0, 4))]
                          : const [BoxShadow(color: Color(0xFFEFDFC4), offset: Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        // Class avatar circular frame
                        Container(
                          width: 64.w,
                          height: 64.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cls.$5.withValues(alpha: 0.15),
                            border: Border.all(color: AppColors.border, width: 2),
                          ),
                          child: ClipOval(
                            child: switch (cls.$1) {
                              CharacterClass.CHARACTER_CLASS_WARRIOR => FrameSequencePlayer(
                                  frames: FrameSequencePlayer.knightIdleFrames(),
                                  preferredSize: Size(48.w, 60.h),
                                ),
                              CharacterClass.CHARACTER_CLASS_MAGE => FrameSequencePlayer(
                                  frames: FrameSequencePlayer.mageIdleFrames(),
                                  preferredSize: Size(48.w, 60.h),
                                ),
                              _ => FrameSequencePlayer(
                                  frames: FrameSequencePlayer.rangerIdleFrames(),
                                  preferredSize: Size(48.w, 60.h),
                                ),
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Name + description + stat bars
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cls.$2.tr,
                                style: textStyleBlack(fontSize: 17.sp, color: AppColors.textPrimary),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                cls.$3.tr,
                                style: textStyleMedium(fontSize: 11.5.sp, color: AppColors.textSecondary),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: cls.$4.map((v) {
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 5.w),
                                      child: Container(
                                        height: 7.h,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFE2F5),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: v,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: cls.$5,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        // Selection circle
                        Container(
                          width: 26.w,
                          height: 26.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected ? AppColors.primary : Colors.white,
                            border: Border.all(color: AppColors.border, width: 2.5),
                          ),
                          child: selected ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null,
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }

  // ── Step 3: Habit ──
  Widget _habitContent() {
    final suggestions = <(LanKey, String, IconData)>[
      (LanKey.drink8GlassesOfWater, 'Drink 8 glasses of water', Icons.water_drop_rounded),
      (LanKey.readFor30Minutes, 'Read for 30 minutes', Icons.menu_book_rounded),
      (LanKey.morningExercise, 'Morning exercise', Icons.directions_run_rounded),
    ];
    return Column(
      key: const ValueKey('habit'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LanKey.forgeFirstHabit.tr, style: textStyleBlack(fontSize: 26.sp, color: AppColors.textPrimary)),
        SizedBox(height: 6.h),
        Text(
          LanKey.smallQuestsBigRewards.tr,
          style: textStyleMedium(fontSize: 13.sp, color: AppColors.textSecondary),
        ),
        SizedBox(height: 16.h),
        Obx(
          () {
            final selectedTitle = controller.firstHabitTitle.value;
            return Expanded(
              child: ListView.separated(
                itemCount: suggestions.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, i) {
                  final s = suggestions[i];
                  final selected = selectedTitle == s.$2;
                  return GestureDetector(
                    onTap: () => controller.selectHabit(s.$2),
                    child: Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: selected ? AppColors.greenDark : AppColors.border,
                          width: selected ? 3 : 2,
                        ),
                        boxShadow: selected
                            ? const [BoxShadow(color: Color(0xFFC6EBD4), offset: Offset(0, 4))]
                            : const [BoxShadow(color: Color(0xFFEFDFC4), offset: Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              color: AppColors.goldLight,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border, width: 1.5),
                            ),
                            child: Icon(s.$3, size: 22.w, color: AppColors.goldDark),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              s.$1.tr,
                              style: textStyleBold(fontSize: 15.sp, color: AppColors.textPrimary),
                            ),
                          ),
                          Container(
                            width: 26.w,
                            height: 26.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected ? AppColors.green : Colors.white,
                              border: Border.all(color: AppColors.border, width: 2.5),
                            ),
                            child: selected ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Step 4: Ready ──
  Widget _readyContent() {
    return Column(
      key: const ValueKey('ready'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _skySceneCard(
          child: FrameSequencePlayer(
            frames: switch (controller.selectedClass.value) {
              CharacterClass.CHARACTER_CLASS_WARRIOR => FrameSequencePlayer.knightIdleFrames(),
              CharacterClass.CHARACTER_CLASS_MAGE => FrameSequencePlayer.mageIdleFrames(),
              CharacterClass.CHARACTER_CLASS_RANGER => FrameSequencePlayer.rangerIdleFrames(),
              _ => FrameSequencePlayer.knightIdleFrames(),
            },
            preferredSize: Size(160.h, 180.h),
          ),
        ),
        SizedBox(height: 18.h),
        Text(
          LanKey.youreAllSetAdventurer.tr,
          textAlign: TextAlign.center,
          style: textStyleBlack(fontSize: 28.sp, color: AppColors.textPrimary),
        ),
        SizedBox(height: 10.h),
        Text(
          LanKey.completeQuestsEarnXpAndGold.tr,
          textAlign: TextAlign.center,
          style: textStyleMedium(fontSize: 13.5.sp, color: AppColors.textSecondary).copyWith(height: 1.5),
        ),
        SizedBox(height: 16.h),
        // Summary card
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border, width: 2),
            boxShadow: const [BoxShadow(color: Color(0xFFEFDFC4), offset: Offset(0, 4))],
          ),
          child: Column(
            children: [
              _summaryRow(
                icon: Icons.auto_awesome_rounded,
                bg: const Color(0xFFF6E6FF),
                title: switch (controller.selectedClass.value) {
                  CharacterClass.CHARACTER_CLASS_WARRIOR => LanKey.warrior.tr,
                  CharacterClass.CHARACTER_CLASS_MAGE => LanKey.mage.tr,
                  CharacterClass.CHARACTER_CLASS_RANGER => LanKey.ranger.tr,
                  _ => LanKey.warrior.tr,
                }
                    .toUpperCase(),
                subtitle: LanKey.yourHeroClass.tr,
              ),
              SizedBox(height: 10.h),
              _summaryRow(
                icon: Icons.flag_rounded,
                bg: AppColors.goldLight,
                title:
                    controller.firstHabitTitle.value.isEmpty ? LanKey.noHabitYet.tr : controller.firstHabitTitle.value,
                subtitle: LanKey.yourFirstHabit.tr,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Sky scene card (shared by Welcome / Ready) ──
  Widget _skySceneCard({required Widget child}) {
    return Container(
      width: double.infinity,
      height: 250.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8FD4FF), Color(0xFFC8ECFF), Color(0xFFE4F6FF)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: Stack(
        children: [
          // Sun
          Positioned(
            top: 14.h,
            right: 20.w,
            child: Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFFFE38A), AppColors.gold],
                ),
                border: Border.all(color: AppColors.border, width: 2),
              ),
            ),
          ),
          // Cloud
          Positioned(
            top: 22.h,
            left: 24.w,
            child: Container(
              width: 64.w,
              height: 26.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFD6EAF7), width: 1.5),
              ),
            ),
          ),
          Center(child: child),
          // Grass slope
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
              child: Container(
                height: 34.h,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF9FE29F), Color(0xFF5FCE74)]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({
    required IconData icon,
    required Color bg,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Icon(icon, size: 20.w, color: AppColors.primaryDark),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textStyleBold(fontSize: 14.sp, color: AppColors.textPrimary)),
              Text(subtitle, style: textStyleMedium(fontSize: 11.sp, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 1: Welcome ──
  Widget _welcomeContent() {
    return Column(
      key: const ValueKey('welcome'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _skySceneCard(
          child: FrameSequencePlayer(
            frames: FrameSequencePlayer.knightIdleFrames(),
            preferredSize: Size(170.h, 190.h),
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          LanKey.lifeIsGrandAdventure.tr,
          textAlign: TextAlign.center,
          style: textStyleBlack(fontSize: 30.sp, color: AppColors.textPrimary),
        ),
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            LanKey.finishTasksEarnXpAndGold.tr,
            textAlign: TextAlign.center,
            style: textStyleMedium(fontSize: 14.sp, color: AppColors.textSecondary).copyWith(height: 1.5),
          ),
        ),
      ],
    );
  }
}
