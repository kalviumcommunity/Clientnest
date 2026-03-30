import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/project_model.dart';
import '../../models/task_model.dart';
import '../../providers/project_provider.dart';
import '../../services/project_service.dart';
import 'create_project_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final ProjectService _service = ProjectService();
  final _taskController = TextEditingController();
  bool _addingTask = false;

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  // ─── Delete Project ────────────────────────────────────────────────────────
  Future<void> _deleteProject() async {
    final confirmed = await _showConfirmDialog(
      'Delete Project',
      'Are you sure you want to delete "${widget.project.title}"? This will also delete all its tasks.',
    );
    if (!confirmed) return;

    try {
      await Provider.of<ProjectProvider>(context, listen: false)
          .deleteProject(widget.project.id);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _showError('Failed to delete project: $e');
    }
  }

  // ─── Add Task ──────────────────────────────────────────────────────────────
  Future<void> _addTask() async {
    final title = _taskController.text.trim();
    if (title.isEmpty) return;
    setState(() => _addingTask = true);
    try {
      final task = Task(
        id: '',
        projectId: widget.project.id,
        userId: widget.project.userId,
        title: title,
        isCompleted: false,
        priority: 'Medium',
        createdAt: DateTime.now(),
      );
      await _service.addTask(widget.project.id, task);
      _taskController.clear();
    } catch (e) {
      if (mounted) _showError('Failed to add task: $e');
    } finally {
      if (mounted) setState(() => _addingTask = false);
    }
  }

  // ─── Toggle Task ───────────────────────────────────────────────────────────
  Future<void> _toggleTask(Task task) async {
    try {
      await _service.toggleTaskCompletion(
          widget.project.id, task.id, !task.isCompleted);
    } catch (e) {
      if (mounted) _showError('Failed to update task: $e');
    }
  }

  // ─── Delete Task ───────────────────────────────────────────────────────────
  Future<void> _deleteTask(Task task) async {
    try {
      await _service.deleteTask(widget.project.id, task.id);
    } catch (e) {
      if (mounted) _showError('Failed to delete task: $e');
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

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
    final textTheme = Theme.of(context).textTheme;
    final project = widget.project;
    final statusColor = _statusColor(project.status);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          project.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Project',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CreateProjectScreen(project: widget.project)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            tooltip: 'Delete Project',
            onPressed: _deleteProject,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Project Info Card ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor, statusColor.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _statusLabel(project.status),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(Icons.rocket_launch_rounded,
                        color: Colors.white.withValues(alpha: 0.6), size: 20),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  project.title,
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (project.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    project.description,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded,
                        size: 14, color: Colors.white.withValues(alpha: 0.8)),
                    const SizedBox(width: 6),
                    Text(
                      project.clientName.isNotEmpty
                          ? project.clientName
                          : 'No client set',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Icon(Icons.calendar_today_outlined,
                        size: 14, color: Colors.white.withValues(alpha: 0.8)),
                    const SizedBox(width: 6),
                    Text(
                      'Due ${DateFormat('MMM dd, yyyy').format(project.deadline)}',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Tasks Section Header ───────────────────────────────────────────
          Row(
            children: [
              Text(
                'Tasks',
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Icon(Icons.checklist_rounded,
                  size: 20, color: colorScheme.primary),
            ],
          ),
          const SizedBox(height: 16),

          // ── Add Task Row ───────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _taskController,
                  decoration: InputDecoration(
                    hintText: 'Add a new task...',
                    filled: true,
                    fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _addTask(),
                  textInputAction: TextInputAction.done,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                width: 48,
                child: ElevatedButton(
                  onPressed: _addingTask ? null : _addTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _addingTask
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.add, size: 22),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Task List ──────────────────────────────────────────────────────
          StreamBuilder<List<Task>>(
            stream: _service.getProjectTasks(project.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Error loading tasks: ${snapshot.error}',
                      style: const TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final tasks = snapshot.data ?? [];

              if (tasks.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(Icons.task_outlined,
                          size: 48,
                          color: colorScheme.onSurface.withValues(alpha: 0.2)),
                      const SizedBox(height: 12),
                      Text(
                        'No tasks yet',
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add a task above to get started.',
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: tasks.map((task) => _TaskTile(
                  task: task,
                  onToggle: () => _toggleTask(task),
                  onDelete: () => _deleteTask(task),
                )).toList(),
              );
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─── Task Tile Widget ──────────────────────────────────────────────────────────
class _TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskTile({
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isCompleted
              ? colorScheme.primary.withValues(alpha: 0.25)
              : colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: task.isCompleted ? colorScheme.primary : Colors.transparent,
              border: Border.all(
                color: task.isCompleted
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.3),
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
            child: task.isCompleted
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration:
                task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted
                ? colorScheme.onSurface.withValues(alpha: 0.4)
                : colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.close_rounded,
              size: 18, color: colorScheme.onSurface.withValues(alpha: 0.35)),
          onPressed: onDelete,
          splashRadius: 20,
          tooltip: 'Delete task',
        ),
      ),
    );
  }
}
