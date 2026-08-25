import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class BottomNav extends StatelessWidget {
  static final _tabs = [
    (label: LanKey.home.tr, icon: PhosphorIcons.house(PhosphorIconsStyle.fill)),
    (label: LanKey.quests.tr, icon: PhosphorIcons.scroll(PhosphorIconsStyle.fill)),
    (label: LanKey.forge.tr, icon: PhosphorIcons.hammer(PhosphorIconsStyle.fill)),
    (label: LanKey.profile.tr, icon: PhosphorIcons.user(PhosphorIconsStyle.fill)),
  ];
  final int currentIndex;

  final ValueChanged<int> onTabChanged;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 2)),
      ),
      padding: EdgeInsets.only(top: 8.h, bottom: MediaQuery.of(context).padding.bottom + 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_tabs.length, (index) {
          final isActive = index == currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 6.w),
                padding: EdgeInsets.symmetric(vertical: 6.h),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.violetLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Active icon placed on a circular background
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? AppColors.primary : Colors.transparent,
                        border: isActive ? Border.all(color: AppColors.primaryDark, width: 2) : null,
                        boxShadow:
                            isActive ? const [BoxShadow(color: AppColors.primaryDark, offset: Offset(0, 3))] : null,
                      ),
                      child: Icon(
                        _tabs[index].icon,
                        size: 18.w,
                        color: isActive ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      _tabs[index].label,
                      style: textStyleBold(
                        fontSize: 11.sp,
                        color: isActive ? AppColors.primaryDark : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
