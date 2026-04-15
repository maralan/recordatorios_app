import 'package:flutter/material.dart';

// Esta clase representa la pantalla de LOGIN
// Extiende de StatelessWidget, por que necesitamos maneja datos dinamicos
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen> {

  //Key del formulario para validar los campos
  final _formKey = GlobalKey<FormState>();

  //Controladores para obtener valores de los inputs
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
          child: Form( 
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction, //Forza  aqui se pueda ver los errores
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
                TextFormField( // Campo de texto para el correo
                  controller: emailController, //Se manda a traer el controller
                  decoration: InputDecoration(
                    labelText: 'Correo', // Texto guia dentro del campo
                    prefixIcon: Icon(Icons.email), // Icono
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), // Bordes redondeados
                    ),
                  ),
                  validator: (value) { //Validamos
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu correo';
                    } else if (!value.contains('@')) {
                      return 'Correo inválido';
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 16), // Espacio entre campos
                TextFormField( // Campo de texto para la contraseña
                controller: passwordController, //Mandamos a traer el controller
                  obscureText: true, // Oculta el texto (modo contraseña)
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) { //Validamos
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu contraseña';
                    }
                    if (value.length < 8) {
                      return 'Mínimo 8 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Align( // Campo (ej: olvide contraseña)
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
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Validación correcta'),
                          ),
                        );
                        //Aqui implementare el codigo o logica de Firebase Auth
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, //COLOR DE FONDO
                      foregroundColor: Colors.white, //Color del texto
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
                Row( // Campo de registro
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿No tienes cuenta?'),
                    TextButton(
                      onPressed: () {
                        //Aqui implementare la navegaaciónde registro
                      },
                      child: const Text('Regístrate'),
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