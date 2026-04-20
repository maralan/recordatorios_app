import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

import 'note_screen.dart';
import 'event_screen.dart';
import 'reminder_screen.dart';
import 'profile_screen.dart';
import 'home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Uses the theme's surface color for background consistency
    final backgroundColor = Theme.of(context).colorScheme.surface;

    final screens = [
      _dashboard(),
      const HomeScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        // Applies primary theme colors to the selected navigation item
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        onTap: (i) => setState(() => currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Datos"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }

  Widget _dashboard() {
    final user = FirebaseAuth.instance.currentUser;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        // Nested StreamBuilders to aggregate data counts from different collections
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .collection('notes')
              .snapshots(),
          builder: (context, notesSnap) {
            final notes = notesSnap.data?.docs.length ?? 0;

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('events')
                  .snapshots(),
              builder: (context, eventsSnap) {
                final events = eventsSnap.data?.docs.length ?? 0;

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('reminders')
                      .snapshots(),
                  builder: (context, remindersSnap) {
                    final reminders = remindersSnap.data?.docs.length ?? 0;
                    final total = notes + events + reminders;

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // DYNAMIC HEADER
                        // Fetches and displays the user's display name in real-time
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .snapshots(),
                          builder: (context, userSnap) {
                            String name = "Usuario";
                            if (userSnap.hasData && userSnap.data!.data() != null) {
                              final data = userSnap.data!.data() as Map<String, dynamic>;
                              name = data['displayName'] ?? "Usuario";
                            }

                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [colorScheme.primary, colorScheme.secondary],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: colorScheme.onPrimary,
                                    child: Icon(
                                      Icons.person,
                                      size: 35,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Bienvenido",
                                        style: TextStyle(
                                          color: colorScheme.onPrimary.withOpacity(0.8),
                                        ),
                                      ),
                                      Text(
                                        name,
                                        style: TextStyle(
                                          color: colorScheme.onPrimary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // KPIs
                        Row(
                          children: [
                            _kpi("Notas", notes, colorScheme.primary),
                            _kpi("Eventos", events, Colors.blueAccent),
                          ],
                        ),
                        Row(
                          children: [
                            _kpi("Recordatorios", reminders, Colors.orangeAccent),
                            _kpi("Total", total, Colors.greenAccent),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Text(
                          "Actividad",
                          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 10),

                        // Main chart displaying the distribution of items
                        SizedBox(
                          height: 220,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 3,
                              centerSpaceRadius: 40,
                              sections: [
                                _section(notes, total, colorScheme.primary),
                                _section(events, total, Colors.blueAccent),
                                _section(reminders, total, Colors.orangeAccent),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        _legend("Notas", colorScheme.primary),
                        _legend("Eventos", Colors.blueAccent),
                        _legend("Recordatorios", Colors.orangeAccent),

                        const SizedBox(height: 20),

                        // ACTIONS
                        _action("Nueva Nota", Icons.note_add, const NoteScreen()),
                        _action("Nuevo Evento", Icons.event, const EventScreen()),
                        _action("Nuevo Recordatorio", Icons.alarm, const ReminderScreen()),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Reusable widget to display a statistic card (KPI)
  Widget _kpi(String title, int value, Color accentColor) {
    return Expanded(
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Calculates percentage and creates a section for the Pie Chart
  PieChartSectionData _section(int value, int total, Color color) {
    final percent = total == 0 ? 0 : ((value / total) * 100).toStringAsFixed(1);
    return PieChartSectionData(
      value: value.toDouble(),
      color: color,
      radius: 55,
      title: "$percent%",
      titleStyle: const TextStyle(
        color: Colors.white, 
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _legend(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  // Helper widget to handle navigation to different creation screens
  Widget _action(String title, IconData icon, Widget screen) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        },
      ),
    );
  }
}