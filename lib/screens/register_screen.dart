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

  Future<void> handleRegister() async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todos los campos son obligatorios')),
      );
      return;
    }

   setState(() => isLoading = true);
    await Future.delayed(Duration(seconds: 1));

    // Guardar datos en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('password', password);

    setState(() => isLoading = false);
    Navigator.pushReplacementNamed(context, '/home');
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Crear una Cuenta', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(labelText: 'Tu Nombre', border: OutlineInputBorder()),
                  onChanged: (val) => name = val,
                  enabled: !isLoading,
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(labelText: 'Correo Electrónico', border: OutlineInputBorder()),
                  onChanged: (val) => email = val,
                  enabled: !isLoading,
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
                  obscureText: true,
                  onChanged: (val) => password = val,
                  enabled: !isLoading,
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
    );
  }
}
