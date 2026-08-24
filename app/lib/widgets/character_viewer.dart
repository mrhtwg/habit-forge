import 'package:flutter/material.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:lottie/lottie.dart';

class CharacterViewer extends StatefulWidget {
  final String? lottiePath;
  final String animation;
  final VoidCallback? onDoubleTap;

  const CharacterViewer({
    super.key,
    this.lottiePath,
    this.animation = 'idle',
    this.onDoubleTap,
  });

  @override
  State<CharacterViewer> createState() => _CharacterViewerState();
}

class _CharacterViewerState extends State<CharacterViewer> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: widget.onDoubleTap,
      child: widget.lottiePath != null
          ? Lottie.asset(
              widget.lottiePath!,
              fit: BoxFit.contain,
              repeat: widget.animation == 'idle',
            )
          : Center(
              child: Icon(Icons.person, size: 80, color: AppColors.textMuted),
            ),
    );
  }
}
