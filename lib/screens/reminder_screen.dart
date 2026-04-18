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
  // 1. Variables de estado para fecha y hora
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  
  final FirestoreService _firestoreService = FirestoreService();
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      isEditing = true;
      // Al editar, extraemos la fecha y la hora del objeto existente
      selectedDate = widget.reminder!.scheduledAt;
      selectedTime = TimeOfDay(
        hour: widget.reminder!.scheduledAt.hour,
        minute: widget.reminder!.scheduledAt.minute,
      );
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
            // Visualización de la selección actual
            Card(
              elevation: 0,
              color: Colors.deepPurple.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Text(
                      "Programado para:",
                      style: TextStyle(color: Colors.deepPurple.shade700),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year} a las ${selectedTime.format(context)}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // BOTÓN: SELECCIONAR FECHA
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
              title: const Text("Cambiar Fecha"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 15),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
            ),

            // BOTÓN: SELECCIONAR HORA
            ListTile(
              leading: const Icon(Icons.access_time, color: Colors.deepPurple),
              title: const Text("Cambiar Hora"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 15),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (picked != null) {
                  setState(() => selectedTime = picked);
                }
              },
            ),

            const Spacer(),

            // BOTÓN ACCIÓN (GUARDAR / ACTUALIZAR)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (user == null) return;

                  // --- PASO CRUCIAL: COMBINAR FECHA Y HORA ---
                  final scheduledDate = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );

                  // Validación simple: ¿La fecha es en el pasado?
                  if (scheduledDate.isBefore(DateTime.now())) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("La hora debe ser futura")),
                    );
                    return;
                  }

                  if (isEditing) {
                    final updatedReminder = ReminderModel(
                      id: widget.reminder!.id,
                      scheduledAt: scheduledDate,
                    );

                    await _firestoreService.updateReminder(user.uid, updatedReminder);
                    
                    await NotificationService.showNotification(
                      id: 1,
                      title: 'Recordatorio actualizado',
                      body: 'Se cambió para el ${selectedTime.format(context)}',
                    );
                  } else {
                    final reminder = ReminderModel(
                      id: '',
                      scheduledAt: scheduledDate,
                    );

                    await _firestoreService.createReminder(reminder, user.uid);

                    await NotificationService.showNotification(
                      id: 2,
                      title: 'Recordatorio creado',
                      body: 'Programado con éxito',
                    );
                  }

                  // Programar/Reprogramar la notificación real
                  await NotificationService.scheduleNotification(
                    id: 3,
                    title: '¡Atención!',
                    body: 'Tienes un recordatorio pendiente',
                    scheduledDate: scheduledDate,
                  );

                  if (!mounted) return;
                  Navigator.pop(context);
                },
                child: Text(
                  isEditing ? "ACTUALIZAR" : "GUARDAR RECORDATORIO",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}