import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

/// SPRITE COMPARTIDO DEL CADETE PARA LOS MINIJUEGOS.
///
/// Replica EXACTAMENTE el lenguaje visual de [PintorStickFigure] del
/// juego principal: cabeza circular trazada (no rellena), cuerpo de
/// palitos negros gruesos para columna/brazos/piernas, ojos como
/// pequeñas circulitas y estrella roja en el pecho. La diferencia
/// con PintorStickFigure es que aquí podemos posicionar el sprite
/// en un punto arbitrario del lienzo, no se asume que ocupa toda
/// la pantalla. Así todos los minijuegos comparten el mismo cadete
/// que el cadete jugador del modo combate.

const Color _kColorTrazo = PaletaCosmoSovietica.tintaNegra;
const Color _kColorTraje = PaletaCosmoSovietica.papelViejo;
const Color _kColorRojo = PaletaCosmoSovietica.rojoOficial;

enum PoseCadeteMinijuego {
  quieto,
  caminando,
  saltando,
  disparando,
  derrotado,
  saludando,
}

/// Dibuja el cadete stick-figure en una posición arbitraria.
///
/// - [centro] es el punto del torso (sobre la columna, a media altura).
/// - [alto] es la altura total del personaje en píxeles.
/// - [direccionMira] +1 mira a la derecha, -1 a la izquierda, 0 quieto.
/// - [pose] determina la posicion de brazos/piernas.
/// - [fasePaso] (0..1) anima el caminado cuando pose == caminando.
/// - [faseRespiracion] (0..1) anima parpadeo de ojos.
/// - [ushanka] si true dibuja gorro de invierno rojo con orejeras.
/// - [parpadeoInvulnerable] reduce alpha para indicar invulnerabilidad.
/// - [grosor] permite afinar el trazo (default 0.045 × alto).
void dibujarCadeteCosmonauta(
  Canvas canvas, {
  required Offset centro,
  required double alto,
  int direccionMira = 1,
  PoseCadeteMinijuego pose = PoseCadeteMinijuego.quieto,
  double fasePaso = 0.0,
  double faseRespiracion = 0.0,
  bool ushanka = false,
  bool parpadeoInvulnerable = false,
  double? grosor,
}) {
  final double alphaFantasma = parpadeoInvulnerable ? 0.45 : 1.0;
  final double grosorTrazo =
      grosor ?? math.max(2.0, alto * 0.045);
  final Paint pincelTrazo = Paint()
    ..color = _kColorTrazo.withValues(alpha: alphaFantasma)
    ..strokeWidth = grosorTrazo
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  final Paint pincelAcento = Paint()
    ..color = _kColorRojo.withValues(alpha: alphaFantasma)
    ..style = PaintingStyle.fill;

  // Misma proporcion que PintorStickFigure (altura = 14 unidades).
  final double unidad = alto / 14.0;
  // El centro proporcionado representa el centro del torso. La cabeza
  // queda 2.5 unidades por encima; las caderas 2.5 unidades por debajo.
  final Offset centroCabeza =
      centro.translate(0, -unidad * 3.0);
  final double radioCabeza = unidad * 1.5;
  final Offset cuello =
      Offset(centroCabeza.dx, centroCabeza.dy + radioCabeza);
  final Offset hombros = cuello.translate(0, unidad * 0.6);
  final Offset caderas = cuello.translate(0, unidad * 4.0);

  // Cabeza (circulo trazado, no relleno).
  canvas.drawCircle(centroCabeza, radioCabeza, pincelTrazo);
  // Ojos / parpadeo.
  _pintarOjosYBoca(
    canvas,
    centroCabeza,
    radioCabeza,
    pincelTrazo,
    pose: pose,
    faseRespiracion: faseRespiracion,
  );
  // CASCO de cosmonauta: burbuja transparente alrededor de la cabeza
  // con visor, antena y estrella roja. Identidad visual del cadete
  // del juego, también consistente con el stick figure principal.
  _pintarCascoCosmonautaMini(
    canvas,
    centroCabeza,
    radioCabeza,
    unidad,
    grosorTrazo,
    alphaFantasma,
  );

  // Columna.
  canvas.drawLine(cuello, caderas, pincelTrazo);

  // Estrella roja en el pecho.
  _pintarEstrella(
    canvas,
    Offset(centro.dx, (cuello.dy + caderas.dy) / 2),
    unidad * 0.55,
    pincelAcento,
  );

  // Brazos: hombro -> codo -> mano segun pose y direccion.
  final (Offset codoIzq, Offset codoDer, Offset manoIzq, Offset manoDer) =
      _calcularBrazos(hombros, unidad, pose, fasePaso, direccionMira);
  canvas.drawLine(hombros, codoIzq, pincelTrazo);
  canvas.drawLine(codoIzq, manoIzq, pincelTrazo);
  canvas.drawLine(hombros, codoDer, pincelTrazo);
  canvas.drawLine(codoDer, manoDer, pincelTrazo);

  // Piernas.
  _pintarPiernas(canvas, caderas, unidad, pose, fasePaso, pincelTrazo);

  // Gorro ushanka opcional.
  if (ushanka) {
    final Offset gorroBase =
        Offset(centroCabeza.dx, centroCabeza.dy - radioCabeza * 0.10);
    final Path camino = Path()
      ..moveTo(gorroBase.dx - radioCabeza * 1.10, gorroBase.dy)
      ..lineTo(gorroBase.dx + radioCabeza * 1.10, gorroBase.dy)
      ..lineTo(gorroBase.dx + radioCabeza * 0.85,
          gorroBase.dy - radioCabeza * 0.95)
      ..lineTo(gorroBase.dx - radioCabeza * 0.85,
          gorroBase.dy - radioCabeza * 0.95)
      ..close();
    canvas.drawPath(
      camino,
      Paint()..color = _kColorRojo.withValues(alpha: alphaFantasma),
    );
    canvas.drawPath(camino, pincelTrazo);
    // Orejeras blancas redondas.
    canvas.drawCircle(
      gorroBase.translate(-radioCabeza * 1.05, -radioCabeza * 0.30),
      radioCabeza * 0.30,
      Paint()
        ..color = PaletaCosmoSovietica.papelViejo
            .withValues(alpha: alphaFantasma),
    );
    canvas.drawCircle(
      gorroBase.translate(radioCabeza * 1.05, -radioCabeza * 0.30),
      radioCabeza * 0.30,
      Paint()
        ..color = PaletaCosmoSovietica.papelViejo
            .withValues(alpha: alphaFantasma),
    );
    canvas.drawCircle(
      gorroBase.translate(-radioCabeza * 1.05, -radioCabeza * 0.30),
      radioCabeza * 0.30,
      pincelTrazo,
    );
    canvas.drawCircle(
      gorroBase.translate(radioCabeza * 1.05, -radioCabeza * 0.30),
      radioCabeza * 0.30,
      pincelTrazo,
    );
    // Estrella roja en la frente del gorro.
    _pintarEstrella(
      canvas,
      gorroBase.translate(0, -radioCabeza * 0.55),
      radioCabeza * 0.30,
      pincelAcento,
    );
  }
}

