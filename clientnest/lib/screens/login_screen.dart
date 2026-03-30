import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'package:clientnest/widgets/custom_buttons.dart';
import 'package:clientnest/widgets/custom_text_field.dart';
import 'auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (mounted) context.go('/home');
      } catch (e) {
        if (mounted) {
          setState(() => _errorMessage = e.toString());
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Enter your email above to reset password.');
      return;
    }
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset email sent to $email'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() { _isGoogleLoading = true; _errorMessage = null; });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.signInWithGoogle();
      if (user != null && mounted) context.go('/home');
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Premium mesh background
          const AuthBackground(),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Back button
                    AuthBackButton(onPressed: () => context.pop())
                        .animate()
                        .fadeIn(duration: 400.ms),

                    const SizedBox(height: 40),

                    // Header badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_open_rounded, size: 13, color: colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            'SIGN IN',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: colorScheme.primary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),

                    const SizedBox(height: 16),

                    Text(
                      'Welcome\nBack!',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                        height: 1.05,
                        color: colorScheme.onSurface,
                      ),
                    ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.1),

                    const SizedBox(height: 10),

                    Text(
                      'Your workspace is waiting. Log in to continue.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        height: 1.5,
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 44),

                    // Error banner
                    if (_errorMessage != null) ...[
                      AuthErrorBanner(message: _errorMessage!)
                          .animate()
                          .fadeIn()
                          .shake(hz: 2, offset: const Offset(4, 0)),
                      const SizedBox(height: 20),
                    ],

                    // Email field
                    CustomTextField(
                      label: 'Email Address',
                      hint: 'you@example.com',
                      icon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Email is required';
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
                        return null;
                      },
                    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.08),

                    const SizedBox(height: 16),

                    // Password field
                    CustomTextField(
                      label: 'Password',
                      hint: 'Min. 6 characters',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Password is required';
                        if (value.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.08),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading ? null : _handleForgotPassword,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 350.ms),

                    const SizedBox(height: 8),

                    // Login button
                    CustomButton(
                      text: 'Sign In',
                      isLoading: _isLoading,
                      onPressed: _isLoading || _isGoogleLoading ? null : _handleLogin,
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05),

                    const SizedBox(height: 32),

                    // OR divider
                    const OrDivider().animate().fadeIn(delay: 450.ms),

                    const SizedBox(height: 32),

                    // Google button
                    GoogleAuthButton(
                      label: 'Continue with Google',
                      isLoading: _isGoogleLoading,
                      onPressed: _isLoading || _isGoogleLoading ? null : _handleGoogleSignIn,
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.05),

                    const SizedBox(height: 36),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : () => context.push('/signup'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 550.ms),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

