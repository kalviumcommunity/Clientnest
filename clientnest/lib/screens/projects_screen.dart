import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../providers/time_tracker_provider.dart';
import '../models/project_model.dart';
import 'package:intl/intl.dart';
import '../shared/widgets/dashboard_widgets.dart';
import 'projects/create_project_screen.dart';
import 'projects/project_detail_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Nest'),
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Leads'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            return ErrorStateWidget(
              error: provider.error!,
              onRetry: () => provider.fetchProjects(),
            );
          }

          if (provider.isLoading && provider.projects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final leads = provider.projects.where((p) => p.status == ProjectStatus.lead).toList();
          final active = provider.projects.where((p) => p.status == ProjectStatus.active).toList();
          final completed = provider.projects.where((p) => p.status == ProjectStatus.completed).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _ProjectListView(projects: leads, emptyMsg: 'No leads found.', icon: Icons.local_fire_department_rounded),
              _ProjectListView(projects: active, emptyMsg: 'No active projects.', icon: Icons.rocket_launch_rounded),
              _ProjectListView(projects: completed, emptyMsg: 'No completed projects yet.', icon: Icons.task_alt_rounded),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'projects_screen_fab',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
        ),
        label: const Text('Add Nest'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _ProjectListView extends StatelessWidget {
  final List<Project> projects;
  final String emptyMsg;
  final IconData icon;

  const _ProjectListView({required this.projects, required this.emptyMsg, required this.icon});

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return EmptyStateWidget(
        title: 'Empty Category',
        message: emptyMsg,
        icon: icon,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: projects.length,
      itemBuilder: (context, index) => _ProjectCard(project: projects[index]),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final deadlineStr = DateFormat('MMM dd, yyyy').format(project.deadline);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectDetailScreen(project: project),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
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
                      Text(project.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(project.clientName, style: TextStyle(fontSize: 12, color: colorScheme.primary)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Provider.of<TimeTrackerProvider>(context, listen: false)
                      .startTracking(project.id, project.title),
                  icon: Icon(Icons.play_circle_fill, color: colorScheme.primary, size: 32),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProgressStepper(context, project.status),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
                const SizedBox(width: 8),
                Text(deadlineStr, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6))),
                const Spacer(),
                Text('\$${project.budget.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStepper(BuildContext context, ProjectStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    int currentStep = 0;
    if (status == ProjectStatus.active) currentStep = 1;
    if (status == ProjectStatus.completed) currentStep = 2;

    return Row(
      children: List.generate(3, (index) {
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: index <= currentStep ? colorScheme.primary : colorScheme.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  index < currentStep ? Icons.check : Icons.circle,
                  size: 14,
                  color: index <= currentStep ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                ),
              ),
              if (index < 2)
                Expanded(
                  child: Container(
                    height: 2,
                    color: index < currentStep ? colorScheme.primary : colorScheme.surfaceVariant,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
