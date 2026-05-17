import 'package:flutter/material.dart';
import 'screens/title_screen.dart';
import 'theme.dart';

void main() {
  runApp(const AppCamaradaDelVacio());
}

class AppCamaradaDelVacio extends StatelessWidget {
  const AppCamaradaDelVacio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camarada del Vacío',
      theme: construirTemaJuego(),
      debugShowCheckedModeBanner: false,
      home: const PantallaTitulo(),
    );
  }
}
