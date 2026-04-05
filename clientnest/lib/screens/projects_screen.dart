import 'package:flutter/material.dart';
import 'package:clientnest/core/theme/nest_design_system.dart';
import 'package:clientnest/shared/widgets/nest_ui.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/project_provider.dart';
import '../models/project_model.dart';
import '../services/firestore_service.dart';
import 'package:clientnest/widgets/status_filter_bar.dart';
import 'package:clientnest/widgets/dashboard_widgets.dart';
import '../screens/projects/create_project_screen.dart';
import '../screens/projects/project_detail_screen.dart';
import 'package:clientnest/shared/widgets/nest_ui.dart';
import '../core/theme/nest_design_system.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  ProjectStatus _selectedStatus = ProjectStatus.active;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Project Nest',
      child: Column(
        children: [
          FilterBar<ProjectStatus>(
            selectedStatus: _selectedStatus,
            options: [
              FilterOption(label: 'leads', value: ProjectStatus.lead),
              FilterOption(label: 'pending', value: ProjectStatus.pending),
              FilterOption(label: 'active', value: ProjectStatus.active),
              FilterOption(label: 'completed', value: ProjectStatus.completed),
            ],
            onChanged: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
          ),
          Expanded(
            child: StreamBuilder<List<Project>>(
              stream: _firestoreService.getProjects(status: _selectedStatus),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return ErrorStateWidget(
                    error: 'Failed to fetch projects',
                    onRetry: () => setState(() {}),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: EmptyStateWidget(
                      title: 'No Projects Found',
                      message: 'Start a new project or try a different status filter.',
                      icon: Icons.rocket_launch_rounded,
                    ).animate().fadeIn(),
                  );
                }

                final projects = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: NestDesignSystem.spacingL, vertical: NestDesignSystem.spacingS),
                  itemCount: projects.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _ProjectCard(project: projects[index])
                        .animate()
                        .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                        .slideY(begin: 0.05);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final deadlineStr = DateFormat('MMM dd, yyyy').format(project.deadline);

    return LayerContainer(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectDetailScreen(project: project),
        ),
      ),
      margin: const EdgeInsets.only(bottom: NestDesignSystem.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      project.clientName.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(project.status, colorScheme),
            ],
          ),
          const SizedBox(height: NestDesignSystem.spacingL),
          Container(
            height: 1,
            color: colorScheme.onSurface.withValues(alpha: 0.05),
          ),
          const SizedBox(height: NestDesignSystem.spacingM),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 12, color: colorScheme.onSurface.withValues(alpha: 0.4)),
              const SizedBox(width: 8),
              Text(
                deadlineStr,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '\$${project.budget.toStringAsFixed(0)}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: NestDesignSystem.graphGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ProjectStatus status, ColorScheme colorScheme) {
    IconData icon;
    Color color;
    String label;

    switch (status) {
      case ProjectStatus.lead:
        icon = Icons.local_fire_department_rounded;
        color = NestDesignSystem.graphOrange;
        label = 'LEAD';
        break;
      case ProjectStatus.pending:
        icon = Icons.hourglass_top_rounded;
        color = NestDesignSystem.graphPurple;
        label = 'PENDING';
        break;
      case ProjectStatus.active:
        icon = Icons.rocket_launch_rounded;
        color = NestDesignSystem.accent;
        label = 'ACTIVE';
        break;
      case ProjectStatus.completed:
        icon = Icons.check_circle_rounded;
        color = NestDesignSystem.graphCyan;
        label = 'DONE';
        break;
      default:
        icon = Icons.folder_rounded;
        color = colorScheme.onSurface.withValues(alpha: 0.3);
        label = 'NEST';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
