import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Simple animated logo with shine effect
class AnimatedLogo extends StatelessWidget {
  final double height;
  final String assetPath;
  final Animation<double> shineAnimation;

  const AnimatedLogo({
    super.key,
    required this.height,
    required this.assetPath,
    required this.shineAnimation,
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
      child: SvgPicture.asset(
        assetPath,
        height: height,
        semanticsLabel: 'Inner Circle Logo',
      ),
    );
  }
}
