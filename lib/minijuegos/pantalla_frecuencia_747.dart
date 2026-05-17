import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../widgets/propaganda_button.dart';
import '../widgets/breathing_stick_figure.dart';
import '../painters/stick_figure_painter.dart';
import 'pintor_rotulador.dart';
import 'utilidades_carga_sprites.dart';

/// FRECUENCIA 7.47 MHz - DIAL SECRETO.
///
/// Una radio Pravda-7 analogica con dial giratorio. El cadete gira la
/// rueda con A/D (o flechas) en pasos de 0.01 MHz dentro del rango
/// [3.00, 12.00]. Cuando la frecuencia coincide (±0.04 MHz) con una de
/// las siete estaciones secretas, la radio "engancha" la transmision y
/// el panel inferior muestra el texto cifrado palabra a palabra como
/// si llegase por radioteletipo. Cada estacion sintonizada activa un
/// flag en EstadoJuego: el cadete acumula descubrimientos.
class PantallaFrecuencia747 extends StatefulWidget {
  final EstadoJuego estado;

  const PantallaFrecuencia747({super.key, required this.estado});

  @override
  State<PantallaFrecuencia747> createState() => _PantallaFrecuencia747State();
}

class _PantallaFrecuencia747State extends State<PantallaFrecuencia747>
    with SingleTickerProviderStateMixin {
  static const double frecuenciaMinima = 3.00;
  static const double frecuenciaMaxima = 12.00;
  static const double pasoGruesoTeclado = 0.10;
  static const double pasoFinoTeclado = 0.01;
  static const double toleranciaSintonia = 0.04;

  late Ticker tickerRadio;
  Duration? marcaTemporalAnterior;
  final FocusNode nodoFoco = FocusNode(debugLabel: 'frecuencia_747');

  double frecuenciaActual = 7.20;
  double angulosRotor = 0.0; // Para animacion sutil al girar.
  bool girandoMasArriba = false;
  bool girandoMasAbajo = false;
  bool modoFino = false;
  // Fase continua para animar VU meter, estática y otros parpadeos.
  double faseTickRadio = 0.0;

  /// Estacion sintonizada en este momento (si la hay).
  _EstacionSecreta? estacionEnganchada;

  /// Texto que va llegando como teletipo cuando hay enganche.
  String textoTeletipo = '';
  int indiceTextoTeletipo = 0;
  double acumuladorTeletipo = 0.0;
  static const double segundosPorCaracter = 0.04;

  /// Lista de estaciones secretas, ordenadas por frecuencia ascendente.
  final List<_EstacionSecreta> estaciones = <_EstacionSecreta>[
    _EstacionSecreta(
      frecuencia: 3.47,
      identificador: 'PRAVDA-3',
      titulo: 'TRANSMISIÓN INTERNA',
      flag: 'radio_pravda3',
      contenido:
          '… BOLETÍN DEL DÍA. CADETE GROMOV: SE LE RECUERDA QUE EL '
          'CAFÉ DE LA CANTINA NO ES UN RECURSO ESTRATÉGICO. TURNO '
          '14:00. FIN DEL BOLETÍN.',
    ),
    _EstacionSecreta(
      frecuencia: 4.21,
      identificador: 'F-447',
      titulo: 'ARCHIVO AUTÓMATA',
      flag: 'radio_archivo447',
      contenido:
          'F-447 / F-447 / F-447 / SOLICITUD DE SOLICITUD DENEGADA. '
          'F-447 / F-447 / F-447 / TRIPLICAR Y SELLAR. F-447.',
    ),
    _EstacionSecreta(
      frecuencia: 5.62,
      identificador: 'COSMO-A',
      titulo: 'ENLACE COSMONAUTA',
      flag: 'radio_cosmonauta',
      contenido:
          '… AQUÍ VÍKTOR. ESTAMOS A LA SOMBRA DE LA LUNA Y EL FRÍO '
          'ENTRA POR LA JUNTA TRASERA. SI ALGUIEN ME OYE: NO ABRÁIS '
          'LA TAPA DEL F-13. REPITO: NO ABRÁIS EL F-13.',
    ),
    _EstacionSecreta(
      frecuencia: 6.84,
      identificador: 'NOCHE-7',
      titulo: 'NOCTURNO PRAVDA-7',
      flag: 'radio_nocturno',
      contenido:
          '… CANCIÓN PARA TURNO DE NOCHE: «BAJO LA ESTRELLA ROJA, '
          'BAJO LA ESTRELLA ROJA, MI ALMOHADA SUEÑA CON UN FORMULARIO '
          'SIN SELLAR». FIN.',
    ),
    _EstacionSecreta(
      frecuencia: 7.47,
      identificador: 'KAMARADA',
      titulo: 'FRECUENCIA OCULTA',
      flag: 'radio_kamarada',
      contenido:
          '7.47 MHz. SI ESCUCHAS ESTO ERES PARTE. EL CAMARADA DEL '
          'VACÍO NO ES UN HOMBRE: ES UNA SEÑAL QUE VIAJA ENTRE '
          'CADETES. PASA EL DIAL.',
    ),
    _EstacionSecreta(
      frecuencia: 9.13,
      identificador: 'KONSEJO',
      titulo: 'KONSEJO CENTRAL',
      flag: 'radio_konsejo',
      contenido:
          '… DIRECTORSKOV CONVOCA REUNIÓN A LA HORA GROMOV. AGENDA: '
          'PRESUPUESTO DE TINTA, BIGOTES DEL COMITÉ, ETC. NO FALTAR '
          'BAJO PENA DE ARCHIVO.',
    ),
    _EstacionSecreta(
      frecuencia: 11.05,
      identificador: '?-?',
      titulo: 'ESTÁTICA',
      flag: 'radio_estatica',
      contenido:
          '… 4 7 7 7 … 4 7 … VOSTRIKOVA … 4 7 7 … (LA SEÑAL SE '
          'INTERRUMPE. ALGO RESPIRA AL OTRO LADO).',
    ),
  ];

  // Sprites de §18 — cableado anticipado.
  ui.Image? imagenMarcoCompleto; // §18.1
  ui.Image? imagenAgujaDial; // §18.2
  ui.Image? imagenAgujaVu; // §18.3
  ui.Image? imagenPulsoSintonizado; // §18.4
  ui.Image? imagenPanelMensaje; // §18.5

  @override
  void initState() {
    super.initState();
    tickerRadio = createTicker(_alTick)..start();
    _cargarSprites();
  }

  Future<void> _cargarSprites() async {
    final resultados = await cargarLoteOpcional(<String>[
      'assets/svg/radio_marco_completo.png',
      'assets/svg/radio_aguja_dial.png',
      'assets/svg/radio_aguja_vu.png',
      'assets/svg/radio_pulso_sintonizado.png',
      'assets/svg/radio_panel_mensaje.png',
    ]);
    if (!mounted) return;
    setState(() {
      imagenMarcoCompleto = resultados[0];
      imagenAgujaDial = resultados[1];
      imagenAgujaVu = resultados[2];
      imagenPulsoSintonizado = resultados[3];
      imagenPanelMensaje = resultados[4];
    });
  }

  @override
  void dispose() {
    tickerRadio.dispose();
    nodoFoco.dispose();
    super.dispose();
  }

  void _alTick(Duration tiempoAcumulado) {
    final marcaAnterior = marcaTemporalAnterior;
    marcaTemporalAnterior = tiempoAcumulado;
    if (marcaAnterior == null) return;
    final dt = (tiempoAcumulado - marcaAnterior).inMicroseconds / 1e6;
    if (dt <= 0) return;

    faseTickRadio = (faseTickRadio + dt) % 1000.0;

    final double pasoEnUso = modoFino ? pasoFinoTeclado : pasoGruesoTeclado;
    final double velocidadDial = pasoEnUso * 6.0;

    bool huboCambio = false;
    if (girandoMasArriba) {
      frecuenciaActual = math.min(
          frecuenciaMaxima, frecuenciaActual + velocidadDial * dt);
      huboCambio = true;
    }
    if (girandoMasAbajo) {
      frecuenciaActual = math.max(
          frecuenciaMinima, frecuenciaActual - velocidadDial * dt);
      huboCambio = true;
    }

    if (huboCambio) {
      angulosRotor += velocidadDial * dt * 8.0 *
          (girandoMasArriba ? 1.0 : -1.0);
      _revisarSintonia();
    }

    // Avance del teletipo: si hay estacion enganchada, escribimos
    // un caracter cada `segundosPorCaracter`.
    if (estacionEnganchada != null &&
        indiceTextoTeletipo < estacionEnganchada!.contenido.length) {
      acumuladorTeletipo += dt;
      while (acumuladorTeletipo >= segundosPorCaracter &&
          indiceTextoTeletipo < estacionEnganchada!.contenido.length) {
        acumuladorTeletipo -= segundosPorCaracter;
        indiceTextoTeletipo += 1;
        textoTeletipo =
            estacionEnganchada!.contenido.substring(0, indiceTextoTeletipo);
      }
    }

    setState(() {});
  }

  /// Devuelve un valor [0..1] indicando cuán cerca está el dial de la
  /// estación más próxima. 1.0 = enganchada o muy cerca; 0.0 = lejos.
  /// Se usa para iluminar gradualmente el indicador de proximidad.
  double _calcularProximidadAEstacion() {
    const double rangoProximidadVisible = 0.25;
    double distanciaMinima = double.infinity;
    for (final estacion in estaciones) {
      final double distanciaEstacion =
          (estacion.frecuencia - frecuenciaActual).abs();
      if (distanciaEstacion < distanciaMinima) {
        distanciaMinima = distanciaEstacion;
      }
    }
    if (distanciaMinima > rangoProximidadVisible) return 0.0;
    return 1.0 - (distanciaMinima / rangoProximidadVisible);
  }

  void _revisarSintonia() {
    _EstacionSecreta? nuevaEstacion;
    for (final estacion in estaciones) {
      final double distancia =
          (estacion.frecuencia - frecuenciaActual).abs();
      if (distancia <= toleranciaSintonia) {
        nuevaEstacion = estacion;
        break;
      }
    }
    if (nuevaEstacion != estacionEnganchada) {
      estacionEnganchada = nuevaEstacion;
      textoTeletipo = '';
      indiceTextoTeletipo = 0;
      acumuladorTeletipo = 0;
      if (nuevaEstacion != null) {
        widget.estado.activarFlag(nuevaEstacion.flag);
      }
    }
  }

  KeyEventResult _alEventoTeclado(FocusNode nodo, KeyEvent evento) {
    final bool esPulsacion =
        evento is KeyDownEvent || evento is KeyRepeatEvent;
    final bool esLevantamiento = evento is KeyUpEvent;
    final tecla = evento.logicalKey;

    if (tecla == LogicalKeyboardKey.keyD ||
        tecla == LogicalKeyboardKey.arrowRight) {
      if (esPulsacion) girandoMasArriba = true;
      if (esLevantamiento) girandoMasArriba = false;
      return KeyEventResult.handled;
    }
    if (tecla == LogicalKeyboardKey.keyA ||
        tecla == LogicalKeyboardKey.arrowLeft) {
      if (esPulsacion) girandoMasAbajo = true;
      if (esLevantamiento) girandoMasAbajo = false;
      return KeyEventResult.handled;
    }
    if (tecla == LogicalKeyboardKey.shiftLeft ||
        tecla == LogicalKeyboardKey.shiftRight) {
      modoFino = esPulsacion;
      return KeyEventResult.handled;
    }
    if (tecla == LogicalKeyboardKey.escape && esPulsacion) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final int totalSintonizadas = estaciones
        .where((e) => widget.estado.tieneFlag(e.flag))
        .length;
    return Scaffold(
      backgroundColor: PaletaRotulador.papelSucio,
      body: Focus(
        focusNode: nodoFoco,
        autofocus: true,
        onKeyEvent: _alEventoTeclado,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => nodoFoco.requestFocus(),
          child: FondoPapelEnvejecido(
            semilla: 31,
            child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _construirCabecera(totalSintonizadas),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 3, child: _construirRadio()),
                      const SizedBox(width: 18),
                      SizedBox(
                          width: 260, child: _construirPanelEstaciones()),
                    ],
                  ),
                ),
              ],
            ),
          ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirCabecera(int sintonizadas) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'RADIO PRAVDA-7 · ESCUCHA OCULTA',
          style: TextStyle(
            fontFamily: 'CosmoMono',
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: PaletaRotulador.tinta,
            letterSpacing: 3,
          ),
        ),
        Row(
          children: [
            _chip(
                'SINTONIZADAS', '$sintonizadas / ${estaciones.length}',
                acentuado: true),
            const SizedBox(width: 12),
            BotonPropaganda(
              texto: 'Cerrar radio',
              compacto: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _chip(String etiqueta, String valor, {bool acentuado = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: PaletaRotulador.papel,
        border: Border.all(
          color: acentuado
              ? PaletaRotulador.rojoEstampilla
              : PaletaRotulador.tinta,
          width: 1.4,
        ),
      ),
      child: Text(
        '$etiqueta $valor',
        style: TextStyle(
          fontFamily: 'CosmoMono',
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: acentuado
              ? PaletaRotulador.rojoEstampilla
              : PaletaRotulador.tinta,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _construirRadio() {
    return MarcoRotulador(
      color: PaletaRotulador.tinta,
      grosor: 3.6,
      intensidadJitter: 1.5,
      margenInterior: 2.0,
      child: Container(
      decoration: const BoxDecoration(
        color: PaletaRotulador.papel,
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: CustomPaint(
              painter: _PintorDialRadio(
                frecuenciaActual: frecuenciaActual,
                frecuenciaMinima: frecuenciaMinima,
                frecuenciaMaxima: frecuenciaMaxima,
                angulosRotor: angulosRotor,
                enganchada: estacionEnganchada != null,
                estaciones: estaciones,
                flagsActivos: widget.estado.flagsActivos,
                faseTickRadio: faseTickRadio,
                proximidadAEstacion: _calcularProximidadAEstacion(),
                imagenMarcoCompleto: imagenMarcoCompleto,
                imagenAgujaDial: imagenAgujaDial,
                imagenAgujaVu: imagenAgujaVu,
                imagenPulsoSintonizado: imagenPulsoSintonizado,
                imagenPanelMensaje: imagenPanelMensaje,
              ),
              child: Container(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PaletaRotulador.papelSucio,
                border: Border.all(
                  color: estacionEnganchada != null
                      ? PaletaRotulador.rojoEstampilla
                      : PaletaRotulador.tinta.withValues(alpha: 0.55),
                  width: 1.4,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: estacionEnganchada != null
                                ? PaletaRotulador.rojoEstampilla
                                : PaletaRotulador.tintaDiluida(0.30),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          estacionEnganchada == null
                              ? 'BUSCANDO SEÑAL…'
                              : '${estacionEnganchada!.identificador} · '
                                  '${estacionEnganchada!.titulo}',
                          style: const TextStyle(
                            fontFamily: 'CosmoMono',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: PaletaRotulador.tinta,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      estacionEnganchada == null
                          ? 'Esta es una RADIO clandestina Pravda-7.\n'
                              'Gira el dial con A / D (o ◀ ▶) para barrer\n'
                              'la banda de 3.00 a 12.00 MHz. Mantén SHIFT\n'
                              'para AVANCE FINO en pasos de 0.01 MHz.\n'
                              'Hay 7 estaciones ocultas. Cuando aciertes una\n'
                              'frecuencia (±0.04 MHz) el LED se pondrá ROJO\n'
                              'y el teletipo escribirá el mensaje.'
                          : textoTeletipo,
                      style: TextStyle(
                        fontFamily: 'CosmoMono',
                        fontSize: 13,
                        height: 1.5,
                        color: estacionEnganchada == null
                            ? PaletaRotulador.tintaDiluida(0.65)
                            : PaletaRotulador.tinta,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _construirPanelEstaciones() {
    return Container(
      decoration: BoxDecoration(
        color: PaletaRotulador.papel,
        border: Border.all(
          color: PaletaRotulador.tinta,
          width: 1.4,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CÓMO ESCUCHAR',
            style: TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: PaletaRotulador.rojoEstampilla,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '1· Mueve la aguja con A/D.\n'
            '2· Mantén SHIFT para paso fino.\n'
            '3· Aguja roja brillante = cerca.\n'
            '4· LED rojo = enganchada.',
            style: TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 10,
              color: PaletaRotulador.tintaDiluida(0.75),
              height: 1.45,
            ),
          ),
          const Divider(color: PaletaRotulador.tinta, height: 16),
          const Text(
            'CUADERNO DE ESTACIONES',
            style: TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: PaletaRotulador.rojoEstampilla,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                for (final estacion in estaciones)
                  _filaEstacion(estacion),
              ],
            ),
          ),
          const Divider(color: PaletaRotulador.tinta, height: 16),
          const Text(
            'CONTROLES',
            style: TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: PaletaRotulador.rojoEstampilla,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'A / ◀  : bajar dial\n'
            'D / ▶  : subir dial\n'
            'SHIFT  : paso fino\n'
            'ESC    : salir',
            style: TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 11,
              color: PaletaRotulador.tintaDiluida(0.75),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              height: 140,
              width: 90,
              child: StickFigureViviente(
                clase: widget.estado.personaje.clase,
                pose: estacionEnganchada != null
                    ? PoseStickFigure.brazoAlzado
                    : PoseStickFigure.reposoFirme,
                idSombreroEquipado:
                    widget.estado.idObjetoCabezaEquipado,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaEstacion(_EstacionSecreta estacion) {
    final bool descubierta = widget.estado.tieneFlag(estacion.flag);
    final bool actual = estacion == estacionEnganchada;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: descubierta
                  ? PaletaRotulador.rojoEstampilla
                  : PaletaRotulador.tintaDiluida(0.45),
              shape: BoxShape.circle,
              border: Border.all(
                color: actual
                    ? PaletaRotulador.rojoEstampilla
                    : PaletaRotulador.tinta,
                width: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              descubierta
                  ? '${estacion.frecuencia.toStringAsFixed(2)} '
                      '· ${estacion.identificador}'
                  : '${_disfraceFrecuencia(estacion.frecuencia)} · ???',
              style: TextStyle(
                fontFamily: 'CosmoMono',
                fontSize: 11,
                fontWeight: actual ? FontWeight.bold : FontWeight.normal,
                color: descubierta
                    ? PaletaRotulador.tinta
                    : PaletaRotulador.tintaDiluida(0.40),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Para estaciones no descubiertas mostramos solo el rango aproximado.
  String _disfraceFrecuencia(double frecuencia) {
    final int bloque = frecuencia.floor();
    return '$bloque.??';
  }
}

class _EstacionSecreta {
  final double frecuencia;
  final String identificador;
  final String titulo;
  final String flag;
  final String contenido;

  const _EstacionSecreta({
    required this.frecuencia,
    required this.identificador,
    required this.titulo,
    required this.flag,
    required this.contenido,
  });
}

class _PintorDialRadio extends CustomPainter {
  final double frecuenciaActual;
  final double frecuenciaMinima;
  final double frecuenciaMaxima;
  final double angulosRotor;
  final bool enganchada;
  final List<_EstacionSecreta> estaciones;
  final Set<String> flagsActivos;
  final double faseTickRadio;
  final double proximidadAEstacion;
  /// Sprites §18 — null si asset no generado / no cargado.
  final ui.Image? imagenMarcoCompleto;
  final ui.Image? imagenAgujaDial;
  final ui.Image? imagenAgujaVu;
  final ui.Image? imagenPulsoSintonizado;
  final ui.Image? imagenPanelMensaje;

  _PintorDialRadio({
    required this.frecuenciaActual,
    required this.frecuenciaMinima,
    required this.frecuenciaMaxima,
    required this.angulosRotor,
    required this.enganchada,
    required this.estaciones,
    required this.flagsActivos,
    required this.faseTickRadio,
    required this.proximidadAEstacion,
    this.imagenMarcoCompleto,
    this.imagenAgujaDial,
    this.imagenAgujaVu,
    this.imagenPulsoSintonizado,
    this.imagenPanelMensaje,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double margen = size.width * 0.06;
    final Rect rectDial = Rect.fromLTWH(
      margen,
      size.height * 0.18,
      size.width - margen * 2,
      size.height * 0.42,
    );

    // Fondo del cuadrante (papel ligeramente más amarillento).
    canvas.drawRect(
      rectDial,
      Paint()..color = PaletaRotulador.papelSucio,
    );
    canvas.drawRect(
      rectDial,
      Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Marcas numericas cada 0.5 MHz, principales cada 1 MHz.
    final double rango = frecuenciaMaxima - frecuenciaMinima;
    double freq = frecuenciaMinima;
    while (freq <= frecuenciaMaxima + 0.001) {
      final double fraccion = (freq - frecuenciaMinima) / rango;
      final double xMarca = rectDial.left + fraccion * rectDial.width;
      final bool esEntero = ((freq * 10).round() % 10) == 0;
      final double alturaMarca = esEntero ? 14 : 7;
      canvas.drawLine(
        Offset(xMarca, rectDial.top),
        Offset(xMarca, rectDial.top + alturaMarca),
        Paint()
          ..color = PaletaRotulador.tinta
          ..strokeWidth = esEntero ? 1.8 : 1.0,
      );
      if (esEntero) {
        final pintorNum = TextPainter(
          text: TextSpan(
            text: freq.toStringAsFixed(0),
            style: const TextStyle(
              color: PaletaRotulador.tinta,
              fontFamily: 'CosmoMono',
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        pintorNum.paint(
          canvas,
          Offset(xMarca - pintorNum.width / 2,
              rectDial.top + alturaMarca + 2),
        );
      }
      freq += 0.5;
    }

    // Marcas de estaciones descubiertas (estrellas rojas en su frecuencia).
    for (final estacion in estaciones) {
      if (!flagsActivos.contains(estacion.flag)) continue;
      final double fraccion =
          (estacion.frecuencia - frecuenciaMinima) / rango;
      final double xEstrella =
          rectDial.left + fraccion * rectDial.width;
      _dibujarEstrellaCinco(
        canvas,
        Offset(xEstrella, rectDial.top + rectDial.height * 0.55),
        6,
        Paint()..color = PaletaRotulador.rojoEstampilla,
      );
    }

    // Aguja indicadora — pasa de rojo a verde con la proximidad.
    final double fraccionActual =
        (frecuenciaActual - frecuenciaMinima) / rango;
    final double xAguja =
        rectDial.left + fraccionActual * rectDial.width;
    final Color colorAguja = enganchada
        ? PaletaRotulador.rojoEstampilla
        : Color.lerp(
            PaletaRotulador.tinta,
            PaletaRotulador.rojoEstampilla,
            proximidadAEstacion * 0.8,
          )!;
    // Halo de proximidad (más intenso cuanto más cerca).
    if (proximidadAEstacion > 0.05) {
      canvas.drawCircle(
        Offset(xAguja, rectDial.top + rectDial.height / 2),
        rectDial.height * 0.6 * proximidadAEstacion,
        Paint()
          ..color = PaletaRotulador.rojoEstampilla
              .withValues(alpha: 0.10 + proximidadAEstacion * 0.15)
          ..maskFilter =
              const MaskFilter.blur(BlurStyle.normal, 6.0),
      );
    }
    canvas.drawLine(
      Offset(xAguja, rectDial.top - 6),
      Offset(xAguja, rectDial.bottom + 6),
      Paint()
        ..color = colorAguja
        ..strokeWidth = 2.4,
    );
    // Triangulo arriba.
    final caminoTriangulo = Path()
      ..moveTo(xAguja - 7, rectDial.top - 6)
      ..lineTo(xAguja + 7, rectDial.top - 6)
      ..lineTo(xAguja, rectDial.top + 2)
      ..close();
    canvas.drawPath(
      caminoTriangulo,
      Paint()..color = colorAguja,
    );

    // Indicador de frecuencia digital.
    final pintorFrec = TextPainter(
      text: TextSpan(
        text: '${frecuenciaActual.toStringAsFixed(2)} MHz',
        style: TextStyle(
          color: enganchada
              ? PaletaRotulador.rojoEstampilla
              : PaletaRotulador.tinta,
          fontFamily: 'CosmoMono',
          fontSize: 28,
          fontWeight: FontWeight.w900,
          letterSpacing: 3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintorFrec.paint(
      canvas,
      Offset(size.width / 2 - pintorFrec.width / 2, size.height * 0.02),
    );

    // Rueda giratoria a la derecha (testimonio visual del giro del dial).
    final Offset centroRueda =
        Offset(size.width - margen * 1.8, size.height * 0.82);
    final double radioRueda = size.width * 0.08;
    canvas.drawCircle(
      centroRueda,
      radioRueda,
      Paint()..color = PaletaRotulador.tinta,
    );
    canvas.drawCircle(
      centroRueda,
      radioRueda,
      Paint()
        ..color = PaletaRotulador.papel
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Marcas radiales que giran con angulosRotor.
    for (int marca = 0; marca < 12; marca++) {
      final double angulo = angulosRotor + marca * math.pi / 6;
      final Offset desde = centroRueda + Offset(
          math.cos(angulo) * radioRueda * 0.65,
          math.sin(angulo) * radioRueda * 0.65);
      final Offset hasta = centroRueda + Offset(
          math.cos(angulo) * radioRueda * 0.95,
          math.sin(angulo) * radioRueda * 0.95);
      canvas.drawLine(
        desde,
        hasta,
        Paint()
          ..color = PaletaRotulador.papel
          ..strokeWidth = 1.5,
      );
    }
    // Eje de la rueda.
    canvas.drawCircle(
      centroRueda,
      radioRueda * 0.18,
      Paint()..color = PaletaRotulador.rojoEstampilla,
    );

    // VU meter central: 7 barras verticales que oscilan.
    _dibujarVuMeter(canvas, size, margen);

    // Estatica visual sobre el dial cuando no hay sintonia.
    if (!enganchada) {
      _dibujarEstaticaSobreDial(canvas, rectDial);
    }

    // LED de sintonia a la izquierda.
    final Offset centroLed = Offset(margen * 1.6, size.height * 0.82);
    canvas.drawCircle(
      centroLed,
      14,
      Paint()
        ..color = enganchada
            ? PaletaRotulador.rojoEstampilla
            : PaletaRotulador.tintaDiluida(0.45),
    );
    canvas.drawCircle(
      centroLed,
      14,
      Paint()
        ..color = PaletaRotulador.papel
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final pintorLed = TextPainter(
      text: const TextSpan(
        text: 'SINTONÍA',
        style: TextStyle(
          color: PaletaRotulador.tinta,
          fontFamily: 'CosmoMono',
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintorLed.paint(
      canvas,
      Offset(centroLed.dx + 22, centroLed.dy - pintorLed.height / 2),
    );
  }

  void _dibujarVuMeter(Canvas canvas, Size size, double margen) {
    const int cantidadBarrasVu = 7;
    final double anchoBarraVu = size.width * 0.018;
    final double altoMaximoVu = size.height * 0.22;
    final double separacionVu = anchoBarraVu * 0.6;
    final double anchoTotalVu = cantidadBarrasVu * anchoBarraVu +
        (cantidadBarrasVu - 1) * separacionVu;
    final double inicioXVu = size.width / 2 - anchoTotalVu / 2;
    final double yBaseVu = size.height * 0.92;

    // Marco del VU meter: papel sucio con borde tinta.
    canvas.drawRect(
      Rect.fromLTWH(
        inicioXVu - 8,
        yBaseVu - altoMaximoVu - 6,
        anchoTotalVu + 16,
        altoMaximoVu + 12,
      ),
      Paint()..color = PaletaRotulador.papelSucio,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        inicioXVu - 8,
        yBaseVu - altoMaximoVu - 6,
        anchoTotalVu + 16,
        altoMaximoVu + 12,
      ),
      Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    for (int indiceBarra = 0; indiceBarra < cantidadBarrasVu; indiceBarra++) {
      // Nivel pseudoaleatorio dependiente del tiempo y de la barra.
      final double fasePropia =
          faseTickRadio * 6.0 + indiceBarra * 1.3;
      double nivelBarra = (math.sin(fasePropia) +
              math.sin(fasePropia * 2.4 + indiceBarra) * 0.6) /
          1.6;
      nivelBarra = (nivelBarra + 1) / 2; // [0..1]
      // Si NO hay enganche, el nivel es bajo (estática); si hay enganche, alto.
      final double nivelFinal = enganchada
          ? 0.35 + nivelBarra * 0.65
          : 0.05 + nivelBarra * 0.20;

      final double altoBarra = altoMaximoVu * nivelFinal;
      final double xBarra =
          inicioXVu + indiceBarra * (anchoBarraVu + separacionVu);
      // Color por nivel: rojo cuando se aproxima a saturación, tinta
      // diluida en niveles medios/bajos.
      final Color colorBarra = nivelFinal > 0.75
          ? PaletaRotulador.rojoEstampilla
          : nivelFinal > 0.45
              ? PaletaRotulador.tintaDiluida(0.80)
              : PaletaRotulador.tintaDiluida(0.50);
      canvas.drawRect(
        Rect.fromLTWH(
          xBarra,
          yBaseVu - altoBarra,
          anchoBarraVu,
          altoBarra,
        ),
        Paint()..color = colorBarra,
      );
    }

    // Etiqueta VU.
    final pintorEtiquetaVu = TextPainter(
      text: const TextSpan(
        text: 'VU',
        style: TextStyle(
          color: PaletaRotulador.tinta,
          fontFamily: 'CosmoMono',
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintorEtiquetaVu.paint(
      canvas,
      Offset(inicioXVu - 8 + (anchoTotalVu + 16) / 2 - pintorEtiquetaVu.width / 2,
          yBaseVu + 2),
    );
  }

  void _dibujarEstaticaSobreDial(Canvas canvas, Rect rectDial) {
    // Estática visual: pequeños puntos blancos pseudoaleatorios sobre el dial.
    final math.Random rngEstatica =
        math.Random((faseTickRadio * 60).floor() ~/ 2);
    final Paint pincelEstatica = Paint()
      ..color = PaletaRotulador.tinta.withValues(alpha: 0.18);
    for (int indicePunto = 0; indicePunto < 35; indicePunto++) {
      canvas.drawCircle(
        Offset(
          rectDial.left + rngEstatica.nextDouble() * rectDial.width,
          rectDial.top + rngEstatica.nextDouble() * rectDial.height,
        ),
        0.8 + rngEstatica.nextDouble() * 1.2,
        pincelEstatica,
      );
    }
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
  bool shouldRepaint(covariant _PintorDialRadio viejo) => true;
}
