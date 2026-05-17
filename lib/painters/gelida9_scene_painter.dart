import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

class PintorEscenarioGelida9 extends CustomPainter {
  final double fase;

  PintorEscenarioGelida9({this.fase = 0});

  @override
  void paint(Canvas canvas, Size size) {
    _pintarCieloHelado(canvas, size);
    _pintarAuroraLejana(canvas, size);
    _pintarMontanasHeladas(canvas, size);
    _pintarSuelo(canvas, size);
    _pintarPancartaCongelada(canvas, size);
    _pintarMostrador(canvas, size);
    _pintarFormulariosCongelados(canvas, size);
    _pintarZonaDerechaPaisajeHelado(canvas, size);
    _pintarCopos(canvas, size);
  }

  void _pintarZonaDerechaPaisajeHelado(Canvas canvas, Size size) {
    final pincelHielo = Paint()
      ..color = PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.6);
    final pincelHieloOscuro = Paint()..color = PaletaCosmoSovietica.tintaTenue.withValues(alpha: 0.7);
    final pincelTrazo = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final pincelTinta = Paint()..color = PaletaCosmoSovietica.tintaNegra;
    final pincelRojo = Paint()..color = PaletaCosmoSovietica.rojoOficial;
    final pincelMetalGris = Paint()..color = PaletaCosmoSovietica.tintaTenue.withValues(alpha: 0.7);

