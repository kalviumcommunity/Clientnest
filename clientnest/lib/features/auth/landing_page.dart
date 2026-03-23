import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../shared/widgets/logo_widget.dart';
import '../../services/auth_service.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signInWithGoogle();
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Gradient Background
          _AnimatedGradientBackground(),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  const LogoWidget(size: 70)
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(delay: 200.ms),
                  const SizedBox(height: 40),
                  Text(
                    'Organize. Track.\nGet Paid.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2,
                          color: colorScheme.onSurface,
                          height: 1.1,
                        ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
                  const SizedBox(height: 20),
                  Text(
                    'The high-end workspace built specifically for the modern freelancer.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          height: 1.5,
                        ),
                  ).animate().fadeIn(delay: 600.ms),
                  const Spacer(),
                  _buildActionButtons(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _handleGoogleSignIn,
          icon: SvgPicture.network(
            'https://www.vectorlogo.zone/logos/google/google-icon.svg', 
            height: 20, 
            placeholderBuilder: (BuildContext context) => const Icon(Icons.g_mobiledata),
          ),
          label: const Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            minimumSize: const Size(double.infinity, 60),
            side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
          ),
        ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.5),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => context.push('/login'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            minimumSize: const Size(double.infinity, 60),
          ),
          child: const Text('Sign In with Email', style: TextStyle(fontWeight: FontWeight.bold)),
        ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.5),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => context.push('/signup'),
          child: Text(
            'Create a new account',
            style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
          ),
        ).animate().fadeIn(delay: 1200.ms),
      ],
    );
  }
}


class _AnimatedGradientBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.08),
            colorScheme.surface,
            colorScheme.secondary.withValues(alpha: 0.08),
            colorScheme.surface,
          ],
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .shimmer(duration: 5.seconds, color: colorScheme.primary.withValues(alpha: 0.05));
  }
}
