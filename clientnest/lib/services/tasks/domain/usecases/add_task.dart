import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class AddTaskParams {
  final TaskEntity task;
  AddTaskParams(this.task);
}

class AddTask implements UseCase<void, AddTaskParams> {
  final TaskRepository repository;

  AddTask(this.repository);

  @override
  Future<Either<Failure, void>> call(AddTaskParams params) async {
    return await repository.addTask(params.task);
  }
}
