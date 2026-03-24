import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/logo_widget.dart';
import '../../shared/widgets/premium_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (mounted) context.go('/auth-wrapper');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: PremiumBackground(
        child: Stack(
          children: [
            // Center content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo with glow
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: const LogoWidget(size: 64)
                          .animate()
                          .scale(
                            duration: 700.ms,
                            curve: Curves.easeOutBack,
                            begin: const Offset(0.6, 0.6),
                          )
                          .fadeIn(duration: 600.ms)
                          .shimmer(delay: 900.ms, duration: 900.ms),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // App name
                  Text(
                    'ClientNest',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                      color: colorScheme.primary,
                    ),
                  )
                  .animate()
                  .slideY(begin: 0.3, end: 0, duration: 600.ms, delay: 350.ms)
                  .fadeIn(duration: 600.ms, delay: 350.ms),

                  const SizedBox(height: 6),

                  Text(
                    'Your freelance command center',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                      letterSpacing: 0.3,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 600.ms),

                  const SizedBox(height: 48),

                  // Loading pill
                  Container(
                    width: 56,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: colorScheme.primary.withValues(alpha: 0.08),
                    ),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      color: colorScheme.primary,
                      minHeight: 4,
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),

            // Version tag at bottom
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Text(
                'v1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                  letterSpacing: 1,
                ),
              ).animate().fadeIn(delay: 1200.ms),
            ),
          ],
        ),
      ),
    );
  }
}
