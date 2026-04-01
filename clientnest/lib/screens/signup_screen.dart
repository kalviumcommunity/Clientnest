import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'package:clientnest/widgets/custom_buttons.dart';
import 'package:clientnest/widgets/custom_text_field.dart';
import '../widgets/auth_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _acceptedTerms = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);

    if (!_acceptedTerms) {
      setState(() => _errorMessage = 'Please accept the Terms & Privacy Policy to continue.');
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.signUpWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
        );
        if (mounted) context.go('/home');
      } catch (e) {
        if (mounted) setState(() => _errorMessage = e.toString());
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
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

                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.secondary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 13, color: colorScheme.secondary),
                          const SizedBox(width: 6),
                          Text(
                            'CREATE ACCOUNT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: colorScheme.secondary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),

                    const SizedBox(height: 16),

                    Text(
                      'Join\nClientNest',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                        height: 1.05,
                        color: colorScheme.onSurface,
                      ),
                    ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.1),

                    const SizedBox(height: 10),

                    Text(
                      'Set up your account and own your workflow.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        height: 1.5,
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 40),

                    // Error banner
                    if (_errorMessage != null) ...[
                      AuthErrorBanner(message: _errorMessage!)
                          .animate()
                          .fadeIn()
                          .shake(hz: 2, offset: const Offset(4, 0)),
                      const SizedBox(height: 20),
                    ],

                    // Name field
                    CustomTextField(
                      label: 'Full Name',
                      hint: 'Your display name',
                      icon: Icons.person_outline_rounded,
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Name is required';
                        if (value.trim().length < 2) return 'Name is too short';
                        return null;
                      },
                    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.08),

                    const SizedBox(height: 14),

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
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.08),

                    const SizedBox(height: 14),

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
                    ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.08),

                    const SizedBox(height: 14),

                    // Confirm password
                    CustomTextField(
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      controller: _confirmPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please confirm your password';
                        if (value != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.08),

                    const SizedBox(height: 20),

                    // Terms checkbox
                    GestureDetector(
                      onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: _acceptedTerms
                                  ? colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _acceptedTerms
                                    ? colorScheme.primary
                                    : colorScheme.outline.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            child: _acceptedTerms
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  height: 1.5,
                                ),
                                children: [
                                  const TextSpan(text: 'I agree to the '),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 450.ms),

                    const SizedBox(height: 28),

                    // Sign up button
                    CustomButton(
                      text: 'Create Account',
                      isLoading: _isLoading,
                      onPressed: _isLoading || _isGoogleLoading ? null : _handleSignup,
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.05),

                    const SizedBox(height: 28),

                    // OR divider
                    OrDivider().animate().fadeIn(delay: 550.ms),

                    const SizedBox(height: 28),

                    // Google button
                    GoogleAuthButton(
                      label: 'Continue with Google',
                      isLoading: _isGoogleLoading,
                      onPressed: _isLoading || _isGoogleLoading ? null : _handleGoogleSignIn,
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.05),

                    const SizedBox(height: 32),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : () => context.pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 650.ms),

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
