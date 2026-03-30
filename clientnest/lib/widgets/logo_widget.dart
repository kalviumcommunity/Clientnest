import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final Color? color;

  const LogoWidget({
    super.key,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logo.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        color ?? Theme.of(context).colorScheme.primary,
        BlendMode.srcIn,
      ),
    );
  }
}

class LogoWithText extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final bool isDark;

  const LogoWithText({
    super.key,
    this.iconSize = 32,
    this.fontSize = 24,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = isDark ? Colors.white : colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LogoWidget(size: iconSize),
        const SizedBox(width: 12),
        Text(
          'ClientNest',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
