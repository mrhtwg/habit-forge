import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/features/forge/pages/forge_page.dart';
import 'package:habit_forge_app/features/home/pages/home_page.dart';
import 'package:habit_forge_app/features/home/widgets/bottom_nav.dart';
import 'package:habit_forge_app/features/main/controllers/main_controller.dart';
import 'package:habit_forge_app/features/profile/pages/profile_page.dart';
import 'package:habit_forge_app/features/quests/pages/quests_page.dart';

class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const HomePage(),
      const QuestsPage(),
      const ForgePage(),
      const ProfilePage(),
    ];

    return Obx(
      () => Scaffold(
        body: IndexedStack(index: controller.currentIndex.value, children: tabs),
        bottomNavigationBar: BottomNav(
          currentIndex: controller.currentIndex.value,
          onTabChanged: controller.onTabChanged,
        ),
      ),
    );
  }
}
