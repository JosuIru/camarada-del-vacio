import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

class PintorEscenarioSolCamarada extends CustomPainter {
  final double fase;

  PintorEscenarioSolCamarada({this.fase = 0});

  @override
  void paint(Canvas canvas, Size size) {
    _pintarCabinaOrbital(canvas, size);
    _pintarVentanaPanoramica(canvas, size);
    _pintarSolGigante(canvas, size);
    _pintarMesaNegociacion(canvas, size);
    _pintarPanelSindical(canvas, size);
    _pintarBanderas(canvas, size);
    _pintarTuberias(canvas, size);
    _pintarZonaDerechaInstalacionSolar(canvas, size);
  }

  void _pintarZonaDerechaInstalacionSolar(Canvas canvas, Size size) {
    final pincelMetalCalido = Paint()..color = PaletaCosmoSovietica.tintaTenue;
    final pincelMetalOscuro = Paint()..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.85);
    final pincelDorado = Paint()..color = PaletaCosmoSovietica.tintaTenue.withValues(alpha: 0.7);
    final pincelDoradoOscuro = Paint()..color = PaletaCosmoSovietica.tintaTenue;
    final trazo = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final pincelRojo = Paint()..color = PaletaCosmoSovietica.rojoOficial;

    // ── Espejo retroreflector (0.14 – 0.20) ──
    final espejoCentro = Offset(size.width * 0.17, size.height * 0.50);
    // Trípode.
    canvas.drawLine(
      espejoCentro,
      Offset(espejoCentro.dx - 16, size.height * 0.78),
      trazo..strokeWidth = 2.4,
    );
    canvas.drawLine(
      espejoCentro,
      Offset(espejoCentro.dx + 16, size.height * 0.78),
      trazo..strokeWidth = 2.4,
    );
    canvas.drawLine(
      espejoCentro,
      Offset(espejoCentro.dx, size.height * 0.78),
      trazo..strokeWidth = 2.0,
    );
    // Disco del espejo (elipse de plata).
    canvas.drawOval(
      Rect.fromCenter(
          center: espejoCentro, width: size.width * 0.05, height: size.height * 0.16),
      Paint()..color = PaletaCosmoSovietica.papelViejo,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: espejoCentro, width: size.width * 0.05, height: size.height * 0.16),
      trazo..strokeWidth = 2.2,
    );
    // Reflejo del sol: línea brillante.
    canvas.drawArc(
      Rect.fromCenter(
          center: espejoCentro,
          width: size.width * 0.035,
          height: size.height * 0.12),
      math.pi * 1.1,
      math.pi * 0.5,
      false,
      Paint()
        ..color = PaletaCosmoSovietica.papelSombra.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // ── Duna calcinada con silueta del mártir (0.32 – 0.40) ──
    final dunaCentro = Offset(size.width * 0.36, size.height * 0.93);
    final dunaPath = Path()
      ..moveTo(dunaCentro.dx - 60, dunaCentro.dy + 10)
      ..quadraticBezierTo(dunaCentro.dx - 30, dunaCentro.dy - 18,
          dunaCentro.dx, dunaCentro.dy - 14)
      ..quadraticBezierTo(dunaCentro.dx + 30, dunaCentro.dy - 10,
          dunaCentro.dx + 60, dunaCentro.dy + 10)
      ..lineTo(dunaCentro.dx + 60, size.height + 5)
      ..lineTo(dunaCentro.dx - 60, size.height + 5)
      ..close();
    canvas.drawPath(
      dunaPath,
      Paint()..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.85),
    );
    canvas.drawPath(
      dunaPath,
      trazo..strokeWidth = 1.6..color = PaletaCosmoSovietica.tintaNegra,
    );
    // Silueta del mártir tendido (vitrificada).
    canvas.save();
    canvas.translate(dunaCentro.dx - 8, dunaCentro.dy - 6);
    canvas.rotate(-0.05);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 38, height: 8),
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.65),
    );
    canvas.drawCircle(Offset(-22, 0), 6,
        Paint()..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.65));
    // Brazos en cruz.
    canvas.drawLine(
      Offset(-8, -2),
      Offset(-8, -16),
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.65)
        ..strokeWidth = 4,
    );
    canvas.drawLine(
      Offset(-8, 2),
      Offset(-8, 16),
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.65)
        ..strokeWidth = 4,
    );
    canvas.restore();

    // ── Manifiesto Solar (0.52 – 0.58 zona alta) ──
    final manifiestoRect = Rect.fromLTWH(
      size.width * 0.53,
      size.height * 0.16,
      size.width * 0.075,
      size.height * 0.14,
    );
    canvas.drawRect(manifiestoRect.inflate(4), pincelRojo);
    canvas.drawRect(manifiestoRect,
        Paint()..color = PaletaCosmoSovietica.papelViejo);
    canvas.drawRect(manifiestoRect, trazo..strokeWidth = 2.2);
    // Sol estilizado en el centro.
    final centroSolMani = Offset(manifiestoRect.center.dx,
        manifiestoRect.top + manifiestoRect.height * 0.3);
    canvas.drawCircle(centroSolMani, 8, pincelDorado);
    canvas.drawCircle(centroSolMani, 8, trazo..strokeWidth = 1.4);
    for (int indiceRayo = 0; indiceRayo < 8; indiceRayo++) {
      final angulo = indiceRayo * math.pi / 4;
      canvas.drawLine(
        Offset(centroSolMani.dx + math.cos(angulo) * 9,
            centroSolMani.dy + math.sin(angulo) * 9),
        Offset(centroSolMani.dx + math.cos(angulo) * 14,
            centroSolMani.dy + math.sin(angulo) * 14),
        Paint()
          ..color = PaletaCosmoSovietica.rojoOficial
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round,
      );
    }
    // Tres líneas (texto).
    for (int indiceLinea = 0; indiceLinea < 3; indiceLinea++) {
      canvas.drawLine(
        Offset(manifiestoRect.left + 4,
            manifiestoRect.bottom - 6 - indiceLinea * 5),
        Offset(manifiestoRect.right - 4,
            manifiestoRect.bottom - 6 - indiceLinea * 5),
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.7)
          ..strokeWidth = 0.8,
      );
    }

    // ── Tanque de protones (0.64 – 0.70) ──
    final tanqueRect = Rect.fromLTWH(
      size.width * 0.645,
      size.height * 0.50,
      size.width * 0.045,
      size.height * 0.30,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tanqueRect, const Radius.circular(8)),
      pincelDoradoOscuro,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tanqueRect, const Radius.circular(8)),
      trazo..strokeWidth = 2.2..color = PaletaCosmoSovietica.tintaNegra,
    );
    // Anillo decorativo.
    canvas.drawLine(
      Offset(tanqueRect.left + 2, tanqueRect.top + 14),
      Offset(tanqueRect.right - 2, tanqueRect.top + 14),
      trazo..strokeWidth = 1.4,
    );
    // Cosecha 1959.
    final etiquetaTanque = Rect.fromLTWH(
      tanqueRect.left + 4,
      tanqueRect.top + tanqueRect.height * 0.4,
      tanqueRect.width - 8,
      tanqueRect.height * 0.25,
    );
    canvas.drawRect(etiquetaTanque,
        Paint()..color = PaletaCosmoSovietica.papelViejo);
    canvas.drawRect(etiquetaTanque, trazo..strokeWidth = 1.0);
    final textoCosecha = TextPainter(
      text: const TextSpan(
        text: 'C1959',
        style: TextStyle(
          color: PaletaCosmoSovietica.tintaNegra,
          fontSize: 7,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textoCosecha.paint(
      canvas,
      Offset(etiquetaTanque.center.dx - textoCosecha.width / 2,
          etiquetaTanque.center.dy - textoCosecha.height / 2),
    );
    // Válvula goteando.
    final centroValvula = Offset(tanqueRect.right + 4, tanqueRect.top + 30);
    canvas.drawCircle(centroValvula, 4, pincelMetalCalido);
    canvas.drawCircle(centroValvula, 4, trazo..strokeWidth = 1.0);
    // Protón cayendo (punto dorado).
    final fracProton = (fase * 2.0) % 1.0;
    canvas.drawCircle(
      Offset(centroValvula.dx, centroValvula.dy + 6 + fracProton * 20),
      1.6,
      pincelDorado,
    );

    // ── Refinería al fondo (0.74 – 0.86 — silueta industrial) ──
    final refineriaY = size.height * 0.40;
    // Torre principal cilíndrica.
    final torreRect = Rect.fromLTWH(
      size.width * 0.76,
      refineriaY,
      size.width * 0.03,
      size.height * 0.30,
    );
    canvas.drawRect(torreRect, pincelMetalCalido);
    canvas.drawRect(torreRect, trazo..strokeWidth = 1.8);
    // Anillos.
    for (int indiceAnillo = 1; indiceAnillo < 4; indiceAnillo++) {
      final yAnillo = torreRect.top + indiceAnillo * torreRect.height / 4;
      canvas.drawLine(
        Offset(torreRect.left - 2, yAnillo),
        Offset(torreRect.right + 2, yAnillo),
        trazo..strokeWidth = 1.4,
      );
    }
    // Escalera lateral.
    for (int indicePeldano = 0; indicePeldano < 6; indicePeldano++) {
      final yPeldano = torreRect.top + 8 + indicePeldano * (torreRect.height - 16) / 5;
      canvas.drawLine(
        Offset(torreRect.right + 2, yPeldano),
        Offset(torreRect.right + 6, yPeldano),
        trazo..strokeWidth = 1.0,
      );
    }
    canvas.drawLine(
      Offset(torreRect.right + 6, torreRect.top + 8),
      Offset(torreRect.right + 6, torreRect.bottom - 8),
      trazo..strokeWidth = 1.0,
    );
    // Chimenea humeante.
    final chimeRect = Rect.fromLTWH(
      torreRect.center.dx - 5,
      torreRect.top - 16,
      10,
      18,
    );
    canvas.drawRect(chimeRect, pincelMetalOscuro);
    canvas.drawRect(chimeRect, trazo..strokeWidth = 1.4);
    // Segunda torre menor.
    final torre2Rect = Rect.fromLTWH(
      size.width * 0.815,
      refineriaY + size.height * 0.06,
      size.width * 0.022,
      size.height * 0.24,
    );
    canvas.drawRect(torre2Rect, pincelMetalCalido);
    canvas.drawRect(torre2Rect, trazo..strokeWidth = 1.6);
    // Tuberías que las conectan.
    canvas.drawLine(
      Offset(torreRect.right, refineriaY + size.height * 0.12),
      Offset(torre2Rect.left, refineriaY + size.height * 0.12),
      trazo..strokeWidth = 3.4..color = pincelMetalCalido.color,
    );
    canvas.drawLine(
      Offset(torreRect.right, refineriaY + size.height * 0.12),
      Offset(torre2Rect.left, refineriaY + size.height * 0.12),
      trazo..strokeWidth = 1.4..color = PaletaCosmoSovietica.tintaNegra,
    );

    // ── Sombra inversa en el suelo (0.86 – 0.92) ──
    final sombraCentro = Offset(size.width * 0.89, size.height * 0.94);
    // Forma de figura humanoide alargada hacia el sol (en lugar de huir).
    final sombraPath = Path()
      ..moveTo(sombraCentro.dx, sombraCentro.dy + 2)
      ..lineTo(sombraCentro.dx + 30, sombraCentro.dy)
      ..lineTo(sombraCentro.dx + 38, sombraCentro.dy - 6)
      ..lineTo(sombraCentro.dx + 36, sombraCentro.dy)
      ..lineTo(sombraCentro.dx + 42, sombraCentro.dy + 2)
      ..lineTo(sombraCentro.dx, sombraCentro.dy + 4)
      ..close();
    canvas.drawPath(
      sombraPath,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.55),
    );
    // Cabeza redonda.
    canvas.drawCircle(
      Offset(sombraCentro.dx + 42, sombraCentro.dy - 4),
      4,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.55),
    );

    // ── Reloj de sol monumental (0.94 – 1.0) ──
    final relojSolBase = Offset(size.width * 0.97, size.height * 0.78);
    // Plataforma circular.
    canvas.drawOval(
      Rect.fromCenter(
          center: relojSolBase, width: size.width * 0.04, height: size.height * 0.04),
      pincelMetalCalido,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: relojSolBase, width: size.width * 0.04, height: size.height * 0.04),
      trazo..strokeWidth = 2,
    );
    // Marcas radiales (12 horas).
    for (int indiceHora = 0; indiceHora < 12; indiceHora++) {
      final angulo = -math.pi + indiceHora * math.pi / 6;
      final radioExt = size.width * 0.02;
      final radioInt = size.width * (indiceHora % 3 == 0 ? 0.013 : 0.017);
      canvas.drawLine(
        Offset(relojSolBase.dx + math.cos(angulo) * radioExt,
            relojSolBase.dy + math.sin(angulo) * radioExt * 0.5),
        Offset(relojSolBase.dx + math.cos(angulo) * radioInt,
            relojSolBase.dy + math.sin(angulo) * radioInt * 0.5),
        trazo..strokeWidth = 1.4..color = PaletaCosmoSovietica.tintaNegra,
      );
    }
    // Gnomon vertical.
    canvas.drawLine(
      relojSolBase,
      Offset(relojSolBase.dx, relojSolBase.dy - size.height * 0.1),
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..strokeWidth = 3,
    );
    canvas.drawCircle(
        Offset(relojSolBase.dx, relojSolBase.dy - size.height * 0.1),
        2.4,
        pincelRojo);
    // Sombra fija marcando 4:47.
    final anguloSombra = -math.pi / 2 + (4 + 47 / 60) * math.pi / 6;
    canvas.drawLine(
      relojSolBase,
      Offset(relojSolBase.dx + math.cos(anguloSombra) * size.width * 0.018,
          relojSolBase.dy + math.sin(anguloSombra) * size.height * 0.018),
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.7)
        ..strokeWidth = 4,
    );
  }

  void _pintarCabinaOrbital(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PaletaCosmoSovietica.tintaTenue,
            PaletaCosmoSovietica.tintaNegra,
          ],
        ).createShader(Rect.fromLTWH(0, 0, 1024, 1024)),
    );

    final pincelRemache = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.45);
    for (double x = 8; x < size.width; x += 28) {
      for (double y = 8; y < size.height; y += 28) {
        canvas.drawCircle(Offset(x, y), 1.4, pincelRemache);
      }
    }
  }

  void _pintarVentanaPanoramica(Canvas canvas, Size size) {
    final ventanaRect = Rect.fromLTWH(
      size.width * 0.08,
      size.height * 0.06,
      size.width * 0.84,
      size.height * 0.45,
    );
    canvas.drawRect(
      ventanaRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            PaletaCosmoSovietica.papelViejo,
            PaletaCosmoSovietica.tintaTenue.withValues(alpha: 0.7),
            PaletaCosmoSovietica.rojoSombra,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(
            Rect.fromLTWH(0, 0, 1024, 1024)),
    );
    canvas.drawRect(
      ventanaRect,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Refuerzos diagonales
    final pincelRefuerzo = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(ventanaRect.topLeft, ventanaRect.bottomRight, pincelRefuerzo);
    canvas.drawLine(ventanaRect.topRight, ventanaRect.bottomLeft, pincelRefuerzo);
    canvas.drawLine(
        Offset(ventanaRect.center.dx, ventanaRect.top),
        Offset(ventanaRect.center.dx, ventanaRect.bottom),
        pincelRefuerzo);
    canvas.drawLine(
        Offset(ventanaRect.left, ventanaRect.center.dy),
        Offset(ventanaRect.right, ventanaRect.center.dy),
        pincelRefuerzo);
  }

  void _pintarSolGigante(Canvas canvas, Size size) {
    final centroSol = Offset(size.width * 0.5, size.height * 0.32);
    final radioSol = size.width * 0.16;
    final pulso = math.sin(fase * math.pi * 2) * 0.5 + 0.5;

    // Corona externa
    canvas.drawCircle(
      centroSol,
      radioSol + 30 + pulso * 12,
      Paint()
        ..color = PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.35),
    );
    canvas.drawCircle(
      centroSol,
      radioSol + 14 + pulso * 6,
      Paint()..color = PaletaCosmoSovietica.tintaTenue.withValues(alpha: 0.5),
    );

    // Sol
    canvas.drawCircle(
      centroSol,
      radioSol,
      Paint()
        ..shader = RadialGradient(
          colors: [
            PaletaCosmoSovietica.papelViejo,
            PaletaCosmoSovietica.tintaTenue.withValues(alpha: 0.7),
            PaletaCosmoSovietica.tintaTenue,
          ],
        ).createShader(Rect.fromCircle(center: centroSol, radius: radioSol)),
    );
    canvas.drawCircle(
      centroSol,
      radioSol,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Pancarta de huelga flotando
    final rectPancarta = Rect.fromCenter(
      center: Offset(centroSol.dx, centroSol.dy - radioSol * 0.15),
      width: radioSol * 1.55,
      height: radioSol * 0.36,
    );
    canvas.drawRect(
      rectPancarta,
      Paint()..color = PaletaCosmoSovietica.papelViejo,
    );
    canvas.drawRect(
      rectPancarta,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    final pintorPancarta = TextPainter(
      text: const TextSpan(
        text: 'HUELGA',
        style: TextStyle(
          fontFamily: 'CosmoMono',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: PaletaCosmoSovietica.rojoOficial,
          letterSpacing: 3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: rectPancarta.width);
    pintorPancarta.paint(
      canvas,
      Offset(rectPancarta.center.dx - pintorPancarta.width / 2,
          rectPancarta.center.dy - pintorPancarta.height / 2),
    );

    // Cara enojada del sol
    final ojoIzq = Offset(centroSol.dx - radioSol * 0.32,
        centroSol.dy + radioSol * 0.25);
    final ojoDer = Offset(centroSol.dx + radioSol * 0.32,
        centroSol.dy + radioSol * 0.25);
    canvas.drawCircle(
      ojoIzq,
      4,
      Paint()..color = PaletaCosmoSovietica.tintaNegra,
    );
    canvas.drawCircle(
      ojoDer,
      4,
      Paint()..color = PaletaCosmoSovietica.tintaNegra,
    );
    final pathBoca = Path()
      ..moveTo(centroSol.dx - radioSol * 0.28,
          centroSol.dy + radioSol * 0.6)
      ..quadraticBezierTo(centroSol.dx, centroSol.dy + radioSol * 0.45,
          centroSol.dx + radioSol * 0.28, centroSol.dy + radioSol * 0.6);
    canvas.drawPath(
      pathBoca,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  void _pintarMesaNegociacion(Canvas canvas, Size size) {
    final mesa = Rect.fromLTWH(
      size.width * 0.22,
      size.height * 0.7,
      size.width * 0.56,
      size.height * 0.08,
    );
    canvas.drawRect(
      mesa,
      Paint()..color = PaletaCosmoSovietica.tintaTenue,
    );
    canvas.drawRect(
      mesa,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    // patas
    canvas.drawLine(
      Offset(mesa.left + 14, mesa.bottom),
      Offset(mesa.left + 14, mesa.bottom + size.height * 0.12),
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(mesa.right - 14, mesa.bottom),
      Offset(mesa.right - 14, mesa.bottom + size.height * 0.12),
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..strokeWidth = 3,
    );
    // Papeles en la mesa
    for (int indice = 0; indice < 4; indice++) {
      final rectPapel = Rect.fromLTWH(
        mesa.left + 24 + indice * (mesa.width / 5),
        mesa.top - 6,
        size.width * 0.05,
        size.height * 0.04,
      );
      canvas.drawRect(
        rectPapel,
        Paint()..color = PaletaCosmoSovietica.papelViejo,
      );
      canvas.drawRect(
        rectPapel,
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  void _pintarPanelSindical(Canvas canvas, Size size) {
    final panel = Rect.fromLTWH(
      size.width * 0.04,
      size.height * 0.56,
      size.width * 0.16,
      size.height * 0.32,
    );
    canvas.drawRect(
      panel,
      Paint()..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.85),
    );
    canvas.drawRect(
      panel,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final pintorTitulo = TextPainter(
      text: const TextSpan(
        text: 'SESG · 7-B',
        style: TextStyle(
          fontFamily: 'CosmoMono',
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: PaletaCosmoSovietica.rojoOficial,
          letterSpacing: 1.6,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: panel.width);
    pintorTitulo.paint(
      canvas,
      Offset(panel.center.dx - pintorTitulo.width / 2, panel.top + 6),
    );
    // Diales
    final pulso = math.sin(fase * math.pi * 4) * 0.5 + 0.5;
    for (int indice = 0; indice < 3; indice++) {
      final centroDial =
          Offset(panel.center.dx, panel.top + 28 + indice * panel.height * 0.22);
      canvas.drawCircle(
        centroDial,
        panel.width * 0.18,
        Paint()..color = PaletaCosmoSovietica.papelViejo,
      );
      canvas.drawCircle(
        centroDial,
        panel.width * 0.18,
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
      final angulo = -math.pi / 2 + (indice * 0.5 + pulso * 0.4) * math.pi;
      canvas.drawLine(
        centroDial,
        Offset(centroDial.dx + math.cos(angulo) * panel.width * 0.14,
            centroDial.dy + math.sin(angulo) * panel.width * 0.14),
        Paint()
          ..color = PaletaCosmoSovietica.rojoOficial
          ..strokeWidth = 1.6,
      );
    }
  }

  void _pintarBanderas(Canvas canvas, Size size) {
    final pincelMastil = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    final pincelRojo = Paint()..color = PaletaCosmoSovietica.rojoOficial;

    for (int indice = 0; indice < 2; indice++) {
      final xBase = indice == 0
          ? size.width * 0.78
          : size.width * 0.9;
      final yBase = size.height * 0.86;
      canvas.drawLine(
        Offset(xBase, yBase),
        Offset(xBase, yBase - size.height * 0.34),
        pincelMastil,
      );
      final ondear =
          math.sin(fase * math.pi * 2 + indice) * size.width * 0.005;
      final rectBandera = Rect.fromLTWH(
        xBase + 1,
        yBase - size.height * 0.34 + ondear,
        size.width * 0.05,
        size.height * 0.06,
      );
      canvas.drawRect(rectBandera, pincelRojo);
      canvas.drawRect(
        rectBandera,
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  void _pintarTuberias(Canvas canvas, Size size) {
    final pincelTuberia = Paint()
      ..color = PaletaCosmoSovietica.tintaTenue
      ..strokeWidth = 6;
    canvas.drawLine(
      Offset(0, size.height * 0.52),
      Offset(size.width * 0.08, size.height * 0.52),
      pincelTuberia,
    );
    canvas.drawLine(
      Offset(size.width * 0.92, size.height * 0.52),
      Offset(size.width, size.height * 0.52),
      pincelTuberia,
    );
  }

  @override
  bool shouldRepaint(covariant PintorEscenarioSolCamarada viejo) =>
      viejo.fase != fase;
}
