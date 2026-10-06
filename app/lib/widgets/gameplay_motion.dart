import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';

class TabEntrance extends StatefulWidget {
  final int index;
  final Widget child;

  const TabEntrance({super.key, required this.index, required this.child});

  @override
  State<TabEntrance> createState() => _TabEntranceState();
}

class _TabEntranceState extends State<TabEntrance> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
    value: 1,
  );
  late final Animation<double> _opacity = Tween(begin: 0.75, end: 1.0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
  );
  late final Animation<Offset> _position = Tween(begin: const Offset(0, 0.015), end: Offset.zero).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) _controller.value = 1;
  }

  @override
  void didUpdateWidget(covariant TabEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index && !MediaQuery.disableAnimationsOf(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _position, child: widget.child),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class DamageFeedback extends StatefulWidget {
  const DamageFeedback({super.key});

  @override
  State<DamageFeedback> createState() => _DamageFeedbackState();
}

class _DamageFeedbackState extends State<DamageFeedback> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
    value: 1,
  );
  late final Worker _worker;
  Character? _previous;
  int _damage = 0;

  @override
  void initState() {
    super.initState();
    _previous = UserService.to.character.value?.deepCopy();
    _worker = ever<Character?>(UserService.to.character, (character) {
      final previous = _previous;
      _previous = character?.deepCopy();
      if (!mounted || previous == null || character == null || previous.id != character.id) return;
      final damage = previous.currentHp - character.currentHp;
      if (damage <= 0 || MediaQuery.disableAnimationsOf(context)) return;
      _damage = damage;
      _controller.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final progress = _controller.value;
              final opacity = (1 - progress).clamp(0.0, 1.0);
              return Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.coral.withValues(alpha: opacity * 0.35), width: 5.w),
                      ),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0, -0.45),
                    child: Transform.translate(
                      offset: Offset(0, -24.h * progress),
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: AppColors.coral,
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          child: Text(
                            '-$_damage HP',
                            style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _worker.dispose();
    _controller.dispose();
    super.dispose();
  }
}
