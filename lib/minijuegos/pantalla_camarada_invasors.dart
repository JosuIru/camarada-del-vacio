import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../widgets/propaganda_button.dart';
import 'pintor_rotulador.dart';
import 'sprite_cadete.dart';
import 'widget_pausa.dart';

/// CAMARADA INVASORS.
///
/// Versión propia de Space Invaders ambientada en la Guerra Fría:
/// flotilla yanki (Tíos Sam, soldados USA, hamburguesas voladoras)
/// desciende en formación hacia el cadete soviético, que dispara
/// sellos oficiales desde abajo. Tres bunkers de F-447 ofrecen
/// cobertura temporal. Si los yankis tocan el suelo o el cadete
/// pierde sus 3 vidas, victoria para el bloque occidental.
class PantallaCamaradaInvasors extends StatefulWidget {
  final EstadoJuego estado;

  const PantallaCamaradaInvasors({super.key, required this.estado});

  @override
  State<PantallaCamaradaInvasors> createState() =>
      _PantallaCamaradaInvasorsState();
}

class _PantallaCamaradaInvasorsState extends State<PantallaCamaradaInvasors>
    with SingleTickerProviderStateMixin {
  static const double anchoMundo = 1.0;
  static const double altoMundo = 1.0;
  static const int columnasFlota = 10;
  static const int filasFlota = 5;

  late Ticker tickerJuego;
  Duration? marcaTemporalAnterior;
  final FocusNode nodoFoco = FocusNode(debugLabel: 'camarada_invasors');

  Offset posicionCadete = const Offset(0.50, 0.92);
  bool moviendoIzquierda = false;
  bool moviendoDerecha = false;
  bool gatilloMantenido = false;
  double tiempoHastaSiguienteDisparo = 0;
  static const double cooldownDisparo = 0.45;

  final List<_InvasorYanki> flota = <_InvasorYanki>[];
  final List<_DisparoCadete> disparosCadete = <_DisparoCadete>[];
  final List<_DisparoYanki> disparosYanki = <_DisparoYanki>[];
  final List<_BunkerF447> bunkers = <_BunkerF447>[];
  int direccionFlota = 1;
  double velocidadFlota = 0.04;
  double acumuladorDisparoEnemigo = 0;
  // Animacion patas oscilantes de los invasores.
  double faseAnimacionFlota = 0;

  // Nave bonus yanki que cruza la parte superior aleatoriamente.
  double tiempoHastaSiguienteNaveBonus = 14.0;
  double posicionXNaveBonus = -0.2;
  bool naveBonusActiva = false;
  int direccionNaveBonus = 1;
  double faseAnimacionNaveBonus = 0;

  int vidas = 3;
  int puntuacion = 0;
  int oleadaActual = 1;
  bool partidaTerminada = false;
  bool partidaPausada = false;
  bool partidaGanada = false;

  // Banner de oleada que sale al completar una flota.
  String? bannerOleada;
  double tiempoBannerOleadaRestante = 0;
  // Margen superior de arranque de la flota: cada oleada empieza más
  // baja para incrementar la presión.
  double margenSuperiorOleada = 0.10;

  @override
  void initState() {
    super.initState();
    _generarFlota();
    _generarBunkers();
    tickerJuego = createTicker(_alTick)..start();
  }

  @override
  void dispose() {
    tickerJuego.dispose();
    nodoFoco.dispose();
    super.dispose();
  }

  void _generarFlota() {
    flota.clear();
    const double margenLateral = 0.08;
    final double margenSuperior = margenSuperiorOleada;
    final double espacioX =
        (anchoMundo - margenLateral * 2) / (columnasFlota - 1);
    final double espacioY = 0.06;
    for (int fila = 0; fila < filasFlota; fila++) {
      for (int columna = 0; columna < columnasFlota; columna++) {
        final _TipoInvasor tipo;
        if (fila == 0) {
          tipo = _TipoInvasor.tioSam;
        } else if (fila == 1) {
          tipo = _TipoInvasor.soldadoUsa;
        } else if (fila <= 2) {
          tipo = _TipoInvasor.hamburguesa;
        } else {
          tipo = _TipoInvasor.cocaCola;
        }
        flota.add(_InvasorYanki(
          posicion: Offset(
            margenLateral + columna * espacioX,
            margenSuperior + fila * espacioY,
          ),
          tipo: tipo,
          puntos: switch (tipo) {
            _TipoInvasor.tioSam => 300,
            _TipoInvasor.soldadoUsa => 200,
            _TipoInvasor.hamburguesa => 100,
            _TipoInvasor.cocaCola => 50,
          },
        ));
      }
    }
    // Cada oleada empieza más rápida que la anterior, pero con escalada
    // suave (0.010 por oleada) para que el desafío sea progresivo.
    velocidadFlota = 0.04 + (oleadaActual - 1) * 0.010;
    direccionFlota = 1;
  }

  void _avanzarOleada() {
    setState(() {
      oleadaActual += 1;
      // Cada oleada baja más para presionar al cadete.
      margenSuperiorOleada =
          math.min(0.30, 0.10 + (oleadaActual - 1) * 0.025);
      bannerOleada = 'OLEADA $oleadaActual\nGLORIA AL BLOQUE';
      tiempoBannerOleadaRestante = 2.6;
      // Recompensa por completar oleada.
      puntuacion += 200 * oleadaActual;
      _generarFlota();
      _generarBunkers();
    });
  }

  void _generarBunkers() {
    bunkers.clear();
    for (int indice = 0; indice < 3; indice++) {
      bunkers.add(_BunkerF447(
        posicion: Offset(0.20 + indice * 0.30, 0.78),
        anchoBunker: 0.12,
        altoBunker: 0.06,
        integridad: 1.0,
      ));
    }
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

    faseAnimacionFlota = (faseAnimacionFlota + dt * 1.5) % 1.0;
    faseAnimacionNaveBonus = (faseAnimacionNaveBonus + dt * 4.0) % 1.0;
    if (tiempoBannerOleadaRestante > 0) {
      tiempoBannerOleadaRestante -= dt;
      if (tiempoBannerOleadaRestante <= 0) {
        bannerOleada = null;
      }
    }
    tiempoHastaSiguienteDisparo =
        math.max(0, tiempoHastaSiguienteDisparo - dt);

    if (gatilloMantenido) _intentarDispararCadete();

    _moverCadete(dt);
    _moverFlota(dt);
    _moverDisparosCadete(dt);
    _moverDisparosYanki(dt);
    _actualizarNaveBonus(dt);
    _resolverImpactos();
    _gestionarDisparosEnemigos(dt);

    if (flota.isEmpty) {
      _avanzarOleada();
    } else if (flota
        .any((invasor) => invasor.posicion.dy > 0.85)) {
      partidaTerminada = true;
      partidaGanada = false;
      _guardarHighscore();
    }

    setState(() {});
  }

  void _moverCadete(double dt) {
    const double velocidad = 0.55;
    double vx = 0;
    if (moviendoIzquierda && !moviendoDerecha) vx = -velocidad;
    if (moviendoDerecha && !moviendoIzquierda) vx = velocidad;
    posicionCadete = Offset(
      (posicionCadete.dx + vx * dt).clamp(0.05, anchoMundo - 0.05),
      posicionCadete.dy,
    );
  }

  void _moverFlota(double dt) {
    final double avance = velocidadFlota * direccionFlota * dt;
    double minX = double.infinity, maxX = -double.infinity;
    for (final invasor in flota) {
      invasor.posicion = invasor.posicion.translate(avance, 0);
      minX = math.min(minX, invasor.posicion.dx);
      maxX = math.max(maxX, invasor.posicion.dx);
    }
    if (minX < 0.04 || maxX > anchoMundo - 0.04) {
      direccionFlota *= -1;
      for (final invasor in flota) {
        // Bajada gradual: la mitad de antes, para no agobiar.
        invasor.posicion = invasor.posicion.translate(0, 0.015);
      }
      // Cada bajada, la flota acelera muy ligeramente.
      velocidadFlota = math.min(0.22, velocidadFlota * 1.04);
    }
  }

  void _intentarDispararCadete() {
    if (tiempoHastaSiguienteDisparo > 0) return;
    disparosCadete.add(_DisparoCadete(
      posicion: posicionCadete.translate(0, -0.045),
    ));
    tiempoHastaSiguienteDisparo = cooldownDisparo;
  }

  void _moverDisparosCadete(double dt) {
    for (final disparo in disparosCadete) {
      disparo.posicion = disparo.posicion.translate(0, -1.6 * dt);
    }
    disparosCadete.removeWhere((d) => d.posicion.dy < -0.02);
  }

  void _gestionarDisparosEnemigos(double dt) {
    acumuladorDisparoEnemigo += dt;
    // Frecuencia de disparo escala con la flota restante.
    final double frecuencia =
        0.7 + (flota.length / (columnasFlota * filasFlota)) * 1.2;
    if (acumuladorDisparoEnemigo >= frecuencia) {
      acumuladorDisparoEnemigo = 0;
      if (flota.isNotEmpty) {
        final invasor =
            flota[math.Random().nextInt(flota.length)];
        disparosYanki.add(_DisparoYanki(
          posicion: invasor.posicion.translate(0, 0.03),
          velocidad: 0.6 + math.Random().nextDouble() * 0.3,
        ));
      }
    }
  }

  void _moverDisparosYanki(double dt) {
    for (final disparo in disparosYanki) {
      disparo.posicion =
          disparo.posicion.translate(0, disparo.velocidad * dt);
    }
    disparosYanki.removeWhere((d) => d.posicion.dy > 1.02);
  }

  void _actualizarNaveBonus(double dt) {
    if (!naveBonusActiva) {
      tiempoHastaSiguienteNaveBonus -= dt;
      if (tiempoHastaSiguienteNaveBonus <= 0) {
        naveBonusActiva = true;
        // Decide direccion aleatoriamente.
        direccionNaveBonus = math.Random().nextBool() ? 1 : -1;
        posicionXNaveBonus = direccionNaveBonus == 1 ? -0.08 : 1.08;
      }
      return;
    }
    // Velocidad UFO atravesando arriba.
    const double velocidadNaveBonus = 0.28;
    posicionXNaveBonus += direccionNaveBonus * velocidadNaveBonus * dt;
    if (posicionXNaveBonus < -0.10 || posicionXNaveBonus > 1.10) {
      naveBonusActiva = false;
      tiempoHastaSiguienteNaveBonus = 12.0 + math.Random().nextDouble() * 8.0;
    }
  }

  void _resolverImpactos() {
    // Disparos del cadete contra flota.
    for (final disparo in List<_DisparoCadete>.from(disparosCadete)) {
      // Bunker absorbe.
      for (final bunker in bunkers) {
        if (bunker.integridad <= 0) continue;
        final Rect rectB = Rect.fromCenter(
            center: bunker.posicion,
            width: bunker.anchoBunker,
            height: bunker.altoBunker);
        if (rectB.contains(disparo.posicion)) {
          bunker.integridad -= 0.25;
          disparosCadete.remove(disparo);
          break;
        }
      }
      if (!disparosCadete.contains(disparo)) continue;
      // Nave bonus impactada: 500 puntos.
      if (naveBonusActiva) {
        final Offset centroNave = Offset(posicionXNaveBonus, 0.05);
        if ((centroNave - disparo.posicion).distance < 0.05) {
          disparosCadete.remove(disparo);
          naveBonusActiva = false;
          tiempoHastaSiguienteNaveBonus = 14.0 + math.Random().nextDouble() * 6.0;
          puntuacion += 500;
          continue;
        }
      }
      // Yanki impactado.
      for (final invasor in List<_InvasorYanki>.from(flota)) {
        if ((invasor.posicion - disparo.posicion).distance < 0.03) {
          flota.remove(invasor);
          disparosCadete.remove(disparo);
          puntuacion += invasor.puntos;
          break;
        }
      }
    }
    // Disparos yankis contra cadete y bunkers.
    for (final disparo in List<_DisparoYanki>.from(disparosYanki)) {
      for (final bunker in bunkers) {
        if (bunker.integridad <= 0) continue;
        final Rect rectB = Rect.fromCenter(
            center: bunker.posicion,
            width: bunker.anchoBunker,
            height: bunker.altoBunker);
        if (rectB.contains(disparo.posicion)) {
          bunker.integridad -= 0.20;
          disparosYanki.remove(disparo);
          break;
        }
      }
      if (!disparosYanki.contains(disparo)) continue;
      if ((disparo.posicion - posicionCadete).distance < 0.04) {
        disparosYanki.remove(disparo);
        _golpearCadete();
      }
    }
  }

  void _golpearCadete() {
    vidas -= 1;
    if (vidas <= 0) {
      partidaTerminada = true;
      partidaGanada = false;
      _guardarHighscore();
    }
  }

  void _guardarHighscore() {
    final int previo = _leerHighscoreInvasors(widget.estado);
    if (puntuacion > previo) {
      _guardarHighscoreInvasors(widget.estado, puntuacion);
    }
  }

  void _resetear() {
    setState(() {
      posicionCadete = const Offset(0.50, 0.92);
      disparosCadete.clear();
      disparosYanki.clear();
      vidas = 3;
      puntuacion = 0;
      oleadaActual = 1;
      margenSuperiorOleada = 0.10;
      bannerOleada = null;
      tiempoBannerOleadaRestante = 0;
      partidaTerminada = false;
      partidaGanada = false;
      naveBonusActiva = false;
      tiempoHastaSiguienteNaveBonus = 14.0;
      _generarFlota();
      _generarBunkers();
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
    if (tecla == LogicalKeyboardKey.space ||
        tecla == LogicalKeyboardKey.keyJ) {
      gatilloMantenido = esPulsacion;
      if (esLevantamiento) gatilloMantenido = false;
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
    final int mejor = _leerHighscoreInvasors(widget.estado);
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
            semilla: 41,
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
          'CAMARADA INVASORS · DEFENSA COSMO',
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
            _chip('VIDAS', '$vidas'),
            const SizedBox(width: 6),
            _chip('OLEADA', '$oleadaActual', acentuado: true),
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

  Widget _construirMundo() {
    return AspectRatio(
      aspectRatio: anchoMundo / altoMundo,
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
          painter: _PintorMundoInvasors(
            flota: flota,
            disparosCadete: disparosCadete,
            disparosYanki: disparosYanki,
            bunkers: bunkers,
            posicionCadete: posicionCadete,
            faseAnimacionFlota: faseAnimacionFlota,
            naveBonusActiva: naveBonusActiva,
            posicionXNaveBonus: posicionXNaveBonus,
            faseAnimacionNaveBonus: faseAnimacionNaveBonus,
            bannerOleada: bannerOleada,
            tiempoBannerOleadaRestante: tiempoBannerOleadaRestante,
            partidaTerminada: partidaTerminada,
            partidaGanada: partidaGanada,
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
            'OBJETIVOS YANKIS',
            style: TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: PaletaRotulador.rojoEstampilla,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'UFO YANKI     500\n'
            'TÍO SAM       300\n'
            'SOLDADO USA   200\n'
            'HAMBURGUESA   100\n'
            'COCA-COLA      50',
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
            'ESPACIO: disparar\n'
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
            '«Defiende el bloque. Que cada sello sea una respuesta.»',
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

enum _TipoInvasor { tioSam, soldadoUsa, hamburguesa, cocaCola }

class _InvasorYanki {
  Offset posicion;
  final _TipoInvasor tipo;
  final int puntos;

  _InvasorYanki({
    required this.posicion,
    required this.tipo,
    required this.puntos,
  });
}

class _DisparoCadete {
  Offset posicion;
  _DisparoCadete({required this.posicion});
}

class _DisparoYanki {
  Offset posicion;
  double velocidad;
  _DisparoYanki({required this.posicion, required this.velocidad});
}

class _BunkerF447 {
  final Offset posicion;
  final double anchoBunker;
  final double altoBunker;
  double integridad;
  _BunkerF447({
    required this.posicion,
    required this.anchoBunker,
    required this.altoBunker,
    required this.integridad,
  });
}

class _PintorMundoInvasors extends CustomPainter {
  final List<_InvasorYanki> flota;
  final List<_DisparoCadete> disparosCadete;
  final List<_DisparoYanki> disparosYanki;
  final List<_BunkerF447> bunkers;
  final Offset posicionCadete;
  final double faseAnimacionFlota;
  final bool naveBonusActiva;
  final double posicionXNaveBonus;
  final double faseAnimacionNaveBonus;
  final String? bannerOleada;
  final double tiempoBannerOleadaRestante;
  final bool partidaTerminada;
  final bool partidaGanada;

  _PintorMundoInvasors({
    required this.flota,
    required this.disparosCadete,
    required this.disparosYanki,
    required this.bunkers,
    required this.posicionCadete,
    required this.faseAnimacionFlota,
    required this.naveBonusActiva,
    required this.posicionXNaveBonus,
    required this.faseAnimacionNaveBonus,
    required this.bannerOleada,
    required this.tiempoBannerOleadaRestante,
    required this.partidaTerminada,
    required this.partidaGanada,
  });

  Offset _r(Offset p, Size size) =>
      Offset(p.dx * size.width, p.dy * size.height);

  @override
  void paint(Canvas canvas, Size size) {
    // Fondo papel viejo con micro-puntitos (estrellas a tinta).
    canvas.drawRect(Offset.zero & size,
        Paint()..color = PaletaRotulador.papel);
    final math.Random rngEstrellas = math.Random(31);
    for (int indice = 0; indice < 90; indice++) {
      canvas.drawCircle(
        Offset(rngEstrellas.nextDouble() * size.width,
            rngEstrellas.nextDouble() * size.height),
        0.6 + rngEstrellas.nextDouble() * 0.7,
        Paint()
          ..color = PaletaRotulador.tintaDiluida(0.30),
      );
    }

    // Suelo: línea de tierra del cadete (tinta, no rojo).
    canvas.drawLine(
      Offset(0, _r(const Offset(0, 0.95), size).dy),
      Offset(size.width, _r(const Offset(0, 0.95), size).dy),
      Paint()
        ..color = PaletaRotulador.tinta
        ..strokeWidth = 2,
    );

    // Nave UFO yanki bonus cruzando arriba.
    if (naveBonusActiva) {
      _dibujarNaveBonus(canvas, size);
    }

    // Bunkers F-447.
    for (final bunker in bunkers) {
      if (bunker.integridad <= 0) continue;
      final Offset centroPx = _r(bunker.posicion, size);
      final double anchoPx = bunker.anchoBunker * size.width;
      final double altoPx = bunker.altoBunker * size.height;
      final double alphaBunker = (bunker.integridad).clamp(0.2, 1.0);
      final Rect rectBunker =
          Rect.fromCenter(center: centroPx, width: anchoPx, height: altoPx);
      canvas.drawRect(
        rectBunker,
        Paint()
          ..color = PaletaRotulador.papelSucio.withValues(alpha: alphaBunker),
      );
      canvas.drawRect(
        Rect.fromLTWH(rectBunker.left, rectBunker.top,
            rectBunker.width, rectBunker.height * 0.22),
        Paint()
          ..color = PaletaRotulador.rojoEstampilla
              .withValues(alpha: alphaBunker),
      );
      canvas.drawRect(
        rectBunker,
        Paint()
          ..color = PaletaRotulador.tinta.withValues(alpha: alphaBunker)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
      final pintor = TextPainter(
        text: TextSpan(
          text: 'F-447',
          style: TextStyle(
            color:
                PaletaRotulador.tinta.withValues(alpha: alphaBunker),
            fontFamily: 'CosmoMono',
            fontSize: math.max(8, altoPx * 0.35),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      pintor.paint(
        canvas,
        Offset(centroPx.dx - pintor.width / 2,
            centroPx.dy - pintor.height / 2 + altoPx * 0.12),
      );
    }

    // Invasores.
    for (final invasor in flota) {
      _dibujarInvasorYanki(canvas, invasor, size);
    }

    // Disparos cadete: pequeños sellos rojos verticales.
    for (final disparo in disparosCadete) {
      final Offset centroPx = _r(disparo.posicion, size);
      canvas.drawRect(
        Rect.fromCenter(
            center: centroPx,
            width: size.width * 0.008,
            height: size.height * 0.028),
        Paint()..color = PaletaRotulador.rojoEstampilla,
      );
      canvas.drawCircle(
        centroPx.translate(0, -size.height * 0.012),
        size.width * 0.010,
        Paint()..color = PaletaRotulador.rojoEstampilla,
      );
    }

    // Disparos yanki: rayos zig-zag azules.
    for (final disparo in disparosYanki) {
      final Offset centroPx = _r(disparo.posicion, size);
      final Path camino = Path()
        ..moveTo(centroPx.dx, centroPx.dy - size.height * 0.02)
        ..lineTo(centroPx.dx - size.width * 0.006,
            centroPx.dy - size.height * 0.008)
        ..lineTo(centroPx.dx + size.width * 0.006,
            centroPx.dy + size.height * 0.008)
        ..lineTo(centroPx.dx, centroPx.dy + size.height * 0.02);
      canvas.drawPath(
        camino,
        Paint()
          ..color = PaletaRotulador.tinta
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4,
      );
    }

    // Cadete defensor abajo.
    final Offset centroCadete = _r(posicionCadete, size);
    dibujarCadeteCosmonauta(
      canvas,
      centro: centroCadete,
      alto: size.height * 0.22,
      direccionMira: 0,
      pose: PoseCadeteMinijuego.disparando,
      fasePaso: 0,
    );

    // Banner de oleada (fade in/out).
    final String? bannerActual = bannerOleada;
    if (bannerActual != null && tiempoBannerOleadaRestante > 0) {
      final double progresoBanner =
          (tiempoBannerOleadaRestante / 2.6).clamp(0.0, 1.0);
      final double opacidadBanner = progresoBanner < 0.20
          ? progresoBanner / 0.20
          : progresoBanner > 0.85
              ? (1.0 - progresoBanner) / 0.15
              : 1.0;
      // Estampilla central con texto de oleada.
      estampillaRoja(
        canvas,
        posicion: Offset(size.width / 2, size.height * 0.40),
        texto: bannerActual,
        anchoEstampilla: size.width * 0.70,
        altoEstampilla: size.height * 0.18,
        rotacionRadianes: -0.04,
        opacidad: opacidadBanner.clamp(0.0, 1.0),
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
              ? '★ VICTORIA SOVIÉTICA ★\nFLOTA YANKI DESARTICULADA\nPULSA ENTER'
              : 'EL BLOQUE ORIENTAL CEDE\nPULSA ENTER PARA REINTENTAR',
          style: TextStyle(
            color: partidaGanada
                ? PaletaRotulador.tinta
                : PaletaRotulador.rojoEstampilla,
            fontFamily: 'CosmoMono',
            fontSize: size.width * 0.038,
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

  void _dibujarNaveBonus(Canvas canvas, Size size) {
    final Offset centroNave = Offset(
      posicionXNaveBonus * size.width,
      0.05 * size.height,
    );
    final double anchoNave = size.width * 0.10;
    final double altoNave = size.height * 0.035;

    // Cuerpo disco platillo: papel con borde tinta + rayado paralelo.
    final Rect rectPlatillo = Rect.fromCenter(
        center: centroNave, width: anchoNave, height: altoNave);
    canvas.drawOval(
      rectPlatillo,
      Paint()..color = PaletaRotulador.papel,
    );
    rayadoParalelo(
      canvas,
      rectPlatillo,
      pincel: Paint()
        ..color = PaletaRotulador.tintaDiluida(0.45)
        ..strokeWidth = 0.8,
      espaciado: math.max(2.0, altoNave * 0.30),
      intensidadJitter: 0.2,
    );
    canvas.drawOval(
      rectPlatillo,
      Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Cúpula superior a tinta.
    final Rect rectCupula = Rect.fromCenter(
      center: centroNave.translate(0, -altoNave * 0.55),
      width: anchoNave * 0.45,
      height: altoNave * 1.2,
    );
    canvas.drawArc(
      rectCupula,
      math.pi,
      math.pi,
      false,
      Paint()..color = PaletaRotulador.tinta,
    );
    canvas.drawArc(
      rectCupula,
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Puntito de papel en cúpula.
    canvas.drawCircle(
      centroNave.translate(0, -altoNave * 0.55),
      anchoNave * 0.025,
      Paint()..color = PaletaRotulador.papel,
    );

    // Luces parpadeantes bajo el platillo (rojas o tinta).
    final bool luzEncendida = faseAnimacionNaveBonus < 0.5;
    for (int indiceLuz = 0; indiceLuz < 5; indiceLuz++) {
      final double offsetLuzX =
          (indiceLuz - 2) * anchoNave * 0.20;
      final Color colorLuzNeon = (indiceLuz.isEven == luzEncendida)
          ? PaletaRotulador.rojoEstampilla
          : PaletaRotulador.tinta;
      canvas.drawCircle(
        centroNave.translate(offsetLuzX, altoNave * 0.45),
        anchoNave * 0.025,
        Paint()..color = colorLuzNeon,
      );
    }

    // Texto "USA" pequeño en el cuerpo a tinta.
    final pintorEtiqueta = TextPainter(
      text: TextSpan(
        text: 'USA',
        style: TextStyle(
          color: PaletaRotulador.papel,
          fontFamily: 'CosmoMono',
          fontSize: math.max(7, altoNave * 0.5),
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintorEtiqueta.paint(
      canvas,
      Offset(centroNave.dx - pintorEtiqueta.width / 2,
          centroNave.dy - pintorEtiqueta.height / 2),
    );

    // Texto "+500" oscilante encima invitando a disparar.
    final pintorBonus = TextPainter(
      text: TextSpan(
        text: '+500',
        style: TextStyle(
          color: PaletaRotulador.rojoEstampilla.withValues(
              alpha: luzEncendida ? 1.0 : 0.55),
          fontFamily: 'CosmoMono',
          fontSize: math.max(9, altoNave * 0.7),
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintorBonus.paint(
      canvas,
      Offset(centroNave.dx - pintorBonus.width / 2,
          centroNave.dy - altoNave * 1.5),
    );
  }

  void _dibujarInvasorYanki(
      Canvas canvas, _InvasorYanki invasor, Size size) {
    final Offset centro = _r(invasor.posicion, size);
    final double escala = size.width * 0.032;
    final bool patasAlt = faseAnimacionFlota < 0.5;
    final double desplazaPatas = patasAlt ? -escala * 0.10 : escala * 0.10;

    final Paint pincelTrazo = Paint()
      ..color = PaletaRotulador.tinta
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    switch (invasor.tipo) {
      case _TipoInvasor.tioSam:
        // Tío Sam: cara papel, sombrero alto tinta, banda roja, barba a
        // tinta diluida.
        final Offset centroCabeza = centro.translate(0, -escala * 0.15);
        canvas.drawCircle(centroCabeza, escala * 0.5,
            Paint()..color = PaletaRotulador.papel);
        canvas.drawCircle(centroCabeza, escala * 0.5, pincelTrazo);
        // Barba: arco rayado.
        rayadoParalelo(
          canvas,
          Rect.fromCenter(
              center: centroCabeza.translate(0, escala * 0.30),
              width: escala * 0.85,
              height: escala * 0.40),
          pincel: Paint()
            ..color = PaletaRotulador.tintaDiluida(0.55)
            ..strokeWidth = 0.7,
          espaciado: math.max(2.0, escala * 0.10),
          intensidadJitter: 0.2,
        );
        // Sombrero alto: tinta.
        canvas.drawRect(
          Rect.fromCenter(
              center: centroCabeza.translate(0, -escala * 0.75),
              width: escala * 0.8,
              height: escala * 0.7),
          Paint()..color = PaletaRotulador.tinta,
        );
        canvas.drawRect(
          Rect.fromCenter(
              center: centroCabeza.translate(0, -escala * 0.40),
              width: escala * 1.15,
              height: escala * 0.16),
          Paint()..color = PaletaRotulador.tinta,
        );
        // Banda blanca con estrella.
        canvas.drawRect(
          Rect.fromCenter(
              center: centroCabeza.translate(0, -escala * 0.50),
              width: escala * 0.8,
              height: escala * 0.16),
          Paint()..color = PaletaRotulador.papel,
        );
        // Banda inferior roja (la única nota de color).
        canvas.drawRect(
          Rect.fromCenter(
              center: centroCabeza.translate(0, -escala * 0.95),
              width: escala * 0.8,
              height: escala * 0.16),
          Paint()..color = PaletaRotulador.rojoEstampilla,
        );
        // Brazos apuntando hacia el cadete.
        canvas.drawLine(
          centroCabeza.translate(-escala * 0.30, escala * 0.50),
          centroCabeza.translate(-escala * 0.50,
              escala * 0.85 + desplazaPatas),
          pincelTrazo,
        );
        canvas.drawLine(
          centroCabeza.translate(escala * 0.30, escala * 0.50),
          centroCabeza.translate(escala * 0.50,
              escala * 0.85 - desplazaPatas),
          pincelTrazo,
        );
        break;
      case _TipoInvasor.soldadoUsa:
        // Soldado USA: papel cara + casco tinta + estrella roja en frente
        // + jacket tinta con cruz de papel.
        final Offset centroCabeza = centro.translate(0, -escala * 0.10);
        canvas.drawCircle(
          centroCabeza,
          escala * 0.45,
          Paint()..color = PaletaRotulador.papel,
        );
        canvas.drawCircle(centroCabeza, escala * 0.45, pincelTrazo);
        // Casco curvo a tinta.
        canvas.drawArc(
          Rect.fromCircle(
              center: centroCabeza, radius: escala * 0.55),
          math.pi,
          math.pi,
          true,
          Paint()..color = PaletaRotulador.tinta,
        );
        canvas.drawArc(
          Rect.fromCircle(
              center: centroCabeza, radius: escala * 0.55),
          math.pi,
          math.pi,
          false,
          pincelTrazo,
        );
        // Estrella roja en el casco (nota de color).
        canvas.drawCircle(
          centroCabeza.translate(0, -escala * 0.35),
          escala * 0.10,
          Paint()..color = PaletaRotulador.rojoEstampilla,
        );
        // Cuerpo: jacket cuadrada a tinta con cruz de papel.
        final Rect rectCuerpoSoldado = Rect.fromCenter(
            center: centro.translate(0, escala * 0.60),
            width: escala * 0.9,
            height: escala * 0.7);
        canvas.drawRect(
          rectCuerpoSoldado,
          Paint()..color = PaletaRotulador.tinta,
        );
        // Pequeña cruz blanca de identificación.
        canvas.drawLine(
          rectCuerpoSoldado.center.translate(0, -escala * 0.15),
          rectCuerpoSoldado.center.translate(0, escala * 0.15),
          Paint()
            ..color = PaletaRotulador.papel
            ..strokeWidth = 2,
        );
        canvas.drawLine(
          rectCuerpoSoldado.center.translate(-escala * 0.15, 0),
          rectCuerpoSoldado.center.translate(escala * 0.15, 0),
          Paint()
            ..color = PaletaRotulador.papel
            ..strokeWidth = 2,
        );
        canvas.drawRect(rectCuerpoSoldado, pincelTrazo);
        break;
      case _TipoInvasor.hamburguesa:
        // Hamburguesa: silueta tinta sobre papel. Sin colores carne/queso.
        canvas.drawArc(
          Rect.fromCircle(center: centro, radius: escala * 0.6),
          math.pi,
          math.pi,
          false,
          Paint()..color = PaletaRotulador.papel..style = PaintingStyle.fill,
        );
        canvas.drawArc(
          Rect.fromCircle(center: centro, radius: escala * 0.6),
          math.pi,
          math.pi,
          false,
          pincelTrazo,
        );
        // Capa central tinta (la "carne").
        canvas.drawRect(
          Rect.fromCenter(
              center: centro,
              width: escala * 1.2,
              height: escala * 0.18),
          Paint()..color = PaletaRotulador.tinta,
        );
        // Capa "lechuga": rayado tembloroso.
        for (int indiceOnda = 0; indiceOnda < 5; indiceOnda++) {
          final double xLecho = centro.dx + (indiceOnda - 2) * escala * 0.25;
          canvas.drawLine(
            Offset(xLecho - escala * 0.10, centro.dy + escala * 0.16),
            Offset(xLecho + escala * 0.10, centro.dy + escala * 0.22),
            pincelTrazo,
          );
        }
        // Pan inferior.
        canvas.drawArc(
          Rect.fromCircle(
              center: centro.translate(0, escala * 0.35),
              radius: escala * 0.55),
          0,
          math.pi,
          false,
          Paint()..color = PaletaRotulador.papel,
        );
        canvas.drawArc(
          Rect.fromCircle(
              center: centro.translate(0, escala * 0.35),
              radius: escala * 0.55),
          0,
          math.pi,
          false,
          pincelTrazo,
        );
        // Semillas de sésamo a tinta.
        for (int indiceSemilla = 0; indiceSemilla < 4; indiceSemilla++) {
          canvas.drawCircle(
            centro.translate(
                (indiceSemilla - 1.5) * escala * 0.25,
                -escala * 0.25 +
                    (indiceSemilla.isEven ? -1 : 1) * escala * 0.05),
            escala * 0.06,
            Paint()..color = PaletaRotulador.tinta,
          );
        }
        break;
      case _TipoInvasor.cocaCola:
        // Botella: silueta a tinta sobre papel + etiqueta roja.
        final Path camino = Path()
          ..moveTo(centro.dx - escala * 0.18, centro.dy - escala * 0.6)
          ..lineTo(centro.dx + escala * 0.18, centro.dy - escala * 0.6)
          ..lineTo(centro.dx + escala * 0.18, centro.dy - escala * 0.30)
          ..lineTo(centro.dx + escala * 0.35, centro.dy - escala * 0.10)
          ..lineTo(centro.dx + escala * 0.35, centro.dy + escala * 0.60)
          ..lineTo(centro.dx - escala * 0.35, centro.dy + escala * 0.60)
          ..lineTo(centro.dx - escala * 0.35, centro.dy - escala * 0.10)
          ..lineTo(centro.dx - escala * 0.18, centro.dy - escala * 0.30)
          ..close();
        canvas.drawPath(
          camino,
          Paint()..color = PaletaRotulador.tinta,
        );
        canvas.drawPath(camino, pincelTrazo);
        // Etiqueta roja en el centro.
        canvas.drawRect(
          Rect.fromCenter(
              center: centro.translate(0, escala * 0.20),
              width: escala * 0.6,
              height: escala * 0.30),
          Paint()..color = PaletaRotulador.rojoEstampilla,
        );
        // Caligrafía blanca abstracta sobre la etiqueta.
        canvas.drawLine(
          centro.translate(-escala * 0.18, escala * 0.20),
          centro.translate(escala * 0.18, escala * 0.20),
          Paint()
            ..color = PaletaRotulador.papel
            ..strokeWidth = 1.4,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _PintorMundoInvasors viejo) => true;
}

const String _flagHighscoreInvasors = 'invasors_highscore_';

int _leerHighscoreInvasors(EstadoJuego estado) {
  for (final flag in estado.flagsActivos) {
    if (flag.startsWith(_flagHighscoreInvasors)) {
      return int.tryParse(flag.substring(_flagHighscoreInvasors.length)) ?? 0;
    }
  }
  return 0;
}

void _guardarHighscoreInvasors(EstadoJuego estado, int puntuacion) {
  estado.flagsActivos.removeWhere(
    (flag) => flag.startsWith(_flagHighscoreInvasors),
  );
  estado.activarFlag('$_flagHighscoreInvasors$puntuacion');
}
