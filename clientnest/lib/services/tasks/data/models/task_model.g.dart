// GENERATED CODE - DO NOT MODIFY BY HAND
// Updated manually to match the current TaskModel schema (status enum replaces isCompleted bool).

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 0;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      dueDate: fields[3] as DateTime,
      // Field 4 was previously 'isCompleted' (bool). Now stored as TaskStatus name string.
      // Gracefully fall back to TaskStatus.active if the value can't be parsed.
      status: _parseStatus(fields[4]),
    );
  }

  TaskStatus _parseStatus(dynamic raw) {
    if (raw is TaskStatus) return raw;
    if (raw is String) {
      return TaskStatus.values.firstWhere(
        (s) => s.name == raw,
        orElse: () => TaskStatus.active,
      );
    }
    // Legacy bool support: true => completed, false => active
    if (raw is bool) {
      return raw ? TaskStatus.completed : TaskStatus.active;
    }
    return TaskStatus.active;
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.dueDate)
      ..writeByte(4)
      ..write(obj.status.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
