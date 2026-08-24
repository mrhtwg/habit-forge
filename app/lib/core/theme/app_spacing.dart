import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSpacing {
  static double get bottomNavHeight => 64.h;
  static double get buttonRadius => 8.r;
  static double get cardRadius => 12.r;
  static List<BoxShadow> get cardShadow => [
        BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12.r, offset: Offset(0, 4.h)),
      ];
  static double get chipRadius => 20.r;
  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 32.r, offset: Offset(0, 8.h)),
      ];
  static double get inputRadius => 12.r;
  static double get lg => 24.w;

  static double get md => 16.w;
  static double get sheetRadius => 16.r;
  static double get sm => 8.w;
  static double get taskTileHeight => 72.h;
  static double get xl => 32.w;

  static double get xs => 4.w;
  static double get xxl => 48.w;

  static double get xxxl => 64.w;
  AppSpacing._();
}
