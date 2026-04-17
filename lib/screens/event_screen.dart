import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';
import 'package:recordatorios_app/helpers/services/firestore_service.dart';
import 'package:recordatorios_app/helpers/services/notification_service.dart';

class EventScreen extends StatefulWidget {
  final EventModel? event;

  const EventScreen({super.key, this.event});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  bool isEditing = false;

  @override
  void initState() {
    super.initState();

    if (widget.event != null) {
      isEditing = true;
      titleController.text = widget.event!.title;
      descriptionController.text = widget.event!.description;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Usuario no autenticado")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Evento' : 'Nuevo Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa un titulo';
                  }
                  return null;
                }
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      if (isEditing) {
                        await _firestoreService.updateEvent(
                          user.uid,
                          widget.event!.id,
                          titleController.text,
                          descriptionController.text,
                        );
                        await NotificationService.showNotification( //notificacion
                          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                          title: 'Evento actualizado', 
                          body: titleController.text,
                        );
                      } else {
                        final event = EventModel(
                          id: '',
                          title: titleController.text,
                          description: descriptionController.text,
                          startDate: DateTime.now(),
                          endDate: DateTime.now(),
                        );

                        await _firestoreService.createEvent(event, user.uid);

                        await NotificationService.showNotification(
                          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                          title: 'Evento creado',
                          body: titleController.text,
                        );

                        await NotificationService.scheduleNotification(
                          id: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1, 
                          title: 'Recordatorio de evento', 
                          body: titleController.text, 
                          scheduledDate: DateTime.now().add(const Duration(seconds: 10))
                        );

                      }
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      print("Error real: $e");

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  }
                },
                child: Text(isEditing ? 'Actualizar' : 'Guardar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}