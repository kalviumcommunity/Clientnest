import 'package:flutter/material.dart';
import 'main_screen_wrapper.dart';

class AnimationDemoScreen extends StatefulWidget {
  const AnimationDemoScreen({super.key});

  @override
  State<AnimationDemoScreen> createState() => _AnimationDemoScreenState();
}

class _AnimationDemoScreenState extends State<AnimationDemoScreen>
    with SingleTickerProviderStateMixin {
  // --- Implicit Animation States ---
  bool _isExpanded = false;
  bool _isVisible = true;

  // --- Explicit Animation Controller ---
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _toggleRotation() {
    if (_rotationController.isAnimating) {
      _rotationController.stop();
    } else {
      _rotationController.repeat(reverse: true);
    }
    setState(() {}); // Update button icon/text
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ClientNest Animations',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- 1. Implicit Animation: AnimatedContainer ---
            _buildSectionHeader('Interactive Dashboard Card'),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                height: _isExpanded ? 200 : 120,
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _isExpanded
                      ? colorScheme.secondaryContainer
                      : colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_alt_rounded,
                      size: _isExpanded ? 50 : 36,
                      color: _isExpanded
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Total Clients',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _isExpanded
                            ? colorScheme.onSecondaryContainer
                            : colorScheme.onPrimaryContainer,
                      ),
                    ),
                    if (_isExpanded) ...[
                      const SizedBox(height: 16),
                      Text(
                        '124',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // --- 2. Implicit Animation: AnimatedOpacity ---
            _buildSectionHeader('Branding Fade Effect'),
            const SizedBox(height: 16),
            Column(
              children: [
                AnimatedOpacity(
                  opacity: _isVisible ? 1.0 : 0.3,
                  duration: const Duration(milliseconds: 600),
                  child: Image.asset(
                    'assets/images/clientnest_logo.png',
                    width: 140,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.business_center_rounded, size: 80, color: colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => setState(() => _isVisible = !_isVisible),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_isVisible ? 'Dim Logo' : 'Focus Logo'),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // --- 3. Explicit Animation: Rotating Widget ---
            _buildSectionHeader('System Status Rotation'),
            const SizedBox(height: 16),
            Column(
              children: [
                RotationTransition(
                  turns: _rotationController,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.settings_rounded,
                      size: 60,
                      color: colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _toggleRotation,
                  icon: Icon(_rotationController.isAnimating ? Icons.stop_rounded : Icons.play_arrow_rounded),
                  label: Text(_rotationController.isAnimating ? 'Stop Animation' : 'Start Animation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.tertiary,
                    foregroundColor: colorScheme.onTertiary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),

            // --- 4. Custom Page Transition ---
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(_createSlideRoute());
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Back to Home (Slide Transition)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                backgroundColor: colorScheme.surfaceVariant,
                foregroundColor: colorScheme.onSurfaceVariant,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  // --- PageRouteBuilder for Slide Transition ---
  Route _createSlideRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const MainScreenWrapper(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
    );
  }
}
