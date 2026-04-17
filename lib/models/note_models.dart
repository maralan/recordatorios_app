import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  String id;
  String title;
  String content;
  bool pinned;
  DateTime createdAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.pinned,
    required this.createdAt,
  });

  // Convertir a mapa (para Firestore)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'pinned': pinned,
      'createdAt': createdAt,
    };
  }

  // Convertir desde Firestore
  factory NoteModel.fromMap(String id, Map<String, dynamic> map) {
    return NoteModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      pinned: map['pinned'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}