import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

class PintorEscenarioZovnak4 extends CustomPainter {
  final double fase;

  PintorEscenarioZovnak4({this.fase = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final pincelCielo = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          PaletaCosmoSovietica.papelSombra,
          PaletaCosmoSovietica.papelSombra,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.6));
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.6), pincelCielo);

    final pincelTrazo = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    final pincelTrazoFino = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final pincelTrazoFinisimo = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final pincelRojo = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial
      ..style = PaintingStyle.fill;
    final pincelRojoTenue = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial.withValues(alpha: 0.35);

    _pintarSolDoble(canvas, size, pincelTrazo, pincelRojoTenue);

    final horizonteY = size.height * 0.6;
    canvas.drawLine(
      Offset(0, horizonteY),
      Offset(size.width, horizonteY),
      pincelTrazo,
    );

    _pintarMontanasVolcanicas(
        canvas, size, horizonteY, pincelTrazo, pincelRojo);

    final pincelSuelo = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          PaletaCosmoSovietica.tintaTenue.withValues(alpha: 0.7),
          PaletaCosmoSovietica.tintaTenue,
        ],
      ).createShader(Rect.fromLTWH(
          0, size.height * 0.6, size.width, size.height * 0.4));
    canvas.drawRect(
      Rect.fromLTWH(0, horizonteY, size.width, size.height * 0.4),
      pincelSuelo,
    );
    for (double y = horizonteY + 12; y < size.height; y += 14) {
      canvas.drawLine(
        Offset(size.width * 0.04, y),
        Offset(size.width * 0.96, y),
        pincelTrazoFinisimo,
      );
    }

    _pintarPancartaAsamblea(
        canvas, size, pincelTrazo, pincelTrazoFino, pincelRojo);

    _pintarUrnaCentral(
        canvas, size, horizonteY, pincelTrazo, pincelRojo, pincelTrazoFino);

    _pintarBanderitas(canvas, size, horizonteY, pincelTrazo, pincelRojo);

    _pintarCrateres(canvas, size, horizonteY, pincelTrazoFino);

    _pintarFormulariosVolando(canvas, size, pincelTrazoFino);

    _pintarZonaDerechaAsamblea(
        canvas, size, horizonteY, pincelTrazo, pincelTrazoFino, pincelRojo);
  }

  void _pintarZonaDerechaAsamblea(Canvas canvas, Size size, double horizonteY,
      Paint pincelTrazo, Paint pincelTrazoFino, Paint pincelRojo) {
    final pincelTinta = Paint()..color = PaletaCosmoSovietica.tintaNegra;
    final pincelArenaOscura = Paint()..color = PaletaCosmoSovietica.tintaTenue;
    final pincelMetalRojizo = Paint()..color = PaletaCosmoSovietica.tintaTenue;
    final trazoFuerte = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // ── Cabinas de votación (0.24 – 0.31) ──
    final cabinaCentro = Offset(size.width * 0.275, size.height * 0.62);
    final cabinaRect = Rect.fromLTWH(
      cabinaCentro.dx - size.width * 0.025,
      cabinaCentro.dy - size.height * 0.18,
      size.width * 0.05,
      size.height * 0.36,
    );
    canvas.drawRect(cabinaRect, pincelMetalRojizo);
    canvas.drawRect(cabinaRect, trazoFuerte..strokeWidth = 2.2);
    // Cortina (rota).
    final cortinaPath = Path()
      ..moveTo(cabinaRect.left + 4, cabinaRect.top + 8)
      ..lineTo(cabinaRect.left + 4, cabinaRect.bottom - 18)
      ..lineTo(cabinaRect.left + 8, cabinaRect.bottom - 20)
      ..lineTo(cabinaRect.left + 6, cabinaRect.bottom - 14)
      ..lineTo(cabinaRect.left + 10, cabinaRect.bottom - 12);
    canvas.drawPath(
      cortinaPath,
      Paint()
        ..color = PaletaCosmoSovietica.rojoSombra
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(cortinaPath, trazoFuerte..strokeWidth = 1.2);
    // Rejilla superior con barrote vertical.
    canvas.drawLine(
      Offset(cabinaRect.center.dx, cabinaRect.top + 14),
      Offset(cabinaRect.center.dx, cabinaRect.top + cabinaRect.height * 0.4),
      trazoFuerte..strokeWidth = 1.4,
    );
    // Cartel "CAB·47".
    final cartelCab = Rect.fromLTWH(
      cabinaRect.left, cabinaRect.top - 8, cabinaRect.width, 8);
    canvas.drawRect(cartelCab,
        Paint()..color = PaletaCosmoSovietica.papelViejo);
    canvas.drawRect(cartelCab, trazoFuerte..strokeWidth = 1);
    final textoCab = TextPainter(
      text: const TextSpan(
        text: 'CAB·47',
        style: TextStyle(
          color: PaletaCosmoSovietica.tintaNegra,
          fontSize: 6,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textoCab.paint(
      canvas,
      Offset(cartelCab.center.dx - textoCab.width / 2,
          cartelCab.center.dy - textoCab.height / 2),
    );

    // ── Estatua caída (0.38 – 0.44 en el suelo) ──
    final centroEstatua = Offset(size.width * 0.40, size.height * 0.93);
    // Cuerpo tendido (rectángulo inclinado).
    canvas.save();
    canvas.translate(centroEstatua.dx, centroEstatua.dy);
    canvas.rotate(-0.12);
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: 50, height: 14),
      pincelArenaOscura,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: 50, height: 14),
      trazoFuerte..strokeWidth = 1.8,
    );
    // Cabeza redonda.
    canvas.drawCircle(Offset(-26, -3), 7, pincelArenaOscura);
    canvas.drawCircle(Offset(-26, -3), 7, trazoFuerte..strokeWidth = 1.6);
    // Brazo levantado roto: tres dedos.
    canvas.drawLine(Offset(20, -3), Offset(32, -16), trazoFuerte..strokeWidth = 2.4);
    for (int indiceDedo = 0; indiceDedo < 3; indiceDedo++) {
      canvas.drawLine(
          Offset(32, -16), Offset(32 + indiceDedo * 2, -22),
          trazoFuerte..strokeWidth = 1.6);
    }
    canvas.restore();
    // Placa.
    final placaEstatua = Rect.fromCenter(
      center: Offset(centroEstatua.dx + 18, centroEstatua.dy + 12),
      width: 24,
      height: 5,
    );
    canvas.drawRect(placaEstatua,
        Paint()..color = PaletaCosmoSovietica.papelViejo);
    canvas.drawRect(placaEstatua, trazoFuerte..strokeWidth = 0.8);

    // ── Cartel de propaganda marciano (0.50 – 0.59 zona alta) ──
    final cartelMar = Rect.fromLTWH(
      size.width * 0.52,
      size.height * 0.17,
      size.width * 0.075,
      size.height * 0.13,
    );
    canvas.drawRect(cartelMar.inflate(3), pincelRojo);
    canvas.drawRect(cartelMar,
        Paint()..color = PaletaCosmoSovietica.papelViejo);
    canvas.drawRect(cartelMar, trazoFuerte);
    // Símbolo marciano: ojo con tres rayos.
    final centroOjoMar = Offset(cartelMar.center.dx, cartelMar.top + cartelMar.height * 0.35);
    canvas.drawCircle(centroOjoMar, 6, pincelTinta);
    canvas.drawCircle(centroOjoMar, 6, trazoFuerte..strokeWidth = 1.4);
    canvas.drawCircle(centroOjoMar, 2, pincelRojo);
    for (int indiceRayo = 0; indiceRayo < 3; indiceRayo++) {
      final angulo = -math.pi / 2 + indiceRayo * math.pi * 2 / 3;
      canvas.drawLine(
        Offset(centroOjoMar.dx + math.cos(angulo) * 8,
            centroOjoMar.dy + math.sin(angulo) * 8),
        Offset(centroOjoMar.dx + math.cos(angulo) * 14,
            centroOjoMar.dy + math.sin(angulo) * 14),
        trazoFuerte..strokeWidth = 1.6,
      );
    }
    // Tres líneas (texto).
    for (int indiceLinea = 0; indiceLinea < 3; indiceLinea++) {
      canvas.drawLine(
        Offset(cartelMar.left + 4,
            cartelMar.bottom - 4 - indiceLinea * 4),
        Offset(cartelMar.right - 4,
            cartelMar.bottom - 4 - indiceLinea * 4),
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.6)
          ..strokeWidth = 0.8,
      );
    }

    // ── Ánfora de sufragios (0.64 – 0.68 en el suelo) ──
    final anforaCentro = Offset(size.width * 0.66, size.height * 0.84);
    final anforaPath = Path()
      ..moveTo(anforaCentro.dx - 8, anforaCentro.dy - 14)
      ..cubicTo(
        anforaCentro.dx - 14, anforaCentro.dy - 8,
        anforaCentro.dx - 14, anforaCentro.dy + 8,
        anforaCentro.dx - 4, anforaCentro.dy + 14,
      )
      ..lineTo(anforaCentro.dx + 4, anforaCentro.dy + 14)
      ..cubicTo(
        anforaCentro.dx + 14, anforaCentro.dy + 8,
        anforaCentro.dx + 14, anforaCentro.dy - 8,
        anforaCentro.dx + 8, anforaCentro.dy - 14,
      )
      ..close();
    canvas.drawPath(anforaPath, pincelArenaOscura);
    canvas.drawPath(anforaPath, trazoFuerte);
    // Boca llena de papeletas dobladas.
    for (int indicePapeleta = 0; indicePapeleta < 4; indicePapeleta++) {
      final xPap = anforaCentro.dx - 6 + indicePapeleta * 4;
      canvas.drawRect(
        Rect.fromLTWH(xPap, anforaCentro.dy - 18 - (indicePapeleta % 2) * 2,
            3, 6),
        Paint()..color = PaletaCosmoSovietica.papelViejo,
      );
    }
    // Banda decorativa.
    canvas.drawLine(
      Offset(anforaCentro.dx - 10, anforaCentro.dy),
      Offset(anforaCentro.dx + 10, anforaCentro.dy),
      pincelRojo..strokeWidth = 2,
    );

    // ── Géiser de azufre (0.76 – 0.80) ──
    final geiserBase = Offset(size.width * 0.78, size.height * 0.94);
    final alturaGeiser = 24.0 + math.sin(fase * math.pi * 2) * 12;
    final geiserPath = Path()
      ..moveTo(geiserBase.dx - 4, geiserBase.dy)
      ..cubicTo(
        geiserBase.dx - 8, geiserBase.dy - alturaGeiser * 0.5,
        geiserBase.dx + 8, geiserBase.dy - alturaGeiser * 0.9,
        geiserBase.dx, geiserBase.dy - alturaGeiser,
      )
      ..cubicTo(
        geiserBase.dx + 8, geiserBase.dy - alturaGeiser * 0.6,
        geiserBase.dx - 8, geiserBase.dy - alturaGeiser * 0.3,
        geiserBase.dx + 4, geiserBase.dy,
      )
      ..close();
    canvas.drawPath(
      geiserPath,
      Paint()..color = PaletaCosmoSovietica.tintaTenue.withValues(alpha: 0.7),
    );
    canvas.drawPath(
      geiserPath,
      Paint()
        ..color = PaletaCosmoSovietica.tintaTenue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Charco de azufre.
    canvas.drawOval(
      Rect.fromCenter(center: geiserBase, width: 20, height: 6),
      Paint()..color = PaletaCosmoSovietica.tintaTenue.withValues(alpha: 0.7),
    );

    // ── Cosmonauta perdido sentado en peñasco (0.94 – 0.98) ──
    final pinaCentro = Offset(size.width * 0.96, size.height * 0.86);
    // Peñasco.
    canvas.drawOval(
      Rect.fromCenter(center: pinaCentro, width: 26, height: 14),
      pincelArenaOscura,
    );
    canvas.drawOval(
      Rect.fromCenter(center: pinaCentro, width: 26, height: 14),
      trazoFuerte,
    );
    // Cosmonauta sentado.
    final cosmoCentro = Offset(pinaCentro.dx, pinaCentro.dy - 16);
    // Cuerpo.
    canvas.drawRect(
      Rect.fromCenter(center: cosmoCentro, width: 12, height: 18),
      Paint()..color = PaletaCosmoSovietica.papelViejo,
    );
    canvas.drawRect(
      Rect.fromCenter(center: cosmoCentro, width: 12, height: 18),
      trazoFuerte..strokeWidth = 1.4,
    );
    // Casco con visor roto.
    canvas.drawCircle(
        Offset(cosmoCentro.dx, cosmoCentro.dy - 12), 8,
        Paint()..color = PaletaCosmoSovietica.papelViejo);
    canvas.drawCircle(
        Offset(cosmoCentro.dx, cosmoCentro.dy - 12), 8,
        trazoFuerte..strokeWidth = 1.6);
    // Visor agrietado.
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(cosmoCentro.dx, cosmoCentro.dy - 12),
          width: 12,
          height: 8),
      math.pi * 1.05,
      math.pi * 0.9,
      false,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill,
    );
    canvas.drawLine(
      Offset(cosmoCentro.dx - 4, cosmoCentro.dy - 14),
      Offset(cosmoCentro.dx + 4, cosmoCentro.dy - 9),
      Paint()
        ..color = PaletaCosmoSovietica.papelViejo
        ..strokeWidth = 0.8,
    );
    // Pierna colgando.
    canvas.drawLine(
      Offset(cosmoCentro.dx - 4, cosmoCentro.dy + 9),
      Offset(cosmoCentro.dx - 4, pinaCentro.dy - 2),
      trazoFuerte..strokeWidth = 2.4,
    );
    canvas.drawLine(
      Offset(cosmoCentro.dx + 4, cosmoCentro.dy + 9),
      Offset(cosmoCentro.dx + 4, pinaCentro.dy - 2),
      trazoFuerte..strokeWidth = 2.4,
    );
    // Estrella roja en pecho.
    canvas.drawCircle(cosmoCentro, 2, pincelRojo);
  }

  void _pintarSolDoble(Canvas canvas, Size size, Paint pincelTrazo,
      Paint pincelRojoTenue) {
    final centroSol1 = Offset(size.width * 0.22, size.height * 0.18);
    final centroSol2 = Offset(size.width * 0.72, size.height * 0.12);
    canvas.drawCircle(centroSol1, size.width * 0.04, pincelRojoTenue);
    canvas.drawCircle(centroSol1, size.width * 0.04, pincelTrazo);
    canvas.drawCircle(centroSol2, size.width * 0.025, pincelRojoTenue);
    canvas.drawCircle(centroSol2, size.width * 0.025, pincelTrazo);
  }

  void _pintarMontanasVolcanicas(Canvas canvas, Size size, double horizonteY,
      Paint pincelTrazo, Paint pincelRojo) {
    final pathMontana = Path()
      ..moveTo(0, horizonteY)
      ..lineTo(size.width * 0.12, horizonteY - size.height * 0.18)
      ..lineTo(size.width * 0.22, horizonteY - size.height * 0.05)
      ..lineTo(size.width * 0.32, horizonteY - size.height * 0.22)
      ..lineTo(size.width * 0.42, horizonteY - size.height * 0.04)
      ..lineTo(size.width * 0.58, horizonteY - size.height * 0.14)
      ..lineTo(size.width * 0.68, horizonteY - size.height * 0.02)
      ..lineTo(size.width * 0.82, horizonteY - size.height * 0.16)
      ..lineTo(size.width * 0.92, horizonteY - size.height * 0.05)
      ..lineTo(size.width, horizonteY)
      ..close();
    canvas.drawPath(
      pathMontana,
      Paint()..color = PaletaCosmoSovietica.papelSombra,
    );
    canvas.drawPath(pathMontana, pincelTrazo);

    final ondulacionLava =
        math.sin(fase * math.pi * 2) * size.height * 0.005;
    canvas.drawCircle(
      Offset(size.width * 0.32, horizonteY - size.height * 0.21),
      3 + ondulacionLava.abs() * 1.5,
      pincelRojo,
    );
    canvas.drawCircle(
      Offset(size.width * 0.82, horizonteY - size.height * 0.155),
      3 + ondulacionLava.abs(),
      pincelRojo,
    );
  }

  void _pintarPancartaAsamblea(Canvas canvas, Size size, Paint pincelTrazo,
      Paint pincelTrazoFino, Paint pincelRojo) {
    final rectPancarta = Rect.fromLTWH(
      size.width * 0.16,
      size.height * 0.04,
      size.width * 0.68,
      size.height * 0.08,
    );
    canvas.drawRect(
      rectPancarta,
      Paint()..color = PaletaCosmoSovietica.papelViejo,
    );
    canvas.drawRect(rectPancarta, pincelTrazo);
    canvas.drawRect(rectPancarta.inflate(-4), pincelTrazoFino);
    final pintor = TextPainter(
      text: const TextSpan(
        text: 'ASAMBLEA PERMANENTE · ZOVNAK-4',
        style: TextStyle(
          fontFamily: 'CosmoMono',
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: PaletaCosmoSovietica.tintaNegra,
          letterSpacing: 2.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: rectPancarta.width);
    pintor.paint(
      canvas,
      Offset(rectPancarta.center.dx - pintor.width / 2,
          rectPancarta.center.dy - pintor.height / 2),
    );
    canvas.drawCircle(
      Offset(rectPancarta.left + 10, rectPancarta.center.dy),
      4,
      pincelRojo,
    );
    canvas.drawCircle(
      Offset(rectPancarta.right - 10, rectPancarta.center.dy),
      4,
      pincelRojo,
    );
  }

  void _pintarUrnaCentral(Canvas canvas, Size size, double horizonteY,
      Paint pincelTrazo, Paint pincelRojo, Paint pincelTrazoFino) {
    final centroUrnaX = size.width * 0.5;
    final urnaTop = horizonteY - size.height * 0.04;
    final pintorBuzon = TextPainter(
      text: const TextSpan(
        text: 'URNA Nº 47',
        style: TextStyle(
          fontFamily: 'CosmoMono',
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: PaletaCosmoSovietica.tintaNegra,
          letterSpacing: 1.6,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintorBuzon.paint(
      canvas,
      Offset(centroUrnaX - pintorBuzon.width / 2,
          urnaTop - size.height * 0.04 - pintorBuzon.height - 2),
    );
    canvas.drawCircle(
      Offset(centroUrnaX - pintorBuzon.width / 2 - 6,
          urnaTop - size.height * 0.04 - pintorBuzon.height / 2 - 2),
      3,
      pincelRojo,
    );
  }

  void _pintarBanderitas(Canvas canvas, Size size, double horizonteY,
      Paint pincelTrazo, Paint pincelRojo) {
    for (int indice = 0; indice < 5; indice++) {
      final x = size.width * (0.1 + indice * 0.2);
      final yBase = horizonteY + size.height * 0.04;
      final altoMastil = size.height * 0.06;
      canvas.drawLine(
        Offset(x, yBase),
        Offset(x, yBase - altoMastil),
        pincelTrazo..strokeWidth = 1.6,
      );
      final ondear =
          math.sin(fase * math.pi * 2 + indice) * size.width * 0.005;
      final rectBandera = Rect.fromLTWH(
        x + 1,
        yBase - altoMastil + ondear,
        size.width * 0.04,
        size.height * 0.025,
      );
      canvas.drawRect(rectBandera, pincelRojo);
      canvas.drawRect(rectBandera, pincelTrazo..strokeWidth = 1.2);
    }
  }

  void _pintarCrateres(Canvas canvas, Size size, double horizonteY,
      Paint pincelTrazoFino) {
    final aleatorio = math.Random(11);
    for (int indice = 0; indice < 22; indice++) {
      final x = aleatorio.nextDouble() * size.width;
      final y = horizonteY +
          aleatorio.nextDouble() * (size.height - horizonteY);
      final radio = 4 + aleatorio.nextDouble() * 9;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: radio * 2, height: radio),
        pincelTrazoFino,
      );
    }
  }

  void _pintarFormulariosVolando(
      Canvas canvas, Size size, Paint pincelTrazoFino) {
    final aleatorio = math.Random(33);
    for (int indice = 0; indice < 6; indice++) {
      final xBase = aleatorio.nextDouble() * size.width;
      final yBase = aleatorio.nextDouble() * size.height * 0.45;
      final deriva = math.sin(fase * math.pi * 2 + indice) * 8;
      final cuadradoLado = 6 + aleatorio.nextDouble() * 6;
      final rect = Rect.fromLTWH(
        xBase + deriva,
        yBase + math.cos(fase * math.pi * 2 + indice) * 4,
        cuadradoLado,
        cuadradoLado * 1.3,
      );
      canvas.drawRect(
        rect,
        Paint()..color = PaletaCosmoSovietica.papelViejo,
      );
      canvas.drawRect(rect, pincelTrazoFino);
    }
  }

  @override
  bool shouldRepaint(covariant PintorEscenarioZovnak4 viejo) =>
      viejo.fase != fase;
}
