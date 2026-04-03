import '../domain/task_models.dart';

abstract class TaskRepository {
  Future<List<Task>> fetchTasks();

  Future<void> seedIfEmpty(List<Task> seedTasks);

  Future<void> replaceAll(List<Task> tasks);
}