(Offset, Offset, Offset, Offset) _calcularBrazos(
    Offset hombros, double u, PoseCadeteMinijuego pose,
    double fasePaso, int direccionMira) {
  switch (pose) {
    case PoseCadeteMinijuego.saltando:
      final codoIzq = Offset(hombros.dx - u * 1.5, hombros.dy - u * 0.4);
      final manoIzq = Offset(hombros.dx - u * 2.0, hombros.dy - u * 2.0);
      final codoDer = Offset(hombros.dx + u * 1.5, hombros.dy - u * 0.4);
      final manoDer = Offset(hombros.dx + u * 2.0, hombros.dy - u * 2.0);
      return (codoIzq, codoDer, manoIzq, manoDer);
    case PoseCadeteMinijuego.disparando:
      // Brazo dominante extendido en la direccion de mira; el otro en reposo.
      final int signoMira = direccionMira == 0 ? 1 : direccionMira;
      final codoIzq = Offset(hombros.dx - u * 1.4, hombros.dy + u * 1.4);
      final manoIzq = Offset(hombros.dx - u * 1.6, hombros.dy + u * 2.8);
      final codoDer = Offset(
          hombros.dx + signoMira * u * 1.5, hombros.dy + u * 0.4);
      final manoDer = Offset(
          hombros.dx + signoMira * u * 3.0, hombros.dy + u * 0.0);
      // Invertimos izq/der si mira a la izquierda.
      if (signoMira < 0) {
        return (codoDer, codoIzq, manoDer, manoIzq);
      }
      return (codoIzq, codoDer, manoIzq, manoDer);
    case PoseCadeteMinijuego.derrotado:
      final codoIzq = Offset(hombros.dx - u * 1.8, hombros.dy + u * 1.8);
      final manoIzq = Offset(hombros.dx - u * 2.4, hombros.dy + u * 3.2);
      final codoDer = Offset(hombros.dx + u * 1.8, hombros.dy + u * 1.8);
      final manoDer = Offset(hombros.dx + u * 2.4, hombros.dy + u * 3.2);
      return (codoIzq, codoDer, manoIzq, manoDer);
    case PoseCadeteMinijuego.saludando:
      // Saludo militar derecho.
      final codoIzq = Offset(hombros.dx - u * 1.4, hombros.dy + u * 1.6);
      final manoIzq = Offset(hombros.dx - u * 1.4, hombros.dy + u * 3.2);
      final codoDer = Offset(hombros.dx + u * 0.6, hombros.dy + u * 0.2);
      final manoDer = Offset(hombros.dx + u * 0.4, hombros.dy - u * 1.2);
      return (codoIzq, codoDer, manoIzq, manoDer);
    case PoseCadeteMinijuego.caminando:
      final double swing = math.sin(fasePaso * math.pi * 2);
      final codoIzq = Offset(hombros.dx - u * 1.0,
          hombros.dy + u * (1.4 + swing * 0.4));
      final manoIzq = Offset(hombros.dx - u * 0.9,
          hombros.dy + u * (2.8 - swing * 0.6));
      final codoDer = Offset(hombros.dx + u * 1.0,
          hombros.dy + u * (1.4 - swing * 0.4));
      final manoDer = Offset(hombros.dx + u * 0.9,
          hombros.dy + u * (2.8 + swing * 0.6));
      return (codoIzq, codoDer, manoIzq, manoDer);
    case PoseCadeteMinijuego.quieto:
      final codoIzq = Offset(hombros.dx - u * 1.3, hombros.dy + u * 1.6);
      final manoIzq = Offset(hombros.dx - u * 1.5, hombros.dy + u * 3.0);
      final codoDer = Offset(hombros.dx + u * 1.3, hombros.dy + u * 1.6);
      final manoDer = Offset(hombros.dx + u * 1.5, hombros.dy + u * 3.0);
      return (codoIzq, codoDer, manoIzq, manoDer);
  }
}

