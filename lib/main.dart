import 'package:flutter/material.dart';
import 'screens/login_screen.dart';  // Vamos a crear este archivo

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarjeta Pare',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(),  // Apunta a la pantalla de login
      debugShowCheckedModeBanner: false,
    );
  }
}