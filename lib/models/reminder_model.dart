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

  Map<String, dynamic> toMap() {
    return {
      'scheduledAt': scheduledAt,
      'eventId': eventId,
      'noteId': noteId,
    };
  }

  factory ReminderModel.fromMap(String id, Map<String, dynamic> map) {
    return ReminderModel(
      id: id,
      scheduledAt: map['scheduledAt'].toDate(),
      eventId: map['eventId'],
      noteId: map['noteId'],
    );
  }
}