void _pintarPiernas(
  Canvas canvas,
  Offset caderas,
  double unidad,
  PoseCadeteMinijuego pose,
  double fasePaso,
  Paint pincelTrazo,
) {
  if (pose == PoseCadeteMinijuego.caminando) {
    final double swing = math.sin(fasePaso * math.pi * 2);
    final double levantaIzq = math.max(0.0, swing);
    final double levantaDer = math.max(0.0, -swing);
    final double desfaseIzq = swing * unidad * 1.0;
    final double desfaseDer = -swing * unidad * 1.0;
    final Offset pieIzq = Offset(caderas.dx - unidad * 1.2 + desfaseIzq,
        caderas.dy + unidad * (3.2 - levantaIzq * 1.2));
    final Offset pieDer = Offset(caderas.dx + unidad * 1.2 + desfaseDer,
        caderas.dy + unidad * (3.2 - levantaDer * 1.2));
    final Offset rodillaIzq = Offset(
        caderas.dx - unidad * 0.6 + desfaseIzq * 0.5,
        caderas.dy + unidad * (1.6 - levantaIzq * 0.5));
    final Offset rodillaDer = Offset(
        caderas.dx + unidad * 0.6 + desfaseDer * 0.5,
        caderas.dy + unidad * (1.6 - levantaDer * 0.5));
    canvas.drawLine(caderas, rodillaIzq, pincelTrazo);
    canvas.drawLine(rodillaIzq, pieIzq, pincelTrazo);
    canvas.drawLine(caderas, rodillaDer, pincelTrazo);
    canvas.drawLine(rodillaDer, pieDer, pincelTrazo);
  } else if (pose == PoseCadeteMinijuego.saltando) {
    final Offset pieIzq =
        Offset(caderas.dx - unidad * 0.6, caderas.dy + unidad * 2.4);
    final Offset pieDer =
        Offset(caderas.dx + unidad * 0.6, caderas.dy + unidad * 2.4);
    final Offset rodillaIzq =
        Offset(caderas.dx - unidad * 0.4, caderas.dy + unidad * 1.2);
    final Offset rodillaDer =
        Offset(caderas.dx + unidad * 0.4, caderas.dy + unidad * 1.2);
    canvas.drawLine(caderas, rodillaIzq, pincelTrazo);
    canvas.drawLine(rodillaIzq, pieIzq, pincelTrazo);
    canvas.drawLine(caderas, rodillaDer, pincelTrazo);
    canvas.drawLine(rodillaDer, pieDer, pincelTrazo);
  } else if (pose == PoseCadeteMinijuego.derrotado) {
    final Offset pieIzq =
        Offset(caderas.dx - unidad * 1.4, caderas.dy + unidad * 3.2);
    final Offset pieDer =
        Offset(caderas.dx + unidad * 1.4, caderas.dy + unidad * 3.2);
    canvas.drawLine(caderas, pieIzq, pincelTrazo);
    canvas.drawLine(caderas, pieDer, pincelTrazo);
  } else {
    final Offset pieIzq =
        Offset(caderas.dx - unidad * 1.2, caderas.dy + unidad * 3.2);
    final Offset pieDer =
        Offset(caderas.dx + unidad * 1.2, caderas.dy + unidad * 3.2);
    final Offset rodillaIzq =
        Offset(caderas.dx - unidad * 0.6, caderas.dy + unidad * 1.6);
    final Offset rodillaDer =
        Offset(caderas.dx + unidad * 0.6, caderas.dy + unidad * 1.6);
    canvas.drawLine(caderas, rodillaIzq, pincelTrazo);
    canvas.drawLine(rodillaIzq, pieIzq, pincelTrazo);
    canvas.drawLine(caderas, rodillaDer, pincelTrazo);
    canvas.drawLine(rodillaDer, pieDer, pincelTrazo);
  }
}

