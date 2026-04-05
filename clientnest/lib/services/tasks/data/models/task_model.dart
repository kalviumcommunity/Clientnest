import 'package:hive/hive.dart';
// Only import the domain Task entity; hide global Task to avoid ambiguity.
import 'package:clientnest/models/task_model.dart' show TaskStatus;
import '../../domain/entities/task.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final DateTime dueDate;
  @HiveField(4)
  final TaskStatus status;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.status = TaskStatus.active,
  });

  TaskEntity toEntity() => TaskEntity(
        id: id,
        title: title,
        description: description,
        dueDate: dueDate,
        status: status,
      );

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate,
      status: entity.status,
    );
  }
}
