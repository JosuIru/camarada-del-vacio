import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../datos/sellos_f447.dart';
import '../models/game_state.dart';
import '../widgets/propaganda_button.dart';
import 'pintor_rotulador.dart';
import 'sprite_cadete.dart';
import 'utilidades_carga_sprites.dart';
import 'widget_pausa.dart';

/// Clave de inventario donde se acumula la racha de derrotas seguidas
/// del cadete en Pixel Perdido. Se incrementa con cada derrota y se
/// resetea al ganar. Cuando alcanza 7 otorga el Sello del Mártir.
const String _kClaveDerrotasSeguidasPixel = 'pixel_perdido_derrotas_seguidas';

/// Umbral de racha de derrotas para que el Comité otorgue el sello
/// satírico del Mártir Burocrático.
const int _kRachaParaSelloMartir = 7;

/// COSMONAUTA DEL PÍXEL PERDIDO.
///
/// Mini-platformer en estilo 8-bit. El cadete se transforma en un
/// sprite pixelado y debe recorrer un mundo cuadriculado lleno de
/// estrellas rojas (kopeks intergalácticos), evitando manchas de
/// tinta (charcos negros) y saltando sobre bloques. Llegar a la
/// bandera roja al final = victoria. Tres caídas = derrota.
class PantallaPixelPerdido extends StatefulWidget {
  final EstadoJuego estado;

  const PantallaPixelPerdido({super.key, required this.estado});

  @override
  State<PantallaPixelPerdido> createState() => _PantallaPixelPerdidoState();
}

