import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'pintor_rotulador.dart';
import 'sprite_cadete.dart';
import 'utilidades_carga_sprites.dart';

/// Tipo de prota en el que el cadete se transforma al entrar
/// a un lugar oculto. Define qué silueta dibuja la pantalla de
/// transformación al final de la animación.
enum FormaProtagonista {
  cadete, // estado inicial
  bolaPinball,
  piezaTetris,
  comecocos,
  agujaRadio,
  bolaNieve,
}

/// PANTALLA DE TRANSFORMACIÓN DEL CADETE.
///
/// Animación corta (3.0 s) que envuelve al cadete en una nube
/// roja parpadeante y al disiparse aparece la nueva forma. Al
/// terminar, llama al callback `alTerminar` y normalmente se
/// hace pushReplacement con el minijuego destino.
///
/// Diseñada para usarse como ruta intermedia entre el escenario
/// libre y el minijuego, así el jugador siente que "entra" en
/// otro plano de existencia.
class PantallaTransformacion extends StatefulWidget {
  final FormaProtagonista formaDestino;
  final String nombreLugar;
  final String fraseTransformacion;
  final VoidCallback alTerminar;

  const PantallaTransformacion({
    super.key,
    required this.formaDestino,
    required this.nombreLugar,
    required this.fraseTransformacion,
    required this.alTerminar,
  });

  @override
  State<PantallaTransformacion> createState() => _PantallaTransformacionState();
}

