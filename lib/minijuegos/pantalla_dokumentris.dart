import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../theme.dart';
import '../widgets/propaganda_button.dart';
import 'pintor_rotulador.dart';
import 'widget_pausa.dart';
import '../widgets/breathing_stick_figure.dart';
import '../painters/stick_figure_painter.dart';

/// DOKUMENTRIS — Tetris burocratico.
///
/// Los bloques son formularios F-447 que caen sobre el escritorio del
/// cadete. Cuando una fila se completa, se sella en rojo y desaparece
/// con un clack mecanografiado. La velocidad de caida aumenta con la
/// cuota de archivo (nivel). La maxima puntuacion queda registrada en
/// los flags del EstadoJuego.
class PantallaDokumentris extends StatefulWidget {
  final EstadoJuego estado;

  const PantallaDokumentris({super.key, required this.estado});

  @override
  State<PantallaDokumentris> createState() => _PantallaDokumentrisState();
}

class _PantallaDokumentrisState extends State<PantallaDokumentris>
    with SingleTickerProviderStateMixin {
  static const int columnasTablero = 10;
  static const int filasTablero = 20;

  // Velocidad de caida: ms por celda. Disminuye al subir nivel.
  static const int msCaidaPorNivelInicial = 800;

  /// Matriz de celdas. null = vacia. int 0..6 = tipo de pieza coloreada.
  late List<List<int?>> celdasTablero;

  late Ticker tickerJuego;
  Duration? marcaTemporalAnterior;
  double msAcumuladosCaida = 0;
  double msAcumuladosAnimacionLineas = 0;

  /// Filas marcadas para borrar (animacion de sellado en curso).
  List<int> filasParaBorrar = <int>[];
  static const double duracionAnimacionLineasMs = 280;

  late _PiezaTetromino piezaActual;
  late _PiezaTetromino piezaSiguiente;

  int puntuacion = 0;
  int filasBorradas = 0;
  int nivel = 1;
  bool partidaTerminada = false;
  bool partidaPausada = false;
  final FocusNode nodoFoco = FocusNode(debugLabel: 'dokumentris');

  // Mensaje flash de propaganda visible durante unos segundos.
  String? mensajePropaganda;
  double msMensajePropagandaRestantes = 0;
  // Indica si el último borrado fue un "dokumentris" (4 líneas).
  bool ultimoBorradoFueCuadruple = false;

  final math.Random aleatorio = math.Random();

  // En estilo rotulador, todos los formularios son papel; lo que les da
  // identidad es el sello (etiqueta) y un patrón de rayado distinto.
  static const List<Color> coloresPorTipo = [
    PaletaRotulador.papel, // 0 — I
    PaletaRotulador.papel, // 1 — O
    PaletaRotulador.papel, // 2 — T
    PaletaRotulador.papel, // 3 — L
    PaletaRotulador.papel, // 4 — J
    PaletaRotulador.papel, // 5 — S
    PaletaRotulador.papel, // 6 — Z
  ];

  /// Etiqueta corta visible en cada celda (sello del formulario).
  static const List<String> etiquetasPorTipo = [
    'I', 'O', 'T', 'L', 'J', 'S', 'Z',
  ];

  /// Definicion canonica de cada tetromino. Cada matriz 4x4 indica
  /// las celdas ocupadas en rotacion 0.
  static const List<List<List<int>>> matricesPorTipo = [
    // I
    [
      [0, 0, 0, 0],
      [1, 1, 1, 1],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    // O
    [
      [0, 1, 1, 0],
      [0, 1, 1, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    // T
    [
      [0, 1, 0, 0],
      [1, 1, 1, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    // L
    [
      [0, 0, 1, 0],
      [1, 1, 1, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    // J
    [
      [1, 0, 0, 0],
      [1, 1, 1, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    // S
    [
      [0, 1, 1, 0],
      [1, 1, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    // Z
    [
      [1, 1, 0, 0],
      [0, 1, 1, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
  ];

  @override
  void initState() {
    super.initState();
    _resetearPartida();
    tickerJuego = createTicker(_alTick)..start();
  }

  void _resetearPartida() {
    celdasTablero = List.generate(
      filasTablero,
      (_) => List<int?>.filled(columnasTablero, null),
    );
    piezaActual = _generarNuevaPieza();
    piezaSiguiente = _generarNuevaPieza();
    puntuacion = 0;
    filasBorradas = 0;
    nivel = 1;
    partidaTerminada = false;
    partidaPausada = false;
    msAcumuladosCaida = 0;
    filasParaBorrar = <int>[];
    msAcumuladosAnimacionLineas = 0;
  }

  _PiezaTetromino _generarNuevaPieza() {
    final tipo = aleatorio.nextInt(7);
    return _PiezaTetromino(
      tipo: tipo,
      matriz: _clonarMatriz(matricesPorTipo[tipo]),
      columnaPivot: columnasTablero ~/ 2 - 2,
      filaPivot: 0,
    );
  }

  List<List<int>> _clonarMatriz(List<List<int>> matriz) {
    return matriz.map((fila) => List<int>.from(fila)).toList();
  }

  @override
  void dispose() {
    tickerJuego.dispose();
    nodoFoco.dispose();
    super.dispose();
  }

  void _alTick(Duration tiempoAcumulado) {
    final marcaAnterior = marcaTemporalAnterior;
    marcaTemporalAnterior = tiempoAcumulado;
    if (marcaAnterior == null) return;
    final msTranscurridos =
        (tiempoAcumulado - marcaAnterior).inMicroseconds / 1000.0;
    if (msTranscurridos <= 0) return;
    if (partidaTerminada || partidaPausada) return;

    // Animacion de borrado de lineas: pausa la caida y el input.
    if (filasParaBorrar.isNotEmpty) {
      msAcumuladosAnimacionLineas += msTranscurridos;
      if (msAcumuladosAnimacionLineas >= duracionAnimacionLineasMs) {
        _completarBorradoFilas();
      } else {
        setState(() {});
      }
      return;
    }

    if (msMensajePropagandaRestantes > 0) {
      msMensajePropagandaRestantes -= msTranscurridos;
      if (msMensajePropagandaRestantes <= 0) {
        msMensajePropagandaRestantes = 0;
        mensajePropaganda = null;
      }
      setState(() {});
    }

    msAcumuladosCaida += msTranscurridos;
    final msPorCelda =
        math.max(55, msCaidaPorNivelInicial - (nivel - 1) * 70).toDouble();
    if (msAcumuladosCaida >= msPorCelda) {
      msAcumuladosCaida = 0;
      _intentarBajarPieza();
    }
  }

  void _mostrarMensajePropaganda(String mensaje, {double duracionMs = 2200}) {
    setState(() {
      mensajePropaganda = mensaje;
      msMensajePropagandaRestantes = duracionMs;
    });
  }

  /// Empuja la pieza una celda hacia abajo. Si choca, la fija al
  /// tablero y genera la siguiente. Termina la partida si la nueva
  /// pieza nace solapada con bloques existentes.
  void _intentarBajarPieza() {
    final movida = piezaActual.copiarConDesplazamiento(0, 1);
    if (_esPosicionValida(movida)) {
      setState(() => piezaActual = movida);
      return;
    }
    _fijarPiezaActualAlTablero();
    _detectarFilasCompletas();
    if (filasParaBorrar.isNotEmpty) {
      msAcumuladosAnimacionLineas = 0;
      return;
    }
    _activarSiguientePieza();
  }

  void _activarSiguientePieza() {
    piezaActual = piezaSiguiente;
    piezaSiguiente = _generarNuevaPieza();
    if (!_esPosicionValida(piezaActual)) {
      setState(() => partidaTerminada = true);
      _registrarHighscoreSiToca();
    }
  }

  void _fijarPiezaActualAlTablero() {
    final cells = piezaActual.celdasOcupadasGlobales();
    for (final celda in cells) {
      if (celda.dy >= 0 &&
          celda.dy < filasTablero &&
          celda.dx >= 0 &&
          celda.dx < columnasTablero) {
        celdasTablero[celda.dy.toInt()][celda.dx.toInt()] =
            piezaActual.tipo;
      }
    }
  }

  void _detectarFilasCompletas() {
    final filasFull = <int>[];
    for (int indiceFila = 0; indiceFila < filasTablero; indiceFila++) {
      if (celdasTablero[indiceFila].every((celda) => celda != null)) {
        filasFull.add(indiceFila);
      }
    }
    if (filasFull.isNotEmpty) {
      setState(() {
        filasParaBorrar = filasFull;
      });
    }
  }

  void _completarBorradoFilas() {
    final cantidadBorradas = filasParaBorrar.length;
    // Eliminamos las filas y bajamos las que estan encima.
    for (final indiceFila in filasParaBorrar.toList()..sort()) {
      celdasTablero.removeAt(indiceFila);
      celdasTablero.insert(
        0,
        List<int?>.filled(columnasTablero, null),
      );
    }
    final bonus = switch (cantidadBorradas) {
      1 => 100,
      2 => 300,
      3 => 500,
      _ => 800,
    };
    final int nivelAnterior = nivel;
    setState(() {
      puntuacion += bonus * nivel;
      filasBorradas += cantidadBorradas;
      nivel = 1 + filasBorradas ~/ 8;
      filasParaBorrar = <int>[];
      msAcumuladosAnimacionLineas = 0;
      ultimoBorradoFueCuadruple = cantidadBorradas >= 4;
    });
    if (cantidadBorradas >= 4) {
      _mostrarMensajePropaganda('★ DOKUMENTRIS OFICIAL ★\nCUOTA TRIPLICADA');
    } else if (nivel > nivelAnterior) {
      _mostrarMensajePropaganda(
          'CUOTA DE ARCHIVO AUMENTADA\nNIVEL $nivel · ACELERAR PRENSAS');
    }
    // Hitos propaganda cada 10 filas — convertimos el modo arcade infinito
    // en algo "celebratorio": el cadete recibe consignas cada vez que cruza
    // un múltiplo de 10 en su cuota.
    final int decenaAnterior = (filasBorradas - cantidadBorradas) ~/ 10;
    final int decenaActual = filasBorradas ~/ 10;
    if (decenaActual > decenaAnterior && decenaActual > 0) {
      final List<String> consignasPropaganda = <String>[
        'CUOTA 10 SUPERADA\nEL CADETE PROMETE',
        'CUOTA 20 SUPERADA\nEL ARCHIVO RESPIRA',
        'CUOTA 30 SUPERADA\nDIRECTORSKOV TOMA NOTA',
        'CUOTA 40 SUPERADA\nLA TINTA NO ALCANZA',
        'CUOTA 50 SUPERADA\n¡HÉROE DEL EXPEDIENTE!',
        'CUOTA 60 SUPERADA\nVOSTRIKOVA ASIENTE',
        'CUOTA 70 SUPERADA\nF-447 ETERNO',
        'CUOTA 80 SUPERADA\nEL PAPEL NUNCA DUERME',
        'CUOTA 90 SUPERADA\nESTRELLA ROJA EN PRAVDA-12',
        'CUOTA 100 SUPERADA\n★ COSMONAUTA EJEMPLAR ★',
      ];
      final int indiceConsignaPropaganda =
          math.min(decenaActual - 1, consignasPropaganda.length - 1);
      _mostrarMensajePropaganda(
          consignasPropaganda[indiceConsignaPropaganda],
          duracionMs: 2800);
    }
    _activarSiguientePieza();
  }

  bool _esPosicionValida(_PiezaTetromino pieza) {
    final celdas = pieza.celdasOcupadasGlobales();
    for (final celda in celdas) {
      final fila = celda.dy.toInt();
      final col = celda.dx.toInt();
      if (col < 0 || col >= columnasTablero) return false;
      if (fila >= filasTablero) return false;
      if (fila < 0) continue; // Permitido nacer sobre el tope.
      if (celdasTablero[fila][col] != null) return false;
    }
    return true;
  }

  void _moverIzquierda() {
    if (partidaTerminada || partidaPausada) return;
    if (filasParaBorrar.isNotEmpty) return;
    final movida = piezaActual.copiarConDesplazamiento(-1, 0);
    if (_esPosicionValida(movida)) {
      setState(() => piezaActual = movida);
    }
  }

  void _moverDerecha() {
    if (partidaTerminada || partidaPausada) return;
    if (filasParaBorrar.isNotEmpty) return;
    final movida = piezaActual.copiarConDesplazamiento(1, 0);
    if (_esPosicionValida(movida)) {
      setState(() => piezaActual = movida);
    }
  }

  void _bajarSuave() {
    if (partidaTerminada || partidaPausada) return;
    if (filasParaBorrar.isNotEmpty) return;
    final movida = piezaActual.copiarConDesplazamiento(0, 1);
    if (_esPosicionValida(movida)) {
      setState(() {
        piezaActual = movida;
        puntuacion += 1;
      });
    }
  }

  void _bajarBrusco() {
    if (partidaTerminada || partidaPausada) return;
    if (filasParaBorrar.isNotEmpty) return;
    var movida = piezaActual;
    int celdasBajadas = 0;
    while (true) {
      final siguiente = movida.copiarConDesplazamiento(0, 1);
      if (!_esPosicionValida(siguiente)) break;
      movida = siguiente;
      celdasBajadas++;
    }
    setState(() {
      piezaActual = movida;
      puntuacion += celdasBajadas * 2;
    });
    msAcumuladosCaida = msCaidaPorNivelInicial.toDouble();
  }

  void _rotarHorario() {
    if (partidaTerminada || partidaPausada) return;
    if (filasParaBorrar.isNotEmpty) return;
    final rotada = piezaActual.copiarConRotacionHoraria();
    if (_esPosicionValida(rotada)) {
      setState(() => piezaActual = rotada);
    } else {
      // Wall-kick basico: probar +1 y -1 col.
      final intentos = [1, -1, 2, -2];
      for (final desplazamiento in intentos) {
        final rotadaDesplazada =
            rotada.copiarConDesplazamiento(desplazamiento, 0);
        if (_esPosicionValida(rotadaDesplazada)) {
          setState(() => piezaActual = rotadaDesplazada);
          return;
        }
      }
    }
  }

  void _registrarHighscoreSiToca() {
    final prev = _leerHighscoreActual(widget.estado);
    if (puntuacion > prev) {
      _guardarHighscore(widget.estado, puntuacion);
    }
  }

  KeyEventResult _alEventoTeclado(FocusNode nodo, KeyEvent evento) {
    if (evento is! KeyDownEvent && evento is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final tecla = evento.logicalKey;

    if (evento is KeyDownEvent &&
        tecla == LogicalKeyboardKey.keyP &&
        !partidaTerminada) {
      setState(() {
        partidaPausada = !partidaPausada;
      });
      return KeyEventResult.handled;
    }
    if (partidaPausada) {
      return KeyEventResult.handled;
    }

    if (partidaTerminada) {
      if (tecla == LogicalKeyboardKey.enter ||
          tecla == LogicalKeyboardKey.space) {
        setState(_resetearPartida);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    if (tecla == LogicalKeyboardKey.arrowLeft ||
        tecla == LogicalKeyboardKey.keyA) {
      _moverIzquierda();
      return KeyEventResult.handled;
    }
    if (tecla == LogicalKeyboardKey.arrowRight ||
        tecla == LogicalKeyboardKey.keyD) {
      _moverDerecha();
      return KeyEventResult.handled;
    }
    if (tecla == LogicalKeyboardKey.arrowDown ||
        tecla == LogicalKeyboardKey.keyS) {
      _bajarSuave();
      return KeyEventResult.handled;
    }
    if (tecla == LogicalKeyboardKey.arrowUp ||
        tecla == LogicalKeyboardKey.keyW) {
      _rotarHorario();
      return KeyEventResult.handled;
    }
    if (tecla == LogicalKeyboardKey.space) {
      _bajarBrusco();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final mejor = _leerHighscoreActual(widget.estado);
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
            semilla: 11,
            child: Stack(
              children: [
                SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _construirCabecera(mejor),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _construirTablero()),
                          const SizedBox(width: 18),
                          SizedBox(width: 220, child: _construirPanelLateral()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
                ),
                OverlayPausaMinijuego(visible: partidaPausada),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirCabecera(int mejor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'DOKUMENTRIS · CABINA ARCADE OFICIAL',
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
            _chipDato('NIVEL', '$nivel'),
            const SizedBox(width: 8),
            _chipDato('FILAS', '$filasBorradas'),
            const SizedBox(width: 8),
            _chipDato('CUOTA', '$puntuacion'),
            const SizedBox(width: 8),
            _chipDato('RÉCORD', '$mejor', acentuado: true),
            const SizedBox(width: 12),
            BotonPropaganda(
              texto: 'Salir',
              compacto: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _chipDato(String etiqueta, String valor, {bool acentuado = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: PaletaRotulador.papel,
        border: Border.all(
          color: acentuado
              ? PaletaRotulador.rojoEstampilla
              : PaletaRotulador.tinta,
          width: 1.4,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$etiqueta ',
            style: TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 10,
              color: PaletaRotulador.tintaDiluida(0.65),
              letterSpacing: 1.2,
            ),
          ),
          Text(
            valor,
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
        ],
      ),
    );
  }

  Widget _construirTablero() {
    return Center(
      child: AspectRatio(
        aspectRatio: columnasTablero / filasTablero,
        child: MarcoRotulador(
          color: PaletaRotulador.tinta,
          grosor: 3.0,
          intensidadJitter: 1.4,
          margenInterior: 2.0,
          child: Container(
          decoration: const BoxDecoration(
            color: PaletaRotulador.papel,
          ),
          child: LayoutBuilder(
            builder: (contexto, restricciones) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _PintorTableroDokumentris(
                        celdasFijas: celdasTablero,
                        piezaActual: partidaTerminada ? null : piezaActual,
                        filasParaBorrar: filasParaBorrar,
                        fragmentoAnimacionBorrado: filasParaBorrar.isEmpty
                            ? 0
                            : msAcumuladosAnimacionLineas /
                                duracionAnimacionLineasMs,
                      ),
                    ),
                  ),
                  if (partidaTerminada)
                    _overlayTexto(
                        'EXPEDIENTE CERRADO · pulsa Espacio/Enter para reabrir el caso'),
                  if (mensajePropaganda != null && !partidaTerminada)
                    _bannerPropaganda(mensajePropaganda!),
                ],
              );
            },
          ),
          ),
        ),
      ),
    );
  }

  Widget _overlayTexto(String texto) {
    return Positioned.fill(
      child: Container(
        color: PaletaRotulador.papel.withValues(alpha: 0.92),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'CosmoMono',
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: PaletaRotulador.rojoEstampilla,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bannerPropaganda(String mensaje) {
    // Calcula opacidad a partir del tiempo restante (fade-in/out).
    final double progresoMensaje = msMensajePropagandaRestantes / 2200.0;
    final double opacidadBanner = progresoMensaje > 0.85
        ? (1.0 - progresoMensaje) / 0.15
        : progresoMensaje < 0.20
            ? progresoMensaje / 0.20
            : 1.0;
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacidadBanner.clamp(0.0, 1.0),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: PaletaCosmoSovietica.rojoOficial,
              border: Border.all(
                color: PaletaCosmoSovietica.papelViejo,
                width: 2,
              ),
            ),
            child: Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'CosmoMono',
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: PaletaCosmoSovietica.papelViejo,
                letterSpacing: 1.5,
                height: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirPanelLateral() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PaletaRotulador.papel,
        border: Border.all(
          color: PaletaRotulador.tinta,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SIGUIENTE FORMULARIO',
            style: TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: PaletaRotulador.rojoEstampilla,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: PaletaRotulador.papelSucio,
                border: Border.all(
                  color: PaletaRotulador.tinta,
                  width: 1.5,
                ),
              ),
              child: CustomPaint(
                painter: _PintorPiezaPreview(pieza: piezaSiguiente),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: PaletaRotulador.tinta, height: 1),
          const SizedBox(height: 8),
          const Text(
            'INSTRUCTIVO DEL CADETE',
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
            '◀ ▶  o A / D : alinear formulario\n'
            '▼  o S       : presionar a fondo\n'
            '▲  o W       : rotar 90°\n'
            'ESPACIO      : sellar al instante\n'
            'P / ESC      : pausar / reanudar',
            style: TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 11,
              color: PaletaRotulador.tintaDiluida(0.75),
              height: 1.45,
            ),
          ),
          const Spacer(),
          Center(
            child: SizedBox(
              height: 200,
              width: 130,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Mesa-zócalo bajo el cadete.
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 10,
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: PaletaRotulador.tinta,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Pila de expedientes a la derecha.
                  Positioned(
                    right: 4,
                    bottom: 12,
                    width: 32,
                    height: 18,
                    child: CustomPaint(
                      painter: _PintorPilaExpedientes(),
                    ),
                  ),
                  // Cadete con cabeza PNG real (misma silueta que en
                  // los escenarios). Si la pieza está cerca de caer
                  // el brazo se alza como sellando.
                  StickFigureViviente(
                    clase: widget.estado.personaje.clase,
                    pose:
                        (msAcumuladosCaida / 500.0).floor().isOdd
                            ? PoseStickFigure.brazoAlzado
                            : PoseStickFigure.reposoFirme,
                    idSombreroEquipado:
                        widget.estado.idObjetoCabezaEquipado,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '«El cosmonauta competente apila los expedientes sin demora.»',
            style: TextStyle(
              fontFamily: 'CosmoSerif',
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: PaletaRotulador.tinta,
            ),
          ),
        ],
      ),
    );
  }
}

class _PiezaTetromino {
  final int tipo;
  final List<List<int>> matriz; // 4x4
  final int columnaPivot;
  final int filaPivot;

  _PiezaTetromino({
    required this.tipo,
    required this.matriz,
    required this.columnaPivot,
    required this.filaPivot,
  });

  _PiezaTetromino copiarConDesplazamiento(int dCol, int dFila) {
    return _PiezaTetromino(
      tipo: tipo,
      matriz: matriz,
      columnaPivot: columnaPivot + dCol,
      filaPivot: filaPivot + dFila,
    );
  }

  _PiezaTetromino copiarConRotacionHoraria() {
    final tamano = matriz.length;
    final nuevaMatriz =
        List.generate(tamano, (_) => List<int>.filled(tamano, 0));
    for (int fila = 0; fila < tamano; fila++) {
      for (int columna = 0; columna < tamano; columna++) {
        nuevaMatriz[columna][tamano - 1 - fila] = matriz[fila][columna];
      }
    }
    return _PiezaTetromino(
      tipo: tipo,
      matriz: nuevaMatriz,
      columnaPivot: columnaPivot,
      filaPivot: filaPivot,
    );
  }

  List<Offset> celdasOcupadasGlobales() {
    final resultado = <Offset>[];
    for (int fila = 0; fila < matriz.length; fila++) {
      for (int columna = 0; columna < matriz[fila].length; columna++) {
        if (matriz[fila][columna] == 1) {
          resultado.add(
              Offset((columnaPivot + columna).toDouble(),
                  (filaPivot + fila).toDouble()));
        }
      }
    }
    return resultado;
  }
}

class _PintorTableroDokumentris extends CustomPainter {
  final List<List<int?>> celdasFijas;
  final _PiezaTetromino? piezaActual;
  final List<int> filasParaBorrar;
  final double fragmentoAnimacionBorrado;

  _PintorTableroDokumentris({
    required this.celdasFijas,
    required this.piezaActual,
    required this.filasParaBorrar,
    required this.fragmentoAnimacionBorrado,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cols = _PantallaDokumentrisState.columnasTablero;
    final filas = _PantallaDokumentrisState.filasTablero;
    final anchoCelda = size.width / cols;
    final altoCelda = size.height / filas;

    // Rejilla de cuadrícula tipo cuaderno: tinta diluida sobre papel.
    final pincelRejilla = Paint()
      ..color = PaletaRotulador.tintaDiluida(0.12)
      ..strokeWidth = 0.8;
    for (int indiceCol = 1; indiceCol < cols; indiceCol++) {
      final x = indiceCol * anchoCelda;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), pincelRejilla);
    }
    for (int indiceFila = 1; indiceFila < filas; indiceFila++) {
      final y = indiceFila * altoCelda;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), pincelRejilla);
    }

    // Celdas fijas (formularios apilados).
    for (int fila = 0; fila < filas; fila++) {
      for (int columna = 0; columna < cols; columna++) {
        final tipo = celdasFijas[fila][columna];
        if (tipo == null) continue;
        final rectCelda = Rect.fromLTWH(
          columna * anchoCelda,
          fila * altoCelda,
          anchoCelda,
          altoCelda,
        );
        final estaBorrandose = filasParaBorrar.contains(fila);
        _pintarFormulario(canvas, rectCelda, tipo, estaBorrandose);
      }
    }

    // Pieza activa con ghost.
    if (piezaActual != null) {
      _pintarPiezaConGhost(canvas, anchoCelda, altoCelda);
    }

    // Flash de filas que se estan eliminando: barra blanca pulsante
    // que recorre las filas para hacer el clear muy notable.
    if (filasParaBorrar.isNotEmpty) {
      final double progreso = fragmentoAnimacionBorrado.clamp(0.0, 1.0);
      // Onda que viene de los lados al centro.
      final double anchoOnda = anchoCelda * cols * progreso * 0.6;
      for (final fila in filasParaBorrar) {
        final Rect rectFila = Rect.fromLTWH(
          (size.width - anchoOnda) / 2,
          fila * altoCelda,
          anchoOnda,
          altoCelda,
        );
        canvas.drawRect(
          rectFila,
          Paint()
            ..color = PaletaCosmoSovietica.papelViejo
                .withValues(alpha: (1.0 - progreso) * 0.95),
        );
        // Estela roja sobre la onda.
        canvas.drawRect(
          Rect.fromLTWH(
              rectFila.left,
              rectFila.top + altoCelda * 0.35,
              rectFila.width,
              altoCelda * 0.30),
          Paint()
            ..color = PaletaCosmoSovietica.rojoOficial
                .withValues(alpha: (1.0 - progreso) * 0.85),
        );
        // Texto APROBADO emergente.
        if (progreso > 0.25 && progreso < 0.85) {
          final double alphaTexto =
              math.sin((progreso - 0.25) / 0.60 * math.pi);
          final pintor = TextPainter(
            text: TextSpan(
              text: 'APROBADO',
              style: TextStyle(
                color: PaletaCosmoSovietica.rojoOficial
                    .withValues(alpha: alphaTexto),
                fontFamily: 'CosmoMono',
                fontSize: altoCelda * 0.65,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          pintor.paint(
            canvas,
            Offset(size.width / 2 - pintor.width / 2,
                fila * altoCelda + altoCelda / 2 - pintor.height / 2),
          );
        }
      }
    }
  }

  void _pintarPiezaConGhost(
      Canvas canvas, double anchoCelda, double altoCelda) {
    final pieza = piezaActual!;
    // Calculamos la pieza fantasma proyectada hasta el fondo.
    var piezaFantasma = pieza;
    while (true) {
      final siguiente = piezaFantasma.copiarConDesplazamiento(0, 1);
      if (!_esPosicionValidaGhost(siguiente)) break;
      piezaFantasma = siguiente;
    }
    final celdasFantasma = piezaFantasma.celdasOcupadasGlobales();
    for (final celda in celdasFantasma) {
      if (celda.dy < 0) continue;
      final rectCelda = Rect.fromLTWH(
        celda.dx * anchoCelda,
        celda.dy * altoCelda,
        anchoCelda,
        altoCelda,
      );
      canvas.drawRect(
        rectCelda.deflate(anchoCelda * 0.12),
        Paint()
          ..color = _PantallaDokumentrisState.coloresPorTipo[pieza.tipo]
              .withValues(alpha: 0.18)
          ..style = PaintingStyle.fill,
      );
      canvas.drawRect(
        rectCelda.deflate(anchoCelda * 0.12),
        Paint()
          ..color = _PantallaDokumentrisState.coloresPorTipo[pieza.tipo]
              .withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }

    // Pieza real encima.
    for (final celda in pieza.celdasOcupadasGlobales()) {
      if (celda.dy < 0) continue;
      final rectCelda = Rect.fromLTWH(
        celda.dx * anchoCelda,
        celda.dy * altoCelda,
        anchoCelda,
        altoCelda,
      );
      _pintarFormulario(canvas, rectCelda, pieza.tipo, false);
    }
  }

  bool _esPosicionValidaGhost(_PiezaTetromino pieza) {
    final celdas = pieza.celdasOcupadasGlobales();
    for (final celda in celdas) {
      final fila = celda.dy.toInt();
      final col = celda.dx.toInt();
      if (col < 0 || col >= _PantallaDokumentrisState.columnasTablero) {
        return false;
      }
      if (fila >= _PantallaDokumentrisState.filasTablero) return false;
      if (fila < 0) continue;
      if (celdasFijas[fila][col] != null) return false;
    }
    return true;
  }

  void _pintarFormulario(
      Canvas canvas, Rect rect, int tipo, bool estaBorrandose) {
    // Semilla estable por celda para que el jitter sea consistente.
    final double semillaCelda =
        rect.left * 0.073 + rect.top * 0.131;
    if (estaBorrandose) {
      // Formulario aprobado: estampilla roja gigante que se desvanece.
      final double alphaBorrado =
          (1.0 - fragmentoAnimacionBorrado).clamp(0.0, 1.0);
      canvas.drawRect(
        rect.deflate(2),
        Paint()..color = PaletaRotulador.papel.withValues(alpha: alphaBorrado),
      );
      estampillaRoja(
        canvas,
        posicion: rect.center,
        texto: 'APROB.',
        anchoEstampilla: rect.width * 0.82,
        altoEstampilla: rect.height * 0.55,
        opacidad: alphaBorrado,
      );
      return;
    }

    // Fondo papel del formulario.
    canvas.drawRect(
      rect.deflate(2),
      Paint()..color = PaletaRotulador.papel,
    );

    // Borde rotulador tembloroso.
    final Paint pincelBorde = Paint()
      ..color = PaletaRotulador.tinta
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    rectanguloRotulador(canvas, rect.deflate(2.5),
        pincel: pincelBorde,
        intensidadJitter: 0.6,
        semilla: semillaCelda);

    // Banda superior con rayado cruzado para parecer cabecera tachada.
    final Rect rectCabecera = Rect.fromLTWH(
      rect.left + 3,
      rect.top + 3,
      rect.width - 6,
      rect.height * 0.18,
    );
    rayadoCruzado(
      canvas,
      rectCabecera,
      pincel: Paint()
        ..color = PaletaRotulador.tintaDiluida(0.65)
        ..strokeWidth = 0.7,
      espaciado: math.max(2.0, rect.height * 0.08),
      intensidadJitter: 0.3,
    );

    // Dos líneas tembloras imitando texto manuscrito.
    final Paint pincelLineaTexto = Paint()
      ..color = PaletaRotulador.tintaDiluida(0.55)
      ..strokeWidth = 0.8;
    trazoTembloroso(
      canvas,
      Offset(rect.left + 4, rect.center.dy + 1),
      Offset(rect.right - 4, rect.center.dy + 1),
      pincel: pincelLineaTexto,
      intensidadJitter: 0.5,
      segmentos: 4,
      semilla: semillaCelda + 5,
    );
    trazoTembloroso(
      canvas,
      Offset(rect.left + 4, rect.center.dy + 4),
      Offset(rect.right - 8, rect.center.dy + 4),
      pincel: pincelLineaTexto,
      intensidadJitter: 0.5,
      segmentos: 4,
      semilla: semillaCelda + 9,
    );

    // Para piezas con identidad fuerte (Z, S, O, T), añadir un patrón
    // sutil que las haga distinguibles sin colores.
    if (rect.width > 18) {
      switch (tipo) {
        case 5: // S
        case 6: // Z
          // Sombra ligera: rayado diagonal tenue.
          rayadoParalelo(
            canvas,
            rect.deflate(4),
            pincel: Paint()
              ..color = PaletaRotulador.tintaDiluida(0.12)
              ..strokeWidth = 0.5,
            espaciado: math.max(3.0, rect.height * 0.12),
            intensidadJitter: 0.2,
          );
          break;
      }
    }

    // Letra del tipo en esquina inferior derecha.
    if (rect.width > 16) {
      final pintorLetra = TextPainter(
        text: TextSpan(
          text: _PantallaDokumentrisState.etiquetasPorTipo[tipo],
          style: TextStyle(
            color: PaletaRotulador.tinta,
            fontFamily: 'CosmoMono',
            fontSize: rect.height * 0.28,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      pintorLetra.paint(
        canvas,
        Offset(
          rect.right - pintorLetra.width - 3,
          rect.bottom - pintorLetra.height - 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PintorTableroDokumentris viejo) {
    return true;
  }
}

class _PintorPiezaPreview extends CustomPainter {
  final _PiezaTetromino pieza;
  _PintorPiezaPreview({required this.pieza});

  @override
  void paint(Canvas canvas, Size size) {
    final celda = math.min(size.width, size.height) / 4;
    final offsetX = (size.width - celda * 4) / 2;
    final offsetY = (size.height - celda * 4) / 2;
    for (int fila = 0; fila < 4; fila++) {
      for (int columna = 0; columna < 4; columna++) {
        if (pieza.matriz[fila][columna] != 1) continue;
        final rect = Rect.fromLTWH(
          offsetX + columna * celda,
          offsetY + fila * celda,
          celda,
          celda,
        );
        canvas.drawRect(
          rect.deflate(2),
          Paint()
            ..color =
                _PantallaDokumentrisState.coloresPorTipo[pieza.tipo],
        );
        canvas.drawRect(
          rect.deflate(2),
          Paint()
            ..color = PaletaCosmoSovietica.tintaNegra
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PintorPiezaPreview viejo) =>
      viejo.pieza != pieza;
}

const String _flagHighscoreDokumentris = 'dokumentris_highscore_';

int _leerHighscoreActual(EstadoJuego estado) {
  for (final flag in estado.flagsActivos) {
    if (flag.startsWith(_flagHighscoreDokumentris)) {
      return int.tryParse(flag.substring(_flagHighscoreDokumentris.length)) ??
          0;
    }
  }
  return 0;
}

void _guardarHighscore(EstadoJuego estado, int puntuacion) {
  estado.flagsActivos.removeWhere(
    (flag) => flag.startsWith(_flagHighscoreDokumentris),
  );
  estado.activarFlag('$_flagHighscoreDokumentris$puntuacion');
}

/// Pilita de expedientes F-447 junto al avatar del cadete: tres
/// rectángulos negros apilados con una franja roja arriba (sello).
class _PintorPilaExpedientes extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint pincelTinta = Paint()..color = PaletaRotulador.tinta;
    final Paint pincelRojo = Paint()
      ..color = PaletaRotulador.rojoEstampilla;
    for (int i = 0; i < 3; i++) {
      final double dy = size.height - 4 - i * 5;
      canvas.drawRect(
        Rect.fromLTWH(0, dy, size.width, 4),
        pincelTinta,
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.6, size.height - 18, 6, 4),
      pincelRojo,
    );
  }

  @override
  bool shouldRepaint(covariant _PintorPilaExpedientes viejo) => false;
}
