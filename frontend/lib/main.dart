import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/task_screen.dart';
import 'screens/reminder_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/completed_screen.dart';
import 'screens/add_task_screen.dart';
import 'models/task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(TaskAdapter());
  
  // Open boxes
  await Hive.openBox<Task>('tasks');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Liquid Glass UI',
      themeMode: ThemeMode.system, // Supports system theme (Dark/Light)
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF1A1A1A)),
          bodyMedium: TextStyle(color: Color(0xFF4A4A4A)),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      // Set the initial route
      home: const HomeScreen(),
      // Define named routes for navigation
      routes: {
        '/tasks': (context) => const TaskScreen(),
        '/reminders': (context) => const ReminderScreen(),
        '/schedule': (context) => const ScheduleScreen(),
        '/completed': (context) => const CompletedScreen(),
        '/add-task': (context) => const AddTaskScreen(),
      },
    );
  }
}