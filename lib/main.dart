import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; //Importamos la pantalla de Login
import 'package:firebase_core/firebase_core.dart';
import 'package:recordatorios_app/helpers/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  String? token = await FirebaseMessaging.instance.getToken();
  print("------------------------------------------");
  print("MI_TOKEN_DISPOSITIVO: $token");
  print("------------------------------------------");

  await FirebaseMessaging.instance.requestPermission(); //PERMISOS
  // ESCUCHAR MENSAJES EN FOREGROUND
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Mensaje recibido: ${message.notification?.title}');

    // Mostrar notificación
    NotificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: message.notification?.title ?? 'Sin título',
      body: message.notification?.body ?? 'Sin contenido',
    );
  });
  tz.initializeTimeZones();
  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginScreen(), //Usaremos el login como principal
    );
  }
}
