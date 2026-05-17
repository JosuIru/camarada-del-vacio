import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

/// Painter polimórfico que dibuja el efecto visual específico de una
/// habilidad sobre el sprite del objetivo. Cada identificador se mapea a
/// una composición distinta. Si llega un identificador desconocido, no se
/// pinta nada y la animación de slash genérica del portrait sigue siendo
/// la única señal visible.
class PintorEfectoHabilidad extends CustomPainter {
  final String identificadorHabilidad;
  final double progreso;
  final math.Random aleatorioFijo;

  PintorEfectoHabilidad({
    required this.identificadorHabilidad,
    required this.progreso,
  }) : aleatorioFijo = math.Random(identificadorHabilidad.hashCode);

  @override
  void paint(Canvas canvas, Size size) {
    switch (identificadorHabilidad) {
      case 'gimnasta_salto_mortal':
        _pintarSaltoMortal(canvas, size);
        break;
      case 'gimnasta_calistenia':
        _pintarOndaCalistenia(canvas, size);
        break;
      case 'gimnasta_patada_olimpica':
        _pintarPatadaOlimpica(canvas, size);
        break;
      case 'ingeniera_sabotaje':
        _pintarEngranajeSabotado(canvas, size);
        break;
      case 'ingeniera_caja_inversa':
        _pintarCajaExplotando(canvas, size);
        break;
      case 'ingeniera_cinta_inmovilizante':
        _pintarEspiralCinta(canvas, size);
        break;
      case 'comisaria_soneto_demoledor':
        _pintarVersosVolando(canvas, size);
        break;
      case 'comisaria_discurso_tedioso':
        _pintarGloboAburrimiento(canvas, size);
        break;
      case 'comisaria_cita_reglamentaria':
        _pintarPergaminoCita(canvas, size);
        break;
      case 'samovar_portatil':
        _pintarSamovarVolcado(canvas, size);
        break;
      default:
        break;
    }
  }

  double get _opacidadCurva {
    if (progreso < 0.15) return progreso / 0.15;
    if (progreso > 0.78) return (1.0 - progreso) / 0.22;
    return 1.0;
  }

  void _pintarSaltoMortal(Canvas canvas, Size size) {
    // Silueta arqueada de stick-figure pasando por encima del objetivo,
    // dibujando un arco que se desvanece tras él, terminando con polvo
    // de aterrizaje.
    final centro = Offset(size.width / 2, size.height * 0.55);
    final ancho = size.width * 0.8;
    final alto = size.height * 0.55;
    final pincelArco = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial
          .withValues(alpha: _opacidadCurva * 0.65)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final caminoArco = Path()
      ..moveTo(centro.dx - ancho / 2, centro.dy)
      ..quadraticBezierTo(centro.dx, centro.dy - alto,
          centro.dx + ancho / 2, centro.dy);
    canvas.drawPath(caminoArco, pincelArco);

    // Silueta mini del cosmonauta moviéndose por el arco.
    final fraccionTrayectoria = progreso.clamp(0.0, 1.0);
    final puntoSilueta = _evaluarBezierCuadratica(
      Offset(centro.dx - ancho / 2, centro.dy),
      Offset(centro.dx, centro.dy - alto),
      Offset(centro.dx + ancho / 2, centro.dy),
      fraccionTrayectoria,
    );
    final pincelSilueta = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
          .withValues(alpha: _opacidadCurva)
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final tamanoSilueta = size.height * 0.18;
    canvas.drawCircle(
        puntoSilueta.translate(0, -tamanoSilueta * 0.35),
        tamanoSilueta * 0.18,
        pincelSilueta..style = PaintingStyle.stroke);
    canvas.drawLine(
        puntoSilueta.translate(0, -tamanoSilueta * 0.2),
        puntoSilueta.translate(0, tamanoSilueta * 0.3),
        pincelSilueta);
    canvas.drawLine(
        puntoSilueta.translate(-tamanoSilueta * 0.3, tamanoSilueta * 0.5),
        puntoSilueta.translate(tamanoSilueta * 0.3, tamanoSilueta * 0.5),
        pincelSilueta);

    // Polvo de aterrizaje al final.
    if (progreso > 0.7) {
      final fragmentoPolvo = (progreso - 0.7) / 0.3;
      final pincelPolvo = Paint()
        ..color = PaletaCosmoSovietica.tintaTenue
            .withValues(alpha: (1.0 - fragmentoPolvo) * 0.5);
      final centroAterrizaje =
          Offset(centro.dx + ancho / 2, centro.dy);
      for (int indicePolvo = 0; indicePolvo < 5; indicePolvo++) {
        final desplazamiento = (indicePolvo - 2) * 6.0;
        canvas.drawCircle(
          Offset(centroAterrizaje.dx + desplazamiento * fragmentoPolvo,
              centroAterrizaje.dy + math.sin(indicePolvo.toDouble()) * 2),
          3 + fragmentoPolvo * 4,
          pincelPolvo,
        );
      }
    }
  }

