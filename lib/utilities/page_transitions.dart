import 'package:flutter/material.dart';

Route<T> crearRutaConTransicion<T>(
  Widget destino, {
  Duration duracion = const Duration(milliseconds: 480),
}) {
  return PageRouteBuilder<T>(
    transitionDuration: duracion,
    reverseTransitionDuration: duracion,
    pageBuilder: (contexto, animacion, animacionSecundaria) => destino,
    transitionsBuilder:
        (contexto, animacion, animacionSecundaria, hijo) {
      final curva = CurvedAnimation(
        parent: animacion,
        curve: Curves.easeOutCubic,
      );
      final escala = Tween<double>(begin: 1.04, end: 1.0).animate(curva);
      return FadeTransition(
        opacity: curva,
        child: ScaleTransition(
          scale: escala,
          child: hijo,
        ),
      );
    },
  );
}