class _PantallaTransformacionState extends State<PantallaTransformacion>
    with SingleTickerProviderStateMixin {
  late Ticker tickerTransicion;
  Duration? marcaTemporalInicio;
  double progresoNormalizado = 0.0;
  bool yaCerrado = false;

  static const double duracionTotalSegundos = 2.6;

  // Sprites de §20 — cableado anticipado. Las 6 formas del cadete usan
  // sprites diferentes: 2 propios (pieza-tetris, aguja-radio) y 4
  // reutilizados de otros minijuegos para coherencia visual con el
  // destino. Cuando el asset falte, se cae al render procedural del
  // painter (que también vive en este archivo).
  ui.Image? imagenFormaCadete; // §2.0 — cadete idle (clase actual)
  ui.Image? imagenFormaBolaPinball; // §10.11 — cadete_bola_f01.png
  ui.Image? imagenFormaPiezaTetris; // §20.1
  ui.Image? imagenFormaComecocos; // reutiliza §16.1 pacman_inspektor
  ui.Image? imagenFormaAgujaRadio; // §20.2
  ui.Image? imagenFormaBolaNieve; // reutiliza §14.4 snow_bola_papel

  @override
  void initState() {
    super.initState();
    tickerTransicion = createTicker(_alTick)..start();
    _cargarSprites();
  }

  Future<void> _cargarSprites() async {
    final resultados = await cargarLoteOpcional(<String>[
      // El cadete "normal" depende de la clase del jugador en runtime;
      // como aquí no tenemos EstadoJuego, dejamos el slot null y el
      // painter usa el sprite procedural existente para esta forma.
      'assets/images/cadete_bola_f01.png',
      'assets/svg/transform_cadete_pieza_tetris.png',
      'assets/svg/pacman_inspektor.png',
      'assets/svg/transform_cadete_aguja_radio.png',
      'assets/svg/snow_bola_papel.png',
    ]);
    if (!mounted) return;
    setState(() {
      imagenFormaBolaPinball = resultados[0];
      imagenFormaPiezaTetris = resultados[1];
      imagenFormaComecocos = resultados[2];
      imagenFormaAgujaRadio = resultados[3];
      imagenFormaBolaNieve = resultados[4];
    });
  }

  @override
  void dispose() {
    tickerTransicion.dispose();
    super.dispose();
  }

  void _alTick(Duration tiempoAcumulado) {
    marcaTemporalInicio ??= tiempoAcumulado;
    final double segundosTranscurridos =
        (tiempoAcumulado - marcaTemporalInicio!).inMicroseconds / 1e6;
    final double nuevoProgreso =
        (segundosTranscurridos / duracionTotalSegundos).clamp(0.0, 1.0);
    if (nuevoProgreso != progresoNormalizado) {
      setState(() {
        progresoNormalizado = nuevoProgreso;
      });
    }
    if (nuevoProgreso >= 1.0 && !yaCerrado) {
      yaCerrado = true;
      tickerTransicion.stop();
      // Permitir que el estado pinte el frame final antes del salto.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.alTerminar();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaRotulador.papelSucio,
      body: CustomPaint(
        painter: _PintorTransformacion(
          progreso: progresoNormalizado,
          formaDestino: widget.formaDestino,
          nombreLugar: widget.nombreLugar,
          frase: widget.fraseTransformacion,
          imagenFormaCadete: imagenFormaCadete,
          imagenFormaBolaPinball: imagenFormaBolaPinball,
          imagenFormaPiezaTetris: imagenFormaPiezaTetris,
          imagenFormaComecocos: imagenFormaComecocos,
          imagenFormaAgujaRadio: imagenFormaAgujaRadio,
          imagenFormaBolaNieve: imagenFormaBolaNieve,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _PintorTransformacion extends CustomPainter {
  final double progreso;
  final FormaProtagonista formaDestino;
  final String nombreLugar;
  final String frase;
  /// Sprites §20 — null = render procedural para esa forma.
  final ui.Image? imagenFormaCadete;
  final ui.Image? imagenFormaBolaPinball;
  final ui.Image? imagenFormaPiezaTetris;
  final ui.Image? imagenFormaComecocos;
  final ui.Image? imagenFormaAgujaRadio;
  final ui.Image? imagenFormaBolaNieve;

  _PintorTransformacion({
    required this.progreso,
    required this.formaDestino,
    required this.nombreLugar,
    required this.frase,
    this.imagenFormaCadete,
    this.imagenFormaBolaPinball,
    this.imagenFormaPiezaTetris,
    this.imagenFormaComecocos,
    this.imagenFormaAgujaRadio,
    this.imagenFormaBolaNieve,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset centro = Offset(size.width / 2, size.height / 2);
    final double radioReferencia = math.min(size.width, size.height) * 0.16;

    // FASE 1 (0.0 - 0.45): cadete visible, nube roja crece.
    // FASE 2 (0.45 - 0.65): destello: la nube tapa todo en blanco/rojo.
    // FASE 3 (0.65 - 1.0): nueva forma emerge, nube se disipa.

    // Fondo con estrellas tenues que parpadean al ritmo del progreso.
    final pincelEstrella = Paint()
      ..color = PaletaRotulador.papel
          .withValues(alpha: 0.25 + 0.30 * math.sin(progreso * math.pi * 8));
    final math.Random rngFijo = math.Random(773);
    for (int indiceEstrella = 0;
        indiceEstrella < 80;
        indiceEstrella++) {
      final double xEstrella = rngFijo.nextDouble() * size.width;
      final double yEstrella = rngFijo.nextDouble() * size.height;
      canvas.drawCircle(
          Offset(xEstrella, yEstrella), 1.4, pincelEstrella);
    }

    // Nube roja pulsante. Su radio cambia con el progreso.
    double radioNube;
    if (progreso < 0.45) {
      radioNube = radioReferencia * (0.5 + progreso * 4.0);
    } else if (progreso < 0.65) {
      radioNube = radioReferencia * 3.5;
    } else {
      radioNube = radioReferencia * 3.5 * (1.0 - (progreso - 0.65) / 0.35);
    }
    final double alphaNube = progreso < 0.65
        ? (0.20 + progreso * 0.80).clamp(0.0, 0.95)
        : (1.0 - (progreso - 0.65) / 0.35).clamp(0.0, 0.95);
    canvas.drawCircle(
      centro,
      radioNube,
      Paint()
        ..shader = RadialGradient(
          colors: [
            PaletaRotulador.rojoEstampilla
                .withValues(alpha: alphaNube),
            PaletaRotulador.rojoEstampilla
                .withValues(alpha: alphaNube * 0.5),
            const Color(0x00000000),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(
            Rect.fromCircle(center: centro, radius: radioNube)),
    );

    // Silueta del prota: cadete en fase 1, nuevo prota en fase 3.
    if (progreso < 0.45) {
      _dibujarSiluetaCadete(canvas, centro, radioReferencia,
          alpha: (1.0 - progreso / 0.45).clamp(0.0, 1.0));
    } else if (progreso > 0.65) {
      final double alphaSilueta =
          ((progreso - 0.65) / 0.35).clamp(0.0, 1.0);
      _dibujarSiluetaProta(
          canvas, centro, radioReferencia, alphaSilueta);
    }

    // Destello blanco rápido en el punto de cruce.
    if (progreso >= 0.45 && progreso < 0.65) {
      final double intensidadDestello =
          1.0 - ((progreso - 0.55).abs() / 0.10);
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..color = PaletaRotulador.papel
              .withValues(alpha: intensidadDestello * 0.85),
      );
    }

    // Texto descriptivo.
    final pintorNombre = TextPainter(
      text: TextSpan(
        text: nombreLugar.toUpperCase(),
        style: TextStyle(
          color: PaletaRotulador.rojoEstampilla
              .withValues(alpha: (progreso * 2).clamp(0.0, 1.0)),
          fontFamily: 'CosmoMono',
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 4,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.width * 0.8);
    pintorNombre.paint(
      canvas,
      Offset(centro.dx - pintorNombre.width / 2,
          size.height * 0.18 - pintorNombre.height / 2),
    );

    final pintorFrase = TextPainter(
      text: TextSpan(
        text: frase,
        style: TextStyle(
          color: PaletaRotulador.papel
              .withValues(alpha: progreso > 0.5 ? 0.85 : 0.0),
          fontFamily: 'CosmoMono',
          fontSize: 13,
          fontStyle: FontStyle.italic,
          height: 1.5,
          letterSpacing: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.width * 0.7);
    pintorFrase.paint(
      canvas,
      Offset(centro.dx - pintorFrase.width / 2,
          size.height * 0.82 - pintorFrase.height / 2),
    );
  }

  void _dibujarSiluetaCadete(
      Canvas canvas, Offset centro, double escala, {required double alpha}) {
    // Stick figure idéntico al del juego principal. El alpha lo
    // aplicamos vía saveLayer para no tener que reescribir el helper.
    canvas.saveLayer(null, Paint()
      ..color = PaletaRotulador.tinta.withValues(alpha: alpha));
    dibujarCadeteCosmonauta(
      canvas,
      centro: centro,
      alto: escala * 5.5,
      pose: PoseCadeteMinijuego.quieto,
    );
    canvas.restore();
  }

  void _dibujarSiluetaProta(
      Canvas canvas, Offset centro, double escala, double alpha) {
    // §20: si hay sprite cargado para la forma destino, drawImageRect.
    // Caemos al render procedural cuando el asset no existe (forma
    // `cadete` siempre cae a procedural porque depende de la clase
    // en runtime).
    final ui.Image? spriteForma = switch (formaDestino) {
      FormaProtagonista.cadete => imagenFormaCadete,
      FormaProtagonista.bolaPinball => imagenFormaBolaPinball,
      FormaProtagonista.piezaTetris => imagenFormaPiezaTetris,
      FormaProtagonista.comecocos => imagenFormaComecocos,
      FormaProtagonista.agujaRadio => imagenFormaAgujaRadio,
      FormaProtagonista.bolaNieve => imagenFormaBolaNieve,
    };
    if (spriteForma != null) {
      // Aspect ratio nativo del sprite, ancho como `escala` × 2.
      final double anchoDestino = escala * 2.5;
      final double altoDestino =
          anchoDestino * spriteForma.height / spriteForma.width;
      final Rect destino = Rect.fromCenter(
        center: centro,
        width: anchoDestino,
        height: altoDestino,
      );
      canvas.saveLayer(null, Paint()..color = PaletaRotulador.tinta
          .withValues(alpha: alpha));
      canvas.drawImageRect(
        spriteForma,
        Rect.fromLTWH(0, 0, spriteForma.width.toDouble(),
            spriteForma.height.toDouble()),
        destino,
        Paint()..filterQuality = FilterQuality.high,
      );
      canvas.restore();
      return;
    }
    switch (formaDestino) {
      case FormaProtagonista.cadete:
        _dibujarSiluetaCadete(canvas, centro, escala, alpha: alpha);
        break;
      case FormaProtagonista.bolaPinball:
        _dibujarBolaPinball(canvas, centro, escala, alpha);
        break;
      case FormaProtagonista.piezaTetris:
        _dibujarPiezaTetris(canvas, centro, escala, alpha);
        break;
      case FormaProtagonista.comecocos:
        _dibujarComecocos(canvas, centro, escala, alpha);
        break;
      case FormaProtagonista.agujaRadio:
        _dibujarAgujaRadio(canvas, centro, escala, alpha);
        break;
      case FormaProtagonista.bolaNieve:
        _dibujarBolaNieve(canvas, centro, escala, alpha);
        break;
    }
  }

  void _dibujarBolaPinball(
      Canvas canvas, Offset centro, double escala, double alpha) {
    canvas.saveLayer(null, Paint()
      ..color = PaletaRotulador.tinta.withValues(alpha: alpha));
    dibujarCabezaComoBola(
      canvas,
      centro: centro,
      radio: escala * 1.1,
      rotacion: progreso * math.pi * 4,
    );
    canvas.restore();
  }

  void _dibujarPiezaTetris(
      Canvas canvas, Offset centro, double escala, double alpha) {
    // Cuatro cuadrados estilo formulario F-447 en forma de L.
    final List<Offset> celdas = <Offset>[
      const Offset(-0.5, -1.0),
      const Offset(-0.5, 0.0),
      const Offset(-0.5, 1.0),
      const Offset(0.5, 1.0),
    ];
    for (final celda in celdas) {
      final Rect rectCelda = Rect.fromCenter(
        center: centro.translate(celda.dx * escala * 0.8,
            celda.dy * escala * 0.8),
        width: escala * 0.7,
        height: escala * 0.7,
      );
      canvas.drawRect(
        rectCelda,
        Paint()
          ..color =
              PaletaRotulador.papel.withValues(alpha: alpha),
      );
      // Banda roja superior.
      canvas.drawRect(
        Rect.fromLTWH(
          rectCelda.left,
          rectCelda.top,
          rectCelda.width,
          rectCelda.height * 0.18,
        ),
        Paint()
          ..color =
              PaletaRotulador.rojoEstampilla.withValues(alpha: alpha),
      );
      canvas.drawRect(
        rectCelda,
        Paint()
          ..color = PaletaRotulador.tinta.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    final pintorLetra = TextPainter(
      text: TextSpan(
        text: 'F',
        style: TextStyle(
          color: PaletaRotulador.tinta.withValues(alpha: alpha),
          fontFamily: 'CosmoMono',
          fontSize: escala * 0.6,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintorLetra.paint(
      canvas,
      Offset(
        centro.dx - escala * 0.4 - pintorLetra.width / 2,
        centro.dy - pintorLetra.height / 2,
      ),
    );
  }

  void _dibujarComecocos(
      Canvas canvas, Offset centro, double escala, double alpha) {
    canvas.saveLayer(null, Paint()
      ..color = PaletaRotulador.tinta.withValues(alpha: alpha));
    final double apertura = 0.15 + 0.20 * math.sin(progreso * math.pi * 6);
    dibujarCabezaComeCocos(
      canvas,
      centro: centro,
      radio: escala * 1.1,
      anguloApertura: apertura,
      anguloBase: 0,
    );
    canvas.restore();
  }

  void _dibujarAgujaRadio(
      Canvas canvas, Offset centro, double escala, double alpha) {
    // Aguja vertical larga estilo dial.
    final Rect rectAguja = Rect.fromCenter(
      center: centro,
      width: escala * 0.18,
      height: escala * 2.4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rectAguja, Radius.circular(escala * 0.08)),
      Paint()
        ..color =
            PaletaRotulador.rojoEstampilla.withValues(alpha: alpha),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rectAguja, Radius.circular(escala * 0.08)),
      Paint()
        ..color = PaletaRotulador.tinta.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Cabeza redonda arriba.
    canvas.drawCircle(
      centro.translate(0, -escala * 1.25),
      escala * 0.30,
      Paint()
        ..color =
            PaletaRotulador.papel.withValues(alpha: alpha),
    );
    canvas.drawCircle(
      centro.translate(0, -escala * 1.25),
      escala * 0.30,
      Paint()
        ..color = PaletaRotulador.tinta.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Ondas que salen de la cabeza.
    for (int indiceOnda = 0; indiceOnda < 3; indiceOnda++) {
      canvas.drawArc(
        Rect.fromCircle(
            center: centro.translate(0, -escala * 1.25),
            radius: escala * (0.45 + indiceOnda * 0.20)),
        -math.pi * 0.65,
        math.pi * 0.30,
        false,
        Paint()
          ..color = PaletaRotulador.rojoEstampilla
              .withValues(alpha: alpha * (1.0 - indiceOnda * 0.25))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _dibujarBolaNieve(
      Canvas canvas, Offset centro, double escala, double alpha) {
    final double radio = escala * 1.1;
    canvas.drawCircle(
      centro,
      radio,
      Paint()
        ..color = PaletaRotulador.papel.withValues(alpha: alpha),
    );
    canvas.drawCircle(
      centro,
      radio,
      Paint()
        ..color = PaletaRotulador.tinta.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    // Forma de cadete encima (Snow Bros style).
    canvas.drawCircle(
      centro.translate(0, -radio * 1.4),
      radio * 0.5,
      Paint()
        ..color = PaletaRotulador.papel.withValues(alpha: alpha),
    );
    canvas.drawCircle(
      centro.translate(0, -radio * 1.4),
      radio * 0.5,
      Paint()
        ..color = PaletaRotulador.tinta.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Estrella roja en la bola grande.
    _dibujarEstrellaCinco(
      canvas,
      centro,
      radio * 0.32,
      Paint()
        ..color = PaletaRotulador.rojoEstampilla.withValues(alpha: alpha),
    );
    // Ojos del Snow Kamarada.
    canvas.drawCircle(
      centro.translate(-radio * 0.18, -radio * 1.45),
      radio * 0.06,
      Paint()
        ..color = PaletaRotulador.tinta.withValues(alpha: alpha),
    );
    canvas.drawCircle(
      centro.translate(radio * 0.18, -radio * 1.45),
      radio * 0.06,
      Paint()
        ..color = PaletaRotulador.tinta.withValues(alpha: alpha),
    );
  }

  void _dibujarEstrellaCinco(
      Canvas canvas, Offset centro, double radio, Paint pincel) {
    final camino = Path();
    for (int indice = 0; indice < 10; indice++) {
      final esExterior = indice.isEven;
      final radioActual = esExterior ? radio : radio * 0.42;
      final angulo = -math.pi / 2 + indice * math.pi / 5;
      final x = centro.dx + math.cos(angulo) * radioActual;
      final y = centro.dy + math.sin(angulo) * radioActual;
      if (indice == 0) {
        camino.moveTo(x, y);
      } else {
        camino.lineTo(x, y);
      }
    }
    camino.close();
    canvas.drawPath(camino, pincel);
  }

  @override
  bool shouldRepaint(covariant _PintorTransformacion viejo) =>
      viejo.progreso != progreso;
}
