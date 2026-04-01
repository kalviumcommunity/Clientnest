import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/time_log_model.dart';
import '../services/firestore_service.dart';

class TimeTrackerProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  TimeLog? _activeLog;
  Timer? _timer;
  int _currentDuration = 0;
  String? _error;
  StreamSubscription<TimeLog?>? _subscription;

  TimeLog? get activeLog => _activeLog;
  int get currentDuration => _currentDuration;
  String? get error => _error;

  TimeTrackerProvider() {
    if (FirebaseAuth.instance.currentUser != null) {
      init();
    }
  }

  void init() {
    _subscription?.cancel();
    _error = null;
    try {
      _subscription = _firestoreService.getActiveTimeLog().listen(
        (log) {
          _activeLog = log;
          if (_activeLog != null && _activeLog!.isRunning) {
            _startLocalTimer();
          } else {
            _stopLocalTimer();
          }
          notifyListeners();
        },
        onError: (Object e) {
          debugPrint('TimeTrackerProvider stream error: $e');
          _activeLog = null;
          _error = e.toString().replaceAll('Exception: ', '');
          _stopLocalTimer();
          notifyListeners();
        },
        onDone: () {
          debugPrint('TimeTrackerProvider stream closed.');
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('TimeTrackerProvider stream exception: $e');
      _activeLog = null;
      _error = e.toString().replaceAll('Exception: ', '');
      _stopLocalTimer();
      notifyListeners();
    }
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
    try {
      await _firestoreService.startTimeLog(projectId, projectTitle);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> stopTracking() async {
    try {
      if (_activeLog != null) {
        await _firestoreService.stopTimeLog(_activeLog!.id, _activeLog!.currentDuration);
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
