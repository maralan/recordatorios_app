import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../helpers/services/firestore_service.dart';
import 'package:recordatorios_app/models/note_models.dart';

class NoteScreen extends StatefulWidget {
  final NoteModel? note; //parametros
  const NoteScreen({super.key, this.note}); //contructor

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  //el initSaate se encaarga de rellenar los campos si vamos editar 
  @override
  void initState() {
    super.initState();
    if (widget.note != null) { //Si 'widget.note' no es nulo, significa que venimos de la pantalla anterior con datos
      titleController.text = widget.note!.title;
      contentController.text = widget.note!.content;
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Nueva Nota' : 'Editar Nota'), //Cambiamos el titulo si es editar o crear
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) => (value == null || value.isEmpty) ? 'Ingresa un titulo' : null,
              ),

              const SizedBox(height: 20),
              TextFormField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Contenido',
                ),
                maxLines: 4,
                validator: (value) => (value == null || value.isEmpty) ? 'Ingresa contenido' : null,
              ),
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                height: 55, // Altura fija para mejor presencia
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final user = FirebaseAuth.instance.currentUser;

                      if (widget.note == null) { //Usaremos el condicional para determinar si e creara o editara
                        final newNote = NoteModel( //Creara un anota
                          id: '',
                          title: titleController.text,
                          content: contentController.text,
                          pinned: false,
                          createdAt: DateTime.now(),
                        );
                        await _firestoreService.createNote(newNote, user!.uid);
                      } else { //editara una nota
                        final updatedNote = NoteModel(
                          id: widget.note!.id,
                          title: titleController.text,
                          content: contentController.text,
                          pinned: widget.note!.pinned,
                          createdAt: widget.note!.createdAt,
                        );
                        await _firestoreService.updateNote(user!.uid, updatedNote);
                      }

                      if (mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  // Implementamos un icono dinammico
                  icon: Icon(
                    widget.note == null ? Icons.save : Icons.edit,
                  ),
                  label: Text(
                    widget.note == null ? 'Guardar Nota' : 'Actualizar Nota',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  // Estilo del boton
                  style: ElevatedButton.styleFrom(
                    // Aquí puedes usar Colors.deepPurple como en tu ejemplo 
                    // o el cambio de color dinámico que vimos antes:
                    backgroundColor: widget.note == null ? Colors.deepPurple : Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}