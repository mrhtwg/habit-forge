import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/generated/assets.dart';

class StatBar extends StatefulWidget {
  final int current;
  final int max;

  const StatBar({
    super.key,
    required this.current,
    required this.max,
  });

  @override
  State<StatBar> createState() => _StatBarState();
}

class _StatBarState extends State<StatBar> with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  late final CurvedAnimation _glowAnimation;

  bool get _isLowHp => (widget.current / widget.max) < 0.3;

  @override
  Widget build(BuildContext context) {
    final ratio = (widget.current / widget.max).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        SizedBox(
          height: 22,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: ratio),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  // The marker image is taller than the progress bar (22), so when vertically centered it protrudes above and below, overlapping the bar
                  final markerSize = 30.w;
                  final barWidth = constraints.maxWidth;
                  // Center the marker on the progress tip; clamp at both ends to avoid overflow clipping
                  final markerLeft = (barWidth * value - markerSize / 2).clamp(0.0, barWidth - markerSize).toDouble();
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (_isLowHp)
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            final glowValue = _glowAnimation.value;
                            return Container(
                              width: double.infinity,
                              height: 22,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9999),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.red.withValues(
                                      alpha: 0.3 + glowValue * 0.4,
                                    ),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(
                            color: Color(0xFF60344e).withValues(alpha: 0.35),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9999),
                          child: Stack(
                            children: [
                              // Background bar
                              Container(
                                height: 22,
                                color: Color(0xFFbb66f5).withValues(alpha: 0.3),
                              ),
                              // Foreground: red → pink gradient from left to right, width grows with value
                              FractionallySizedBox(
                                widthFactor: value,
                                child: Container(
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppColors.red, AppColors.pink],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Current progress position marker: golden image overlaid on the progress bar
                      Positioned(
                        left: markerLeft,
                        top: (22 - markerSize) / 2,
                        child: Image.asset(
                          Assets.imagesSharedStatArrow,
                          width: markerSize,
                          height: markerSize,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void didUpdateWidget(covariant StatBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isLowHp) {
      if (!_glowController.isAnimating) {
        _glowController.repeat(reverse: true);
      }
    } else {
      if (_glowController.isAnimating) {
        _glowController.stop();
        _glowController.reset();
      }
    }
  }

  @override
  void dispose() {
    _glowAnimation.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glowAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );
    if (_isLowHp) {
      _glowController.repeat(reverse: true);
    }
  }
}
