import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/animation/frame_sequence_player.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/features/splash/controllers/splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF9ED9FF), Color(0xFFC8ECFF), Color(0xFFE4F6FF)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FrameSequencePlayer(
                frames: FrameSequencePlayer.knightIdleFrames(),
                preferredSize: Size(200.h, 220.h),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Habit ',
                    style: textStyleBlack(fontSize: 46.sp, color: AppColors.textPrimary),
                  ),
                  Text(
                    'Forge',
                    style: textStyleBlack(fontSize: 46.sp, color: Color(0xff7b4fe0)),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: 240.w,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation(AppColors.gold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
