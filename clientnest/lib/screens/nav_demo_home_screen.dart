import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// NavDemoHomeScreen
///
/// Demonstrates Flutter's Navigator API alongside GoRouter named routes:
///   • Navigator.push()       — imperative push onto the stack
///   • Navigator.pushNamed()  — named-route push (registered in GoRouter)
///   • Navigator.pop()        — pops back from details
///
/// GoRouter exposes a Navigator under the hood, so both approaches work together.
class NavDemoHomeScreen extends StatefulWidget {
  const NavDemoHomeScreen({super.key});

  @override
  State<NavDemoHomeScreen> createState() => _NavDemoHomeScreenState();
}

class _NavDemoHomeScreenState extends State<NavDemoHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    debugPrint('NavDemoHomeScreen: initState() — screen mounted on Navigator stack');

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideIn = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ─── Navigator.push() ────────────────────────────────────────────────────────
  void _navigatePush(BuildContext context) {
    debugPrint('NavDemoHomeScreen: Navigator.push() called');
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const DetailsScreen(
          message: 'Navigated via Navigator.push() 🚀',
          method: 'Navigator.push',
        ),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  // ─── Navigator.pushNamed() via GoRouter ──────────────────────────────────────
  void _navigatePushNamed(BuildContext context) {
    debugPrint('NavDemoHomeScreen: Navigator.pushNamed() — context.push(\'/details\')');
    context.push('/details', extra: {
      'message': 'Navigated via Navigator.pushNamed() 📌',
      'method': 'Navigator.pushNamed',
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
          tooltip: 'Back to Dashboard',
        ),
        title: const Text(
          'Navigation Demo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.route_rounded, size: 16, color: colorScheme.onPrimaryContainer),
                const SizedBox(width: 6),
                Text(
                  'Navigator API',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: SlideTransition(
          position: _slideIn,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero Banner ─────────────────────────────────────────────
                _HeroBanner(colorScheme: colorScheme),
                const SizedBox(height: 32),

                // ── Section label ────────────────────────────────────────────
                Text(
                  'Choose a Navigation Method',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Navigator.push() card ────────────────────────────────────
                _NavMethodCard(
                  icon: Icons.arrow_circle_right_rounded,
                  color: const Color(0xFF6366F1),
                  title: 'Navigator.push()',
                  subtitle: 'Imperatively push a new route onto the stack with a custom slide transition.',
                  codeSnippet:
                      'Navigator.push(\n  context,\n  MaterialPageRoute(\n    builder: (_) => DetailsScreen(),\n  ),\n);',
                  onTap: () => _navigatePush(context),
                ),
                const SizedBox(height: 16),

                // ── Navigator.pushNamed() card ───────────────────────────────
                _NavMethodCard(
                  icon: Icons.label_important_rounded,
                  color: const Color(0xFF8B5CF6),
                  title: 'Navigator.pushNamed()',
                  subtitle: 'Push a route by name — as registered in GoRouter — and pass arguments.',
                  codeSnippet:
                      'Navigator.pushNamed(\n  context,\n  \'/details\',\n  arguments: \'Hello from Home!\',\n);',
                  onTap: () => _navigatePushNamed(context),
                ),
                const SizedBox(height: 32),

                // ── Stack Diagram ────────────────────────────────────────────
                _StackDiagram(colorScheme: colorScheme),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ────────────────────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final ColorScheme colorScheme;
  const _HeroBanner({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withValues(alpha: 0.85),
            const Color(0xFF8B5CF6).withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.layers_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 20),
          const Text(
            'Flutter Navigator API',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Navigate between screens using a stack-based model. '
            'Push routes onto the stack and pop them to go back.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavMethodCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String codeSnippet;
  final VoidCallback onTap;

  const _NavMethodCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.codeSnippet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(alpha: 0.55),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: colorScheme.onSurface.withValues(alpha: 0.3)),
                  ],
                ),
                const SizedBox(height: 16),
                // Code snippet
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    codeSnippet,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11.5,
                      color: color,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // CTA button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: Text('Navigate → $title'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StackDiagram extends StatelessWidget {
  final ColorScheme colorScheme;
  const _StackDiagram({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stacked_bar_chart_rounded, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Navigator Stack Model',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _StackItem(
            icon: Icons.layers_rounded,
            label: 'DetailsScreen',
            tag: 'push()',
            color: const Color(0xFF6366F1),
            isTop: true,
          ),
          _StackConnector(),
          _StackItem(
            icon: Icons.home_rounded,
            label: 'NavDemoHomeScreen',
            tag: 'current',
            color: const Color(0xFF8B5CF6),
          ),
          _StackConnector(),
          _StackItem(
            icon: Icons.dashboard_rounded,
            label: 'MainScreenWrapper',
            tag: 'root',
            color: colorScheme.secondary,
          ),
          const SizedBox(height: 12),
          Text(
            'pop() removes the top-most route, returning to the previous screen.',
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StackItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tag;
  final Color color;
  final bool isTop;

  const _StackItem({
    required this.icon,
    required this.label,
    required this.tag,
    required this.color,
    this.isTop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isTop ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: isTop ? 0.4 : 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tag,
              style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _StackConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      child: Icon(
        Icons.arrow_downward_rounded,
        size: 16,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// DetailsScreen
// ════════════════════════════════════════════════════════════════════════════

/// DetailsScreen
///
/// Receives data from the previous screen and demonstrates Navigator.pop().
/// Can be reached via:
///   1. Navigator.push()       → receives `message` & `method` as constructor args
///   2. Navigator.pushNamed()  → receives data via ModalRoute.settings.arguments
///      OR GoRouter's extra map.
class DetailsScreen extends StatefulWidget {
  final String? message;
  final String? method;

  const DetailsScreen({super.key, this.message, this.method});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    debugPrint('DetailsScreen: initState() — pushed onto Navigator stack');

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideIn = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Resolve data from either direct constructor args or GoRouter/ModalRoute args
  Map<String, String> _resolveArgs(BuildContext context) {
    // GoRouter extra (pushNamed path)
    final goExtra = GoRouterState.of(context).extra;
    if (goExtra is Map<String, dynamic>) {
      return {
        'message': goExtra['message'] as String? ?? 'No message',
        'method': goExtra['method'] as String? ?? 'Unknown',
      };
    }
    // ModalRoute arguments (legacy pushNamed)
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is String) {
      return {'message': routeArgs, 'method': 'Navigator.pushNamed'};
    }
    // Direct constructor args
    return {
      'message': widget.message ?? 'No message received.',
      'method': widget.method ?? 'Direct',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final args = _resolveArgs(context);
    final message = args['message']!;
    final method = args['method']!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: 'Navigator.pop()',
          onPressed: () {
            debugPrint('DetailsScreen: Navigator.pop() called — removing from stack');
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Details Screen',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: SlideTransition(
          position: _slideIn,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Data received badge ──────────────────────────────────────
                _DataReceivedBanner(
                  message: message,
                  method: method,
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 28),

                // ── Section label ────────────────────────────────────────────
                Text(
                  'Navigation Concepts',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Info cards ───────────────────────────────────────────────
                _InfoCard(
                  icon: Icons.layers_rounded,
                  color: const Color(0xFF6366F1),
                  title: 'Stack-Based Navigation',
                  body:
                      'Flutter uses a stack to manage routes. push() adds a route to '
                      'the top; pop() removes it. The screen below this one is still '
                      'alive in memory — preserved in the widget tree.',
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.label_rounded,
                  color: const Color(0xFF8B5CF6),
                  title: 'Named Routes',
                  body:
                      'Named routes (like \'/details\') let you navigate without importing '
                      'screen files directly. In larger apps this decouples navigation '
                      'from the widget hierarchy.',
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.send_rounded,
                  color: const Color(0xFF06B6D4),
                  title: 'Passing Arguments',
                  body:
                      'Data can be passed during push via constructor args, '
                      'ModalRoute.of(context)!.settings.arguments, or GoRouter\'s extra '
                      'parameter — all demonstrated in this flow.',
                ),
                const SizedBox(height: 32),

                // ── Back button CTA ──────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      debugPrint('DetailsScreen: Navigator.pop() — back to NavDemoHomeScreen');
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Navigator.pop()  →  Back to Home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DataReceivedBanner extends StatelessWidget {
  final String message;
  final String method;
  final ColorScheme colorScheme;

  const _DataReceivedBanner({
    required this.message,
    required this.method,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withValues(alpha: 0.9),
            const Color(0xFF06B6D4).withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Data Received!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Message chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.message_rounded, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Method chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.route_rounded, color: Colors.white60, size: 14),
                const SizedBox(width: 6),
                Text(
                  'via  $method',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  const _InfoCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
