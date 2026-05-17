import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

/// Painter polimórfico que reemplaza el sprite normal del peón durante el
/// instante "peak" del viaje de ataque. Cada habilidad transforma al
/// cosmonauta en un objeto absurdo (bola acrobática, llave inglesa girando,
/// libreta-arma...) al estilo cómico de West of Loathing.
class PintorTransformacionAtaque extends CustomPainter {
  final String identificadorHabilidad;
  final double faseTransformacion;

  PintorTransformacionAtaque({
    required this.identificadorHabilidad,
    required this.faseTransformacion,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (identificadorHabilidad) {
      case 'gimnasta_salto_mortal':
        _pintarBolaAcrobata(canvas, size);
        break;
      case 'gimnasta_patada_olimpica':
        _pintarPiernaPatada(canvas, size);
        break;
      case 'gimnasta_calistenia':
        _pintarTresCosmonautas(canvas, size);
        break;
      case 'gimnasta_pulso_cardiovascular':
        _pintarCorazonPalpitante(canvas, size);
        break;
      case 'ingeniera_sabotaje':
        _pintarLlaveInglesaGirando(canvas, size);
        break;
      case 'ingeniera_caja_inversa':
        _pintarCajaHerramientasAbierta(canvas, size);
        break;
      case 'ingeniera_cinta_inmovilizante':
        _pintarRolloCintaGirando(canvas, size);
        break;
      case 'ingeniera_parche_urgencia':
        _pintarParcheAdhesivo(canvas, size);
        break;
      case 'comisaria_decreto_realidad':
        _pintarLibretaSelloFinal(canvas, size);
        break;
      case 'comisaria_soneto_demoledor':
        _pintarAtrilConVersos(canvas, size);
        break;
      case 'comisaria_discurso_tedioso':
        _pintarMegafonoTedio(canvas, size);
        break;
      case 'comisaria_cita_reglamentaria':
        _pintarPergaminoCita(canvas, size);
        break;
      case 'samovar_portatil':
        _pintarSamovarVolando(canvas, size);
        break;
      case 'ataque_basico_melee':
        _pintarPunoExtendido(canvas, size);
        break;
      default:
        _pintarSignoExclamacion(canvas, size);
    }
  }

  // ---------- Helpers ----------

  Paint get _pincelTrazo => Paint()
    ..color = PaletaCosmoSovietica.tintaNegra
    ..strokeWidth = 2.4
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  Paint get _pincelRellenoRojo => Paint()
    ..color = PaletaCosmoSovietica.rojoOficial
    ..style = PaintingStyle.fill;

  Paint get _pincelRellenoOscuro => Paint()
    ..color = PaletaCosmoSovietica.tintaNegra
    ..style = PaintingStyle.fill;

  Paint get _pincelPapel => Paint()
    ..color = PaletaCosmoSovietica.papelViejo
    ..style = PaintingStyle.fill;

  double get _palpitacion =>
      math.sin(faseTransformacion * math.pi * 2) * 0.5 + 0.5;

  // ---------- Transformaciones específicas ----------

  /// Salto mortal patriótico: el cosmonauta se enrolla en bola, gira en el
  /// aire y aterriza con patada de karate. La animación tiene tres tramos:
  ///   • 0.00 – 0.40 → bola enrollada rotando (líneas de velocidad).
  ///   • 0.40 – 0.70 → giro a media vuelta, pierna saliendo de la bola.
  ///   • 0.70 – 1.00 → pose final de karate con patada lateral extendida.
  void _pintarBolaAcrobata(Canvas canvas, Size size) {
    final faseSalto = faseTransformacion;
    if (faseSalto < 0.40) {
      _pintarBolaEnrollada(canvas, size, faseSalto / 0.40);
    } else if (faseSalto < 0.70) {
      _pintarBolaAbriendose(
          canvas, size, (faseSalto - 0.40) / 0.30);
    } else {
      _pintarPatadaKarate(canvas, size, (faseSalto - 0.70) / 0.30);
    }
  }

  /// Fase 1: cuerpo del cosmonauta hecho un ovillo, rotando.
  void _pintarBolaEnrollada(
      Canvas canvas, Size size, double progreso) {
    final centro = Offset(size.width / 2, size.height * 0.55);
    final radio = size.shortestSide * 0.32;
    final anguloRotacion = progreso * math.pi * 4;

    // Aura de impulso roja al rotar.
    final pincelAura = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(centro, radio * 1.18, pincelAura);

    // Cuerpo de la bola (silueta).
    canvas.drawCircle(centro, radio, _pincelPapel);
    canvas.drawCircle(centro, radio, _pincelTrazo);

    // Rasgos del cosmonauta dentro de la bola, rotando: la cabeza con gorra,
    // dos brazos y dos piernas dobladas pegadas al cuerpo.
    canvas.save();
    canvas.translate(centro.dx, centro.dy);
    canvas.rotate(anguloRotacion);
    final radioCabeza = radio * 0.32;
    final centroCabeza = Offset(0, -radio * 0.35);
    canvas.drawCircle(centroCabeza, radioCabeza, _pincelPapel);
    canvas.drawCircle(centroCabeza, radioCabeza, _pincelTrazo);
    // Banda de gorra militar sobre la cabeza.
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centroCabeza.dx, centroCabeza.dy - radioCabeza * 0.65),
        width: radioCabeza * 1.7,
        height: radioCabeza * 0.4,
      ),
      _pincelRellenoOscuro,
    );
    // Brazos doblados pegados al pecho.
    canvas.drawLine(
      Offset(-radio * 0.45, 0),
      Offset(-radio * 0.05, radio * 0.05),
      _pincelTrazo,
    );
    canvas.drawLine(
      Offset(radio * 0.45, 0),
      Offset(radio * 0.05, radio * 0.05),
      _pincelTrazo,
    );
    // Piernas dobladas en forma de Z.
    canvas.drawLine(
      Offset(-radio * 0.15, radio * 0.2),
      Offset(-radio * 0.5, radio * 0.45),
      _pincelTrazo,
    );
    canvas.drawLine(
      Offset(-radio * 0.5, radio * 0.45),
      Offset(-radio * 0.2, radio * 0.6),
      _pincelTrazo,
    );
    canvas.drawLine(
      Offset(radio * 0.15, radio * 0.2),
      Offset(radio * 0.5, radio * 0.45),
      _pincelTrazo,
    );
    canvas.drawLine(
      Offset(radio * 0.5, radio * 0.45),
      Offset(radio * 0.2, radio * 0.6),
      _pincelTrazo,
    );
    canvas.restore();

    // Líneas de velocidad concéntricas a la bola.
    final pincelLineaVelocidad = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    for (int indiceLinea = 0; indiceLinea < 6; indiceLinea++) {
      final anguloLinea =
          anguloRotacion + indiceLinea * math.pi / 3;
      final inicioLinea = Offset(
        centro.dx + math.cos(anguloLinea) * radio * 1.25,
        centro.dy + math.sin(anguloLinea) * radio * 1.25,
      );
      final finLinea = Offset(
        centro.dx + math.cos(anguloLinea) * radio * 1.65,
        centro.dy + math.sin(anguloLinea) * radio * 1.65,
      );
      canvas.drawLine(inicioLinea, finLinea, pincelLineaVelocidad);
    }
  }

  /// Fase 2: la bola se abre. El cosmonauta empieza a estirar una pierna
  /// y los brazos preparando la patada.
  void _pintarBolaAbriendose(
      Canvas canvas, Size size, double progreso) {
    final centro = Offset(size.width / 2, size.height * 0.55);
    final radio = size.shortestSide * 0.3;
    // Cuerpo principal del torso (ovalado, abriéndose hacia patada).
    final altoTorso = radio * (1.6 + progreso * 0.5);
    final anchoTorso = radio * (1.0 - progreso * 0.4);
    canvas.drawOval(
      Rect.fromCenter(
          center: centro, width: anchoTorso, height: altoTorso),
      _pincelPapel,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: centro, width: anchoTorso, height: altoTorso),
      _pincelTrazo,
    );
    // Cabeza con gorra.
    final radioCabeza = radio * 0.32;
    final centroCabeza =
        Offset(centro.dx, centro.dy - altoTorso * 0.55);
    canvas.drawCircle(centroCabeza, radioCabeza, _pincelPapel);
    canvas.drawCircle(centroCabeza, radioCabeza, _pincelTrazo);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centroCabeza.dx, centroCabeza.dy - radioCabeza * 0.65),
        width: radioCabeza * 1.7,
        height: radioCabeza * 0.4,
      ),
      _pincelRellenoOscuro,
    );
    // Brazo extendido atrás (preparando la patada).
    canvas.drawLine(
      Offset(centro.dx - anchoTorso * 0.3, centro.dy - radio * 0.2),
      Offset(
        centro.dx - anchoTorso * 0.3 - radio * (0.4 + progreso * 0.4),
        centro.dy - radio * (0.3 + progreso * 0.2),
      ),
      _pincelTrazo,
    );
    // Brazo delante con puño cerrado.
    canvas.drawLine(
      Offset(centro.dx + anchoTorso * 0.3, centro.dy - radio * 0.1),
      Offset(
        centro.dx + anchoTorso * 0.5,
        centro.dy + radio * 0.05,
      ),
      _pincelTrazo,
    );
    canvas.drawCircle(
      Offset(centro.dx + anchoTorso * 0.5, centro.dy + radio * 0.05),
      radio * 0.1,
      _pincelRellenoOscuro,
    );
    // Pierna estirándose hacia la derecha (la que dará la patada).
    final largoPierna = radio * (0.6 + progreso * 1.3);
    final origenCadera = Offset(centro.dx, centro.dy + altoTorso * 0.3);
    final puntaPie = Offset(
      origenCadera.dx + largoPierna,
      origenCadera.dy - radio * 0.05 * progreso,
    );
    canvas.drawLine(
      origenCadera,
      puntaPie,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    // Bota roja al final.
    final tamanoBota = radio * 0.22;
    canvas.drawRect(
      Rect.fromCenter(
        center: puntaPie,
        width: tamanoBota * 1.2,
        height: tamanoBota,
      ),
      _pincelRellenoRojo,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: puntaPie,
        width: tamanoBota * 1.2,
        height: tamanoBota,
      ),
      _pincelTrazo,
    );
    // Pierna de apoyo doblada.
    canvas.drawLine(
      origenCadera,
      Offset(centro.dx - radio * 0.05, centro.dy + altoTorso * 0.7),
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  /// Fase 3: pose final de karate, patada lateral extendida, explosión de
  /// líneas rojas al final indicando impacto.
  void _pintarPatadaKarate(Canvas canvas, Size size, double progreso) {
    final centro = Offset(size.width * 0.42, size.height * 0.55);
    final tamano = size.shortestSide;
    final radioCabeza = tamano * 0.1;
    final centroCabeza = Offset(centro.dx, centro.dy - tamano * 0.32);
    // Cabeza.
    canvas.drawCircle(centroCabeza, radioCabeza, _pincelPapel);
    canvas.drawCircle(centroCabeza, radioCabeza, _pincelTrazo);
    // Banda roja en la frente.
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(
            centroCabeza.dx, centroCabeza.dy - radioCabeza * 0.5),
        width: radioCabeza * 2.1,
        height: radioCabeza * 0.4,
      ),
      _pincelRellenoRojo,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(
            centroCabeza.dx, centroCabeza.dy - radioCabeza * 0.5),
        width: radioCabeza * 2.1,
        height: radioCabeza * 0.4,
      ),
      _pincelTrazo,
    );
    // Ojos enfocados.
    canvas.drawCircle(
      Offset(centroCabeza.dx - radioCabeza * 0.3,
          centroCabeza.dy + radioCabeza * 0.15),
      radioCabeza * 0.12,
      _pincelRellenoOscuro,
    );
    canvas.drawCircle(
      Offset(centroCabeza.dx + radioCabeza * 0.3,
          centroCabeza.dy + radioCabeza * 0.15),
      radioCabeza * 0.12,
      _pincelRellenoOscuro,
    );
    // Boca en grito de impacto «¡HA!».
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
            centroCabeza.dx, centroCabeza.dy + radioCabeza * 0.55),
        width: radioCabeza * 0.55,
        height: radioCabeza * 0.4,
      ),
      _pincelRellenoOscuro,
    );

    // Torso recto.
    final hombros = Offset(centro.dx, centro.dy - tamano * 0.21);
    final cadera = Offset(centro.dx, centro.dy + tamano * 0.07);
    final pincelCuerpo = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(hombros, cadera, pincelCuerpo);

    // Brazo izquierdo: doblado en guardia, puño junto al pecho.
    final codoIzquierdo =
        Offset(hombros.dx - tamano * 0.1, hombros.dy + tamano * 0.05);
    final punoIzquierdo =
        Offset(hombros.dx + tamano * 0.02, hombros.dy + tamano * 0.12);
    canvas.drawLine(hombros, codoIzquierdo, pincelCuerpo);
    canvas.drawLine(codoIzquierdo, punoIzquierdo, pincelCuerpo);
    canvas.drawCircle(punoIzquierdo, tamano * 0.035, _pincelRellenoOscuro);
    // Brazo derecho: estirado atrás para balance.
    final punoDerecho =
        Offset(hombros.dx - tamano * 0.18, hombros.dy + tamano * 0.03);
    canvas.drawLine(hombros, punoDerecho, pincelCuerpo);
    canvas.drawCircle(punoDerecho, tamano * 0.035, _pincelRellenoOscuro);

    // Pierna de apoyo, ligeramente doblada (caballo).
    final rodillaApoyo =
        Offset(centro.dx - tamano * 0.03, centro.dy + tamano * 0.22);
    final pieApoyo =
        Offset(centro.dx + tamano * 0.04, centro.dy + tamano * 0.36);
    canvas.drawLine(cadera, rodillaApoyo, pincelCuerpo);
    canvas.drawLine(rodillaApoyo, pieApoyo, pincelCuerpo);

    // Pierna de patada: extendida horizontal hacia la derecha. Hacemos
    // que sobre-extienda un poco al inicio de la fase para que se note el
    // golpe.
    final estiramientoPatada = 0.95 + math.sin(progreso * math.pi) * 0.08;
    final puntaPatada = Offset(
      cadera.dx + tamano * 0.5 * estiramientoPatada,
      cadera.dy - tamano * 0.02,
    );
    canvas.drawLine(
      cadera,
      puntaPatada,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..strokeWidth = 6.5
        ..strokeCap = StrokeCap.round,
    );
    // Bota roja gigante en la punta.
    final tamanoBota = tamano * 0.11;
    canvas.drawRect(
      Rect.fromCenter(
        center: puntaPatada,
        width: tamanoBota * 1.3,
        height: tamanoBota,
      ),
      _pincelRellenoRojo,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: puntaPatada,
        width: tamanoBota * 1.3,
        height: tamanoBota,
      ),
      _pincelTrazo,
    );

    // Explosión de líneas rojas saliendo de la punta de la bota (impacto).
    final intensidadImpacto = math.sin(progreso * math.pi);
    final pincelLineaImpacto = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    for (int indiceLineaImpacto = 0;
        indiceLineaImpacto < 7;
        indiceLineaImpacto++) {
      final anguloImpacto = -math.pi / 3 +
          (indiceLineaImpacto / 6) * (math.pi * 2 / 3);
      final largoImpacto = tamano * (0.08 + intensidadImpacto * 0.12);
      final inicioImpacto = Offset(
        puntaPatada.dx + math.cos(anguloImpacto) * tamanoBota * 0.7,
        puntaPatada.dy + math.sin(anguloImpacto) * tamanoBota * 0.7,
      );
      final finImpacto = Offset(
        puntaPatada.dx + math.cos(anguloImpacto) * largoImpacto,
        puntaPatada.dy + math.sin(anguloImpacto) * largoImpacto,
      );
      canvas.drawLine(inicioImpacto, finImpacto, pincelLineaImpacto);
    }
    // Asterisco «¡POW!» encima del pie.
    final centroPow = Offset(
      puntaPatada.dx,
      puntaPatada.dy - tamano * 0.18,
    );
    for (int indicePuntaPow = 0; indicePuntaPow < 6; indicePuntaPow++) {
      final anguloPunto =
          indicePuntaPow * math.pi / 3;
      canvas.drawLine(
        centroPow,
        Offset(
          centroPow.dx + math.cos(anguloPunto) * tamano * 0.05,
          centroPow.dy + math.sin(anguloPunto) * tamano * 0.05,
        ),
        pincelLineaImpacto,
      );
    }
  }

  /// Patada Olímpica · secuencia en 3 actos: preparación con rodilla flexionada,
  /// extensión brusca, e impacto con explosión y bota soviética.
  void _pintarPiernaPatada(Canvas canvas, Size size) {
    final fase = faseTransformacion;
    final fracExtension = fase < 0.5 ? fase / 0.5 : 1.0;
    final fracImpacto = fase < 0.5 ? 0.0 : (fase - 0.5) / 0.5;

    final pincelTrazoCuerpo = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;
    final pincelTrazoFino = _pincelTrazo;

    // Cosmonauta apoyado al borde izquierdo, ligeramente inclinado.
    final centroEscena = Offset(size.width * 0.28, size.height * 0.55);
    final radioCabeza = size.width * 0.06;
    final centroCabeza = Offset(
      centroEscena.dx - size.width * 0.04,
      centroEscena.dy - size.height * 0.34,
    );
    canvas.drawCircle(centroCabeza, radioCabeza, _pincelPapel);
    canvas.drawCircle(centroCabeza, radioCabeza, pincelTrazoFino);
    // Gorra militar.
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centroCabeza.dx, centroCabeza.dy - radioCabeza * 0.6),
        width: radioCabeza * 1.9,
        height: radioCabeza * 0.4,
      ),
      _pincelRellenoOscuro,
    );

    // Torso ligeramente inclinado a la izquierda para balance.
    final hombros = centroCabeza.translate(
      size.width * 0.01,
      radioCabeza + size.height * 0.02,
    );
    final cadera = Offset(
      centroEscena.dx + size.width * 0.04,
      centroEscena.dy + size.height * 0.02,
    );
    canvas.drawLine(hombros, cadera, pincelTrazoCuerpo);

    // Brazo de balance, hacia atrás-arriba.
    canvas.drawLine(
      hombros,
      hombros.translate(-size.width * 0.13, -size.height * 0.12),
      pincelTrazoCuerpo,
    );
    // Brazo delantero al pecho con puño.
    final punoCerrado = hombros.translate(
      size.width * 0.04,
      size.height * 0.08,
    );
    canvas.drawLine(hombros, punoCerrado, pincelTrazoCuerpo);
    canvas.drawCircle(punoCerrado, size.width * 0.025, _pincelRellenoOscuro);

    // Pierna de apoyo doblada (caballo).
    final pieApoyo = Offset(
      cadera.dx - size.width * 0.03,
      cadera.dy + size.height * 0.34,
    );
    final rodillaApoyo = Offset(
      cadera.dx - size.width * 0.06,
      cadera.dy + size.height * 0.18,
    );
    canvas.drawLine(cadera, rodillaApoyo, pincelTrazoCuerpo);
    canvas.drawLine(rodillaApoyo, pieApoyo, pincelTrazoCuerpo);

    // Pierna de patada: arranca flexionada y se estira con fracExtension.
    // En reposo (fracExtension=0) la rodilla está pegada al pecho.
    // Extendida (fracExtension=1) llega al extremo derecho de la escena.
    final largoPiernaMaximo = size.width * 0.62;
    final largoActual = largoPiernaMaximo *
        Curves.easeOutBack.transform(fracExtension.clamp(0.0, 1.0));
    final puntaPatada = Offset(
      cadera.dx + largoActual,
      cadera.dy + size.height * 0.005,
    );
    // Si aún no se ha extendido del todo, dibujamos una rodilla intermedia.
    if (fracExtension < 0.6) {
      final mezclaRodilla =
          (1.0 - fracExtension / 0.6).clamp(0.0, 1.0);
      final rodillaIntermedia = Offset(
        cadera.dx + largoActual * (0.55 + mezclaRodilla * 0.2),
        cadera.dy - size.height * 0.14 * mezclaRodilla,
      );
      canvas.drawLine(cadera, rodillaIntermedia, pincelTrazoCuerpo);
      canvas.drawLine(rodillaIntermedia, puntaPatada, pincelTrazoCuerpo);
    } else {
      canvas.drawLine(cadera, puntaPatada, pincelTrazoCuerpo);
    }

    // Bota soviética en la punta, sobre-extendida durante el impacto.
    final escalaBota = 1.0 + fracImpacto * 0.18;
    final anchoBota = size.width * 0.1 * escalaBota;
    final altoBota = size.height * 0.09 * escalaBota;
    final rectBota = Rect.fromCenter(
      center: puntaPatada,
      width: anchoBota,
      height: altoBota,
    );
    canvas.drawRect(rectBota, _pincelRellenoRojo);
    canvas.drawRect(rectBota, pincelTrazoFino);
    // Suela (línea inferior gruesa).
    canvas.drawLine(
      Offset(rectBota.left, rectBota.bottom + 1),
      Offset(rectBota.right, rectBota.bottom + 1),
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..strokeWidth = 3,
    );

    // Líneas de movimiento detrás de la bota durante la extensión.
    if (fracExtension > 0.2 && fracExtension < 0.95) {
      final pincelEstela = Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
            .withValues(alpha: (1.0 - fracExtension).clamp(0.0, 1.0))
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      for (int indiceEstela = 0; indiceEstela < 4; indiceEstela++) {
        final yEstela =
            puntaPatada.dy + (indiceEstela - 1.5) * size.height * 0.04;
        canvas.drawLine(
          Offset(puntaPatada.dx - size.width * 0.12, yEstela),
          Offset(puntaPatada.dx - size.width * 0.04, yEstela),
          pincelEstela,
        );
      }
    }

    // Explosión de impacto con líneas rojas + asterisco POW.
    if (fracImpacto > 0) {
      final intensidad = math.sin(fracImpacto * math.pi);
      final pincelLineaImpacto = Paint()
        ..color = PaletaCosmoSovietica.rojoOficial
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      for (int indiceLineaImpacto = 0;
          indiceLineaImpacto < 7;
          indiceLineaImpacto++) {
        final anguloImpacto = -math.pi / 3 +
            (indiceLineaImpacto / 6.0) * (math.pi * 2 / 3);
        final inicioImpacto = Offset(
          puntaPatada.dx + math.cos(anguloImpacto) * anchoBota * 0.7,
          puntaPatada.dy + math.sin(anguloImpacto) * anchoBota * 0.7,
        );
        final finImpacto = Offset(
          puntaPatada.dx +
              math.cos(anguloImpacto) *
                  (anchoBota * 0.7 + size.width * 0.1 * intensidad),
          puntaPatada.dy +
              math.sin(anguloImpacto) *
                  (anchoBota * 0.7 + size.width * 0.1 * intensidad),
        );
        canvas.drawLine(inicioImpacto, finImpacto, pincelLineaImpacto);
      }
      // Asterisco POW arriba de la bota.
      final centroPow =
          puntaPatada.translate(0, -size.height * 0.22);
      for (int indicePuntoPow = 0; indicePuntoPow < 6; indicePuntoPow++) {
        final anguloPow = indicePuntoPow * math.pi / 3;
        canvas.drawLine(
          centroPow,
          Offset(
            centroPow.dx +
                math.cos(anguloPow) * size.width * 0.06 * intensidad,
            centroPow.dy +
                math.sin(anguloPow) * size.width * 0.06 * intensidad,
          ),
          pincelLineaImpacto,
        );
      }
    }
  }

  /// Tres cosmonautas haciendo flexiones en formación coordinada.
  void _pintarTresCosmonautas(Canvas canvas, Size size) {
    const cantidadCosmonautas = 3;
    for (int indiceCosmonauta = 0;
        indiceCosmonauta < cantidadCosmonautas;
        indiceCosmonauta++) {
      final centroX = size.width *
          (0.22 + indiceCosmonauta * 0.28);
      final centroY = size.height * 0.6 +
          math.sin(faseTransformacion * math.pi * 2 + indiceCosmonauta) *
              size.height * 0.05;
      final tamano = size.height * 0.22;
      canvas.drawCircle(
        Offset(centroX, centroY - tamano * 0.7),
        tamano * 0.25,
        _pincelTrazo..style = PaintingStyle.stroke,
      );
      canvas.drawLine(
        Offset(centroX, centroY - tamano * 0.4),
        Offset(centroX, centroY + tamano * 0.5),
        _pincelTrazo,
      );
      canvas.drawLine(
        Offset(centroX - tamano * 0.5, centroY),
        Offset(centroX + tamano * 0.5, centroY),
        _pincelTrazo,
      );
      canvas.drawLine(
        Offset(centroX, centroY + tamano * 0.5),
        Offset(centroX - tamano * 0.4, centroY + tamano),
        _pincelTrazo,
      );
      canvas.drawLine(
        Offset(centroX, centroY + tamano * 0.5),
        Offset(centroX + tamano * 0.4, centroY + tamano),
        _pincelTrazo,
      );
    }
  }

  /// Corazón rojo enorme palpitando.
  void _pintarCorazonPalpitante(Canvas canvas, Size size) {
    final centroCorazon = Offset(size.width / 2, size.height * 0.55);
    final escalaPulso = 0.85 + _palpitacion * 0.25;
    final ancho = size.width * 0.45 * escalaPulso;
    final alto = size.height * 0.5 * escalaPulso;
    final caminoCorazon = Path()
      ..moveTo(centroCorazon.dx, centroCorazon.dy + alto * 0.55)
      ..cubicTo(
        centroCorazon.dx - ancho * 0.7, centroCorazon.dy + alto * 0.15,
        centroCorazon.dx - ancho * 0.55, centroCorazon.dy - alto * 0.45,
        centroCorazon.dx, centroCorazon.dy - alto * 0.1,
      )
      ..cubicTo(
        centroCorazon.dx + ancho * 0.55, centroCorazon.dy - alto * 0.45,
        centroCorazon.dx + ancho * 0.7, centroCorazon.dy + alto * 0.15,
        centroCorazon.dx, centroCorazon.dy + alto * 0.55,
      )
      ..close();
    canvas.drawPath(caminoCorazon, _pincelRellenoRojo);
    canvas.drawPath(caminoCorazon, _pincelTrazo);
    // Brillito blanco
    canvas.drawCircle(
      centroCorazon.translate(-ancho * 0.25, -alto * 0.15),
      ancho * 0.07,
      _pincelPapel,
    );
  }

  /// Sabotaje · cosmonauta-ingeniera blande una llave inglesa enorme que
  /// gira sobre la cabeza durante 70% de la animación y al final golpea
  /// hacia abajo soltando tornillos y chispas.
  void _pintarLlaveInglesaGirando(Canvas canvas, Size size) {
    final fase = faseTransformacion;
    final estaGolpeando = fase >= 0.7;
    final progresoGiro = (fase / 0.7).clamp(0.0, 1.0);
    final progresoGolpe =
        estaGolpeando ? (fase - 0.7) / 0.3 : 0.0;

    final pincelTrazoCuerpo = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // Cosmonauta-ingeniera centrada-abajo.
    final cadera = Offset(size.width * 0.5, size.height * 0.78);
    final hombros = cadera.translate(0, -size.height * 0.22);
    final radioCabeza = size.width * 0.06;
    final centroCabeza = hombros.translate(0, -radioCabeza - size.height * 0.02);
    canvas.drawCircle(centroCabeza, radioCabeza, _pincelPapel);
    canvas.drawCircle(centroCabeza, radioCabeza, _pincelTrazo);
    // Pañuelo rojo de obrera al cuello.
    canvas.drawPath(
      Path()
        ..moveTo(hombros.dx - radioCabeza * 0.7, hombros.dy)
        ..lineTo(hombros.dx + radioCabeza * 0.7, hombros.dy)
        ..lineTo(hombros.dx, hombros.dy + radioCabeza * 0.7)
        ..close(),
      _pincelRellenoRojo,
    );
    // Torso.
    canvas.drawLine(hombros, cadera, pincelTrazoCuerpo);
    // Piernas firmes en posición caballo.
    canvas.drawLine(
      cadera,
      cadera.translate(-size.width * 0.07, size.height * 0.18),
      pincelTrazoCuerpo,
    );
    canvas.drawLine(
      cadera,
      cadera.translate(size.width * 0.07, size.height * 0.18),
      pincelTrazoCuerpo,
    );

    // Brazos sosteniendo la llave: muñeca por encima de la cabeza durante
    // el giro, baja hacia el frente durante el golpe.
    final anguloBlandir = estaGolpeando
        ? -math.pi / 2 + progresoGolpe * (math.pi / 2 + 0.6)
        : -math.pi / 2;
    final radioBrazos = size.height * 0.32;
    final centroEmpunadura = Offset(
      hombros.dx + math.cos(anguloBlandir) * radioBrazos,
      hombros.dy + math.sin(anguloBlandir) * radioBrazos,
    );
    canvas.drawLine(hombros, centroEmpunadura, pincelTrazoCuerpo);
    // Puños sobre la empuñadura.
    canvas.drawCircle(centroEmpunadura, size.width * 0.03, _pincelRellenoOscuro);

    // La llave inglesa: longitud larga, gira durante la fase 1, queda
    // alineada con el brazo durante el golpe.
    final anguloLlave = estaGolpeando
        ? anguloBlandir
        : anguloBlandir + progresoGiro * math.pi * 4;
    canvas.save();
    canvas.translate(centroEmpunadura.dx, centroEmpunadura.dy);
    canvas.rotate(anguloLlave);
    final largoLlave = size.width * 0.55;
    final grosorLlave = size.height * 0.09;
    // Mango.
    final rectMango = Rect.fromLTWH(
      0,
      -grosorLlave / 2,
      largoLlave * 0.7,
      grosorLlave,
    );
    canvas.drawRect(rectMango, _pincelRellenoOscuro);
    canvas.drawRect(rectMango, _pincelTrazo);
    // Cabeza ajustable al extremo.
    final centroCabezaLlave = Offset(largoLlave * 0.78, 0);
    final radioCabezaLlave = grosorLlave * 1.5;
    final caminoCabezaLlave = Path();
    for (int indiceVerticeLlave = 0;
        indiceVerticeLlave < 6;
        indiceVerticeLlave++) {
      final anguloVertice = indiceVerticeLlave * math.pi / 3;
      final x = centroCabezaLlave.dx +
          math.cos(anguloVertice) * radioCabezaLlave;
      final y = centroCabezaLlave.dy +
          math.sin(anguloVertice) * radioCabezaLlave;
      if (indiceVerticeLlave == 0) {
        caminoCabezaLlave.moveTo(x, y);
      } else {
        caminoCabezaLlave.lineTo(x, y);
      }
    }
    caminoCabezaLlave.close();
    canvas.drawPath(caminoCabezaLlave, _pincelRellenoOscuro);
    canvas.drawPath(caminoCabezaLlave, _pincelTrazo);
    // Mordaza ajustable (rectángulo claro).
    canvas.drawRect(
      Rect.fromLTWH(centroCabezaLlave.dx - radioCabezaLlave * 0.5,
          -grosorLlave * 0.4, radioCabezaLlave * 0.5, grosorLlave * 0.4),
      _pincelPapel,
    );
    canvas.restore();

    // Durante el giro, líneas de velocidad concéntricas alrededor de la mano.
    if (!estaGolpeando) {
      final pincelLineasVelocidad = Paint()
        ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.55)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;
      for (int indiceLineaVelocidad = 0;
          indiceLineaVelocidad < 5;
          indiceLineaVelocidad++) {
        final anguloLinea = anguloLlave + indiceLineaVelocidad * math.pi / 2.5;
        final radio = largoLlave * 1.1;
        canvas.drawLine(
          Offset(
            centroEmpunadura.dx + math.cos(anguloLinea) * radio,
            centroEmpunadura.dy + math.sin(anguloLinea) * radio,
          ),
          Offset(
            centroEmpunadura.dx + math.cos(anguloLinea) * (radio + size.width * 0.05),
            centroEmpunadura.dy + math.sin(anguloLinea) * (radio + size.width * 0.05),
          ),
          pincelLineasVelocidad,
        );
      }
    }

    // Tornillos saliendo disparados al golpear.
    if (estaGolpeando) {
      final aleatorio = math.Random(13);
      for (int indiceTornilloSaliente = 0;
          indiceTornilloSaliente < 8;
          indiceTornilloSaliente++) {
        final anguloTornillo = (aleatorio.nextDouble() * 2 - 1) * math.pi / 2;
        final largoDisparo = size.width *
            (0.18 + aleatorio.nextDouble() * 0.15) *
            progresoGolpe;
        final origenTornillo = Offset(
          centroEmpunadura.dx + math.cos(anguloBlandir) * largoLlave,
          centroEmpunadura.dy + math.sin(anguloBlandir) * largoLlave,
        );
        final destinoTornillo = origenTornillo.translate(
          math.cos(anguloTornillo) * largoDisparo,
          math.sin(anguloTornillo) * largoDisparo,
        );
        // Línea de trayectoria.
        canvas.drawLine(
          origenTornillo,
          destinoTornillo,
          Paint()
            ..color = PaletaCosmoSovietica.tintaNegra
                .withValues(alpha: (1.0 - progresoGolpe).clamp(0.0, 1.0))
            ..strokeWidth = 1.6,
        );
        // Tornillo: una pequeña X.
        final tamanoTornillo = size.width * 0.012;
        canvas.drawLine(
          destinoTornillo.translate(-tamanoTornillo, -tamanoTornillo),
          destinoTornillo.translate(tamanoTornillo, tamanoTornillo),
          Paint()
            ..color = PaletaCosmoSovietica.tintaNegra
            ..strokeWidth = 1.8,
        );
        canvas.drawLine(
          destinoTornillo.translate(tamanoTornillo, -tamanoTornillo),
          destinoTornillo.translate(-tamanoTornillo, tamanoTornillo),
          Paint()
            ..color = PaletaCosmoSovietica.tintaNegra
            ..strokeWidth = 1.8,
        );
      }
      // Chispas rojas en el punto de impacto.
      final puntoImpacto = Offset(
        centroEmpunadura.dx + math.cos(anguloBlandir) * largoLlave,
        centroEmpunadura.dy + math.sin(anguloBlandir) * largoLlave,
      );
      final intensidadImpacto = math.sin(progresoGolpe * math.pi);
      for (int indiceChispa = 0; indiceChispa < 5; indiceChispa++) {
        final anguloChispa = indiceChispa * math.pi / 2.5;
        canvas.drawLine(
          puntoImpacto,
          puntoImpacto.translate(
            math.cos(anguloChispa) * size.width * 0.06 * intensidadImpacto,
            math.sin(anguloChispa) * size.width * 0.06 * intensidadImpacto,
          ),
          Paint()
            ..color = PaletaCosmoSovietica.rojoOficial
            ..strokeWidth = 2.6
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  /// Caja de herramientas abierta volando con clavos saltando.
  void _pintarCajaHerramientasAbierta(Canvas canvas, Size size) {
    final centroCaja = Offset(size.width / 2, size.height * 0.6);
    final anchoCaja = size.width * 0.55;
    final altoCaja = size.height * 0.32;
    final rectCaja = Rect.fromCenter(
      center: centroCaja,
      width: anchoCaja,
      height: altoCaja,
    );
    canvas.drawRect(rectCaja, _pincelPapel);
    canvas.drawRect(rectCaja, _pincelTrazo);
    // Tapa abierta arriba
    canvas.save();
    canvas.translate(centroCaja.dx - anchoCaja * 0.3,
        centroCaja.dy - altoCaja * 0.5);
    canvas.rotate(-0.5);
    canvas.drawRect(
      Rect.fromLTWH(0, -altoCaja * 0.1, anchoCaja * 0.6, altoCaja * 0.18),
      _pincelRellenoOscuro,
    );
    canvas.restore();
    // Clavos/herramientas saltando hacia arriba
    for (int indiceHerramientaSaltando = 0;
        indiceHerramientaSaltando < 5;
        indiceHerramientaSaltando++) {
      final x = centroCaja.dx +
          (indiceHerramientaSaltando - 2) * anchoCaja * 0.18;
      final yBase = centroCaja.dy - altoCaja * 0.55;
      final yAltura =
          yBase - altoCaja * (0.3 + indiceHerramientaSaltando * 0.07);
      canvas.drawLine(
        Offset(x, yBase),
        Offset(x, yAltura),
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(Offset(x, yAltura), 2.0, _pincelRellenoRojo);
    }
  }

  /// Rollo de cinta adhesiva gigante girando.
  void _pintarRolloCintaGirando(Canvas canvas, Size size) {
    final centroRollo = Offset(size.width / 2, size.height * 0.55);
    final radioExt = size.shortestSide * 0.36;
    canvas.save();
    canvas.translate(centroRollo.dx, centroRollo.dy);
    canvas.rotate(faseTransformacion * math.pi * 4);
    canvas.drawCircle(Offset.zero, radioExt, _pincelRellenoRojo);
    canvas.drawCircle(Offset.zero, radioExt, _pincelTrazo);
    canvas.drawCircle(Offset.zero, radioExt * 0.45, _pincelPapel);
    canvas.drawCircle(
        Offset.zero, radioExt * 0.45, _pincelTrazo);
    // Tira que se desenrolla
    canvas.drawRect(
      Rect.fromLTWH(radioExt, -radioExt * 0.15,
          radioExt * 0.7, radioExt * 0.3),
      _pincelRellenoRojo,
    );
    canvas.drawRect(
      Rect.fromLTWH(radioExt, -radioExt * 0.15,
          radioExt * 0.7, radioExt * 0.3),
      _pincelTrazo,
    );
    canvas.restore();
  }

  /// Parche adhesivo en X cubriendo todo.
  void _pintarParcheAdhesivo(Canvas canvas, Size size) {
    final centroParche = Offset(size.width / 2, size.height * 0.55);
    final ladoParche = size.shortestSide * 0.7;
    for (final inclinacion in [0.3, -0.3]) {
      canvas.save();
      canvas.translate(centroParche.dx, centroParche.dy);
      canvas.rotate(inclinacion);
      final rectTira = Rect.fromCenter(
        center: Offset.zero,
        width: ladoParche,
        height: ladoParche * 0.32,
      );
      canvas.drawRect(rectTira, _pincelRellenoRojo);
      canvas.drawRect(rectTira, _pincelTrazo);
      // Líneas de costura
      for (int indiceCostura = 0; indiceCostura < 4; indiceCostura++) {
        final x = rectTira.left + (indiceCostura + 0.5) * rectTira.width / 4;
        canvas.drawLine(
          Offset(x, rectTira.top + 4),
          Offset(x, rectTira.bottom - 4),
          Paint()
            ..color = PaletaCosmoSovietica.tintaNegra
            ..strokeWidth = 1.0,
        );
      }
      canvas.restore();
    }
  }

  /// Decreto de Realidad · El sello oficial cae desde arriba, golpea el
  /// papel y deja una huella roja con estrella. Secuencia:
  ///   • 0.00 – 0.60 → sello descendiendo con sombra creciente bajo él.
  ///   • 0.60 – 0.75 → impacto (sello deformado, salpicaduras de tinta).
  ///   • 0.75 – 1.00 → sello se eleva dejando huella nítida.
  void _pintarLibretaSelloFinal(Canvas canvas, Size size) {
    final centroPapel = Offset(size.width / 2, size.height * 0.65);
    final anchoPapel = size.width * 0.7;
    final altoPapel = size.height * 0.36;
    final rectPapel = Rect.fromCenter(
      center: centroPapel,
      width: anchoPapel,
      height: altoPapel,
    );
    // Papel oficial F-447 con encabezado rojo.
    canvas.drawRect(rectPapel, _pincelPapel);
    final rectEncabezado = Rect.fromLTWH(
      rectPapel.left,
      rectPapel.top,
      rectPapel.width,
      altoPapel * 0.18,
    );
    canvas.drawRect(rectEncabezado, _pincelRellenoRojo);
    canvas.drawRect(rectPapel, _pincelTrazo);
    canvas.drawRect(rectEncabezado, _pincelTrazo);
    // «F-447» garabateado en el encabezado.
    final pincelTextoEncabezado = Paint()
      ..color = PaletaCosmoSovietica.papelViejo
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(rectEncabezado.left + 8, rectEncabezado.center.dy),
      Offset(rectEncabezado.left + 60, rectEncabezado.center.dy),
      pincelTextoEncabezado,
    );
    // Renglones en el papel.
    final pincelRenglonTenue = Paint()
      ..color = PaletaCosmoSovietica.tintaTenue
      ..strokeWidth = 0.8;
    for (int indiceRenglon = 0; indiceRenglon < 4; indiceRenglon++) {
      final yRenglon = rectPapel.top +
          altoPapel * (0.32 + indiceRenglon * 0.16);
      canvas.drawLine(
        Offset(rectPapel.left + 12, yRenglon),
        Offset(rectPapel.right - 12, yRenglon),
        pincelRenglonTenue,
      );
    }

    final fase = faseTransformacion;
    final radioSello = size.width * 0.16;

    // Centro del sello: arranca arriba, cae hasta justo encima del papel.
    final yDescenso = Curves.easeInQuad.transform(fase.clamp(0.0, 1.0));
    final yPapel = centroPapel.dy - radioSello * 0.2;
    final yArriba = size.height * 0.08;
    double yCentroSello = yArriba + (yPapel - yArriba) * yDescenso.clamp(0.0, 1.0);

    // En la fase de impacto rebota un poco arriba.
    if (fase > 0.6 && fase < 0.75) {
      final fracImpacto = (fase - 0.6) / 0.15;
      yCentroSello = yPapel + math.sin(fracImpacto * math.pi) * radioSello * 0.18;
    } else if (fase >= 0.75) {
      final fracRetirada = (fase - 0.75) / 0.25;
      yCentroSello =
          yPapel - radioSello * 0.6 * Curves.easeOutCubic.transform(fracRetirada);
    }

    final centroSello = Offset(centroPapel.dx, yCentroSello);

    // Si el sello ya impactó al menos una vez (fase > 0.6) dibujamos la
    // huella roja con estrella en el papel.
    if (fase > 0.6) {
      final opacidadHuella =
          fase > 0.75 ? 1.0 : ((fase - 0.6) / 0.15).clamp(0.0, 1.0);
      final centroHuella = Offset(centroPapel.dx, yPapel);
      canvas.drawCircle(
        centroHuella,
        radioSello,
        Paint()
          ..color =
              PaletaCosmoSovietica.rojoOficial.withValues(alpha: opacidadHuella)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.4,
      );
      canvas.drawCircle(
        centroHuella,
        radioSello * 0.78,
        Paint()
          ..color = PaletaCosmoSovietica.rojoOficial
              .withValues(alpha: opacidadHuella * 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3,
      );
      _dibujarEstrellaInterna(
        canvas,
        centroHuella,
        radioSello * 0.55,
        Paint()
          ..color =
              PaletaCosmoSovietica.rojoOficial.withValues(alpha: opacidadHuella),
      );

      // Salpicaduras de tinta en el momento de impacto.
      if (fase < 0.78) {
        final intensidad = math.sin(((fase - 0.6) / 0.18).clamp(0.0, 1.0) * math.pi);
        final aleatorioSalpique = math.Random(7);
        for (int indiceSalpique = 0; indiceSalpique < 8; indiceSalpique++) {
          final anguloSalpique = aleatorioSalpique.nextDouble() * math.pi * 2;
          final radioSalpique =
              radioSello * (1.0 + aleatorioSalpique.nextDouble() * 0.6);
          final centroSalpique = Offset(
            centroHuella.dx + math.cos(anguloSalpique) * radioSalpique,
            centroHuella.dy + math.sin(anguloSalpique) * radioSalpique * 0.4,
          );
          canvas.drawCircle(
            centroSalpique,
            (1.6 + aleatorioSalpique.nextDouble() * 1.5) * intensidad,
            Paint()
              ..color = PaletaCosmoSovietica.rojoOficial
                  .withValues(alpha: 0.85 * intensidad),
          );
        }
      }
    }

    // Sombra del sello sobre el papel (cuanto más bajo, más definida).
    final intensidadSombra = (yDescenso).clamp(0.0, 1.0);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centroPapel.dx, yPapel + radioSello * 0.5),
        width: radioSello * 2 * (0.5 + intensidadSombra * 0.7),
        height: radioSello * 0.4 * (0.4 + intensidadSombra),
      ),
      Paint()
        ..color =
            PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.18 * intensidadSombra),
    );

    // El sello en sí: rectángulo vertical de mango + bloque redondo abajo
    // con estrella tallada.
    final escalaImpacto =
        fase > 0.6 && fase < 0.75 ? (1.0 + math.sin(((fase - 0.6) / 0.15) * math.pi) * 0.12) : 1.0;
    final anchoSelloEscalado = radioSello * 2 * escalaImpacto;
    final altoBloqueSello = radioSello * 0.65 * escalaImpacto;
    final rectBloqueSello = Rect.fromCenter(
      center: centroSello,
      width: anchoSelloEscalado,
      height: altoBloqueSello,
    );
    canvas.drawRect(
      rectBloqueSello,
      Paint()..color = PaletaCosmoSovietica.rojoOficial,
    );
    canvas.drawRect(rectBloqueSello, _pincelTrazo);
    // Estrella tallada en la cara del sello.
    _dibujarEstrellaInterna(
      canvas,
      centroSello,
      radioSello * 0.45,
      Paint()..color = PaletaCosmoSovietica.papelViejo,
    );
    // Mango cilíndrico saliendo hacia arriba.
    final altoMango = radioSello * 1.3;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centroSello.dx, centroSello.dy - altoBloqueSello / 2 - altoMango / 2),
        width: radioSello * 0.6,
        height: altoMango,
      ),
      _pincelRellenoOscuro,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centroSello.dx, centroSello.dy - altoBloqueSello / 2 - altoMango / 2),
        width: radioSello * 0.6,
        height: altoMango,
      ),
      _pincelTrazo,
    );
    // Pomo redondo encima del mango.
    canvas.drawCircle(
      Offset(centroSello.dx, centroSello.dy - altoBloqueSello / 2 - altoMango - radioSello * 0.18),
      radioSello * 0.32,
      _pincelRellenoOscuro,
    );
    canvas.drawCircle(
      Offset(centroSello.dx, centroSello.dy - altoBloqueSello / 2 - altoMango - radioSello * 0.18),
      radioSello * 0.32,
      _pincelTrazo,
    );
  }

  void _dibujarEstrellaInterna(
      Canvas canvas, Offset centro, double radio, Paint pincel) {
    final camino = Path();
    const cantidadPuntas = 5;
    for (int indicePunto = 0;
        indicePunto < cantidadPuntas * 2;
        indicePunto++) {
      final esExterior = indicePunto % 2 == 0;
      final radioActual = esExterior ? radio : radio * 0.42;
      final angulo =
          -math.pi / 2 + indicePunto * math.pi / cantidadPuntas;
      final x = centro.dx + math.cos(angulo) * radioActual;
      final y = centro.dy + math.sin(angulo) * radioActual;
      if (indicePunto == 0) {
        camino.moveTo(x, y);
      } else {
        camino.lineTo(x, y);
      }
    }
    camino.close();
    canvas.drawPath(camino, pincel);
  }

  /// Atril con versos saliendo en cascada.
  void _pintarAtrilConVersos(Canvas canvas, Size size) {
    final puntoBaseAtril = Offset(size.width / 2, size.height * 0.9);
    // Soporte
    canvas.drawLine(
      puntoBaseAtril,
      puntoBaseAtril.translate(0, -size.height * 0.6),
      _pincelTrazo..strokeWidth = 3.4,
    );
    // Atril (rombo inclinado)
    final rectAtril = Rect.fromCenter(
      center: puntoBaseAtril.translate(0, -size.height * 0.6),
      width: size.width * 0.4,
      height: size.height * 0.2,
    );
    canvas.save();
    canvas.translate(rectAtril.center.dx, rectAtril.center.dy);
    canvas.rotate(-0.18);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: rectAtril.width,
        height: rectAtril.height,
      ),
      _pincelPapel,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: rectAtril.width,
        height: rectAtril.height,
      ),
      _pincelTrazo..strokeWidth = 2.2,
    );
    canvas.restore();
    // 14 versos volando hacia arriba con desfase.
    for (int indiceVerso = 0; indiceVerso < 14; indiceVerso++) {
      final tVerso = (indiceVerso / 14.0 + faseTransformacion) % 1.0;
      final xVerso = rectAtril.center.dx +
          (math.sin(indiceVerso * 0.9) * size.width * 0.35);
      final yVerso = rectAtril.center.dy - tVerso * size.height * 0.7;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(xVerso, yVerso),
          width: size.width * 0.12,
          height: 3,
        ),
        Paint()
          ..color = (indiceVerso % 3 == 0
                  ? PaletaCosmoSovietica.rojoOficial
                  : PaletaCosmoSovietica.tintaNegra)
              .withValues(alpha: (1.0 - tVerso).clamp(0.0, 1.0)),
      );
    }
  }

  /// Discurso Tedioso · Comisaria sosteniendo un megáfono enorme del que
  /// salen ondas concéntricas y letras Z gigantes flotando como bostezos.
  void _pintarMegafonoTedio(Canvas canvas, Size size) {
    final pincelTrazoCuerpo = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // Cosmonauta a la izquierda, sosteniendo el megáfono.
    final cadera = Offset(size.width * 0.18, size.height * 0.78);
    final hombros = cadera.translate(0, -size.height * 0.22);
    final radioCabeza = size.width * 0.055;
    final centroCabeza = hombros.translate(0, -radioCabeza - size.height * 0.02);
    canvas.drawCircle(centroCabeza, radioCabeza, _pincelPapel);
    canvas.drawCircle(centroCabeza, radioCabeza, _pincelTrazo);
    // Gorra de comisaria con estrella.
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centroCabeza.dx, centroCabeza.dy - radioCabeza * 0.55),
        width: radioCabeza * 1.9,
        height: radioCabeza * 0.45,
      ),
      _pincelRellenoOscuro,
    );
    canvas.drawCircle(
      Offset(centroCabeza.dx, centroCabeza.dy - radioCabeza * 0.55),
      radioCabeza * 0.18,
      _pincelRellenoRojo,
    );
    // Torso.
    canvas.drawLine(hombros, cadera, pincelTrazoCuerpo);
    // Piernas firmes.
    canvas.drawLine(
      cadera,
      cadera.translate(-size.width * 0.04, size.height * 0.16),
      pincelTrazoCuerpo,
    );
    canvas.drawLine(
      cadera,
      cadera.translate(size.width * 0.05, size.height * 0.16),
      pincelTrazoCuerpo,
    );

    // Brazo sosteniendo el megáfono al frente.
    final puntoBoquilla = Offset(size.width * 0.34, size.height * 0.52);
    canvas.drawLine(hombros, puntoBoquilla, pincelTrazoCuerpo);

    // Megáfono rojo apuntando hacia la derecha.
    final puntoBocina = Offset(size.width * 0.78, size.height * 0.52);
    final radioBoquilla = size.height * 0.07;
    final radioBocina = size.height * 0.27;
    final caminoMegafono = Path()
      ..moveTo(puntoBoquilla.dx, puntoBoquilla.dy - radioBoquilla)
      ..lineTo(puntoBocina.dx, puntoBocina.dy - radioBocina)
      ..lineTo(puntoBocina.dx, puntoBocina.dy + radioBocina)
      ..lineTo(puntoBoquilla.dx, puntoBoquilla.dy + radioBoquilla)
      ..close();
    canvas.drawPath(caminoMegafono, _pincelRellenoRojo);
    canvas.drawPath(caminoMegafono, _pincelTrazo);
    // Aro de la bocina (borde reforzado).
    canvas.drawLine(
      Offset(puntoBocina.dx, puntoBocina.dy - radioBocina),
      Offset(puntoBocina.dx, puntoBocina.dy + radioBocina),
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..strokeWidth = 4,
    );
    // Banda decorativa del megáfono.
    canvas.drawLine(
      Offset(
        puntoBoquilla.dx + (puntoBocina.dx - puntoBoquilla.dx) * 0.55,
        puntoBoquilla.dy - radioBoquilla * 1.6,
      ),
      Offset(
        puntoBoquilla.dx + (puntoBocina.dx - puntoBoquilla.dx) * 0.55,
        puntoBoquilla.dy + radioBoquilla * 1.6,
      ),
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..strokeWidth = 2,
    );

    // Ondas concéntricas saliendo de la bocina.
    for (int indiceOnda = 0; indiceOnda < 3; indiceOnda++) {
      final tOnda = (indiceOnda / 3.0 + faseTransformacion) % 1.0;
      final radioOnda = radioBocina + size.height * 0.05 + tOnda * size.height * 0.5;
      final centroOnda = puntoBocina.translate(0, 0);
      canvas.drawArc(
        Rect.fromCircle(center: centroOnda, radius: radioOnda),
        -math.pi * 0.32,
        math.pi * 0.64,
        false,
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra
              .withValues(alpha: (1.0 - tOnda).clamp(0.0, 1.0))
          ..strokeWidth = 2.8
          ..style = PaintingStyle.stroke,
      );
    }

    // Letras Z gigantes flotando con desfase, cada una crece y se desvanece.
    final aleatorioZ = math.Random(11);
    const cantidadZetas = 5;
    for (int indiceZ = 0; indiceZ < cantidadZetas; indiceZ++) {
      final tZ = (indiceZ / cantidadZetas + faseTransformacion) % 1.0;
      final escalaZ = 0.6 + tZ * 0.7;
      final inclinacionZ = (aleatorioZ.nextDouble() - 0.5) * 0.5;
      final xZ = puntoBocina.dx + size.width * 0.08 + tZ * size.width * 0.18;
      final yZ = puntoBocina.dy -
          size.height * 0.25 -
          tZ * size.height * 0.4 +
          math.sin(indiceZ * 1.7) * size.height * 0.04;
      final opacidadZ = (1.0 - tZ).clamp(0.0, 1.0);
      _dibujarLetraZeta(
        canvas,
        Offset(xZ, yZ),
        size.height * 0.14 * escalaZ,
        inclinacionZ,
        opacidadZ,
      );
    }
  }

  void _dibujarLetraZeta(Canvas canvas, Offset centro, double tamano,
      double inclinacion, double opacidad) {
    canvas.save();
    canvas.translate(centro.dx, centro.dy);
    canvas.rotate(inclinacion);
    final pincel = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: opacidad)
      ..strokeWidth = tamano * 0.16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.miter;
    final medio = tamano / 2;
    final camino = Path()
      ..moveTo(-medio, -medio)
      ..lineTo(medio, -medio)
      ..lineTo(-medio, medio)
      ..lineTo(medio, medio);
    canvas.drawPath(
      camino,
      Paint()
        ..color = pincel.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = pincel.strokeWidth
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  /// Pergamino que se desenrolla cómicamente.
  void _pintarPergaminoCita(Canvas canvas, Size size) {
    final centroPergamino =
        Offset(size.width / 2, size.height * 0.55);
    final anchoPerg = size.width * 0.7;
    final altoPerg = size.height * 0.5;
    final rectPerg = Rect.fromCenter(
      center: centroPergamino,
      width: anchoPerg,
      height: altoPerg,
    );
    canvas.drawRect(rectPerg, _pincelPapel);
    canvas.drawRect(rectPerg, _pincelTrazo);
    // Rodillos en los extremos
    canvas.drawCircle(
      Offset(rectPerg.left, rectPerg.center.dy),
      altoPerg * 0.2,
      _pincelRellenoRojo,
    );
    canvas.drawCircle(
      Offset(rectPerg.left, rectPerg.center.dy),
      altoPerg * 0.2,
      _pincelTrazo,
    );
    canvas.drawCircle(
      Offset(rectPerg.right, rectPerg.center.dy),
      altoPerg * 0.2,
      _pincelRellenoRojo,
    );
    canvas.drawCircle(
      Offset(rectPerg.right, rectPerg.center.dy),
      altoPerg * 0.2,
      _pincelTrazo,
    );
    // Texto sugerido (renglones)
    final pincelRenglon = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..strokeWidth = 1.0;
    for (int indiceRenglon = 0; indiceRenglon < 5; indiceRenglon++) {
      final y = rectPerg.top + altoPerg * (0.18 + indiceRenglon * 0.16);
      canvas.drawLine(
        Offset(rectPerg.left + altoPerg * 0.35, y),
        Offset(rectPerg.right - altoPerg * 0.35, y),
        pincelRenglon,
      );
    }
  }

  /// Samovar tumbado vertiendo agua hirviendo.
  void _pintarSamovarVolando(Canvas canvas, Size size) {
    final centroSamovar = Offset(size.width * 0.4, size.height * 0.5);
    final anchoSamovar = size.width * 0.3;
    final altoSamovar = size.height * 0.4;
    canvas.save();
    canvas.translate(centroSamovar.dx, centroSamovar.dy);
    canvas.rotate(0.7);
    final rectSamovar = Rect.fromCenter(
      center: Offset.zero,
      width: anchoSamovar,
      height: altoSamovar,
    );
    canvas.drawRect(rectSamovar, _pincelRellenoOscuro);
    canvas.drawRect(rectSamovar, _pincelTrazo);
    // Pico
    canvas.drawLine(
      Offset(rectSamovar.right, -altoSamovar * 0.15),
      Offset(rectSamovar.right + anchoSamovar * 0.3, -altoSamovar * 0.05),
      _pincelTrazo..strokeWidth = 3.0,
    );
    canvas.restore();
    // Chorros de agua a la derecha
    for (int indiceChorro = 0; indiceChorro < 4; indiceChorro++) {
      final tChorro =
          (indiceChorro / 4.0 + faseTransformacion) % 1.0;
      final xChorro =
          centroSamovar.dx + anchoSamovar + tChorro * size.width * 0.4;
      final yChorro = centroSamovar.dy +
          math.sin(tChorro * math.pi) * altoSamovar * 0.2;
      canvas.drawCircle(
        Offset(xChorro, yChorro),
        5,
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra
              .withValues(alpha: 0.85 * (1.0 - tChorro).clamp(0.0, 1.0)),
      );
    }
  }

  /// Ataque básico melee · puñetazo en tres fases:
  ///   • 0.00 – 0.35 → brazo retraído junto al pecho, peón sólido.
  ///   • 0.35 – 0.70 → brazo extendiéndose con estela de movimiento.
  ///   • 0.70 – 1.00 → puño impactando con ondas de choque.
  void _pintarPunoExtendido(Canvas canvas, Size size) {
    final pincelTrazoCuerpo = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;

    final cadera = Offset(size.width * 0.28, size.height * 0.78);
    final hombros = cadera.translate(0, -size.height * 0.22);
    final radioCabeza = size.width * 0.055;
    final centroCabeza = hombros.translate(0, -radioCabeza - size.height * 0.02);
    canvas.drawCircle(centroCabeza, radioCabeza, _pincelPapel);
    canvas.drawCircle(centroCabeza, radioCabeza, _pincelTrazo);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centroCabeza.dx, centroCabeza.dy - radioCabeza * 0.55),
        width: radioCabeza * 1.9,
        height: radioCabeza * 0.4,
      ),
      _pincelRellenoOscuro,
    );
    canvas.drawLine(hombros, cadera, pincelTrazoCuerpo);
    canvas.drawLine(
      cadera,
      cadera.translate(-size.width * 0.04, size.height * 0.16),
      pincelTrazoCuerpo,
    );
    canvas.drawLine(
      cadera,
      cadera.translate(size.width * 0.05, size.height * 0.16),
      pincelTrazoCuerpo,
    );

    final fase = faseTransformacion;
    // Posición del puño según fase.
    Offset centroPuno;
    double radioPuno;
    bool dibujarEstela = false;
    bool dibujarImpacto = false;
    if (fase < 0.35) {
      // Retraído al pecho.
      final fracPrep = fase / 0.35;
      centroPuno = Offset(
        hombros.dx + size.width * 0.05 + math.sin(fracPrep * math.pi) * size.width * 0.012,
        hombros.dy + size.height * 0.08,
      );
      radioPuno = size.width * 0.05;
    } else if (fase < 0.70) {
      // Extendiéndose.
      final fracExtension = (fase - 0.35) / 0.35;
      final progresoCurva = Curves.easeOutCubic.transform(fracExtension);
      final origen = Offset(
        hombros.dx + size.width * 0.05,
        hombros.dy + size.height * 0.08,
      );
      final destino = Offset(size.width * 0.86, size.height * 0.55);
      centroPuno = Offset.lerp(origen, destino, progresoCurva)!;
      radioPuno = size.width * (0.05 + fracExtension * 0.06);
      dibujarEstela = true;
    } else {
      // Impacto.
      final fracImpacto = (fase - 0.70) / 0.30;
      final pulsoImpacto = 1.0 + math.sin(fracImpacto * math.pi) * 0.18;
      centroPuno = Offset(size.width * 0.86, size.height * 0.55);
      radioPuno = size.width * 0.11 * pulsoImpacto;
      dibujarImpacto = true;
    }

    // Brazo: línea desde hombros hasta puño.
    canvas.drawLine(hombros, centroPuno, pincelTrazoCuerpo);

    // Puño con nudillos.
    canvas.drawCircle(centroPuno, radioPuno, _pincelPapel);
    canvas.drawCircle(centroPuno, radioPuno, _pincelTrazo);
    for (int indiceNudillo = 0; indiceNudillo < 3; indiceNudillo++) {
      final yNudillo = centroPuno.dy -
          radioPuno * 0.4 +
          indiceNudillo * radioPuno * 0.4;
      canvas.drawLine(
        Offset(centroPuno.dx - radioPuno * 0.3, yNudillo),
        Offset(centroPuno.dx + radioPuno * 0.4, yNudillo),
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra
          ..strokeWidth = 1.8,
      );
    }

    // Estela de movimiento durante la extensión.
    if (dibujarEstela) {
      final pincelEstela = Paint()
        ..color =
            PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.45)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      for (int indiceLineaEstela = 0;
          indiceLineaEstela < 4;
          indiceLineaEstela++) {
        final yEstela = centroPuno.dy +
            (indiceLineaEstela - 1.5) * radioPuno * 0.45;
        canvas.drawLine(
          Offset(centroPuno.dx - radioPuno * 2.5, yEstela),
          Offset(centroPuno.dx - radioPuno * 0.9, yEstela),
          pincelEstela,
        );
      }
    }

    // Ondas de impacto.
    if (dibujarImpacto) {
      final fracImpacto = (fase - 0.70) / 0.30;
      final intensidad = math.sin(fracImpacto * math.pi);
      // Anillo de impacto.
      canvas.drawCircle(
        centroPuno,
        radioPuno * (1.6 + intensidad * 0.6),
        Paint()
          ..color = PaletaCosmoSovietica.rojoOficial
              .withValues(alpha: (1.0 - fracImpacto * 0.6).clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.4,
      );
      // Líneas radiales rojas.
      for (int indiceLineaImpacto = 0;
          indiceLineaImpacto < 8;
          indiceLineaImpacto++) {
        final anguloLinea = indiceLineaImpacto * math.pi / 4;
        final desde = Offset(
          centroPuno.dx + math.cos(anguloLinea) * radioPuno * 1.1,
          centroPuno.dy + math.sin(anguloLinea) * radioPuno * 1.1,
        );
        final hasta = Offset(
          centroPuno.dx +
              math.cos(anguloLinea) * radioPuno * (1.6 + intensidad * 0.6),
          centroPuno.dy +
              math.sin(anguloLinea) * radioPuno * (1.6 + intensidad * 0.6),
        );
        canvas.drawLine(
          desde,
          hasta,
          Paint()
            ..color = PaletaCosmoSovietica.rojoOficial
            ..strokeWidth = 2.6
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  /// Fallback genérico: signo de exclamación de cómic.
  void _pintarSignoExclamacion(Canvas canvas, Size size) {
    final centroSigno = Offset(size.width / 2, size.height * 0.55);
    final alto = size.height * 0.7;
    final ancho = size.width * 0.22;
    final rectBarraSigno = Rect.fromCenter(
      center: centroSigno.translate(0, -alto * 0.1),
      width: ancho,
      height: alto * 0.7,
    );
    canvas.drawRect(rectBarraSigno, _pincelRellenoRojo);
    canvas.drawRect(rectBarraSigno, _pincelTrazo);
    final centroPunto =
        centroSigno.translate(0, alto * 0.45);
    canvas.drawCircle(centroPunto, ancho * 0.55, _pincelRellenoRojo);
    canvas.drawCircle(centroPunto, ancho * 0.55, _pincelTrazo);
  }

  @override
  bool shouldRepaint(covariant PintorTransformacionAtaque viejo) =>
      viejo.faseTransformacion != faseTransformacion ||
      viejo.identificadorHabilidad != identificadorHabilidad;
}
