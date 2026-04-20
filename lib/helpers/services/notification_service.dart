import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // INIT
  static Future<void> init() async {
    // Configures the default icon for Android notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);

    // Mandatory channel setup for Android 8.0 (Oreo) and higher
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'reminder_channel',
      'Recordatorios',
      description: 'Canal de recordatorios',
      importance: Importance.max,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // NOTIFICACIÓN INMEDIATA
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    // Defines visual and sound priority for the notification
    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'reminder_channel',
        'Recordatorios',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _notifications.show(id, title, body, details);
  }

  // NOTIFICACIÓN PROGRAMADA (SIN ERRORES)
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final now = DateTime.now();

    // Validates that the notification is set for a future time
    if (scheduledDate.isBefore(now)) {
      print("ERROR: fecha pasada");
      return;
    }

    final delay = scheduledDate.difference(now);

    print("Se ejecutará en ${delay.inSeconds} segundos");

    // Executes the notification after the calculated time difference
    Future.delayed(delay, () async {
      await showNotification(
        id: id,
        title: title,
        body: body,
      );
    });
  }
}