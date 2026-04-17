import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reminder_model.dart';
import '../helpers/services/firestore_service.dart';
import '../helpers/services/notification_service.dart';

class ReminderScreen extends StatefulWidget {
  final ReminderModel? reminder;

  const ReminderScreen({super.key, this.reminder});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  DateTime selectedDate = DateTime.now().add(const Duration(minutes: 1));

  final FirestoreService _firestoreService = FirestoreService();

  bool isEditing = false;

  @override
  void initState() {
    super.initState();

    if (widget.reminder != null) {
      isEditing = true;
      selectedDate = widget.reminder!.scheduledAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Recordatorio' : 'Nuevo Recordatorio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Fecha: $selectedDate"),

            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );

                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              child: const Text("Seleccionar fecha"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                if (isEditing) {
                  final updatedReminder = ReminderModel(
                    id: widget.reminder!.id,
                    scheduledAt: selectedDate,
                  );

                  await _firestoreService.updateReminder(
                    user!.uid,
                    updatedReminder,
                  );

                  await NotificationService.showNotification(
                    id: 1,
                    title: 'Recordatorio actualizado',
                    body: 'Se actualizó correctamente',
                  );
                } else {
                  final reminder = ReminderModel(
                    id: '',
                    scheduledAt: selectedDate,
                  );

                  await _firestoreService.createReminder(
                    reminder,
                    user!.uid,
                  );

                  await NotificationService.showNotification(
                    id: 2,
                    title: 'Recordatorio creado',
                    body: 'Se programó correctamente',
                  );

                  await NotificationService.scheduleNotification(
                    id: 3,
                    title: 'Recordatorio',
                    body: 'Tienes un recordatorio',
                    scheduledDate: selectedDate,
                  );
                }

                Navigator.pop(context);
              },
              child: Text(isEditing ? "Actualizar" : "Guardar"),
            ),
          ],
        ),
      ),
    );
  }
}