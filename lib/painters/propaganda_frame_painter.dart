import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

class PintorMarcoPropaganda extends CustomPainter {
  final Color colorTrazo;
  final Color colorAcento;
  final double grosor;
  final bool conEstrellas;
  final bool conSelloRojo;

  PintorMarcoPropaganda({
    this.colorTrazo = PaletaCosmoSovietica.tintaNegra,
    this.colorAcento = PaletaCosmoSovietica.rojoOficial,
    this.grosor = 2.5,
    this.conEstrellas = true,
    this.conSelloRojo = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pincelTrazo = Paint()
      ..color = colorTrazo
      ..strokeWidth = grosor
      ..style = PaintingStyle.stroke;

    final pincelInterior = Paint()
      ..color = colorTrazo
      ..strokeWidth = grosor * 0.5
      ..style = PaintingStyle.stroke;

    final pincelAcento = Paint()
      ..color = colorAcento
      ..style = PaintingStyle.fill;

    final margenExterior = grosor;
    final rectExterior = Rect.fromLTWH(
      margenExterior,
      margenExterior,
      size.width - margenExterior * 2,
      size.height - margenExterior * 2,
    );
    canvas.drawRect(rectExterior, pincelTrazo);

    final rectInterior = rectExterior.deflate(6);
    canvas.drawRect(rectInterior, pincelInterior);

    if (conEstrellas) {
      final tamanoEstrella = math.min(size.width, size.height) * 0.04;
      for (final esquina in [
        rectExterior.topLeft.translate(14, 14),
        rectExterior.topRight.translate(-14, 14),
        rectExterior.bottomLeft.translate(14, -14),
        rectExterior.bottomRight.translate(-14, -14),
      ]) {
        _pintarEstrella(canvas, esquina, tamanoEstrella, pincelAcento);
      }
    }

    if (conSelloRojo) {
      final posSello = rectExterior.topRight.translate(-30, 30);
      canvas.drawCircle(
        posSello,
        14,
        Paint()
          ..color = colorAcento
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
      _pintarEstrella(canvas, posSello, 8, pincelAcento);
    }
  }

  void _pintarEstrella(
      Canvas canvas, Offset centro, double radio, Paint pincel) {
    final puntos = 5;
    final pathEstrella = Path();
    for (int indice = 0; indice < puntos * 2; indice++) {
      final esExterior = indice % 2 == 0;
      final radioActual = esExterior ? radio : radio * 0.45;
      final angulo = -math.pi / 2 + indice * math.pi / puntos;
      final x = centro.dx + math.cos(angulo) * radioActual;
      final y = centro.dy + math.sin(angulo) * radioActual;
      if (indice == 0) {
        pathEstrella.moveTo(x, y);
      } else {
        pathEstrella.lineTo(x, y);
      }
    }
    pathEstrella.close();
    canvas.drawPath(pathEstrella, pincel);
  }

  @override
  bool shouldRepaint(covariant PintorMarcoPropaganda viejo) =>
      viejo.colorTrazo != colorTrazo ||
      viejo.colorAcento != colorAcento ||
      viejo.conEstrellas != conEstrellas ||
      viejo.conSelloRojo != conSelloRojo;
}
