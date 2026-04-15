import 'package:flutter/material.dart';

// Esta clase representa la pantalla de LOGIN
// Extiende de StatelessWidget, lo que significa que no maneja estados dinamicos
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Scaffold es la estructura base de la pantalla (layout principal)
      appBar: AppBar( // Barra superior con el titulo
        title: const Text('Login'),
        centerTitle: true, // Centra el título
      ),
      body: SingleChildScrollView( // Permite hacer scroll si el teclado tapa elementos
        child: Padding( // Padding agrega espacio alrededor de todo el contenido
          padding: const EdgeInsets.all(20.0),
          child: Column( // Column organiza los elementos de forma vertical
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text( // Título principal
                'Bienvenido',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Inicia sesión para continuar',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              TextField( // Campo de texto para el correo
                decoration: InputDecoration(
                  labelText: 'Correo', // Texto guia dentro del campo
                  prefixIcon: Icon(Icons.email), // Icono
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Bordes redondeados
                  ),
                ),
              ),
              const SizedBox(height: 16), // Espacio entre campos
              TextField( // Campo de texto para la contraseña
                obscureText: true, // Oculta el texto (modo contraseña)
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align( // Texto opcional (ej: recuperar contraseña)
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ),
              const SizedBox(height: 20), // Espacio antes del boton
              SizedBox( // Boton para inicio de sesion
                width: double.infinity, // Hace el botón ancho completo
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Aqui ira la logica para iniciar sesion
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row( // Texto inferior (registro)
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes cuenta?'),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Regístrate'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}