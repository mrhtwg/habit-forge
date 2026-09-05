import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:habit_forge_app/core/network/hive/game_constants.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';

class HudBar extends StatelessWidget {
  final String label;
  final Color color;
  final String text;

  const HudBar({super.key, required this.label, required this.color, required this.text});
  @override
  Widget build(BuildContext context) {
    final ratio = _ratioFor(label);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 10.w),
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
}
