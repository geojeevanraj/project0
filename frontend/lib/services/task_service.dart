import 'package:hive/hive.dart';
import '../models/task.dart';

class TaskService {
  static const String _boxName = 'tasks';

  // Get the tasks box
  Box<Task> get _box => Hive.box<Task>(_boxName);

  // Add a new task
  Future<void> addTask(Task task) async {
    await _box.add(task);
  }

  // Get all tasks
  List<Task> getAllTasks() {
    return _box.values.toList();
  }

  // Get pending tasks
  List<Task> getPendingTasks() {
    return _box.values.where((task) => task.isPending).toList();
  }

  // Get in-progress tasks
  List<Task> getInProgressTasks() {
    return _box.values.where((task) => task.isInProgress).toList();
  }

  // Get completed tasks
  List<Task> getCompletedTasks() {
    return _box.values.where((task) => task.isCompleted).toList();
  }

  // Get tasks for today
  List<Task> getTodayTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _box.values.where((task) {
      return task.dateTime.isAfter(today) && task.dateTime.isBefore(tomorrow);
    }).toList();
  }

  // Update task status
  Future<void> updateTaskStatus(Task task, String status) async {
    task.status = status;
    await task.save();
  }

  // Delete a task
  Future<void> deleteTask(Task task) async {
    await task.delete();
  }

  // Get counts
  int getPendingCount() => getPendingTasks().length;
  int getInProgressCount() => getInProgressTasks().length;
  int getCompletedCount() => getCompletedTasks().length;

  // Clear all tasks (for testing)
  Future<void> clearAll() async {
    await _box.clear();
  }
}
