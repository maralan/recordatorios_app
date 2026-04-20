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

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();

    // If an event is passed, populate controllers for editing mode
    if (widget.event != null) {
      isEditing = true;
      titleController.text = widget.event!.title;
      descriptionController.text = widget.event!.description;
      selectedDate = widget.event!.startDate;
      selectedTime = TimeOfDay.fromDateTime(widget.event!.startDate);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // Opens the date picker and handles logic to prevent past date selection errors
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    // Safety check: initialDate must never be before firstDate
    final DateTime initialDatePickerDate = selectedDate.isBefore(today) ? today : selectedDate;
    final DateTime firstDatePickerDate = selectedDate.isBefore(today) ? selectedDate : today;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDatePickerDate,
      firstDate: firstDatePickerDate,
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Displays the time picker to set the event's hour and minute
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
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
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa un título';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 25),

                // Visual summary of the selected schedule
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Resumen de programación:",
                        style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year} a las ${selectedTime.format(context)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                    title: const Text("Fecha del evento"),
                    subtitle: Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                    trailing: const Icon(Icons.edit, size: 20),
                    onTap: () => _selectDate(context),
                  ),
                ),
                const SizedBox(height: 8),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.access_time, color: Colors.deepPurple),
                    title: const Text("Hora del evento"),
                    subtitle: Text(selectedTime.format(context)),
                    trailing: const Icon(Icons.edit, size: 20),
                    onTap: () => _selectTime(context),
                  ),
                ),

                const SizedBox(height: 40),

                // Save button with data validation and Firestore integration
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
                      if (_formKey.currentState!.validate()) {
                        
                        // Combines separate date and time selections into a single DateTime object
                        final fullDate = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );

                        // Prevents users from scheduling events in the past
                        if (fullDate.isBefore(DateTime.now())) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("¡Ups! No puedes programar un evento en el pasado."),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return; 
                        }

                        try {
                          if (isEditing) {
                            // Updates the event and triggers an immediate "update successful" notification
                            await _firestoreService.updateEvent(
                              user.uid,
                              widget.event!.id,
                              titleController.text,
                              descriptionController.text,
                              fullDate,
                              fullDate,
                            );

                            await NotificationService.showNotification(
                              id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                              title: 'Evento actualizado',
                              body: titleController.text,
                            );
                          } else {
                            // Creates new event record and schedules both immediate and delayed notifications
                            final event = EventModel(
                              id: '',
                              title: titleController.text,
                              description: descriptionController.text,
                              startDate: fullDate,
                              endDate: fullDate,
                            );

                            await _firestoreService.createEvent(event, user.uid);

                            await NotificationService.showNotification(
                              id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                              title: 'Evento creado',
                              body: titleController.text,
                            );

                            await NotificationService.scheduleNotification(
                              id: (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 1,
                              title: 'Recordatorio: ${titleController.text}',
                              body: 'Tu evento comienza ahora',
                              scheduledDate: fullDate,
                            );
                          }

                          if (!mounted) return;
                          Navigator.pop(context);
                          
                        } catch (e) {
                          debugPrint("Error en EventScreen: $e");
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error al guardar: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: Text(
                      isEditing ? 'ACTUALIZAR EVENTO' : 'GUARDAR EVENTO',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}