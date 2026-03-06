import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatelessStatefulDemoScreen extends StatelessWidget {
  const StatelessStatefulDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: Text(
          'Stateless vs Stateful Demo',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const HeaderWidget(title: "Interactive Demo App"),
            const SizedBox(height: 32),
            Text(
              "Stateless Widget",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            const StaticInfoCard(),
            const SizedBox(height: 32),
            Text(
              "Stateful Widget",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            const InteractiveColorToggleWidget(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATELESS WIDGET EXAMPLES
// ─────────────────────────────────────────────────────────────────────────────

class HeaderWidget extends StatelessWidget {
  final String title;

  const HeaderWidget({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: cs.onPrimaryContainer,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class StaticInfoCard extends StatelessWidget {
  const StaticInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.info_outline_rounded, color: cs.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'I am a StatelessWidget',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'My UI is static and cannot change unless my parent rebuilds me with new data.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: cs.onSurface.withValues(alpha: 0.6),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATEFUL WIDGET EXAMPLE
// ─────────────────────────────────────────────────────────────────────────────

class InteractiveColorToggleWidget extends StatefulWidget {
  const InteractiveColorToggleWidget({super.key});

  @override
  State<InteractiveColorToggleWidget> createState() =>
      _InteractiveColorToggleWidgetState();
}

class _InteractiveColorToggleWidgetState
    extends State<InteractiveColorToggleWidget> {
  // --- STATE VARIABLES ---
  bool _isActive = false;

  void _toggleState() {
    // Calling setState() tells Flutter to rebuild this widget
    setState(() {
      _isActive = !_isActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final activeColor = cs.primary.withValues(alpha: 0.15);

    return Card(
      color: _isActive ? activeColor : defaultColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: _isActive ? cs.primary.withValues(alpha: 0.5) : Colors.transparent,
          width: 2,
        ),
      ),
      elevation: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              _isActive ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded,
              size: 48,
              color: _isActive ? cs.primary : cs.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'I am a StatefulWidget',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'State: ${_isActive ? "Active (On)" : "Inactive (Off)"}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _isActive ? cs.primary : cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _toggleState,
              icon: Icon(_isActive ? Icons.power_settings_new : Icons.power_settings_new),
              label: Text(_isActive ? "Turn Off" : "Turn On"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isActive ? cs.primary : cs.surfaceContainerHighest,
                foregroundColor: _isActive ? cs.onPrimary : cs.onSurface,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
