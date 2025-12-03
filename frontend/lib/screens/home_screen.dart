import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../services/task_service.dart';

// Entry point to run the app standalone for preview purposes
void main() {
  runApp(const LiquidGlassApp());
}

class LiquidGlassApp extends StatelessWidget {
  const LiquidGlassApp({super.key});

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
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Size size = MediaQuery.of(context).size;
    final taskService = TaskService();

    return Scaffold(
      // Important: Transparent scaffold to show the background blobs
      backgroundColor: Colors.transparent, 
      extendBody: true,
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Task>('tasks').listenable(),
        builder: (context, Box<Task> box, _) {
          final pendingCount = taskService.getPendingCount();
          final inProgressCount = taskService.getInProgressCount();
          final completedCount = taskService.getCompletedCount();
          final todayTasksCount = taskService.getTodayTasks().where((t) => !t.isCompleted).length;

          return Stack(
            children: [
              // 1. Dynamic Background (Gradients & Blobs)
              _buildBackground(isDark, size),

              // 2. Main Content
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Custom AppBar ---
                      _buildCustomAppBar(isDark),
                      const SizedBox(height: 24),

                      // --- Greeting ---
                      Text(
                        "Good Morning,\nAlex",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Summary Cards ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryCard("Pending", "$pendingCount", Colors.orange, isDark, size.width),
                          _buildSummaryCard("In Progress", "$inProgressCount", Colors.blue, isDark, size.width),
                          _buildSummaryCard("Done", "$completedCount", Colors.green, isDark, size.width),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // --- AI Suggestion Card ---
                      _buildAISuggestionCard(isDark),
                      const SizedBox(height: 24),

                      // --- Navigation Tiles ---
                      Text(
                        "Overview",
                        style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Grid Layout for Tiles
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildNavTile(context, Icons.task_alt_rounded, "Tasks", "$todayTasksCount due today", isDark, '/tasks'),
                      _buildNavTile(context, Icons.notifications_none_rounded, "Reminders", "No new alerts", isDark, '/reminders'),
                      _buildNavTile(context, Icons.calendar_today_rounded, "Schedule", "3 meetings", isDark, '/schedule'),
                      _buildNavTile(context, Icons.check_circle_outline_rounded, "Completed", "$completedCount items", isDark, '/completed'),
                    ],
                  ),
                  
                  // Space for the floating button at bottom
                  const SizedBox(height: 100),
                ],
              ),
              ),
            ),
          ],
        );
        },
      ),
    );
  }

  // --- Background Builder ---
  Widget _buildBackground(bool isDark, Size size) {
    return Stack(
      children: [
        // Base Gradient
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
        // Abstract Blob 1
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [Colors.purpleAccent.withOpacity(0.3), Colors.transparent]
                    : [Colors.blueAccent.withOpacity(0.4), Colors.transparent],
              ),
            ),
          ),
        ),
        // Abstract Blob 2
        Positioned(
          bottom: 100,
          left: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [Colors.tealAccent.withOpacity(0.2), Colors.transparent]
                    : [Colors.pinkAccent.withOpacity(0.3), Colors.transparent],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 50,
      isDark: isDark,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.grid_view_rounded, color: isDark ? Colors.white : Colors.black87),
          Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: NetworkImage("https://i.pravatar.cc/150?img=11"), // Placeholder Avatar
                fit: BoxFit.cover,
              ),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, Color accentColor, bool isDark, double screenWidth) {
    return GlassContainer(
      width: (screenWidth - 48 - 24) / 3, // Calculate width based on padding
      padding: const EdgeInsets.all(16),
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 4,
              backgroundColor: accentColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISuggestionCard(bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      isDark: isDark,
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.purpleAccent, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AI Suggestion",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent.shade100,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "You usually exercise at 6 PM. Schedule a workout?",
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile(BuildContext context, IconData icon, String title, String subtitle, bool isDark, String route) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(context, route);
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 32, color: isDark ? Colors.white : Colors.black87),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// --- Reusable Glass Container ---
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
            // The "Glass" Color
            color: isDark 
                ? Colors.grey.shade900.withOpacity(0.3) 
                : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              // Subtle border gradient for 3D effect
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