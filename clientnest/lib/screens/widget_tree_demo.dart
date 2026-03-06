import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ──────────────────────────────────────────────────────────────────────────────
// WidgetTreeDemoScreen
//
// Purpose:
//   1. Visualise Flutter's widget tree hierarchy with an interactive ASCII-tree
//      card inside a real, nested widget tree (Scaffold > Column > Card …).
//   2. Demonstrate Flutter's reactive model:
//      - A counter that rebuilds the UI on every increment / decrement
//        via setState().
//      - A profile-card toggle (show / hide details) via setState().
//      - A live theme-colour switcher via setState().
//
// Nothing in this file touches Firebase, routing, or authentication.
// ──────────────────────────────────────────────────────────────────────────────

class WidgetTreeDemoScreen extends StatefulWidget {
  const WidgetTreeDemoScreen({super.key});

  @override
  State<WidgetTreeDemoScreen> createState() => _WidgetTreeDemoScreenState();
}

class _WidgetTreeDemoScreenState extends State<WidgetTreeDemoScreen>
    with SingleTickerProviderStateMixin {
  // ── Reactive State ──────────────────────────────────────────────────────────

  /// Counter demo state.
  int _counter = 0;

  /// Profile-card toggle state.
  bool _showDetails = false;

  /// Accent colour switcher state.
  int _accentIndex = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const List<Color> _accents = [
    Color(0xFF6366F1), // Indigo (app default)
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Rose
  ];

  static const List<String> _accentLabels = [
    'Indigo',
    'Emerald',
    'Amber',
    'Rose',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Color get _accent => _accents[_accentIndex];

  void _increment() {
    setState(() => _counter++);
    _pulseController.forward(from: 0);
  }

  void _decrement() {
    if (_counter > 0) {
      setState(() => _counter--);
      _pulseController.forward(from: 0);
    }
  }

  void _reset() => setState(() => _counter = 0);

  void _toggleDetails() => setState(() => _showDetails = !_showDetails);

  void _nextAccent() =>
      setState(() => _accentIndex = (_accentIndex + 1) % _accents.length);

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Widget Tree:
    //
    // MaterialApp (via main.dart)
    // └── Scaffold
    //     ├── AppBar
    //     └── body → CustomScrollView
    //         └── SliverList → Column of demo cards:
    //             ├── _WidgetTreeCard       (static: shows tree visualisation)
    //             ├── _CounterCard          (reactive: setState counter)
    //             ├── _ProfileCard          (reactive: setState show/hide)
    //             └── _ThemeSwitcherCard    (reactive: setState accent colour)

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: Text(
          'Widget Tree & Reactive UI',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _AccentDot(color: _accent),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SectionLabel('Flutter Widget Tree'),
                _WidgetTreeCard(accent: _accent),
                const SizedBox(height: 20),

                _SectionLabel('Reactive UI — Counter  (setState)'),
                _CounterCard(
                  accent: _accent,
                  counter: _counter,
                  pulseAnimation: _pulseAnimation,
                  onIncrement: _increment,
                  onDecrement: _decrement,
                  onReset: _reset,
                ),
                const SizedBox(height: 20),

                _SectionLabel('Reactive UI — Profile Card  (setState)'),
                _ProfileCard(
                  accent: _accent,
                  showDetails: _showDetails,
                  onToggle: _toggleDetails,
                ),
                const SizedBox(height: 20),

                _SectionLabel('Reactive UI — Colour Switcher  (setState)'),
                _ThemeSwitcherCard(
                  accent: _accent,
                  accentLabel: _accentLabels[_accentIndex],
                  onSwitch: _nextAccent,
                ),
                const SizedBox(height: 8),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared section label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Accent dot indicator shown in AppBar
// ─────────────────────────────────────────────────────────────────────────────

class _AccentDot extends StatelessWidget {
  final Color color;
  const _AccentDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 14,
      height: 14,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Widget Tree Visualisation Card  (static — no state)
// ─────────────────────────────────────────────────────────────────────────────
//
// Demonstrates the VISUAL tree without any reactive state so students can see
// the hierarchy clearly.

class _WidgetTreeCard extends StatelessWidget {
  final Color accent;
  const _WidgetTreeCard({required this.accent});

  // The actual Flutter widget tree of THIS card is:
  //   Card
  //   └── Padding
  //       └── Column
  //           ├── Row  (header)
  //           │   ├── Icon
  //           │   └── Text
  //           ├── Divider
  //           └── _TreeNode (recursive)
  //               └── … nested _TreeNodes

  static const _treeData = [
    _TreeItem('MaterialApp', 0),
    _TreeItem('└── Scaffold', 1),
    _TreeItem('    ├── AppBar', 2),
    _TreeItem('    └── body', 2),
    _TreeItem('        └── CustomScrollView', 3),
    _TreeItem('            └── SliverList', 4),
    _TreeItem('                └── Column', 5),
    _TreeItem('                    ├── _WidgetTreeCard', 6),
    _TreeItem('                    ├── _CounterCard', 6),
    _TreeItem('                    ├── _ProfileCard', 6),
    _TreeItem('                    └── _ThemeSwitcherCard', 6),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.account_tree_outlined, color: accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Widget Hierarchy',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        'This screen\'s actual widget tree',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: cs.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: cs.outlineVariant.withOpacity(0.4)),
            const SizedBox(height: 12),
            // Tree nodes
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF111111)
                    : const Color(0xFFF8F7FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: accent.withOpacity(0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _treeData.map((item) {
                  final isLeaf = item.depth == 6;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      item.label,
                      style: GoogleFonts.sourceCodePro(
                        fontSize: 12,
                        color: isLeaf
                            ? accent
                            : cs.onSurface.withOpacity(item.depth == 0 ? 1.0 : 0.75),
                        fontWeight: item.depth == 0
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            // Key insight chip
            _InfoChip(
              icon: Icons.lightbulb_outline,
              text: 'Every widget in the tree renders independently — '
                  'Flutter only repaints what changes.',
              accent: accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _TreeItem {
  final String label;
  final int depth;
  const _TreeItem(this.label, this.depth);
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Counter Card — demonstrates setState() incremental re-render
// ─────────────────────────────────────────────────────────────────────────────

class _CounterCard extends StatelessWidget {
  final Color accent;
  final int counter;
  final Animation<double> pulseAnimation;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onReset;

  const _CounterCard({
    required this.accent,
    required this.counter,
    required this.pulseAnimation,
    required this.onIncrement,
    required this.onDecrement,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.repeat_rounded, color: accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Counter Demo',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        'Tap +/– → setState() → UI rebuilds',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: cs.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                // Reset
                IconButton(
                  onPressed: onReset,
                  icon: Icon(Icons.refresh_rounded, color: cs.onSurface.withOpacity(0.4)),
                  tooltip: 'Reset counter',
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Counter display
            ScaleTransition(
              scale: pulseAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [accent.withOpacity(0.15), accent.withOpacity(0.03)],
                  ),
                  border: Border.all(color: accent.withOpacity(0.3), width: 2),
                ),
                alignment: Alignment.center,
                child: TweenAnimationBuilder<int>(
                  tween: IntTween(begin: counter, end: counter),
                  duration: const Duration(milliseconds: 150),
                  builder: (context, value, _) => Text(
                    '$counter',
                    style: GoogleFonts.inter(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CircleButton(
                  icon: Icons.remove,
                  onTap: onDecrement,
                  accent: accent,
                  enabled: counter > 0,
                ),
                const SizedBox(width: 24),
                _CircleButton(
                  icon: Icons.add,
                  onTap: onIncrement,
                  accent: accent,
                  enabled: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // State annotation
            _CodeAnnotation(
              lines: const [
                '// State variable:',
                'int _counter = ${'_counter'};',
                '',
                '// Button triggers:',
                'setState(() => _counter++);',
              ],
              accent: accent,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Profile Card — show / hide toggle via setState()
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final Color accent;
  final bool showDetails;
  final VoidCallback onToggle;

  const _ProfileCard({
    required this.accent,
    required this.showDetails,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.person_outline_rounded, color: accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Card Toggle',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        'Tap to show / hide details via setState()',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: cs.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: cs.outlineVariant.withOpacity(0.3)),
            const SizedBox(height: 16),
            // Avatar row
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: accent.withOpacity(0.15),
                  child: Text(
                    'CN',
                    style: GoogleFonts.inter(
                      color: accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alex Freelancer',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        'Full-Stack Developer',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: cs.onSurface.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                // Toggle button
                AnimatedRotation(
                  turns: showDetails ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: IconButton(
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: accent,
                    ),
                    onPressed: onToggle,
                    tooltip: showDetails ? 'Hide details' : 'Show details',
                  ),
                ),
              ],
            ),
            // Animated details panel
            AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              child: showDetails
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        children: [
                          Divider(color: cs.outlineVariant.withOpacity(0.3)),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: 'alex@clientnest.dev',
                            accent: accent,
                          ),
                          const SizedBox(height: 10),
                          _DetailRow(
                            icon: Icons.work_outline_rounded,
                            label: 'Projects',
                            value: '14 completed',
                            accent: accent,
                          ),
                          const SizedBox(height: 10),
                          _DetailRow(
                            icon: Icons.star_outline_rounded,
                            label: 'Rating',
                            value: '4.9 / 5.0',
                            accent: accent,
                          ),
                          const SizedBox(height: 14),
                          _CodeAnnotation(
                            lines: const [
                              'bool _showDetails = false;',
                              '',
                              '// Toggle button:',
                              'setState(() =>',
                              '  _showDetails = !_showDetails,',
                              ');',
                            ],
                            accent: accent,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: accent),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: cs.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Theme / Colour Switcher Card — dynamic colour via setState()
// ─────────────────────────────────────────────────────────────────────────────

class _ThemeSwitcherCard extends StatelessWidget {
  final Color accent;
  final String accentLabel;
  final VoidCallback onSwitch;

  const _ThemeSwitcherCard({
    required this.accent,
    required this.accentLabel,
    required this.onSwitch,
  });

  static const _accents = [
    Color(0xFF6366F1),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.palette_outlined, color: accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Colour Switcher',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        'setState() updates colour across all cards',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: cs.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Colour swatches
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _accents.map((c) {
                final isSelected = c == accent;
                return GestureDetector(
                  onTap: onSwitch,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: isSelected ? 44 : 36,
                    height: isSelected ? 44 : 36,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: cs.onSurface, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [BoxShadow(color: c.withOpacity(0.4), blurRadius: 12)]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Active colour label
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Container(
                  key: ValueKey(accentLabel),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: accent.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Active: $accentLabel',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Switch button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSwitch,
                icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                label: const Text('Next Colour'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _CodeAnnotation(
              lines: const [
                'int _accentIndex = 0;',
                '',
                '// Button triggers:',
                'setState(() =>',
                '  _accentIndex =',
                '    (_accentIndex + 1) % 4,',
                ');',
              ],
              accent: accent,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers shared across cards
// ─────────────────────────────────────────────────────────────────────────────

/// A monospace code annotation box — shows pseudo-code for setState() calls.
class _CodeAnnotation extends StatelessWidget {
  final List<String> lines;
  final Color accent;

  const _CodeAnnotation({required this.lines, required this.accent});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0E0E0E) : const Color(0xFFF4F3FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((line) {
          final isComment = line.startsWith('//');
          return Text(
            line,
            style: GoogleFonts.sourceCodePro(
              fontSize: 11.5,
              color: isComment
                  ? cs.onSurface.withOpacity(0.4)
                  : line.isEmpty
                      ? Colors.transparent
                      : cs.onSurface.withOpacity(0.8),
              fontStyle: isComment ? FontStyle.italic : FontStyle.normal,
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// An info chip with an icon — used at the bottom of the tree card.
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color accent;

  const _InfoChip({
    required this.icon,
    required this.text,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: cs.onSurface.withOpacity(0.65),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A circular icon button used in the counter card.
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color accent;
  final bool enabled;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.accent,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.3,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: accent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
