import 'package:cloud_firestore/cloud_firestore.dart';

class TimeLog {
  final String id;
  final String userId;
  final String projectId;
  final String projectTitle;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isRunning;
  final int durationInMinutes;

  TimeLog({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.projectTitle,
    required this.startTime,
    this.endTime,
    required this.isRunning,
    this.durationInMinutes = 0,
  });

  factory TimeLog.fromMap(Map<String, dynamic> map, String documentId) {
    return TimeLog(
      id: documentId,
      userId: map['userId'] ?? '',
      projectId: map['projectId'] ?? '',
      projectTitle: map['projectTitle'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: map['endTime'] != null ? (map['endTime'] as Timestamp).toDate() : null,
      isRunning: map['isRunning'] ?? false,
      durationInMinutes: map['durationInMinutes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'projectId': projectId,
      'projectTitle': projectTitle,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'isRunning': isRunning,
      'durationInMinutes': durationInMinutes,
    };
  }

  int get currentDuration {
    if (isRunning) {
      return DateTime.now().difference(startTime).inMinutes + durationInMinutes;
    }
    return durationInMinutes;
  }
}