  void _pintarOndaCalistenia(Canvas canvas, Size size) {
    final centroOnda = Offset(size.width / 2, size.height * 0.55);
    final radioOnda = size.shortestSide * (0.15 + progreso * 0.45);
    final pincelOnda = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial
          .withValues(alpha: _opacidadCurva * (1.0 - progreso) * 0.85)
      ..strokeWidth = 4 - progreso * 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(centroOnda, radioOnda, pincelOnda);
    canvas.drawCircle(
      centroOnda,
      radioOnda * 0.62,
      pincelOnda..strokeWidth = 2.0,
    );
    // Iconos mini de flexión en el borde de la onda (cosmonautas haciendo
    // gimnasia patrióticamente).
    final cantidadCosmonautas = 6;
    for (int indiceCosmonauta = 0;
        indiceCosmonauta < cantidadCosmonautas;
        indiceCosmonauta++) {
      final anguloCosmonauta =
          indiceCosmonauta * math.pi * 2 / cantidadCosmonautas +
              progreso * math.pi;
      final posicionCosmonauta = Offset(
        centroOnda.dx + math.cos(anguloCosmonauta) * radioOnda * 0.95,
        centroOnda.dy + math.sin(anguloCosmonauta) * radioOnda * 0.95,
      );
      final tamanoMiniCosmonauta = size.shortestSide * 0.05;
      final pincelMini = Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
            .withValues(alpha: _opacidadCurva * (1.0 - progreso))
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(
          posicionCosmonauta.translate(0, -tamanoMiniCosmonauta * 0.5),
          tamanoMiniCosmonauta * 0.25,
          pincelMini);
      canvas.drawLine(
        posicionCosmonauta.translate(0, -tamanoMiniCosmonauta * 0.2),
        posicionCosmonauta.translate(0, tamanoMiniCosmonauta * 0.4),
        pincelMini,
      );
      canvas.drawLine(
        posicionCosmonauta
            .translate(-tamanoMiniCosmonauta * 0.4, tamanoMiniCosmonauta * 0.1),
        posicionCosmonauta
            .translate(tamanoMiniCosmonauta * 0.4, tamanoMiniCosmonauta * 0.1),
        pincelMini,
      );
    }
  }

  void _pintarPatadaOlimpica(Canvas canvas, Size size) {
    // Banda kinésica curva: 3 arcos concéntricos que rotan, sugiriendo
    // el barrido de la pierna.
    final centroBanda = Offset(size.width / 2, size.height * 0.55);
    final pincelBanda = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial
          .withValues(alpha: _opacidadCurva * 0.75)
      ..strokeWidth = 3.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final radioBaseBanda = size.shortestSide * 0.32;
    final anguloRotacion = progreso * math.pi * 2.5;
    for (int indiceArco = 0; indiceArco < 3; indiceArco++) {
      final radioArco =
          radioBaseBanda - indiceArco * radioBaseBanda * 0.18;
      final inicioArco = anguloRotacion - math.pi * 0.6;
      canvas.drawArc(
        Rect.fromCircle(center: centroBanda, radius: radioArco),
        inicioArco,
        math.pi * 0.7,
        false,
        pincelBanda..strokeWidth = 3.6 - indiceArco * 1.0,
      );
    }
  }

