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

  @override
  void initState() {
    super.initState();

    if (widget.event != null) {
      isEditing = true;
      titleController.text = widget.event!.title;
      descriptionController.text = widget.event!.description;
      selectedDate = widget.event!.startDate;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  //FUNCION PARA MOSTRAR EL CALENDARIO
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    // Normalizacion a solo fecha (sin horas/minutos) para comparar
    final DateTime today = DateTime(now.year, now.month, now.day);

    //Seguridad: initialDate  nunca puede ser menor a firstDate
    //Si la fecha del evento ya paso, el calendario se abre en hoy
    final DateTime initialDatePickerDate = selectedDate.isBefore(today)
      ? today
      : selectedDate;

    //Permitimos que el calendario retroceda hasta la fecha del evento
    //Si esta es antigua, para que no truene la aserción.
    final DateTime firstDatePickerDate = selectedDate.isBefore(today)
      ? selectedDate
      : today;

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
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
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
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Fecha: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _selectDate(context), 
                      icon: const Icon(Icons.calendar_today),
                      label: const Text("cambiar"),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          if (isEditing) {
                            // --- ACTUALIZAR EVENTO ---
                            await _firestoreService.updateEvent(
                              user.uid,
                              widget.event!.id,
                              titleController.text,
                              descriptionController.text,
                              selectedDate,
                              selectedDate,
                            );

                            await NotificationService.showNotification(
                              id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                              title: 'Evento actualizado',
                              body: titleController.text,
                            );
                          } else {
                            // --- CREAR NUEVO EVENTO ---
                            final event = EventModel(
                              id: '',
                              title: titleController.text,
                              description: descriptionController.text,
                              startDate: selectedDate,
                              endDate: selectedDate,
                            );

                            await _firestoreService.createEvent(event, user.uid);

                            // Notificación inmediata
                            await NotificationService.showNotification(
                              id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                              title: 'Evento creado',
                              body: titleController.text,
                            );

                            // Notificación programada para la fecha elegida
                            await NotificationService.scheduleNotification(
                              id: (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 1,
                              title: 'Recordatorio de evento: ${titleController.text}',
                              body: titleController.text,
                              scheduledDate: selectedDate,
                            );
                          }

                          // --- VOLVER AL HOME ---
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
                      isEditing ? 'ACTUALIZAR' : 'GUARDAR',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            )
          )
        ),
      ),
    );
  }
}