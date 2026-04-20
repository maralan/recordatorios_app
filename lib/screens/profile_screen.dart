import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Access the current authenticated user session
    final user = FirebaseAuth.instance.currentUser;

    // Safety check: if the session is lost, display a placeholder
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Sesión finalizada")),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        // One-time fetch of the user's document from the 'users' collection
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          // Synchronize the controller with the data fetched from Firestore
          nameController.text = data?['displayName'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // AVATAR - Static icon for user representation
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.deepPurple,
                  child: const Icon(Icons.person, size: 50, color: Colors.white),
                ),

                const SizedBox(height: 15),

                Text(
                  nameController.text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  data?['email'] ?? '',
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 30),

                // EDIT - Text field to modify user's display name
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Nombre",
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // SAVE BUTTON - Performs an update operation on the user document
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      backgroundColor: Colors.deepPurple,
                    ),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .update({
                        'displayName': nameController.text,
                      });

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Perfil actualizado")),
                        );
                      }
                    },
                    child: const Text("Guardar cambios"),
                  ),
                ),

                const SizedBox(height: 20),

                // LOGOUT - Clears session and resets the navigation stack
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.orange),
                  title: const Text("Cerrar sesión"),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();

                    if (!mounted) return;

                    // pushAndRemoveUntil ensures the user cannot go back to the profile after logout
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),

                // DELETE - Removes user data and deletes the Auth account
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text("Eliminar cuenta"),
                  onTap: () async {
                    // Remove the record from Firestore database
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .delete();

                    // Remove the user from Firebase Authentication
                    await user.delete();

                    if (!mounted) return;

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}