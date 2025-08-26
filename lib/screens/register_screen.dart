import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String name = '';
  String email = '';
  String password = '';
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    await Future.delayed(Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);      // Nombre
    await prefs.setString('userEmail', email);    // Email
    await prefs.setString('userPassword', password); // Contraseña
    await prefs.setString('team', 'U12 Escorpiones'); // Equipo inicial
    await prefs.setString('currentUserName', name);   // Usuario actual para HomeScreen

    setState(() => isLoading = false);
    Navigator.pushReplacementNamed(context, '/home');
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu nombre';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu correo';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return 'Correo no válido';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
    if (value.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 350,
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Crear una Cuenta', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Tu Nombre', border: OutlineInputBorder()),
                    onChanged: (val) => name = val,
                    enabled: !isLoading,
                    validator: validateName,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Correo Electrónico', border: OutlineInputBorder()),
                    onChanged: (val) => email = val,
                    enabled: !isLoading,
                    validator: validateEmail,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
                    obscureText: true,
                    onChanged: (val) => password = val,
                    enabled: !isLoading,
                    validator: validatePassword,
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : handleRegister,
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Registrarse'),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: Text('¿Ya tienes cuenta? Iniciar Sesión'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
