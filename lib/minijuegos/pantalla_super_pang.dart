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
import '../widgets/breathing_stick_figure.dart';
import '../painters/stick_figure_painter.dart';

/// SUPER PANG GALÁCTICO — Operación Cápsula F-447.
///
/// El cadete dispara cuerdas-visado verticales para reventar globos
/// burocráticos llenos de F-447 que rebotan por la antecámara. Cada
/// globo grande se divide en dos al recibir impacto, hasta que los
/// más pequeños desaparecen del todo. Mecánica clásica de Pang!
/// adaptada a la estética cosmosoviética rotulador.
class PantallaSuperPangGalactico extends StatefulWidget {
  final EstadoJuego estado;

  const PantallaSuperPangGalactico({super.key, required this.estado});

  @override
  State<PantallaSuperPangGalactico> createState() =>
      _PantallaSuperPangGalacticoState();
}

class _PantallaSuperPangGalacticoState extends State<PantallaSuperPangGalactico>
    with SingleTickerProviderStateMixin {
  // Mundo en coordenadas relativas 0..1.
  static const double anchoMundo = 1.0;
  static const double sueloY = 0.92;
  static const double techoY = 0.04;

  // Cadete.
  static const double radioCadete = 0.025;
  static const double velocidadCadeteMax = 0.55;
  double cadeteX = 0.5;
  double velocidadCadete = 0.0;
  bool moviendoIzquierda = false;
  bool moviendoDerecha = false;
  int direccionMira = 1;
  double fasePaso = 0.0;
  bool cadeteEstaDisparando = false;
  double tiempoPoseDisparo = 0;

  // Cuerda (1 sola activa a la vez = Pang clásico).
  bool cuerdaActiva = false;
  double cuerdaTopY = sueloY;
  double cuerdaX = 0.5;
  static const double velocidadCuerda = 1.4;

  // Globos.
  final List<_GloboBurocratico> globos = <_GloboBurocratico>[];
  final math.Random rng = math.Random();

  // Físicas globo: gravedad y velocidad moderadas para que los
  // globos sean legibles y permitan apuntar con calma.
  static const double gravedadGlobo = 0.42;
  static const double reboteSuelo = 1.0;

  // HUD.
  int vidas = 3;
  int puntos = 0;
  int nivelActual = 1;
  bool partidaPausada = false;
  bool partidaTerminada = false;
  bool partidaGanada = false;
  double tiempoInvulnerable = 0.0;

  // Banner de nivel.
  String? bannerNivel;
  double tiempoBannerRestante = 0;

  late Ticker tickerJuego;
  Duration? marcaTemporalAnterior;
  final FocusNode nodoFoco =
      FocusNode(debugLabel: 'super_pang_galactico');

  // Sprites de §21 — cableado anticipado.
  ui.Image? imagenGloboGrande; // §21.1 (280×280)
  ui.Image? imagenGloboMedio; // §21.1 (200×200)
  ui.Image? imagenGloboPequeno; // §21.1 (120×120)
  ui.Image? imagenArpon; // §21.2
  ui.Image? imagenBannerNivel; // §21.3

  @override
  void initState() {
    super.initState();
    _generarNivel();
    tickerJuego = createTicker(_alTick)..start();
    _cargarSprites();
  }

  Future<void> _cargarSprites() async {
    final resultados = await cargarLoteOpcional(<String>[
      'assets/svg/pang_globo_grande.png',
      'assets/svg/pang_globo_medio.png',
      'assets/svg/pang_globo_pequeno.png',
      'assets/svg/pang_arpon.png',
      'assets/svg/pang_banner_nivel.png',
    ]);
    if (!mounted) return;
    setState(() {
      imagenGloboGrande = resultados[0];
      imagenGloboMedio = resultados[1];
      imagenGloboPequeno = resultados[2];
      imagenArpon = resultados[3];
      imagenBannerNivel = resultados[4];
    });
  }

  @override
  void dispose() {
    tickerJuego.dispose();
    nodoFoco.dispose();
    super.dispose();
  }

  void _generarNivel() {
    globos.clear();
    cuerdaActiva = false;
    cadeteX = 0.5;
    velocidadCadete = 0;
    tiempoInvulnerable = 1.4;
    bannerNivel = 'NIVEL $nivelActual\nGLOBOS F-447';
    tiempoBannerRestante = 2.0;
    // Distribución de globos según el nivel.
    final int cantidadGrandes = nivelActual < 3
        ? 2
        : nivelActual < 5
            ? 3
            : 4;
    for (int i = 0; i < cantidadGrandes; i++) {
      final double x = 0.15 + i * (0.70 / math.max(1, cantidadGrandes - 1));
      globos.add(_GloboBurocratico(
        posicion: Offset(x, 0.20),
        velocidad: Offset(
          (rng.nextBool() ? 1 : -1) * (0.18 + rng.nextDouble() * 0.04),
          0.0,
        ),
        tamano: 3, // XL
      ));
    }
    // En niveles altos añadimos un par extra de tamaño L.
    if (nivelActual >= 4) {
      globos.add(_GloboBurocratico(
        posicion: const Offset(0.30, 0.40),
        velocidad: const Offset(0.22, 0),
        tamano: 2,
      ));
      globos.add(_GloboBurocratico(
        posicion: const Offset(0.70, 0.40),
        velocidad: const Offset(-0.22, 0),
        tamano: 2,
      ));
    }
  }

  void _alTick(Duration tiempoAcumulado) {
    if (!mounted) return;
    final marcaAnterior = marcaTemporalAnterior;
    marcaTemporalAnterior = tiempoAcumulado;
    if (marcaAnterior == null) return;
    final double dt =
        (tiempoAcumulado - marcaAnterior).inMicroseconds / 1e6;
    if (dt <= 0) return;
    if (partidaPausada || partidaTerminada) return;

    // Subdividir dt en sub-pasos para evitar tunneling de globos.
    const double dtMax = 0.020;
    final int subPasos = math.max(1, (dt / dtMax).ceil());
    final double dtSub = dt / subPasos;
    for (int i = 0; i < subPasos; i++) {
      _pasoFisica(dtSub);
    }

    if (tiempoBannerRestante > 0) {
      tiempoBannerRestante -= dt;
      if (tiempoBannerRestante <= 0) {
        bannerNivel = null;
      }
    }
    if (tiempoInvulnerable > 0) {
      tiempoInvulnerable -= dt;
      if (tiempoInvulnerable < 0) tiempoInvulnerable = 0;
    }
    if (tiempoPoseDisparo > 0) {
      tiempoPoseDisparo -= dt;
      if (tiempoPoseDisparo <= 0) {
        cadeteEstaDisparando = false;
      }
    }

    // Comprueba fin de nivel: todos los globos reventados.
    if (globos.isEmpty) {
      if (nivelActual >= 5) {
        partidaTerminada = true;
        partidaGanada = true;
        _guardarHighscore();
      } else {
        nivelActual += 1;
        _generarNivel();
      }
    }

    setState(() {});
  }

  void _pasoFisica(double dt) {
    // Mover cadete con aceleración/inercia mínima (no se patina).
    double objetivo = 0;
    if (moviendoIzquierda && !moviendoDerecha) {
      objetivo = -velocidadCadeteMax;
      direccionMira = -1;
    } else if (moviendoDerecha && !moviendoIzquierda) {
      objetivo = velocidadCadeteMax;
      direccionMira = 1;
    }
    velocidadCadete = objetivo;
    cadeteX = (cadeteX + velocidadCadete * dt)
        .clamp(radioCadete + 0.01, anchoMundo - radioCadete - 0.01);
    if (objetivo != 0) {
      fasePaso = (fasePaso + dt * 1.6) % 1.0;
    }

    // Mover cuerda.
    if (cuerdaActiva) {
      cuerdaTopY -= velocidadCuerda * dt;
      if (cuerdaTopY < techoY) {
        cuerdaActiva = false;
      }
    }

    // Mover globos: gravedad + rebote suelo/paredes/techo.
    for (final globo in globos) {
      globo.velocidad = Offset(
        globo.velocidad.dx,
        globo.velocidad.dy + gravedadGlobo * dt,
      );
      Offset nueva = globo.posicion + globo.velocidad * dt;
      final double r = globo.radio;
      // Rebote paredes.
      if (nueva.dx - r < 0) {
        nueva = Offset(r, nueva.dy);
        globo.velocidad =
            Offset(-globo.velocidad.dx, globo.velocidad.dy);
      } else if (nueva.dx + r > anchoMundo) {
        nueva = Offset(anchoMundo - r, nueva.dy);
        globo.velocidad =
            Offset(-globo.velocidad.dx, globo.velocidad.dy);
      }
      // Rebote techo.
      if (nueva.dy - r < techoY) {
        nueva = Offset(nueva.dx, techoY + r);
        globo.velocidad =
            Offset(globo.velocidad.dx, globo.velocidad.dy.abs());
      }
      // Rebote suelo: velocidad vertical constante por tamaño (Pang
      // clásico: globos no se amortiguan).
      if (nueva.dy + r > sueloY) {
        nueva = Offset(nueva.dx, sueloY - r);
        final double velReboteVertical =
            _velocidadReboteSuelo(globo.tamano);
        globo.velocidad =
            Offset(globo.velocidad.dx, -velReboteVertical * reboteSuelo);
      }
      globo.posicion = nueva;
      globo.faseAnimacion += dt * 2.4;
    }

    // Colisión cuerda <-> globo: la cuerda es una línea vertical
    // entre (cuerdaX, cuerdaTopY) y (cuerdaX, sueloY). Comprobamos
    // si el círculo del globo intersecta esa línea — así no se nos
    // escapa un globo aunque vaya rápido. Iteramos sobre una copia
    // para que `_reventarGlobo` (que muta `globos`) sea seguro.
    if (cuerdaActiva) {
      _GloboBurocratico? globoAlcanzado;
      for (final globo in List<_GloboBurocratico>.from(globos)) {
        final double r = globo.radio;
        final double dx = (globo.posicion.dx - cuerdaX).abs();
        if (dx > r) continue;
        // El segmento de la cuerda en Y va de cuerdaTopY (alto) a
        // sueloY (bajo). El globo está en globo.posicion.dy.
        final double yMin = cuerdaTopY;
        final double yMax = sueloY;
        if (globo.posicion.dy + r >= yMin &&
            globo.posicion.dy - r <= yMax) {
          globoAlcanzado = globo;
          break;
        }
      }
      if (globoAlcanzado != null) {
        _reventarGlobo(globoAlcanzado);
        cuerdaActiva = false;
      }
    }

    // Colisión cadete <-> globo (vida perdida). Iteración sobre
    // copia: defensiva contra futuras mutaciones intra-bucle.
    if (tiempoInvulnerable <= 0) {
      for (final globo in List<_GloboBurocratico>.from(globos)) {
        final double dx = globo.posicion.dx - cadeteX;
        final double dy = globo.posicion.dy - sueloY + radioCadete * 2.5;
        final double distancia = math.sqrt(dx * dx + dy * dy);
        if (distancia < globo.radio + radioCadete * 1.4) {
          vidas -= 1;
          tiempoInvulnerable = 2.0;
          if (vidas <= 0) {
            partidaTerminada = true;
            partidaGanada = false;
            _guardarHighscore();
          }
          break;
        }
      }
    }
  }

  /// Velocidad vertical inicial al rebotar en suelo. Pang clásico:
  /// globos rebotan al ritmo de su tamaño (los grandes saltan más alto).
  double _velocidadReboteSuelo(int tamano) {
    switch (tamano) {
      case 3:
        return 0.88;
      case 2:
        return 0.78;
      case 1:
        return 0.70;
      default:
        return 0.62;
    }
  }

  void _reventarGlobo(_GloboBurocratico globo) {
    final int tamano = globo.tamano;
    final int puntosGanados = (4 - tamano) * 50;
    puntos += puntosGanados;
    globos.remove(globo);
    if (tamano > 0) {
      // Divide en 2 globos del tamaño inmediatamente menor: uno a
      // cada lado, con la velocidad horizontal espejada.
      final int nuevoTamano = tamano - 1;
      final double velocidadInicial = 0.20 + 0.04 * nuevoTamano;
      final double velReboteY = _velocidadReboteSuelo(nuevoTamano);
      globos.add(_GloboBurocratico(
        posicion: globo.posicion,
        velocidad: Offset(-velocidadInicial, -velReboteY * 0.65),
        tamano: nuevoTamano,
      ));
      globos.add(_GloboBurocratico(
        posicion: globo.posicion,
        velocidad: Offset(velocidadInicial, -velReboteY * 0.65),
        tamano: nuevoTamano,
      ));
    }
  }

  void _intentarDisparar() {
    if (cuerdaActiva || partidaTerminada || partidaPausada) return;
    cuerdaActiva = true;
    cuerdaX = cadeteX;
    cuerdaTopY = sueloY - radioCadete * 2.0;
    cadeteEstaDisparando = true;
    tiempoPoseDisparo = 0.20;
  }

  void _reiniciar() {
    setState(() {
      vidas = 3;
      puntos = 0;
      nivelActual = 1;
      partidaTerminada = false;
      partidaGanada = false;
      partidaPausada = false;
      _generarNivel();
    });
  }

  static const String _flagHighscore = 'super_pang_highscore_';

  int _leerHighscore() {
    for (final flag in widget.estado.flagsActivos) {
      if (flag.startsWith(_flagHighscore)) {
        return int.tryParse(flag.substring(_flagHighscore.length)) ?? 0;
      }
    }
    return 0;
  }

  void _guardarHighscore() {
    final int previo = _leerHighscore();
    if (puntos > previo) {
      widget.estado.flagsActivos.removeWhere(
        (flag) => flag.startsWith(_flagHighscore),
      );
      widget.estado.activarFlag('$_flagHighscore$puntos');
    }
  }

  KeyEventResult _alEventoTeclado(FocusNode nodo, KeyEvent evento) {
    if (evento is KeyDownEvent) {
      final tecla = evento.logicalKey;
      if (tecla == LogicalKeyboardKey.keyA ||
          tecla == LogicalKeyboardKey.arrowLeft) {
        moviendoIzquierda = true;
        return KeyEventResult.handled;
      }
      if (tecla == LogicalKeyboardKey.keyD ||
          tecla == LogicalKeyboardKey.arrowRight) {
        moviendoDerecha = true;
        return KeyEventResult.handled;
      }
      if (tecla == LogicalKeyboardKey.space ||
          tecla == LogicalKeyboardKey.keyW ||
          tecla == LogicalKeyboardKey.arrowUp) {
        _intentarDisparar();
        return KeyEventResult.handled;
      }
      if (tecla == LogicalKeyboardKey.keyP) {
        setState(() => partidaPausada = !partidaPausada);
        return KeyEventResult.handled;
      }
      if (tecla == LogicalKeyboardKey.keyR && partidaTerminada) {
        _reiniciar();
        return KeyEventResult.handled;
      }
    } else if (evento is KeyUpEvent) {
      final tecla = evento.logicalKey;
      if (tecla == LogicalKeyboardKey.keyA ||
          tecla == LogicalKeyboardKey.arrowLeft) {
        moviendoIzquierda = false;
        return KeyEventResult.handled;
      }
      if (tecla == LogicalKeyboardKey.keyD ||
          tecla == LogicalKeyboardKey.arrowRight) {
        moviendoDerecha = false;
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletaRotulador.papel,
      body: Focus(
        focusNode: nodoFoco,
        autofocus: true,
        onKeyEvent: _alEventoTeclado,
        child: SafeArea(
          child: Column(
            children: [
              _construirEncabezado(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: PaletaRotulador.papel,
                        border: Border.all(
                          color: PaletaRotulador.tinta,
                          width: 2.4,
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (contexto, restricciones) {
                          // Tamaño del cadete suficientemente grande
                          // para que la cabeza PNG (≈48% del ancho del
                          // widget) sea legible en pantalla.
                          final double anchoCadetePx =
                              restricciones.maxWidth * 0.18;
                          final double altoCadetePx =
                              restricciones.maxHeight * 0.36;
                          final double sueloPx = sueloY *
                              restricciones.maxHeight;
                          final double izquierdaCadete =
                              cadeteX * restricciones.maxWidth -
                                  anchoCadetePx / 2;
                          final double arribaCadete =
                              sueloPx - altoCadetePx;
                          final bool parpadea = tiempoInvulnerable > 0 &&
                              (tiempoInvulnerable * 12).floor().isEven;
                          return Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _PintorSuperPang(
                                    cuerdaActiva: cuerdaActiva,
                                    cuerdaX: cuerdaX,
                                    cuerdaTopY: cuerdaTopY,
                                    globos: List<_GloboBurocratico>.from(
                                        globos),
                                    bannerNivel: bannerNivel,
                                    imagenGloboGrande: imagenGloboGrande,
                                    imagenGloboMedio: imagenGloboMedio,
                                    imagenGloboPequeno: imagenGloboPequeno,
                                    imagenArpon: imagenArpon,
                                    imagenBannerNivel: imagenBannerNivel,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: izquierdaCadete,
                                top: arribaCadete,
                                width: anchoCadetePx,
                                height: altoCadetePx,
                                child: IgnorePointer(
                                  child: Opacity(
                                    opacity: parpadea ? 0.45 : 1.0,
                                    child: Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.diagonal3Values(
                                        direccionMira >= 0 ? 1.0 : -1.0,
                                        1.0,
                                        1.0,
                                      ),
                                      child: StickFigureViviente(
                                        clase: widget
                                            .estado.personaje.clase,
                                        pose: cadeteEstaDisparando
                                            ? PoseStickFigure
                                                .brazoAlzado
                                            : PoseStickFigure
                                                .reposoFirme,
                                        enMovimiento:
                                            moviendoIzquierda ||
                                                moviendoDerecha,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              OverlayPausaMinijuego(
                                  visible: partidaPausada),
                              if (partidaTerminada)
                                _construirOverlayFinPartida(),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirEncabezado() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: PaletaRotulador.papel,
        border: Border(
          bottom: BorderSide(color: PaletaRotulador.tinta, width: 1.6),
        ),
      ),
      child: Row(
        children: [
          BotonPropaganda(
            texto: 'SALIR',
            compacto: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 16),
          const Text(
            'SUPER PANG GALÁCTICO',
            style: TextStyle(
              fontFamily: 'CosmoSerif',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: PaletaRotulador.tinta,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          Text(
            'NIVEL $nivelActual   VIDAS $vidas   PUNTOS $puntos',
            style: const TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 13,
              color: PaletaRotulador.tinta,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirOverlayFinPartida() {
    return Positioned.fill(
      child: Container(
        color: PaletaRotulador.papel.withValues(alpha: 0.86),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                partidaGanada
                    ? 'ANTECÁMARA DESPEJADA'
                    : 'GLOBO APLASTÓ AL CADETE',
                style: const TextStyle(
                  fontFamily: 'CosmoSerif',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: PaletaRotulador.rojoEstampilla,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'PUNTOS: $puntos',
                style: const TextStyle(
                  fontFamily: 'CosmoMono',
                  fontSize: 16,
                  color: PaletaRotulador.tinta,
                ),
              ),
              const SizedBox(height: 20),
              BotonPropaganda(
                texto: 'REINTENTAR',
                onPressed: _reiniciar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Globo burocrático: cápsula de papelería inflada que rebota.
class _GloboBurocratico {
  Offset posicion;
  Offset velocidad;
  /// 0=S, 1=M, 2=L, 3=XL.
  final int tamano;
  double faseAnimacion = 0;

  _GloboBurocratico({
    required this.posicion,
    required this.velocidad,
    required this.tamano,
  });

  double get radio {
    switch (tamano) {
      case 3:
        return 0.075;
      case 2:
        return 0.055;
      case 1:
        return 0.038;
      default:
        return 0.025;
    }
  }

  String get etiqueta {
    switch (tamano) {
      case 3:
        return 'F-447';
      case 2:
        return 'F-447';
      case 1:
        return 'F';
      default:
        return '·';
    }
  }
}

class _PintorSuperPang extends CustomPainter {
  final bool cuerdaActiva;
  final double cuerdaX;
  final double cuerdaTopY;
  final List<_GloboBurocratico> globos;
  final String? bannerNivel;
  /// Sprites §21 — null = render procedural para ese elemento.
  final ui.Image? imagenGloboGrande;
  final ui.Image? imagenGloboMedio;
  final ui.Image? imagenGloboPequeno;
  final ui.Image? imagenArpon;
  final ui.Image? imagenBannerNivel;

  _PintorSuperPang({
    required this.cuerdaActiva,
    required this.cuerdaX,
    required this.cuerdaTopY,
    required this.globos,
    required this.bannerNivel,
    this.imagenGloboGrande,
    this.imagenGloboMedio,
    this.imagenGloboPequeno,
    this.imagenArpon,
    this.imagenBannerNivel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Fondo de papel sucio.
    final Rect area = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(area, Paint()..color = PaletaRotulador.papel);
    // Manchas tenues de propaganda detrás.
    final math.Random rngFondo = math.Random(11);
    for (int i = 0; i < 14; i++) {
      final double x = rngFondo.nextDouble() * size.width;
      final double y = rngFondo.nextDouble() * size.height * 0.85;
      final double radio = 14 + rngFondo.nextDouble() * 22;
      canvas.drawCircle(
        Offset(x, y),
        radio,
        Paint()..color = PaletaRotulador.tintaDiluida(0.06),
      );
    }
    // Suelo: línea + zócalo.
    final double sueloPx = _PantallaSuperPangGalacticoState.sueloY *
        size.height;
    canvas.drawRect(
      Rect.fromLTWH(0, sueloPx, size.width, size.height - sueloPx),
      Paint()..color = PaletaRotulador.tintaDiluida(0.18),
    );
    canvas.drawLine(
      Offset(0, sueloPx),
      Offset(size.width, sueloPx),
      Paint()
        ..color = PaletaRotulador.tinta
        ..strokeWidth = 2.4,
    );
    // Pared techo: cintilla "COB.CEKPETNO".
    final TextPainter pintorTecho = TextPainter(
      text: const TextSpan(
        text:
            'COB. CEKPETNO · CÁPSULA F-447 · COB. CEKPETNO · CÁPSULA F-447',
        style: TextStyle(
          fontFamily: 'CosmoMono',
          fontSize: 9,
          color: PaletaRotulador.tinta,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintorTecho.paint(canvas, const Offset(8, 6));

    // Cuerda activa.
    if (cuerdaActiva) {
      final double xPx = cuerdaX * size.width;
      final double topPx = cuerdaTopY * size.height;
      canvas.drawLine(
        Offset(xPx, topPx),
        Offset(xPx, sueloPx),
        Paint()
          ..color = PaletaRotulador.rojoEstampilla
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round,
      );
      // Ancla en la punta.
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset(xPx, topPx), width: 10, height: 6),
        Paint()..color = PaletaRotulador.rojoEstampilla,
      );
    }

    // Globos.
    for (final globo in globos) {
      _pintarGlobo(canvas, globo, size);
    }

    // El cadete se renderiza FUERA del painter como widget
    // StickFigureViviente (igual sprite que el resto del juego, con
    // cabeza PNG según clase). Así garantiza identidad visual con
    // los escenarios.

    // Banner de nivel.
    if (bannerNivel != null) {
      final TextPainter pintorBanner = TextPainter(
        text: TextSpan(
          text: bannerNivel,
          style: const TextStyle(
            fontFamily: 'CosmoSerif',
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: PaletaRotulador.rojoEstampilla,
            letterSpacing: 3,
            height: 1.2,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width * 0.8);
      pintorBanner.paint(
        canvas,
        Offset(
          (size.width - pintorBanner.width) / 2,
          size.height * 0.35,
        ),
      );
    }
  }

  void _pintarGlobo(
      Canvas canvas, _GloboBurocratico globo, Size size) {
    final Offset centroPx = Offset(
      globo.posicion.dx * size.width,
      globo.posicion.dy * size.height,
    );
    final double radioPx = globo.radio * size.width;
    // Pequeña deformación (latido) según faseAnimacion.
    final double escalaY = 1.0 + math.sin(globo.faseAnimacion) * 0.05;
    final Rect rectGlobo = Rect.fromCenter(
      center: centroPx,
      width: radioPx * 2,
      height: radioPx * 2 * escalaY,
    );
    // Relleno papel con tinta diluida.
    canvas.drawOval(
      rectGlobo,
      Paint()..color = PaletaRotulador.tintaDiluida(0.08),
    );
    // Borde rotulador (doble pasada para temblor a ojo).
    canvas.drawOval(
      rectGlobo,
      Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
    canvas.drawOval(
      rectGlobo.deflate(1.4),
      Paint()
        ..color = PaletaRotulador.tintaDiluida(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );
    // Sello rojo F-447 (en los grandes y medianos).
    if (globo.tamano >= 1) {
      final TextPainter pintorSello = TextPainter(
        text: TextSpan(
          text: globo.etiqueta,
          style: TextStyle(
            fontFamily: 'CosmoMono',
            fontSize: globo.tamano == 3
                ? 14
                : (globo.tamano == 2 ? 11 : 9),
            fontWeight: FontWeight.w900,
            color: PaletaRotulador.rojoEstampilla,
            letterSpacing: 2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      pintorSello.paint(
        canvas,
        centroPx -
            Offset(pintorSello.width / 2, pintorSello.height / 2),
      );
    } else {
      // Punto rojo en los más pequeños.
      canvas.drawCircle(
        centroPx,
        radioPx * 0.30,
        Paint()..color = PaletaRotulador.rojoEstampilla,
      );
    }
    // Cordón/nudo arriba del globo: detalle artesanal.
    canvas.drawLine(
      Offset(centroPx.dx, centroPx.dy - radioPx * escalaY),
      Offset(centroPx.dx, centroPx.dy - radioPx * escalaY - 6),
      Paint()
        ..color = PaletaRotulador.tinta
        ..strokeWidth = 1.4,
    );
  }

  @override
  bool shouldRepaint(covariant _PintorSuperPang viejo) => true;
}
