import 'package:cloud_firestore/cloud_firestore.dart';

enum ProjectStatus { lead, active, completed }

class Project {
  final String id;
  final String userId;
  final String clientId;
  final String clientName;
  final String title;
  final String description;
  final ProjectStatus status;
  final double budget;
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime? lastActivity;

  Project({
    required this.id,
    required this.userId,
    required this.clientId,
    required this.clientName,
    required this.title,
    required this.description,
    required this.status,
    required this.budget,
    required this.deadline,
    required this.createdAt,
    this.lastActivity,
  });

  factory Project.fromMap(Map<String, dynamic> map, String documentId) {
    return Project(
      id: documentId,
      userId: map['userId'] ?? '',
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ProjectStatus.active,
      ),
      budget: (map['budget'] ?? 0.0).toDouble(),
      deadline: (map['deadline'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastActivity: map['lastActivity'] != null 
          ? (map['lastActivity'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'clientId': clientId,
      'clientName': clientName,
      'title': title,
      'description': description,
      'status': status.name,
      'budget': budget,
      'deadline': Timestamp.fromDate(deadline),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActivity': lastActivity != null ? Timestamp.fromDate(lastActivity!) : null,
    };
  }

  Project copyWith({
    String? id,
    String? userId,
    String? clientId,
    String? clientName,
    String? title,
    String? description,
    ProjectStatus? status,
    double? budget,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? lastActivity,
  }) {
    return Project(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      budget: budget ?? this.budget,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }
}
