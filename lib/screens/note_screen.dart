import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../helpers/services/firestore_service.dart';
import 'package:recordatorios_app/models/note_models.dart';

class NoteScreen extends StatefulWidget {
  final NoteModel? note;
  // If a note is passed, the screen enters "Edit Mode"
  const NoteScreen({super.key, this.note});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    // Pre-fill controllers if editing an existing note
    if (widget.note != null) {
      titleController.text = widget.note!.title;
      contentController.text = widget.note!.content;
    }
  }

  // Handles both Create and Update operations in Firestore
  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Map the current input data to the NoteModel
      final note = NoteModel(
        id: widget.note?.id ?? '',
        title: titleController.text,
        content: contentController.text,
        pinned: widget.note?.pinned ?? false,
        createdAt: widget.note?.createdAt ?? DateTime.now(),
      );

      // Logical switch: update if ID exists, otherwise create new entry
      if (widget.note == null) {
        await _firestoreService.createNote(note, user.uid);
      } else {
        await _firestoreService.updateNote(user.uid, note);
      }

      // Return to the previous screen after a successful operation
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic styling based on the current app theme brightness
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Editar Nota" : "Nueva Nota"),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveNote,
        icon: const Icon(Icons.save),
        label: Text(isEditing ? "Actualizar" : "Guardar"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Title Input Field
              TextFormField(
                controller: titleController,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: "Título",
                  filled: true,
                  fillColor: isDark ? Colors.grey[900] : Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) => v!.isEmpty ? "Ingresa título" : null,
              ),

              const SizedBox(height: 20),

              // Content Input Field - Expands to fill available vertical space
              Expanded(
                child: TextFormField(
                  controller: contentController,
                  maxLines: null, // Allows for unlimited line breaks
                  expands: true,
                  decoration: InputDecoration(
                    hintText: "Escribe tu nota...",
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? "Escribe algo" : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}