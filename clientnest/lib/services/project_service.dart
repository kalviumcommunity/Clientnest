import '../models/task_model.dart';
import 'firestore_service.dart';

class ProjectService {
  final FirestoreService _firestoreService = FirestoreService();

  // Get tasks for a specific project with optional status filter
  Stream<List<Task>> getProjectTasks(String projectId, {TaskStatus? status}) {
    return _firestoreService.getTasks(projectId, status: status);
  }

  // Add a new task to a project
  Future<void> addTask(String projectId, Task task) async {
    // Ensure the task has the correct project ID and default status
    final taskWithProjectId = task.copyWith(
      projectId: projectId,
      status: task.status, // Should already be active from model default but copyWith ensures it
    );
    return _firestoreService.addTask(taskWithProjectId);
  }

  // Toggle task status between active and completed
  Future<void> toggleTaskCompletion(String projectId, String taskId, TaskStatus currentStatus) {
    return _firestoreService.toggleTask(taskId, currentStatus);
  }


  // Delete a task
  Future<void> deleteTask(String projectId, String taskId) {
    return _firestoreService.deleteTask(taskId);
  }
}