class _PantallaPixelPerdidoState extends State<PantallaPixelPerdido>
    with SingleTickerProviderStateMixin {
  static const int columnasMapa = 36;
  static const int filasMapa = 14;
  // # bloque solido, . aire, * kopek rojo, X mancha tinta, F bandera fin,
  // P punto inicial.

  /// Tres niveles de dificultad creciente. Cada cadena debe medir
  /// exactamente [columnasMapa] caracteres y la lista [filasMapa].
  /// Cada nivel debe incluir UN 'P' (spawn) y UN 'F' (meta).
  ///
  /// Π-I (introducción): plataformas amplias, una sola altura, tres
  /// charcos en la fila 11 pero todos saltables.
  /// Π-II (intermedio): subidas en zigzag, más charcos por fila, gaps
  /// que requieren saltos consecutivos.
  /// Π-III (avanzado): plataformas pequeñas con kopeks aislados,
  /// charcos casi cada 3 columnas, requiere coordinar caída + salto.
  static const List<List<String>> nivelesPixelPerdido = <List<String>>[
    // ─────────── NIVEL 1 ── Π-I · Reseña de Adaptación ───────────
    <String>[
      '....................................',
      '....................................',
      '..........*..............*..........',
      '.........###............###.........',
      '....................................',
      '..*.........*..........*.........*..',
      '..##........##.........##.......##..',
      '....................................',
      '............*.........*.............',
      '...####....####......####....####...',
      '..P..........................F......',
      '##########X##########X##########X###',
      '####################################',
      '####################################',
    ],
    // ──────── NIVEL 2 ── Π-II · Tránsito Reglamentario ────────
    <String>[
      '....................................',
      '....................................',
      '......*.................*...........',
      '.....###...............###..........',
      '....................................',
      '.............*.................*....',
      '............####...............####.',
      '....................................',
      '...*.................*..............',
      '...####.............####............',
      '..P............................F....',
      '#####X#####X#####X#####X######X#####',
      '####################################',
      '####################################',
    ],
    // ──────── NIVEL 3 ── Π-III · Auditoría de Píxel ────────
    <String>[
      '....................................',
      '....*........*...........*..........',
      '...###......###.........###.........',
      '....................................',
      '..*..............*.......*..........',
      '.###............###......###........',
      '..............*.....................',
      '..*.........####....................',
      '.###...........................####.',
      '.................*..................',
      '..P............................F....',
      '###X###X##X##X###X####X###X###X###X#',
      '####################################',
      '####################################',
    ],
  ];

  late Ticker tickerJuego;
  Duration? marcaTemporalAnterior;
  final FocusNode nodoFoco = FocusNode(debugLabel: 'pixel_perdido');

  late List<List<String>> mapaCargado;
  int kopeksRecogidos = 0;
  int kopeksTotales = 0;
  /// Índice del nivel actual dentro de [nivelesPixelPerdido].
  int nivelActual = 0;
  /// Suma acumulada de kopeks recogidos a lo largo de TODOS los niveles
  /// completados en la sesión actual. Se compara contra la suma de
  /// kopeksTotales por nivel para decidir el Sello del Recolector.
  int kopeksAcumuladosSesion = 0;
  /// Suma acumulada de kopeksTotales esperados (todos los niveles).
  int kopeksTotalesSesion = 0;
  /// True si el cadete ha completado los niveles sin perder ni una vida
  /// en toda la sesión. Pre-requisito para el Sello del Topógrafo.
  bool sesionSinMorir = true;
  /// Sellos F-447 que el cadete obtiene en esta sesión concreta del
  /// minijuego. Se rellena al finalizar la partida (victoria o derrota
  /// definitiva) y se muestra en el panel de resultados.
  final List<SelloF447> sellosObtenidosEnEstaPartida = <SelloF447>[];
  int vidas = 3;
  bool partidaTerminada = false;
  bool partidaPausada = false;
  bool partidaGanada = false;

  // Posicion en celdas (continuas).
  double posicionX = 1.0;
  double posicionY = 1.0;
  double velocidadX = 0;
  double velocidadY = 0;
  /// Punto en el que respawna tras perder vida.
  double respawnX = 2.5;
  double respawnY = 9.5;
  bool moviendoIzquierda = false;
  bool moviendoDerecha = false;
  bool enSuelo = false;
  int direccionMira = 1;
  // Camara: cuanto del mapa se ve a la derecha.
  double scrollCamara = 0;

  // Sprites pixel-art de §17 — cableado anticipado.
  ui.Image? imagenCadetePixel; // §17.1
  ui.Image? imagenKopek; // §17.2
  ui.Image? imagenCharcoTinta; // §17.3
  ui.Image? imagenBloqueTile; // §17.4
  ui.Image? imagenBanderaMeta; // §17.5

  @override
  void initState() {
    super.initState();
    _cargarMapa();
    tickerJuego = createTicker(_alTick)..start();
    _cargarSprites();
  }

  Future<void> _cargarSprites() async {
    final resultados = await cargarLoteOpcional(<String>[
      'assets/svg/pixel_cadete_idle.png',
      'assets/svg/pixel_kopek.png',
      'assets/svg/pixel_charco_tinta.png',
      'assets/svg/pixel_bloque_tile.png',
      'assets/svg/pixel_bandera_meta.png',
    ]);
    if (!mounted) return;
    setState(() {
      imagenCadetePixel = resultados[0];
      imagenKopek = resultados[1];
      imagenCharcoTinta = resultados[2];
      imagenBloqueTile = resultados[3];
      imagenBanderaMeta = resultados[4];
    });
  }

  @override
  void dispose() {
    tickerJuego.dispose();
    nodoFoco.dispose();
    super.dispose();
  }

  /// Carga el nivel [nivelActual] en `mapaCargado`. Si [reiniciarSesion]
  /// es true (modo "empezar de cero" tras derrota o pulsar reintentar),
  /// resetea acumulados, vidas y vuelve al nivel 0. Si es false, mantiene
  /// los acumulados (modo "avancé de nivel tras ganar el anterior").
  void _cargarMapa({bool reiniciarSesion = true}) {
    if (reiniciarSesion) {
      nivelActual = 0;
      kopeksAcumuladosSesion = 0;
      kopeksTotalesSesion = 0;
      sesionSinMorir = true;
      vidas = 3;
    } else {
      // Avance entre niveles: acumular lo que se llevaba del nivel
      // anterior antes de reescribir el mapa.
      kopeksAcumuladosSesion += kopeksRecogidos;
    }
    final List<String> trazado = nivelesPixelPerdido[nivelActual];
    mapaCargado = List<List<String>>.generate(
      filasMapa,
      (fila) => List<String>.generate(
        columnasMapa,
        (columna) => trazado[fila][columna],
      ),
    );
    kopeksRecogidos = 0;
    kopeksTotales = 0;
    for (int fila = 0; fila < filasMapa; fila++) {
      for (int columna = 0; columna < columnasMapa; columna++) {
        if (mapaCargado[fila][columna] == '*') kopeksTotales++;
        if (mapaCargado[fila][columna] == 'P') {
          posicionX = columna + 0.5;
          posicionY = fila + 0.5;
          respawnX = posicionX;
          respawnY = posicionY;
          mapaCargado[fila][columna] = '.';
        }
      }
    }
    kopeksTotalesSesion += kopeksTotales;
    partidaTerminada = false;
    partidaGanada = false;
    velocidadX = 0;
    velocidadY = 0;
  }

  void _alTick(Duration tiempoAcumulado) {
    final marcaAnterior = marcaTemporalAnterior;
    marcaTemporalAnterior = tiempoAcumulado;
    if (marcaAnterior == null) return;
    final double dt =
        (tiempoAcumulado - marcaAnterior).inMicroseconds / 1e6;
    if (dt <= 0) return;
    if (partidaPausada) return;
    if (partidaTerminada) {
      setState(() {});
      return;
    }
    // Subdividir dt en sub-pasos para evitar tunneling cuando el
    // cadete cae rápido o el frame tarda mucho (cada paso máx 0.020s
    // ≈ 50 fps efectivos para la integración física).
    const double dtMax = 0.020;
    final int subPasos = math.max(1, (dt / dtMax).ceil());
    final double dtSub = dt / subPasos;
    for (int i = 0; i < subPasos; i++) {
      _actualizarFisica(dtSub);
    }
    _actualizarCamara();
    setState(() {});
  }

  bool _esSolido(int columna, int fila) {
    if (fila < 0 || fila >= filasMapa) return true;
    if (columna < 0 || columna >= columnasMapa) return true;
    return mapaCargado[fila][columna] == '#';
  }

  bool _esLetal(int columna, int fila) {
    if (fila < 0 || fila >= filasMapa) return false;
    if (columna < 0 || columna >= columnasMapa) return false;
    return mapaCargado[fila][columna] == 'X';
  }

  void _actualizarFisica(double dt) {
    const double velCaminar = 6.5;
    const double gravedad = 22.0;

    velocidadX = 0;
    if (moviendoIzquierda && !moviendoDerecha) {
      velocidadX = -velCaminar;
      direccionMira = -1;
    } else if (moviendoDerecha && !moviendoIzquierda) {
      velocidadX = velCaminar;
      direccionMira = 1;
    }
    velocidadY += gravedad * dt;
    if (velocidadY > 16) velocidadY = 16;

    // Mover X y resolver colisiones.
    double nuevoX = posicionX + velocidadX * dt;
    final int filaActual = posicionY.floor();
    if (velocidadX > 0) {
      final int colDerecha = (nuevoX + 0.4).floor();
      if (_esSolido(colDerecha, filaActual)) {
        nuevoX = colDerecha - 0.4;
      }
    } else if (velocidadX < 0) {
      final int colIzquierda = (nuevoX - 0.4).floor();
      if (_esSolido(colIzquierda, filaActual)) {
        nuevoX = colIzquierda + 1.4;
      }
    }
    posicionX = nuevoX.clamp(0.4, columnasMapa - 0.4);

    // Mover Y y resolver colisiones.
    double nuevoY = posicionY + velocidadY * dt;
    final int colActual = posicionX.floor();
    enSuelo = false;
    if (velocidadY > 0) {
      final int filaAbajo = (nuevoY + 0.4).floor();
      if (_esSolido(colActual, filaAbajo)) {
        nuevoY = filaAbajo - 0.4;
        velocidadY = 0;
        enSuelo = true;
      }
    } else if (velocidadY < 0) {
      final int filaArriba = (nuevoY - 0.4).floor();
      if (_esSolido(colActual, filaArriba)) {
        nuevoY = filaArriba + 1.4;
        velocidadY = 0;
      }
    }
    posicionY = nuevoY;

    // Caer fuera del mapa.
    if (posicionY > filasMapa) {
      _perderVida();
    }

    // Recogida de kopeks / bandera por proximidad al hitbox COMPLETO
    // del cadete (su sprite visual mide ~1.2 celdas, no sólo la celda
    // central). Barremos las 9 celdas vecinas y aceptamos contacto si
    // la distancia al centro de la celda es < 0.7 celdas.
    final int filaJugador = posicionY.floor();
    final int colJugador = posicionX.floor();
    for (int deltaFila = -1; deltaFila <= 1; deltaFila++) {
      for (int deltaCol = -1; deltaCol <= 1; deltaCol++) {
        final int filaRevisada = filaJugador + deltaFila;
        final int colRevisada = colJugador + deltaCol;
        if (filaRevisada < 0 || filaRevisada >= filasMapa) continue;
        if (colRevisada < 0 || colRevisada >= columnasMapa) continue;
        final String contenido = mapaCargado[filaRevisada][colRevisada];
        if (contenido != '*' && contenido != 'F') continue;
        final double diferenciaX = posicionX - (colRevisada + 0.5);
        final double diferenciaY = posicionY - (filaRevisada + 0.5);
        final double distanciaCuadrada =
            diferenciaX * diferenciaX + diferenciaY * diferenciaY;
        if (distanciaCuadrada > 0.7 * 0.7) continue;
        if (contenido == '*') {
          mapaCargado[filaRevisada][colRevisada] = '.';
          kopeksRecogidos++;
        } else if (contenido == 'F') {
          // Bandera: si quedan niveles, avanzar; si era el último,
          // terminar la sesión victoriosa y otorgar sellos.
          if (nivelActual < nivelesPixelPerdido.length - 1) {
            nivelActual++;
            _cargarMapa(reiniciarSesion: false);
          } else {
            partidaTerminada = true;
            partidaGanada = true;
            _guardarHighscore();
          }
        }
      }
    }
    // Tinta letal: chequear pies y celda actual.
    final int filaPies = (posicionY + 0.35).floor();
    final int colPies = posicionX.round();
    if (_esLetal(colPies, filaPies)) {
      _perderVida();
    }
  }

  void _actualizarCamara() {
    const int columnasVisibles = 16;
    final double objetivo = posicionX - columnasVisibles / 2;
    scrollCamara = objetivo
        .clamp(0.0, (columnasMapa - columnasVisibles).toDouble());
  }

  void _perderVida() {
    vidas -= 1;
    sesionSinMorir = false;
    if (vidas <= 0) {
      partidaTerminada = true;
      partidaGanada = false;
      _guardarHighscore();
      return;
    }
    // Volver al punto 'P' marcado en el mapa (siempre sobre suelo firme).
    posicionX = respawnX;
    posicionY = respawnY;
    velocidadX = 0;
    velocidadY = 0;
  }

  void _guardarHighscore() {
    final int previo = _leerHighscorePixel(widget.estado);
    if (kopeksRecogidos > previo) {
      _guardarHighscorePixel(widget.estado, kopeksRecogidos);
    }
    _otorgarSellosPorResultado();
  }

  /// Otorga los sellos F-447 del catálogo según el resultado de la
  /// partida actual. Es idempotente: si el sello ya estaba activo, no
  /// duplica el objeto otorgado ni vuelve a aparecer en la lista de
  /// nuevos sellos (esa lista solo recoge sellos REALMENTE nuevos).
  void _otorgarSellosPorResultado() {
    final estado = widget.estado;
    sellosObtenidosEnEstaPartida.clear();

    if (partidaGanada) {
      _intentarOtorgarSello(estado, 'sello_pixel_reformado');
      // Recolector: requiere TODOS los kopeks de los 3 niveles. Sumamos
      // los del último nivel (aún no acumulado) a los previos.
      final int kopeksTotalSesion =
          kopeksAcumuladosSesion + kopeksRecogidos;
      if (kopeksTotalesSesion > 0 &&
          kopeksTotalSesion >= kopeksTotalesSesion) {
        _intentarOtorgarSello(estado, 'sello_recolector_total');
      }
      // Topógrafo: completar los 3 niveles sin morir.
      if (sesionSinMorir) {
        _intentarOtorgarSello(estado, 'sello_topografo_universal');
      }
      // Ganar reinicia la racha de derrotas.
      estado.inventario.remove(_kClaveDerrotasSeguidasPixel);
    } else {
      // Derrota: incrementar contador. Al llegar al umbral, sello
      // satírico del Mártir Burocrático. La racha NO se resetea al
      // recibir el sello; un usuario puede seguir cayendo y el sello
      // sigue otorgado (idempotente).
      final int derrotasPrevias =
          estado.inventario[_kClaveDerrotasSeguidasPixel] ?? 0;
      final int nuevasDerrotas = derrotasPrevias + 1;
      estado.inventario[_kClaveDerrotasSeguidasPixel] = nuevasDerrotas;
      if (nuevasDerrotas >= _kRachaParaSelloMartir) {
        _intentarOtorgarSello(estado, 'sello_martir_burocratico');
      }
    }
  }

  /// Activa el flag del sello [idSello] y, si el sello tiene objeto
  /// asociado, lo añade al inventario. Si el sello ya estaba activo
  /// no hace nada (no duplica objetos). Si lo otorga por primera vez,
  /// lo añade a `sellosObtenidosEnEstaPartida` para mostrarlo en UI.
  void _intentarOtorgarSello(EstadoJuego estado, String idSello) {
    if (estado.tieneFlag(idSello)) return;
    final sello = selloPorId(idSello);
    if (sello == null) return;
    estado.activarFlag(idSello);
    if (sello.idObjetoOtorgado != null) {
      estado.anadirObjeto(sello.idObjetoOtorgado!);
    }
    sellosObtenidosEnEstaPartida.add(sello);
  }

  KeyEventResult _alEventoTeclado(FocusNode nodo, KeyEvent evento) {
    final bool esPulsacion =
        evento is KeyDownEvent || evento is KeyRepeatEvent;
    final bool esLevantamiento = evento is KeyUpEvent;
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

    if (partidaTerminada && esPulsacion) {
      if (tecla == LogicalKeyboardKey.enter ||
          tecla == LogicalKeyboardKey.space ||
          tecla == LogicalKeyboardKey.numpadEnter) {
        setState(_cargarMapa);
        return KeyEventResult.handled;
      }
    }

    if (tecla == LogicalKeyboardKey.keyA ||
        tecla == LogicalKeyboardKey.arrowLeft) {
      moviendoIzquierda = esPulsacion;
      if (esLevantamiento) moviendoIzquierda = false;
      return KeyEventResult.handled;
    }
    if (tecla == LogicalKeyboardKey.keyD ||
        tecla == LogicalKeyboardKey.arrowRight) {
      moviendoDerecha = esPulsacion;
      if (esLevantamiento) moviendoDerecha = false;
      return KeyEventResult.handled;
    }
    if ((tecla == LogicalKeyboardKey.keyW ||
            tecla == LogicalKeyboardKey.arrowUp ||
            tecla == LogicalKeyboardKey.space) &&
        evento is KeyDownEvent) {
      // Salto: -13.5 alcanza ≈ 4.1 unidades, suficiente para subir
      // entre cualquier par de plataformas adyacentes (separadas 2-3
      // filas en el trazado del mapa) con margen.
      if (enSuelo) velocidadY = -13.5;
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
    final int mejor = _leerHighscorePixel(widget.estado);
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
            semilla: 23,
            child: Stack(
              children: [
                SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _construirCabecera(mejor),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _construirMundo()),
                          const SizedBox(width: 16),
                          SizedBox(width: 220, child: _construirPanelLateral()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
                ),
                OverlayPausaMinijuego(visible: partidaPausada),
                if (partidaTerminada) _construirOverlayResultados(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirCabecera(int mejor) {
    final String etiquetaNivel = 'Π-${_romanos(nivelActual + 1)}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'COSMONAUTA · PÍXEL PERDIDO · $etiquetaNivel',
          style: const TextStyle(
            fontFamily: 'CosmoMono',
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: PaletaRotulador.papel,
            letterSpacing: 3,
          ),
        ),
        Row(
          children: [
            _chip('NIVEL',
                '${nivelActual + 1} / ${nivelesPixelPerdido.length}'),
            const SizedBox(width: 6),
            _chip('VIDAS', '$vidas'),
            const SizedBox(width: 6),
            _chip('KOPEKS', '$kopeksRecogidos / $kopeksTotales',
                acentuado: true),
            const SizedBox(width: 6),
            _chip('RÉCORD', '$mejor'),
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

  /// Conversión simple a numeración romana (1..3) usada para etiquetar
  /// los niveles del minijuego como Π-I / Π-II / Π-III.
  String _romanos(int numero) {
    switch (numero) {
      case 1:
        return 'I';
      case 2:
        return 'II';
      case 3:
        return 'III';
      default:
        return numero.toString();
    }
  }

  Widget _chip(String etiqueta, String valor, {bool acentuado = false}) {
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

  Widget _construirMundo() {
    const int columnasVisibles = 16;
    return AspectRatio(
      aspectRatio: columnasVisibles / filasMapa,
      child: MarcoRotulador(
        color: PaletaRotulador.tinta,
        grosor: 3.6,
        intensidadJitter: 1.5,
        margenInterior: 2.0,
        child: Container(
        decoration: const BoxDecoration(
          color: PaletaRotulador.papel,
        ),
        child: CustomPaint(
          painter: _PintorPixelPerdido(
            mapa: mapaCargado,
            posicionX: posicionX,
            posicionY: posicionY,
            scrollCamara: scrollCamara,
            columnasVisibles: columnasVisibles,
            direccionMira: direccionMira,
            partidaTerminada: partidaTerminada,
            partidaGanada: partidaGanada,
            imagenCadetePixel: imagenCadetePixel,
            imagenKopek: imagenKopek,
            imagenCharcoTinta: imagenCharcoTinta,
            imagenBloqueTile: imagenBloqueTile,
            imagenBanderaMeta: imagenBanderaMeta,
          ),
          child: Container(),
        ),
        ),
      ),
    );
  }

  Widget _construirPanelLateral() {
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
            'INSTRUCTIVO',
            style: TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: PaletaRotulador.rojoEstampilla,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Salta los charcos de tinta. Recoge kopeks (★). Llega a la bandera roja sin perder las tres vidas.',
            style: TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 11,
              color: PaletaRotulador.tinta,
              height: 1.5,
            ),
          ),
          const Divider(color: PaletaRotulador.tinta, height: 22),
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
          const SizedBox(height: 4),
          Text(
            'A / ◀  : izquierda\n'
            'D / ▶  : derecha\n'
            'W / ↑  : saltar\n'
            'ESC    : salir',
            style: TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 11,
              color: PaletaRotulador.tintaDiluida(0.75),
              height: 1.5,
            ),
          ),
          const Spacer(),
          const Text(
            '«Un cosmonauta perdido es un cosmonauta libre, hasta que vuelve.»',
            style: TextStyle(
              fontFamily: 'CosmoSerif',
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: PaletaRotulador.tinta,
            ),
          ),
        ],
      ),
    );
  }

  /// Overlay modal que aparece al terminar la partida. Muestra:
  /// - veredicto del Comité (victoria / derrota),
  /// - kopeks recogidos y récord,
  /// - sellos F-447 obtenidos por primera vez (con su decreto),
  /// - acceso a reiniciar o salir.
  Widget _construirOverlayResultados() {
    final bool gano = partidaGanada;
    final int derrotasAcumuladas =
        widget.estado.inventario[_kClaveDerrotasSeguidasPixel] ?? 0;
    return Positioned.fill(
      child: ColoredBox(
        color: PaletaRotulador.tinta.withValues(alpha: 0.55),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: PaletaRotulador.papel,
                border: Border.all(
                  color: gano
                      ? PaletaRotulador.rojoEstampilla
                      : PaletaRotulador.tinta,
                  width: 2.2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gano
                        ? 'EXPEDIENTE Π · ARCHIVADO'
                        : 'EXPEDIENTE Π · INCOMPLETO',
                    style: TextStyle(
                      fontFamily: 'CosmoMono',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: gano
                          ? PaletaRotulador.rojoEstampilla
                          : PaletaRotulador.tinta,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    gano
                        ? 'El Camarada Cadete completa los ${nivelesPixelPerdido.length} '
                            'recorridos del Píxel.\n'
                            'Kopeks totales: ${kopeksAcumuladosSesion + kopeksRecogidos} / '
                            '$kopeksTotalesSesion.'
                        : 'Tres caídas en el nivel Π-${_romanos(nivelActual + 1)}. '
                            'El Comité registra la incidencia (racha: '
                            '$derrotasAcumuladas / $_kRachaParaSelloMartir).',
                    style: const TextStyle(
                      fontFamily: 'CosmoSerif',
                      fontSize: 13,
                      color: PaletaRotulador.tinta,
                      height: 1.4,
                    ),
                  ),
                  if (sellosObtenidosEnEstaPartida.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'SELLOS F-447 ARCHIVADOS',
                      style: TextStyle(
                        fontFamily: 'CosmoMono',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.6,
                        color: PaletaRotulador.rojoEstampilla,
                      ),
                    ),
                    const SizedBox(height: 6),
                    for (final sello in sellosObtenidosEnEstaPartida)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: _tarjetaSelloObtenido(sello),
                      ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      BotonPropaganda(
                        texto: gano ? 'Volver a la cápsula' : 'Reintentar',
                        compacto: true,
                        onPressed: () {
                          if (gano) {
                            Navigator.of(context).pop();
                          } else {
                            setState(_cargarMapa);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      BotonPropaganda(
                        texto: 'Salir',
                        compacto: true,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tarjetaSelloObtenido(SelloF447 sello) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: PaletaRotulador.papelSucio,
        border: Border.all(
          color: sello.categoria.colorTinta,
          width: 1.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sello.tituloLargo.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'CosmoMono',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                  color: sello.categoria.colorTinta,
                ),
              ),
              Text(
                sello.categoria.etiqueta,
                style: TextStyle(
                  fontFamily: 'CosmoMono',
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: sello.categoria.colorTinta,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            sello.decretoComite,
            style: const TextStyle(
              fontFamily: 'CosmoSerif',
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: PaletaRotulador.tinta,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PintorPixelPerdido extends CustomPainter {
  final List<List<String>> mapa;
  final double posicionX;
  final double posicionY;
  final double scrollCamara;
  final int columnasVisibles;
  final int direccionMira;
  final bool partidaTerminada;
  final bool partidaGanada;
  /// Sprites §17 — null si asset no generado / no cargado.
  final ui.Image? imagenCadetePixel;
  final ui.Image? imagenKopek;
  final ui.Image? imagenCharcoTinta;
  final ui.Image? imagenBloqueTile;
  final ui.Image? imagenBanderaMeta;

  _PintorPixelPerdido({
    required this.mapa,
    required this.posicionX,
    required this.posicionY,
    required this.scrollCamara,
    required this.columnasVisibles,
    required this.direccionMira,
    required this.partidaTerminada,
    required this.partidaGanada,
    this.imagenCadetePixel,
    this.imagenKopek,
    this.imagenCharcoTinta,
    this.imagenBloqueTile,
    this.imagenBanderaMeta,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double anchoCelda = size.width / columnasVisibles;
    final double altoCelda = size.height / mapa.length;

    // Fondo: papel viejo con estrellas a tinta (dos capas con parallax).
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = PaletaRotulador.papel,
    );
    // Estrellas lejanas (no scroll): puntitos de tinta.
    final math.Random rngEstrellas = math.Random(89);
    for (int indice = 0; indice < 60; indice++) {
      final double xEstrella =
          rngEstrellas.nextDouble() * size.width;
      final double yEstrella =
          rngEstrellas.nextDouble() * size.height * 0.6;
      final double tamano = rngEstrellas.nextBool() ? 2.0 : 1.0;
      canvas.drawRect(
        Rect.fromLTWH(xEstrella, yEstrella, tamano, tamano),
        Paint()
          ..color = PaletaRotulador.tintaDiluida(0.40),
      );
    }
    // Estrellas más cercanas con scroll lento: pequeñas estampillas rojas.
    final math.Random rngEstrellasCerca = math.Random(13);
    for (int indice = 0; indice < 30; indice++) {
      final double xOriginal =
          rngEstrellasCerca.nextDouble() * size.width * 2;
      final double xParallax =
          (xOriginal - scrollCamara * anchoCelda * 0.30) %
              size.width;
      canvas.drawRect(
        Rect.fromLTWH(
            xParallax,
            rngEstrellasCerca.nextDouble() * size.height * 0.55,
            2,
            2),
        Paint()
          ..color = PaletaRotulador.rojoEstampilla
              .withValues(alpha: 0.65),
      );
    }
    // Luna roja (única nota de color) con cráteres a tinta.
    final double xLuna = size.width * 0.75;
    final double yLuna = size.height * 0.18;
    canvas.drawCircle(
      Offset(xLuna, yLuna),
      anchoCelda * 1.2,
      Paint()
        ..color = PaletaRotulador.rojoEstampilla.withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      Offset(xLuna, yLuna),
      anchoCelda * 1.2,
      Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    for (final cratero in <Offset>[
      const Offset(-0.4, 0.2),
      const Offset(0.3, -0.1),
      const Offset(0.1, 0.4),
    ]) {
      canvas.drawCircle(
        Offset(xLuna + cratero.dx * anchoCelda, yLuna + cratero.dy * anchoCelda),
        anchoCelda * 0.15,
        Paint()
          ..color = PaletaRotulador.tinta.withValues(alpha: 0.50),
      );
    }

    for (int fila = 0; fila < mapa.length; fila++) {
      for (int columna = 0; columna < mapa[fila].length; columna++) {
        final double xPx = (columna - scrollCamara) * anchoCelda;
        final double yPx = fila * altoCelda;
        if (xPx + anchoCelda < 0 || xPx > size.width) continue;
        final Rect rectCelda =
            Rect.fromLTWH(xPx, yPx, anchoCelda, altoCelda);
        // §17: si el sprite pixel del tile está cargado, drawImageRect
        // directo y saltar el render procedural. Mantiene fallback.
        final ui.Image? spriteTile = switch (mapa[fila][columna]) {
          '#' => imagenBloqueTile,
          'X' => imagenCharcoTinta,
          '*' => imagenKopek,
          'F' => imagenBanderaMeta,
          _ => null,
        };
        if (spriteTile != null) {
          // La bandera (canónica 64×128) es más alta que la celda;
          // la pintamos sobresaliendo hacia arriba para que el asta se
          // vea entera. Los demás encajan en la celda.
          final Rect rectSprite = mapa[fila][columna] == 'F'
              ? Rect.fromLTWH(
                  rectCelda.left,
                  rectCelda.top - altoCelda,
                  rectCelda.width,
                  altoCelda * 2)
              : rectCelda;
          canvas.drawImageRect(
            spriteTile,
            Rect.fromLTWH(0, 0, spriteTile.width.toDouble(),
                spriteTile.height.toDouble()),
            rectSprite,
            Paint()..filterQuality = FilterQuality.none, // pixel-art crisp
          );
          continue; // siguiente columna
        }
        switch (mapa[fila][columna]) {
          case '#':
            // Bloque tipo ladrillo dibujado a rotulador: papel sucio +
            // rayado paralelo + grietas a tinta.
            canvas.drawRect(
              rectCelda,
              Paint()..color = PaletaRotulador.papelSucio,
            );
            // Rayado paralelo dando volumen (sombra).
            rayadoParalelo(
              canvas,
              rectCelda,
              pincel: Paint()
                ..color = PaletaRotulador.tintaDiluida(0.35)
                ..strokeWidth = 0.7,
              espaciado: math.max(3.0, rectCelda.height * 0.25),
              intensidadJitter: 0.3,
            );
            // Grietas tipo ladrillo a tinta.
            canvas.drawLine(
              Offset(rectCelda.left, rectCelda.center.dy),
              Offset(rectCelda.right, rectCelda.center.dy),
              Paint()
                ..color = PaletaRotulador.tinta
                ..strokeWidth = 1.4,
            );
            canvas.drawLine(
              Offset(rectCelda.left + rectCelda.width * 0.25,
                  rectCelda.top),
              Offset(rectCelda.left + rectCelda.width * 0.25,
                  rectCelda.center.dy),
              Paint()
                ..color = PaletaRotulador.tinta
                ..strokeWidth = 1.4,
            );
            canvas.drawLine(
              Offset(rectCelda.left + rectCelda.width * 0.75,
                  rectCelda.center.dy),
              Offset(rectCelda.left + rectCelda.width * 0.75,
                  rectCelda.bottom),
              Paint()
                ..color = PaletaRotulador.tinta
                ..strokeWidth = 1.4,
            );
            // Borde general a rotulador tembloroso.
            rectanguloRotulador(
              canvas,
              rectCelda,
              pincel: Paint()
                ..color = PaletaRotulador.tinta
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.4,
              intensidadJitter: 0.6,
              semilla: rectCelda.left * 0.13 + rectCelda.top * 0.27,
            );
            break;
          case 'X':
            // Charco de tinta: rectángulo negro con burbujas rojas.
            canvas.drawRect(
              rectCelda,
              Paint()..color = PaletaRotulador.tinta,
            );
            // Burbujas brillantes de tinta.
            for (int gotaIndice = 0;
                gotaIndice < 4;
                gotaIndice++) {
              final double dxGota = anchoCelda *
                  (0.15 + gotaIndice * 0.22);
              final double dyGota = altoCelda *
                  (0.20 + (gotaIndice.isEven ? 0.20 : 0.50));
              canvas.drawCircle(
                Offset(rectCelda.left + dxGota,
                    rectCelda.top + dyGota),
                anchoCelda * 0.08,
                Paint()..color = PaletaRotulador.rojoEstampilla,
              );
              canvas.drawCircle(
                Offset(rectCelda.left + dxGota - 1,
                    rectCelda.top + dyGota - 1),
                anchoCelda * 0.03,
                Paint()
                  ..color = PaletaRotulador.rojoEstampilla
                      .withValues(alpha: 0.85),
              );
            }
            // Pinchos arriba (advertencia visual).
            for (int diente = 0; diente < 4; diente++) {
              final Path triangulo = Path()
                ..moveTo(
                    rectCelda.left + anchoCelda * (0.15 + diente * 0.25),
                    rectCelda.top)
                ..lineTo(
                    rectCelda.left + anchoCelda * (0.25 + diente * 0.25),
                    rectCelda.top + altoCelda * 0.18)
                ..lineTo(
                    rectCelda.left + anchoCelda * (0.35 + diente * 0.25),
                    rectCelda.top)
                ..close();
              canvas.drawPath(triangulo,
                  Paint()..color = PaletaRotulador.rojoEstampilla);
            }
            break;
          case '*':
            // Kopek estrella roja con halo pulsante.
            final double pulso =
                0.65 + 0.35 * math.sin(scrollCamara * 0.5 +
                    fila * 0.7 + columna * 0.3);
            canvas.drawCircle(
              rectCelda.center,
              anchoCelda * 0.38 * pulso,
              Paint()
                ..color = PaletaRotulador.rojoEstampilla
                    .withValues(alpha: 0.25),
            );
            _dibujarEstrellaCinco(
              canvas,
              rectCelda.center,
              anchoCelda * 0.30,
              Paint()..color = PaletaRotulador.rojoEstampilla,
            );
            _dibujarEstrellaCinco(
              canvas,
              rectCelda.center,
              anchoCelda * 0.30,
              Paint()
                ..color = PaletaRotulador.tinta
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.0,
            );
            break;
          case 'F':
            // Bandera roja ondeante: poste + tela animada.
            final double xPoste = rectCelda.left + anchoCelda * 0.20;
            canvas.drawRect(
              Rect.fromLTWH(xPoste, rectCelda.top, 3, altoCelda * 1.0),
              Paint()..color = PaletaRotulador.papel,
            );
            // Pomo del poste arriba.
            canvas.drawCircle(
              Offset(xPoste + 1.5, rectCelda.top + 2),
              4,
              Paint()..color = PaletaRotulador.rojoEstampilla,
            );
            // Tela ondeante (animada con scrollCamara como tiempo
            // aproximado para evitar pasar timestamp adicional).
            final double faseOnda = scrollCamara * 0.3 +
                fila * 0.5;
            final Path tela = Path()
              ..moveTo(xPoste + 3, rectCelda.top + altoCelda * 0.10);
            const int subSeg = 6;
            for (int subIndice = 1; subIndice <= subSeg; subIndice++) {
              final double tSeg = subIndice / subSeg;
              final double xSeg = xPoste + 3 +
                  tSeg * anchoCelda * 0.85;
              final double ySeg = rectCelda.top +
                  altoCelda * 0.10 +
                  math.sin(tSeg * math.pi * 2 + faseOnda) *
                      altoCelda * 0.06;
              tela.lineTo(xSeg, ySeg);
            }
            for (int subIndice = subSeg; subIndice >= 0; subIndice--) {
              final double tSeg = subIndice / subSeg;
              final double xSeg = xPoste + 3 +
                  tSeg * anchoCelda * 0.85;
              final double ySeg = rectCelda.top +
                  altoCelda * 0.55 +
                  math.sin(tSeg * math.pi * 2 + faseOnda) *
                      altoCelda * 0.06;
              tela.lineTo(xSeg, ySeg);
            }
            tela.close();
            canvas.drawPath(
              tela,
              Paint()..color = PaletaRotulador.rojoEstampilla,
            );
            canvas.drawPath(
              tela,
              Paint()
                ..color = PaletaRotulador.tinta
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.0,
            );
            _dibujarEstrellaCinco(
              canvas,
              Offset(xPoste + anchoCelda * 0.45,
                  rectCelda.top + altoCelda * 0.32),
              anchoCelda * 0.14,
              Paint()..color = PaletaRotulador.papel,
            );
            break;
        }
      }
    }

    // Dibujar cadete pixel-art. La plantilla mide 11×14 píxeles y se
    // centra en `centro`. Escala calculada para que el sprite ocupe
    // exactamente la altura de la hitbox (0.8 celdas) y los pies del
    // sprite coincidan con la base de la hitbox (posicionY + 0.4).
    const double altoHitboxCeldas = 0.8;
    final double escalaPixelCadete = altoHitboxCeldas * altoCelda / 14.0;
    final double altoSpritePx = 14.0 * escalaPixelCadete;
    final double xPxJugador =
        (posicionX - scrollCamara) * anchoCelda;
    final double yPiesJugador = (posicionY + 0.4) * altoCelda;
    final double yPxJugador = yPiesJugador - altoSpritePx / 2.0;
    // §17.1: cadete pixel canónico (64×96) si está cargado, sino fallback.
    if (imagenCadetePixel != null) {
      final double anchoSpritePx = altoSpritePx * 64 / 96; // mantiene ratio
      final Rect destino = Rect.fromCenter(
        center: Offset(xPxJugador, yPxJugador),
        width: anchoSpritePx,
        height: altoSpritePx,
      );
      // Mirror horizontal si va hacia la izquierda.
      canvas.save();
      if (direccionMira < 0) {
        canvas.translate(destino.center.dx * 2, 0);
        canvas.scale(-1, 1);
      }
      canvas.drawImageRect(
        imagenCadetePixel!,
        Rect.fromLTWH(0, 0, imagenCadetePixel!.width.toDouble(),
            imagenCadetePixel!.height.toDouble()),
        destino,
        Paint()..filterQuality = FilterQuality.none,
      );
      canvas.restore();
    } else {
      dibujarCadetePixelArt(
        canvas,
        centro: Offset(xPxJugador, yPxJugador),
        escalaPixel: escalaPixelCadete,
        direccionMira: direccionMira,
      );
    }

    // Overlay fin de partida.
    if (partidaTerminada) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = PaletaRotulador.papel.withValues(alpha: 0.85),
      );
      final pintor = TextPainter(
        text: TextSpan(
          text: partidaGanada
              ? '★ BANDERA ALCANZADA ★\nPULSA ENTER PARA OTRA RONDA'
              : 'PIXEL DERRAMADO\nPULSA ENTER PARA REINTENTAR',
          style: TextStyle(
            color: partidaGanada
                ? PaletaRotulador.rojoEstampilla
                : PaletaRotulador.rojoEstampilla,
            fontFamily: 'CosmoMono',
            fontSize: anchoCelda * 0.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            height: 1.4,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: size.width * 0.85);
      pintor.paint(
        canvas,
        Offset(size.width / 2 - pintor.width / 2,
            size.height / 2 - pintor.height / 2),
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
  bool shouldRepaint(covariant _PintorPixelPerdido viejo) => true;
}

const String _flagHighscorePixel = 'pixel_perdido_highscore_';

int _leerHighscorePixel(EstadoJuego estado) {
  for (final flag in estado.flagsActivos) {
    if (flag.startsWith(_flagHighscorePixel)) {
      return int.tryParse(flag.substring(_flagHighscorePixel.length)) ?? 0;
    }
  }
  return 0;
}

void _guardarHighscorePixel(EstadoJuego estado, int puntuacion) {
  estado.flagsActivos.removeWhere(
    (flag) => flag.startsWith(_flagHighscorePixel),
  );
  estado.activarFlag('$_flagHighscorePixel$puntuacion');
}