  void _pintarEngranajeSabotado(Canvas canvas, Size size) {
    final centroEngranaje =
        Offset(size.width / 2, size.height * 0.45);
    final radioEngranaje = size.shortestSide * 0.22;
    final anguloEngranaje =
        progreso * math.pi * 2 * (1.0 - progreso * 0.8);
    final pincelEngranaje = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
          .withValues(alpha: _opacidadCurva * 0.9)
      ..style = PaintingStyle.fill;
    final cantidadDientes = 8;
    final caminoEngranaje = Path();
    for (int indiceDiente = 0;
        indiceDiente < cantidadDientes * 2;
        indiceDiente++) {
      final esExterior = indiceDiente % 2 == 0;
      final radioPunto =
          esExterior ? radioEngranaje : radioEngranaje * 0.7;
      final anguloPunto = indiceDiente * math.pi / cantidadDientes +
          anguloEngranaje -
          math.pi / 2;
      final x = centroEngranaje.dx + math.cos(anguloPunto) * radioPunto;
      final y = centroEngranaje.dy + math.sin(anguloPunto) * radioPunto;
      if (indiceDiente == 0) {
        caminoEngranaje.moveTo(x, y);
      } else {
        caminoEngranaje.lineTo(x, y);
      }
    }
    caminoEngranaje.close();
    canvas.drawPath(caminoEngranaje, pincelEngranaje);
    canvas.drawCircle(
      centroEngranaje,
      radioEngranaje * 0.32,
      Paint()..color = PaletaCosmoSovietica.papelViejo,
    );

    // Grieta que se abre por el medio del engranaje.
    final largoGrieta = radioEngranaje * 1.6 * progreso;
    canvas.drawLine(
      centroEngranaje.translate(-largoGrieta / 2, -radioEngranaje * 0.1),
      centroEngranaje.translate(largoGrieta / 2, radioEngranaje * 0.1),
      Paint()
        ..color = PaletaCosmoSovietica.rojoOficial
            .withValues(alpha: _opacidadCurva)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );

    // Chispas saltando.
    final cantidadChispas = 7;
    for (int indiceChispa = 0;
        indiceChispa < cantidadChispas;
        indiceChispa++) {
      final anguloChispa = indiceChispa * math.pi / cantidadChispas;
      final distanciaChispa =
          radioEngranaje * (1.2 + progreso * 0.8);
      final centroChispa = Offset(
        centroEngranaje.dx + math.cos(anguloChispa) * distanciaChispa,
        centroEngranaje.dy + math.sin(anguloChispa) * distanciaChispa,
      );
      canvas.drawCircle(
        centroChispa,
        2.0 + math.sin(progreso * math.pi * 4 + indiceChispa) * 0.8,
        Paint()
          ..color = const Color(0xFFE6B400)
              .withValues(alpha: _opacidadCurva * (1.0 - progreso)),
      );
    }
  }

