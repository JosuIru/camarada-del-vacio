import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

class PintorEscenarioPravda7 extends CustomPainter {
  final double fase;

  PintorEscenarioPravda7({this.fase = 0});

  @override
  void paint(Canvas canvas, Size size) {
    _pintarInterior(canvas, size);
    _pintarTuberiasFantasma(canvas, size);
    _pintarBanderaDescolorida(canvas, size);
    _pintarPanelRotoCentral(canvas, size);
    _pintarMesaCongelada(canvas, size);
    _pintarGrafiti(canvas, size);
    _pintarFormulariosFlotando(canvas, size);
    _pintarZonaDerechaTripulacion(canvas, size);
    _pintarParticulasFantasmales(canvas, size);
    _pintarPenumbraSuperior(canvas, size);
  }

  void _pintarZonaDerechaTripulacion(Canvas canvas, Size size) {
    final pincelMetal = Paint()..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.85);
    final pincelMetalClaro = Paint()..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.85);
    final pincelTrazo = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final pincelTinta = Paint()..color = PaletaCosmoSovietica.tintaNegra;
    final pincelRojo = Paint()..color = PaletaCosmoSovietica.rojoOficial;
    final pincelHielo = Paint()
      ..color = PaletaCosmoSovietica.papelSombra.withValues(alpha: 0.5);

    // ── Lockers de cosmonautas (0.66 – 0.78) ──
    final yLockerBase = size.height * 0.34;
    for (int indiceLocker = 0; indiceLocker < 4; indiceLocker++) {
      final xLocker = size.width * (0.665 + indiceLocker * 0.027);
      final rectLocker = Rect.fromLTWH(
        xLocker,
        yLockerBase,
        size.width * 0.024,
        size.height * 0.22,
      );
      canvas.drawRect(rectLocker, pincelMetalClaro);
      canvas.drawRect(rectLocker, pincelTrazo);
      // Bisagras.
      canvas.drawCircle(
          Offset(rectLocker.left + 2, rectLocker.top + 6), 1.4, pincelTinta);
      canvas.drawCircle(
          Offset(rectLocker.left + 2, rectLocker.bottom - 6), 1.4, pincelTinta);
      // Asa.
      canvas.drawRect(
        Rect.fromLTWH(
            rectLocker.right - 5, rectLocker.center.dy - 1, 3, 2),
        pincelTinta,
      );
      // Placa con número.
      final placaRect = Rect.fromLTWH(
        rectLocker.left + 3,
        rectLocker.top + 4,
        rectLocker.width - 6,
        rectLocker.height * 0.12,
      );
      canvas.drawRect(placaRect,
          Paint()..color = PaletaCosmoSovietica.papelViejo);
      canvas.drawRect(placaRect,
          Paint()
            ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8);
      // Cinta roja sobre algunos lockers (caídos en servicio).
      if (indiceLocker == 0 || indiceLocker == 2) {
        canvas.drawRect(
          Rect.fromLTWH(rectLocker.left - 2,
              rectLocker.top + rectLocker.height * 0.35,
              rectLocker.width + 4, 4),
          pincelRojo,
        );
      }
    }

    // ── Asientos vacíos en fila (0.55 – 0.78, suelo) ──
    final horizonteY = size.height * 0.62;
    for (int indiceAsiento = 0; indiceAsiento < 4; indiceAsiento++) {
      final xAsiento = size.width * (0.55 + indiceAsiento * 0.06);
      final rectAsiento = Rect.fromCenter(
        center: Offset(xAsiento, horizonteY + size.height * 0.08),
        width: size.width * 0.035,
        height: size.height * 0.03,
      );
      canvas.drawRect(rectAsiento, pincelMetal);
      canvas.drawRect(rectAsiento, pincelTrazo..strokeWidth = 1.4);
      // Respaldo más alto.
      final rectRespaldo = Rect.fromLTWH(
        rectAsiento.left,
        rectAsiento.top - size.height * 0.05,
        rectAsiento.width,
        size.height * 0.06,
      );
      canvas.drawRect(rectRespaldo, pincelMetal);
      canvas.drawRect(rectRespaldo, pincelTrazo..strokeWidth = 1.4);
      // Patas.
      canvas.drawLine(
        Offset(rectAsiento.left + 2, rectAsiento.bottom),
        Offset(rectAsiento.left + 2, rectAsiento.bottom + size.height * 0.04),
        pincelTrazo..strokeWidth = 1.6,
      );
      canvas.drawLine(
        Offset(rectAsiento.right - 2, rectAsiento.bottom),
        Offset(rectAsiento.right - 2, rectAsiento.bottom + size.height * 0.04),
        pincelTrazo..strokeWidth = 1.6,
      );
      // Escarcha cubriendo asiento.
      canvas.drawRect(
        Rect.fromLTWH(rectAsiento.left + 1, rectAsiento.top - 1,
            rectAsiento.width - 2, 3),
        pincelHielo,
      );
    }

    // ── Consolas reventadas (0.82 – 0.94) ──
    for (int indiceConsola = 0; indiceConsola < 3; indiceConsola++) {
      final xConsola = size.width * (0.82 + indiceConsola * 0.05);
      final rectConsola = Rect.fromLTWH(
        xConsola,
        size.height * 0.44,
        size.width * 0.04,
        size.height * 0.18,
      );
      canvas.drawRect(rectConsola, pincelMetal);
      canvas.drawRect(rectConsola, pincelTrazo);
      // Pantalla rota: rect verde con grietas.
      final pantallaRect = Rect.fromLTWH(
        rectConsola.left + 3,
        rectConsola.top + 4,
        rectConsola.width - 6,
        rectConsola.height * 0.4,
      );
      canvas.drawRect(pantallaRect,
          Paint()..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.85));
      canvas.drawRect(pantallaRect, pincelTrazo..strokeWidth = 1.2);
      // Grieta.
      canvas.drawPath(
        Path()
          ..moveTo(pantallaRect.left + 2, pantallaRect.top + 3)
          ..lineTo(pantallaRect.center.dx, pantallaRect.center.dy)
          ..lineTo(pantallaRect.right - 1, pantallaRect.bottom - 2),
        Paint()
          ..color = PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
      // Botones.
      for (int indiceBoton = 0; indiceBoton < 4; indiceBoton++) {
        final yBoton = rectConsola.top + rectConsola.height * 0.55 +
            (indiceBoton ~/ 2) * 8;
        final xBoton = rectConsola.left + 6 + (indiceBoton % 2) * 10;
        canvas.drawCircle(
          Offset(xBoton, yBoton),
          1.8,
          indiceBoton == 0 ? pincelRojo : pincelTinta,
        );
      }
      // Cable suelto colgando.
      canvas.drawPath(
        Path()
          ..moveTo(rectConsola.right - 4, rectConsola.bottom)
          ..quadraticBezierTo(
            rectConsola.right + 4,
            rectConsola.bottom + size.height * 0.04,
            rectConsola.right - 2,
            rectConsola.bottom + size.height * 0.08,
          ),
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }

    // ── Tumba improvisada con casco (0.83 – 0.88, suelo) ──
    final centroTumba = Offset(size.width * 0.85, size.height * 0.88);
    // Montículo.
    canvas.drawArc(
      Rect.fromCenter(
          center: centroTumba, width: size.width * 0.04, height: size.height * 0.04),
      math.pi,
      math.pi,
      false,
      Paint()..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.85),
    );
    canvas.drawArc(
      Rect.fromCenter(
          center: centroTumba, width: size.width * 0.04, height: size.height * 0.04),
      math.pi,
      math.pi,
      false,
      pincelTrazo..strokeWidth = 1.6,
    );
    // Casco encima.
    final cascoCentro = Offset(centroTumba.dx, centroTumba.dy - 8);
    canvas.drawCircle(cascoCentro, 8, pincelMetalClaro);
    canvas.drawCircle(cascoCentro, 8, pincelTrazo..strokeWidth = 1.6);
    // Visor.
    canvas.drawArc(
      Rect.fromCenter(center: cascoCentro, width: 12, height: 8),
      math.pi * 1.1,
      math.pi * 0.8,
      false,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.7)
        ..style = PaintingStyle.fill,
    );
    // Placa.
    canvas.drawRect(
      Rect.fromLTWH(centroTumba.dx - 8, centroTumba.dy + 4, 16, 4),
      Paint()..color = PaletaCosmoSovietica.papelViejo,
    );

    // ── Compuerta de acoplamiento a la izquierda (0.02 – 0.08) ──
    final compuertaRect = Rect.fromLTWH(
      size.width * 0.02,
      size.height * 0.32,
      size.width * 0.06,
      size.height * 0.40,
    );
    canvas.drawRect(compuertaRect, pincelMetalClaro);
    canvas.drawRect(compuertaRect, pincelTrazo..strokeWidth = 2.4);
    // Remaches verticales.
    for (int indiceRemache = 0; indiceRemache < 6; indiceRemache++) {
      final yRem = compuertaRect.top + 8 +
          indiceRemache * (compuertaRect.height - 16) / 5;
      canvas.drawCircle(
          Offset(compuertaRect.left + 4, yRem), 1.6, pincelTinta);
      canvas.drawCircle(
          Offset(compuertaRect.right - 4, yRem), 1.6, pincelTinta);
    }
    // Sello F-447 horizontal.
    for (int indiceSello = 0; indiceSello < 3; indiceSello++) {
      final ySello = compuertaRect.top + 20 + indiceSello * 24;
      canvas.drawRect(
        Rect.fromLTWH(compuertaRect.left - 4, ySello,
            compuertaRect.width + 8, 4),
        pincelRojo,
      );
    }
    // Rueda de cierre.
    final ruedaCierre = Offset(compuertaRect.center.dx,
        compuertaRect.center.dy + 30);
    canvas.drawCircle(ruedaCierre, 8, pincelMetalClaro);
    canvas.drawCircle(ruedaCierre, 8, pincelTrazo..strokeWidth = 1.6);
    for (int indiceRayo = 0; indiceRayo < 4; indiceRayo++) {
      final angulo = indiceRayo * math.pi / 2;
      canvas.drawLine(
        ruedaCierre,
        Offset(ruedaCierre.dx + math.cos(angulo) * 8,
            ruedaCierre.dy + math.sin(angulo) * 8),
        pincelTrazo..strokeWidth = 1.4,
      );
    }

    // ── Reloj de pared a las 4:47 (zona central alta) ──
    final relojCentro = Offset(size.width * 0.36, size.height * 0.22);
    canvas.drawCircle(relojCentro, 22, pincelMetalClaro);
    canvas.drawCircle(relojCentro, 22, pincelTrazo..strokeWidth = 2.2);
    for (int indiceHora = 0; indiceHora < 12; indiceHora++) {
      final angulo = -math.pi / 2 + indiceHora * math.pi / 6;
      final radioInt = indiceHora % 3 == 0 ? 16.0 : 19.0;
      canvas.drawLine(
        Offset(relojCentro.dx + math.cos(angulo) * 22,
            relojCentro.dy + math.sin(angulo) * 22),
        Offset(relojCentro.dx + math.cos(angulo) * radioInt,
            relojCentro.dy + math.sin(angulo) * radioInt),
        Paint()
          ..color = PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.5)
          ..strokeWidth = 1.0,
      );
    }
    final anguloHoraReloj = -math.pi / 2 + (4 + 47 / 60) * math.pi / 6;
    final anguloMinReloj = -math.pi / 2 + 47 * math.pi / 30;
    canvas.drawLine(
      relojCentro,
      Offset(relojCentro.dx + math.cos(anguloHoraReloj) * 11,
          relojCentro.dy + math.sin(anguloHoraReloj) * 11),
      Paint()
        ..color = PaletaCosmoSovietica.papelViejo
        ..strokeWidth = 2.2,
    );
    canvas.drawLine(
      relojCentro,
      Offset(relojCentro.dx + math.cos(anguloMinReloj) * 17,
          relojCentro.dy + math.sin(anguloMinReloj) * 17),
      Paint()
        ..color = PaletaCosmoSovietica.papelViejo
        ..strokeWidth = 1.6,
    );
    canvas.drawCircle(relojCentro, 2, pincelRojo);
  }

  void _pintarInterior(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PaletaCosmoSovietica.tintaNegra,
            PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.85),
            PaletaCosmoSovietica.tintaNegra,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(const Rect.fromLTWH(0, 0, 1024, 1024)),
    );

    final pincelTuberia = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.85);
    // perspectiva del suelo
    final pathSuelo = Path()
      ..moveTo(0, size.height * 0.62)
      ..lineTo(size.width, size.height * 0.62)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(pathSuelo, pincelTuberia);

    final pincelLinea = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.8)
      ..strokeWidth = 1.2;
    for (double y = size.height * 0.66; y < size.height; y += 14) {
      canvas.drawLine(
        Offset(size.width * 0.04, y),
        Offset(size.width * 0.96, y),
        pincelLinea,
      );
    }
    for (double xRel = 0.1; xRel <= 0.9; xRel += 0.2) {
      canvas.drawLine(
        Offset(size.width * xRel, size.height * 0.62),
        Offset(size.width * (xRel * 0.5 + 0.25), size.height),
        pincelLinea,
      );
    }
  }

  void _pintarTuberiasFantasma(Canvas canvas, Size size) {
    final pincelTuberia = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.85);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.05, size.width, size.height * 0.04),
      pincelTuberia,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.05, size.width, size.height * 0.04),
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    for (double x = size.width * 0.05;
        x < size.width * 0.95;
        x += size.width * 0.12) {
      canvas.drawRect(
        Rect.fromLTWH(x, size.height * 0.05, size.width * 0.015,
            size.height * 0.04),
        Paint()..color = PaletaCosmoSovietica.tintaNegra,
      );
    }

    // tubería vertical rota
    canvas.drawRect(
      Rect.fromLTWH(
          size.width * 0.06, size.height * 0.09, size.width * 0.025, size.height * 0.42),
      pincelTuberia,
    );
    canvas.drawRect(
      Rect.fromLTWH(
          size.width * 0.06, size.height * 0.09, size.width * 0.025, size.height * 0.42),
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // fugas pálidas
    final intensidadFuga = math.sin(fase * math.pi * 2) * 0.5 + 0.5;
    final pincelFuga = Paint()
      ..color = PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.25 + intensidadFuga * 0.25);
    canvas.drawCircle(
      Offset(size.width * 0.078, size.height * 0.31),
      6 + intensidadFuga * 3,
      pincelFuga,
    );
  }

  void _pintarBanderaDescolorida(Canvas canvas, Size size) {
    final mastil = Offset(size.width * 0.85, size.height * 0.58);
    canvas.drawLine(
      mastil,
      Offset(mastil.dx, mastil.dy - size.height * 0.34),
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..strokeWidth = 2.5,
    );
    final ondear =
        math.sin(fase * math.pi * 1.4) * size.width * 0.003;
    final pathBandera = Path()
      ..moveTo(mastil.dx, mastil.dy - size.height * 0.34)
      ..lineTo(mastil.dx + size.width * 0.13 + ondear,
          mastil.dy - size.height * 0.32)
      ..lineTo(mastil.dx + size.width * 0.12,
          mastil.dy - size.height * 0.22)
      ..lineTo(mastil.dx, mastil.dy - size.height * 0.24)
      ..close();
    canvas.drawPath(
      pathBandera,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.78),
    );
    canvas.drawPath(
      pathBandera,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // estrella borrada
    final centroEstrella = Offset(
        mastil.dx + size.width * 0.06, mastil.dy - size.height * 0.28);
    canvas.drawCircle(
      centroEstrella,
      6,
      Paint()..color = PaletaCosmoSovietica.rojoOficial.withValues(alpha: 0.4),
    );
  }

  void _pintarPanelRotoCentral(Canvas canvas, Size size) {
    final rectPanel = Rect.fromLTWH(
      size.width * 0.36,
      size.height * 0.18,
      size.width * 0.28,
      size.height * 0.32,
    );
    canvas.drawRect(
      rectPanel,
      Paint()..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.85),
    );
    canvas.drawRect(
      rectPanel,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
    // pantalla con eco verde
    final pantalla = Rect.fromCenter(
      center: rectPanel.center,
      width: rectPanel.width * 0.7,
      height: rectPanel.height * 0.45,
    );
    canvas.drawRect(
      pantalla,
      Paint()..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.85),
    );
    canvas.drawRect(
      pantalla,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // texto repetido
    final pintorTexto = TextPainter(
      text: const TextSpan(
        text: 'TODAVÍA ESTAMOS ABAJO\nTODAVÍA ESTAMOS ABAJO\nTODAVÍA ESTAMOS ABAJO',
        style: TextStyle(
          fontFamily: 'CosmoMono',
          fontSize: 9,
          color: PaletaCosmoSovietica.tintaTenue,
          letterSpacing: 1.2,
          height: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: pantalla.width - 6);
    pintorTexto.paint(
      canvas,
      Offset(pantalla.left + 3, pantalla.top + 3),
    );

    // grietas en el cristal
    final pincelGrieta = Paint()
      ..color = PaletaCosmoSovietica.tintaTenue.withValues(alpha: 0.6)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final centroGrieta = Offset(
        pantalla.center.dx + pantalla.width * 0.18,
        pantalla.center.dy + pantalla.height * 0.05);
    for (int indice = 0; indice < 5; indice++) {
      final angulo = indice * (math.pi / 2.5);
      canvas.drawLine(
        centroGrieta,
        Offset(centroGrieta.dx + math.cos(angulo) * 14,
            centroGrieta.dy + math.sin(angulo) * 10),
        pincelGrieta,
      );
    }

    // luces de panel
    final pulso = math.sin(fase * math.pi * 4) * 0.5 + 0.5;
    canvas.drawCircle(
      Offset(rectPanel.left + 12, rectPanel.bottom - 14),
      3,
      Paint()..color = PaletaCosmoSovietica.rojoOficial.withValues(alpha: 0.6 + pulso * 0.4),
    );
    canvas.drawCircle(
      Offset(rectPanel.right - 12, rectPanel.bottom - 14),
      3,
      Paint()..color = PaletaCosmoSovietica.tintaTenue.withValues(alpha: 0.5 + pulso * 0.4),
    );
  }

  void _pintarMesaCongelada(Canvas canvas, Size size) {
    final rectMesa = Rect.fromLTWH(
      size.width * 0.16,
      size.height * 0.7,
      size.width * 0.18,
      size.height * 0.08,
    );
    canvas.drawRect(
      rectMesa,
      Paint()..color = PaletaCosmoSovietica.tintaTenue,
    );
    canvas.drawRect(
      rectMesa,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(rectMesa.left + 8, rectMesa.bottom),
      Offset(rectMesa.left + 8, rectMesa.bottom + size.height * 0.12),
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..strokeWidth = 2.5,
    );
    canvas.drawLine(
      Offset(rectMesa.right - 8, rectMesa.bottom),
      Offset(rectMesa.right - 8, rectMesa.bottom + size.height * 0.12),
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..strokeWidth = 2.5,
    );
    // tazas vacías escarchadas
    for (int indice = 0; indice < 3; indice++) {
      final x = rectMesa.left + 10 + indice * 18;
      canvas.drawCircle(
        Offset(x, rectMesa.top - 4),
        5,
        Paint()..color = PaletaCosmoSovietica.papelViejo,
      );
      canvas.drawCircle(
        Offset(x, rectMesa.top - 4),
        5,
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  void _pintarGrafiti(Canvas canvas, Size size) {
    final pintorGrafiti = TextPainter(
      text: const TextSpan(
        text: 'NO BUSQUEN',
        style: TextStyle(
          fontFamily: 'CosmoMono',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: PaletaCosmoSovietica.rojoOficial,
          letterSpacing: 2.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(size.width * 0.7, size.height * 0.62);
    canvas.rotate(-0.18);
    pintorGrafiti.paint(canvas, Offset.zero);
    canvas.restore();
  }

  void _pintarFormulariosFlotando(Canvas canvas, Size size) {
    final aleatorio = math.Random(9);
    for (int indice = 0; indice < 10; indice++) {
      final xBase = aleatorio.nextDouble() * size.width;
      final yBase = aleatorio.nextDouble() * size.height;
      final deriva = math.sin(fase * math.pi * 1.4 + indice) * 6;
      final cuadradoLado = 6 + aleatorio.nextDouble() * 6;
      final rectFormulario = Rect.fromLTWH(
        xBase + deriva,
        yBase + math.cos(fase * math.pi * 1.4 + indice) * 3,
        cuadradoLado,
        cuadradoLado * 1.3,
      );
      canvas.drawRect(
        rectFormulario,
        Paint()..color = PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.7),
      );
      canvas.drawRect(
        rectFormulario,
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7,
      );
    }
  }

  void _pintarParticulasFantasmales(Canvas canvas, Size size) {
    final aleatorio = math.Random(21);
    for (int indice = 0; indice < 24; indice++) {
      final xBase = aleatorio.nextDouble() * size.width;
      final yBase = aleatorio.nextDouble() * size.height;
      final deriva = (fase * size.height * 0.5 + yBase) % size.height;
      canvas.drawCircle(
        Offset(xBase, deriva),
        1.5,
        Paint()..color = PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.35),
      );
    }
  }

  void _pintarPenumbraSuperior(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.12),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.8),
            const Color(0x00000000),
          ],
        ).createShader(const Rect.fromLTWH(0, 0, 1024, 200)),
    );
  }

  @override
  bool shouldRepaint(covariant PintorEscenarioPravda7 viejo) =>
      viejo.fase != fase;
}
