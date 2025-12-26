import 'package:flutter/material.dart';

/// Animated text with shine effect
class AnimatedShineText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Animation<double> shineAnimation;

  const AnimatedShineText({
    super.key,
    required this.text,
    required this.shineAnimation,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shineAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                (shineAnimation.value - 0.3).clamp(0.0, 1.0),
                shineAnimation.value.clamp(0.0, 1.0),
                (shineAnimation.value + 0.3).clamp(0.0, 1.0),
              ],
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.7),
                Colors.transparent,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }
}