void _pintarOjosYBoca(
  Canvas canvas,
  Offset centroCabeza,
  double radioCabeza,
  Paint pincelTrazo, {
  required PoseCadeteMinijuego pose,
  required double faseRespiracion,
}) {
  if (pose == PoseCadeteMinijuego.derrotado) {
    // Dos cruces "X" en lugar de ojos.
    final Paint pincelCaido = Paint()
      ..color = pincelTrazo.color
      ..strokeWidth = pincelTrazo.strokeWidth * 0.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Offset ojoIzq = Offset(
        centroCabeza.dx - radioCabeza * 0.4,
        centroCabeza.dy - radioCabeza * 0.05);
    final Offset ojoDer = Offset(
        centroCabeza.dx + radioCabeza * 0.4,
        centroCabeza.dy - radioCabeza * 0.05);
    final double cruzMedio = radioCabeza * 0.22;
    for (final centroOjoCaido in [ojoIzq, ojoDer]) {
      canvas.drawLine(
          centroOjoCaido.translate(-cruzMedio, -cruzMedio),
          centroOjoCaido.translate(cruzMedio, cruzMedio),
          pincelCaido);
      canvas.drawLine(
          centroOjoCaido.translate(cruzMedio, -cruzMedio),
          centroOjoCaido.translate(-cruzMedio, cruzMedio),
          pincelCaido);
    }
    return;
  }
  final bool estaParpadeando = (faseRespiracion >= 0.0 &&
          faseRespiracion < 0.045) ||
      (faseRespiracion >= 0.48 && faseRespiracion < 0.52);
  final Paint pincelOjo = Paint()
    ..color = pincelTrazo.color
    ..strokeWidth = pincelTrazo.strokeWidth * 0.55
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  final Offset ojoIzq = Offset(
      centroCabeza.dx - radioCabeza * 0.38,
      centroCabeza.dy - radioCabeza * 0.1);
  final Offset ojoDer = Offset(
      centroCabeza.dx + radioCabeza * 0.38,
      centroCabeza.dy - radioCabeza * 0.1);
  if (estaParpadeando) {
    final double largoParpadeo = radioCabeza * 0.28;
    canvas.drawLine(
        ojoIzq.translate(-largoParpadeo * 0.5, 0),
        ojoIzq.translate(largoParpadeo * 0.5, 0),
        pincelOjo);
    canvas.drawLine(
        ojoDer.translate(-largoParpadeo * 0.5, 0),
        ojoDer.translate(largoParpadeo * 0.5, 0),
        pincelOjo);
  } else {
    canvas.drawCircle(ojoIzq, radioCabeza * 0.10,
        Paint()..color = pincelTrazo.color);
    canvas.drawCircle(ojoDer, radioCabeza * 0.10,
        Paint()..color = pincelTrazo.color);
  }
  // Boca neutra.
  canvas.drawLine(
    Offset(centroCabeza.dx - radioCabeza * 0.20,
        centroCabeza.dy + radioCabeza * 0.30),
    Offset(centroCabeza.dx + radioCabeza * 0.20,
        centroCabeza.dy + radioCabeza * 0.30),
    pincelOjo,
  );
}

