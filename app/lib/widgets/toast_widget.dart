import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';

/// Convenience methods for Toast
class Toast {
  /// Clear all Toasts
  static void clear() {
    ToastManager.instance.clear();
  }

  /// Show an error Toast
  static void error(String message, {int? duration}) {
    ToastManager.instance.show(message, duration: duration);
  }

  /// Show an info Toast
  static void info(String message, {int? duration}) {
    ToastManager.instance.show(message, duration: duration);
  }

  /// Configure the bottom margin
  static void setBottomMargin(double margin) {
    ToastConfig.bottomMargin = margin;
  }

  /// Configure the default display duration
  static void setDuration(int milliseconds) {
    ToastConfig.duration = milliseconds;
  }

  /// Configure the maximum number of Toasts
  static void setMaxToasts(int max) {
    ToastConfig.maxToasts = max;
  }

  /// Configure the spacing between Toasts
  static void setSpacing(double spacing) {
    ToastConfig.spacing = spacing;
  }

  /// Show a normal Toast
  static void show(String message, {int? duration}) {
    ToastManager.instance.show(message, duration: duration);
  }

  /// Show a success Toast
  static void success(String message, {int? duration}) {
    ToastManager.instance.show(message, duration: duration);
  }

  /// Show a warning Toast
  static void warning(String message, {int? duration}) {
    ToastManager.instance.show(message, duration: duration);
  }
}

/// Toast configuration
class ToastConfig {
  /// Maximum number of Toasts shown at the same time
  static int maxToasts = 1;

  /// Toast display duration (milliseconds)
  static int duration = 2000;

  /// Spacing between Toasts
  static double spacing = 8.0.h;

  /// Toast bottom margin
  static double bottomMargin = MediaQuery.of(Get.context!).size.height * 2 / 3;
}

/// Toast manager
class ToastManager {
  static final ToastManager _instance = ToastManager._();
  static ToastManager get instance => _instance;

  /// List of currently displayed Toasts
  final List<_ToastItem> _toasts = [];

  ToastManager._();

  /// Clear all Toasts
  void clear() {
    for (var toast in _toasts) {
      toast.remove();
    }
    _toasts.clear();
  }

  /// Show a Toast
  void show(String message, {int? duration}) {
    // If the maximum count is exceeded, remove the oldest one (at the end of the list)
    if (_toasts.length >= ToastConfig.maxToasts) {
      final oldest = _toasts.last;
      oldest.remove();
      _toasts.removeLast();
    }

    // Shift all existing toasts' positions up by 1
    for (var i = 0; i < _toasts.length; i++) {
      _toasts[i].updatePosition(i + 1);
    }

    // Create a new Toast with position 0 (at the very bottom)
    final toastItem = _ToastItem(message: message, duration: duration ?? ToastConfig.duration, position: 0);

    // Insert the new toast at the beginning of the list
    _toasts.insert(0, toastItem);

    // Show the Toast
    toastItem.show(() {
      _toasts.remove(toastItem);
      _updatePositions();
    });
  }

  /// Update the position of all Toasts
  void _updatePositions() {
    for (var i = 0; i < _toasts.length; i++) {
      _toasts[i].updatePosition(i);
    }
  }
}

/// Toast item
class _ToastItem {
  final String message;
  final int duration;
  int position;
  OverlayEntry? _overlayEntry;
  final _animationController = Rx<AnimationController?>(null);
  VoidCallback? _onDismiss;

  _ToastItem({required this.message, required this.duration, required this.position});

  /// Remove the Toast
  void remove() {
    if (_overlayEntry == null) return;

    // Invoke the widget's exit animation callback
    if (_onDismiss != null) {
      _onDismiss!();
      // Wait for the exit animation to finish before removing the overlay
      Future.delayed(const Duration(milliseconds: 300), () {
        _overlayEntry?.remove();
        _overlayEntry = null;
        _animationController.value = null;
        _onDismiss = null;
      });
    } else {
      // If there is no callback, remove it directly
      _overlayEntry?.remove();
      _overlayEntry = null;
      _animationController.value = null;
    }
  }

  /// Show a Toast
  void show(VoidCallback onRemove) {
    final overlay = Get.overlayContext;
    if (overlay == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        position: position,
        onAnimationController: (controller) {
          _animationController.value = controller;
        },
        onDismiss: (callback) {
          _onDismiss = callback;
        },
      ),
    );

    Overlay.of(overlay).insert(_overlayEntry!);

    // Automatically remove after the delay
    Future.delayed(Duration(milliseconds: duration), () {
      remove();
      onRemove();
    });
  }

  /// Update the position
  void updatePosition(int newPosition) {
    position = newPosition;
    _overlayEntry?.markNeedsBuild();
  }
}

/// Toast widget
class _ToastWidget extends StatefulWidget {
  final String message;
  final int position;
  final ValueChanged<AnimationController> onAnimationController;
  final ValueChanged<VoidCallback> onDismiss;

  const _ToastWidget({
    required this.message,
    required this.position,
    required this.onAnimationController,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _dismissController;
  late Animation<double> _enterFadeAnimation;
  late Animation<Offset> _enterSlideAnimation;
  late Animation<double> _dismissFadeAnimation;
  late Animation<Offset> _dismissSlideAnimation;
  bool _isDismissing = false;
  double? _lockedBottomOffset; // Lock the position while dismissing

  @override
  Widget build(BuildContext context) {
    // Use the locked position while dismissing; otherwise use the dynamically computed position
    final bottomOffset = _isDismissing
        ? (_lockedBottomOffset ?? ToastConfig.bottomMargin)
        : ToastConfig.bottomMargin + widget.position * (60.h + ToastConfig.spacing);

    return Positioned(
      left: 16.w,
      right: 16.w,
      bottom: bottomOffset,
      child: AnimatedBuilder(
        animation: Listenable.merge([_controller, _dismissController]),
        builder: (context, child) {
          // Pick the animation based on the current state
          final opacity = _isDismissing ? _dismissFadeAnimation.value : _enterFadeAnimation.value;
          final offset = _isDismissing ? _dismissSlideAnimation.value : _enterSlideAnimation.value;

          return Transform.translate(
            offset: Offset(0, offset.dy * 60.h), // Convert to actual pixels
            child: Opacity(opacity: opacity, child: child),
          );
        },
        child: IgnorePointer(
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 300.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                widget.message,
                style: textStyleMedium(color: Colors.white, fontSize: 13.sp).copyWith(decoration: TextDecoration.none),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _dismissController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Enter animation controller
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    // Exit animation controller
    _dismissController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    // Enter animation: fade in
    _enterFadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Enter animation: slide in from the bottom
    _enterSlideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Exit animation: slide out upward (starting from the current position Offset.zero)
    _dismissSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1), // Move upward
    ).animate(CurvedAnimation(parent: _dismissController, curve: Curves.easeInCubic));

    // Exit animation: fade out
    _dismissFadeAnimation = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _dismissController, curve: Curves.easeInOut));

    widget.onAnimationController(_controller);

    // Register the exit animation callback
    widget.onDismiss(_startDismissAnimation);

    // Play the enter animation
    _controller.forward();
  }

  /// Start the exit animation
  void _startDismissAnimation() {
    if (!mounted || _isDismissing) return;

    // Lock the current position so the toast doesn't move due to position updates while dismissing
    _lockedBottomOffset = ToastConfig.bottomMargin + widget.position * (60.h + ToastConfig.spacing);

    setState(() {
      _isDismissing = true;
    });

    // Play the exit animation
    _dismissController.forward();
  }
}
