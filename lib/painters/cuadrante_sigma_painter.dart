import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/cuadrante_sigma.dart';
import '../theme.dart';

class PintorCuadranteSigma extends CustomPainter {
  final double fase;
  final Set<String> planetasAccesibles;
  final String? planetaDestacado;
  final String? planetaUbicacionActual;

  PintorCuadranteSigma({
    required this.fase,
    required this.planetasAccesibles,
    this.planetaDestacado,
    this.planetaUbicacionActual,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _pintarCosmos(canvas, size);
    _pintarMarcoYTitulo(canvas, size);
    _pintarOrbitas(canvas, size);
    _pintarRutas(canvas, size);
    _pintarPlanetas(canvas, size);
    _pintarIndicadorUbicacionActual(canvas, size);
  }

  void _pintarCosmos(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [PaletaCosmoSovietica.tintaNegra, PaletaCosmoSovietica.tintaNegra],
        ).createShader(const Rect.fromLTWH(0, 0, 1024, 1024)),
    );

    final aleatorioEstrellas = math.Random(11);
    for (int indiceEstrella = 0; indiceEstrella < 220; indiceEstrella++) {
      final radioEstrella = 0.4 + aleatorioEstrellas.nextDouble() * 1.6;
      final brilloBase = 0.4 + aleatorioEstrellas.nextDouble() * 0.6;
      final desfaseParpadeo = aleatorioEstrellas.nextDouble() * math.pi * 2;
      final frecuenciaParpadeo =
          0.4 + aleatorioEstrellas.nextDouble() * 1.8;
      final intensidadParpadeo =
          math.sin(fase * math.pi * 2 * frecuenciaParpadeo + desfaseParpadeo);
      final brilloEfectivo =
          (brilloBase + intensidadParpadeo * 0.28).clamp(0.05, 1.0);
      final centroEstrella = Offset(
        aleatorioEstrellas.nextDouble() * size.width,
        aleatorioEstrellas.nextDouble() * size.height,
      );
      canvas.drawCircle(
        centroEstrella,
        radioEstrella,
        Paint()..color = Colors.white.withValues(alpha: brilloEfectivo),
      );
      // Cruz de destello en las estrellas más brillantes.
      if (brilloEfectivo > 0.78 && radioEstrella > 1.1) {
        final destelloAlpha = (brilloEfectivo - 0.78) / 0.22;
        final pincelDestello = Paint()
          ..color = Colors.white.withValues(alpha: destelloAlpha * 0.55)
          ..strokeWidth = 0.6;
        final largoDestello = radioEstrella * 3.6;
        canvas.drawLine(
          centroEstrella.translate(-largoDestello, 0),
          centroEstrella.translate(largoDestello, 0),
          pincelDestello,
        );
        canvas.drawLine(
          centroEstrella.translate(0, -largoDestello),
          centroEstrella.translate(0, largoDestello),
          pincelDestello,
        );
      }
    }