  void _pintarCajaExplotando(Canvas canvas, Size size) {
    final centroCaja = Offset(size.width / 2, size.height * 0.5);
    final apertura = (progreso * 1.4).clamp(0.0, 1.0);
    final ladoCaja = size.shortestSide * 0.28;

    // Tapa abriéndose hacia arriba.
    canvas.save();
    canvas.translate(centroCaja.dx, centroCaja.dy - ladoCaja * 0.4);
    canvas.rotate(-apertura * math.pi * 0.55);
    final rectTapa = Rect.fromCenter(
      center: Offset(0, -ladoCaja * 0.1),
      width: ladoCaja * 1.05,
      height: ladoCaja * 0.18,
    );
    canvas.drawRect(
      rectTapa,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
            .withValues(alpha: _opacidadCurva * 0.85),
    );
    canvas.restore();

    // Cuerpo de la caja.
    final rectCuerpoCaja = Rect.fromCenter(
      center: centroCaja,
      width: ladoCaja,
      height: ladoCaja * 0.65,
    );
    canvas.drawRect(
      rectCuerpoCaja,
      Paint()
        ..color = PaletaCosmoSovietica.tintaTenue
            .withValues(alpha: _opacidadCurva * 0.7),
    );
    canvas.drawRect(
      rectCuerpoCaja,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
            .withValues(alpha: _opacidadCurva)
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke,
    );

    // Herramientas saliendo (líneas radiales con cabeza diferente).
    if (progreso > 0.2) {
      final fragmentoSalida = (progreso - 0.2) / 0.6;
      final cantidadHerramientas = 6;
      for (int indiceHerramienta = 0;
          indiceHerramienta < cantidadHerramientas;
          indiceHerramienta++) {
        final anguloHerramienta = -math.pi +
            indiceHerramienta * math.pi / (cantidadHerramientas - 1);
        final distanciaSalida = ladoCaja * (0.3 + fragmentoSalida * 1.2);
        final puntoCabeza = Offset(
          centroCaja.dx + math.cos(anguloHerramienta) * distanciaSalida,
          centroCaja.dy + math.sin(anguloHerramienta) * distanciaSalida * 0.7,
        );
        canvas.drawLine(
          centroCaja,
          puntoCabeza,
          Paint()
            ..color = PaletaCosmoSovietica.tintaNegra
                .withValues(alpha: _opacidadCurva * (1.0 - fragmentoSalida))
            ..strokeWidth = 2.0
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawCircle(
          puntoCabeza,
          3.0,
          Paint()
            ..color = PaletaCosmoSovietica.rojoOficial.withValues(
                alpha: _opacidadCurva * (1.0 - fragmentoSalida)),
        );
      }
    }
  }

  void _pintarEspiralCinta(Canvas canvas, Size size) {
    final centroEspiral = Offset(size.width / 2, size.height * 0.5);
    final pincelCinta = Paint()
      ..color = PaletaCosmoSovietica.tintaTenue
          .withValues(alpha: _opacidadCurva * 0.85)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;
    final caminoEspiral = Path();
    final cantidadVueltas = 3.5;
    final pasosEspiral = 80;
    for (int indicePaso = 0; indicePaso < pasosEspiral; indicePaso++) {
      final t = indicePaso / pasosEspiral;
      if (t > progreso * 1.2) break;
      final anguloEspiral = t * math.pi * 2 * cantidadVueltas;
      final radioEspiral = size.shortestSide * 0.35 * t;
      final puntoEspiral = Offset(
        centroEspiral.dx + math.cos(anguloEspiral) * radioEspiral,
        centroEspiral.dy + math.sin(anguloEspiral) * radioEspiral * 0.85,
      );
      if (indicePaso == 0) {
        caminoEspiral.moveTo(puntoEspiral.dx, puntoEspiral.dy);
      } else {
        caminoEspiral.lineTo(puntoEspiral.dx, puntoEspiral.dy);
      }
    }
    canvas.drawPath(caminoEspiral, pincelCinta);
    // Etiquetas «X» rojas pequeñas dispersas a lo largo de la cinta.
    final cantidadEtiquetas = (progreso * 4).floor().clamp(0, 4);
    for (int indiceEtiqueta = 0;
        indiceEtiqueta < cantidadEtiquetas;
        indiceEtiqueta++) {
      final t = (indiceEtiqueta + 1) / 5.0;
      final anguloEtiqueta = t * math.pi * 2 * cantidadVueltas;
      final radioEtiqueta = size.shortestSide * 0.35 * t;
      final centroEtiqueta = Offset(
        centroEspiral.dx + math.cos(anguloEtiqueta) * radioEtiqueta,
        centroEspiral.dy + math.sin(anguloEtiqueta) * radioEtiqueta * 0.85,
      );
      final pincelEtiqueta = Paint()
        ..color = PaletaCosmoSovietica.rojoOficial
            .withValues(alpha: _opacidadCurva)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;
      final ladoX = 3.5;
      canvas.drawLine(
          centroEtiqueta.translate(-ladoX, -ladoX),
          centroEtiqueta.translate(ladoX, ladoX),
          pincelEtiqueta);
      canvas.drawLine(
          centroEtiqueta.translate(ladoX, -ladoX),
          centroEtiqueta.translate(-ladoX, ladoX),
          pincelEtiqueta);
    }
  }

  void _pintarVersosVolando(Canvas canvas, Size size) {
    // 14 versos (acotación al "soneto") aparecen flotando alrededor del
    // peón, escalonados en el tiempo, escritos como pequeñas líneas
    // rectangulares (versos esquemáticos).
    final centroVersos = Offset(size.width / 2, size.height * 0.45);
    for (int indiceVerso = 0; indiceVerso < 14; indiceVerso++) {
      final tVerso = indiceVerso / 14.0;
      final fragmentoLocal = (progreso - tVerso * 0.6).clamp(0.0, 1.0);
      if (fragmentoLocal <= 0) continue;
      final anguloVerso =
          tVerso * math.pi * 2 + math.sin(indiceVerso * 1.7) * 0.3;
      final distanciaVerso =
          size.shortestSide * (0.18 + fragmentoLocal * 0.42);
      final centroVerso = Offset(
        centroVersos.dx + math.cos(anguloVerso) * distanciaVerso,
        centroVersos.dy +
            math.sin(anguloVerso) * distanciaVerso * 0.65 -
            fragmentoLocal * 10,
      );
      final opacidadVerso =
          _opacidadCurva * (1.0 - fragmentoLocal * 0.6);
      final colorVerso = indiceVerso % 4 == 0
          ? PaletaCosmoSovietica.rojoOficial
          : PaletaCosmoSovietica.tintaNegra;
      canvas.save();
      canvas.translate(centroVerso.dx, centroVerso.dy);
      canvas.rotate(math.sin(indiceVerso * 1.2) * 0.4);
      canvas.drawRect(
        const Rect.fromLTWH(-9, -1.2, 18, 2.4),
        Paint()..color = colorVerso.withValues(alpha: opacidadVerso),
      );
      canvas.drawRect(
        const Rect.fromLTWH(-7, 2.5, 10, 1.4),
        Paint()
          ..color = colorVerso.withValues(alpha: opacidadVerso * 0.7),
      );
      canvas.restore();
    }
  }

  void _pintarGloboAburrimiento(Canvas canvas, Size size) {
    final centroGlobo =
        Offset(size.width * 0.62, size.height * 0.3);
    final escalaGlobo = (0.3 + progreso * 0.7).clamp(0.0, 1.0);
    final rectGlobo = Rect.fromCenter(
      center: centroGlobo,
      width: size.shortestSide * 0.55 * escalaGlobo,
      height: size.shortestSide * 0.35 * escalaGlobo,
    );
    canvas.drawOval(
      rectGlobo,
      Paint()
        ..color = PaletaCosmoSovietica.papelViejo
            .withValues(alpha: _opacidadCurva * 0.95),
    );
    canvas.drawOval(
      rectGlobo,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
            .withValues(alpha: _opacidadCurva)
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke,
    );
    // Cola del globo hacia el peón.
    final caminoColaGlobo = Path()
      ..moveTo(rectGlobo.center.dx - rectGlobo.width * 0.3,
          rectGlobo.bottom - 2)
      ..lineTo(rectGlobo.center.dx - rectGlobo.width * 0.4,
          rectGlobo.bottom + 10)
      ..lineTo(rectGlobo.center.dx - rectGlobo.width * 0.18,
          rectGlobo.bottom + 1)
      ..close();
    canvas.drawPath(
      caminoColaGlobo,
      Paint()
        ..color = PaletaCosmoSovietica.papelViejo
            .withValues(alpha: _opacidadCurva * 0.95),
    );
    canvas.drawPath(
      caminoColaGlobo,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
            .withValues(alpha: _opacidadCurva)
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke,
    );
    // Texto "ZZZ" dentro del globo.
    if (escalaGlobo > 0.5) {
      final pintorTextoZ = TextPainter(
        text: TextSpan(
          text: 'zzz...',
          style: TextStyle(
            fontFamily: 'CosmoSerif',
            fontSize: rectGlobo.height * 0.5,
            fontWeight: FontWeight.bold,
            color: PaletaCosmoSovietica.tintaNegra
                .withValues(alpha: _opacidadCurva),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      pintorTextoZ.paint(
        canvas,
        Offset(rectGlobo.center.dx - pintorTextoZ.width / 2,
            rectGlobo.center.dy - pintorTextoZ.height / 2),
      );
    }
  }

  void _pintarPergaminoCita(Canvas canvas, Size size) {
    final centroPergamino = Offset(size.width / 2, size.height * 0.45);
    final anchoDesplegado =
        size.width * 0.7 * (0.15 + progreso * 0.85).clamp(0.0, 1.0);
    final altoPergamino = size.height * 0.45;
    final rectPergamino = Rect.fromCenter(
      center: centroPergamino,
      width: anchoDesplegado,
      height: altoPergamino,
    );
    canvas.drawRect(
      rectPergamino,
      Paint()
        ..color = PaletaCosmoSovietica.papelViejo
            .withValues(alpha: _opacidadCurva * 0.92),
    );
    canvas.drawRect(
      rectPergamino,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
            .withValues(alpha: _opacidadCurva)
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke,
    );
    // Rodillos en ambos extremos.
    final pincelRodillo = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial
          .withValues(alpha: _opacidadCurva);
    canvas.drawCircle(
      Offset(rectPergamino.left, rectPergamino.center.dy),
      altoPergamino * 0.18,
      pincelRodillo,
    );
    canvas.drawCircle(
      Offset(rectPergamino.right, rectPergamino.center.dy),
      altoPergamino * 0.18,
      pincelRodillo,
    );
    // Renglones de texto.
    if (anchoDesplegado > size.width * 0.35) {
      final pincelRenglon = Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
            .withValues(alpha: _opacidadCurva * 0.6)
        ..strokeWidth = 1.2;
      final espaciado = altoPergamino * 0.15;
      for (int indiceRenglon = 0; indiceRenglon < 5; indiceRenglon++) {
        final y = rectPergamino.top + espaciado * (indiceRenglon + 1);
        final largoRenglon =
            rectPergamino.width * (0.55 + (indiceRenglon * 0.06));
        canvas.drawLine(
          Offset(rectPergamino.left + rectPergamino.width * 0.18, y),
          Offset(
              rectPergamino.left +
                  rectPergamino.width * 0.18 +
                  largoRenglon * 0.6,
              y),
          pincelRenglon,
        );
      }
    }
  }

  void _pintarSamovarVolcado(Canvas canvas, Size size) {
    // Gotas grandes de agua cayendo sobre el peón.
    final cantidadGotasGrandes = 10;
    for (int indiceGota = 0; indiceGota < cantidadGotasGrandes; indiceGota++) {
      final desfaseGota = indiceGota / cantidadGotasGrandes;
      final tGota = ((progreso - desfaseGota * 0.4) * 1.6).clamp(0.0, 1.0);
      if (tGota <= 0) continue;
      final xGota =
          size.width * (0.15 + (indiceGota * 0.085 % 0.7));
      final yGota = tGota * size.height;
      if (yGota > size.height + 5) continue;
      final radioGotaGrande = 4.5 + math.sin(indiceGota.toDouble()) * 1.2;
      final caminoGota = Path()
        ..moveTo(xGota, yGota - radioGotaGrande * 1.6)
        ..quadraticBezierTo(xGota + radioGotaGrande * 1.2,
            yGota - radioGotaGrande * 0.1, xGota, yGota + radioGotaGrande)
        ..quadraticBezierTo(xGota - radioGotaGrande * 1.2,
            yGota - radioGotaGrande * 0.1, xGota, yGota - radioGotaGrande * 1.6)
        ..close();
      canvas.drawPath(
        caminoGota,
        Paint()
          ..color = const Color(0xFF1F4E79)
              .withValues(alpha: _opacidadCurva * (1.0 - tGota * 0.3)),
      );
      canvas.drawPath(
        caminoGota,
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra
              .withValues(alpha: _opacidadCurva * 0.8)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke,
      );
    }
  }

  Offset _evaluarBezierCuadratica(
      Offset puntoInicio, Offset puntoControl, Offset puntoFin, double t) {
    final fragmentoComplementario = 1.0 - t;
    return Offset(
      fragmentoComplementario * fragmentoComplementario * puntoInicio.dx +
          2 * fragmentoComplementario * t * puntoControl.dx +
          t * t * puntoFin.dx,
      fragmentoComplementario * fragmentoComplementario * puntoInicio.dy +
          2 * fragmentoComplementario * t * puntoControl.dy +
          t * t * puntoFin.dy,
    );
  }

  @override
  bool shouldRepaint(covariant PintorEfectoHabilidad viejo) =>
      viejo.progreso != progreso ||
      viejo.identificadorHabilidad != identificadorHabilidad;
}
