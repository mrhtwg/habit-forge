import 'package:flutter/material.dart';

/// A [Text] that rolls its number smoothly whenever [value] changes.
///
/// On the first build it shows the current value immediately; on subsequent
/// changes it tweens from the previous value to the new one.
class AnimatedNumberText extends StatelessWidget {
  /// The target number to display.
  final int value;

  final Duration duration;
  final Curve curve;

  final TextStyle? style;
  final TextAlign? textAlign;

  /// Optional display formatter (e.g. thousands separators or a suffix).
  final String Function(int value)? formatter;

  const AnimatedNumberText(
    this.value, {
    super.key,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.style,
    this.textAlign,
    this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, animated, _) {
        final display = formatter?.call(animated.round()) ?? animated.round().toString();
        return Text(display, style: style, textAlign: textAlign);
      },
    );
  }
}
