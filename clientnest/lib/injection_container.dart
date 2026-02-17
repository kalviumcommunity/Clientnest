import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/tasks/data/datasources/task_local_data_source.dart';
import 'features/tasks/data/models/task_model.dart';
import 'features/tasks/data/repositories/task_repository_impl.dart';
import 'features/tasks/domain/repositories/task_repository.dart';
import 'features/tasks/domain/usecases/add_task.dart';
import 'features/tasks/domain/usecases/get_tasks.dart';
import 'features/tasks/presentation/bloc/task_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Tasks
  // Bloc
  sl.registerFactory(
    () => TaskBloc(
      getTasks: sl(),
      addTask: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTasks(sl()));
  sl.registerLazySingleton(() => AddTask(sl()));

  // Repository
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(sl()),
  );

  //! Core
  // Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TaskModelAdapter());
  final taskBox = await Hive.openBox<TaskModel>('tasks');
  sl.registerLazySingleton(() => taskBox);
}
