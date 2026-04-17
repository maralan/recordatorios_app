import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recordatorios_app/models/event_model.dart';
import 'package:recordatorios_app/models/note_models.dart';
import 'package:recordatorios_app/models/reminder_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

// --------------- CRUD PARA NOTAS --------------------------
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

  // --------------- CRUD PARA EVENTOS --------------------------
  //crear evento
  Future<void> createEvent(EventModel event, String userId) async {
    final doc = await _db
      .collection('users')
      .doc(userId)
      .collection('events')
      .add(event.toMap());
    await doc.update({'id': doc.id});
  }

  // obtener datos de evento
  Stream<List<EventModel>> getEvents(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('events')
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  //Actualiza evento
  Future<void> updateEvent(
    String userId,
    String eventId,
    String title,
    String description,
  ) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(eventId)
        .update({
      'title': title,
      'description': description,
    });
  }

  // eliminar evento
  Future<void> deleteEvent(String userId, String eventId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(eventId)
        .delete();
  }

  // --------------- CRUD PARA RECORDATORIO --------------------------
  // CREAR RECORDATORIO
  Future<void> createReminder(ReminderModel reminder, String userId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .add(reminder.toMap());
  }

  // OBTENER RECORDATORIOS
  Stream<List<ReminderModel>> getReminders(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReminderModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  //ACTUALIZAR RECORATORIO
  Future<void> updateReminder(String userId,  ReminderModel reminder,) async {
  await _db
      .collection('users')
      .doc(userId)
      .collection('reminders')
      .doc(reminder.id)
      .update(reminder.toMap());
}

  // ELIMINAR
  Future<void> deleteReminder(String userId, String reminderId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .doc(reminderId)
        .delete();
  }
}