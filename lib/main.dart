import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; //Importamos la pantalla de Login
import 'package:firebase_core/firebase_core.dart';
import 'package:recordatorios_app/helpers/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
