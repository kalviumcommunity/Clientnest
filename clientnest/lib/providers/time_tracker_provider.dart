import 'dart:async';
import 'package:flutter/material.dart';
import '../models/time_log_model.dart';
import '../services/firestore_service.dart';

class TimeTrackerProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  TimeLog? _activeLog;
  Timer? _timer;
  int _currentDuration = 0;

  TimeLog? get activeLog => _activeLog;
  int get currentDuration => _currentDuration;

  void init() {
    _firestoreService.getActiveTimeLog().listen((log) {
      _activeLog = log;
      if (_activeLog != null && _activeLog!.isRunning) {
        _startLocalTimer();
      } else {
        _stopLocalTimer();
      }
      notifyListeners();
    });
  }

  void _startLocalTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_activeLog != null) {
        _currentDuration = _activeLog!.currentDuration;
        notifyListeners();
      }
    });
  }

  void _stopLocalTimer() {
    _timer?.cancel();
    _timer = null;
    _currentDuration = 0;
    notifyListeners();
  }

  Future<void> startTracking(String projectId, String projectTitle) async {
    await _firestoreService.startTimeLog(projectId, projectTitle);
  }

  Future<void> stopTracking() async {
    if (_activeLog != null) {
      await _firestoreService.stopTimeLog(_activeLog!.id, _activeLog!.currentDuration);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
