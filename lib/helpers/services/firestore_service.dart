import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recordatorios_app/models/note_models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Crear nota
  Future<void> createNote(NoteModel note, String userId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .add(note.toMap());
  }

  // Obtener notas
  Stream<List<NoteModel>> getNotes(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NoteModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  //Actualizar notas
  Future<void> updateNote(String userId, NoteModel note) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(note.id)
        .update(note.toMap());
  }

  // Eliminar nota
  Future<void> deleteNote(String userId, String noteId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(noteId)
        .delete();
  }
}