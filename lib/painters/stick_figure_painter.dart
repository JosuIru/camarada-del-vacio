import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/game_class.dart';
import '../theme.dart';

enum PoseStickFigure {
  reposoFirme,
  saludoMilitar,
  brazoAlzado,
  combateListo,
  derrotado,
  caminando,
  /// Brazos arriba en V, saltitos sincronizados. Se usa al completar
  /// misiones, ganar combates, conseguir insignias.
  celebrando,
  /// Sentado en un banco/taburete: caderas bajadas, piernas dobladas
  /// hacia adelante, espalda recta. Para NPCs en sillas, en la barra.
  sentado,
  /// Apoyado contra una pared a la izquierda: torso inclinado, mano
  /// derecha apoyada, una pierna cruzada. Para NPCs descansando.
  apoyado,
  /// Leyendo un papel sostenido con ambas manos a media altura.
  /// Cabeza ligeramente inclinada hacia abajo.
  leyendo,
}

class PintorStickFigure extends CustomPainter {
  final ClaseCosmonauta? clase;
  final PoseStickFigure pose;
  final Color colorTrazo;
  final Color colorAcento;
  final double grosorTrazo;
  final double fasePaso;

  /// Fase normalizada (0..1) del ciclo de respiración. Se usa para activar
  /// el parpadeo de ojos en dos ventanas cortas del ciclo, sin acoplar el
  /// pintor a un controlador externo.
  final double faseRespiracion;

  final String? idSombreroEquipado;
  final String? idArmaEquipada;
  final String? idTorsoEquipado;

  /// Cuando vale `false`, el painter omite todo lo que va de cuello para
  /// arriba: el círculo de la cabeza, los ojos/boca, el casco de
  /// cosmonauta y los detalles específicos de clase (gafas/banda/etc.).
  /// Pensado para casos en que la cabeza se va a superponer como
  /// `Image.asset` (PNG de cabeza por clase).
  final bool dibujarCabeza;

  /// Cuando vale `true`, el painter pinta ÚNICAMENTE el sombrero
  /// equipado y nada más. Pensado para usarse como capa overlay encima
  /// de la cabeza PNG, para que la ushanka, gorra, etc. queden visibles
  /// sobre el casco del PNG (que se dibujaría tapando al sombrero si
  /// fuera al revés). El `idSombreroEquipado` debe estar definido.
  final bool soloSombrero;

