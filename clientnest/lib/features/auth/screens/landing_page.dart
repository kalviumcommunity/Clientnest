import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../services/auth_service.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      body: Stack(
        children: [
          // Background Animated Gradient
          const _AnimatedBackground(),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Hero(
                            tag: 'app_logo',
                            child: Icon(
                              Icons.nest_cam_wired_stand_rounded,
                              color: theme.primaryColor,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ClientNest',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          themeProvider.toggleTheme(!themeProvider.isDarkMode);
                        },
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            key: ValueKey(themeProvider.isDarkMode),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0),
                  
                  const Spacer(),
                  
                  // Main Content
                  const _TypewriterText(
                    texts: [
                      "Manage Clients. Track Work. Get Paid.",
                      "Your Freelance Command Center.",
                      "Workflow Simplified.",
                    ],
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Illustration / Abstract
                  Center(
                    child: Container(
                      height: 280,
                      width: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            theme.primaryColor.withOpacity(0.2),
                            theme.primaryColor.withOpacity(0.0),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.dashboard_customize_rounded,
                          size: 150,
                          color: theme.primaryColor.withOpacity(0.8),
                        ),
                      ),
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .moveY(begin: -10, end: 10, duration: 2.seconds, curve: Curves.easeInOut)
                      .fadeIn(duration: 1.seconds),
                  ),
                  
                  const Spacer(),
                  
                  // Buttons
                  Column(
                    children: [
                      SocialButton(
                        text: 'Continue with Google',
                        iconPath: '', // Handled in widget
                        onPressed: _isSigningIn ? () {} : () async {
                          setState(() => _isSigningIn = true);
                          try {
                            final user = await authService.signInWithGoogle();
                            if (user != null && mounted) {
                              context.go('/home');
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isSigningIn = false);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Login',
                        isOutline: true,
                        onPressed: () => context.push('/login'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => context.push('/signup'),
                        child: Text(
                          "Don't have an account? Sign Up",
                          style: TextStyle(
                            color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 800.ms, delay: 400.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypewriterText extends StatefulWidget {
  final List<String> texts;
  const _TypewriterText({required this.texts});

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 4));
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.texts.length;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.5),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            widget.texts[_currentIndex],
            key: ValueKey(_currentIndex),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedBackground extends StatelessWidget {
  const _AnimatedBackground();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: theme.scaffoldBackgroundColor,
          ),
        ),
        // Randomly placed glow circles for particle effect
        ...List.generate(6, (index) {
          final size = 100.0 + (index * 50);
          return Positioned(
            top: (index * 150.0) % MediaQuery.of(context).size.height,
            left: (index * 100.0) % MediaQuery.of(context).size.width,
            child: _GlowCircle(
              color: theme.primaryColor.withOpacity(isDark ? 0.05 : 0.03),
              size: size,
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
              .move(
                begin: Offset.zero,
                end: Offset(
                  index.isEven ? 30 : -30,
                  index.isOdd ? 30 : -30,
                ),
                duration: (3 + index).seconds,
                curve: Curves.easeInOut,
              ),
          );
        }),
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0),
          ],
        ),
      ),
    );
  }
}
