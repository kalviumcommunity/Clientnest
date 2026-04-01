import 'package:equatable/equatable.dart';
import '../../../../models/task_model.dart'; // Import the global status enum

class Task extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskStatus status;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.status = TaskStatus.active,
  });

  @override
  List<Object?> get props => [id, title, description, dueDate, status];

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
    );
  }
}
