import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Paints its [text] with the brand primary->secondary gradient.
class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    required this.style,
    this.colors = AppColors.brandGradient,
    this.textAlign,
  });

  final String text;
  final TextStyle style;
  final List<Color> colors;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        textAlign: textAlign,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}
