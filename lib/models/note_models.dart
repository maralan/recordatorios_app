import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final bool pinned;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    this.pinned = false,
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