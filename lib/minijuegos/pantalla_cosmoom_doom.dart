import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../widgets/propaganda_button.dart';
import 'pintor_rotulador.dart';
import 'utilidades_carga_sprites.dart';
import 'widget_pausa.dart';

/// COSMOOM DOOM.
///
/// Pseudo-3D estilo Wolfenstein/Doom temprano (raycasting por
/// columnas). El cadete recorre en primera persona los pasillos del
/// Ministerio Cosmonáutico, plagados de Burócratas-Zombi y mesas con
/// expedientes. Dispara sellos rojos que tumban a los burócratas de
/// dos selladas. Salud limitada y un final claro: llegar a la salida.
class PantallaCosmoomDoom extends StatefulWidget {
  final EstadoJuego estado;

  const PantallaCosmoomDoom({super.key, required this.estado});

  @override
  State<PantallaCosmoomDoom> createState() => _PantallaCosmoomDoomState();
}

class _PantallaCosmoomDoomState extends State<PantallaCosmoomDoom>
    with SingleTickerProviderStateMixin {
  // 0 aire, 1 pared estandar, 2 pared con sello rojo, 3 pared archivador,
  // 4 puerta salida.
  static const List<String> trazadoMapa = <String>[
    '1111111111111111',
    '1..............1',
    '1.111111.1111..1',
    '1.1....1.1..1..1',
    '1.1.22.1.1..1..1',
    '1.1....1.1..1..1',
    '1.1.1111.1..1..1',
    '1.1..........3.1',
    '1.111.111111.3.1',
    '1.....1......3.1',
    '1.111.1.1111.3.1',
    '1.1...1.1....3.1',
    '1.1.111.1.1111.1',
    '1.1.....1......1',
    '1.111111111114.1',
    '1111111111111111',
  ];

  late List<List<int>> mapa;
  late Ticker tickerJuego;
  Duration? marcaTemporalAnterior;
  final FocusNode nodoFoco = FocusNode(debugLabel: 'cosmoom_doom');

  // Estado del jugador.
  // Posicion inicial en la fila 1 (pasillo libre de la entrada). El
  // angulo apunta a +x (mira al fondo de ese pasillo).
  double jugadorX = 3.5;
  double jugadorY = 1.5;
  double jugadorAngulo = 0; // radianes, 0 = mira +x
  int vidaJugador = 100;
  int sellos = 12;
  int puntuacion = 0;
  bool partidaTerminada = false;
  bool partidaGanada = false;
  bool partidaPausada = false;
  bool moviendoAdelante = false;
  bool moviendoAtras = false;
  bool girandoIzquierda = false;
  bool girandoDerecha = false;
  bool desplazandoIzquierda = false;
  bool desplazandoDerecha = false;
  double tiempoHastaSiguienteSello = 0;
  double fasePistola = 0;

  final List<_BurocrataZombi> enemigos = <_BurocrataZombi>[];
  final List<_SelloVolante> sellosLanzados = <_SelloVolante>[];
  double tiempoFlashDolor = 0;
  // Sprites del minijuego. Se cargan asincrónicamente en [initState];
  // mientras llegan (o si el asset no existe todavía — cableado
  // anticipado), el painter cae al modo geométrico para que nunca
  // haya pantalla negra. Cada uno está documentado en
  // `BRIEFING_ARTE.md` §13.
  ui.Image? imagenZombiFrente;
  ui.Image? imagenZombiPerfil;
  ui.Image? imagenParedMinisterio; // §13.1 — 512×512 tileable
  ui.Image? imagenSueloBaldosa; // §13.2 — 512×512 tileable XY
  ui.Image? imagenMesaBurocratica; // §13.3 — 320×440 billboard
  ui.Image? imagenSelloProyectil; // §13.4 — 160×160 sprite
  ui.Image? imagenHudCadete; // §13.5 — 800×260 marco HUD

  static const double fovTotal = 1.15; // ~66 grados (estandar Doom/Wolf)
  static const double velocidadCaminarJugador = 3.2;
  static const double velocidadRotacionJugador = 2.4;
  static const double cooldownSello = 0.32;

  @override
  void initState() {
    super.initState();
    mapa = List<List<int>>.generate(
      trazadoMapa.length,
      (fila) => List<int>.generate(trazadoMapa[fila].length, (columna) {
        final c = trazadoMapa[fila][columna];
        if (c == '.') return 0;
        if (c == '1') return 1;
        if (c == '2') return 2;
        if (c == '3') return 3;
        if (c == '4') return 4;
        return 0;
      }),
    );
    _generarEnemigos();
    tickerJuego = createTicker(_alTick)..start();
    _cargarSprites();
  }

  /// Carga los 7 sprites del Doom en paralelo. Los 2 burócratas-zombi
  /// ya existen como PNG; los 5 de §13 son cableado anticipado: si
  /// `assets/svg/doom_*.png` no existe aún, la utility devuelve null
  /// y el painter mantiene el render procedural actual.
  Future<void> _cargarSprites() async {
    final resultados = await cargarLoteOpcional(<String>[
      'assets/images/burocrata_zombi_frente.png',
      'assets/images/burocrata_zombi_perfil.png',
      'assets/svg/doom_pared_ministerio.png',
      'assets/svg/doom_suelo_baldosa.png',
      'assets/svg/doom_mesa_burocratica.png',
      'assets/svg/doom_sello_proyectil.png',
      'assets/svg/doom_hud_cadete.png',
    ]);
    if (!mounted) return;
    setState(() {
      imagenZombiFrente = resultados[0];
      imagenZombiPerfil = resultados[1];
      imagenParedMinisterio = resultados[2];
      imagenSueloBaldosa = resultados[3];
      imagenMesaBurocratica = resultados[4];
      imagenSelloProyectil = resultados[5];
      imagenHudCadete = resultados[6];
    });
  }

  @override
  void dispose() {
    tickerJuego.dispose();
    nodoFoco.dispose();
    super.dispose();
  }

  void _generarEnemigos() {
    enemigos.clear();
    // Ministerio plagado: más burócratas-zombi para que el FPS
    // tenga densidad real. Patrullan los pasillos del complejo.
    enemigos.addAll(<_BurocrataZombi>[
      _BurocrataZombi(posX: 5.5, posY: 4.5),
      _BurocrataZombi(posX: 9.5, posY: 7.5),
      _BurocrataZombi(posX: 11.5, posY: 11.5),
      _BurocrataZombi(posX: 3.5, posY: 10.5),
      _BurocrataZombi(posX: 7.5, posY: 13.5),
      _BurocrataZombi(posX: 2.5, posY: 6.5),
      _BurocrataZombi(posX: 12.5, posY: 3.5),
      _BurocrataZombi(posX: 8.5, posY: 9.5),
      _BurocrataZombi(posX: 13.5, posY: 14.5),
      _BurocrataZombi(posX: 6.5, posY: 11.5),
      _BurocrataZombi(posX: 4.5, posY: 13.5),
      _BurocrataZombi(posX: 10.5, posY: 5.5),
    ]);
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
    fasePistola += dt;
    if (tiempoHastaSiguienteSello > 0) {
      tiempoHastaSiguienteSello -= dt;
    }
    if (tiempoFlashDolor > 0) {
      tiempoFlashDolor = math.max(0, tiempoFlashDolor - dt);
    }
    _moverJugador(dt);
    _moverEnemigos(dt);
    _moverSellos(dt);
    _resolverImpactos(dt);
    setState(() {});
  }

  void _moverJugador(double dt) {
    if (girandoIzquierda) {
      jugadorAngulo -= velocidadRotacionJugador * dt;
    }
    if (girandoDerecha) {
      jugadorAngulo += velocidadRotacionJugador * dt;
    }
    final double cosA = math.cos(jugadorAngulo);
    final double senA = math.sin(jugadorAngulo);
    double dx = 0, dy = 0;
    if (moviendoAdelante) {
      dx += cosA * velocidadCaminarJugador * dt;
      dy += senA * velocidadCaminarJugador * dt;
    }
    if (moviendoAtras) {
      dx -= cosA * velocidadCaminarJugador * dt * 0.7;
      dy -= senA * velocidadCaminarJugador * dt * 0.7;
    }
    if (desplazandoIzquierda) {
      dx += senA * velocidadCaminarJugador * dt * 0.7;
      dy -= cosA * velocidadCaminarJugador * dt * 0.7;
    }
    if (desplazandoDerecha) {
      dx -= senA * velocidadCaminarJugador * dt * 0.7;
      dy += cosA * velocidadCaminarJugador * dt * 0.7;
    }
    // Mover X probando colision.
    final double nuevoX = jugadorX + dx;
    if (!_esPared(nuevoX, jugadorY)) {
      jugadorX = nuevoX;
    }
    final double nuevoY = jugadorY + dy;
    if (!_esPared(jugadorX, nuevoY)) {
      jugadorY = nuevoY;
    }
    // Comprobar puerta de salida.
    final int celdaActual = _celdaEn(jugadorX, jugadorY);
    if (celdaActual == 4) {
      partidaTerminada = true;
      partidaGanada = true;
      _guardarHighscore();
    }
  }

  bool _esPared(double x, double y) {
    final int fila = y.floor();
    final int columna = x.floor();
    if (fila < 0 || fila >= mapa.length) return true;
    if (columna < 0 || columna >= mapa[0].length) return true;
    final int valor = mapa[fila][columna];
    return valor == 1 || valor == 2 || valor == 3;
  }

  int _celdaEn(double x, double y) {
    final int fila = y.floor();
    final int columna = x.floor();
    if (fila < 0 || fila >= mapa.length) return 1;
    if (columna < 0 || columna >= mapa[0].length) return 1;
    return mapa[fila][columna];
  }

  /// Comprueba si hay línea de visión libre entre dos celdas: lanza
  /// un rayo en pasos pequeños y devuelve false si encuentra pared.
  bool _hayLineaVision(
      double origenX, double origenY, double destinoX, double destinoY) {
    final double dx = destinoX - origenX;
    final double dy = destinoY - origenY;
    final double distancia = math.sqrt(dx * dx + dy * dy);
    if (distancia < 0.001) return true;
    const double pasoRayo = 0.18;
    final int pasos = (distancia / pasoRayo).ceil();
    for (int p = 1; p < pasos; p++) {
      final double t = p / pasos;
      final double rx = origenX + dx * t;
      final double ry = origenY + dy * t;
      if (_esPared(rx, ry)) return false;
    }
    return true;
  }

  void _moverEnemigos(double dt) {
    const double velEnemigo = 0.7;
    final math.Random rngWander = math.Random();
    for (final enemigo in List<_BurocrataZombi>.from(enemigos)) {
      if (!enemigo.vivo) continue;
      final double dx = jugadorX - enemigo.posX;
      final double dy = jugadorY - enemigo.posY;
      final double dist = math.sqrt(dx * dx + dy * dy);
      if (dist < 0.05) continue;
      // Sólo persigue si tiene línea de visión directa o ya está
      // cerca (combate cuerpo a cuerpo): evita que pateen tras la
      // pared como antes.
      final bool tieneVision = dist < 1.5 ||
          _hayLineaVision(
              enemigo.posX, enemigo.posY, jugadorX, jugadorY);
      if (!tieneVision) {
        enemigo.fase += dt;
        continue;
      }
      double dirX = dx / dist;
      double dirY = dy / dist;
      double nx = enemigo.posX + dirX * velEnemigo * dt;
      double ny = enemigo.posY + dirY * velEnemigo * dt;
      bool avanzoX = !_esPared(nx, enemigo.posY);
      bool avanzoY = !_esPared(enemigo.posX, ny);
      // Si una via esta bloqueada, intenta moverse solo en el otro eje
      // o aplicar un pequeno wander perpendicular para no atascarse.
      if (!avanzoX && !avanzoY) {
        final double angWander = rngWander.nextDouble() * math.pi * 2;
        nx = enemigo.posX + math.cos(angWander) * velEnemigo * dt;
        ny = enemigo.posY + math.sin(angWander) * velEnemigo * dt;
        avanzoX = !_esPared(nx, enemigo.posY);
        avanzoY = !_esPared(enemigo.posX, ny);
      }
      if (avanzoX) enemigo.posX = nx;
      if (avanzoY) enemigo.posY = ny;
      enemigo.fase += dt;
      // Ataque cuerpo a cuerpo si esta muy cerca.
      if (dist < 0.6 && enemigo.cooldownAtaque <= 0) {
        vidaJugador -= 8;
        enemigo.cooldownAtaque = 1.0;
        tiempoFlashDolor = 0.4;
        if (vidaJugador <= 0) {
          vidaJugador = 0;
          partidaTerminada = true;
          partidaGanada = false;
          _guardarHighscore();
        }
      } else if (enemigo.cooldownAtaque > 0) {
        enemigo.cooldownAtaque -= dt;
      }
    }
  }

  void _moverSellos(double dt) {
    for (final sello in sellosLanzados) {
      sello.posX += math.cos(sello.angulo) * 6.0 * dt;
      sello.posY += math.sin(sello.angulo) * 6.0 * dt;
      sello.vidaSegundos -= dt;
      if (_esPared(sello.posX, sello.posY)) {
        sello.vidaSegundos = 0;
      }
    }
    sellosLanzados.removeWhere((s) => s.vidaSegundos <= 0);
  }

  void _resolverImpactos(double dt) {
    for (final sello in List<_SelloVolante>.from(sellosLanzados)) {
      for (final enemigo in enemigos) {
        if (!enemigo.vivo) continue;
        final double dxEnem = enemigo.posX - sello.posX;
        final double dyEnem = enemigo.posY - sello.posY;
        if (dxEnem * dxEnem + dyEnem * dyEnem < 0.35 * 0.35) {
          enemigo.vidaRestante -= 1;
          sellosLanzados.remove(sello);
          if (enemigo.vidaRestante <= 0) {
            enemigo.vivo = false;
            puntuacion += 150;
          }
          break;
        }
      }
    }
  }

  void _dispararSello() {
    if (tiempoHastaSiguienteSello > 0) return;
    if (sellos <= 0) return;
    sellos -= 1;
    sellosLanzados.add(_SelloVolante(
      posX: jugadorX + math.cos(jugadorAngulo) * 0.3,
      posY: jugadorY + math.sin(jugadorAngulo) * 0.3,
      angulo: jugadorAngulo,
      vidaSegundos: 1.2,
    ));
    tiempoHastaSiguienteSello = cooldownSello;
    fasePistola = 0; // animar retroceso
  }

  void _guardarHighscore() {
    final int previo = _leerHighscoreDoom(widget.estado);
    if (puntuacion > previo) {
      _guardarHighscoreDoom(widget.estado, puntuacion);
    }
  }

  void _resetear() {
    setState(() {
      jugadorX = 3.5;
      jugadorY = 1.5;
      jugadorAngulo = 0;
      vidaJugador = 100;
      sellos = 12;
      puntuacion = 0;
      partidaTerminada = false;
      partidaGanada = false;
      sellosLanzados.clear();
      _generarEnemigos();
    });
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
        _resetear();
        return KeyEventResult.handled;
      }
    }

    void setear(bool valor, void Function(bool) destino) {
      if (esPulsacion) destino(true);
      if (esLevantamiento) destino(false);
    }

    if (tecla == LogicalKeyboardKey.keyW ||
        tecla == LogicalKeyboardKey.arrowUp) {
      setear(esPulsacion, (v) => moviendoAdelante = v);
      return KeyEventResult.handled;
    }
    if (tecla == LogicalKeyboardKey.keyS ||
        tecla == LogicalKeyboardKey.arrowDown) {
      setear(esPulsacion, (v) => moviendoAtras = v);
      return KeyEventResult.handled;
    }
    if (tecla == LogicalKeyboardKey.keyA ||
        tecla == LogicalKeyboardKey.arrowLeft) {
      setear(esPulsacion, (v) => girandoIzquierda = v);
      return KeyEventResult.handled;
    }
    if (tecla == LogicalKeyboardKey.keyD ||
        tecla == LogicalKeyboardKey.arrowRight) {
      setear(esPulsacion, (v) => girandoDerecha = v);
      return KeyEventResult.handled;
    }
    if (tecla == LogicalKeyboardKey.keyQ) {
      setear(esPulsacion, (v) => desplazandoIzquierda = v);
      return KeyEventResult.handled;
    }
    if (tecla == LogicalKeyboardKey.keyE) {
      setear(esPulsacion, (v) => desplazandoDerecha = v);
      return KeyEventResult.handled;
    }
    if (tecla == LogicalKeyboardKey.space && evento is KeyDownEvent) {
      _dispararSello();
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
    final int mejor = _leerHighscoreDoom(widget.estado);
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
            semilla: 53,
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
                              Expanded(child: _construirVista3D()),
                              const SizedBox(width: 16),
                              SizedBox(
                                  width: 220,
                                  child: _construirPanelLateral()),
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
          'COSMOOM DOOM · MINISTERIO',
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
            _chip('VIDA', '$vidaJugador'),
            const SizedBox(width: 6),
            _chip('SELLOS', '$sellos'),
            const SizedBox(width: 6),
            _chip('PUNTOS', '$puntuacion', acentuado: true),
            const SizedBox(width: 6),
            _chip('RÉCORD', '$mejor', acentuado: true),
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

  Widget _construirVista3D() {
    return AspectRatio(
      aspectRatio: 4 / 3,
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
          painter: _PintorVistaDoom(
            mapa: mapa,
            jugadorX: jugadorX,
            jugadorY: jugadorY,
            jugadorAngulo: jugadorAngulo,
            enemigos: enemigos,
            sellosLanzados: sellosLanzados,
            tiempoFlashDolor: tiempoFlashDolor,
            fasePistola: fasePistola,
            vidaJugador: vidaJugador,
            sellosRestantes: sellos,
            puntuacionActual: puntuacion,
            partidaTerminada: partidaTerminada,
            partidaGanada: partidaGanada,
            imagenZombiFrente: imagenZombiFrente,
            imagenZombiPerfil: imagenZombiPerfil,
            imagenParedMinisterio: imagenParedMinisterio,
            imagenSueloBaldosa: imagenSueloBaldosa,
            imagenMesaBurocratica: imagenMesaBurocratica,
            imagenSelloProyectil: imagenSelloProyectil,
            imagenHudCadete: imagenHudCadete,
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
            'OBJETIVOS',
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
            'Recorre los pasillos del Ministerio. Sella a los Burócratas-Zombi con tus sellos rojos (dos selladas por cabeza). Encuentra la puerta verde de salida.',
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
            'W / ↑  : adelante\n'
            'S / ↓  : atrás\n'
            'A / ◀  : girar izq\n'
            'D / ▶  : girar der\n'
            'Q / E  : strafe\n'
            'ESPACIO: sellar\n'
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
            '«Sella, archiva, avanza. El Ministerio no perdona pasillos sin firmar.»',
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
}

class _BurocrataZombi {
  double posX;
  double posY;
  int vidaRestante;
  bool vivo;
  double fase;
  double cooldownAtaque;

  _BurocrataZombi({
    required this.posX,
    required this.posY,
  })  : vidaRestante = 2,
        vivo = true,
        fase = 0,
        cooldownAtaque = 0;
}

class _SelloVolante {
  double posX;
  double posY;
  double angulo;
  double vidaSegundos;

  _SelloVolante({
    required this.posX,
    required this.posY,
    required this.angulo,
    required this.vidaSegundos,
  });
}

class _PintorVistaDoom extends CustomPainter {
  final List<List<int>> mapa;
  final double jugadorX;
  final double jugadorY;
  final double jugadorAngulo;
  final List<_BurocrataZombi> enemigos;
  final List<_SelloVolante> sellosLanzados;
  final double tiempoFlashDolor;
  final double fasePistola;
  final int vidaJugador;
  final int sellosRestantes;
  final int puntuacionActual;
  final bool partidaTerminada;
  final bool partidaGanada;
  /// Sprites del minijuego. Pueden ser null durante los primeros
  /// frames mientras se cargan o si el asset aún no se ha generado
  /// (cableado anticipado §13.x); en ambos casos el painter cae al
  /// dibujado procedural como fallback.
  final ui.Image? imagenZombiFrente;
  final ui.Image? imagenZombiPerfil;
  final ui.Image? imagenParedMinisterio; // §13.1
  final ui.Image? imagenSueloBaldosa; // §13.2
  final ui.Image? imagenMesaBurocratica; // §13.3
  final ui.Image? imagenSelloProyectil; // §13.4
  final ui.Image? imagenHudCadete; // §13.5

  _PintorVistaDoom({
    required this.mapa,
    required this.jugadorX,
    required this.jugadorY,
    required this.jugadorAngulo,
    required this.enemigos,
    required this.sellosLanzados,
    required this.tiempoFlashDolor,
    required this.fasePistola,
    required this.vidaJugador,
    required this.sellosRestantes,
    required this.puntuacionActual,
    required this.partidaTerminada,
    required this.partidaGanada,
    this.imagenZombiFrente,
    this.imagenZombiPerfil,
    this.imagenParedMinisterio,
    this.imagenSueloBaldosa,
    this.imagenMesaBurocratica,
    this.imagenSelloProyectil,
    this.imagenHudCadete,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Techo: papel sucio con rayado paralelo (sombra arquitectónica).
    final Rect rectTecho =
        Rect.fromLTWH(0, 0, size.width, size.height / 2);
    canvas.drawRect(
      rectTecho,
      Paint()..color = PaletaRotulador.papelSucio,
    );
    rayadoParalelo(
      canvas,
      rectTecho,
      pincel: Paint()
        ..color = PaletaRotulador.tintaDiluida(0.20)
        ..strokeWidth = 0.7,
      espaciado: math.max(4.0, size.height * 0.06),
      anguloRayas: math.pi / 4,
      intensidadJitter: 0.4,
    );
    // Linea de horizonte: tinta firme.
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      Paint()
        ..color = PaletaRotulador.tinta
        ..strokeWidth = 1.8,
    );
    // Suelo: papel limpio con rayado a tinta para sugerir baldosas.
    final Rect rectSuelo =
        Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2);
    canvas.drawRect(
      rectSuelo,
      Paint()..color = PaletaRotulador.papel,
    );
    // Lineas de perspectiva del suelo.
    final Offset puntoFuga = Offset(size.width / 2, size.height / 2);
    for (int indiceLinea = -6; indiceLinea <= 6; indiceLinea++) {
      final double xBaseLinea = size.width / 2 +
          indiceLinea * size.width / 12;
      canvas.drawLine(
        puntoFuga,
        Offset(xBaseLinea, size.height),
        Paint()
          ..color =
              PaletaRotulador.tinta.withValues(alpha: 0.30)
          ..strokeWidth = 0.7,
      );
    }
    for (int indiceFila = 1; indiceFila <= 6; indiceFila++) {
      final double yLinea = size.height / 2 +
          (size.height / 2) *
              (indiceFila / 6) * (indiceFila / 6);
      canvas.drawLine(
        Offset(0, yLinea),
        Offset(size.width, yLinea),
        Paint()
          ..color =
              PaletaRotulador.tinta.withValues(alpha: 0.20)
          ..strokeWidth = 0.6,
      );
    }

    // Raycasting por columnas (1 rayo cada 2 px para no saturar).
    // Distancia al plano de proyeccion: hace que las paredes mantengan
    // la proporcion correcta segun el FOV y el ancho de pantalla.
    final double distanciaProyeccion =
        (size.width / 2) /
            math.tan(_PantallaCosmoomDoomState.fovTotal / 2);
    const int pasoColumnas = 2;
    final List<double> distanciasBuffer = List<double>.filled(
        (size.width / pasoColumnas).ceil() + 1, double.infinity);

    int indiceBuffer = 0;
    for (double xPantalla = 0;
        xPantalla < size.width;
        xPantalla += pasoColumnas, indiceBuffer++) {
      final double anguloRayo = jugadorAngulo +
          (xPantalla / size.width - 0.5) *
              _PantallaCosmoomDoomState.fovTotal;
      final ({double distancia, int valor, bool ladoX}) hit =
          _trazarRayo(anguloRayo);
      // Corregir fish-eye con coseno relativo.
      final double distanciaCorregida =
          hit.distancia * math.cos(anguloRayo - jugadorAngulo);
      distanciasBuffer[indiceBuffer] = distanciaCorregida;
      // Altura de la pared en pantalla = distProyeccion / distMundo.
      // Capamos a altura de pantalla para evitar valores extremos al
      // pegarse a una pared.
      final double alturaPared = math.min(size.height * 1.4,
          distanciaProyeccion / (distanciaCorregida + 0.001));
      final double topePared = (size.height - alturaPared) / 2;
      // Color según el tipo de pared (escala de tinta para que todo
      // funcione en blanco y negro; el rojo se reserva para sellos y
      // la puerta de salida).
      Color colorPared;
      switch (hit.valor) {
        case 2:
          // Pared con sello: rojo apagado.
          colorPared = PaletaRotulador.rojoEstampilla.withValues(alpha: 0.85);
          break;
        case 3:
          // Archivador: tinta media (más oscuro que muro estándar).
          colorPared = PaletaRotulador.tintaDiluida(0.55);
          break;
        case 4:
          // Puerta de salida: rojo pleno.
          colorPared = PaletaRotulador.rojoEstampilla;
          break;
        default:
          // Muro estándar: papel sucio.
          colorPared = PaletaRotulador.papelSucio;
      }
      // Atenuar por distancia (menos agresiva: visibilidad razonable
      // hasta 14 unidades).
      final double atenuacion =
          (1.0 - (distanciaCorregida / 14).clamp(0.0, 0.80));
      final Color colorFinal = Color.lerp(
        PaletaRotulador.tinta,
        hit.ladoX
            ? Color.lerp(colorPared, PaletaRotulador.tinta, 0.20)!
            : colorPared,
        atenuacion,
      )!;
      canvas.drawRect(
        Rect.fromLTWH(xPantalla, topePared, pasoColumnas.toDouble() + 1,
            alturaPared),
        Paint()..color = colorFinal,
      );
      // Textura pseudo-ladrillo: bandas horizontales con ligero
      // alternado de tono segun la posicion vertical. Solo sobre paredes
      // estandar y archivador para no enmascarar puerta/sello.
      if (hit.valor == 1 || hit.valor == 3) {
        // Cuantos "ladrillos" caben en la pared visible.
        final int bandas = math.max(2, (alturaPared / 16).floor());
        for (int indiceBanda = 0; indiceBanda < bandas; indiceBanda++) {
          final double yBanda = topePared +
              alturaPared * indiceBanda / bandas;
          // Linea de mortero entre ladrillos (oscura).
          canvas.drawLine(
            Offset(xPantalla, yBanda),
            Offset(xPantalla + pasoColumnas.toDouble() + 1, yBanda),
            Paint()
              ..color = PaletaRotulador.tinta
                  .withValues(alpha: 0.40 * atenuacion)
              ..strokeWidth = 0.8,
          );
          // Cada otra banda, un leve highlight.
          if (indiceBanda.isOdd) {
            canvas.drawRect(
              Rect.fromLTWH(
                  xPantalla,
                  yBanda + 1.5,
                  pasoColumnas.toDouble() + 1,
                  1.5),
              Paint()
                ..color = PaletaRotulador.tinta
                    .withValues(alpha: 0.10 * atenuacion),
            );
          }
        }
      }
    }

    // Sprites: enemigos + sellos volantes (billboarding).
    _pintarSprites(canvas, size, distanciasBuffer, pasoColumnas);

    // Crosshair central: mira para el sello.
    final Offset centroVista = Offset(size.width / 2, size.height / 2);
    final Paint pincelMira = Paint()
      ..color = PaletaRotulador.papel.withValues(alpha: 0.65)
      ..strokeWidth = 1.4;
    canvas.drawLine(
      centroVista.translate(-8, 0),
      centroVista.translate(-3, 0),
      pincelMira,
    );
    canvas.drawLine(
      centroVista.translate(3, 0),
      centroVista.translate(8, 0),
      pincelMira,
    );
    canvas.drawLine(
      centroVista.translate(0, -8),
      centroVista.translate(0, -3),
      pincelMira,
    );
    canvas.drawLine(
      centroVista.translate(0, 3),
      centroVista.translate(0, 8),
      pincelMira,
    );

    // Flash de dolor.
    if (tiempoFlashDolor > 0) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..color = PaletaRotulador.rojoEstampilla
              .withValues(alpha: tiempoFlashDolor * 0.6),
      );
    }

    // Pistola / sello en la mano (HUD inferior).
    _pintarSelloEnMano(canvas, size);

    // HUD inferior estilo Doom con cara del cosmonauta + barras.
    _pintarHUDInferiorCosmonauta(canvas, size);

    // Mini-mapa esquina superior derecha.
    _pintarMiniMapa(canvas, size);

    if (partidaTerminada) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = PaletaRotulador.papel.withValues(alpha: 0.85),
      );
      final pintor = TextPainter(
        text: TextSpan(
          text: partidaGanada
              ? '★ MINISTERIO SELLADO ★\nPULSA ENTER PARA OTRA RONDA'
              : 'TE HAN SELLADO\nPULSA ENTER PARA REINTENTAR',
          style: TextStyle(
            color: partidaGanada
                ? PaletaRotulador.rojoEstampilla
                : PaletaRotulador.rojoEstampilla,
            fontFamily: 'CosmoMono',
            fontSize: size.width * 0.035,
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

  ({double distancia, int valor, bool ladoX}) _trazarRayo(double angulo) {
    // DDA grid traversal.
    final double dirX = math.cos(angulo);
    final double dirY = math.sin(angulo);
    int mapaX = jugadorX.floor();
    int mapaY = jugadorY.floor();
    final double deltaDistX = (dirX == 0) ? 1e30 : (1 / dirX).abs();
    final double deltaDistY = (dirY == 0) ? 1e30 : (1 / dirY).abs();
    int pasoX, pasoY;
    double distLadoX, distLadoY;
    if (dirX < 0) {
      pasoX = -1;
      distLadoX = (jugadorX - mapaX) * deltaDistX;
    } else {
      pasoX = 1;
      distLadoX = (mapaX + 1.0 - jugadorX) * deltaDistX;
    }
    if (dirY < 0) {
      pasoY = -1;
      distLadoY = (jugadorY - mapaY) * deltaDistY;
    } else {
      pasoY = 1;
      distLadoY = (mapaY + 1.0 - jugadorY) * deltaDistY;
    }
    bool ladoX = true;
    int valorChoque = 1;
    for (int paso = 0; paso < 80; paso++) {
      if (distLadoX < distLadoY) {
        distLadoX += deltaDistX;
        mapaX += pasoX;
        ladoX = true;
      } else {
        distLadoY += deltaDistY;
        mapaY += pasoY;
        ladoX = false;
      }
      if (mapaY < 0 || mapaY >= mapa.length) break;
      if (mapaX < 0 || mapaX >= mapa[0].length) break;
      final int valorCelda = mapa[mapaY][mapaX];
      if (valorCelda == 1 || valorCelda == 2 || valorCelda == 3 ||
          valorCelda == 4) {
        valorChoque = valorCelda;
        break;
      }
    }
    double distancia;
    if (ladoX) {
      distancia = (mapaX - jugadorX + (1 - pasoX) / 2) / dirX;
    } else {
      distancia = (mapaY - jugadorY + (1 - pasoY) / 2) / dirY;
    }
    return (distancia: distancia.abs(), valor: valorChoque, ladoX: ladoX);
  }

  void _pintarSprites(Canvas canvas, Size size,
      List<double> distanciasBuffer, int pasoColumnas) {
    final double distanciaProyeccion =
        (size.width / 2) /
            math.tan(_PantallaCosmoomDoomState.fovTotal / 2);
    // Lista de sprites a pintar: enemigos vivos + sellos volantes.
    // Ordenarlos por distancia descendente (mas lejano primero).
    final List<_SpriteRender> sprites = <_SpriteRender>[];
    for (final enemigo in enemigos) {
      if (!enemigo.vivo) continue;
      sprites.add(_SpriteRender(
        posX: enemigo.posX,
        posY: enemigo.posY,
        tipo: _TipoSprite.enemigo,
        ref: enemigo,
      ));
    }
    for (final sello in sellosLanzados) {
      sprites.add(_SpriteRender(
        posX: sello.posX,
        posY: sello.posY,
        tipo: _TipoSprite.sello,
        ref: sello,
      ));
    }
    // Calcular distancia y orden.
    for (final s in sprites) {
      final double dx = s.posX - jugadorX;
      final double dy = s.posY - jugadorY;
      s.distancia = math.sqrt(dx * dx + dy * dy);
    }
    sprites.sort((a, b) => b.distancia.compareTo(a.distancia));
    // Pintar.
    for (final s in sprites) {
      final double dx = s.posX - jugadorX;
      final double dy = s.posY - jugadorY;
      final double anguloSprite = math.atan2(dy, dx) - jugadorAngulo;
      double angNorm = anguloSprite;
      while (angNorm > math.pi) {
        angNorm -= 2 * math.pi;
      }
      while (angNorm < -math.pi) {
        angNorm += 2 * math.pi;
      }
      if (angNorm.abs() > _PantallaCosmoomDoomState.fovTotal) continue;
      final double distancia = s.distancia *
          math.cos(angNorm);
      if (distancia < 0.1) continue;
      final double xPantallaCentro =
          size.width * (0.5 + angNorm / _PantallaCosmoomDoomState.fovTotal);
      // Tamano del sprite proporcional a la distancia de proyeccion
      // (mismo factor que las paredes para que coexistan en escala).
      final double altoSprite = math.min(size.height * 1.2,
          distanciaProyeccion / distancia * 0.85);
      final double anchoSprite = altoSprite *
          (s.tipo == _TipoSprite.sello ? 0.5 : 0.75);
      final Rect rectSprite = Rect.fromCenter(
        center: Offset(xPantallaCentro,
            size.height / 2 + altoSprite * 0.20),
        width: anchoSprite,
        height: altoSprite,
      );
      // Comprobar oclusion por columna de buffer.
      final int columnaBuffer =
          (xPantallaCentro / pasoColumnas).floor().clamp(0,
              distanciasBuffer.length - 1);
      if (distanciasBuffer[columnaBuffer] < distancia) {
        // Mucho mas cerca la pared: aun asi dibujamos por estetica.
      }
      if (s.tipo == _TipoSprite.enemigo) {
        _pintarSpriteBurocrata(canvas, rectSprite, s.ref as _BurocrataZombi,
            distancia);
      } else {
        _pintarSpriteSello(canvas, rectSprite, distancia);
      }
    }
  }

  void _pintarSpriteBurocrata(
      Canvas canvas, Rect rect, _BurocrataZombi enemigo, double distancia) {
    final double atenuacion = (1.0 - (distancia / 12).clamp(0.0, 0.7));
    // Si los sprites PNG ya están cargados, usamos el ciclo de dos
    // frames (frente/perfil) sincronizado con la fase del enemigo para
    // simular un walk-cycle. Si no, caemos al dibujado geométrico.
    final bool mostrarPerfil = (enemigo.fase * 2).floor().isOdd;
    final ui.Image? spriteActual =
        mostrarPerfil ? imagenZombiPerfil : imagenZombiFrente;
    if (spriteActual != null) {
      final Rect rectOrigen = Rect.fromLTWH(
        0,
        0,
        spriteActual.width.toDouble(),
        spriteActual.height.toDouble(),
      );
      final Paint pincelImagen = Paint()
        ..filterQuality = FilterQuality.high
        ..colorFilter = ColorFilter.mode(
          PaletaRotulador.papel.withValues(alpha: 1.0 - atenuacion),
          BlendMode.srcATop,
        );
      canvas.drawImageRect(spriteActual, rectOrigen, rect, pincelImagen);
      // Marca de vida (puntos pequeños rojos) — se conserva por encima
      // del sprite para que el jugador siga viendo cuántos sellos
      // necesita.
      for (int indice = 0; indice < enemigo.vidaRestante; indice++) {
        canvas.drawCircle(
          Offset(rect.center.dx + (indice - 0.5) * rect.width * 0.08,
              rect.top - rect.height * 0.02),
          rect.width * 0.025,
          Paint()..color = PaletaRotulador.rojoEstampilla,
        );
      }
      return;
    }
    final Paint pincelTrazo = Paint()
      ..color = PaletaRotulador.tinta
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final double cuerpoH = rect.height * 0.55;
    final double cabezaR = rect.height * 0.18;
    // Cuerpo verde archivo (traje burócrata).
    final Rect rectCuerpo = Rect.fromLTWH(
      rect.center.dx - rect.width * 0.4,
      rect.center.dy - cuerpoH * 0.10,
      rect.width * 0.8,
      cuerpoH,
    );
    canvas.drawRect(
      rectCuerpo,
      Paint()
        ..color = Color.lerp(
                PaletaRotulador.tinta,
                PaletaRotulador.rojoEstampilla,
                atenuacion)!,
    );
    canvas.drawRect(rectCuerpo, pincelTrazo);
    // Cabeza palida.
    canvas.drawCircle(
      Offset(rect.center.dx, rectCuerpo.top - cabezaR * 0.95),
      cabezaR,
      Paint()
        ..color = Color.lerp(PaletaRotulador.tinta,
                PaletaRotulador.papel, atenuacion)!,
    );
    canvas.drawCircle(
      Offset(rect.center.dx, rectCuerpo.top - cabezaR * 0.95),
      cabezaR,
      pincelTrazo,
    );
    // Ojos rojos (parpadean).
    final bool parpadeo = (enemigo.fase * 6).floor().isEven;
    canvas.drawCircle(
      Offset(rect.center.dx - cabezaR * 0.35,
          rectCuerpo.top - cabezaR * 1.10),
      cabezaR * 0.12,
      Paint()..color = parpadeo
          ? PaletaRotulador.rojoEstampilla
          : PaletaRotulador.tinta,
    );
    canvas.drawCircle(
      Offset(rect.center.dx + cabezaR * 0.35,
          rectCuerpo.top - cabezaR * 1.10),
      cabezaR * 0.12,
      Paint()..color = parpadeo
          ? PaletaRotulador.rojoEstampilla
          : PaletaRotulador.tinta,
    );
    // Brazos extendidos (zombi).
    final double swing = math.sin(enemigo.fase * 4) * rect.width * 0.10;
    canvas.drawLine(
      Offset(rectCuerpo.left + rect.width * 0.05, rectCuerpo.top + cuerpoH * 0.2),
      Offset(rectCuerpo.left - rect.width * 0.12, rectCuerpo.top + cuerpoH * 0.4 + swing),
      pincelTrazo..strokeWidth = 4,
    );
    canvas.drawLine(
      Offset(rectCuerpo.right - rect.width * 0.05, rectCuerpo.top + cuerpoH * 0.2),
      Offset(rectCuerpo.right + rect.width * 0.12, rectCuerpo.top + cuerpoH * 0.4 - swing),
      pincelTrazo,
    );
    // Maletin colgando.
    canvas.drawRect(
      Rect.fromLTWH(rectCuerpo.right + rect.width * 0.05,
          rectCuerpo.top + cuerpoH * 0.45,
          rect.width * 0.18, rect.height * 0.12),
      Paint()..color = PaletaRotulador.tinta,
    );
    // Marca de vida (puntos pequeños rojos).
    for (int indice = 0; indice < enemigo.vidaRestante; indice++) {
      canvas.drawCircle(
        Offset(rectCuerpo.center.dx + (indice - 0.5) * rect.width * 0.08,
            rectCuerpo.top - rect.height * 0.42),
        rect.width * 0.025,
        Paint()..color = PaletaRotulador.rojoEstampilla,
      );
    }
  }

  void _pintarSpriteSello(Canvas canvas, Rect rect, double distancia) {
    // Sello rojo rotando.
    final double radio = math.min(rect.width, rect.height) * 0.4;
    canvas.drawCircle(
      rect.center,
      radio,
      Paint()..color = PaletaRotulador.rojoEstampilla,
    );
    canvas.drawCircle(
      rect.center,
      radio,
      Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    final pintor = TextPainter(
      text: TextSpan(
        text: 'F-447',
        style: TextStyle(
          color: PaletaRotulador.papel,
          fontFamily: 'CosmoMono',
          fontSize: radio * 0.7,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintor.paint(
      canvas,
      Offset(rect.center.dx - pintor.width / 2,
          rect.center.dy - pintor.height / 2),
    );
  }

  void _pintarSelloEnMano(Canvas canvas, Size size) {
    final double bobX = math.sin(fasePistola * 12) * 4;
    final double bobY = math.sin(fasePistola * 6) * 4;
    final Offset centroSello = Offset(
        size.width * 0.78 + bobX, size.height * 0.95 + bobY);
    final double radioSello = size.width * 0.07 *
        (1.0 - math.max(0.0, fasePistola < 0.15 ? (0.15 - fasePistola) / 0.15 : 0) * 0.3);
    // Mango de madera.
    canvas.drawRect(
      Rect.fromCenter(
          center: centroSello,
          width: radioSello * 0.4,
          height: radioSello * 1.4),
      Paint()..color = PaletaRotulador.tinta,
    );
    canvas.drawCircle(
      centroSello.translate(0, -radioSello * 0.6),
      radioSello * 0.3,
      Paint()..color = PaletaRotulador.tintaDiluida(0.65),
    );
    // Cabeza del sello (cuadrada).
    canvas.drawRect(
      Rect.fromCenter(
          center: centroSello.translate(0, radioSello * 0.6),
          width: radioSello * 1.4,
          height: radioSello * 0.5),
      Paint()..color = PaletaRotulador.rojoEstampilla,
    );
    canvas.drawRect(
      Rect.fromCenter(
          center: centroSello.translate(0, radioSello * 0.6),
          width: radioSello * 1.4,
          height: radioSello * 0.5),
      Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final pintor = TextPainter(
      text: const TextSpan(
        text: 'F-447',
        style: TextStyle(
          color: PaletaRotulador.papel,
          fontFamily: 'CosmoMono',
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintor.paint(
      canvas,
      Offset(centroSello.dx - pintor.width / 2,
          centroSello.dy + radioSello * 0.6 - pintor.height / 2),
    );
  }

  void _pintarHUDInferiorCosmonauta(Canvas canvas, Size size) {
    // Banda inferior tipo cabina metálica.
    final double alturaHud = size.height * 0.12;
    final Rect rectHud = Rect.fromLTWH(
      0,
      size.height - alturaHud,
      size.width,
      alturaHud,
    );
    canvas.drawRect(
      rectHud,
      Paint()..color = PaletaRotulador.papelSucio,
    );
    // Borde superior a tinta firme.
    canvas.drawLine(
      rectHud.topLeft,
      rectHud.topRight,
      Paint()
        ..color = PaletaRotulador.tinta
        ..strokeWidth = 2.0,
    );
    canvas.drawLine(
      rectHud.topLeft.translate(0, 3),
      rectHud.topRight.translate(0, 3),
      Paint()
        ..color = PaletaRotulador.rojoEstampilla
        ..strokeWidth = 1.0,
    );
    // Remaches decorativos.
    for (int indiceRemache = 0; indiceRemache < 12; indiceRemache++) {
      canvas.drawCircle(
        Offset(
          rectHud.left + 12 + indiceRemache * (rectHud.width - 24) / 11,
          rectHud.top + 9,
        ),
        2.2,
        Paint()..color = PaletaRotulador.tinta,
      );
    }

    // Bloque izquierdo: barra de vida + número grande.
    final double alturaBarraVida = alturaHud * 0.55;
    final Rect rectBarraVida = Rect.fromLTWH(
      rectHud.left + 16,
      rectHud.top + alturaHud * 0.30,
      size.width * 0.16,
      alturaBarraVida,
    );
    canvas.drawRect(
      rectBarraVida,
      Paint()..color = PaletaRotulador.tinta,
    );
    final double fraccionVida = (vidaJugador / 100).clamp(0.0, 1.0);
    // Vida alta = tinta sólida (estado normal); vida baja = rojo alarmante.
    final Color colorBarraVida = fraccionVida > 0.55
        ? PaletaRotulador.tinta
        : fraccionVida > 0.25
            ? PaletaRotulador.tintaDiluida(0.65)
            : PaletaRotulador.rojoEstampilla;
    canvas.drawRect(
      Rect.fromLTWH(rectBarraVida.left, rectBarraVida.top,
          rectBarraVida.width * fraccionVida, rectBarraVida.height),
      Paint()..color = colorBarraVida,
    );
    canvas.drawRect(
      rectBarraVida,
      Paint()
        ..color = PaletaRotulador.papel
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    final pintorEtiquetaVida = TextPainter(
      text: const TextSpan(
        text: 'VIDA',
        style: TextStyle(
          color: PaletaRotulador.papel,
          fontFamily: 'CosmoMono',
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintorEtiquetaVida.paint(
      canvas,
      Offset(rectBarraVida.left,
          rectBarraVida.top - pintorEtiquetaVida.height - 2),
    );
    final pintorNumeroVida = TextPainter(
      text: TextSpan(
        text: '$vidaJugador',
        style: TextStyle(
          color: colorBarraVida,
          fontFamily: 'CosmoMono',
          fontSize: alturaHud * 0.42,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintorNumeroVida.paint(
      canvas,
      Offset(rectBarraVida.right + 10,
          rectBarraVida.center.dy - pintorNumeroVida.height / 2),
    );

    // Centro: cara del cosmonauta reaccionando al daño.
    final Offset centroCara = Offset(
        rectHud.center.dx, rectHud.top + alturaHud * 0.55);
    final double radioCara = alturaHud * 0.42;
    _dibujarCaraCosmonautaHud(canvas, centroCara, radioCara);

    // Bloque derecho: munición.
    final double alturaBarraMunicion = alturaBarraVida;
    final Rect rectBarraMunicion = Rect.fromLTWH(
      rectHud.right - size.width * 0.16 - 16 - 60,
      rectHud.top + alturaHud * 0.30,
      size.width * 0.16,
      alturaBarraMunicion,
    );
    canvas.drawRect(
      rectBarraMunicion,
      Paint()..color = PaletaRotulador.tinta,
    );
    final double fraccionMunicion = (sellosRestantes / 20).clamp(0.0, 1.0);
    canvas.drawRect(
      Rect.fromLTWH(rectBarraMunicion.left, rectBarraMunicion.top,
          rectBarraMunicion.width * fraccionMunicion,
          rectBarraMunicion.height),
      Paint()..color = PaletaRotulador.rojoEstampilla,
    );
    canvas.drawRect(
      rectBarraMunicion,
      Paint()
        ..color = PaletaRotulador.papel
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    final pintorEtiquetaMunicion = TextPainter(
      text: const TextSpan(
        text: 'SELLOS',
        style: TextStyle(
          color: PaletaRotulador.papel,
          fontFamily: 'CosmoMono',
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintorEtiquetaMunicion.paint(
      canvas,
      Offset(rectBarraMunicion.left,
          rectBarraMunicion.top - pintorEtiquetaMunicion.height - 2),
    );
    final pintorNumeroMunicion = TextPainter(
      text: TextSpan(
        text: '$sellosRestantes',
        style: TextStyle(
          color: PaletaRotulador.rojoEstampilla,
          fontFamily: 'CosmoMono',
          fontSize: alturaHud * 0.42,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintorNumeroMunicion.paint(
      canvas,
      Offset(rectBarraMunicion.right + 10,
          rectBarraMunicion.center.dy - pintorNumeroMunicion.height / 2),
    );
  }

  void _dibujarCaraCosmonautaHud(
      Canvas canvas, Offset centroCara, double radioCara) {
    // Marco del retrato.
    canvas.drawRect(
      Rect.fromCenter(
        center: centroCara,
        width: radioCara * 2.4,
        height: radioCara * 2.4,
      ),
      Paint()..color = PaletaRotulador.papel,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: centroCara,
        width: radioCara * 2.4,
        height: radioCara * 2.4,
      ),
      Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Casco (círculo gris claro con visor curvo).
    canvas.drawCircle(
      centroCara,
      radioCara,
      Paint()..color = PaletaRotulador.papel,
    );
    canvas.drawCircle(
      centroCara,
      radioCara,
      Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Visor curvo arriba.
    canvas.drawArc(
      Rect.fromCircle(center: centroCara, radius: radioCara * 0.9),
      math.pi * 1.1,
      math.pi * 0.8,
      false,
      Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = radioCara * 0.18,
    );

    // Estrella roja en la frente del casco.
    _dibujarEstrellaHud(
      canvas,
      centroCara.translate(0, -radioCara * 0.55),
      radioCara * 0.18,
      Paint()..color = PaletaRotulador.rojoEstampilla,
    );

    // Expresión según fracción de vida.
    final double fraccionVida = (vidaJugador / 100).clamp(0.0, 1.0);
    // Ojos.
    final double yOjos = centroCara.dy + radioCara * 0.05;
    final double offsetOjos = radioCara * 0.28;
    if (fraccionVida <= 0) {
      // Muerto: cruces.
      _dibujarCruzOjo(canvas,
          Offset(centroCara.dx - offsetOjos, yOjos), radioCara * 0.10);
      _dibujarCruzOjo(canvas,
          Offset(centroCara.dx + offsetOjos, yOjos), radioCara * 0.10);
    } else {
      // Ojos abiertos. Pupilas pequeñas, miran al centro.
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(centroCara.dx - offsetOjos, yOjos),
            width: radioCara * 0.22,
            height: radioCara * 0.18),
        Paint()..color = PaletaRotulador.papel,
      );
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(centroCara.dx + offsetOjos, yOjos),
            width: radioCara * 0.22,
            height: radioCara * 0.18),
        Paint()..color = PaletaRotulador.papel,
      );
      canvas.drawCircle(
        Offset(centroCara.dx - offsetOjos, yOjos),
        radioCara * 0.06,
        Paint()..color = PaletaRotulador.tinta,
      );
      canvas.drawCircle(
        Offset(centroCara.dx + offsetOjos, yOjos),
        radioCara * 0.06,
        Paint()..color = PaletaRotulador.tinta,
      );
    }

    // Boca según vida.
    final Paint pincelBoca = Paint()
      ..color = PaletaRotulador.tinta
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final Offset centroBoca = centroCara.translate(0, radioCara * 0.45);
    if (fraccionVida <= 0) {
      // Boca recta plana.
      canvas.drawLine(
        centroBoca.translate(-radioCara * 0.30, 0),
        centroBoca.translate(radioCara * 0.30, 0),
        pincelBoca,
      );
    } else if (fraccionVida > 0.75) {
      // Sereno: leve sonrisa.
      canvas.drawArc(
        Rect.fromCenter(
            center: centroBoca,
            width: radioCara * 0.50,
            height: radioCara * 0.18),
        0,
        math.pi,
        false,
        pincelBoca,
      );
    } else if (fraccionVida > 0.50) {
      // Tenso: línea recta.
      canvas.drawLine(
        centroBoca.translate(-radioCara * 0.25, 0),
        centroBoca.translate(radioCara * 0.25, 0),
        pincelBoca,
      );
    } else if (fraccionVida > 0.25) {
      // Herido: mueca hacia abajo.
      canvas.drawArc(
        Rect.fromCenter(
            center: centroBoca.translate(0, radioCara * 0.15),
            width: radioCara * 0.50,
            height: radioCara * 0.30),
        math.pi,
        math.pi,
        false,
        pincelBoca,
      );
    } else {
      // Crítico: boca abierta gritando (óvalo negro).
      canvas.drawOval(
        Rect.fromCenter(
            center: centroBoca,
            width: radioCara * 0.30,
            height: radioCara * 0.40),
        Paint()..color = PaletaRotulador.tinta,
      );
    }

    // Goterón de sangre si está crítico.
    if (fraccionVida <= 0.30 && fraccionVida > 0) {
      final Path camnoGota = Path()
        ..moveTo(centroCara.dx + radioCara * 0.35,
            centroCara.dy - radioCara * 0.15)
        ..lineTo(centroCara.dx + radioCara * 0.35,
            centroCara.dy + radioCara * 0.40)
        ..arcToPoint(
          Offset(centroCara.dx + radioCara * 0.45,
              centroCara.dy + radioCara * 0.40),
          radius: Radius.circular(radioCara * 0.10),
          clockwise: false,
        )
        ..lineTo(centroCara.dx + radioCara * 0.45,
            centroCara.dy - radioCara * 0.10)
        ..close();
      canvas.drawPath(
        camnoGota,
        Paint()..color = PaletaRotulador.rojoEstampilla,
      );
    }
  }

  void _dibujarCruzOjo(Canvas canvas, Offset centro, double tamano) {
    final Paint pincelCruz = Paint()
      ..color = PaletaRotulador.tinta
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      centro.translate(-tamano, -tamano),
      centro.translate(tamano, tamano),
      pincelCruz,
    );
    canvas.drawLine(
      centro.translate(-tamano, tamano),
      centro.translate(tamano, -tamano),
      pincelCruz,
    );
  }

  void _dibujarEstrellaHud(
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

  void _pintarMiniMapa(Canvas canvas, Size size) {
    final double anchoMini = size.width * 0.20;
    final double altoMini = anchoMini * mapa.length / mapa[0].length;
    final Rect rectMini =
        Rect.fromLTWH(size.width - anchoMini - 12, 12, anchoMini, altoMini);
    canvas.drawRect(rectMini,
        Paint()..color = PaletaRotulador.papel.withValues(alpha: 0.90));
    canvas.drawRect(
      rectMini,
      Paint()
        ..color = PaletaRotulador.papel.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    final double anchoCelda = anchoMini / mapa[0].length;
    final double altoCelda = altoMini / mapa.length;
    for (int fila = 0; fila < mapa.length; fila++) {
      for (int columna = 0; columna < mapa[0].length; columna++) {
        final int v = mapa[fila][columna];
        if (v == 0) continue;
        Color colorMini;
        switch (v) {
          case 4:
            colorMini = PaletaRotulador.rojoEstampilla;
            break;
          case 2:
            colorMini = PaletaRotulador.rojoEstampilla;
            break;
          default:
            colorMini = PaletaRotulador.papel.withValues(alpha: 0.6);
        }
        canvas.drawRect(
          Rect.fromLTWH(rectMini.left + columna * anchoCelda,
              rectMini.top + fila * altoCelda, anchoCelda, altoCelda),
          Paint()..color = colorMini,
        );
      }
    }
    // Jugador.
    final Offset puntoJugador = Offset(
      rectMini.left + jugadorX * anchoCelda,
      rectMini.top + jugadorY * altoCelda,
    );
    canvas.drawCircle(puntoJugador, anchoCelda * 0.3,
        Paint()..color = PaletaRotulador.rojoEstampilla);
    canvas.drawLine(
      puntoJugador,
      puntoJugador.translate(
          math.cos(jugadorAngulo) * anchoCelda * 0.7,
          math.sin(jugadorAngulo) * anchoCelda * 0.7),
      Paint()
        ..color = PaletaRotulador.rojoEstampilla
        ..strokeWidth = 1.4,
    );
  }

  @override
  bool shouldRepaint(covariant _PintorVistaDoom viejo) => true;
}

enum _TipoSprite { enemigo, sello }

class _SpriteRender {
  final double posX;
  final double posY;
  final _TipoSprite tipo;
  final Object ref;
  double distancia = 0;

  _SpriteRender({
    required this.posX,
    required this.posY,
    required this.tipo,
    required this.ref,
  });
}

const String _flagHighscoreDoom = 'cosmoom_highscore_';

int _leerHighscoreDoom(EstadoJuego estado) {
  for (final flag in estado.flagsActivos) {
    if (flag.startsWith(_flagHighscoreDoom)) {
      return int.tryParse(flag.substring(_flagHighscoreDoom.length)) ?? 0;
    }
  }
  return 0;
}

void _guardarHighscoreDoom(EstadoJuego estado, int puntuacion) {
  estado.flagsActivos.removeWhere(
    (flag) => flag.startsWith(_flagHighscoreDoom),
  );
  estado.activarFlag('$_flagHighscoreDoom$puntuacion');
}
