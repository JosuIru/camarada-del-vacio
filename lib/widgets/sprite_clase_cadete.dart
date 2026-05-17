import 'package:flutter/material.dart';
import '../models/game_class.dart';

/// Pose-base del cadete según la clase. Cada combinación de clase y estado
/// resuelve a un PNG del set `cadete_<clase>_<estado>.png`.
enum EstadoSpriteClase {
  /// Pose neutra de descanso. Para retratos de selección de clase,
  /// inventario, y momentos sin acción específica.
  idle,

  /// Pose combativa con el equipo característico de la clase
  /// (llave inglesa, libreta de decretos, brazo en guardia).
  combate,

  /// Sentada en banco/taburete, para NPCs en cantina o reposo.
  sentada,

  /// Cadete hecho una bola rodante (variante por clase).
  bola,
}

String _segmentoClase(ClaseCosmonauta clase) {
  switch (clase) {
    case ClaseCosmonauta.gimnasta:
      return 'gimnasta';
    case ClaseCosmonauta.ingeniera:
      return 'ingeniera';
    case ClaseCosmonauta.comisaria:
      return 'comisaria';
  }
}

String _segmentoEstado(EstadoSpriteClase estado) {
  switch (estado) {
    case EstadoSpriteClase.idle:
      return 'idle';
    case EstadoSpriteClase.combate:
      return 'combate';
    case EstadoSpriteClase.sentada:
      return 'sentada';
    case EstadoSpriteClase.bola:
      return 'bola';
  }
}

/// Devuelve la ruta del PNG del sprite atlas por clase y estado. Cada
/// uno de los 12 sprites — 3 clases × 4 estados — debe existir en
/// `assets/images/`.
String rutaSpriteClaseCadete(
  ClaseCosmonauta clase,
  EstadoSpriteClase estado,
) {
  final String segmentoClase = _segmentoClase(clase);
  final String segmentoEstado = _segmentoEstado(estado);
  return 'assets/images/cadete_${segmentoClase}_$segmentoEstado.png';
}

/// Devuelve la ruta del PNG con la CABEZA del cadete para una clase.
/// Estos sprites son retratos de hombros hacia arriba: incluyen casco
/// soviético, ojos, boca, y rasgos específicos por clase
/// (gafas+antena en Ingeniera, estrella extra en Comisario). El cuerpo
/// se sigue pintando con [PintorStickFigure] dibujando `dibujarCabeza:
/// false` para que la cabeza PNG se superponga sin solaparse.
String rutaCabezaCadete(ClaseCosmonauta clase) {
  switch (clase) {
    case ClaseCosmonauta.gimnasta:
      return 'assets/images/cabeza_cadete.png';
    case ClaseCosmonauta.ingeniera:
      return 'assets/images/cabeza_ingeniera.png';
    case ClaseCosmonauta.comisaria:
      return 'assets/images/cabeza_comisaria.png';
  }
}

/// Muestra el sprite del cadete para una clase y un estado concretos
/// usando los PNG del atlas por clase. Mantiene `BoxFit.contain` y
/// resolución alta para que el trazo a mano alzada se vea limpio.
class SpriteClaseCadete extends StatelessWidget {
  final ClaseCosmonauta clase;
  final EstadoSpriteClase estado;
  final BoxFit ajuste;

  const SpriteClaseCadete({
    super.key,
    required this.clase,
    this.estado = EstadoSpriteClase.idle,
    this.ajuste = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      rutaSpriteClaseCadete(clase, estado),
      fit: ajuste,
      filterQuality: FilterQuality.high,
    );
  }
}
