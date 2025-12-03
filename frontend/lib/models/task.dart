import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime dateTime;

  @HiveField(2)
  String status; // 'pending', 'in_progress', 'completed'

  @HiveField(3)
  String category;

  @HiveField(4)
  String priority; // 'low', 'medium', 'high'

  Task({
    required this.title,
    required this.dateTime,
    this.status = 'pending',
    this.category = 'Personal',
    this.priority = 'medium',
  });

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';

  void markAsCompleted() {
    status = 'completed';
    save();
  }

  void markAsInProgress() {
    status = 'in_progress';
    save();
  }

  void markAsPending() {
    status = 'pending';
    save();
  }
}
