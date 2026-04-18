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
    // Detectamos si estamos editando para precargar la fecha
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
            Text(
              "Fecha seleccionada:\n$selectedDate",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
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
              icon: const Icon(Icons.calendar_today),
              label: const Text("Seleccionar fecha"),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  // Validar que el usuario esté logueado
                  if (user == null) return;

                  if (isEditing) {
                    // --- LÓGICA PARA ACTUALIZAR ---
                    final updatedReminder = ReminderModel(
                      id: widget.reminder!.id,
                      scheduledAt: selectedDate,
                    );

                    await _firestoreService.updateReminder(
                      user.uid,
                      updatedReminder,
                    );

                    await NotificationService.showNotification(
                      id: 1,
                      title: 'Recordatorio actualizado',
                      body: 'Se actualizó correctamente',
                    );
                  } else {
                    // --- LÓGICA PARA CREAR NUEVO ---
                    final reminder = ReminderModel(
                      id: '',
                      scheduledAt: selectedDate,
                    );

                    await _firestoreService.createReminder(
                      reminder,
                      user.uid,
                    );

                    await NotificationService.showNotification(
                      id: 2,
                      title: 'Recordatorio creado',
                      body: 'Se programó correctamente',
                    );

                    // Programar la notificación futura
                    await NotificationService.scheduleNotification(
                      id: 3,
                      title: '¡Atención!',
                      body: 'Tienes un recordatorio pendiente',
                      scheduledDate: selectedDate,
                    );
                  }

                  // Se ejecuta tanto para "isEditing" como para el "else"
                  if (!mounted) return;
                  Navigator.pop(context);
                },
                child: Text(
                  isEditing ? "ACTUALIZAR" : "GUARDAR",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}