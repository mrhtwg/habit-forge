import 'package:flutter/material.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';

/// HabitForge pressable button.
///
/// Normal state keeps the game-style look: a **hard** drop shadow (no blur)
/// below the button. On press the shadow disappears and the button sinks down
/// by [pressOffset]; on release it animates back to the regular raised state.
///
/// Works for both pill and circular shapes — use a large [borderRadius]
/// (e.g. 999) and equal padding for a circle.
class PressableButton extends StatefulWidget {
  /// The button content (icon / label row).
  final Widget child;

  /// Tap handler; when null the button is inert.
  final VoidCallback? onTap;

  final Color backgroundColor;

  final Color borderColor;
  final Color shadowColor;

  /// Border thickness (2 for pills, 2.5 for the circular FAB).
  final double borderWidth;

  /// Inner padding that (together with the child) defines the button size.
  final EdgeInsetsGeometry padding;

  /// Corner radius; 999 gives a pill, or a circle when width == height.
  final double borderRadius;

  /// How far the button sinks on press (also the shadow offset).
  final double pressOffset;

  /// Animation duration for the press / release transition.
  final Duration duration;

  const PressableButton({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor = AppColors.primary,
    this.borderColor = AppColors.border,
    this.shadowColor = AppColors.primaryDark,
    this.borderWidth = 2,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.borderRadius = 999,
    this.pressOffset = 4,
    this.duration = const Duration(milliseconds: 50),
  });

  @override
  State<PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<PressableButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
      onTapUp: widget.onTap == null ? null : (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: widget.duration,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _pressed ? widget.pressOffset : 0, 0),
        transformAlignment: Alignment.center,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: widget.borderColor, width: widget.borderWidth),
          boxShadow: _pressed ? null : [BoxShadow(color: widget.shadowColor, offset: Offset(0, widget.pressOffset))],
        ),
        child: widget.child,
      ),
    );
  }

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }
}
