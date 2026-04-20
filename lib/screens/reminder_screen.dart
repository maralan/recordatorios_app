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
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  
  final FirestoreService _firestoreService = FirestoreService();
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    // Check if we are editing an existing reminder to initialize the state
    if (widget.reminder != null) {
      isEditing = true;
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- UI: VISUAL STATUS CARD ---
            // Displays the current selection for date and time in a prominent way
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    "Programado para",
                    style: TextStyle(fontSize: 14, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}\n${selectedTime.format(context)}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- DATE PICKER TRIGGER ---
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                title: const Text("Cambiar Fecha"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 15),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(), // Prevents picking dates in the past
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
              ),
            ),

            // --- TIME PICKER TRIGGER ---
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
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
            ),

            const Spacer(),

            // --- SAVE / UPDATE ACTION ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white, 
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (user == null) return;

                  // Combine selected date and time into a single DateTime object
                  final scheduledDate = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );

                  // VALIDATION: Ensure the scheduled time is at least 5 seconds in the future
                  if (scheduledDate.isBefore(DateTime.now().add(const Duration(seconds: 5)))) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Error: La hora debe ser futura"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  // Generate a unique ID for the notification based on current timestamp
                  int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

                  try {
                    if (isEditing) {
                      final updatedReminder = ReminderModel(
                        id: widget.reminder!.id,
                        scheduledAt: scheduledDate,
                      );
                      await _firestoreService.updateReminder(user.uid, updatedReminder);
                    } else {
                      final reminder = ReminderModel(
                        id: '',
                        scheduledAt: scheduledDate,
                      );
                      await _firestoreService.createReminder(reminder, user.uid);
                    }

                    // --- NOTIFICATIONS FLOW ---
                    
                    // 1. Instant Confirmation: Notify the user that the action was successful
                    await NotificationService.showNotification(
                      id: 999,
                      title: '¡Guardado con éxito!',
                      body: 'Tu recordatorio ha sido programado.',
                    );

                    // 2. Scheduled Alert: Trigger the actual reminder at the chosen time
                    await NotificationService.scheduleNotification(
                      id: notificationId,
                      title: '¡Recordatorio!',
                      body: 'Es hora de tu actividad programada.',
                      scheduledDate: scheduledDate,
                    );

                    if (!mounted) return;
                    Navigator.pop(context); 
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error al guardar: $e")),
                    );
                  }
                },
                child: Text(
                  isEditing ? "ACTUALIZAR RECORDATORIO" : "GUARDAR RECORDATORIO",
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