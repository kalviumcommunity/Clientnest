import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/logo_widget.dart';

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
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      context.go('/auth-wrapper');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LogoWidget(size: 100)
                .animate()
                .scale(duration: 800.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 600.ms)
                .shimmer(delay: 1.seconds, duration: 1200.ms),
            const SizedBox(height: 24),
            Text(
              'ClientNest',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    color: colorScheme.primary,
                  ),
            )
            .animate()
            .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 400.ms)
            .fadeIn(duration: 600.ms, delay: 400.ms),
            const SizedBox(height: 12),
            SizedBox(
              width: 40,
              child: LinearProgressIndicator(
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                color: colorScheme.primary,
                minHeight: 2,
              ),
            ).animate().fadeIn(delay: 1.seconds),
          ],
        ),
      ),
    );
  }
}
