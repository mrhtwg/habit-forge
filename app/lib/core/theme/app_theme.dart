import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_spacing.dart';
import 'package:habit_forge_app/core/theme/app_typography.dart';

// Font families (corresponds to pubspec fonts)
const _displayFont = 'Baloo2'; // Rounded display font: titles / logo / key numbers
const _handFont = 'Caveat'; // Handwritten accents
const _uiFont = 'Nunito'; // Rounded body text

// Text outline
Widget buildOutlineText(String text, TextStyle textStyle, {Color strokeColor = Colors.white, double strokeWidth = 1}) {
  return Stack(
    children: [
      Text(
        text,
        style: textStyle.copyWith(color: Colors.transparent).copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth
                ..color = strokeColor,
            ),
      ),
      Text(text, style: textStyle),
    ],
  );
}

TextStyle textStyleBlack({double? fontSize, Color? color}) => TextStyle(
      fontSize: fontSize ?? 18.sp,
      color: color ?? AppColors.textPrimary,
      fontFamily: _displayFont,
      fontWeight: FontWeight.w800,
    );

TextStyle textStyleBold({double? fontSize, Color? color}) => TextStyle(
      fontSize: fontSize ?? 18.sp,
      color: color ?? AppColors.textPrimary,
      fontFamily: _displayFont,
      fontWeight: FontWeight.w700,
    );

/// Handwritten accent font (greetings / reward cheers, etc.)
TextStyle textStyleHand({double? fontSize, Color? color}) => TextStyle(
      fontSize: fontSize ?? 20.sp,
      color: color ?? AppColors.textPrimary,
      fontFamily: _handFont,
      fontWeight: FontWeight.w600,
    );

TextStyle textStyleLight({double? fontSize, Color? color}) => TextStyle(
      fontSize: fontSize ?? 14.sp,
      color: color ?? AppColors.textPrimary,
      fontFamily: _uiFont,
      fontWeight: FontWeight.w300,
    );

TextStyle textStyleMedium({double? fontSize, Color? color}) => TextStyle(
      fontSize: fontSize ?? 14.sp,
      color: color ?? AppColors.textPrimary,
      fontFamily: _uiFont,
      fontWeight: FontWeight.w500,
    );

TextStyle textStyleNormal({double? fontSize, Color? color}) => textStyleRegular(fontSize: fontSize, color: color);

TextStyle textStyleRegular({double? fontSize, Color? color}) => TextStyle(
      fontSize: fontSize ?? 14.sp,
      color: color ?? AppColors.textPrimary,
      fontFamily: _uiFont,
      fontWeight: FontWeight.w400,
    );

TextStyle textStyleSemiBold({double? fontSize, Color? color}) => textStyleBold(fontSize: fontSize, color: color);

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.scaffold,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.gold,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineLarge: AppTypography.headline,
        headlineMedium: AppTypography.title,
        titleLarge: AppTypography.subtitle,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.caption,
        labelSmall: AppTypography.label,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: const BorderSide(color: AppColors.border, width: 1.5),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
