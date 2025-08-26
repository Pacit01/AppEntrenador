import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _teamController = TextEditingController();

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);
    await prefs.setString('team', _teamController.text);

    // Ir al HomeScreen después de guardar
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Configura tu perfil")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Tu nombre"),
            ),
            TextField(
              controller: _teamController,
              decoration: InputDecoration(labelText: "Nombre del equipo"),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveData,
              child: Text("Guardar y continuar"),
            ),
          ],
        ),
      ),
    );
  }
}
