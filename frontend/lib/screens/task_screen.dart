import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_service.dart';

// Entry point for standalone testing
void main() {
  runApp(const TaskScreenApp());
}

class TaskScreenApp extends StatelessWidget {
  const TaskScreenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Liquid Glass Tasks',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      home: const TaskScreen(),
    );
  }
}

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ["All", "Pending", "In Progress", "Completed"];
  final TaskService _taskService = TaskService();

  List<Task> _getFilteredTasks() {
    switch (_selectedCategoryIndex) {
      case 1: // Pending
        return _taskService.getPendingTasks();
      case 2: // In Progress
        return _taskService.getInProgressTasks();
      case 3: // Completed
        return _taskService.getCompletedTasks();
      default: // All
        return _taskService.getAllTasks();
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.orangeAccent;
      case 'low':
        return Colors.greenAccent;
      default:
        return Colors.blueAccent;
    }
  }

  String _getDeadlineText(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) {
      if (difference.inHours > 0) {
        return 'In ${difference.inHours} hours';
      } else if (difference.inMinutes > 0) {
        return 'In ${difference.inMinutes} minutes';
      } else {
        return 'Due now';
      }
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays > 1) {
      return DateFormat('MMM dd').format(dateTime);
    } else {
      return 'Overdue';
    }
  }

  Future<void> _navigateToAddTask() async {
    final result = await Navigator.pushNamed(context, '/add-task');
    if (result == true) {
      setState(() {}); // Refresh the list
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Task>('tasks').listenable(),
        builder: (context, Box<Task> box, _) {
          final tasks = _getFilteredTasks();

          return Stack(
            children: [
              // 1. Shared Background Logic (Consistent with Home)
              _buildBackground(isDark),

              // 2. Main Content
              SafeArea(
                child: Column(
                  children: [
                    // --- AppBar ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      child: _buildCustomAppBar(isDark),
                    ),

                    // --- Category Chips ---
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedCategoryIndex == index;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategoryIndex = index),
                            child: _buildCategoryChip(_categories[index], isSelected, isDark),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // --- Task List ---
                    Expanded(
                      child: tasks.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.task_alt,
                                    size: 64,
                                    color: isDark ? Colors.white24 : Colors.black26,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No tasks yet',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: isDark ? Colors.white54 : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              physics: const BouncingScrollPhysics(),
                              itemCount: tasks.length,
                              itemBuilder: (context, index) {
                                final task = tasks[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildTaskCard(
                                    task: task,
                                    title: task.title,
                                    deadline: _getDeadlineText(task.dateTime),
                                    category: task.category,
                                    priorityColor: _getPriorityColor(task.priority),
                                    isDark: isDark,
                                    isCompleted: task.isCompleted,
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildLiquidVoiceFAB(isDark),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // --- Background (Reused for consistency) ---
  Widget _buildBackground(bool isDark) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]
                  : [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3)],
            ),
          ),
        ),
        Positioned(
          top: 100,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [Colors.purpleAccent.withOpacity(0.25), Colors.transparent]
                    : [Colors.blueAccent.withOpacity(0.3), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 200,
          right: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [Colors.tealAccent.withOpacity(0.2), Colors.transparent]
                    : [Colors.pinkAccent.withOpacity(0.25), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Components ---

  Widget _buildCustomAppBar(bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      borderRadius: 20,
      isDark: isDark,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.black12,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back, size: 20, color: isDark ? Colors.white : Colors.black87),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                "Tasks",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.search_rounded, color: isDark ? Colors.white70 : Colors.black54),
              const SizedBox(width: 20),
              Icon(Icons.filter_list_rounded, color: isDark ? Colors.white70 : Colors.black54),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, bool isDark) {
    // If selected, we use a solid gradient. If not, we use the Glass effect.
    if (isSelected) {
      return Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0072FF).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(right: 12),
        child: GlassContainer(
          borderRadius: 30,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          isDark: isDark,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildTaskCard({
    required Task task,
    required String title,
    required String deadline,
    required String category,
    required Color priorityColor,
    required bool isDark,
    required bool isCompleted,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      isDark: isDark,
      child: Row(
        children: [
          // Checkbox (Custom styled via Theme or manual container)
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: isCompleted,
              activeColor: Colors.greenAccent,
              side: BorderSide(
                color: isDark ? Colors.white54 : Colors.black45,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              onChanged: (val) {
                HapticFeedback.lightImpact();
                if (val == true) {
                  task.markAsCompleted();
                } else {
                  task.markAsPending();
                }
                setState(() {});
              },
            ),
          ),
          const SizedBox(width: 12),
          
          // Task Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Priority Dot
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: priorityColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: priorityColor.withOpacity(0.5),
                            blurRadius: 4,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      deadline,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text("•", style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 8),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidVoiceFAB(bool isDark) {
    return Container(
      height: 65,
      width: 65,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0072FF).withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: -5,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(35),
          onTap: () {
            HapticFeedback.mediumImpact();
            _navigateToAddTask();
          },
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}

// --- Reusable Glass Container (Same as Home Screen) ---
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final bool isDark;
  final double borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(0),
    required this.isDark,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: isDark 
                ? Colors.grey.shade900.withOpacity(0.3) 
                : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDark 
                  ? Colors.white.withOpacity(0.1) 
                  : Colors.white.withOpacity(0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}