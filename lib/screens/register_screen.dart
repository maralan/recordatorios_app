import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  //Key del formulario para validar todos los campos
  final _formKey = GlobalKey<FormState>();

  //Controladores para obtener valores escritos por el usuario
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  //Codigo para librar memoria cuando la panatalla se destruye
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
      body: SingleChildScrollView( //Scroll ppara evitar errores cuando aparece el teclado
        child: Padding(
          padding: const EdgeInsets.all(20.0),

          child: Form( //Funcion Form que agrupara y permitira validar todos los input
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction, //funciona para validar mientras el usuario escribe
            child: Column(
              children: [

                const SizedBox(height: 40),

                const Text( //Titulo principal
                  'Crear cuenta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                // Campo para correo
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) { //Validacion del correo
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu correo';
                    }
                    if (!value.contains('@')) {
                      return 'Correo inválido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // campo para la contraseña
                TextFormField(
                  controller: passwordController,
                  obscureText: true, //metodo para ocultar el texto en (modo contraseña)
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) { //codigo para validacion de error (contraseña)
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu contraseña';
                    }
                    if (value.length < 8) {
                      return 'Mínimo 8 caracteres';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // campo para confirmar contraseña
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true, //metodo para ocultar el texto en (modo contraseña)
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) { //codigo para validacion (aqui se debe coincidir con el campo contraseña)
                    if (value == null || value.isEmpty) {
                      return 'Confirma tu contraseña';
                    }
                    if (value != passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Boton de registro
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton( //Aqui ejecutaremos la validacion del formulario
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Registro válido'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, //color de fondo
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Registrarse'),
                  ),
                ),

                const SizedBox(height: 20),

                //Codigo para volver/regresar al login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Ya tienes cuenta?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); //funcion para regresar a login
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