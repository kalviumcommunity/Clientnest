import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../bloc/task_bloc.dart';
import '../../domain/entities/task.dart';
import '../../../../injection_container.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TaskBloc>()..add(LoadTasks()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ClientNest Tasks'),
        ),
        body: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TaskLoaded) {
              if (state.tasks.isEmpty) {
                return const Center(child: Text('No tasks yet.'));
              }
              return ListView.builder(
                itemCount: state.tasks.length,
                itemBuilder: (context, index) {
                  final task = state.tasks[index];
                  return ListTile(
                    title: Text(task.title),
                    subtitle: Text(task.description),
                    trailing: Text(task.dueDate.toString().split(' ')[0]),
                  );
                },
              );
            } else if (state is TaskError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () {
              final task = Task(
                id: const Uuid().v4(),
                title: 'New Task',
                description: 'Description of the task',
                dueDate: DateTime.now(),
              );
              context.read<TaskBloc>().add(AddTaskEvent(task));
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
