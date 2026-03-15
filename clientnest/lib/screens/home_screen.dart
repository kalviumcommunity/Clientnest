// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/project_provider.dart';
import '../providers/invoice_provider.dart';
import '../services/auth_service.dart';
import '../shared/widgets/dashboard_widgets.dart';
import '../shared/widgets/time_tracker_widget.dart';
import '../models/project_model.dart';
import '../widgets/client_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('HomeScreen: build() called - Widget rebuild event');
    final user = Provider.of<AuthService>(context).currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120.0,
                floating: false,
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  expandedTitleScale: 1.2,
                  titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  title: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                        backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                        child: user?.photoURL == null 
                            ? Text(user?.displayName?[0].toUpperCase() ?? 'U', style: TextStyle(color: colorScheme.primary, fontSize: 14))
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hi, ${user?.displayName?.split(' ')[0] ?? 'Freelancer'}', 
                              style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Home Screen', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Next Deadline Countdown
                    Consumer<ProjectProvider>(
                      builder: (context, provider, child) {
                        final now = DateTime.now();
                        final upcoming = provider.projects
                            .where((p) => p.status != ProjectStatus.completed && p.deadline.isAfter(now))
                            .toList();
                        
                        if (upcoming.isEmpty) return const SizedBox.shrink();
                        
                        upcoming.sort((a, b) => a.deadline.compareTo(b.deadline));
                        final next = upcoming.first;
                        
                        return Column(
                          children: [
                            DeadlineCountdown(deadline: next.deadline, title: next.title),
                            const SizedBox(height: 24),
                          ],
                        );
                      }
                    ),

                    // Financial Snapshot
                    Consumer<InvoiceProvider>(
                      builder: (context, provider, child) {
                        double totalIncome = 0;
                        double totalPending = 0;
                        for (var inv in provider.invoices) {
                          if (inv.status == 'Paid') {
                            totalIncome += inv.amount;
                          } else {
                            totalPending += inv.amount;
                          }
                        }
                        return FinancialSnapshot(income: totalIncome, pending: totalPending);
                      }
                    ),
                    const SizedBox(height: 32),

                    // Quick Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _DashboardStatTile(
                            label: 'Active Projects',
                            value: Provider.of<ProjectProvider>(context).projects.where((p) => p.status == ProjectStatus.active).length.toString(),
                            icon: Icons.rocket_launch_outlined,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DashboardStatTile(
                            label: 'Leads',
                            value: Provider.of<ProjectProvider>(context).projects.where((p) => p.status == ProjectStatus.lead).length.toString(),
                            icon: Icons.flash_on_outlined,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const _HotReloadDemo(),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/details',
                            arguments: "Hello from Home Screen",
                          );
                        },
                        child: const Text('Go to Details'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // ── Navigator Demo entry card ─────────────────────────────
                    _NavigatorDemoCard(),
                    const SizedBox(height: 32),
                    
                    // --- Our Top Clients Section ---
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Top Clients',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const ClientCard(
                      clientName: 'Alex Johnson',
                      companyName: 'Tech Solutions',
                      status: 'Active',
                      icon: Icons.person_rounded,
                    ),
                    const ClientCard(
                      clientName: 'Maria Garcia',
                      companyName: 'Design Co',
                      status: 'Pending',
                      icon: Icons.person_add_rounded,
                    ),
                    const ClientCard(
                      clientName: 'Global Inc',
                      companyName: 'Corporate Hub',
                      status: 'Active',
                      icon: Icons.business_rounded,
                    ),
                    
                    const SizedBox(height: 100), // Space for persistent time tracker
                  ]),
                ),
              ),
            ],
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FloatingTimeTracker(),
          ),
        ],
      ),
    );
  }
}

class _DashboardStatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DashboardStatTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.5))),
        ],
      ),
    );
  }
}

class _HotReloadDemo extends StatefulWidget {
  const _HotReloadDemo();

  @override
  State<_HotReloadDemo> createState() => _HotReloadDemoState();
}

class _HotReloadDemoState extends State<_HotReloadDemo> {
  int _count = 0;

  void _increment() {
    setState(() {
      _count++;
      debugPrint('Button pressed. Current count: $_count');
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building _HotReloadDemo - Widget Tree can be inspected in DevTools');
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hot Reload & Debugging Demo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Modify this widget\'s text or colours in code, then save to see Hot Reload update instantly.',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Welcome to Clientnest',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '$_count',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _increment,
                  icon: const Icon(Icons.touch_app),
                  label: const Text('Press Me'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
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

// ────────────────────────────────────────────────────────────────────────────
// Navigator Demo Entry Card (shown on Home dashboard)
// ────────────────────────────────────────────────────────────────────────────

class _NavigatorDemoCard extends StatelessWidget {
  const _NavigatorDemoCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          debugPrint('HomeScreen: Navigating to /nav-demo via GoRouter');
          context.push('/nav-demo');
        },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6366F1).withValues(alpha: 0.08),
                const Color(0xFF8B5CF6).withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF6366F1).withValues(alpha: 0.25),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.route_rounded,
                    color: Color(0xFF6366F1),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Navigator API Demo',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Explore push(), pop() & named routes',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: const Color(0xFF6366F1).withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
