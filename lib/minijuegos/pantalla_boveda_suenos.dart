import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../widgets/propaganda_button.dart';
import 'pintor_rotulador.dart';
import 'sprite_cadete.dart';

/// BÓVEDA DE SUEÑOS CONFISCADOS.
///
/// Mini-experiencia narrativa, no es un juego de habilidad. El cadete
/// recuesta la cabeza en la almohada y atraviesa cinco viñetas oníricas
/// confiscadas por el archivo nocturno del Comité: visiones de
/// Vassiliev, Gromov, Petrov 58 y Vostrikova. Cada viñeta tiene una
/// ilustración estilo grabado + texto que va apareciendo letra a letra.
/// El jugador avanza con Espacio/Enter. Al final, despierta.
class PantallaBovedaSuenos extends StatefulWidget {
  final EstadoJuego estado;

  const PantallaBovedaSuenos({super.key, required this.estado});

  @override
  State<PantallaBovedaSuenos> createState() => _PantallaBovedaSuenosState();
}

class _PantallaBovedaSuenosState extends State<PantallaBovedaSuenos>
    with SingleTickerProviderStateMixin {
  late Ticker tickerSuenos;
  Duration? marcaTemporalAnterior;
  final FocusNode nodoFoco = FocusNode(debugLabel: 'boveda_suenos');

  int indiceVinetaActual = 0;
  String textoVisible = '';
  int caracteresMostrados = 0;
  double acumuladorTeletipo = 0.0;
  static const double segundosPorCaracter = 0.025;
  /// Fase 0..1 que pulsa para animar los grabados.
  double faseRespiracion = 0.0;

  final List<_VinetaOnirica> vinetas = const <_VinetaOnirica>[
    _VinetaOnirica(
      titulo: 'VASSILIEV · LA SILLA VACÍA',
      tipoIlustracion: _TipoIlustracion.sillaVacia,
      cuerpo:
          'Vassiliev está sentado en una silla que ya no le sostiene. '
          'Tiene la gorra del Capitán cruzada sobre las rodillas y un '
          'samovar tibio entre las manos. Dice: «Hijo, el café se enfría, '
          'pero la patria espera». Cuando intentas darle la mano, los '
          'dedos atraviesan los suyos. La silla cruje. La silla se queda.',
      flagDescubrimiento: 'sueno_vassiliev',
    ),
    _VinetaOnirica(
      titulo: 'GROMOV · LA HORA 4:47',
      tipoIlustracion: _TipoIlustracion.relojDormido,
      cuerpo:
          'Un reloj industrial marca las 4:47 y respira despacio. Es '
          'Gromov, dormido dentro del cristal. Bajo las manecillas, una '
          'firma que se borra cada vez que la miras. Susurra: «Yo no '
          'paré el reloj. Sólo dejé de respirar a tiempo».',
      flagDescubrimiento: 'sueno_gromov',
    ),
    _VinetaOnirica(
      titulo: 'PETROV 58 · LA QUEMADURA',
      tipoIlustracion: _TipoIlustracion.trajeQuemado,
      cuerpo:
          'Un traje anti-radiación cuelga vacío en mitad del cosmos. '
          'En el pecho, una quemadura circular que aún humea. Una voz '
          'baja —no del traje, sino del humo— dice: «No firmes el F-447. '
          'Es el F-447 quien firma a quien lo firma».',
      flagDescubrimiento: 'sueno_petrov58',
    ),
    _VinetaOnirica(
      titulo: 'VOSTRIKOVA · LA PRAVDA-7',
      tipoIlustracion: _TipoIlustracion.naveLejana,
      cuerpo:
          'La Pravda-7 cae en silencio por una luna gélida. Una ventanilla '
          'iluminada. Detrás del vidrio, Vostrikova firma una bitácora a '
          'la luz de una vela rusa. Levanta la vista y articula sin voz: '
          '«Todavía estamos abajo. Sigue oyendo».',
      flagDescubrimiento: 'sueno_vostrikova',
    ),
    _VinetaOnirica(
      titulo: 'EL CAMARADA DEL VACÍO',
      tipoIlustracion: _TipoIlustracion.cadeteFlotando,
      cuerpo:
          'Estás flotando boca arriba en un océano de papel viejo. Cada '
          'hoja lleva tu nombre con una firma que no recuerdas. Sobre ti, '
          'una estrella roja del tamaño del sol. Una voz te pregunta: '
          '«¿Estás dispuesto a perderte un poco más?». Asientes en sueños.',
      flagDescubrimiento: 'sueno_camarada_vacio',
    ),
  ];

  @override
  void initState() {
    super.initState();
    tickerSuenos = createTicker(_alTick)..start();
  }

  @override
  void dispose() {
    tickerSuenos.dispose();
    nodoFoco.dispose();
    super.dispose();
  }

  void _alTick(Duration tiempoAcumulado) {
    final marcaAnterior = marcaTemporalAnterior;
    marcaTemporalAnterior = tiempoAcumulado;
    if (marcaAnterior == null) return;
    final double dt =
        (tiempoAcumulado - marcaAnterior).inMicroseconds / 1e6;
    if (dt <= 0) return;
    faseRespiracion = (faseRespiracion + dt * 0.35) % 1.0;
    // Avanzar teletipo de la vineta actual.
    if (indiceVinetaActual < vinetas.length) {
      final cuerpo = vinetas[indiceVinetaActual].cuerpo;
      if (caracteresMostrados < cuerpo.length) {
        acumuladorTeletipo += dt;
        while (acumuladorTeletipo >= segundosPorCaracter &&
            caracteresMostrados < cuerpo.length) {
          acumuladorTeletipo -= segundosPorCaracter;
          caracteresMostrados += 1;
          textoVisible = cuerpo.substring(0, caracteresMostrados);
        }
      }
    }
    setState(() {});
  }

  void _avanzar() {
    final cuerpo = indiceVinetaActual < vinetas.length
        ? vinetas[indiceVinetaActual].cuerpo
        : '';
    if (caracteresMostrados < cuerpo.length) {
      // Si aun no esta todo escrito, completar de golpe.
      setState(() {
        caracteresMostrados = cuerpo.length;
        textoVisible = cuerpo;
        acumuladorTeletipo = 0;
      });
      return;
    }
    // Marcar como descubierto y pasar a la siguiente.
    if (indiceVinetaActual < vinetas.length) {
      widget.estado.activarFlag(
          vinetas[indiceVinetaActual].flagDescubrimiento);
    }
    if (indiceVinetaActual + 1 >= vinetas.length) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      indiceVinetaActual += 1;
      caracteresMostrados = 0;
      textoVisible = '';
      acumuladorTeletipo = 0;
    });
  }

  KeyEventResult _alEventoTeclado(FocusNode nodo, KeyEvent evento) {
    if (evento is! KeyDownEvent) return KeyEventResult.ignored;
    final tecla = evento.logicalKey;
    if (tecla == LogicalKeyboardKey.space ||
        tecla == LogicalKeyboardKey.enter ||
        tecla == LogicalKeyboardKey.numpadEnter) {
      _avanzar();
      return KeyEventResult.handled;
    }
    if (tecla == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final vineta = vinetas[indiceVinetaActual];
    return Scaffold(
      backgroundColor: PaletaRotulador.papelSucio,
      body: FondoPapelEnvejecido(
        semilla: 67,
        child: Focus(
        focusNode: nodoFoco,
        autofocus: true,
        onKeyEvent: _alEventoTeclado,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _construirCabecera(),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: AspectRatio(
                        aspectRatio: 4 / 5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: PaletaRotulador.papel,
                            border: Border.all(
                              color: PaletaRotulador.tinta,
                              width: 4,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CustomPaint(
                            painter: _PintorVineta(
                              tipo: vineta.tipoIlustracion,
                              fase: faseRespiracion,
                              titulo: vineta.titulo,
                              textoVisible: textoVisible,
                              completa: caracteresMostrados >=
                                  vineta.cuerpo.length,
                              progreso:
                                  indiceVinetaActual / (vinetas.length - 1),
                            ),
                            child: Container(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _construirControles(),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _construirCabecera() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'BÓVEDA DE SUEÑOS CONFISCADOS',
          style: TextStyle(
            fontFamily: 'CosmoMono',
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: PaletaRotulador.papel,
            letterSpacing: 3,
          ),
        ),
        Row(
          children: [
            Text(
              'VIÑETA ${indiceVinetaActual + 1} / ${vinetas.length}',
              style: const TextStyle(
                fontFamily: 'CosmoMono',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: PaletaRotulador.rojoEstampilla,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(width: 12),
            BotonPropaganda(
              texto: 'Despertar',
              compacto: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _construirControles() {
    return Text(
      caracteresMostrados >= vinetas[indiceVinetaActual].cuerpo.length
          ? 'ESPACIO o ENTER · pasar página · ESC · despertar'
          : 'ESPACIO o ENTER · completar texto',
      style: const TextStyle(
        fontFamily: 'CosmoMono',
        fontSize: 11,
        color: PaletaRotulador.tinta,
        letterSpacing: 1.2,
      ),
    );
  }
}

enum _TipoIlustracion {
  sillaVacia,
  relojDormido,
  trajeQuemado,
  naveLejana,
  cadeteFlotando,
}

class _VinetaOnirica {
  final String titulo;
  final _TipoIlustracion tipoIlustracion;
  final String cuerpo;
  final String flagDescubrimiento;

  const _VinetaOnirica({
    required this.titulo,
    required this.tipoIlustracion,
    required this.cuerpo,
    required this.flagDescubrimiento,
  });
}

class _PintorVineta extends CustomPainter {
  final _TipoIlustracion tipo;
  final double fase;
  final String titulo;
  final String textoVisible;
  final bool completa;
  final double progreso;

  _PintorVineta({
    required this.tipo,
    required this.fase,
    required this.titulo,
    required this.textoVisible,
    required this.completa,
    required this.progreso,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Papel viejo con textura tenue de fibras.
    canvas.drawRect(Offset.zero & size,
        Paint()..color = PaletaRotulador.papel);
    final math.Random rngTextura = math.Random(7);
    for (int indice = 0; indice < 220; indice++) {
      final double xFibra = rngTextura.nextDouble() * size.width;
      final double yFibra = rngTextura.nextDouble() * size.height;
      canvas.drawRect(
        Rect.fromLTWH(xFibra, yFibra,
            0.5 + rngTextura.nextDouble() * 2.5, 0.5),
        Paint()
          ..color = PaletaRotulador.tintaDiluida(0.45).withValues(alpha: 0.12),
      );
    }

    // Cabecera de la viñeta: rojo + rayado paralelo en tinta para
    // sugerir que la mancha está hecha a mano con plumilla.
    final Rect rectCabecera = Rect.fromLTWH(0, 0, size.width, size.height * 0.12);
    canvas.drawRect(
        rectCabecera, Paint()..color = PaletaRotulador.rojoEstampilla);
    rayadoParalelo(
      canvas,
      rectCabecera,
      pincel: Paint()
        ..color = PaletaRotulador.tinta.withValues(alpha: 0.18)
        ..strokeWidth = 0.6,
      espaciado: 4.0,
      intensidadJitter: 0.4,
    );
    final pintorTitulo = TextPainter(
      text: TextSpan(
        text: titulo,
        style: TextStyle(
          color: PaletaRotulador.papel,
          fontFamily: 'CosmoMono',
          fontSize: size.width * 0.032,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width * 0.95);
    pintorTitulo.paint(
      canvas,
      Offset(size.width / 2 - pintorTitulo.width / 2,
          rectCabecera.center.dy - pintorTitulo.height / 2),
    );

    // Marco grabado.
    final Rect rectIlustracion = Rect.fromLTWH(
      size.width * 0.10,
      size.height * 0.16,
      size.width * 0.80,
      size.height * 0.48,
    );
    canvas.drawRect(rectIlustracion,
        Paint()..color = PaletaRotulador.papelSucio);
    // Marco a rotulador (tembloroso doble pasada).
    rectanguloRotulador(
      canvas,
      rectIlustracion,
      pincel: Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
      intensidadJitter: 1.4,
      doblePasada: true,
      semilla: tipo.index * 17.0,
    );

    // Ilustracion segun el tipo de sueno.
    canvas.save();
    canvas.clipRect(rectIlustracion);
    switch (tipo) {
      case _TipoIlustracion.sillaVacia:
        _dibujarSillaVacia(canvas, rectIlustracion);
        break;
      case _TipoIlustracion.relojDormido:
        _dibujarRelojDormido(canvas, rectIlustracion);
        break;
      case _TipoIlustracion.trajeQuemado:
        _dibujarTrajeQuemado(canvas, rectIlustracion);
        break;
      case _TipoIlustracion.naveLejana:
        _dibujarNaveLejana(canvas, rectIlustracion);
        break;
      case _TipoIlustracion.cadeteFlotando:
        _dibujarCadeteFlotando(canvas, rectIlustracion);
        break;
    }
    canvas.restore();

    // Estampilla "CONFISCADO" en la esquina inferior derecha de la
    // ilustración, ligeramente rotada para refuerzo narrativo.
    estampillaRoja(
      canvas,
      posicion: Offset(
        rectIlustracion.right - size.width * 0.10,
        rectIlustracion.bottom - size.height * 0.05,
      ),
      texto: 'CONFISCADO',
      anchoEstampilla: size.width * 0.22,
      altoEstampilla: size.height * 0.07,
      rotacionRadianes: -0.16,
      opacidad: 0.82,
    );

    // Pie de pagina con texto.
    final Rect rectTexto = Rect.fromLTWH(
      size.width * 0.08,
      size.height * 0.68,
      size.width * 0.84,
      size.height * 0.28,
    );
    final pintorTexto = TextPainter(
      text: TextSpan(
        text: textoVisible,
        style: TextStyle(
          color: PaletaRotulador.tinta,
          fontFamily: 'CosmoSerif',
          fontSize: size.width * 0.028,
          fontStyle: FontStyle.italic,
          height: 1.5,
          letterSpacing: 0.4,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.justify,
    )..layout(maxWidth: rectTexto.width);
    pintorTexto.paint(canvas, rectTexto.topLeft);

    // Indicador de pulsacion al completar texto.
    if (completa) {
      final double alphaPulso =
          0.5 + 0.5 * math.sin(fase * math.pi * 8);
      canvas.drawCircle(
        Offset(size.width - size.width * 0.06, size.height - size.height * 0.05),
        size.width * 0.012,
        Paint()
          ..color = PaletaRotulador.rojoEstampilla
              .withValues(alpha: alphaPulso),
      );
    }

    // Indicador de progreso (vinetas) abajo a la izquierda.
    // Conocemos el total a traves del progreso: si hay 5 vinetas, los
    // valores van 0/4, 1/4, 2/4, 3/4, 4/4. Calculamos a la inversa.
    final int totalIndicadores = (1 / 0.25).round() + 1; // 5
    final int indiceActual = (progreso * (totalIndicadores - 1)).round();
    for (int indicePunto = 0; indicePunto < totalIndicadores; indicePunto++) {
      final double xPunto = size.width * 0.06 +
          indicePunto * size.width * 0.025;
      final double yPunto = size.height - size.height * 0.05;
      canvas.drawCircle(
        Offset(xPunto, yPunto),
        size.width * 0.008,
        Paint()
          ..color = indicePunto <= indiceActual
              ? PaletaRotulador.rojoEstampilla
              : PaletaRotulador.tintaDiluida(0.45),
      );
    }
  }

  // ────── Ilustraciones ──────────────────────────────────────────

  void _dibujarSillaVacia(Canvas canvas, Rect rect) {
    final Paint pincelTrazo = Paint()
      ..color = PaletaRotulador.tinta
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    // Suelo de cuadricula.
    for (int indice = 0; indice < 16; indice++) {
      canvas.drawLine(
        Offset(rect.left + indice * rect.width / 16,
            rect.bottom),
        Offset(rect.left + rect.width / 2,
            rect.center.dy + rect.height * 0.15),
        Paint()
          ..color = PaletaRotulador.tintaDiluida(0.45).withValues(alpha: 0.35)
          ..strokeWidth = 1.0,
      );
    }
    // Silla de madera (perspectiva ligera).
    final Offset asiento = Offset(rect.center.dx, rect.center.dy + rect.height * 0.10);
    final double anchoAsiento = rect.width * 0.34;
    final double altoAsiento = rect.height * 0.06;
    canvas.drawRect(
      Rect.fromCenter(
          center: asiento,
          width: anchoAsiento,
          height: altoAsiento),
      Paint()..color = PaletaRotulador.tintaDiluida(0.70),
    );
    canvas.drawRect(
      Rect.fromCenter(
          center: asiento,
          width: anchoAsiento,
          height: altoAsiento),
      pincelTrazo,
    );
    // Respaldo alto.
    canvas.drawRect(
      Rect.fromLTWH(
          asiento.dx - anchoAsiento * 0.45,
          asiento.dy - rect.height * 0.30,
          anchoAsiento * 0.90,
          rect.height * 0.30),
      Paint()..color = PaletaRotulador.tintaDiluida(0.50),
    );
    canvas.drawRect(
      Rect.fromLTWH(
          asiento.dx - anchoAsiento * 0.45,
          asiento.dy - rect.height * 0.30,
          anchoAsiento * 0.90,
          rect.height * 0.30),
      pincelTrazo,
    );
    // Cuatro patas.
    for (final dxPata in <double>[-0.42, -0.30, 0.30, 0.42]) {
      canvas.drawLine(
        Offset(asiento.dx + anchoAsiento * dxPata,
            asiento.dy + altoAsiento * 0.5),
        Offset(asiento.dx + anchoAsiento * dxPata * 0.85,
            rect.bottom - rect.height * 0.05),
        pincelTrazo,
      );
    }
    // Gorra de capitán sobre el asiento.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: asiento.translate(0, -rect.height * 0.04),
              width: anchoAsiento * 0.55,
              height: rect.height * 0.05),
          Radius.circular(rect.height * 0.02)),
      Paint()..color = PaletaRotulador.tintaDiluida(0.75),
    );
    canvas.drawRect(
      Rect.fromCenter(
          center: asiento.translate(0, -rect.height * 0.02),
          width: anchoAsiento * 0.85,
          height: rect.height * 0.018),
      Paint()..color = PaletaRotulador.tinta,
    );
    // Estrella roja en la gorra.
    _dibujarEstrellaCinco(
      canvas,
      asiento.translate(0, -rect.height * 0.045),
      rect.height * 0.022,
      Paint()..color = PaletaRotulador.rojoEstampilla,
    );
    // Vapor del samovar.
    for (int indiceVapor = 0; indiceVapor < 4; indiceVapor++) {
      canvas.drawCircle(
        Offset(
            asiento.dx + rect.width * 0.15,
            rect.top + rect.height * (0.10 + indiceVapor * 0.06)),
        rect.width * (0.012 + indiceVapor * 0.005),
        Paint()
          ..color = PaletaRotulador.papel
              .withValues(alpha: 0.45 + 0.1 * math.sin(fase * math.pi * 4)),
      );
    }
  }

  void _dibujarRelojDormido(Canvas canvas, Rect rect) {
    final Offset centroReloj = rect.center;
    final double radioReloj = math.min(rect.width, rect.height) * 0.32;
    final Paint pincelTrazo = Paint()
      ..color = PaletaRotulador.tinta
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(
        centroReloj, radioReloj * 1.05,
        Paint()..color = PaletaRotulador.tintaDiluida(0.65));
    canvas.drawCircle(centroReloj, radioReloj,
        Paint()..color = PaletaRotulador.papelSucio);
    canvas.drawCircle(centroReloj, radioReloj, pincelTrazo);
    // Marcas horarias.
    for (int indiceHora = 0; indiceHora < 12; indiceHora++) {
      final double angulo = indiceHora * math.pi / 6;
      final Offset desde = centroReloj.translate(
          math.cos(angulo) * radioReloj * 0.85,
          math.sin(angulo) * radioReloj * 0.85);
      final Offset hasta = centroReloj.translate(
          math.cos(angulo) * radioReloj * 0.95,
          math.sin(angulo) * radioReloj * 0.95);
      canvas.drawLine(desde, hasta, pincelTrazo..strokeWidth = 2);
    }
    // Aguja horaria fija en 4 + minutera en 47.
    final double anguloHora = (4 + 47 / 60) * math.pi / 6 - math.pi / 2;
    final double anguloMinuto = 47 * math.pi / 30 - math.pi / 2;
    canvas.drawLine(
      centroReloj,
      centroReloj.translate(math.cos(anguloHora) * radioReloj * 0.55,
          math.sin(anguloHora) * radioReloj * 0.55),
      pincelTrazo..strokeWidth = 3.5,
    );
    canvas.drawLine(
      centroReloj,
      centroReloj.translate(math.cos(anguloMinuto) * radioReloj * 0.85,
          math.sin(anguloMinuto) * radioReloj * 0.85),
      Paint()
        ..color = PaletaRotulador.rojoEstampilla
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    // Cara dormida dentro del reloj (ojos cerrados + Z).
    canvas.drawLine(
      centroReloj.translate(-radioReloj * 0.30, -radioReloj * 0.10),
      centroReloj.translate(-radioReloj * 0.10, -radioReloj * 0.10),
      pincelTrazo..strokeWidth = 2.4,
    );
    canvas.drawLine(
      centroReloj.translate(radioReloj * 0.10, -radioReloj * 0.10),
      centroReloj.translate(radioReloj * 0.30, -radioReloj * 0.10),
      pincelTrazo,
    );
    // Letras Z saliendo del reloj.
    for (int indiceZ = 0; indiceZ < 3; indiceZ++) {
      final pintorZ = TextPainter(
        text: TextSpan(
          text: 'Z',
          style: TextStyle(
            color: PaletaRotulador.tinta
                .withValues(alpha: 0.7 - indiceZ * 0.2),
            fontFamily: 'CosmoMono',
            fontSize: rect.height *
                (0.05 + indiceZ * 0.02 +
                    0.005 * math.sin((fase + indiceZ * 0.3) * math.pi * 2)),
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      pintorZ.paint(
        canvas,
        Offset(
          centroReloj.dx + radioReloj * (0.85 + indiceZ * 0.12),
          centroReloj.dy - radioReloj * (0.85 + indiceZ * 0.20),
        ),
      );
    }
  }

  void _dibujarTrajeQuemado(Canvas canvas, Rect rect) {
    // Fondo cosmos negro.
    canvas.drawRect(rect, Paint()..color = PaletaRotulador.tinta);
    final math.Random rngEstrellas = math.Random(13);
    for (int indice = 0; indice < 50; indice++) {
      canvas.drawCircle(
        Offset(rect.left + rngEstrellas.nextDouble() * rect.width,
            rect.top + rngEstrellas.nextDouble() * rect.height),
        0.6 + rngEstrellas.nextDouble() * 0.8,
        Paint()
          ..color =
              PaletaRotulador.papel.withValues(alpha: 0.55),
      );
    }
    // Traje vacio centrado.
    final Offset centroTraje = rect.center;
    final Paint pincelTrazo = Paint()
      ..color = PaletaRotulador.papel
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    // Casco vacio (transparente con visor cuarteado).
    canvas.drawCircle(
      centroTraje.translate(0, -rect.height * 0.20),
      rect.height * 0.10,
      Paint()..color = PaletaRotulador.tintaDiluida(0.85),
    );
    canvas.drawCircle(
      centroTraje.translate(0, -rect.height * 0.20),
      rect.height * 0.10,
      pincelTrazo,
    );
    // Cuerpo del traje vacio.
    final Rect rectCuerpo = Rect.fromCenter(
      center: centroTraje.translate(0, rect.height * 0.05),
      width: rect.width * 0.30,
      height: rect.height * 0.35,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rectCuerpo, Radius.circular(rect.width * 0.04)),
      Paint()..color = PaletaRotulador.tintaDiluida(0.65),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rectCuerpo, Radius.circular(rect.width * 0.04)),
      pincelTrazo,
    );
    // Mangas colgando floppy.
    canvas.drawLine(
      rectCuerpo.topLeft,
      rectCuerpo.translate(-rect.width * 0.10, rect.height * 0.10).topLeft,
      pincelTrazo..strokeWidth = 6,
    );
    canvas.drawLine(
      rectCuerpo.topRight,
      rectCuerpo.translate(rect.width * 0.10, rect.height * 0.10).topRight,
      pincelTrazo,
    );
    // Quemadura circular pulsante en el pecho.
    final double pulso = 0.55 + 0.45 * math.sin(fase * math.pi * 4);
    canvas.drawCircle(
      rectCuerpo.center.translate(0, -rect.height * 0.02),
      rect.height * 0.040 * (1 + pulso * 0.2),
      Paint()
        ..color = PaletaRotulador.rojoEstampilla.withValues(alpha: pulso),
    );
    canvas.drawCircle(
      rectCuerpo.center.translate(0, -rect.height * 0.02),
      rect.height * 0.025,
      Paint()..color = PaletaRotulador.tinta,
    );
    // Humo subiendo.
    for (int indiceHumo = 0; indiceHumo < 5; indiceHumo++) {
      canvas.drawCircle(
        rectCuerpo.center.translate(
            math.sin((fase + indiceHumo * 0.2) * math.pi * 2) *
                rect.width * 0.015,
            -rect.height * (0.05 + indiceHumo * 0.04)),
        rect.width * (0.010 + indiceHumo * 0.004),
        Paint()
          ..color = PaletaRotulador.papel
              .withValues(alpha: 0.35 - indiceHumo * 0.06),
      );
    }
  }

  void _dibujarNaveLejana(Canvas canvas, Rect rect) {
    // Luna gelida (azul) ocupando la mitad inferior.
    canvas.drawRect(rect,
        Paint()..color = PaletaRotulador.tinta);
    final math.Random rngEstrellas = math.Random(19);
    for (int indice = 0; indice < 50; indice++) {
      canvas.drawCircle(
        Offset(rect.left + rngEstrellas.nextDouble() * rect.width,
            rect.top + rngEstrellas.nextDouble() * rect.height * 0.7),
        0.5 + rngEstrellas.nextDouble() * 0.9,
        Paint()
          ..color = PaletaRotulador.papel.withValues(alpha: 0.55),
      );
    }
    // Luna grande.
    final Offset centroLuna = Offset(rect.center.dx,
        rect.bottom + rect.height * 0.30);
    canvas.drawCircle(centroLuna, rect.height * 0.55,
        Paint()..color = PaletaRotulador.tintaDiluida(0.50));
    canvas.drawCircle(centroLuna, rect.height * 0.55,
        Paint()
          ..color = PaletaRotulador.tinta
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    // Crateres.
    for (final ofsCrater in <Offset>[
      Offset(-0.15, -0.40),
      Offset(0.18, -0.30),
      Offset(0.0, -0.25),
      Offset(-0.25, -0.20),
    ]) {
      canvas.drawCircle(
        centroLuna.translate(
            ofsCrater.dx * rect.height, ofsCrater.dy * rect.height),
        rect.height * (0.02 + (ofsCrater.dx.abs() + ofsCrater.dy.abs()) * 0.05),
        Paint()..color = PaletaRotulador.tintaDiluida(0.70),
      );
    }
    // Pravda-7 cayendo (silueta).
    final Offset centroNave = rect.topLeft.translate(
        rect.width * 0.55, rect.height * 0.20);
    final double anchoNave = rect.width * 0.20;
    final double altoNave = rect.height * 0.10;
    // Cuerpo capsula.
    canvas.drawArc(
      Rect.fromCenter(center: centroNave, width: anchoNave, height: altoNave),
      math.pi,
      math.pi,
      true,
      Paint()..color = PaletaRotulador.papelSucio,
    );
    canvas.drawRect(
      Rect.fromCenter(
          center: centroNave.translate(0, altoNave * 0.30),
          width: anchoNave * 0.85,
          height: altoNave * 0.60),
      Paint()..color = PaletaRotulador.papelSucio,
    );
    // Ventanilla iluminada.
    canvas.drawCircle(
      centroNave.translate(0, altoNave * 0.20),
      anchoNave * 0.12,
      Paint()..color = PaletaRotulador.papelSucio,
    );
    canvas.drawCircle(
      centroNave.translate(0, altoNave * 0.20),
      anchoNave * 0.12,
      Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // Estela de caida.
    final Path estela = Path()
      ..moveTo(centroNave.dx - anchoNave * 0.10, centroNave.dy + altoNave * 0.60)
      ..lineTo(centroNave.dx + anchoNave * 0.10, centroNave.dy + altoNave * 0.60)
      ..lineTo(centroNave.dx, rect.bottom);
    canvas.drawPath(
      estela,
      Paint()
        ..color = PaletaRotulador.rojoEstampilla.withValues(alpha: 0.4),
    );
  }

  void _dibujarCadeteFlotando(Canvas canvas, Rect rect) {
    // Oceano de papel viejo.
    canvas.drawRect(rect,
        Paint()..color = PaletaRotulador.papel);
    // Hojas flotando como olas.
    final math.Random rngHojas = math.Random(101);
    for (int indice = 0; indice < 40; indice++) {
      final double xHoja = rect.left + rngHojas.nextDouble() * rect.width;
      final double yHoja = rect.top + rngHojas.nextDouble() * rect.height;
      final double rotacion = rngHojas.nextDouble() * math.pi;
      canvas.save();
      canvas.translate(xHoja, yHoja);
      canvas.rotate(rotacion +
          math.sin(fase * math.pi * 2 + indice) * 0.2);
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset.zero,
            width: rect.width * 0.06,
            height: rect.height * 0.08),
        Paint()..color = PaletaRotulador.papel,
      );
      canvas.drawRect(
        Rect.fromLTWH(
            -rect.width * 0.03, -rect.height * 0.04,
            rect.width * 0.06, rect.height * 0.012),
        Paint()..color = PaletaRotulador.rojoEstampilla,
      );
      canvas.restore();
    }
    // Sol estrella gigante arriba.
    canvas.drawCircle(
      Offset(rect.center.dx, rect.top + rect.height * 0.18),
      rect.width * (0.15 + 0.01 * math.sin(fase * math.pi * 4)),
      Paint()
        ..color = PaletaRotulador.rojoEstampilla.withValues(alpha: 0.85),
    );
    _dibujarEstrellaCinco(
      canvas,
      Offset(rect.center.dx, rect.top + rect.height * 0.18),
      rect.width * 0.10,
      Paint()..color = PaletaRotulador.papel.withValues(alpha: 0.7),
    );

    // Cadete flotando boca arriba.
    dibujarCadeteCosmonauta(
      canvas,
      centro: rect.center.translate(0, rect.height * 0.10),
      alto: rect.height * 0.30,
      pose: PoseCadeteMinijuego.derrotado, // brazos abiertos como flotando
      faseRespiracion: fase,
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
  bool shouldRepaint(covariant _PintorVineta viejo) =>
      viejo.tipo != tipo ||
      viejo.fase != fase ||
      viejo.textoVisible != textoVisible ||
      viejo.completa != completa;
}