/// Casco cosmonauta para los stick figures de los minijuegos.
/// Replica el aspecto del casco del [PintorStickFigure] principal:
/// burbuja transparente, visor curvo, antena con bolita roja y
/// estrella en la frente. Diseñado para ser barato de pintar.
void _pintarCascoCosmonautaMini(
  Canvas canvas,
  Offset centroCabeza,
  double radioCabeza,
  double unidad,
  double grosorTrazo,
  double alphaFantasma,
) {
  final double radioCasco = radioCabeza * 1.42;
  // Borde del casco.
  canvas.drawCircle(
    centroCabeza,
    radioCasco,
    Paint()
      ..color = _kColorTrazo.withValues(alpha: alphaFantasma)
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosorTrazo * 1.05
      ..strokeCap = StrokeCap.round,
  );
  // Reflejo interno tenue.
  canvas.drawArc(
    Rect.fromCircle(
      center: centroCabeza.translate(-radioCasco * 0.15, -radioCasco * 0.10),
      radius: radioCasco * 0.70,
    ),
    math.pi * 1.15,
    math.pi * 0.45,
    false,
    Paint()
      ..color = _kColorTraje.withValues(alpha: alphaFantasma * 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosorTrazo * 0.6,
  );
  // Visor curvo en la frente.
  canvas.drawArc(
    Rect.fromCircle(center: centroCabeza, radius: radioCasco * 0.80),
    math.pi * 1.10,
    math.pi * 0.80,
    false,
    Paint()
      ..color = _kColorTrazo.withValues(alpha: alphaFantasma * 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosorTrazo * 0.55,
  );
  // Antena con bolita roja.
  final double anguloAntena = -math.pi / 2 - 0.50;
  final Offset baseAntena = Offset(
    centroCabeza.dx + math.cos(anguloAntena) * radioCasco,
    centroCabeza.dy + math.sin(anguloAntena) * radioCasco,
  );
  final Offset puntaAntena = Offset(
    baseAntena.dx + math.cos(anguloAntena) * unidad * 0.7,
    baseAntena.dy + math.sin(anguloAntena) * unidad * 0.7,
  );
  canvas.drawLine(
    baseAntena,
    puntaAntena,
    Paint()
      ..color = _kColorTrazo.withValues(alpha: alphaFantasma)
      ..strokeWidth = grosorTrazo
      ..strokeCap = StrokeCap.round,
  );
  canvas.drawCircle(
    puntaAntena,
    unidad * 0.22,
    Paint()..color = _kColorRojo.withValues(alpha: alphaFantasma),
  );
  // Aro del cuello: dos líneas paralelas.
  final double yAroSuperior =
      centroCabeza.dy + radioCasco - grosorTrazo * 0.6;
  final double yAroInferior = yAroSuperior + grosorTrazo * 0.9;
  final double anchoAro = radioCasco * 0.85;
  final Paint pincelAroSuperior = Paint()
    ..color = _kColorTrazo.withValues(alpha: alphaFantasma)
    ..strokeWidth = grosorTrazo
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
    Offset(centroCabeza.dx - anchoAro, yAroSuperior),
    Offset(centroCabeza.dx + anchoAro, yAroSuperior),
    pincelAroSuperior,
  );
  canvas.drawLine(
    Offset(centroCabeza.dx - anchoAro * 0.92, yAroInferior),
    Offset(centroCabeza.dx + anchoAro * 0.92, yAroInferior),
    Paint()
      ..color = _kColorTrazo.withValues(alpha: alphaFantasma)
      ..strokeWidth = grosorTrazo * 0.65
      ..strokeCap = StrokeCap.round,
  );
  // Estrella roja en la frente del casco.
  _pintarEstrella(
    canvas,
    centroCabeza.translate(0, -radioCasco * 0.55),
    unidad * 0.32,
    Paint()..color = _kColorRojo.withValues(alpha: alphaFantasma),
  );
}

void _pintarEstrella(
    Canvas canvas, Offset centro, double radio, Paint pincel) {
  final Path camino = Path();
  for (int indice = 0; indice < 10; indice++) {
    final bool esExterior = indice.isEven;
    final double radioActual = esExterior ? radio : radio * 0.42;
    final double angulo = -math.pi / 2 + indice * math.pi / 5;
    final double x = centro.dx + math.cos(angulo) * radioActual;
    final double y = centro.dy + math.sin(angulo) * radioActual;
    if (indice == 0) {
      camino.moveTo(x, y);
    } else {
      camino.lineTo(x, y);
    }
  }
  camino.close();
  canvas.drawPath(camino, pincel);
}

/// CABEZA DEL CADETE COMO COMECOCOS DEL INSPEKTOR.
/// La cabeza redonda del cosmonauta abre la boca como Pac-Man.
/// Hace que el comecocos del Inspektor sea claramente "la cabeza del
/// cadete" y no un Pac-Man amarillo genérico.
void dibujarCabezaComeCocos(
  Canvas canvas, {
  required Offset centro,
  required double radio,
  required double anguloApertura,
  required double anguloBase,
  bool parpadeoInvulnerable = false,
}) {
  final double alpha = parpadeoInvulnerable ? 0.45 : 1.0;
  final Paint pincelFill = Paint()
    ..color = _kColorTraje.withValues(alpha: alpha)
    ..style = PaintingStyle.fill;
  final Paint pincelTrazo = Paint()
    ..color = _kColorTrazo.withValues(alpha: alpha)
    ..strokeWidth = math.max(1.6, radio * 0.10)
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  // Cabeza-casco redonda: relleno papelViejo + trazo negro encima.
  final Path camino = Path()
    ..moveTo(centro.dx, centro.dy)
    ..arcTo(
      Rect.fromCircle(center: centro, radius: radio),
      anguloBase + anguloApertura,
      math.pi * 2 - anguloApertura * 2,
      false,
    )
    ..close();
  canvas.drawPath(camino, pincelFill);
  canvas.drawPath(camino, pincelTrazo);
  // Visor curvo oscuro arriba (caracteristica del cosmonauta).
  canvas.drawArc(
    Rect.fromCenter(
        center: centro, width: radio * 1.5, height: radio * 0.85),
    math.pi * 1.15,
    math.pi * 0.70,
    false,
    Paint()
      ..color = _kColorTrazo.withValues(alpha: alpha * 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.0, radio * 0.15),
  );
  // Estrella roja arriba (corona).
  _pintarEstrella(
    canvas,
    centro.translate(0, -radio * 0.55),
    radio * 0.22,
    Paint()..color = _kColorRojo.withValues(alpha: alpha),
  );
}

/// CABEZA DEL CADETE COMO BOLA DE PINBALL.
/// Para el planeta Π-7: la cabeza del cosmonauta rueda; conserva
/// los ojos y la estrella roja en órbita para sugerir rotación.
void dibujarCabezaComoBola(
  Canvas canvas, {
  required Offset centro,
  required double radio,
  required double rotacion,
}) {
  final Paint pincelTrazo = Paint()
    ..color = _kColorTrazo
    ..strokeWidth = math.max(1.6, radio * 0.10)
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  // Casco circular trazado.
  canvas.drawCircle(centro, radio, pincelTrazo);
  // Pequeno casco interior tenue por el visor.
  canvas.drawCircle(
    centro,
    radio * 0.78,
    Paint()
      ..color = PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = pincelTrazo.strokeWidth * 0.6,
  );
  // Ojos rotando con la bola.
  for (final double offsetAngulo in <double>[-0.35, 0.35]) {
    final double angulo = rotacion + offsetAngulo - math.pi / 2;
    final Offset centroOjo = centro.translate(
        math.cos(angulo) * radio * 0.45,
        math.sin(angulo) * radio * 0.45);
    canvas.drawCircle(centroOjo, radio * 0.10,
        Paint()..color = _kColorTrazo);
  }
  // Estrella roja girando alrededor del centro.
  final Offset posEstrella = centro.translate(
      math.cos(rotacion + math.pi / 2) * radio * 0.55,
      math.sin(rotacion + math.pi / 2) * radio * 0.55);
  _pintarEstrella(
    canvas,
    posEstrella,
    radio * 0.18,
    Paint()..color = _kColorRojo,
  );
}

/// PIXEL ART del cadete para Cosmonauta del Píxel Perdido.
/// Plantilla 11×14 fiel al stick-figure (cabeza redonda + visor, traje
/// papelViejo, cuerpo de palo, brazos y piernas claros, estrella roja).
void dibujarCadetePixelArt(
  Canvas canvas, {
  required Offset centro,
  required double escalaPixel,
  required int direccionMira,
}) {
  // . vacio   T trazo negro   B traje papel viejo   V visor azul oscuro
  // R rojo (estrella/banda)
  const List<String> plantilla = <String>[
    '...TTTTT...',
    '..TBBBBBT..',
    '..TBVVVBT..',
    '..TBVVVBT..',
    '..TBBBBBT..',
    '...TTTTT...',
    '.T..TTT..T.',
    'T..TBBBT..T',
    '..TBRRRBT..',
    '..TBRRRBT..',
    '..TBBBBBT..',
    '...T...T...',
    '...T...T...',
    '..TT...TT..',
  ];
  final int columnas = plantilla[0].length;
  final int filas = plantilla.length;
  final double anchoTotal = columnas * escalaPixel;
  final double altoTotal = filas * escalaPixel;
  final double dirX = direccionMira < 0 ? -1.0 : 1.0;
  final double origenX = centro.dx - anchoTotal / 2 * dirX;
  final double origenY = centro.dy - altoTotal / 2;
  for (int fila = 0; fila < filas; fila++) {
    for (int columna = 0; columna < columnas; columna++) {
      final String simbolo = plantilla[fila][columna];
      if (simbolo == '.') continue;
      Color color;
      switch (simbolo) {
        case 'T':
          color = _kColorTrazo;
          break;
        case 'B':
          color = PaletaCosmoSovietica.papelViejo;
          break;
        case 'V':
          color = _kColorTrazo;
          break;
        case 'R':
          color = _kColorRojo;
          break;
        default:
          continue;
      }
      final Rect rectPix = Rect.fromLTWH(
        origenX + columna * escalaPixel * dirX,
        origenY + fila * escalaPixel,
        escalaPixel.abs(),
        escalaPixel,
      );
      canvas.drawRect(rectPix, Paint()..color = color);
    }
  }
}
