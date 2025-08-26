import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          Center(child: Text('Bienvenido a Coach\'s Clipboard')),
          Center(child: Text('Planifica tus entrenamientos')),
          Center(child: ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            child: Text('Comenzar'),
          )),
        ],
      ),
    );
  }
}
