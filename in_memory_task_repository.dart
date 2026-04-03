import '../domain/task_models.dart';
import 'task_repository.dart';

class InMemoryTaskRepository implements TaskRepository {
  InMemoryTaskRepository([List<Task>? initialTasks])
      : _tasks = List<Task>.from(initialTasks ?? const <Task>[]);

  List<Task> _tasks;

  @override
  Future<List<Task>> fetchTasks() async => List<Task>.from(_tasks);

  @override
  Future<void> replaceAll(List<Task> tasks) async {
    _tasks = List<Task>.from(tasks);
  }

  @override
  Future<void> seedIfEmpty(List<Task> seedTasks) async {
    if (_tasks.isEmpty) {
      _tasks = List<Task>.from(seedTasks);
    }
  }
}
