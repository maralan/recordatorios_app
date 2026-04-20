class ReminderModel {
  final String id;
  final DateTime scheduledAt;
  final String? eventId;
  final String? noteId;

  ReminderModel({
    required this.id,
    required this.scheduledAt,
    this.eventId,
    this.noteId,
  });

  // Prepares the reminder data to be saved in the database
  Map<String, dynamic> toMap() {
    return {
      'scheduledAt': scheduledAt,
      'eventId': eventId,
      'noteId': noteId,
    };
  }

  // Reconstructs the reminder object from a database Map and document ID
  factory ReminderModel.fromMap(String id, Map<String, dynamic> map) {
    return ReminderModel(
      id: id,
      // Converts the database timestamp back to a DateTime object
      scheduledAt: map['scheduledAt'].toDate(),
      eventId: map['eventId'],
      noteId: map['noteId'],
    );
  }
}