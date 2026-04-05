import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

class ProjectProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Project> _projects = []; // Filtered list
  List<Project> _allProjects = []; // Unfiltered list for dashboards
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Project>>? _subscription;
  StreamSubscription<List<Project>>? _totalSubscription;

  // Query State
  ProjectStatus? _filterStatus;
  String _sortBy = 'createdAt';
  bool _isDescending = true;

  List<Project> get projects => _projects;
  List<Project> get allProjects => _allProjects;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ProjectStatus? get filterStatus => _filterStatus;
  String get sortBy => _sortBy;
  bool get isDescending => _isDescending;

  ProjectProvider() {
    if (FirebaseAuth.instance.currentUser != null) {
      _initTotalStream();
      fetchProjects();
    }
  }

  void _initTotalStream() {
    _totalSubscription?.cancel();
    _totalSubscription = _firestoreService.getProjects().listen(
      (projects) {
        _allProjects = projects;
        notifyListeners();
      },
      onError: (e) => debugPrint('Total Projects Stream Error: $e'),
    );
  }

  void setFilter(ProjectStatus? status) {
    if (_filterStatus == status) return;
    _filterStatus = status;
    fetchProjects();
  }

  void setSort(String field, {bool? descending}) {
    _sortBy = field;
    if (descending != null) _isDescending = descending;
    fetchProjects();
  }

  void toggleDirection() {
    _isDescending = !_isDescending;
    fetchProjects();
  }

  void fetchProjects() {
    _subscription?.cancel();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _subscription = _firestoreService.getProjects(
        status: _filterStatus,
        sortBy: _sortBy,
        descending: _isDescending,
      ).listen(
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
    _totalSubscription?.cancel();
    _totalSubscription = null;
    _projects = [];
    _allProjects = [];
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

  Future<void> toggleTask(String taskId, TaskStatus currentStatus) async {
    try {
      await _firestoreService.toggleTask(taskId, currentStatus);
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
