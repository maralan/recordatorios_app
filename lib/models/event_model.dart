class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
  });

  // Converts the model instance into a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  // Creates a model instance from Firestore data and document ID
  factory EventModel.fromMap(String id, Map<String, dynamic> map) {
    return EventModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      // Converts Firestore Timestamps back to Dart DateTime objects
      startDate: map['startDate'].toDate(),
      endDate: map['endDate'].toDate(),
    );
  }
}