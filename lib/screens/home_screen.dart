import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'note_screen.dart';
import 'event_screen.dart';
import 'package:recordatorios_app/helpers/services/firestore_service.dart';
import 'package:recordatorios_app/models/note_models.dart';
import 'package:recordatorios_app/models/event_model.dart';

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
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Recordatorios'),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            tabs: const [
              Tab(text: "Notas"),
              Tab(text: "Eventos"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildNotes(),
            _buildEvents(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (currentIndex == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NoteScreen()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EventScreen()),
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
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final notes = snapshot.data!;

        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (_, i) {
            final note = notes[i];

            return ListTile(
              title: Text(note.title),
              subtitle: Text(note.content),

              // EDITAR NOTA
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NoteScreen(note: note),
                  ),
                );
              },

              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () =>
                    firestoreService.deleteNote(user!.uid, note.id),
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
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final events = snapshot.data!;

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (_, i) {
            final event = events[i];

            return ListTile(
              title: Text(event.title),
              subtitle: Text(event.description),

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
                onPressed: () =>
                    firestoreService.deleteEvent(user!.uid, event.id),
              ),
            );
          },
        );
      },
    );
  }
}