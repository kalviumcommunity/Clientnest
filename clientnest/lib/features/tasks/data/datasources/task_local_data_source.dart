import 'package:hive/hive.dart';
import '../models/task_model.dart';
import '../../../../core/error/failures.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<void> addTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<void> updateTask(TaskModel task);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Box<TaskModel> taskBox;

  TaskLocalDataSourceImpl(this.taskBox);

  @override
  Future<List<TaskModel>> getTasks() async {
    return taskBox.values.toList();
  }

  @override
  Future<void> addTask(TaskModel task) async {
    await taskBox.put(task.id, task);
  }

  @override
  Future<void> deleteTask(String id) async {
    await taskBox.delete(id);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await taskBox.put(task.id, task);
  }
}
