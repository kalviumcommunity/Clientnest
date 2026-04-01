import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:clientnest/services/tasks/presentation/bloc/task_bloc.dart';
import 'package:clientnest/services/tasks/domain/entities/task.dart' as domain;
import 'package:clientnest/utils/injection_container.dart';
import 'package:clientnest/models/task_model.dart' show TaskStatus;
import 'package:flutter_animate/flutter_animate.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (_) => sl<TaskBloc>()..add(LoadTasks()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Universal Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: colorScheme.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _TaskList(status: TaskStatus.active),
            _TaskList(status: TaskStatus.completed),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton.extended(
            onPressed: () {
              final task = domain.Task(
                id: const Uuid().v4(),
                title: 'New Task',
                description: 'Quick task description',
                dueDate: DateTime.now(),
                status: TaskStatus.active,
              );
              context.read<TaskBloc>().add(AddTaskEvent(task));
            },
            label: const Text('New Task'),
            icon: const Icon(Icons.add_task_rounded),
          ),
        ),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final TaskStatus status;
  const _TaskList({required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TaskLoaded) {
          final filteredTasks = state.tasks.where((t) => t.status == status).toList();

          if (filteredTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    status == TaskStatus.active ? Icons.task_alt_rounded : Icons.history_rounded,
                    size: 64,
                    color: colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    status == TaskStatus.active ? 'No active tasks' : 'No tasks finished yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              final isDone = task.status == TaskStatus.completed;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: IconButton(
                    icon: Icon(
                      isDone ? Icons.check_circle_rounded : Icons.circle_outlined,
                      color: isDone ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.3),
                      size: 28,
                    ),
                    onPressed: () {
                      // TODO: dispatch UpdateTaskEvent when added to TaskBloc.
                      // Toggle: isDone ? TaskStatus.active : TaskStatus.completed
                    },
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? colorScheme.onSurface.withValues(alpha: 0.4) : colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 12, color: colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            task.dueDate.toString().split(' ')[0],
                            style: TextStyle(fontSize: 12, color: colorScheme.primary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05),
              );
            },
          );
        } else if (state is TaskError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox();
      },
    );
  }
}

