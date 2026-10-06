import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/features/forge/pages/forge_page.dart';
import 'package:habit_forge_app/features/home/pages/home_page.dart';
import 'package:habit_forge_app/features/home/widgets/bottom_nav.dart';
import 'package:habit_forge_app/features/main/controllers/main_controller.dart';
import 'package:habit_forge_app/features/profile/pages/profile_page.dart';
import 'package:habit_forge_app/features/quests/pages/quests_page.dart';
import 'package:habit_forge_app/widgets/account_bind_banner.dart';
import 'package:habit_forge_app/widgets/death_overlay.dart';
import 'package:habit_forge_app/widgets/gameplay_motion.dart';

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
        body: Column(
          children: [
            // Guest reminder: no account is bound, so an uninstall or a new phone
            // would lose this device's progress. Collapses to nothing once an
            // account is bound (or in local-only builds).
            const SafeArea(bottom: false, child: AccountBindBanner()),
            Expanded(
              child: Stack(
                children: [
                  TabEntrance(
                    index: controller.currentIndex.value,
                    child: IndexedStack(
                      index: controller.currentIndex.value,
                      children: List.generate(
                        tabs.length,
                        (index) => TickerMode(
                          enabled: index == controller.currentIndex.value,
                          child: tabs[index],
                        ),
                      ),
                    ),
                  ),
                  const DamageFeedback(),
                  // Death/recovery state is app-wide: show it from every tab.
                  const DeathOverlay(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNav(
          currentIndex: controller.currentIndex.value,
          onTabChanged: controller.onTabChanged,
        ),
      ),
    );
  }
}
