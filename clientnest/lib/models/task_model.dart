import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { active, completed }

class Task {
  final String id;
  final String projectId;
  final String userId;
  final String title;
  final TaskStatus status;
  final String priority;
  final DateTime? dueDate;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.title,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.createdAt,
  });

  factory Task.fromMap(Map<String, dynamic> map, String documentId) {
    // Migration logic: handles legacy isCompleted boolean and any "pending" status values
    TaskStatus status;
    if (map['status'] != null) {
      if (map['status'] == 'completed') {
        status = TaskStatus.completed;
      } else {
        // Any other status (including "pending") becomes "active"
        status = TaskStatus.active;
      }
    } else {
      // Fallback for legacy boolean field
      final isCompleted = map['isCompleted'] ?? false;
      status = isCompleted ? TaskStatus.completed : TaskStatus.active;
    }

    return Task(
      id: documentId,
      projectId: map['projectId'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      status: status,
      priority: map['priority'] ?? 'Medium',
      dueDate: map['dueDate'] != null ? (map['dueDate'] as Timestamp).toDate() : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'userId': userId,
      'title': title,
      'status': status.name,
      'priority': priority,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Task copyWith({
    String? id,
    String? projectId,
    String? userId,
    String? title,
    TaskStatus? status,
    String? priority,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

