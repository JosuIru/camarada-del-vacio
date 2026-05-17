import 'package:flutter/material.dart';
import '../data/cuadrante_sigma.dart';
import '../models/game_state.dart';
import '../screens/canteen_screen.dart';
import '../screens/cuadrante_sigma_screen.dart';
import '../screens/overworld_map_screen.dart';
import '../screens/planeta_gelida9_screen.dart';
import '../screens/planeta_pravda7_screen.dart';
import '../screens/planeta_sol_camarada_screen.dart';
import '../screens/planeta_zovnak4_screen.dart';
import '../screens/reactor_screen.dart';
import '../screens/room_screen.dart';
import 'page_transitions.dart';

/// Calcula la pantalla destino tras cargar una partida, en función del
/// último módulo que el cadete había visitado. Si el módulo es un planeta
/// del Cuadrante Sigma, manda al mapa estelar; si es un módulo interno de
/// la Pravda-12, manda directo a esa sala.
Widget construirPantallaSegunUltimoModulo(EstadoJuego estadoCargado) {
  final identificadorUltimoModulo = estadoCargado.ultimoModuloVisitado;
  final identificadoresDePlanetas = {
    for (final planeta in planetasCuadranteSigma) planeta.identificador,
  };

  if (identificadoresDePlanetas.contains(identificadorUltimoModulo) &&
      identificadorUltimoModulo != 'pravda12') {
    switch (identificadorUltimoModulo) {
      case 'zovnak4':
        return PantallaPlanetaZovnak4(estado: estadoCargado);
      case 'gelida9':
        return PantallaPlanetaGelida9(estado: estadoCargado);
      case 'sol_camarada':
        return PantallaPlanetaSolCamarada(estado: estadoCargado);
      case 'pravda7':
        return PantallaPlanetaPravda7(estado: estadoCargado);
      default:
        return PantallaCuadranteSigma(
          estado: estadoCargado,
          planetaDestacado: identificadorUltimoModulo,
        );
    }
  }

  switch (identificadorUltimoModulo) {
    case 'capsula':
      return PantallaSala(estado: estadoCargado);
    case 'cantina':
      return PantallaCantina(estado: estadoCargado);
    case 'reactor':
      return PantallaReactor(estado: estadoCargado);
    case 'pravda12':
      return PantallaMapaOverworld(estado: estadoCargado);
    default:
      return PantallaMapaOverworld(
        estado: estadoCargado,
        moduloDestacado: identificadorUltimoModulo,
      );
  }
}

/// Reemplaza toda la pila de navegación por la pantalla calculada para la
/// partida cargada. Útil al cargar desde la pantalla de título.
void navegarAPartidaCargada(BuildContext context, EstadoJuego estadoCargado) {
  final pantallaDestino = construirPantallaSegunUltimoModulo(estadoCargado);
  Navigator.of(context).pushAndRemoveUntil(
    crearRutaConTransicion(pantallaDestino),
    (rutaPrevia) => false,
  );
}
