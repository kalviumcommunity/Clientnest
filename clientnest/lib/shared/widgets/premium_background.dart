import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PremiumBackground extends StatelessWidget {
  final Widget child;
  const PremiumBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        // Subtle Mesh Gradient circles
        Positioned(
          top: -150,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary.withValues(alpha: 0.035),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(duration: 8.seconds, begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
        ),
        Positioned(
          top: 200,
          right: -150,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.secondary.withValues(alpha: 0.035),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(duration: 10.seconds, begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
        ),
        Positioned(
          bottom: -100,
          left: 50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.tertiary.withValues(alpha: 0.025),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(duration: 12.seconds, begin: const Offset(1, 1), end: const Offset(1.15, 1.15)),
        ),
        
        // The main content
        child,
      ],
    );
  }
}
