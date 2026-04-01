import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../providers/project_provider.dart';
import '../providers/time_tracker_provider.dart';
import '../models/project_model.dart';
import 'package:intl/intl.dart';
import 'package:clientnest/widgets/dashboard_widgets.dart';
import '../screens/projects/create_project_screen.dart';
import '../screens/projects/project_detail_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<ProjectProvider>(
      builder: (context, provider, child) {
        final leads = provider.projects
            .where((p) =>
                p.status == ProjectStatus.lead ||
                p.status == ProjectStatus.pending)
            .toList();
        final active = provider.projects
            .where((p) => p.status == ProjectStatus.active)
            .toList();
        final completed = provider.projects
            .where((p) => p.status == ProjectStatus.completed)
            .toList();

        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              'Project Nest',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal, fontSize: 13),
                indicatorColor: colorScheme.primary,
                indicatorWeight: 3,
                dividerColor: Colors.transparent,
                tabs: [
                  _buildTab('Leads', leads.length, colorScheme),
                  _buildTab('Active', active.length, colorScheme),
                  _buildTab('Completed', completed.length, colorScheme),
                ],
              ),
            ),
          ),
          body: _buildBody(provider, leads, active, completed),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 110.0),
            child: FloatingActionButton.extended(
              heroTag: 'projects_screen_fab',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CreateProjectScreen()),
              ),
              label: const Text('Add Nest',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.add),
              elevation: 4,
            ),
          ),
        );
      },
    );
  }

  Tab _buildTab(String label, int count, ColorScheme colorScheme) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(
    ProjectProvider provider,
    List<Project> leads,
    List<Project> active,
    List<Project> completed,
  ) {
    if (provider.error != null) {
      return ErrorStateWidget(
        error: provider.error!,
        onRetry: () => provider.fetchProjects(),
      );
    }

    if (provider.isLoading && provider.projects.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return TabBarView(
      controller: _tabController,
      physics: const BouncingScrollPhysics(),
      children: [
        _ProjectListView(
          projects: leads,
          emptyMsg: 'No leads yet. Add a prospect to get started.',
          icon: Icons.local_fire_department_rounded,
        ),
        _ProjectListView(
          projects: active,
          emptyMsg: 'No active projects. Start working on a lead!',
          icon: Icons.rocket_launch_rounded,
        ),
        _ProjectListView(
          projects: completed,
          emptyMsg: 'No completed projects yet. Keep going!',
          icon: Icons.task_alt_rounded,
        ),
      ],
    );
  }
}

// ─── Project List View ─────────────────────────────────────────────────────────

class _ProjectListView extends StatelessWidget {
  final List<Project> projects;
  final String emptyMsg;
  final IconData icon;

  const _ProjectListView({
    required this.projects,
    required this.emptyMsg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return EmptyStateWidget(
        title: 'Empty Category',
        message: emptyMsg,
        icon: icon,
      ).animate().fadeIn();
    }

    // MediaQuery-aware top padding to account for AppBar + TabBar
    final topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight + 48 + 16;

    return ListView.builder(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: topPadding,
        bottom: 120,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: projects.length,
      itemBuilder: (context, index) => _ProjectCard(project: projects[index])
          .animate()
          .fadeIn(duration: 350.ms, delay: (index * 45).ms)
          .slideY(begin: 0.08, end: 0),
    );
  }
}

// ─── Project Card ──────────────────────────────────────────────────────────────

class _ProjectCard extends StatelessWidget {
  final Project project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final deadlineStr =
        DateFormat('MMM dd, yyyy').format(project.deadline);
    final isOverdue = project.deadline.isBefore(DateTime.now()) &&
        project.status != ProjectStatus.completed;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectDetailScreen(project: project),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isOverdue
                      ? Colors.redAccent.withValues(alpha: 0.3)
                      : colorScheme.outlineVariant.withValues(alpha: 0.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              project.clientName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () =>
                            Provider.of<TimeTrackerProvider>(context,
                                    listen: false)
                                .startTracking(project.id, project.title),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: colorScheme.primary,
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildProgressStepper(context, project.status),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: isOverdue
                            ? Colors.redAccent
                            : colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOverdue ? 'Overdue · $deadlineStr' : deadlineStr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isOverdue
                              ? Colors.redAccent
                              : colorScheme.onSurface.withValues(alpha: 0.4),
                          fontWeight: isOverdue ? FontWeight.w600 : null,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${project.budget.toStringAsFixed(0)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStepper(
      BuildContext context, ProjectStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    int currentStep = 0;
    if (status == ProjectStatus.active) currentStep = 1;
    if (status == ProjectStatus.completed) currentStep = 2;

    return Row(
      children: List.generate(3, (index) {
        final isActive = index <= currentStep;
        final isCompleted = index < currentStep;

        return Expanded(
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isActive
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: isActive
                      ? null
                      : Border.all(
                          color: colorScheme.outline
                              .withValues(alpha: 0.2)),
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : Icons.circle,
                  size: isCompleted ? 14 : 7,
                  color: isActive
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.4),
                ),
              ),
              if (index < 2)
                Expanded(
                  child: Container(
                    height: 3,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
