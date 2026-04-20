import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recordatorios_app/models/event_model.dart';
import 'package:recordatorios_app/models/note_models.dart';
import 'package:recordatorios_app/models/reminder_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

// --------------- CRUD FOR NOTES --------------------------

  // Adds a new note to the user's specific sub-collection
  Future<void> createNote(NoteModel note, String userId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .add(note.toMap());
  }

  // Retrieves notes ordered by priority (pinned) and creation date
  Stream<List<NoteModel>> getNotes(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .orderBy('pinned', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NoteModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Updates an existing note using its unique document ID
  Future<void> updateNote(String userId, NoteModel note) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(note.id)
        .update(note.toMap());
  }

  Future<void> deleteNote(String userId, String noteId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(noteId)
        .delete();
  }

// --------------- CRUD FOR EVENTS --------------------------

  // Creates an event and saves the generated document ID back into the record
  Future<void> createEvent(EventModel event, String userId) async {
    final doc = await _db
      .collection('users')
      .doc(userId)
      .collection('events')
      .add(event.toMap());
    await doc.update({'id': doc.id});
  }

  // Listens to real-time updates for events sorted by start date
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

  Future<void> updateEvent(
    String userId,
    String eventId,
    String title,
    String description,
    DateTime startDate,
    DateTime endDate,
  ) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(eventId)
        .update({
      'title': title,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
    });
  }

  Future<void> deleteEvent(String userId, String eventId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(eventId)
        .delete();
  }

// --------------- CRUD FOR REMINDERS --------------------------

  Future<void> createReminder(ReminderModel reminder, String userId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .add(reminder.toMap());
  }

  // Fetches the stream of reminders for a specific user
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

  Future<void> updateReminder(String userId,  ReminderModel reminder,) async {
  await _db
      .collection('users')
      .doc(userId)
      .collection('reminders')
      .doc(reminder.id)
      .update(reminder.toMap());
}

  Future<void> deleteReminder(String userId, String reminderId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .doc(reminderId)
        .delete();
  }
}