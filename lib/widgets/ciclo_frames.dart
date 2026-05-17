import 'dart:async';
import 'package:flutter/material.dart';

/// Reproduce un set de N frames PNG en bucle. Sustituye a un GIF: los
/// frames se intercambian con un [Timer] y se renderizan con
/// [Image.asset], lo que evita la compresión y artefactos de GIF y
/// mantiene el escalado limpio (los assets son alta resolución).
///
/// Asume que todos los frames del set tienen las mismas dimensiones y
/// el mismo anclaje del contenido dentro del lienzo (ver
/// BRIEFING_ARTE.md §10 — convención obligatoria).
class CicloDeFrames extends StatefulWidget {
  /// Rutas a los frames en orden de reproducción.
  final List<String> rutasFrames;
  /// Duración de cada frame en pantalla.
  final Duration duracionPorFrame;
  /// Ajuste de la imagen dentro del widget.
  final BoxFit ajuste;
  /// Alineamiento del contenido dentro del lienzo.
  final AlignmentGeometry alineamiento;
  /// Si false, el ciclo se queda parado en el primer frame (útil
  /// para pausar animaciones cuando el escenario está en background).
  final bool reproducir;

  const CicloDeFrames({
    super.key,
    required this.rutasFrames,
    this.duracionPorFrame = const Duration(milliseconds: 500),
    this.ajuste = BoxFit.contain,
    this.alineamiento = Alignment.center,
    this.reproducir = true,
  });

  @override
  State<CicloDeFrames> createState() => _CicloDeFramesState();
}

class _CicloDeFramesState extends State<CicloDeFrames> {
  int indiceFrameActual = 0;
  Timer? temporizador;

  @override
  void initState() {
    super.initState();
    _arrancarTemporizador();
  }

  @override
  void didUpdateWidget(CicloDeFrames viejo) {
    super.didUpdateWidget(viejo);
    final bool cambioFrames = !_listasIguales(
        viejo.rutasFrames, widget.rutasFrames);
    final bool cambioDuracion =
        viejo.duracionPorFrame != widget.duracionPorFrame;
    final bool cambioReproducir =
        viejo.reproducir != widget.reproducir;
    if (cambioFrames || cambioDuracion || cambioReproducir) {
      temporizador?.cancel();
      if (cambioFrames) indiceFrameActual = 0;
      _arrancarTemporizador();
    }
  }

  bool _listasIguales(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int indice = 0; indice < a.length; indice++) {
      if (a[indice] != b[indice]) return false;
    }
    return true;
  }

  void _arrancarTemporizador() {
    if (!widget.reproducir || widget.rutasFrames.length < 2) return;
    temporizador = Timer.periodic(widget.duracionPorFrame, (_) {
      if (!mounted) return;
      setState(() {
        indiceFrameActual =
            (indiceFrameActual + 1) % widget.rutasFrames.length;
      });
    });
  }

  @override
  void dispose() {
    temporizador?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rutasFrames.isEmpty) {
      return const SizedBox.shrink();
    }
    return Image.asset(
      widget.rutasFrames[indiceFrameActual],
      fit: widget.ajuste,
      alignment: widget.alineamiento,
      filterQuality: FilterQuality.high,
    );
  }
}
