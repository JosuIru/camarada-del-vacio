import 'package:flutter/material.dart';

class PaletaCosmoSovietica {
  /// Papel base: blanco-crema MUY tenue, casi off-white. Antes
  /// (#F2EDE0) era demasiado sepia/amarillo saturado.
  static const Color papelViejo = Color(0xFFF5F1E8);
  /// Papel sombra: una sombra perceptible pero neutra (sin amarillo).
  static const Color papelSombra = Color(0xFFE8E2D2);
  static const Color tintaNegra = Color(0xFF15110D);
  /// Antes (#5A4F3F) era marrón sepia. Ahora gris neutro frío para
  /// que sólo haya tres familias cromáticas: papel, tinta, rojo.
  static const Color tintaTenue = Color(0xFF625E58);
  static const Color rojoOficial = Color(0xFFC8102E);
  static const Color rojoSombra = Color(0xFF8A0A1F);
  /// Antes (#6B6B3A) verde-mostaza. Reemplazado por gris neutro
  /// idéntico a tintaTenue — la paleta del juego queda limitada
  /// estrictamente a papel + tinta (con gris medio) + rojo.
  static const Color verdeArchivo = Color(0xFF625E58);
}

class TipografiaPropaganda {
  /// Serif principal: títulos, diálogos, cuerpo largo. EB Garamond
  /// vía la familia local "CosmoSerif" registrada en pubspec.yaml.
  static const String familiaPrincipal = 'CosmoSerif';
  /// Máquina de escribir: logs, etiquetas burocráticas, paneles.
  /// Special Elite vía "CosmoMono".
  static const String familiaMonoespaciada = 'CosmoMono';
  /// Rotulador a mano: carteles, propaganda, sellos visibles.
  /// Permanent Marker vía "CosmoRotulador".
  static const String familiaRotulador = 'CosmoRotulador';

  static const TextStyle tituloEnorme = TextStyle(
    fontFamily: familiaPrincipal,
    fontSize: 64,
    fontWeight: FontWeight.w900,
    color: PaletaCosmoSovietica.tintaNegra,
    letterSpacing: 4,
    height: 1.0,
  );

  static const TextStyle tituloSeccion = TextStyle(
    fontFamily: familiaPrincipal,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: PaletaCosmoSovietica.tintaNegra,
    letterSpacing: 2,
  );

  static const TextStyle subtitulo = TextStyle(
    fontFamily: familiaPrincipal,
    fontSize: 19,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.bold,
    color: PaletaCosmoSovietica.tintaNegra,
    letterSpacing: 1,
  );

  static const TextStyle cuerpoLargo = TextStyle(
    fontFamily: familiaPrincipal,
    fontSize: 15,
    color: PaletaCosmoSovietica.tintaNegra,
    height: 1.45,
  );

  static const TextStyle bocadilloDialogo = TextStyle(
    fontFamily: familiaPrincipal,
    fontSize: 16,
    color: PaletaCosmoSovietica.tintaNegra,
    height: 1.4,
    fontStyle: FontStyle.italic,
  );

  static const TextStyle etiquetaBurocratica = TextStyle(
    fontFamily: familiaMonoespaciada,
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: PaletaCosmoSovietica.tintaNegra,
    letterSpacing: 2,
  );

  static const TextStyle numeroStat = TextStyle(
    fontFamily: familiaMonoespaciada,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: PaletaCosmoSovietica.tintaNegra,
  );

  static const TextStyle textoLog = TextStyle(
    fontFamily: familiaMonoespaciada,
    fontSize: 15,
    color: PaletaCosmoSovietica.tintaNegra,
    height: 1.5,
  );
}

ThemeData construirTemaJuego() {
  return ThemeData(
    scaffoldBackgroundColor: PaletaCosmoSovietica.papelViejo,
    colorScheme: const ColorScheme.light(
      primary: PaletaCosmoSovietica.rojoOficial,
      secondary: PaletaCosmoSovietica.tintaNegra,
      surface: PaletaCosmoSovietica.papelViejo,
      onSurface: PaletaCosmoSovietica.tintaNegra,
    ),
    textTheme: const TextTheme(
      bodyMedium: TipografiaPropaganda.cuerpoLargo,
    ),
    useMaterial3: true,
  );
}