  PintorStickFigure({
    required this.clase,
    this.pose = PoseStickFigure.reposoFirme,
    this.colorTrazo = PaletaCosmoSovietica.tintaNegra,
    this.colorAcento = PaletaCosmoSovietica.rojoOficial,
    this.grosorTrazo = 3.5,
    this.fasePaso = 0,
    this.faseRespiracion = 0,
    this.idSombreroEquipado,
    this.idArmaEquipada,
    this.idTorsoEquipado,
    this.dibujarCabeza = true,
    this.soloSombrero = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pincelTrazo = Paint()
      ..color = colorTrazo
      ..strokeWidth = grosorTrazo
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final pincelAcento = Paint()
      ..color = colorAcento
      ..strokeWidth = grosorTrazo
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    final pincelAcentoTrazo = Paint()
      ..color = colorAcento
      ..strokeWidth = grosorTrazo
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final centroX = size.width / 2;
    final unidad = size.height / 14;

    // Modo "solo sombrero": pinta exclusivamente el accesorio equipado
    // como overlay encima de la cabeza PNG. Si no hay sombrero, no
    // pinta nada.
    if (soloSombrero) {
      if (idSombreroEquipado != null) {
        final centroCabeza = Offset(centroX, unidad * 2.2);
        final radioCabeza = unidad * 1.3;
        _pintarSombreroEquipado(
          canvas: canvas,
          centroCabeza: centroCabeza,
          radioCabeza: radioCabeza,
          pincelTrazo: pincelTrazo,
          pincelAcento: pincelAcento,
          pincelAcentoTrazo: pincelAcentoTrazo,
        );
      }
      return;
    }

    // BALANCEO del torso al caminar: ligero swing del eje cuello-caderas
    // para dar sensación de paso. La cadera oscila lateralmente con la
    // pierna que avanza; el cuello queda fijo verticalmente.
    final double swingTorsoBase = pose == PoseStickFigure.caminando
        ? math.sin(fasePaso * math.pi * 2) * unidad * 0.18
        : 0.0;

    final centroCabeza = Offset(centroX, unidad * 2.2);
    final radioCabeza = unidad * 1.3;
    final cuello = Offset(centroX, centroCabeza.dy + radioCabeza);
    final caderas = Offset(centroX + swingTorsoBase, cuello.dy + unidad * 4);
    final hombros = Offset(centroX, cuello.dy + unidad * 0.6);

    if (dibujarCabeza) {
      canvas.drawCircle(centroCabeza, radioCabeza, pincelTrazo);
      _pintarOjosYBoca(canvas, centroCabeza, radioCabeza, pincelTrazo);
      // Casco de cosmonauta sobre la cabeza. Si hay un sombrero
      // equipado, se dibuja DENTRO del casco (sigue siendo visible).
      _pintarCascoCosmonauta(
        canvas: canvas,
        centroCabeza: centroCabeza,
        radioCabeza: radioCabeza,
        cuello: cuello,
        hombros: hombros,
        unidad: unidad,
        pincelTrazo: pincelTrazo,
        pincelAcento: pincelAcento,
      );
    }
    canvas.drawLine(cuello, caderas, pincelTrazo);

    if (idTorsoEquipado != null) {
      _pintarTorsoEquipado(
        canvas: canvas,
        hombros: hombros,
        caderas: caderas,
        unidad: unidad,
        pincelTrazo: pincelTrazo,
        pincelAcento: pincelAcento,
      );
    }

    final (brazoIzq, brazoDer, manoIzq, manoDer) =
        _calcularBrazos(hombros, unidad);
    canvas.drawLine(hombros, brazoIzq, pincelTrazo);
    canvas.drawLine(brazoIzq, manoIzq, pincelTrazo);
    canvas.drawLine(hombros, brazoDer, pincelTrazo);
    canvas.drawLine(brazoDer, manoDer, pincelTrazo);

    if (pose == PoseStickFigure.caminando) {
      final swing = math.sin(fasePaso * math.pi * 2);
      final levantaIzq = math.max(0.0, swing);
      final levantaDer = math.max(0.0, -swing);
      final desfaseIzq = swing * unidad * 1.2;
      final desfaseDer = -swing * unidad * 1.2;
      final pieIzq = Offset(caderas.dx - unidad * 1.4 + desfaseIzq,
          caderas.dy + unidad * (3.5 - levantaIzq * 1.4));
      final pieDer = Offset(caderas.dx + unidad * 1.4 + desfaseDer,
          caderas.dy + unidad * (3.5 - levantaDer * 1.4));
      final rodillaIzq = Offset(
          caderas.dx - unidad * 0.8 + desfaseIzq * 0.5,
          caderas.dy + unidad * (1.8 - levantaIzq * 0.6));
      final rodillaDer = Offset(
          caderas.dx + unidad * 0.8 + desfaseDer * 0.5,
          caderas.dy + unidad * (1.8 - levantaDer * 0.6));
      canvas.drawLine(caderas, rodillaIzq, pincelTrazo);
      canvas.drawLine(rodillaIzq, pieIzq, pincelTrazo);
      canvas.drawLine(caderas, rodillaDer, pincelTrazo);
      canvas.drawLine(rodillaDer, pieDer, pincelTrazo);
    } else if (pose == PoseStickFigure.sentado) {
      // Piernas dobladas hacia adelante (rodillas frente al cuerpo,
      // pies más abajo). El torso baja porque la "cadera está
      // posada" pero mantenemos `caderas` como pivote: las rodillas
      // van hacia delante (eje X) en lugar de hacia abajo.
      final pieIzq = Offset(
          caderas.dx - unidad * 1.4, caderas.dy + unidad * 2.5);
      final pieDer = Offset(
          caderas.dx + unidad * 1.4, caderas.dy + unidad * 2.5);
      final rodillaIzq = Offset(
          caderas.dx - unidad * 1.6, caderas.dy + unidad * 0.4);
      final rodillaDer = Offset(
          caderas.dx + unidad * 1.6, caderas.dy + unidad * 0.4);
      canvas.drawLine(caderas, rodillaIzq, pincelTrazo);
      canvas.drawLine(rodillaIzq, pieIzq, pincelTrazo);
      canvas.drawLine(caderas, rodillaDer, pincelTrazo);
      canvas.drawLine(rodillaDer, pieDer, pincelTrazo);
    } else if (pose == PoseStickFigure.apoyado) {
      // Una pierna recta, otra cruzada por delante. Le da casualidad.
      final pieIzq = Offset(
          caderas.dx - unidad * 1.0, caderas.dy + unidad * 3.5);
      final pieDer = Offset(
          caderas.dx - unidad * 0.2, caderas.dy + unidad * 3.5);
      final rodillaIzq = Offset(
          caderas.dx - unidad * 0.8, caderas.dy + unidad * 1.8);
      final rodillaDer = Offset(
          caderas.dx + unidad * 0.3, caderas.dy + unidad * 2.0);
      canvas.drawLine(caderas, rodillaIzq, pincelTrazo);
      canvas.drawLine(rodillaIzq, pieIzq, pincelTrazo);
      canvas.drawLine(caderas, rodillaDer, pincelTrazo);
      canvas.drawLine(rodillaDer, pieDer, pincelTrazo);
    } else if (pose == PoseStickFigure.leyendo) {
      // Piernas casi juntas, postura recta.
      final pieIzq = Offset(
          caderas.dx - unidad * 0.9, caderas.dy + unidad * 3.5);
      final pieDer = Offset(
          caderas.dx + unidad * 0.9, caderas.dy + unidad * 3.5);
      final rodillaIzq = Offset(
          caderas.dx - unidad * 0.5, caderas.dy + unidad * 1.8);
      final rodillaDer = Offset(
          caderas.dx + unidad * 0.5, caderas.dy + unidad * 1.8);
      canvas.drawLine(caderas, rodillaIzq, pincelTrazo);
      canvas.drawLine(rodillaIzq, pieIzq, pincelTrazo);
      canvas.drawLine(caderas, rodillaDer, pincelTrazo);
      canvas.drawLine(rodillaDer, pieDer, pincelTrazo);
      // Dibujamos el "papel" entre las dos manos (a media altura).
      final Offset manoIzq = Offset(
          caderas.dx - unidad * 0.5, caderas.dy - unidad * 2.0);
      final Offset manoDer = Offset(
          caderas.dx + unidad * 0.5, caderas.dy - unidad * 2.0);
      final Rect rectPapel = Rect.fromLTRB(
          manoIzq.dx - unidad * 0.2,
          manoIzq.dy - unidad * 0.4,
          manoDer.dx + unidad * 0.2,
          manoDer.dy + unidad * 0.6);
      canvas.drawRect(
        rectPapel,
        Paint()..color = PaletaCosmoSovietica.papelViejo,
      );
      canvas.drawRect(
        rectPapel,
        Paint()
          ..color = colorTrazo
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      // Líneas de "texto" en el papel.
      for (int indiceLinea = 0; indiceLinea < 3; indiceLinea++) {
        canvas.drawLine(
          Offset(rectPapel.left + 3,
              rectPapel.top + 3 + indiceLinea * unidad * 0.28),
          Offset(rectPapel.right - 3,
              rectPapel.top + 3 + indiceLinea * unidad * 0.28),
          Paint()
            ..color = colorTrazo.withValues(alpha: 0.5)
            ..strokeWidth = 0.7,
        );
      }
    } else if (pose == PoseStickFigure.celebrando) {
      // Salto sincronizado: ambas piernas se levantan a la vez con
      // oscilación senoidal (cuando arriba, los pies más cerca de las
      // caderas; cuando abajo, los pies en la posición de reposo).
      final double saltito =
          (math.sin(fasePaso * math.pi * 2) + 1) / 2; // 0..1
      final double alturaSalto = unidad * 0.6 * saltito;
      final double aberturaPies = 1.4 + saltito * 0.15;
      final pieIzq = Offset(
          caderas.dx - unidad * aberturaPies,
          caderas.dy + unidad * 3.5 - alturaSalto);
      final pieDer = Offset(
          caderas.dx + unidad * aberturaPies,
          caderas.dy + unidad * 3.5 - alturaSalto);
      final rodillaIzq = Offset(
          caderas.dx - unidad * 0.7,
          caderas.dy + unidad * 1.8 - alturaSalto * 0.35);
      final rodillaDer = Offset(
          caderas.dx + unidad * 0.7,
          caderas.dy + unidad * 1.8 - alturaSalto * 0.35);
      canvas.drawLine(caderas, rodillaIzq, pincelTrazo);
      canvas.drawLine(rodillaIzq, pieIzq, pincelTrazo);
      canvas.drawLine(caderas, rodillaDer, pincelTrazo);
      canvas.drawLine(rodillaDer, pieDer, pincelTrazo);
    } else {
      final pieIzq =
          Offset(caderas.dx - unidad * 1.4, caderas.dy + unidad * 3.5);
      final pieDer =
          Offset(caderas.dx + unidad * 1.4, caderas.dy + unidad * 3.5);
      final rodillaIzq =
          Offset(caderas.dx - unidad * 0.8, caderas.dy + unidad * 1.8);
      final rodillaDer =
          Offset(caderas.dx + unidad * 0.8, caderas.dy + unidad * 1.8);
      if (pose == PoseStickFigure.derrotado) {
        canvas.drawLine(caderas, pieIzq, pincelTrazo);
        canvas.drawLine(caderas, pieDer, pincelTrazo);
      } else {
        canvas.drawLine(caderas, rodillaIzq, pincelTrazo);
        canvas.drawLine(rodillaIzq, pieIzq, pincelTrazo);
        canvas.drawLine(caderas, rodillaDer, pincelTrazo);
        canvas.drawLine(rodillaDer, pieDer, pincelTrazo);
      }
    }

    _pintarTocadoYAccesorios(
      canvas: canvas,
      centroCabeza: centroCabeza,
      radioCabeza: radioCabeza,
      manoIzq: manoIzq,
      manoDer: manoDer,
      unidad: unidad,
      pincelTrazo: pincelTrazo,
      pincelAcento: pincelAcento,
      pincelAcentoTrazo: pincelAcentoTrazo,
    );

    if (idSombreroEquipado != null && dibujarCabeza) {
      _pintarSombreroEquipado(
        canvas: canvas,
        centroCabeza: centroCabeza,
        radioCabeza: radioCabeza,
        pincelTrazo: pincelTrazo,
        pincelAcento: pincelAcento,
        pincelAcentoTrazo: pincelAcentoTrazo,
      );
    }

    if (idArmaEquipada != null) {
      _pintarArmaEquipada(
        canvas: canvas,
        manoDer: manoDer,
        manoIzq: manoIzq,
        unidad: unidad,
        pincelTrazo: pincelTrazo,
        pincelAcento: pincelAcento,
      );
    }
  }

  /// Casco esférico de cosmonauta sobre la cabeza. Es una burbuja
  /// transparente (sólo borde grueso a tinta, sin relleno opaco) un
  /// poco más grande que la cabeza, con:
  ///   - **Visor** arqueado en la frente (línea curva gruesa).
  ///   - **Reflejo** semicurvo a media altura (toque de papel claro).
  ///   - **Antena** corta vertical a la izquierda con bolita roja al final.
  ///   - **Aro del cuello** conectando casco al traje (dos líneas
  ///     paralelas a la altura del cuello).
  void _pintarCascoCosmonauta({
    required Canvas canvas,
    required Offset centroCabeza,
    required double radioCabeza,
    required Offset cuello,
    required Offset hombros,
    required double unidad,
    required Paint pincelTrazo,
    required Paint pincelAcento,
  }) {
    final double radioCasco = radioCabeza * 1.42;
    // Borde del casco. Sin relleno: vemos la cabeza/ojos por dentro.
    canvas.drawCircle(
      centroCabeza,
      radioCasco,
      Paint()
        ..color = colorTrazo
        ..style = PaintingStyle.stroke
        ..strokeWidth = grosorTrazo * 1.05
        ..strokeCap = StrokeCap.round,
    );
    // Reflejo sutil (arco interno) — da volumen al cristal.
    canvas.drawArc(
      Rect.fromCircle(
        center: centroCabeza.translate(-radioCasco * 0.15, -radioCasco * 0.10),
        radius: radioCasco * 0.70,
      ),
      math.pi * 1.15,
      math.pi * 0.45,
      false,
      Paint()
        ..color = PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = grosorTrazo * 0.6,
    );
    // Visor frontal arqueado (línea más oscura cruzando la frente).
    canvas.drawArc(
      Rect.fromCircle(center: centroCabeza, radius: radioCasco * 0.80),
      math.pi * 1.10,
      math.pi * 0.80,
      false,
      Paint()
        ..color = colorTrazo
        ..style = PaintingStyle.stroke
        ..strokeWidth = grosorTrazo * 0.55,
    );
    // Antena: tubo corto saliendo arriba-izquierda con bolita roja.
    final double anguloAntena = -math.pi / 2 - 0.50;
    final Offset baseAntena = Offset(
      centroCabeza.dx + math.cos(anguloAntena) * radioCasco,
      centroCabeza.dy + math.sin(anguloAntena) * radioCasco,
    );
    final Offset puntaAntena = Offset(
      baseAntena.dx + math.cos(anguloAntena) * unidad * 0.7,
      baseAntena.dy + math.sin(anguloAntena) * unidad * 0.7,
    );
    canvas.drawLine(baseAntena, puntaAntena, pincelTrazo);
    canvas.drawCircle(puntaAntena, unidad * 0.22, pincelAcento);
    // Aro del cuello: dos líneas horizontales gruesas justo bajo el
    // casco que sugieren la "junta" entre casco y traje.
    final double yAroSuperior =
        centroCabeza.dy + radioCasco - grosorTrazo * 0.6;
    final double yAroInferior = yAroSuperior + grosorTrazo * 0.9;
    final double anchoAro = radioCasco * 0.85;
    canvas.drawLine(
      Offset(centroCabeza.dx - anchoAro, yAroSuperior),
      Offset(centroCabeza.dx + anchoAro, yAroSuperior),
      pincelTrazo,
    );
    canvas.drawLine(
      Offset(centroCabeza.dx - anchoAro * 0.92, yAroInferior),
      Offset(centroCabeza.dx + anchoAro * 0.92, yAroInferior),
      Paint()
        ..color = colorTrazo
        ..strokeWidth = grosorTrazo * 0.65
        ..strokeCap = StrokeCap.round,
    );
    // Estrella roja en el centro de la frente del casco.
    _pintarEstrellaCascoCadete(
      canvas,
      centroCabeza.translate(0, -radioCasco * 0.55),
      unidad * 0.32,
      pincelAcento,
    );
  }

  void _pintarEstrellaCascoCadete(
      Canvas canvas, Offset centro, double radio, Paint pincel) {
    final Path camino = Path();
    for (int indicePunta = 0; indicePunta < 10; indicePunta++) {
      final bool esExterior = indicePunta.isEven;
      final double radioActual = esExterior ? radio : radio * 0.42;
      final double angulo = -math.pi / 2 + indicePunta * math.pi / 5;
      final double x = centro.dx + math.cos(angulo) * radioActual;
      final double y = centro.dy + math.sin(angulo) * radioActual;
      if (indicePunta == 0) {
        camino.moveTo(x, y);
      } else {
        camino.lineTo(x, y);
      }
    }
    camino.close();
    canvas.drawPath(camino, pincel);
  }

  void _pintarTorsoEquipado({
    required Canvas canvas,
    required Offset hombros,
    required Offset caderas,
    required double unidad,
    required Paint pincelTrazo,
    required Paint pincelAcento,
  }) {
    switch (idTorsoEquipado) {
      case 'torso_chaleco_reforzado':
        final rectChaleco = Rect.fromCenter(
          center: Offset(hombros.dx,
              (hombros.dy + caderas.dy) / 2 + unidad * 0.2),
          width: unidad * 2.8,
          height: unidad * 3.4,
        );
        canvas.drawRect(
          rectChaleco,
          Paint()..color = colorTrazo,
        );
        canvas.drawRect(
          rectChaleco,
          Paint()
            ..color = PaletaCosmoSovietica.papelViejo
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4,
        );
        for (int indice = 1; indice < 3; indice++) {
          final y =
              rectChaleco.top + rectChaleco.height * (indice / 3);
          canvas.drawLine(
            Offset(rectChaleco.left + 2, y),
            Offset(rectChaleco.right - 2, y),
            Paint()
              ..color = PaletaCosmoSovietica.papelViejo
                  .withValues(alpha: 0.6)
              ..strokeWidth = 0.8,
          );
        }
        break;
      case 'torso_capote_oficial':
        final pathCapote = Path()
          ..moveTo(hombros.dx - unidad * 1.7, hombros.dy)
          ..lineTo(hombros.dx - unidad * 2.4, caderas.dy + unidad * 0.6)
          ..lineTo(hombros.dx + unidad * 2.4, caderas.dy + unidad * 0.6)
          ..lineTo(hombros.dx + unidad * 1.7, hombros.dy)
          ..close();
        canvas.drawPath(
          pathCapote,
          Paint()..color = colorTrazo,
        );
        canvas.drawPath(pathCapote, pincelTrazo..strokeWidth = grosorTrazo);
        canvas.drawLine(
          Offset(hombros.dx, hombros.dy),
          Offset(hombros.dx, caderas.dy + unidad * 0.5),
          Paint()
            ..color = colorAcento
            ..strokeWidth = 1.6,
        );
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(
                hombros.dx - unidad * 1.0, hombros.dy + unidad * 0.6),
            width: unidad * 0.6,
            height: unidad * 0.4,
          ),
          pincelAcento,
        );
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(
                hombros.dx + unidad * 1.0, hombros.dy + unidad * 0.6),
            width: unidad * 0.6,
            height: unidad * 0.4,
          ),
          pincelAcento,
        );
        break;
    }
  }

  void _pintarArmaEquipada({
    required Canvas canvas,
    required Offset manoDer,
    required Offset manoIzq,
    required double unidad,
    required Paint pincelTrazo,
    required Paint pincelAcento,
  }) {
    switch (idArmaEquipada) {
      case 'arma_llave_inglesa':
        final mango = Rect.fromCenter(
          center: Offset(manoDer.dx + unidad * 0.4,
              manoDer.dy + unidad * 0.4),
          width: unidad * 0.4,
          height: unidad * 2.0,
        );
        canvas.save();
        canvas.translate(mango.center.dx, mango.center.dy);
        canvas.rotate(0.35);
        canvas.translate(-mango.center.dx, -mango.center.dy);
        canvas.drawRect(
          mango,
          Paint()..color = colorTrazo,
        );
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(mango.center.dx, mango.top - unidad * 0.3),
            width: unidad * 1.1,
            height: unidad * 0.7,
          ),
          Paint()..color = colorTrazo,
        );
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(mango.center.dx, mango.top - unidad * 0.3),
            width: unidad * 0.55,
            height: unidad * 0.3,
          ),
          Paint()..color = PaletaCosmoSovietica.papelViejo,
        );
        canvas.restore();
        break;
      case 'arma_remache_neumatico':
        final cuerpoPistola = Rect.fromLTWH(
          manoDer.dx,
          manoDer.dy - unidad * 0.4,
          unidad * 1.4,
          unidad * 0.7,
        );
        canvas.drawRect(
          cuerpoPistola,
          Paint()..color = colorTrazo,
        );
        canvas.drawRect(
          Rect.fromLTWH(
            cuerpoPistola.right,
            cuerpoPistola.top + unidad * 0.15,
            unidad * 0.7,
            unidad * 0.4,
          ),
          Paint()..color = colorTrazo,
        );
        canvas.drawRect(
          Rect.fromLTWH(
            cuerpoPistola.left + unidad * 0.4,
            cuerpoPistola.bottom,
            unidad * 0.4,
            unidad * 0.7,
          ),
          Paint()..color = colorTrazo,
        );
        canvas.drawCircle(
          Offset(cuerpoPistola.right + unidad * 0.7,
              cuerpoPistola.center.dy),
          unidad * 0.18,
          pincelAcento,
        );
        break;
      case 'arma_libreta_decretos':
        final rectLibreta = Rect.fromCenter(
          center: Offset(manoDer.dx + unidad * 0.5,
              manoDer.dy + unidad * 0.2),
          width: unidad * 1.4,
          height: unidad * 1.8,
        );
        canvas.drawRect(
          rectLibreta,
          Paint()..color = PaletaCosmoSovietica.papelViejo,
        );
        canvas.drawRect(rectLibreta, pincelTrazo..strokeWidth = 1.6);
        for (int indice = 1; indice < 4; indice++) {
          final y = rectLibreta.top + rectLibreta.height * (indice / 4);
          canvas.drawLine(
            Offset(rectLibreta.left + 2, y),
            Offset(rectLibreta.right - 2, y),
            Paint()
              ..color = colorTrazo
              ..strokeWidth = 0.8,
          );
        }
        canvas.drawRect(
          Rect.fromLTWH(rectLibreta.left, rectLibreta.top,
              rectLibreta.width, unidad * 0.3),
          pincelAcento,
        );
        break;
    }
  }

  void _pintarSombreroEquipado({
    required Canvas canvas,
    required Offset centroCabeza,
    required double radioCabeza,
    required Paint pincelTrazo,
    required Paint pincelAcento,
    required Paint pincelAcentoTrazo,
  }) {
    switch (idSombreroEquipado) {
      case 'gorra_cosmonauta':
        final rectGorra = Rect.fromCenter(
          center: Offset(
              centroCabeza.dx, centroCabeza.dy - radioCabeza * 0.75),
          width: radioCabeza * 2.4,
          height: radioCabeza * 0.85,
        );
        canvas.drawRect(
          rectGorra,
          Paint()..color = colorTrazo,
        );
        canvas.drawRect(rectGorra, pincelTrazo);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(
                centroCabeza.dx + radioCabeza * 0.1, rectGorra.bottom),
            width: radioCabeza * 1.4,
            height: radioCabeza * 0.18,
          ),
          Paint()..color = colorTrazo,
        );
        final centroEstrella = Offset(
            centroCabeza.dx, rectGorra.center.dy + radioCabeza * 0.02);
        _pintarEstrella(
          canvas,
          centroEstrella,
          radioCabeza * 0.32,
          pincelAcento,
        );
        break;
      case 'ushanka_termica':
        final pathUshanka = Path()
          ..moveTo(centroCabeza.dx - radioCabeza * 1.2,
              centroCabeza.dy - radioCabeza * 0.3)
          ..lineTo(centroCabeza.dx - radioCabeza * 1.4,
              centroCabeza.dy + radioCabeza * 0.4)
          ..lineTo(centroCabeza.dx - radioCabeza * 0.95,
              centroCabeza.dy + radioCabeza * 0.5)
          ..lineTo(centroCabeza.dx - radioCabeza * 0.95,
              centroCabeza.dy - radioCabeza * 0.2)
          ..lineTo(centroCabeza.dx, centroCabeza.dy - radioCabeza * 1.1)
          ..lineTo(centroCabeza.dx + radioCabeza * 0.95,
              centroCabeza.dy - radioCabeza * 0.2)
          ..lineTo(centroCabeza.dx + radioCabeza * 0.95,
              centroCabeza.dy + radioCabeza * 0.5)
          ..lineTo(centroCabeza.dx + radioCabeza * 1.4,
              centroCabeza.dy + radioCabeza * 0.4)
          ..lineTo(centroCabeza.dx + radioCabeza * 1.2,
              centroCabeza.dy - radioCabeza * 0.3)
          ..close();
        canvas.drawPath(
          pathUshanka,
          Paint()..color = colorTrazo,
        );
        canvas.drawPath(pathUshanka, pincelTrazo);
        _pintarEstrella(
          canvas,
          Offset(centroCabeza.dx, centroCabeza.dy - radioCabeza * 0.55),
          radioCabeza * 0.25,
          pincelAcento,
        );
        break;
      case 'casco_ingeniera':
        final rectCasco = Rect.fromCenter(
          center: Offset(
              centroCabeza.dx, centroCabeza.dy - radioCabeza * 0.6),
          width: radioCabeza * 2.5,
          height: radioCabeza * 1.3,
        );
        canvas.drawRect(
          rectCasco,
          Paint()..color = PaletaCosmoSovietica.papelViejo,
        );
        canvas.drawRect(rectCasco, pincelTrazo);
        canvas.drawRect(
          Rect.fromLTWH(rectCasco.left, rectCasco.bottom - 4,
              rectCasco.width, 4),
          Paint()..color = colorAcento,
        );
        canvas.drawCircle(
          Offset(rectCasco.center.dx, rectCasco.top + 4),
          3,
          pincelAcento,
        );
        break;
    }
  }

  (Offset, Offset, Offset, Offset) _calcularBrazos(Offset hombros, double u) {
    switch (pose) {
      case PoseStickFigure.brazoAlzado:
        final codoIzq = Offset(hombros.dx - u * 1.5, hombros.dy + u * 1.4);
        final manoIzq = Offset(hombros.dx - u * 2.6, hombros.dy + u * 2.6);
        final codoDer = Offset(hombros.dx + u * 1.0, hombros.dy - u * 0.6);
        final manoDer = Offset(hombros.dx + u * 1.8, hombros.dy - u * 2.4);
        return (codoIzq, codoDer, manoIzq, manoDer);
      case PoseStickFigure.saludoMilitar:
        final codoIzq = Offset(hombros.dx - u * 1.4, hombros.dy + u * 1.6);
        final manoIzq = Offset(hombros.dx - u * 1.4, hombros.dy + u * 3.2);
        final codoDer = Offset(hombros.dx + u * 0.6, hombros.dy + u * 0.2);
        final manoDer = Offset(hombros.dx + u * 0.4, hombros.dy - u * 1.2);
        return (codoIzq, codoDer, manoIzq, manoDer);
      case PoseStickFigure.combateListo:
        final codoIzq = Offset(hombros.dx - u * 1.6, hombros.dy + u * 1.0);
        final manoIzq = Offset(hombros.dx - u * 2.8, hombros.dy + u * 1.6);
        final codoDer = Offset(hombros.dx + u * 1.6, hombros.dy + u * 1.0);
        final manoDer = Offset(hombros.dx + u * 2.8, hombros.dy + u * 1.6);
        return (codoIzq, codoDer, manoIzq, manoDer);
      case PoseStickFigure.derrotado:
        final codoIzq = Offset(hombros.dx - u * 1.8, hombros.dy + u * 1.8);
        final manoIzq = Offset(hombros.dx - u * 2.6, hombros.dy + u * 3.4);
        final codoDer = Offset(hombros.dx + u * 1.8, hombros.dy + u * 1.8);
        final manoDer = Offset(hombros.dx + u * 2.6, hombros.dy + u * 3.4);
        return (codoIzq, codoDer, manoIzq, manoDer);
      case PoseStickFigure.reposoFirme:
        final codoIzq = Offset(hombros.dx - u * 1.4, hombros.dy + u * 1.6);
        final manoIzq = Offset(hombros.dx - u * 1.6, hombros.dy + u * 3.2);
        final codoDer = Offset(hombros.dx + u * 1.4, hombros.dy + u * 1.6);
        final manoDer = Offset(hombros.dx + u * 1.6, hombros.dy + u * 3.2);
        return (codoIzq, codoDer, manoIzq, manoDer);
      case PoseStickFigure.sentado:
        // Manos en las rodillas, codos hacia abajo. Pose tranquila.
        final codoIzq = Offset(hombros.dx - u * 1.0, hombros.dy + u * 1.6);
        final manoIzq = Offset(hombros.dx - u * 1.2, hombros.dy + u * 3.4);
        final codoDer = Offset(hombros.dx + u * 1.0, hombros.dy + u * 1.6);
        final manoDer = Offset(hombros.dx + u * 1.2, hombros.dy + u * 3.4);
        return (codoIzq, codoDer, manoIzq, manoDer);
      case PoseStickFigure.apoyado:
        // Brazo derecho colgado, brazo izquierdo apoyado contra una
        // pared imaginaria a la izquierda.
        final codoIzq = Offset(hombros.dx - u * 2.0, hombros.dy + u * 0.4);
        final manoIzq = Offset(hombros.dx - u * 2.6, hombros.dy + u * 0.4);
        final codoDer = Offset(hombros.dx + u * 1.4, hombros.dy + u * 1.6);
        final manoDer = Offset(hombros.dx + u * 1.6, hombros.dy + u * 3.0);
        return (codoIzq, codoDer, manoIzq, manoDer);
      case PoseStickFigure.leyendo:
        // Ambas manos juntas a media altura sosteniendo un papel.
        // Una leve respiración mueve apenas las manos.
        final double meneo =
            math.sin(faseRespiracion * math.pi * 2) * u * 0.06;
        final codoIzq = Offset(hombros.dx - u * 1.2, hombros.dy + u * 1.6);
        final manoIzq =
            Offset(hombros.dx - u * 0.5, hombros.dy + u * (2.2 + meneo));
        final codoDer = Offset(hombros.dx + u * 1.2, hombros.dy + u * 1.6);
        final manoDer =
            Offset(hombros.dx + u * 0.5, hombros.dy + u * (2.2 - meneo));
        return (codoIzq, codoDer, manoIzq, manoDer);
      case PoseStickFigure.celebrando:
        // Brazos arriba en V con pequeñas oscilaciones laterales:
        // un saludo de cosmonauta soviético con puños cerrados.
        final double meneo = math.sin(fasePaso * math.pi * 2) * 0.18;
        final codoIzq = Offset(
            hombros.dx - u * 1.5, hombros.dy - u * (0.4 + meneo));
        final manoIzq = Offset(
            hombros.dx - u * 2.4 - meneo * u * 0.4,
            hombros.dy - u * (2.4 + meneo));
        final codoDer = Offset(
            hombros.dx + u * 1.5, hombros.dy - u * (0.4 - meneo));
        final manoDer = Offset(
            hombros.dx + u * 2.4 + meneo * u * 0.4,
            hombros.dy - u * (2.4 - meneo));
        return (codoIzq, codoDer, manoIzq, manoDer);
      case PoseStickFigure.caminando:
        // Brazos con codo flexionado y movimiento alternado natural:
        // mientras la pierna izquierda avanza, el brazo derecho lo
        // hace también (contralateral). El codo se mantiene cerca
        // del cuerpo (no recto en la línea hombro-mano).
        final double swing = math.sin(fasePaso * math.pi * 2);
        final double swingPerpendicular =
            math.cos(fasePaso * math.pi * 2);
        // Brazo izquierdo: avanza/retrocede en oposición al derecho.
        final codoIzq = Offset(
          hombros.dx - u * 0.95 + swingPerpendicular * u * 0.20,
          hombros.dy + u * (1.6 + swing * 0.50),
        );
        final manoIzq = Offset(
          hombros.dx - u * 0.55 + swing * u * 0.95,
          hombros.dy + u * (2.9 - swing * 0.30),
        );
        final codoDer = Offset(
          hombros.dx + u * 0.95 - swingPerpendicular * u * 0.20,
          hombros.dy + u * (1.6 - swing * 0.50),
        );
        final manoDer = Offset(
          hombros.dx + u * 0.55 - swing * u * 0.95,
          hombros.dy + u * (2.9 + swing * 0.30),
        );
        return (codoIzq, codoDer, manoIzq, manoDer);
    }
  }

  void _pintarTocadoYAccesorios({
    required Canvas canvas,
    required Offset centroCabeza,
    required double radioCabeza,
    required Offset manoIzq,
    required Offset manoDer,
    required double unidad,
    required Paint pincelTrazo,
    required Paint pincelAcento,
    required Paint pincelAcentoTrazo,
  }) {
    if (clase == ClaseCosmonauta.gimnasta) {
      final cintaY = centroCabeza.dy - radioCabeza * 0.4;
      canvas.drawLine(
        Offset(centroCabeza.dx - radioCabeza * 1.05, cintaY),
        Offset(centroCabeza.dx + radioCabeza * 1.05, cintaY),
        pincelAcentoTrazo,
      );
      _pintarEstrella(
        canvas,
        Offset(centroCabeza.dx, cintaY),
        radioCabeza * 0.35,
        pincelAcento,
      );
    } else if (clase == ClaseCosmonauta.ingeniera) {
      final rectCasco = Rect.fromCenter(
        center: Offset(centroCabeza.dx, centroCabeza.dy - radioCabeza * 0.5),
        width: radioCabeza * 2.6,
        height: radioCabeza * 1.4,
      );
      canvas.drawRect(rectCasco, pincelTrazo);
      canvas.drawLine(
        Offset(rectCasco.left, rectCasco.bottom),
        Offset(rectCasco.right, rectCasco.bottom),
        pincelAcentoTrazo,
      );
      final puntoLlave = manoDer;
      canvas.drawLine(
        puntoLlave,
        Offset(puntoLlave.dx + unidad * 0.6, puntoLlave.dy + unidad * 1.6),
        pincelTrazo,
      );
      canvas.drawRect(
        Rect.fromCenter(
          center:
              Offset(puntoLlave.dx + unidad * 0.6, puntoLlave.dy + unidad * 1.8),
          width: unidad * 0.7,
          height: unidad * 0.4,
        ),
        pincelTrazo,
      );
    } else if (clase == ClaseCosmonauta.comisaria) {
      final ushankaTop = Offset(centroCabeza.dx, centroCabeza.dy - radioCabeza);
      final pathGorro = Path()
        ..moveTo(ushankaTop.dx - radioCabeza * 1.1, ushankaTop.dy)
        ..lineTo(ushankaTop.dx + radioCabeza * 1.1, ushankaTop.dy)
        ..lineTo(ushankaTop.dx + radioCabeza * 0.9,
            ushankaTop.dy - radioCabeza * 0.9)
        ..lineTo(ushankaTop.dx - radioCabeza * 0.9,
            ushankaTop.dy - radioCabeza * 0.9)
        ..close();
      canvas.drawPath(pathGorro, pincelTrazo);
      _pintarEstrella(
        canvas,
        Offset(ushankaTop.dx, ushankaTop.dy - radioCabeza * 0.45),
        radioCabeza * 0.35,
        pincelAcento,
      );
      final rectLibro = Rect.fromCenter(
        center: Offset(manoIzq.dx - unidad * 0.2, manoIzq.dy + unidad * 0.4),
        width: unidad * 1.2,
        height: unidad * 1.6,
      );
      canvas.drawRect(rectLibro, pincelTrazo);
      canvas.drawLine(
        Offset(rectLibro.left + 2, rectLibro.center.dy),
        Offset(rectLibro.right - 2, rectLibro.center.dy),
        pincelAcentoTrazo,
      );
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

  /// Pinta dos ojos pequeños y, opcionalmente, una línea horizontal de boca
  /// neutra. Cuando la fase respiratoria atraviesa una de dos ventanas
  /// cortas del ciclo, los ojos se convierten en rayas (parpadeo). Se evita
  /// dibujar la cara si la pose es "derrotado" para no romper la lectura
  /// dramática del cuerpo caído.
  void _pintarOjosYBoca(Canvas canvas, Offset centroCabeza,
      double radioCabeza, Paint pincelTrazo) {
    if (pose == PoseStickFigure.derrotado) {
      // En lugar de ojos, dibuja dos cruces "X" para indicar fuera de combate.
      final pincelCaido = Paint()
        ..color = pincelTrazo.color
        ..strokeWidth = pincelTrazo.strokeWidth * 0.6
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final ojoIzq = Offset(
          centroCabeza.dx - radioCabeza * 0.4, centroCabeza.dy - radioCabeza * 0.05);
      final ojoDer = Offset(
          centroCabeza.dx + radioCabeza * 0.4, centroCabeza.dy - radioCabeza * 0.05);
      final cruzMedio = radioCabeza * 0.22;
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
    final estaParpadeando = (faseRespiracion >= 0.0 &&
            faseRespiracion < 0.045) ||
        (faseRespiracion >= 0.48 && faseRespiracion < 0.52);
    final pincelOjo = Paint()
      ..color = pincelTrazo.color
      ..strokeWidth = pincelTrazo.strokeWidth * 0.55
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final ojoIzq = Offset(centroCabeza.dx - radioCabeza * 0.38,
        centroCabeza.dy - radioCabeza * 0.1);
    final ojoDer = Offset(centroCabeza.dx + radioCabeza * 0.38,
        centroCabeza.dy - radioCabeza * 0.1);
    if (estaParpadeando) {
      final largoParpadeo = radioCabeza * 0.28;
      canvas.drawLine(
          ojoIzq.translate(-largoParpadeo * 0.5, 0),
          ojoIzq.translate(largoParpadeo * 0.5, 0),
          pincelOjo);
      canvas.drawLine(
          ojoDer.translate(-largoParpadeo * 0.5, 0),
          ojoDer.translate(largoParpadeo * 0.5, 0),
          pincelOjo);
    } else {
      final radioOjo = radioCabeza * 0.13;
      canvas.drawCircle(
          ojoIzq,
          radioOjo,
          Paint()
            ..color = pincelTrazo.color
            ..style = PaintingStyle.fill);
      canvas.drawCircle(
          ojoDer,
          radioOjo,
          Paint()
            ..color = pincelTrazo.color
            ..style = PaintingStyle.fill);
    }
    // Boca neutra: línea sutil bajo los ojos.
    final pincelBoca = Paint()
      ..color = pincelTrazo.color.withValues(alpha: 0.85)
      ..strokeWidth = pincelTrazo.strokeWidth * 0.45
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(centroCabeza.dx - radioCabeza * 0.28,
          centroCabeza.dy + radioCabeza * 0.4),
      Offset(centroCabeza.dx + radioCabeza * 0.28,
          centroCabeza.dy + radioCabeza * 0.4),
      pincelBoca,
    );
  }

  @override
  bool shouldRepaint(covariant PintorStickFigure viejo) =>
      viejo.clase != clase ||
      viejo.pose != pose ||
      viejo.fasePaso != fasePaso ||
      viejo.faseRespiracion != faseRespiracion ||
      viejo.colorTrazo != colorTrazo ||
      viejo.idSombreroEquipado != idSombreroEquipado ||
      viejo.idArmaEquipada != idArmaEquipada ||
      viejo.idTorsoEquipado != idTorsoEquipado;
}
