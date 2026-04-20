import 'package:flutter/material.dart';
import 'package:recordatorios_app/utils/auth_wrapper.dart';
import 'screens/login_screen.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:recordatorios_app/helpers/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  // 1. Ensure Flutter framework is fully initialized before calling native code
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Initialize Firebase project connection
  await Firebase.initializeApp();

  // 3. Firebase Cloud Messaging (FCM) - Get Device Token for push notifications
  String? token = await FirebaseMessaging.instance.getToken();
  debugPrint("------------------------------------------");
  debugPrint("DEVICE_TOKEN: $token");
  debugPrint("------------------------------------------");

  // 4. Request OS permissions for notifications (required for iOS and Android 13+)
  await FirebaseMessaging.instance.requestPermission();
  
  // 5. Handle foreground push messages: trigger a local notification when data arrives
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Foreground Message received: ${message.notification?.title}');

    NotificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: message.notification?.title ?? 'Sin título',
      body: message.notification?.body ?? 'Sin contenido',
    );
  });
  
  // 6. Timezone initialization: critical for scheduling notifications at specific times
  tz.initializeTimeZones();
  
  // 7. Initialize local notification channel settings
  await NotificationService.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Primary seed color used to derive the entire application palette
    const seedColor = Colors.deepPurple;

    return MaterialApp(
      title: 'App Recordatorio',
      debugShowCheckedModeBanner: false,

      // --- LIGHT THEME CONFIGURATION ---
      theme: ThemeData(
        useMaterial3: true, // Enables latest Material design components
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), 
      ),

      // --- DARK THEME CONFIGURATION ---
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
          // Surface colors are automatically calculated for better readability
        ),
      ),

      // --- THEME MODE ---
      // Automatically switches between Light and Dark based on OS settings
      themeMode: ThemeMode.system, 
      
      // The application starts at AuthWrapper to determine if login is needed
      home: const AuthWrapper(),
    );
  }
}