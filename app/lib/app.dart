import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/i18n/app_locale.dart';
import 'package:habit_forge_app/core/i18n/app_translations.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/widgets/toast_widget.dart';

class HabitForgeApp extends StatelessWidget {
  const HabitForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => GetMaterialApp(
        title: 'HabitForge',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        translations: AppTranslations(),
        locale: AppLocale.initialLocale(),
        fallbackLocale: const Locale('en'),
        supportedLocales: const [Locale('en'), Locale('zh')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: Routers.splash,
        getPages: AppPages.pages,
        builder: (context, child) {
          // App-wide Toast overlay sits above the Navigator (and above any
          // bottom sheet / dialog), so Toast.show works without a context.
          return Stack(
            textDirection: TextDirection.ltr,
            children: [
              MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
                child: child ?? const SizedBox(),
              ),
              ToastOverlay.mount(),
            ],
          );
        },
      ),
    );
  }
}
