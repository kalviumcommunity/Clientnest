import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/project_provider.dart';
import '../../models/project_model.dart';
import 'package:clientnest/widgets/dashboard_widgets.dart';
import 'create_project_screen.dart';
import 'project_detail_screen.dart';

/// Full-featured project list screen with live Firestore data,
/// tab filtering, and navigation to detail & create screens.
class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen>
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Nest'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Leads'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, _) {
          if (provider.error != null) {
            return ErrorStateWidget(
              error: provider.error!,
              onRetry: () => provider.fetchProjects(),
            );
          }

          if (provider.isLoading && provider.projects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final leads = provider.projects
              .where((p) => p.status == ProjectStatus.lead || p.status == ProjectStatus.pending)
              .toList();
          final active = provider.projects
              .where((p) => p.status == ProjectStatus.active)
              .toList();
          final completed = provider.projects
              .where((p) => p.status == ProjectStatus.completed)
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _ProjectListView(
                projects: leads,
                emptyMsg: 'No leads yet. Tap + to add one.',
                icon: Icons.local_fire_department_rounded,
              ),
              _ProjectListView(
                projects: active,
                emptyMsg: 'No active projects. Get started!',
                icon: Icons.rocket_launch_rounded,
              ),
              _ProjectListView(
                projects: completed,
                emptyMsg: 'No completed projects yet.',
                icon: Icons.task_alt_rounded,
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'project_list_fab',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const CreateProjectScreen()),
        ),
        label: const Text('New Project'),
        icon: const Icon(Icons.add_rounded),
        elevation: 2,
      ),
    );
  }
}

// ─── Project List View ───────────────────────────────────────────────────────
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
        title: 'Nothing here',
        message: emptyMsg,
        icon: icon,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        return _ProjectCard(project: projects[index])
            .animate()
            .fadeIn(delay: (index * 60).ms)
            .slideY(begin: 0.08);
      },
    );
  }
}

// ─── Project Card ────────────────────────────────────────────────────────────
class _ProjectCard extends StatelessWidget {
  final Project project;

  const _ProjectCard({required this.project});

  Color _statusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return const Color(0xFF6366F1);
      case ProjectStatus.lead:
      case ProjectStatus.pending:
        return const Color(0xFFF59E0B);
      case ProjectStatus.completed:
        return const Color(0xFF10B981);
    }
  }

  String _statusLabel(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.lead:
        return 'Lead';
      case ProjectStatus.pending:
        return 'Pending';
      case ProjectStatus.completed:
        return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _statusColor(project.status);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectDetailScreen(project: project),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: title + status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colored left accent
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (project.clientName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          project.clientName,
                          style: TextStyle(
                              fontSize: 12, color: colorScheme.primary),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(project.status),
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (project.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                project.description,
                style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.55)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 14),
            // Bottom row: deadline + arrow
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.45)),
                const SizedBox(width: 6),
                Text(
                  'Due ${DateFormat('MMM dd, yyyy').format(project.deadline)}',
                  style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.5)),
                ),
                const Spacer(),
                Icon(Icons.chevron_right_rounded,
                    size: 18,
                    color: colorScheme.onSurface.withValues(alpha: 0.3)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
