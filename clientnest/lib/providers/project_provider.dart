import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

class ProjectProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void fetchProjects() {
    debugPrint('ProjectProvider: Fetching projects...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    _firestoreService.getProjects().listen(
      (projects) {
        debugPrint('ProjectProvider: Received ${projects.length} projects.');
        _projects = projects;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('ProjectProvider Error: $e');
        _isLoading = false;
        _error = e.toString();
        notifyListeners();
      },
    );
  }
  // ... rest of the class

  Stream<List<Task>> getProjectTasks(String projectId) {
    return _firestoreService.getTasks(projectId);
  }

  Future<void> addProject(Project project) async {
    await _firestoreService.addProject(project);
  }

  Future<void> updateProject(Project project) async {
    await _firestoreService.updateProject(project);
  }

  Future<void> addTask(Task task) async {
    await _firestoreService.addTask(task);
  }

  Future<void> toggleTask(String taskId, bool isCompleted) async {
    await _firestoreService.toggleTask(taskId, isCompleted);
  }
}
