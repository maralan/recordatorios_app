import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  // GlobalKey for form validation and state management
  final _formKey = GlobalKey<FormState>();

  // Text controllers to retrieve user input values
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Lifecycle method to release memory resources when the widget is destroyed
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        centerTitle: true,
      ),
      body: SingleChildScrollView( 
        // SingleChildScrollView prevents overflow errors when the keyboard appears
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form( 
            key: _formKey,
            // Validates fields as the user interacts with them
            autovalidateMode: AutovalidateMode.onUserInteraction, 
            child: Column(
              children: [
                const SizedBox(height: 40),

                const Text( 
                  'Crear cuenta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                // Email Input Field
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) { 
                    if (value == null || value.isEmpty) return 'Ingresa tu correo';
                    if (!value.contains('@')) return 'Correo inválido';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password Input Field
                TextFormField(
                  controller: passwordController,
                  obscureText: true, 
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) { 
                    if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
                    if (value.length < 8) return 'Mínimo 8 caracteres';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Confirm Password Input Field
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true, 
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) { 
                    if (value == null || value.isEmpty) return 'Confirma tu contraseña';
                    if (value != passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Register Action Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton( 
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) { 
                        try {
                          // 1. Create user in Firebase Authentication
                          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword( 
                            email: emailController.text.trim(), 
                            password: passwordController.text.trim(),
                          );
                          
                          // 2. Initialize user profile document in Firestore
                          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                            'uid': userCredential.user!.uid,
                            'email': emailController.text.trim(),
                            'displayName': 'Usuario Nuevo',
                            'displayImage': '',
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar( 
                            const SnackBar(content: Text('¡Registro exitoso en la nube!')),
                          );
                          
                          // Returns to the login screen
                          Navigator.pop(context); 

                        } on FirebaseAuthException catch (e) {
                          // Handling specific Firebase Auth exceptions
                          String mensaje = 'Error al registrar'; 
                          if (e.code == 'email-already-in-use') mensaje = 'El correo ya está en uso';
                          if (e.code == 'invalid-email') mensaje = 'Correo inválido';
                          if (e.code == 'weak-password') mensaje = 'Contraseña muy débil';
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(mensaje))
                          );
                        } catch (e) {
                          debugPrint(e.toString()); 
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, 
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Registrarse'),
                  ),
                ),

                const SizedBox(height: 20),

                // Navigation back to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Ya tienes cuenta?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); 
                      },
                      child: const Text('Inicia sesión'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}