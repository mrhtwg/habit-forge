import 'package:flutter/material.dart';

/// Plays PNG sequence-frame animations (replaces SVGA character animations).
/// Usage: pass a list of frame asset paths; plays in a loop or once at the given fps.
class FrameSequencePlayer extends StatefulWidget {
  /// Knight idle sequence frames (62 frames, 362×644, transparent PNG)
  static const int knightIdleCount = 62;

  static const String _knightIdleDir = 'assets/animations/knight_idle';

  /// Mage idle sequence frames (62 frames, 360×662, transparent PNG)
  static const int mageIdleCount = 62;

  static const String _mageIdleDir = 'assets/animations/mage_idle';

  /// Ranger idle sequence frames (72 frames, 720×960, transparent PNG)
  static const int rangerIdleCount = 72;

  static const String _rangerIdleDir = 'assets/animations/ranger_idle';

  /// Frame asset path list (ordered)
  final List<String> frames;

  /// Playback frame rate (fps), defaults to 24
  final double fps;

  /// Whether to loop playback, defaults to true
  final bool autoRepeat;

  /// Playback completion callback (fired once when not looping)
  final VoidCallback? callback;

  /// Specified display size (auto-fits when null)
  final Size? preferredSize;

  final BoxFit fit;
  const FrameSequencePlayer({
    super.key,
    required this.frames,
    this.fps = 24,
    this.autoRepeat = true,
    this.callback,
    this.preferredSize,
    this.fit = BoxFit.contain,
  });

  @override
  State<FrameSequencePlayer> createState() => _FrameSequencePlayerState();

  static List<String> knightIdleFrames() => List.generate(
        knightIdleCount,
        (i) => '$_knightIdleDir/knight_idle_${i.toString().padLeft(2, '0')}.png',
      );
  static List<String> mageIdleFrames() => List.generate(
        mageIdleCount,
        (i) => '$_mageIdleDir/mage_idle_${i.toString().padLeft(2, '0')}.png',
      );

  static List<String> rangerIdleFrames() => List.generate(
        rangerIdleCount,
        (i) => '$_rangerIdleDir/ranger_idle_${i.toString().padLeft(2, '0')}.png',
      );
}

class _FrameSequencePlayerState extends State<FrameSequencePlayer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  Widget build(BuildContext context) {
    if (widget.frames.isEmpty) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final index =
            (_controller.value * (widget.frames.length - 1)).round().clamp(0, widget.frames.length - 1).toInt();
        return SizedBox(
          width: widget.preferredSize?.width,
          height: widget.preferredSize?.height,
          child: Image.asset(
            widget.frames[index],
            fit: widget.fit,
            gaplessPlayback: true,
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant FrameSequencePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.frames.length != widget.frames.length || oldWidget.fps != widget.fps) {
      _controller.duration = Duration(milliseconds: (widget.frames.length / widget.fps * 1000).round());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (widget.frames.length / widget.fps * 1000).round()),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.callback?.call();
        if (widget.autoRepeat && mounted) _controller.repeat();
      }
    });
    if (widget.frames.isNotEmpty) _controller.repeat();
  }
}
