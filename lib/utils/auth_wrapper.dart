import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recordatorios_app/screens/login_screen.dart';
import 'package:recordatorios_app/screens/dashboard_screen.dart';

/// AuthWrapper acts as a root navigator listener.
/// It automatically switches between Login and Dashboard screens 
/// based on the user's authentication state.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // The stream listens to real-time changes (Login, Logout, Account creation)
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // 1. Handling Connection State:
        // While Firebase is checking the persistence or initializing, show a loader.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Conditional Navigation:
        // snapshot.hasData is true if a valid 'User' object is present.
        if (snapshot.hasData) {
          // If the user is authenticated, redirect to the main app dashboard.
          return const DashboardScreen(); 
        } else {
          // If the user is not logged in or has logged out, redirect to the Login screen.
          return const LoginScreen(); 
        }
      },
    );
  }
}