import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';

class AppTypography {
  AppTypography._();

  static const String _display = 'Baloo2';
  static const String _body = 'Nunito';
  static const String _mono = 'Nunito';

  static TextStyle get displayLarge =>
      TextStyle(fontFamily: _display, fontSize: 32.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary);
  static TextStyle get displayMedium =>
      TextStyle(fontFamily: _display, fontSize: 28.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary);
  static TextStyle get displaySmall =>
      TextStyle(fontFamily: _display, fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary);
  static TextStyle get headline =>
      TextStyle(fontFamily: _body, fontSize: 20.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get title =>
      TextStyle(fontFamily: _body, fontSize: 18.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get subtitle =>
      TextStyle(fontFamily: _body, fontSize: 16.sp, fontWeight: FontWeight.w500, color: AppColors.textSecondary);
  static TextStyle get body =>
      TextStyle(fontFamily: _body, fontSize: 14.sp, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static TextStyle get caption =>
      TextStyle(fontFamily: _body, fontSize: 12.sp, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static TextStyle get label =>
      TextStyle(fontFamily: _body, fontSize: 10.sp, fontWeight: FontWeight.w500, color: AppColors.textMuted);
  static TextStyle get number =>
      TextStyle(fontFamily: _mono, fontSize: 16.sp, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
}
