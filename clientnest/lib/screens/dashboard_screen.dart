import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../core/theme/theme_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../services/auth_service.dart';
import 'package:clientnest/widgets/dashboard_widgets.dart';
import 'package:clientnest/widgets/time_tracker_widget.dart';
import 'package:clientnest/widgets/logo_widget.dart';
import '../../providers/client_provider.dart';
import '../../models/project_model.dart';
import '../../screens/projects/create_project_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clientnest/widgets/premium_background.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showProfileSheet(BuildContext context, dynamic user) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            CircleAvatar(
              radius: 40,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null 
                  ? Text(user?.displayName?[0].toUpperCase() ?? 'U', 
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colorScheme.primary))
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? 'Freelancer',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? 'No email available',
              style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 32),
            _buildProfileOption(
              context,
              icon: themeProvider.themeMode == ThemeMode.dark ? Icons.wb_sunny_outlined : Icons.nightlight_round_outlined,
              label: themeProvider.themeMode == ThemeMode.dark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              trailing: Switch.adaptive(
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
              onTap: () => themeProvider.toggleTheme(),
            ),
            const SizedBox(height: 12),
            _buildProfileOption(
              context,
              icon: Icons.logout_rounded,
              label: 'Logout',
              color: Colors.redAccent,
              onTap: () async {
                Navigator.pop(context);
                await authService.signOut();
                if (context.mounted) context.go('/landing');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context, {
    required IconData icon, 
    required String label, 
    required VoidCallback onTap, 
    Widget? trailing,
    Color? color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? colorScheme.onSurface, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color ?? colorScheme.onSurface)),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text("Something went wrong. Please try again."),
            ),
          );
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            FirebaseFirestore.instance.collection('users').doc(user.uid).set({
              'name': user.displayName ?? "",
              'email': user.email ?? "",
              'photoURL': user.photoURL ?? "",
              'role': "freelancer",
              'joinedAt': FieldValue.serverTimestamp(),
              'themePreference': "system"
            }, SetOptions(merge: true)).catchError((e) => debugPrint('Error creating user doc: $e'));
          });
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildTopHeader(context, user),
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        children: [
                          _buildWelcomeSection(context, user),
                          const SizedBox(height: 32),
                          _buildDashboardContent(context),
                          const SizedBox(height: 120),
                        ],
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
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 110.0),
            child: FloatingActionButton(
              heroTag: 'dashboard_create_project_fab',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
              ),
              tooltip: 'New Project',
              child: const Icon(Icons.add_rounded),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopHeader(BuildContext context, dynamic user) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const LogoWithText(iconSize: 28, fontSize: 20),
          GestureDetector(
            onTap: () => _showProfileSheet(context, user),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null 
                  ? Text(user?.displayName?[0].toUpperCase() ?? 'U', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimaryContainer))
                  : null,
            ).animate().scale(delay: 200.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OVERVIEW',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Hi, ${user?.displayName?.split(' ')[0] ?? 'Freelancer'}!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1.5,
          ),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.05);
  }

  Widget _buildDashboardContent(BuildContext context) {
    return Consumer3<ProjectProvider, ClientProvider, InvoiceProvider>(
      builder: (context, projectProvider, clientProvider, invoiceProvider, child) {
        if (projectProvider.error != null) {
          return ErrorStateWidget(
            error: projectProvider.error!,
            onRetry: () => projectProvider.fetchProjects(),
          );
        }

        if (projectProvider.isLoading && projectProvider.projects.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (projectProvider.projects.isEmpty) {
          return const EmptyStateWidget(
            title: 'No Projects Yet',
            message: 'Start by adding your first project to track your progress.',
          );
        }

        return Column(
          children: [
            _buildMainFeature(context, projectProvider),
            const SizedBox(height: 32),
            _buildStatsGrid(context, projectProvider),
            const SizedBox(height: 32),
            _buildFinancialSection(context, invoiceProvider),
          ],
        );
      },
    );
  }

  Widget _buildMainFeature(BuildContext context, ProjectProvider provider) {
    final now = DateTime.now();
    final upcoming = provider.projects
        .where((p) => p.status != ProjectStatus.completed && p.deadline.isAfter(now))
        .toList();
    
    if (upcoming.isEmpty) return const SizedBox.shrink();
    
    upcoming.sort((a, b) => a.deadline.compareTo(b.deadline));
    final next = upcoming.first;
    
    return DeadlineCountdown(deadline: next.deadline, title: next.title)
        .animate()
        .slideY(begin: 0.1, duration: 600.ms)
        .fadeIn();
  }

  Widget _buildStatsGrid(BuildContext context, ProjectProvider projectProvider) {
    final activeCount = projectProvider.projects
        .where((p) => p.status == ProjectStatus.active)
        .length;
    final pendingWorkCount = projectProvider.projects
        .where((p) => p.status != ProjectStatus.completed)
        .length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.6,
      children: [
        _buildStatCard(
          context,
          'Active Nests',
          activeCount.toString(),
          Icons.rocket_launch_rounded,
          const Color(0xFF6366F1),
        ),
        _buildStatCard(
          context,
          'Pending Work',
          pendingWorkCount.toString(),
          Icons.pending_actions_rounded,
          const Color(0xFFF59E0B),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1.5),
                  ),
                ],
              ),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10, 
                  color: colorScheme.onSurface.withValues(alpha: 0.5), 
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialSection(BuildContext context, InvoiceProvider provider) {
    double totalIncome = 0;
    double totalPending = 0;
    for (var inv in provider.invoices) {
      if (inv.status == 'Paid') {
        totalIncome += inv.amount;
      } else {
        totalPending += inv.amount;
      }
    }
    return FinancialSnapshot(income: totalIncome, pending: totalPending)
        .animate()
        .fadeIn(delay: 600.ms)
        .slideY(begin: 0.1);
  }
}
