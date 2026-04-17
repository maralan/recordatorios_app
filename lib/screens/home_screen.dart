import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'note_screen.dart';
import 'package:recordatorios_app/helpers/services/firestore_service.dart';
import 'package:recordatorios_app/models/note_models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis notas'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<NoteModel>>(
        stream: firestoreService.getNotes(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay notas aún'),
            );
          }

          final notes = snapshot.data!;
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              
              final note = notes[index];

              return ListTile(
                title: Text(note.title),
                subtitle: Text(note.content, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () { //Se agrega el ONTAP para editar
                  Navigator.push(
                    context, 
                    MaterialPageRoute( //Pasamos la nota a la pantalla de edicion
                      builder: (context) =>NoteScreen(note: note),
                    ),
                  );
                },
                trailing: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(1), //Fondo rojo
                    shape: BoxShape.circle,
                  ), 
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red,),
                    onPressed: () async {
                      await firestoreService.deleteNote(user.uid, note.id);
                    },
                  ),
                ) 
              );
            }
          );
        },
      ),
      //Ingresamos boton para crear nota
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //ingresamos funcion para que vaje a la siguiente pantalla
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NoteScreen(),
            ),
          );
        },
        backgroundColor: Colors.deepPurple, //color defondo
        foregroundColor: Colors.white,
        elevation: 10, //Dar mas profundidad de sombra
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(15),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}