import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Entry point for standalone testing
void main() {
  runApp(const ReminderScreenApp());
}

class ReminderScreenApp extends StatelessWidget {
  const ReminderScreenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Liquid Glass Reminders',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const ReminderScreen(),
    );
  }
}

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  bool _isPastRemindersExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          // 1. Shared Background Logic
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

                const SizedBox(height: 10),

                // --- Reminders List ---
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Section Title
                      _buildSectionHeader("Upcoming", isDark),
                      const SizedBox(height: 12),

                      // Upcoming Reminders
                      _buildReminderCard(
                        title: "Call John",
                        time: "6:00 PM",
                        date: "Today",
                        icon: Icons.phone_in_talk_rounded,
                        color: Colors.blueAccent,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildReminderCard(
                        title: "Take Vitamin D",
                        time: "8:00 AM",
                        date: "Tomorrow",
                        icon: Icons.medication_rounded,
                        color: Colors.orangeAccent,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildReminderCard(
                        title: "Team Meeting",
                        time: "10:30 AM",
                        date: "Wed, Oct 24",
                        icon: Icons.video_camera_front_rounded,
                        color: Colors.purpleAccent,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 32),

                      // Past Reminders Section (Collapsible-ish feel)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isPastRemindersExpanded = !_isPastRemindersExpanded;
                          });
                        },
                        child: Row(
                          children: [
                            _buildSectionHeader("Past Reminders", isDark),
                            const SizedBox(width: 8),
                            Icon(
                              _isPastRemindersExpanded 
                                ? Icons.keyboard_arrow_up_rounded 
                                : Icons.keyboard_arrow_down_rounded,
                              color: isDark ? Colors.white54 : Colors.black45,
                            )
                          ],
                        ),
                      ),
                      
                      if (_isPastRemindersExpanded) ...[
                        const SizedBox(height: 12),
                        _buildPastReminderItem("Pay electricity bill", "Yesterday", isDark),
                        const SizedBox(height: 12),
                        _buildPastReminderItem("Submit Assignment", "Mon, Oct 22", isDark),
                        const SizedBox(height: 12),
                        _buildPastReminderItem("Dentist Appointment", "Oct 15", isDark),
                      ],

                      // Extra space for FAB
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildLiquidAddButton(isDark),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // --- Background ---
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
        // Blob 1
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [Colors.indigoAccent.withOpacity(0.3), Colors.transparent]
                    : [Colors.cyanAccent.withOpacity(0.4), Colors.transparent],
              ),
            ),
          ),
        ),
        // Blob 2
        Positioned(
          bottom: 100,
          left: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [Colors.deepPurpleAccent.withOpacity(0.2), Colors.transparent]
                    : [Colors.orangeAccent.withOpacity(0.2), Colors.transparent],
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
                onTap: () {
                   // Handle back navigation
                },
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
                "Reminders",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          Icon(Icons.more_vert_rounded, color: isDark ? Colors.white70 : Colors.black54),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
        color: isDark ? Colors.white54 : Colors.black45,
      ),
    );
  }

  Widget _buildReminderCard({
    required String title,
    required String time,
    required String date,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      isDark: isDark,
      child: Row(
        children: [
          // Icon Box
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.5), width: 1),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          
          // Details
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
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text("•", style: TextStyle(color: isDark ? Colors.white24 : Colors.black26)),
                    const SizedBox(width: 6),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Bell Icon (Active)
          Icon(
            Icons.notifications_active_rounded, 
            color: isDark ? Colors.white24 : Colors.black26,
            size: 20
          ),
        ],
      ),
    );
  }

  Widget _buildPastReminderItem(String title, String date, bool isDark) {
    return GlassContainer(
      // Less padding and no background opacity to make it look "faded" or "past"
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      isDark: isDark,
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 20, color: isDark ? Colors.white38 : Colors.black38),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                decoration: TextDecoration.lineThrough,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ),
          Text(
            date,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white30 : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidAddButton(bool isDark) {
    return Container(
      height: 65,
      width: 65,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF512F), Color(0xFFDD2476)], // Different gradient for Reminders (Red/Pink)
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDD2476).withOpacity(0.4),
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
            // Add Reminder Action
          },
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 32,
          ),
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