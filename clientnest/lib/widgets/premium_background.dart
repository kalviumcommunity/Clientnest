import 'package:flutter/material.dart';

class PremiumBackground extends StatelessWidget {
  final Widget child;
  const PremiumBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // The luxury fintech design abandons heavy shapes and blobs.
    // We simply rely on the solid scaffold background colour from the theme.
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }
}
