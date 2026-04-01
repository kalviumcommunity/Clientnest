import 'package:hive/hive.dart';
// Only import the domain Task entity; hide global Task to avoid ambiguity.
import 'package:clientnest/models/task_model.dart' show TaskStatus;
import '../../domain/entities/task.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends Task {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String title;
  @override
  @HiveField(2)
  final String description;
  @override
  @HiveField(3)
  final DateTime dueDate;
  @override
  @HiveField(4)
  final TaskStatus status;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.status = TaskStatus.active,
  }) : super(
          id: id,
          title: title,
          description: description,
          dueDate: dueDate,
          status: status,
        );

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      status: task.status,
    );
  }
}
