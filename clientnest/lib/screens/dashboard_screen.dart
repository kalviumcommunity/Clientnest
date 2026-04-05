import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/client_provider.dart';
import '../../services/auth_service.dart';
import 'package:clientnest/widgets/dashboard_widgets.dart';
import 'package:clientnest/widgets/time_tracker_widget.dart';
import 'package:clientnest/widgets/logo_widget.dart';
import '../../models/project_model.dart';
import '../../screens/projects/create_project_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clientnest/shared/widgets/nest_ui.dart';
import '../../core/theme/nest_design_system.dart';

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
                  ? Text(
                      user?.displayName?[0].toUpperCase() ?? 'U',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? 'Freelancer',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              user?.email ?? 'No email available',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 32),
            _buildProfileOption(
              context,
              icon: themeProvider.themeMode == ThemeMode.dark ? Icons.wb_sunny_outlined : Icons.nightlight_round_outlined,
              label: themeProvider.themeMode == ThemeMode.dark ? 'Light Mode' : 'Dark Mode',
              trailing: Switch.adaptive(
                value: themeProvider.themeMode == ThemeMode.dark,
                activeColor: NestDesignSystem.accent,
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
              onTap: () => themeProvider.toggleTheme(),
            ),
            const SizedBox(height: 12),
            _buildProfileOption(
              context,
              icon: Icons.logout_rounded,
              label: 'Sign Out',
              color: NestDesignSystem.error,
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

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
    Color? color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayerContainer(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: Row(
        children: [
          Icon(icon, color: color ?? colorScheme.onSurface, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: color ?? colorScheme.onSurface,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AppShell(
      title: 'Dashboard',
      actions: [
        IconButton(
          onPressed: () => _showProfileSheet(context, user),
          icon: CircleAvatar(
            radius: 14,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
            child: user.photoURL == null
                ? Text(
                    user.displayName?[0].toUpperCase() ?? 'U',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  )
                : null,
          ),
        ),
      ],
      child: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              context.read<ProjectProvider>().fetchProjects();
              context.read<ClientProvider>().fetchClients();
              context.read<InvoiceProvider>().fetchInvoices();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: NestDesignSystem.spacingL, vertical: NestDesignSystem.spacingL),
              children: [
                _buildWelcomeSection(context, user),
                const SizedBox(height: NestDesignSystem.spacingXL),
                _buildDashboardContent(context),
                const SizedBox(height: 140),
              ],
            ),
          ),
          const Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: FloatingTimeTracker(),
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
          'Hi, ${user?.displayName?.split(' ')[0] ?? 'Freelancer'}',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Here is your workspace overview.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.02);
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
          return _buildLoadingSkeleton(context);
        }

        return Column(
          children: [
            _buildMainFeature(context, projectProvider),
            const SizedBox(height: NestDesignSystem.spacingXL),
            _buildStatsGrid(context, projectProvider, clientProvider, invoiceProvider),
            const SizedBox(height: NestDesignSystem.spacingXL),
            _buildFinancialSection(context, invoiceProvider),
          ],
        );
      },
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return const Column(
      children: [
        SkeletonLoader(height: 160),
        SizedBox(height: 28),
        Row(
          children: [
            Expanded(child: SkeletonLoader(height: 100)),
            SizedBox(width: 16),
            Expanded(child: SkeletonLoader(height: 100)),
          ],
        ),
        SizedBox(height: 28),
        SkeletonLoader(height: 300),
      ],
    );
  }

  Widget _buildMainFeature(BuildContext context, ProjectProvider provider) {
    if (provider.allProjects.isEmpty) {
      return const EmptyStateWidget(
        title: 'Project Nest is Empty',
        message: 'Start by creating your first project to track deadlines and tasks.',
        icon: Icons.rocket_launch_outlined,
      );
    }

    final now = DateTime.now();
    final upcomingList = provider.allProjects.where((p) => p.status != ProjectStatus.completed && p.deadline.isAfter(now)).toList();
    final overdueList = provider.allProjects.where((p) => p.status != ProjectStatus.completed && p.deadline.isBefore(now)).toList();

    if (upcomingList.isEmpty && overdueList.isEmpty) return const SizedBox.shrink();

    final projectsToDisplay = upcomingList.isNotEmpty ? upcomingList : overdueList;
    projectsToDisplay.sort((a, b) => a.deadline.compareTo(b.deadline));
    final nextProject = projectsToDisplay.first;

    return DeadlineCountdown(deadline: nextProject.deadline, title: nextProject.title).animate().fadeIn(duration: 800.ms).slideY(begin: 0.05);
  }

  Widget _buildStatsGrid(
    BuildContext context,
    ProjectProvider projectProvider,
    ClientProvider clientProvider,
    InvoiceProvider invoiceProvider,
  ) {
    final activeCount = projectProvider.allProjects.where((p) => p.status == ProjectStatus.active).length;
    final clientCount = clientProvider.allClients.length;
    final invoiceCount = invoiceProvider.allInvoices.length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Active Nests',
                value: activeCount.toString(),
                icon: Icons.rocket_launch_rounded,
                color: NestDesignSystem.graphBlue,
                trend: '+2',
                isTrendPositive: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                label: 'Global Clients',
                value: clientCount.toString(),
                icon: Icons.people_rounded,
                color: NestDesignSystem.graphCyan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StatCard(
          label: 'Total Generated Invoices',
          value: invoiceCount.toString(),
          icon: Icons.receipt_long_rounded,
          color: NestDesignSystem.graphPurple,
          trend: 'Live',
        ),
      ],
    );
  }

  Widget _buildFinancialSection(BuildContext context, InvoiceProvider provider) {
    return FinancialSnapshot(
      income: provider.totalIncome,
      pending: provider.totalPending,
    ).animate().fadeIn(duration: 1000.ms).slideY(begin: 0.05);
  }
}