    // ── Grietas en el suelo helado (0.30 – 1.0) ──
    final aleatorioGrietas = math.Random(13);
    for (int indiceGrieta = 0; indiceGrieta < 8; indiceGrieta++) {
      final xInicio = size.width * (0.30 + aleatorioGrietas.nextDouble() * 0.68);
      final yInicio =
          size.height * (0.66 + aleatorioGrietas.nextDouble() * 0.30);
      final caminoGrieta = Path()..moveTo(xInicio, yInicio);
      double x = xInicio;
      double y = yInicio;
      for (int indiceSegmento = 0; indiceSegmento < 4; indiceSegmento++) {
        x += (aleatorioGrietas.nextDouble() - 0.5) * size.width * 0.05;
        y += (aleatorioGrietas.nextDouble() - 0.3) * size.height * 0.04;
        caminoGrieta.lineTo(x, y);
      }
      canvas.drawPath(
        caminoGrieta,
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }

    // ── Estatua de Directorskov (0.48 – 0.54) ──
    final baseEstatua = Offset(size.width * 0.50, size.height * 0.86);
    // Pedestal.
    final pedestalRect = Rect.fromCenter(
      center: baseEstatua,
      width: size.width * 0.045,
      height: size.height * 0.06,
    );
    canvas.drawRect(pedestalRect, pincelHieloOscuro);
    canvas.drawRect(pedestalRect, pincelTrazo);
    // Placa.
    final placaPed = Rect.fromCenter(
      center: Offset(baseEstatua.dx, pedestalRect.top + 8),
      width: pedestalRect.width * 0.7,
      height: 8,
    );
    canvas.drawRect(placaPed,
        Paint()..color = PaletaCosmoSovietica.papelViejo);
    canvas.drawRect(placaPed, pincelTrazo..strokeWidth = 1.0);
    // Cuerpo de la estatua: figura vertical con dedo extendido.
    final centroEstatua = Offset(baseEstatua.dx, pedestalRect.top - size.height * 0.10);
    canvas.drawCircle(
        Offset(centroEstatua.dx, centroEstatua.dy), 10, pincelHieloOscuro);
    canvas.drawCircle(
        Offset(centroEstatua.dx, centroEstatua.dy), 10, pincelTrazo);
    // Torso.
    final torsoPath = Path()
      ..moveTo(centroEstatua.dx - 10, centroEstatua.dy + 10)
      ..lineTo(centroEstatua.dx - 8, pedestalRect.top)
      ..lineTo(centroEstatua.dx + 8, pedestalRect.top)
      ..lineTo(centroEstatua.dx + 10, centroEstatua.dy + 10)
      ..close();
    canvas.drawPath(torsoPath, pincelHieloOscuro);
    canvas.drawPath(torsoPath, pincelTrazo);
    // Brazo extendido apuntando al horizonte.
    canvas.drawLine(
      Offset(centroEstatua.dx + 8, centroEstatua.dy + 14),
      Offset(centroEstatua.dx + 26, centroEstatua.dy + 6),
      pincelTrazo..strokeWidth = 3.6..color = PaletaCosmoSovietica.tintaTenue.withValues(alpha: 0.7),
    );
    canvas.drawLine(
      Offset(centroEstatua.dx + 8, centroEstatua.dy + 14),
      Offset(centroEstatua.dx + 26, centroEstatua.dy + 6),
      pincelTrazo..strokeWidth = 1.4..color = PaletaCosmoSovietica.tintaNegra,
    );
    // Escarcha cubriendo hombros.
    canvas.drawRect(
      Rect.fromLTWH(centroEstatua.dx - 12, centroEstatua.dy + 8, 24, 4),
      pincelHielo,
    );

    // ── Kiosco F-447 (0.32 – 0.36) ──
    final kioscoRect = Rect.fromLTWH(
      size.width * 0.325,
      size.height * 0.58,
      size.width * 0.035,
      size.height * 0.18,
    );
    canvas.drawRect(kioscoRect, pincelMetalGris);
    canvas.drawRect(kioscoRect, pincelTrazo..strokeWidth = 2);
    // Techo.
    final techoKiosco = Path()
      ..moveTo(kioscoRect.left - 4, kioscoRect.top)
      ..lineTo(kioscoRect.center.dx, kioscoRect.top - 12)
      ..lineTo(kioscoRect.right + 4, kioscoRect.top)
      ..close();
    canvas.drawPath(techoKiosco,
        Paint()..color = PaletaCosmoSovietica.rojoSombra);
    canvas.drawPath(techoKiosco, pincelTrazo..strokeWidth = 1.8);
    // Ventana de servicio.
    final ventanaKiosco = Rect.fromLTWH(
      kioscoRect.left + 3,
      kioscoRect.top + 10,
      kioscoRect.width - 6,
      kioscoRect.height * 0.3,
    );
    canvas.drawRect(ventanaKiosco,
        Paint()..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.85));
    canvas.drawRect(ventanaKiosco, pincelTrazo..strokeWidth = 1.2);
    // Cartel "F-447".
    final cartelKiosco = Rect.fromLTWH(
      kioscoRect.left,
      kioscoRect.top - 28,
      kioscoRect.width,
      12,
    );
    canvas.drawRect(cartelKiosco,
        Paint()..color = PaletaCosmoSovietica.papelViejo);
    canvas.drawRect(cartelKiosco, pincelTrazo..strokeWidth = 1.0);
    final textoF447 = TextPainter(
      text: const TextSpan(
        text: 'F-447',
        style: TextStyle(
          color: PaletaCosmoSovietica.tintaNegra,
          fontSize: 7,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textoF447.paint(
      canvas,
      Offset(cartelKiosco.center.dx - textoF447.width / 2,
          cartelKiosco.center.dy - textoF447.height / 2),
    );

    // ── Antena de hielo caída (0.62 – 0.72) ──
    final antenaBase = Offset(size.width * 0.62, size.height * 0.84);
    canvas.drawLine(
      antenaBase,
      Offset(antenaBase.dx + size.width * 0.08, size.height * 0.32),
      pincelTrazo..strokeWidth = 3..color = PaletaCosmoSovietica.tintaNegra,
    );
    canvas.drawLine(
      antenaBase,
      Offset(antenaBase.dx + size.width * 0.08, size.height * 0.32),
      Paint()
        ..color = pincelMetalGris.color
        ..strokeWidth = 1.6,
    );
    // Plato de antena.
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(antenaBase.dx + size.width * 0.08, size.height * 0.32),
        width: 28,
        height: 16,
      ),
      math.pi * 1.15,
      math.pi * 0.7,
      false,
      pincelMetalGris..style = PaintingStyle.fill,
    );
    pincelMetalGris.style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(antenaBase.dx + size.width * 0.08, size.height * 0.32),
        width: 28,
        height: 16,
      ),
      math.pi * 1.15,
      math.pi * 0.7,
      false,
      pincelTrazo..strokeWidth = 1.6..color = PaletaCosmoSovietica.tintaNegra,
    );
    // Tirantes.
    canvas.drawLine(
      antenaBase,
      Offset(antenaBase.dx - 24, size.height * 0.78),
      pincelTrazo..strokeWidth = 1.2,
    );
    canvas.drawLine(
      antenaBase.translate(8, 0),
      Offset(antenaBase.dx + 30, size.height * 0.78),
      pincelTrazo..strokeWidth = 1.2,
    );

    // ── Kvas helado tirado (0.74 – 0.76) ──
    final centroKvas = Offset(size.width * 0.74, size.height * 0.92);
    // Botella tumbada.
    canvas.drawOval(
      Rect.fromCenter(center: centroKvas, width: 14, height: 5),
      Paint()..color = PaletaCosmoSovietica.rojoSombra,
    );
    canvas.drawOval(
      Rect.fromCenter(center: centroKvas, width: 14, height: 5),
      pincelTrazo..strokeWidth = 1.2..color = PaletaCosmoSovietica.tintaNegra,
    );
    // Cuello.
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset(centroKvas.dx + 7, centroKvas.dy),
          width: 6,
          height: 3),
      Paint()..color = PaletaCosmoSovietica.rojoSombra,
    );
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset(centroKvas.dx + 7, centroKvas.dy),
          width: 6,
          height: 3),
      pincelTrazo..strokeWidth = 1.0,
    );
    // Burbujas congeladas saliendo.
    for (int indiceBurbuja = 0; indiceBurbuja < 3; indiceBurbuja++) {
      canvas.drawCircle(
        Offset(centroKvas.dx + 14 + indiceBurbuja * 4, centroKvas.dy - 2 - indiceBurbuja * 3),
        1.5,
        pincelHielo,
      );
    }

    // ── Oso polar nominal (0.83 – 0.90) ──
    final osoCentro = Offset(size.width * 0.86, size.height * 0.72);
    // Cuerpo.
    canvas.drawOval(
      Rect.fromCenter(center: osoCentro, width: 38, height: 22),
      Paint()..color = PaletaCosmoSovietica.papelViejo,
    );
    canvas.drawOval(
      Rect.fromCenter(center: osoCentro, width: 38, height: 22),
      pincelTrazo..strokeWidth = 1.8..color = PaletaCosmoSovietica.tintaNegra,
    );
    // Cabeza.
    canvas.drawCircle(
      Offset(osoCentro.dx - 22, osoCentro.dy - 4),
      11,
      Paint()..color = PaletaCosmoSovietica.papelViejo,
    );
    canvas.drawCircle(
      Offset(osoCentro.dx - 22, osoCentro.dy - 4),
      11,
      pincelTrazo..strokeWidth = 1.6,
    );
    // Orejas.
    canvas.drawCircle(
      Offset(osoCentro.dx - 28, osoCentro.dy - 12),
      3,
      Paint()..color = PaletaCosmoSovietica.papelViejo,
    );
    canvas.drawCircle(
      Offset(osoCentro.dx - 18, osoCentro.dy - 14),
      3,
      Paint()..color = PaletaCosmoSovietica.papelViejo,
    );
    // Ojo y hocico.
    canvas.drawCircle(
        Offset(osoCentro.dx - 26, osoCentro.dy - 5), 1.4, pincelTinta);
    canvas.drawCircle(
        Offset(osoCentro.dx - 32, osoCentro.dy - 2), 1.4, pincelTinta);
    // Patas.
    for (final xPata in [-12.0, -2.0, 8.0, 14.0]) {
      canvas.drawRect(
        Rect.fromLTWH(osoCentro.dx + xPata, osoCentro.dy + 10, 5, 8),
        Paint()..color = PaletaCosmoSovietica.papelViejo,
      );
      canvas.drawRect(
        Rect.fromLTWH(osoCentro.dx + xPata, osoCentro.dy + 10, 5, 8),
        pincelTrazo..strokeWidth = 1.2,
      );
    }
    // Chapa "Sindicato Estelar" sobre el costado.
    final chapaOso = Rect.fromCenter(
      center: osoCentro,
      width: 14,
      height: 8,
    );
    canvas.drawRect(chapaOso, pincelRojo);
    canvas.drawRect(chapaOso, pincelTrazo..strokeWidth = 0.8);

    // ── Cabina de calefacción individual (0.95 – 1.0) ──
    final cabinaRect = Rect.fromLTWH(
      size.width * 0.96,
      size.height * 0.34,
      size.width * 0.035,
      size.height * 0.45,
    );
    canvas.drawRect(cabinaRect, pincelMetalGris);
    canvas.drawRect(cabinaRect, pincelTrazo..strokeWidth = 2.2);
    // Techo a dos aguas con chimenea.
    final techoCabina = Path()
      ..moveTo(cabinaRect.left - 3, cabinaRect.top)
      ..lineTo(cabinaRect.center.dx, cabinaRect.top - 16)
      ..lineTo(cabinaRect.right + 3, cabinaRect.top)
      ..close();
    canvas.drawPath(techoCabina,
        Paint()..color = PaletaCosmoSovietica.rojoSombra);
    canvas.drawPath(techoCabina, pincelTrazo..strokeWidth = 1.8);
    // Chimenea apagada.
    final chimeneaCabina = Rect.fromLTWH(
        cabinaRect.center.dx - 3, cabinaRect.top - 26, 6, 10);
    canvas.drawRect(chimeneaCabina, pincelTinta);
    // Ventana congelada.
    final ventanaCabina = Rect.fromLTWH(
      cabinaRect.left + 4,
      cabinaRect.top + 12,
      cabinaRect.width - 8,
      cabinaRect.height * 0.25,
    );
    canvas.drawRect(ventanaCabina,
        Paint()..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.85));
    canvas.drawRect(ventanaCabina, pincelTrazo..strokeWidth = 1.0);
    // Cruz blanca de escarcha en la ventana.
    canvas.drawLine(
      Offset(ventanaCabina.center.dx, ventanaCabina.top + 1),
      Offset(ventanaCabina.center.dx, ventanaCabina.bottom - 1),
      Paint()
        ..color = PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.7)
        ..strokeWidth = 1.0,
    );
    canvas.drawLine(
      Offset(ventanaCabina.left + 1, ventanaCabina.center.dy),
      Offset(ventanaCabina.right - 1, ventanaCabina.center.dy),
      Paint()
        ..color = PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.7)
        ..strokeWidth = 1.0,
    );
    // Puerta.
    final puertaCabina = Rect.fromLTWH(
      cabinaRect.center.dx - 5,
      cabinaRect.bottom - cabinaRect.height * 0.4,
      10,
      cabinaRect.height * 0.4,
    );
    canvas.drawRect(puertaCabina, pincelTinta);
    canvas.drawCircle(
        Offset(puertaCabina.right - 2, puertaCabina.center.dy),
        1.4,
        pincelRojo);
  }

  void _pintarCieloHelado(Canvas canvas, Size size) {
    final pincelCielo = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          PaletaCosmoSovietica.papelSombra,
          PaletaCosmoSovietica.tintaTenue.withValues(alpha: 0.7),
        ],
      ).createShader(const Rect.fromLTWH(0, 0, 1024, 1024));
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.62), pincelCielo);
  }

  void _pintarAuroraLejana(Canvas canvas, Size size) {
    final pincelAurora = Paint()
      ..color = PaletaCosmoSovietica.tintaTenue.withValues(alpha: 0.55);
    final pathAurora = Path()
      ..moveTo(0, size.height * 0.18)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.08,
          size.width * 0.6, size.height * 0.22)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.3,
          size.width, size.height * 0.18)
      ..lineTo(size.width, size.height * 0.32)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.42,
          size.width * 0.4, size.height * 0.32)
      ..quadraticBezierTo(
          size.width * 0.15, size.height * 0.24, 0, size.height * 0.32)
      ..close();
    canvas.drawPath(pathAurora, pincelAurora);

    final pincelAurora2 = Paint()
      ..color = PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.4);
    final pathAurora2 = Path()
      ..moveTo(0, size.height * 0.24)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.18,
          size.width * 0.7, size.height * 0.28)
      ..quadraticBezierTo(size.width * 0.9, size.height * 0.34,
          size.width, size.height * 0.26);
    canvas.drawPath(
      pathAurora2,
      pincelAurora2..style = PaintingStyle.stroke..strokeWidth = 6,
    );
  }

  void _pintarMontanasHeladas(Canvas canvas, Size size) {
    final pincelMontana = Paint()
      ..color = PaletaCosmoSovietica.tintaTenue;
    final pincelTrazo = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final horizonteY = size.height * 0.62;
    final pathMontana = Path()
      ..moveTo(0, horizonteY)
      ..lineTo(size.width * 0.1, horizonteY - size.height * 0.16)
      ..lineTo(size.width * 0.18, horizonteY - size.height * 0.04)
      ..lineTo(size.width * 0.3, horizonteY - size.height * 0.22)
      ..lineTo(size.width * 0.42, horizonteY - size.height * 0.05)
      ..lineTo(size.width * 0.58, horizonteY - size.height * 0.18)
      ..lineTo(size.width * 0.7, horizonteY - size.height * 0.03)
      ..lineTo(size.width * 0.85, horizonteY - size.height * 0.2)
      ..lineTo(size.width, horizonteY - size.height * 0.06)
      ..lineTo(size.width, horizonteY)
      ..close();
    canvas.drawPath(pathMontana, pincelMontana);
    canvas.drawPath(pathMontana, pincelTrazo);

    final pincelHielo = Paint()..color = PaletaCosmoSovietica.papelViejo;
    for (final cumbre in [
      Offset(size.width * 0.3, horizonteY - size.height * 0.22),
      Offset(size.width * 0.58, horizonteY - size.height * 0.18),
      Offset(size.width * 0.85, horizonteY - size.height * 0.2),
    ]) {
      final pathHielo = Path()
        ..moveTo(cumbre.dx - 12, cumbre.dy + 14)
        ..lineTo(cumbre.dx, cumbre.dy)
        ..lineTo(cumbre.dx + 12, cumbre.dy + 14)
        ..close();
      canvas.drawPath(pathHielo, pincelHielo);
      canvas.drawPath(pathHielo, pincelTrazo..strokeWidth = 1.4);
    }
  }

  void _pintarSuelo(Canvas canvas, Size size) {
    final horizonteY = size.height * 0.62;
    canvas.drawRect(
      Rect.fromLTWH(0, horizonteY, size.width, size.height * 0.38),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PaletaCosmoSovietica.papelViejo,
            PaletaCosmoSovietica.papelSombra,
          ],
        ).createShader(
            const Rect.fromLTWH(0, 0, 1024, 1024)),
    );

    final pincelTrazoFino = Paint()
      ..color = PaletaCosmoSovietica.tintaTenue.withValues(alpha: 0.45)
      ..strokeWidth = 1.0;
    for (double y = horizonteY + 14; y < size.height; y += 14) {
      canvas.drawLine(
        Offset(size.width * 0.04, y),
        Offset(size.width * 0.96, y),
        pincelTrazoFino,
      );
    }
    final pincelGrieta = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.3)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final aleatorio = math.Random(5);
    for (int indice = 0; indice < 10; indice++) {
      final xInicio = aleatorio.nextDouble() * size.width;
      final yInicio =
          horizonteY + aleatorio.nextDouble() * (size.height - horizonteY);
      final pathGrieta = Path()..moveTo(xInicio, yInicio);
      double xActual = xInicio;
      double yActual = yInicio;
      for (int paso = 0; paso < 3; paso++) {
        xActual += (aleatorio.nextDouble() - 0.5) * 30;
        yActual += aleatorio.nextDouble() * 12;
        pathGrieta.lineTo(xActual, yActual);
      }
      canvas.drawPath(pathGrieta, pincelGrieta);
    }
  }

  void _pintarPancartaCongelada(Canvas canvas, Size size) {
    final rectPancarta = Rect.fromLTWH(
      size.width * 0.18,
      size.height * 0.04,
      size.width * 0.64,
      size.height * 0.09,
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
        ..strokeWidth = 2.2,
    );
    for (int indice = 0; indice < 5; indice++) {
      final xCarambano = rectPancarta.left +
          rectPancarta.width * 0.15 +
          indice * rectPancarta.width * 0.18;
      final pathCarambano = Path()
        ..moveTo(xCarambano - 4, rectPancarta.bottom)
        ..lineTo(xCarambano, rectPancarta.bottom + 14)
        ..lineTo(xCarambano + 4, rectPancarta.bottom)
        ..close();
      canvas.drawPath(
        pathCarambano,
        Paint()..color = PaletaCosmoSovietica.papelViejo,
      );
      canvas.drawPath(
        pathCarambano,
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
    final pintorPancarta = TextPainter(
      text: const TextSpan(
        text: 'COMITÉ DE BIENVENIDA · EN SESIÓN DESDE 1968',
        style: TextStyle(
          fontFamily: 'CosmoMono',
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: PaletaCosmoSovietica.tintaNegra,
          letterSpacing: 2.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: rectPancarta.width);
    pintorPancarta.paint(
      canvas,
      Offset(rectPancarta.center.dx - pintorPancarta.width / 2,
          rectPancarta.center.dy - pintorPancarta.height / 2),
    );
    canvas.drawCircle(
      Offset(rectPancarta.left + 10, rectPancarta.center.dy),
      4,
      Paint()..color = PaletaCosmoSovietica.rojoOficial,
    );
  }

  void _pintarMostrador(Canvas canvas, Size size) {
    final horizonteY = size.height * 0.62;
    final rectMostrador = Rect.fromLTWH(
      size.width * 0.36,
      horizonteY + size.height * 0.08,
      size.width * 0.28,
      size.height * 0.16,
    );
    canvas.drawRect(
      rectMostrador,
      Paint()..color = PaletaCosmoSovietica.papelSombra,
    );
    canvas.drawRect(
      rectMostrador,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(rectMostrador.left, rectMostrador.top + 6),
      Offset(rectMostrador.right, rectMostrador.top + 6),
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..strokeWidth = 1.4,
    );
    final pintorCartel = TextPainter(
      text: const TextSpan(
        text: 'F-447 · 47 COPIAS',
        style: TextStyle(
          fontFamily: 'CosmoMono',
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: PaletaCosmoSovietica.tintaNegra,
          letterSpacing: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rectCartelito = Rect.fromCenter(
      center: Offset(rectMostrador.center.dx,
          rectMostrador.top - pintorCartel.height - 4),
      width: pintorCartel.width + 12,
      height: pintorCartel.height + 4,
    );
    canvas.drawRect(
      rectCartelito,
      Paint()..color = PaletaCosmoSovietica.papelViejo,
    );
    canvas.drawRect(
      rectCartelito,
      Paint()
        ..color = PaletaCosmoSovietica.rojoOficial
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    pintorCartel.paint(
      canvas,
      Offset(rectCartelito.center.dx - pintorCartel.width / 2,
          rectCartelito.center.dy - pintorCartel.height / 2),
    );
  }

  void _pintarFormulariosCongelados(Canvas canvas, Size size) {
    final aleatorio = math.Random(7);
    for (int indice = 0; indice < 12; indice++) {
      final x = aleatorio.nextDouble() * size.width;
      final y = size.height * 0.55 + aleatorio.nextDouble() * size.height * 0.4;
      final cuadradoLado = 5 + aleatorio.nextDouble() * 5;
      final rectFormulario = Rect.fromCenter(
        center: Offset(x, y),
        width: cuadradoLado,
        height: cuadradoLado * 1.3,
      );
      canvas.drawRect(
        rectFormulario,
        Paint()..color = PaletaCosmoSovietica.papelViejo,
      );
      canvas.drawRect(
        rectFormulario,
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra
              .withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }
  }

  void _pintarCopos(Canvas canvas, Size size) {
    final aleatorio = math.Random(13);
    for (int indice = 0; indice < 60; indice++) {
      final xBase = aleatorio.nextDouble() * size.width;
      final yBase = aleatorio.nextDouble() * size.height;
      final desplazamientoY =
          (fase * size.height + yBase) % size.height;
      final radioCopo = 0.8 + aleatorio.nextDouble() * 1.6;
      canvas.drawCircle(
        Offset(xBase + math.sin(fase * math.pi * 2 + indice) * 4,
            desplazamientoY),
        radioCopo,
        Paint()..color = PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.85),
      );
    }
  }

  @override
  bool shouldRepaint(covariant PintorEscenarioGelida9 viejo) =>
      viejo.fase != fase;
}
