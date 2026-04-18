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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final user = FirebaseAuth.instance.currentUser;
  final firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Recordatorios'),
          actions: [ //Boton de Perfilde usuario
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              }
            )
          ],
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            tabs: const [
              Tab(text: "Notas"),
              Tab(text: "Eventos"),
              Tab(text: "Recordatorio"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildNotes(),
            _buildEvents(),
            _buildReminders(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (currentIndex == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NoteScreen()),
              );
            } else if (currentIndex == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EventScreen()),
              );
            } else {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const ReminderScreen()),
                
              );
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildNotes() {
    return StreamBuilder<List<NoteModel>>(
      stream: firestoreService.getNotes(user!.uid),
      builder: (context, snapshot) {

        //loading real
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        //error
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final notes = snapshot.data ?? [];

        if (notes.isEmpty) {
          return const Center(child: Text("No hay notas"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: notes.length,
          itemBuilder: (_, i) {
            final note = notes[i];

            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  note.pinned ? Icons.push_pin : Icons.note,
                  color: note.pinned ? Colors.orange : Colors.deepPurple,
                ),

                title: Text(
                  note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                subtitle: Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // EDITAR
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NoteScreen(note: note),
                    ),
                  );
                },

                // BOTONES
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // PIN
                    IconButton(
                      icon: Icon(
                        note.pinned
                            ? Icons.push_pin
                            : Icons.push_pin_outlined,
                        color: Colors.orange,
                      ),
                      onPressed: () {
                        firestoreService.updateNote(
                          user!.uid,
                          NoteModel(
                            id: note.id,
                            title: note.title,
                            content: note.content,
                            pinned: !note.pinned,
                            createdAt: note.createdAt,
                          ),
                        );
                      },
                    ),

                    // ELIMINAR
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        firestoreService.deleteNote(user!.uid, note.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEvents() {
    return StreamBuilder<List<EventModel>>(
      stream: firestoreService.getEvents(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator());
        } 

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return const Center(child: Text("No hay eventos"));
        }

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (_, i) {
            final event = events[i];

            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                leading: const Icon(Icons.event, color: Colors.deepPurple),
                title: Text(event.title),
                subtitle: Text(
                  "${event.description}\nFecha: ${event.startDate.toLocal()}",
                ),

                // EDITAR EVENTO
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventScreen(event: event),
                    ),
                  );
                },

                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => {
                      firestoreService.deleteEvent(user!.uid, event.id),
                  },
                ),
              ),
            ); 
          },
        );
      },
    );
  }

  // RECORDATORIOS
  Widget _buildReminders() {
    return StreamBuilder<List<ReminderModel>>(
      stream: firestoreService.getReminders(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final reminders = snapshot.data ?? [];

        if (reminders.isEmpty) {
          return const Center(child: Text("No hay recordatorios"));
        }

        return ListView.builder(
          itemCount: reminders.length,
          itemBuilder: (_, i) {
            final reminder = reminders[i];

            return Card(
              margin:const EdgeInsets.all(10),
              child: ListTile(
                leading: const Icon(Icons.alarm, color: Colors.deepPurple),
                title: const Text("Recordatorio"),
                subtitle: Text(reminder.scheduledAt.toString()),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReminderScreen(reminder: reminder),
                    ),
                  );
                },

                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    firestoreService.deleteReminder(
                      user!.uid,
                      reminder.id,
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}