    // 4 cometas que recorren la pantalla. Cada uno tiene seed propio.
    for (int indiceCometa = 0; indiceCometa < 4; indiceCometa++) {
      final aleatorioCometa = math.Random(indiceCometa * 37 + 5);
      final desfaseCometa = aleatorioCometa.nextDouble();
      final faseCometa = (fase + desfaseCometa) % 1.0;
      final yInicialNormalizada =
          0.1 + aleatorioCometa.nextDouble() * 0.55;
      final inclinacion = 0.18 + aleatorioCometa.nextDouble() * 0.35;
      final xCometa = (1.2 - faseCometa * 1.4) * size.width;
      final yCometa =
          (yInicialNormalizada + faseCometa * inclinacion) * size.height;
      if (xCometa < -100 || xCometa > size.width + 100) continue;
      final largoCola = 32 + aleatorioCometa.nextDouble() * 60;
      final pathCola = Path()
        ..moveTo(xCometa, yCometa)
        ..lineTo(xCometa + largoCola, yCometa - largoCola * 0.32);
      final visibilidadCometa = (faseCometa < 0.05
              ? faseCometa / 0.05
              : faseCometa > 0.95
                  ? (1.0 - faseCometa) / 0.05
                  : 1.0)
          .clamp(0.0, 1.0);
      canvas.drawPath(
        pathCola,
        Paint()
          ..color = PaletaCosmoSovietica.rojoOficial
              .withValues(alpha: 0.45 * visibilidadCometa)
          ..strokeWidth = 1.3,
      );
      canvas.drawCircle(
        Offset(xCometa, yCometa),
        2.0,
        Paint()
          ..color = PaletaCosmoSovietica.papelViejo
              .withValues(alpha: 0.95 * visibilidadCometa),
      );
    }
  }

  void _pintarMarcoYTitulo(Canvas canvas, Size size) {
    final pincelMarco = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    final rectMarco = Rect.fromLTWH(
      size.width * 0.03,
      size.height * 0.06,
      size.width * 0.94,
      size.height * 0.88,
    );
    canvas.drawRect(rectMarco, pincelMarco);
    canvas.drawRect(
      rectMarco.deflate(6),
      Paint()
        ..color = PaletaCosmoSovietica.rojoOficial.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final pintorTitulo = TextPainter(
      text: const TextSpan(
        text: '★ MAPA OFICIAL · CUADRANTE SIGMA · 1962 ★',
        style: TextStyle(
          fontFamily: 'CosmoMono',
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: PaletaCosmoSovietica.papelViejo,
          letterSpacing: 2.6,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);
    final rectFondoTitulo = Rect.fromCenter(
      center: Offset(size.width / 2, rectMarco.top),
      width: pintorTitulo.width + 28,
      height: pintorTitulo.height + 6,
    );
    canvas.drawRect(
      rectFondoTitulo,
      Paint()..color = PaletaCosmoSovietica.tintaNegra,
    );
    canvas.drawRect(rectFondoTitulo, pincelMarco..strokeWidth = 1.6);
    pintorTitulo.paint(
      canvas,
      Offset(rectFondoTitulo.center.dx - pintorTitulo.width / 2,
          rectFondoTitulo.center.dy - pintorTitulo.height / 2),
    );
  }

  void _pintarOrbitas(Canvas canvas, Size size) {
    final centro = Offset(size.width * 0.5, size.height * 0.5);
    final pincelOrbita = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (int indice = 1; indice <= 3; indice++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: centro,
          width: size.width * 0.36 * indice,
          height: size.height * 0.34 * indice,
        ),
        pincelOrbita,
      );
    }
  }

  void _pintarRutas(Canvas canvas, Size size) {
    final pravda12 = planetasCuadranteSigma.firstWhere(
        (planeta) => planeta.identificador == 'pravda12');
    final origen = Offset(
      pravda12.posicionRelativa.dx * size.width,
      pravda12.posicionRelativa.dy * size.height,
    );
    final pincelRuta = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial.withValues(alpha: 0.55)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (final planeta in planetasCuadranteSigma) {
      if (planeta.identificador == 'pravda12') continue;
      final destino = Offset(
        planeta.posicionRelativa.dx * size.width,
        planeta.posicionRelativa.dy * size.height,
      );
      final esAccesible =
          planetasAccesibles.contains(planeta.identificador);
      if (!esAccesible) {
        _pintarLineaPunteada(
          canvas,
          origen,
          destino,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.18)
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke,
        );
      } else {
        canvas.drawLine(origen, destino, pincelRuta);
      }
    }
  }

  void _pintarLineaPunteada(
      Canvas canvas, Offset desde, Offset hasta, Paint pincel) {
    const longitudGuion = 5.0;
    const longitudEspacio = 4.0;
    final distancia = (hasta - desde).distance;
    double recorrido = 0;
    while (recorrido < distancia) {
      final t1 = recorrido / distancia;
      final t2 = math
          .min((recorrido + longitudGuion) / distancia, 1.0)
          .toDouble();
      canvas.drawLine(
        Offset.lerp(desde, hasta, t1)!,
        Offset.lerp(desde, hasta, t2)!,
        pincel,
      );
      recorrido += longitudGuion + longitudEspacio;
    }
  }

  void _pintarPlanetas(Canvas canvas, Size size) {
    final pulso = math.sin(fase * math.pi * 2) * 0.5 + 0.5;
    for (final planeta in planetasCuadranteSigma) {
      final centro = Offset(
        planeta.posicionRelativa.dx * size.width,
        planeta.posicionRelativa.dy * size.height,
      );
      final radioPlaneta = planeta.radioRelativo * size.width;
      final esAccesible =
          planetasAccesibles.contains(planeta.identificador);
      final esDestacado = planetaDestacado == planeta.identificador;
      final esUbicacion = planetaUbicacionActual == planeta.identificador;

      if (esDestacado || esUbicacion) {
        final extra = pulso * radioPlaneta * 0.35;
        canvas.drawCircle(
          centro,
          radioPlaneta + extra,
          Paint()
            ..color = PaletaCosmoSovietica.rojoOficial
                .withValues(alpha: 0.18 + pulso * 0.18),
        );
      }

      final colorCentro =
          esAccesible ? planeta.colorCentro : PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.85);
      final colorBorde =
          esAccesible ? planeta.colorBorde : PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.85);
      canvas.drawCircle(
        centro,
        radioPlaneta,
        Paint()
          ..shader = RadialGradient(
            colors: [colorCentro, colorBorde],
            stops: const [0.0, 1.0],
          ).createShader(Rect.fromCircle(center: centro, radius: radioPlaneta)),
      );
      canvas.drawCircle(
        centro,
        radioPlaneta,
        Paint()
          ..color = Colors.white.withValues(alpha: esAccesible ? 0.7 : 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );

      final pintorEmoji = TextPainter(
        text: TextSpan(
          text: planeta.emojiDecoracion,
          style: TextStyle(
            fontSize: radioPlaneta * 0.95,
            color: Colors.white.withValues(alpha: esAccesible ? 1.0 : 0.4),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      // Ligera oscilación vertical para sensación de planeta vivo.
      final desfaseFlotacion = planeta.identificador.hashCode % 7;
      final desplazamientoFlotacion =
          math.sin(fase * math.pi * 2 + desfaseFlotacion) * radioPlaneta * 0.06;
      pintorEmoji.paint(
        canvas,
        Offset(centro.dx - pintorEmoji.width / 2,
            centro.dy - pintorEmoji.height / 2 + desplazamientoFlotacion),
      );

      // Un satélite minúsculo orbita los planetas accesibles, indicando que
      // están activos y reciben patrullas oficiales.
      if (esAccesible && planeta.implementado) {
        final anguloSatelite =
            fase * math.pi * 2 + planeta.identificador.hashCode * 0.7;
        final radioOrbitaSatelite = radioPlaneta * 1.55;
        final centroSatelite = Offset(
          centro.dx + math.cos(anguloSatelite) * radioOrbitaSatelite,
          centro.dy + math.sin(anguloSatelite) * radioOrbitaSatelite * 0.55,
        );
        canvas.drawCircle(
          centroSatelite,
          1.6,
          Paint()
            ..color =
                PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.85),
        );
        canvas.drawCircle(
          centroSatelite,
          3.0,
          Paint()
            ..color =
                PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.18),
        );
      }

      final pintorEtiqueta = TextPainter(
        text: TextSpan(
          text: planeta.etiqueta,
          style: TextStyle(
            fontFamily: 'CosmoMono',
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: esAccesible
                ? PaletaCosmoSovietica.papelViejo
                : Colors.white.withValues(alpha: 0.4),
            letterSpacing: 1.4,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 200);
      final etiquetaY = centro.dy + radioPlaneta + 6;
      final rectEtiqueta = Rect.fromCenter(
        center: Offset(centro.dx, etiquetaY + pintorEtiqueta.height / 2),
        width: pintorEtiqueta.width + 10,
        height: pintorEtiqueta.height + 4,
      );
      canvas.drawRect(
        rectEtiqueta,
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.85),
      );
      canvas.drawRect(
        rectEtiqueta,
        Paint()
          ..color = PaletaCosmoSovietica.rojoOficial
              .withValues(alpha: esAccesible ? 0.75 : 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      pintorEtiqueta.paint(
        canvas,
        Offset(centro.dx - pintorEtiqueta.width / 2, etiquetaY),
      );

      if (!planeta.implementado) {
        final pintorEnObras = TextPainter(
          text: const TextSpan(
            text: '[EN OBRAS]',
            style: TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: PaletaCosmoSovietica.rojoOficial,
              letterSpacing: 1.6,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        pintorEnObras.paint(
          canvas,
          Offset(centro.dx - pintorEnObras.width / 2,
              centro.dy - radioPlaneta - pintorEnObras.height - 4),
        );
      }
    }
  }

  void _pintarIndicadorUbicacionActual(Canvas canvas, Size size) {
    final identificadorUbicacion = planetaUbicacionActual;
    if (identificadorUbicacion == null) return;
    final planetaActual = planetasCuadranteSigma.firstWhere(
      (planeta) => planeta.identificador == identificadorUbicacion,
      orElse: () => planetasCuadranteSigma.first,
    );
    final centro = Offset(
      planetaActual.posicionRelativa.dx * size.width,
      planetaActual.posicionRelativa.dy * size.height,
    );
    final radioPlaneta = planetaActual.radioRelativo * size.width;
    final pintorAqui = TextPainter(
      text: const TextSpan(
        text: 'USTED ESTÁ AQUÍ',
        style: TextStyle(
          fontFamily: 'CosmoMono',
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: PaletaCosmoSovietica.papelViejo,
          letterSpacing: 1.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rectFlag = Rect.fromCenter(
      center: Offset(
          centro.dx, centro.dy - radioPlaneta - pintorAqui.height - 14),
      width: pintorAqui.width + 12,
      height: pintorAqui.height + 4,
    );
    canvas.drawRect(rectFlag, Paint()..color = PaletaCosmoSovietica.rojoOficial);
    canvas.drawRect(
      rectFlag,
      Paint()
        ..color = PaletaCosmoSovietica.papelViejo
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    pintorAqui.paint(
      canvas,
      Offset(rectFlag.center.dx - pintorAqui.width / 2,
          rectFlag.center.dy - pintorAqui.height / 2),
    );
    canvas.drawLine(
      Offset(rectFlag.center.dx, rectFlag.bottom),
      Offset(centro.dx, centro.dy - radioPlaneta),
      Paint()
        ..color = PaletaCosmoSovietica.rojoOficial
        ..strokeWidth = 1.4,
    );
  }

  @override
  bool shouldRepaint(covariant PintorCuadranteSigma viejo) =>
      viejo.fase != fase ||
      viejo.planetasAccesibles.length != planetasAccesibles.length ||
      viejo.planetaDestacado != planetaDestacado ||
      viejo.planetaUbicacionActual != planetaUbicacionActual;
}
