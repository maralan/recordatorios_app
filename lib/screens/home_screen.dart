import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'note_screen.dart';
import 'event_screen.dart';
import 'reminder_screen.dart';
import 'profile_screen.dart';
import 'package:recordatorios_app/helpers/services/firestore_service.dart';
import 'package:recordatorios_app/models/note_models.dart';
import 'package:recordatorios_app/models/event_model.dart';
import 'package:recordatorios_app/models/reminder_model.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Keeps track of the current tab to navigate to the correct creation screen
  int currentIndex = 0;
  final user = FirebaseAuth.instance.currentUser;
  final firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          elevation: 0,
          title: Text(
            'Mis Recordatorios',
            style: TextStyle(color: colorScheme.onPrimary),
          ),
          actions: [
            IconButton(
              icon: CircleAvatar(
                backgroundColor: colorScheme.onPrimary,
                child: Icon(Icons.person, color: colorScheme.primary),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
          ],
          bottom: TabBar(
            // Updates currentIndex when a tab is tapped to sync with the FAB logic
            onTap: (index) => setState(() => currentIndex = index),
            labelColor: colorScheme.onPrimary,
            unselectedLabelColor: colorScheme.onPrimary.withOpacity(0.6),
            indicatorColor: colorScheme.onPrimary,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: "Notas"),
              Tab(text: "Eventos"),
              Tab(text: "Alertas"),
            ],
          ),
        ),
        body: TabBarView(
          // Each child is a stream-backed list for real-time updates
          children: [
            _buildNotes(),
            _buildEvents(),
            _buildReminders(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          icon: const Icon(Icons.add),
          label: const Text(
            "Crear",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            // Determines which screen to push based on the active tab
            final routes = [const NoteScreen(), const EventScreen(), const ReminderScreen()];
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => routes[currentIndex]),
            );
          },
        ),
      ),
    );
  }

  // Builds the list of notes using a Firestore stream
  Widget _buildNotes() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return StreamBuilder<List<NoteModel>>(
      stream: firestoreService.getNotes(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final notes = snapshot.data ?? [];
        if (notes.isEmpty) return const Center(child: Text("No hay notas"));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: notes.length,
          itemBuilder: (_, i) {
            final note = notes[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NoteScreen(note: note))),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(
                        note.pinned ? Icons.push_pin : Icons.note_alt_outlined,
                        color: note.pinned ? Colors.orange : colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              note.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.push_pin, color: note.pinned ? Colors.orange : colorScheme.outline),
                            onPressed: () => firestoreService.updateNote(user!.uid, note.copyWith(pinned: !note.pinned)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => firestoreService.deleteNote(user!.uid, note.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Builds the list of events with formatted dates
  Widget _buildEvents() {
    return StreamBuilder<List<EventModel>>(
      stream: firestoreService.getEvents(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final events = snapshot.data ?? [];
        if (events.isEmpty) return const Center(child: Text("No hay eventos"));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: events.length,
          itemBuilder: (_, i) {
            final event = events[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: Icon(Icons.event, color: Theme.of(context).colorScheme.primary),
                title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${event.description}\n📅 ${DateFormat('dd/MM/yyyy – HH:mm').format(event.startDate)}"),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventScreen(event: event))),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => firestoreService.deleteEvent(user!.uid, event.id),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Builds the list of stand-alone reminders/alerts
  Widget _buildReminders() {
    return StreamBuilder<List<ReminderModel>>(
      stream: firestoreService.getReminders(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final reminders = snapshot.data ?? [];
        if (reminders.isEmpty) return const Center(child: Text("No hay recordatorios"));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: reminders.length,
          itemBuilder: (_, i) {
            final reminder = reminders[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: Icon(Icons.alarm, color: Theme.of(context).colorScheme.primary),
                title: const Text("Recordatorio", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(DateFormat('dd/MM/yyyy - HH:mm').format(reminder.scheduledAt)),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReminderScreen(reminder: reminder))),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => firestoreService.deleteReminder(user!.uid, reminder.id),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Local helper to enable immutable state updates for the pinned status
extension on NoteModel {
  NoteModel copyWith({bool? pinned}) {
    return NoteModel(
      id: id,
      title: title,
      content: content,
      pinned: pinned ?? this.pinned,
      createdAt: createdAt,
    );
  }
}