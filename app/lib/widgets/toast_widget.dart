import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';

/// Hosts the app-wide Toast overlay.
///
/// Mounted once at the root of the widget tree (see HabitForgeApp), above the
/// Navigator, so [Toast] can show from anywhere — bottom sheets, dialogs,
/// early startup — without requiring a BuildContext.
class ToastOverlay {
  static final GlobalKey<OverlayState> _key = GlobalKey<OverlayState>();

  ToastOverlay._();

  /// The root-level [Overlay] widget; place it above the app's Navigator.
  static Widget mount() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Overlay(key: _key),
    );
  }

  /// Insert an entry into the Toast overlay. No-op when the overlay is not
  /// mounted yet (e.g. Toast called before runApp).
  static void insert(OverlayEntry entry) {
    _key.currentState?.insert(entry);
  }
}

/// Convenience methods for Toast
class Toast {
  /// Clear all Toasts
  static void clear() {
    ToastManager.instance.clear();
  }

  /// Show an error Toast
  static void error(String msg, {int? duration}) {
    ToastManager.instance.show(
      msg,
      duration: duration,
      icon: Icons.error_rounded,
      iconColor: AppColors.coral,
    );
  }

  /// Show an info Toast
  static void info(String msg, {int? duration}) {
    ToastManager.instance.show(
      msg,
      duration: duration,
      icon: Icons.info_rounded,
      iconColor: AppColors.info,
    );
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
  static void show(String msg, {int? duration}) {
    ToastManager.instance.show(
      msg,
      duration: duration,
      icon: Icons.bolt_rounded,
      iconColor: AppColors.primary,
    );
  }

  /// Show a success Toast
  static void success(String msg, {int? duration}) {
    ToastManager.instance.show(
      msg,
      duration: duration,
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.green,
    );
  }

  /// Show a warning Toast
  static void warning(String msg, {int? duration}) {
    ToastManager.instance.show(
      msg,
      duration: duration,
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.warning,
    );
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

  /// Toast bottom margin (2/3 of the screen height by default, or a custom
  /// value set via [Toast.setBottomMargin]).
  static double? _customBottomMargin;

  static double get bottomMargin {
    if (_customBottomMargin != null) return _customBottomMargin!;
    final ctx = Get.context;
    if (ctx == null) return 400;
    return MediaQuery.of(ctx).size.height * 2 / 3;
  }

  static set bottomMargin(double value) {
    _customBottomMargin = value;
  }
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
  void show(
    String msg, {
    int? duration,
    IconData? icon,
    Color? iconColor,
  }) {
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
    final toastItem = _ToastItem(
      msg: msg,
      duration: duration ?? ToastConfig.duration,
      position: 0,
      icon: icon ?? Icons.info_rounded,
      iconColor: iconColor ?? AppColors.info,
    );

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
  final String msg;
  final int duration;
  final IconData icon;
  final Color iconColor;
  int position;
  OverlayEntry? _overlayEntry;
  final _animationController = Rx<AnimationController?>(null);
  VoidCallback? _onDismiss;

  _ToastItem({
    required this.msg,
    required this.duration,
    required this.icon,
    required this.iconColor,
    required this.position,
  });

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
    // Insert into the app-wide Toast overlay mounted at the root, so no
    // caller BuildContext is needed (works in sheets, dialogs, startup).
    _overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        msg: msg,
        position: position,
        icon: icon,
        iconColor: iconColor,
        onAnimationController: (controller) {
          _animationController.value = controller;
        },
        onDismiss: (callback) {
          _onDismiss = callback;
        },
      ),
    );

    ToastOverlay.insert(_overlayEntry!);

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
  final String msg;
  final int position;
  final IconData icon;
  final Color iconColor;
  final ValueChanged<AnimationController> onAnimationController;
  final ValueChanged<VoidCallback> onDismiss;

  const _ToastWidget({
    required this.msg,
    required this.position,
    required this.icon,
    required this.iconColor,
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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                // Game-style card: cream surface, ink stroke, hard shadow.
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.border, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.border.withValues(alpha: 0.35),
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 18.w, color: widget.iconColor),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      widget.msg,
                      style: textStyleBold(fontSize: 13.sp, color: AppColors.textPrimary)
                          .copyWith(decoration: TextDecoration.none),
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  ),
                ],
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
