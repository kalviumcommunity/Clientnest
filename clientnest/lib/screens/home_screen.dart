// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../providers/invoice_provider.dart';
import '../providers/client_provider.dart';
import '../services/auth_service.dart';
import 'package:clientnest/widgets/dashboard_widgets.dart';
import 'package:clientnest/widgets/time_tracker_widget.dart';
import '../models/project_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('HomeScreen: build() called');
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
                            ? Text(
                                user?.displayName?[0].toUpperCase() ?? 'U',
                                style: TextStyle(color: colorScheme.primary, fontSize: 14),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, ${user?.displayName?.split(' ')[0] ?? 'Freelancer'}',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Welcome back',
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                              fontSize: 10,
                            ),
                          ),
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
                    // ── Next Deadline Countdown ──────────────────────────────
                    Consumer<ProjectProvider>(
                      builder: (context, provider, child) {
                        final now = DateTime.now();
                        final upcoming = provider.projects
                            .where((p) =>
                                p.status != ProjectStatus.completed &&
                                p.deadline.isAfter(now))
                            .toList();

                        if (upcoming.isEmpty) return const SizedBox.shrink();

                        upcoming.sort((a, b) => a.deadline.compareTo(b.deadline));
                        final next = upcoming.first;

                        return Column(
                          children: [
                            DeadlineCountdown(
                              deadline: next.deadline,
                              title: next.title,
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),

                    // ── Financial Snapshot ───────────────────────────────────
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
                        return FinancialSnapshot(
                          income: totalIncome,
                          pending: totalPending,
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // ── Quick Stats Row ──────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _DashboardStatTile(
                            label: 'Active Projects',
                            value: Provider.of<ProjectProvider>(context)
                                .projects
                                .where((p) => p.status == ProjectStatus.active)
                                .length
                                .toString(),
                            icon: Icons.rocket_launch_outlined,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DashboardStatTile(
                            label: 'Leads',
                            value: Provider.of<ProjectProvider>(context)
                                .projects
                                .where((p) => p.status == ProjectStatus.lead)
                                .length
                                .toString(),
                            icon: Icons.flash_on_outlined,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1),
                    const SizedBox(height: 32),

                    // ── Top Clients ──────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Top Clients',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 16),

                    Consumer<ClientProvider>(
                      builder: (context, clientProvider, child) {
                        if (clientProvider.isLoading && clientProvider.clients.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final clients = clientProvider.clients;

                        if (clients.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.person_add_rounded,
                                  size: 40,
                                  color: colorScheme.primary.withValues(alpha: 0.4),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No clients yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Add your first client in the CRM tab.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 400.ms);
                        }

                        // Show up to 5 most recent clients
                        final displayClients = clients.take(5).toList();
                        return Column(
                          children: displayClients.asMap().entries.map((entry) {
                            final i = entry.key;
                            final client = entry.value;
                            return _ClientRow(client: client)
                                .animate()
                                .fadeIn(delay: (400 + i * 80).ms)
                                .slideX(begin: 0.05, end: 0);
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 100), // Space for persistent time tracker
                  ]),
                ),
              ),
            ],
          ),
          const Positioned(
            bottom: 110,
            left: 16,
            right: 16,
            child: FloatingTimeTracker(),
          ),
        ],
      ),
    );
  }
}

// ── Dashboard Stat Tile ──────────────────────────────────────────────────────

class _DashboardStatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DashboardStatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -1)),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Client Row (replaces the hardcoded ClientCard) ───────────────────────────

class _ClientRow extends StatelessWidget {
  final dynamic client;

  const _ClientRow({required this.client});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Hero(
                  tag: 'client_avatar_${client.id}',
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.secondary],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (client.company.isNotEmpty)
                        Text(
                          client.company,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else if (client.email.isNotEmpty)
                        Text(
                          client.email,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
