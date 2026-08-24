import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/features/achievements/bindings/achievements_binding.dart';
import 'package:habit_forge_app/features/achievements/pages/achievements_page.dart';
import 'package:habit_forge_app/features/auth/bindings/auth_binding.dart';
import 'package:habit_forge_app/features/auth/pages/auth_page.dart';
import 'package:habit_forge_app/features/auth/pages/email_login_page.dart';
import 'package:habit_forge_app/features/boarding/bindings/boarding_binding.dart';
import 'package:habit_forge_app/features/boarding/pages/boarding_page.dart';
import 'package:habit_forge_app/features/character/bindings/character_binding.dart';
import 'package:habit_forge_app/features/character/pages/character_page.dart';
import 'package:habit_forge_app/features/main/bindings/main_binding.dart';
import 'package:habit_forge_app/features/main/pages/main_page.dart';
import 'package:habit_forge_app/features/settings/bindings/settings_binding.dart';
import 'package:habit_forge_app/features/settings/pages/settings_page.dart';
import 'package:habit_forge_app/features/splash/bindings/splash_binding.dart';
import 'package:habit_forge_app/features/splash/pages/splash_page.dart';
import 'package:habit_forge_app/features/statistics/bindings/statistics_binding.dart';
import 'package:habit_forge_app/features/statistics/pages/statistics_page.dart';

class AppPages {
  static final List<GetPage> pages = [
    commonFadeInPage(name: Routers.splash, binding: SplashBinding(), page: () => SplashPage()),
    commonFadeInPage(name: Routers.login, binding: AuthBinding(), page: () => AuthPage()),
    commonFadeInPage(name: Routers.boarding, binding: BoardBinding(), page: () => BoardingPage()),
    commonFadeInPage(name: Routers.main, binding: MainBinding(), page: () => MainPage()),
    commonCupertinoPage(name: Routers.emailLogin, binding: AuthBinding(), page: () => EmailLoginPage()),
    commonCupertinoPage(name: Routers.character, binding: CharacterBinding(), page: () => CharacterPage()),
    commonCupertinoPage(name: Routers.achievements, binding: AchievementsBinding(), page: () => AchievementsPage()),
    commonCupertinoPage(name: Routers.statistics, binding: StatisticsBinding(), page: () => StatisticsPage()),
    commonCupertinoPage(name: Routers.settings, binding: SettingsBinding(), page: () => SettingsPage()),
  ];

  // Common transition route (right to left)
  static GetPage commonCupertinoPage(
          {required String name, required Bindings binding, required Widget Function() page,}) =>
      GetPage(
          name: name,
          binding: binding,
          page: page,
          transition: Transition.cupertino,
          transitionDuration: const Duration(milliseconds: 300),);

  // Common transition route (FadeIn)
  static GetPage commonFadeInPage({required String name, required Bindings binding, required Widget Function() page}) =>
      GetPage(
          name: name,
          binding: binding,
          page: page,
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 500),);
}

class Routers {
  static final String splash = "/splash";
  static final String login = "/login";
  static final String emailLogin = "/login/email";
  static final String boarding = "/boarding";
  static final String main = "/main";
  static final String home = "/home";
  static final String quests = "/quests";
  static final String forge = "/forge";
  static final String profile = "/profile";
  static final String character = "/character";
  static final String achievements = "/achievements";
  static final String statistics = "/statistics";
  static final String settings = "/settings";
}
