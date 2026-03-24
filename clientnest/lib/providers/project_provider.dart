import 'dart:async';
import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

class ProjectProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Project>>? _subscription;

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void fetchProjects() {
    _subscription?.cancel();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _subscription = _firestoreService.getProjects().listen(
        (projects) {
          _projects = projects;
          _isLoading = false;
          _error = null;
          notifyListeners();
        },
        onError: (e) {
          debugPrint('ProjectProvider Error: $e');
          _isLoading = false;
          _error = e.toString().replaceAll('Exception: ', '');
          notifyListeners();
        },
        cancelOnError: false,
      );
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  void clear() {
    _subscription?.cancel();
    _subscription = null;
    _projects = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Stream<List<Task>> getProjectTasks(String projectId) {
    try {
      return _firestoreService.getTasks(projectId);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return const Stream.empty();
    }
  }

  Future<void> addProject(Project project) async {
    try {
      await _firestoreService.addProject(project);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      await _firestoreService.updateProject(project);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _firestoreService.deleteProject(projectId);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addTask(Task task) async {
    try {
      await _firestoreService.addTask(task);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleTask(String taskId, bool isCompleted) async {
    try {
      await _firestoreService.toggleTask(taskId, isCompleted);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _firestoreService.deleteTask(taskId);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }
}
