import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../theme.dart';
import '../widgets/propaganda_button.dart';
import 'pintor_rotulador.dart';
import 'sprite_cadete.dart';
import 'utilidades_carga_sprites.dart';
import 'widget_pausa.dart';

/// INSPEKTOR PAC-MAN.
///
/// Tablero 21 columnas x 21 filas. El cadete se transforma en
/// Inspektor: una cabeza amarilla con sombrero rojo que recorre
/// los pasillos comiendo "expedientes" (puntos blancos). Cuatro
/// Komisarios (rojo, verde, gris, naranja) le persiguen con IA
/// sencilla (mezcla de chase Manhattan y movimiento aleatorio).
/// Las "tachas de tinta" del centro son power-ups que invierten
/// el rol y permiten encarcelar Komisarios durante 6 segundos.
class PantallaInspektorPacman extends StatefulWidget {
  final EstadoJuego estado;

  const PantallaInspektorPacman({super.key, required this.estado});

  @override
  State<PantallaInspektorPacman> createState() =>
      _PantallaInspektorPacmanState();
}

class _PantallaInspektorPacmanState extends State<PantallaInspektorPacman>
    with SingleTickerProviderStateMixin {
  static const int columnasTablero = 21;
  static const int filasTablero = 21;
  // 0 pasillo con expediente, 1 pared, 2 pasillo vacio,
  // 3 power-up (tacha de tinta), 4 corral del komisariato.
  static const List<String> trazadoTablero = <String>[
    '111111111111111111111',
    '100000000010000000001',
    '101110111010111011101',
    '130000000000000000031',
    '101011101010101110101',
    '100010000010000010001',
    '111110111010111011111',
    '111110100000001011111',
    '111110101444101011111',
    '100000001444100000001',
    '111110101111101011111',
    '111110100000001011111',
    '111110101110101011111',
    '100000000010000000001',
    '101110111010111011101',
    '100010000000000010001',
    '111010111010111010111',
    '100000001010100000001',
    '101111101110111110101',
    '130000000000000000031',
    '111111111111111111111',
  ];

  late List<List<int>> celdas;
  late Ticker tickerJuego;
  Duration? marcaTemporalAnterior;
  final FocusNode nodoFoco = FocusNode(debugLabel: 'inspektor_pacman');

  // Posicion de Inspektor en coordenadas (columna, fila) continuas.
  late double inspektorX;
  late double inspektorY;
  // Direccion actual y direccion deseada por el jugador.
  int direccionInspektorX = 0;
  int direccionInspektorY = 0;
  int direccionDeseadaX = 0;
  int direccionDeseadaY = 0;
  double velocidadInspektor = 4.2; // celdas por segundo

  late List<_Komisario> komisarios;
  int expedientesPendientes = 0;
  int puntuacion = 0;
  int vidas = 3;
  bool partidaTerminada = false;
  bool partidaPausada = false;
  bool partidaGanada = false;
  double segundosCazaInvertida = 0.0;
  // Animacion de boca del comecocos.
  double faseBoca = 0.0;

  // Partículas visuales cuando el Inspektor come expedientes o tinta.
  final List<_ParticulaExpediente> particulas = <_ParticulaExpediente>[];

  // Bonus "fruta" tipo Pac-Man: sello del Comité que aparece tras comer
  // 60 expedientes. Da 500 puntos y desaparece tras 8 segundos.
  static const int expedientesParaBonus = 60;
  static const double duracionBonusSegundos = 8.0;
  bool bonusSelloActivo = false;
  double tiempoBonusRestanteSegundos = 0;
  int expedientesComidosAcumulados = 0;
  int totalBonusComidos = 0;
  Offset? posicionBonusSello; // celda (col, fila) +0.5

  // Sprites de §16 — cableado anticipado.
  ui.Image? imagenInspektor; // §16.1
  ui.Image? imagenKomisarioGorro; // §16.2 (variante gorro)
  ui.Image? imagenKomisarioMonoculo; // §16.2 (variante monóculo)
  ui.Image? imagenKomisarioBigote; // §16.2 (variante bigote)
  ui.Image? imagenKomisarioPipa; // §16.2 (variante pipa)
  ui.Image? imagenExpediente; // §16.3
  ui.Image? imagenTintaPower; // §16.4
  ui.Image? imagenFondoLaberinto; // §16.5

  @override
  void initState() {
    super.initState();
    _inicializarTablero();
    tickerJuego = createTicker(_alTick)..start();
    _cargarSprites();
  }

  Future<void> _cargarSprites() async {
    final resultados = await cargarLoteOpcional(<String>[
      'assets/svg/pacman_inspektor.png',
      'assets/svg/pacman_komisario_gorro.png',
      'assets/svg/pacman_komisario_monoculo.png',
      'assets/svg/pacman_komisario_bigote.png',
      'assets/svg/pacman_komisario_pipa.png',
      'assets/svg/pacman_expediente.png',
      'assets/svg/pacman_tinta_power.png',
      'assets/svg/pacman_fondo_laberinto.png',
    ]);
    if (!mounted) return;
    setState(() {
      imagenInspektor = resultados[0];
      imagenKomisarioGorro = resultados[1];
      imagenKomisarioMonoculo = resultados[2];
      imagenKomisarioBigote = resultados[3];
      imagenKomisarioPipa = resultados[4];
      imagenExpediente = resultados[5];
      imagenTintaPower = resultados[6];
      imagenFondoLaberinto = resultados[7];
    });
  }

  @override
  void dispose() {
    tickerJuego.dispose();
    nodoFoco.dispose();
    super.dispose();
  }

  void _inicializarTablero() {
    celdas = List<List<int>>.generate(
      filasTablero,
      (fila) {
        return List<int>.generate(
          columnasTablero,
          (columna) {
            final String caracter = trazadoTablero[fila][columna];
            return int.parse(caracter);
          },
        );
      },
    );
    expedientesPendientes = 0;
    for (final fila in celdas) {
      for (final celda in fila) {
        if (celda == 0) expedientesPendientes++;
      }
    }
    // Posiciones centradas en celda (sufijo .5 para que casiCentrado
    // funcione desde el primer frame).
    inspektorX = 10.5;
    inspektorY = 15.5;
    direccionInspektorX = 0;
    direccionInspektorY = 0;
    direccionDeseadaX = 0;
    direccionDeseadaY = 0;
    // Komisarios distribuidos por el laberinto (no atrapados en el
    // corral) y con direccion inicial NO nula para que arranquen ya
    // moviendose desde el primer frame.
    // Komisarios: en estilo rotulador se distinguen por intensidad de
    // tinta (sólo el rojo lo lleva el más peligroso: KOM-R).
    komisarios = <_Komisario>[
      _Komisario(
          color: PaletaRotulador.rojoEstampilla,
          nombre: 'KOM-R',
          posX: 10.5,
          posY: 1.5)
        ..direccionY = 1,
      _Komisario(
          color: PaletaRotulador.tintaDiluida(0.85),
          nombre: 'KOM-V',
          posX: 1.5,
          posY: 5.5)
        ..direccionX = 1,
      _Komisario(
          color: PaletaRotulador.tintaDiluida(0.55),
          nombre: 'KOM-G',
          posX: 19.5,
          posY: 5.5)
        ..direccionX = -1,
      _Komisario(
          color: PaletaRotulador.tintaDiluida(0.30),
          nombre: 'KOM-N',
          posX: 10.5,
          posY: 11.5)
        ..direccionY = 1,
    ];
    puntuacion = 0;
    vidas = 3;
    partidaTerminada = false;
    partidaGanada = false;
    segundosCazaInvertida = 0.0;
    bonusSelloActivo = false;
    tiempoBonusRestanteSegundos = 0;
    posicionBonusSello = null;
    expedientesComidosAcumulados = 0;
    totalBonusComidos = 0;
    particulas.clear();
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

    faseBoca += dt * 8.0;

    if (segundosCazaInvertida > 0) {
      segundosCazaInvertida = math.max(0, segundosCazaInvertida - dt);
    }

    _moverInspektor(dt);
    _comerCeldas();
    for (final komisario in komisarios) {
      _moverKomisario(komisario, dt);
    }
    _resolverColisiones();
    _actualizarBonus(dt);
    _actualizarParticulas(dt);

    if (expedientesPendientes <= 0) {
      partidaTerminada = true;
      partidaGanada = true;
      _guardarHighscoreSiToca();
    }

    setState(() {});
  }

  void _moverInspektor(double dt) {
    final double avance = velocidadInspektor * dt;
    final int filaActual = inspektorY.floor();
    final int colActual = inspektorX.floor();

    if (direccionDeseadaX != 0 || direccionDeseadaY != 0) {
      final int proxFila = filaActual + direccionDeseadaY;
      final int proxCol = colActual + direccionDeseadaX;
      final bool deseadaPasable = _esPasable(proxCol, proxFila);

      // Reglas de cambio de direccion (en orden de prioridad):
      // 1. Si estamos parados, aplicar deseada inmediatamente.
      // 2. Si la deseada es opuesta a la actual (mismo eje), invertir
      //    inmediatamente sin esperar a estar centrado.
      // 3. Si la deseada es perpendicular y estamos cerca del centro de
      //    la celda, girar y hacer snap al centro.
      final bool parado =
          direccionInspektorX == 0 && direccionInspektorY == 0;
      final bool ejeOpuesto =
          (direccionDeseadaX != 0 && direccionDeseadaX == -direccionInspektorX) ||
              (direccionDeseadaY != 0 && direccionDeseadaY == -direccionInspektorY);
      final double xFraccion = inspektorX - colActual;
      final double yFraccion = inspektorY - filaActual;
      final bool casiCentrado = (xFraccion - 0.5).abs() < 0.30 &&
          (yFraccion - 0.5).abs() < 0.30;

      if (deseadaPasable && (parado || ejeOpuesto)) {
        direccionInspektorX = direccionDeseadaX;
        direccionInspektorY = direccionDeseadaY;
      } else if (deseadaPasable && casiCentrado) {
        direccionInspektorX = direccionDeseadaX;
        direccionInspektorY = direccionDeseadaY;
        inspektorX = colActual + 0.5;
        inspektorY = filaActual + 0.5;
      }
    }

    // Avanzar en la direccion actual si la celda siguiente es pasable.
    final double siguienteX = inspektorX + direccionInspektorX * avance;
    final double siguienteY = inspektorY + direccionInspektorY * avance;
    final int colSiguiente = siguienteX.floor();
    final int filaSiguiente = siguienteY.floor();
    if (_esPasable(colSiguiente, filaSiguiente)) {
      inspektorX = siguienteX;
      inspektorY = siguienteY;
    } else {
      // Pared al frente: snap al centro de la celda actual.
      inspektorX = inspektorX.floor() + 0.5;
      inspektorY = inspektorY.floor() + 0.5;
      direccionInspektorX = 0;
      direccionInspektorY = 0;
    }

    // Tunel lateral (envoltura horizontal).
    if (inspektorX < 0) inspektorX = columnasTablero - 0.01;
    if (inspektorX >= columnasTablero) inspektorX = 0.01;
  }

  bool _esPasable(int columna, int fila) {
    if (fila < 0 || fila >= filasTablero) return false;
    if (columna < 0 || columna >= columnasTablero) return true; // tunel
    final int valorCelda = celdas[fila][columna];
    return valorCelda != 1;
  }

  void _comerCeldas() {
    final int colActual = inspektorX.floor();
    final int filaActual = inspektorY.floor();
    if (filaActual < 0 || filaActual >= filasTablero) return;
    if (colActual < 0 || colActual >= columnasTablero) return;
    final int valorCelda = celdas[filaActual][colActual];
    if (valorCelda == 0) {
      celdas[filaActual][colActual] = 2;
      expedientesPendientes--;
      puntuacion += 10;
      expedientesComidosAcumulados++;
      // Cada N expedientes, intentar generar el sello bonus.
      if (!bonusSelloActivo &&
          expedientesComidosAcumulados >= expedientesParaBonus &&
          expedientesComidosAcumulados %
                  expedientesParaBonus ==
              0) {
        _aparecerBonusSello();
      }
      _emitirParticulas(
        Offset(colActual + 0.5, filaActual + 0.5),
        PaletaCosmoSovietica.papelViejo,
        cantidadParticulas: 5,
      );
    } else if (valorCelda == 3) {
      celdas[filaActual][colActual] = 2;
      segundosCazaInvertida = 6.0;
      puntuacion += 50;
      for (final komisario in komisarios) {
        komisario.aturdido = true;
      }
      _emitirParticulas(
        Offset(colActual + 0.5, filaActual + 0.5),
        PaletaCosmoSovietica.rojoOficial,
        cantidadParticulas: 14,
      );
    }
  }

  void _emitirParticulas(
    Offset centroCeldas,
    Color colorParticula, {
    required int cantidadParticulas,
  }) {
    final math.Random rngParticulas = math.Random();
    for (int indiceParticula = 0; indiceParticula < cantidadParticulas; indiceParticula++) {
      final double anguloEmision = rngParticulas.nextDouble() * math.pi * 2;
      final double velocidadEmision =
          1.5 + rngParticulas.nextDouble() * 2.0;
      particulas.add(_ParticulaExpediente(
        posicion: centroCeldas,
        velocidad: Offset(math.cos(anguloEmision) * velocidadEmision,
            math.sin(anguloEmision) * velocidadEmision),
        color: colorParticula,
        vidaRestante: 0.5 + rngParticulas.nextDouble() * 0.4,
      ));
    }
  }

  void _aparecerBonusSello() {
    // Lo colocamos en una celda transitable cercana al centro del mapa
    // (priorizamos celdas tipo 2 ya comidas para no machacar expedientes).
    const int colCentro = 10;
    const int filaCentro = 9;
    final math.Random rngBonus = math.Random();
    final List<Offset> candidatos = <Offset>[];
    for (int radio = 1; radio <= 5; radio++) {
      for (int dFila = -radio; dFila <= radio; dFila++) {
        for (int dColumna = -radio; dColumna <= radio; dColumna++) {
          final int fila = filaCentro + dFila;
          final int columna = colCentro + dColumna;
          if (fila < 1 || fila >= filasTablero - 1) continue;
          if (columna < 1 || columna >= columnasTablero - 1) continue;
          final int valor = celdas[fila][columna];
          if (valor == 2) {
            candidatos.add(Offset(columna + 0.5, fila + 0.5));
          }
        }
      }
      if (candidatos.isNotEmpty) break;
    }
    if (candidatos.isEmpty) return;
    posicionBonusSello =
        candidatos[rngBonus.nextInt(candidatos.length)];
    bonusSelloActivo = true;
    tiempoBonusRestanteSegundos = duracionBonusSegundos;
  }

  void _actualizarBonus(double dt) {
    if (!bonusSelloActivo) return;
    tiempoBonusRestanteSegundos -= dt;
    if (tiempoBonusRestanteSegundos <= 0) {
      bonusSelloActivo = false;
      tiempoBonusRestanteSegundos = 0;
      posicionBonusSello = null;
      return;
    }
    // Colisión con el inspektor: la distancia al centro de la celda.
    final Offset? bonusPosicion = posicionBonusSello;
    if (bonusPosicion != null) {
      final double dxBonus = bonusPosicion.dx - inspektorX;
      final double dyBonus = bonusPosicion.dy - inspektorY;
      if (dxBonus * dxBonus + dyBonus * dyBonus < 0.45 * 0.45) {
        puntuacion += 500;
        totalBonusComidos++;
        bonusSelloActivo = false;
        tiempoBonusRestanteSegundos = 0;
        posicionBonusSello = null;
        _emitirParticulas(
          bonusPosicion,
          PaletaRotulador.rojoEstampilla,
          cantidadParticulas: 24,
        );
      }
    }
  }

  void _actualizarParticulas(double dt) {
    for (final particula in particulas) {
      particula.posicion = particula.posicion.translate(
          particula.velocidad.dx * dt, particula.velocidad.dy * dt);
      particula.vidaRestante -= dt;
      // Fricción suave.
      particula.velocidad =
          particula.velocidad * math.pow(0.10, dt).toDouble();
    }
    particulas.removeWhere((p) => p.vidaRestante <= 0);
  }

  void _moverKomisario(_Komisario komisario, double dt) {
    // Komisarios aturdidos a 1.5 (en vez de 2.0): más comestibles
    // durante el power-up, mayor contraste con su velocidad normal.
    final double velocidad = komisario.aturdido ? 1.5 : 3.6;
    final double avance = velocidad * dt;

    final double xCentrado = komisario.posX - komisario.posX.floor();
    final double yCentrado = komisario.posY - komisario.posY.floor();
    final bool casiCentrado =
        (xCentrado - 0.5).abs() < 0.15 && (yCentrado - 0.5).abs() < 0.15;

    if (casiCentrado) {
      final int filaActual = komisario.posY.floor();
      final int colActual = komisario.posX.floor();
      // Evaluar las 4 direcciones, descartando hacia atras.
      final List<List<int>> opciones = <List<int>>[];
      const List<List<int>> direcciones = <List<int>>[
        [1, 0],
        [-1, 0],
        [0, 1],
        [0, -1],
      ];
      for (final direccion in direcciones) {
        if (direccion[0] == -komisario.direccionX &&
            direccion[1] == -komisario.direccionY) {
          continue;
        }
        if (_esPasable(colActual + direccion[0], filaActual + direccion[1])) {
          opciones.add(direccion);
        }
      }
      // Si no hay opciones, permitir retroceder.
      if (opciones.isEmpty) {
        for (final direccion in direcciones) {
          if (_esPasable(
              colActual + direccion[0], filaActual + direccion[1])) {
            opciones.add(direccion);
          }
        }
      }
      // Elegir la opcion que minimice (o maximice si aturdido)
      // distancia Manhattan al inspector. Mezclamos con un 25% de
      // aleatoriedad para que no sean letalmente eficientes.
      if (opciones.isNotEmpty) {
        opciones.sort((a, b) {
          final double distA = (colActual + a[0] - inspektorX).abs() +
              (filaActual + a[1] - inspektorY).abs();
          final double distB = (colActual + b[0] - inspektorX).abs() +
              (filaActual + b[1] - inspektorY).abs();
          if (komisario.aturdido) {
            return distB.compareTo(distA);
          } else {
            return distA.compareTo(distB);
          }
        });
        final List<int> direccionElegida =
            komisario.rng.nextDouble() < 0.25
                ? opciones[komisario.rng.nextInt(opciones.length)]
                : opciones.first;
        komisario.direccionX = direccionElegida[0];
        komisario.direccionY = direccionElegida[1];
        komisario.posX = colActual + 0.5;
        komisario.posY = filaActual + 0.5;
      }
    }

    final double siguienteX = komisario.posX + komisario.direccionX * avance;
    final double siguienteY = komisario.posY + komisario.direccionY * avance;
    if (_esPasable(siguienteX.floor(), siguienteY.floor())) {
      komisario.posX = siguienteX;
      komisario.posY = siguienteY;
    } else {
      komisario.posX = komisario.posX.floor() + 0.5;
      komisario.posY = komisario.posY.floor() + 0.5;
      komisario.direccionX = 0;
      komisario.direccionY = 0;
    }

    if (komisario.posX < 0) komisario.posX = columnasTablero - 0.01;
    if (komisario.posX >= columnasTablero) komisario.posX = 0.01;

    if (segundosCazaInvertida <= 0 && komisario.aturdido) {
      komisario.aturdido = false;
    }
  }

  void _resolverColisiones() {
    for (final komisario in komisarios) {
      final double dx = komisario.posX - inspektorX;
      final double dy = komisario.posY - inspektorY;
      final double distancia = math.sqrt(dx * dx + dy * dy);
      if (distancia < 0.55) {
        if (komisario.aturdido) {
          // Encarcelar: devolver al corral.
          komisario.posX = 10.0;
          komisario.posY = 9.0;
          komisario.direccionX = 0;
          komisario.direccionY = -1;
          komisario.aturdido = false;
          puntuacion += 200;
        } else {
          _perderVida();
          return;
        }
      }
    }
  }

  void _perderVida() {
    vidas -= 1;
    if (vidas <= 0) {
      partidaTerminada = true;
      partidaGanada = false;
      _guardarHighscoreSiToca();
      return;
    }
    // Reposicionar en centros de celda.
    inspektorX = 10.5;
    inspektorY = 15.5;
    direccionInspektorX = 0;
    direccionInspektorY = 0;
    direccionDeseadaX = 0;
    direccionDeseadaY = 0;
    for (int indice = 0; indice < komisarios.length; indice++) {
      komisarios[indice].posX = 9.5 + indice * 1.0;
      komisarios[indice].posY = 9.5;
      komisarios[indice].direccionX = 0;
      komisarios[indice].direccionY = -1;
    }
  }

  void _guardarHighscoreSiToca() {
    final int previo = _leerHighscorePacman(widget.estado);
    if (puntuacion > previo) {
      _guardarHighscorePacman(widget.estado, puntuacion);
    }
  }

  KeyEventResult _alEventoTeclado(FocusNode nodo, KeyEvent evento) {
    final bool esPulsacion =
        evento is KeyDownEvent || evento is KeyRepeatEvent;
    if (!esPulsacion) return KeyEventResult.ignored;
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
          tecla == LogicalKeyboardKey.space ||
          tecla == LogicalKeyboardKey.numpadEnter) {
        setState(_inicializarTablero);
        return KeyEventResult.handled;
      }
    }

    if (tecla == LogicalKeyboardKey.keyA ||
        tecla == LogicalKeyboardKey.arrowLeft) {
      direccionDeseadaX = -1;
      direccionDeseadaY = 0;
      return KeyEventResult.handled;
    }
    if (tecla == LogicalKeyboardKey.keyD ||
        tecla == LogicalKeyboardKey.arrowRight) {
      direccionDeseadaX = 1;
      direccionDeseadaY = 0;
      return KeyEventResult.handled;
    }
    if (tecla == LogicalKeyboardKey.keyW ||
        tecla == LogicalKeyboardKey.arrowUp) {
      direccionDeseadaX = 0;
      direccionDeseadaY = -1;
      return KeyEventResult.handled;
    }
    if (tecla == LogicalKeyboardKey.keyS ||
        tecla == LogicalKeyboardKey.arrowDown) {
      direccionDeseadaX = 0;
      direccionDeseadaY = 1;
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
            semilla: 17,
            child: _construirContenidoInspektor(),
          ),
        ),
      ),
    );
  }

  Widget _construirContenidoInspektor() {
    final int mejor = _leerHighscorePacman(widget.estado);
    return Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _construirCabecera(mejor),
                const SizedBox(height: 12),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _construirTablero()),
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
    );
  }

  Widget _construirCabecera(int mejor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'INSPEKTOR · CORREDORES DEL COMITÉ',
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

  Widget _construirTablero() {
    return Center(
      child: AspectRatio(
        aspectRatio: columnasTablero / filasTablero,
        child: MarcoRotulador(
          color: PaletaRotulador.tinta,
          grosor: 3.6,
          intensidadJitter: 1.6,
          margenInterior: 2.0,
          child: Container(
          decoration: const BoxDecoration(
            color: PaletaRotulador.papel,
          ),
          child: CustomPaint(
            painter: _PintorTableroPacman(
              celdas: celdas,
              inspektorX: inspektorX,
              inspektorY: inspektorY,
              direccionInspektorX: direccionInspektorX,
              direccionInspektorY: direccionInspektorY,
              komisarios: komisarios,
              segundosCazaInvertida: segundosCazaInvertida,
              faseBoca: faseBoca,
              particulas: particulas,
              bonusSelloActivo: bonusSelloActivo,
              posicionBonusSello: posicionBonusSello,
              tiempoBonusRestanteSegundos: tiempoBonusRestanteSegundos,
              partidaTerminada: partidaTerminada,
              partidaGanada: partidaGanada,
              imagenInspektor: imagenInspektor,
              imagenKomisarioGorro: imagenKomisarioGorro,
              imagenKomisarioMonoculo: imagenKomisarioMonoculo,
              imagenKomisarioBigote: imagenKomisarioBigote,
              imagenKomisarioPipa: imagenKomisarioPipa,
              imagenExpediente: imagenExpediente,
              imagenTintaPower: imagenTintaPower,
              imagenFondoLaberinto: imagenFondoLaberinto,
            ),
            child: Container(),
          ),
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
            'CORPS DE KOMISARIOS',
            style: TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: PaletaRotulador.rojoEstampilla,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          for (final komisario in komisarios)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: komisario.aturdido
                          ? PaletaRotulador.tintaDiluida(0.20)
                          : komisario.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: PaletaRotulador.tinta, width: 1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    komisario.nombre,
                    style: const TextStyle(
                      fontFamily: 'CosmoMono',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PaletaCosmoSovietica.papelViejo,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(color: PaletaCosmoSovietica.papelViejo, height: 16),
          const Text(
            'EXPEDIENTES',
            style: TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: PaletaCosmoSovietica.rojoOficial,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'QUEDAN $expedientesPendientes',
            style: const TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: PaletaCosmoSovietica.papelViejo,
            ),
          ),
          if (segundosCazaInvertida > 0) ...[
            const SizedBox(height: 8),
            Text(
              'TINTA: ${segundosCazaInvertida.toStringAsFixed(1)} s',
              style: const TextStyle(
                fontFamily: 'CosmoMono',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: PaletaRotulador.rojoEstampilla,
              ),
            ),
          ],
          if (bonusSelloActivo) ...[
            const SizedBox(height: 8),
            Text(
              'SELLO BONUS: '
              '${tiempoBonusRestanteSegundos.toStringAsFixed(1)} s',
              style: const TextStyle(
                fontFamily: 'CosmoMono',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: PaletaRotulador.rojoEstampilla,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'BONUS COMIDOS: $totalBonusComidos',
            style: const TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 11,
              color: PaletaRotulador.tinta,
            ),
          ),
          const Divider(color: PaletaCosmoSovietica.papelViejo, height: 16),
          const Text(
            'CONTROLES',
            style: TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: PaletaCosmoSovietica.rojoOficial,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'WASD / Flechas\nESC : salir',
            style: TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 11,
              color: PaletaRotulador.tintaDiluida(0.75),
              height: 1.5,
            ),
          ),
          const Spacer(),
          const Text(
            '«El Inspektor sabe el camino. El expediente recoge al Inspektor.»',
            style: TextStyle(
              fontFamily: 'CosmoSerif',
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: PaletaCosmoSovietica.papelViejo,
            ),
          ),
        ],
      ),
    );
  }
}

class _Komisario {
  final Color color;
  final String nombre;
  double posX;
  double posY;
  int direccionX;
  int direccionY;
  bool aturdido;
  final math.Random rng;

  _Komisario({
    required this.color,
    required this.nombre,
    required this.posX,
    required this.posY,
  })  : direccionX = 0,
        direccionY = -1,
        aturdido = false,
        rng = math.Random();
}

class _ParticulaExpediente {
  Offset posicion;
  Offset velocidad;
  final Color color;
  double vidaRestante;

  _ParticulaExpediente({
    required this.posicion,
    required this.velocidad,
    required this.color,
    required this.vidaRestante,
  });
}

class _PintorTableroPacman extends CustomPainter {
  final List<List<int>> celdas;
  final double inspektorX;
  final double inspektorY;
  final int direccionInspektorX;
  final int direccionInspektorY;
  final List<_Komisario> komisarios;
  final double segundosCazaInvertida;
  final double faseBoca;
  final List<_ParticulaExpediente> particulas;
  final bool bonusSelloActivo;
  final Offset? posicionBonusSello;
  final double tiempoBonusRestanteSegundos;
  final bool partidaTerminada;
  final bool partidaGanada;
  /// Sprites §16 — null si asset no generado / no cargado.
  final ui.Image? imagenInspektor;
  final ui.Image? imagenKomisarioGorro;
  final ui.Image? imagenKomisarioMonoculo;
  final ui.Image? imagenKomisarioBigote;
  final ui.Image? imagenKomisarioPipa;
  final ui.Image? imagenExpediente;
  final ui.Image? imagenTintaPower;
  final ui.Image? imagenFondoLaberinto;

  _PintorTableroPacman({
    required this.celdas,
    required this.inspektorX,
    required this.inspektorY,
    required this.direccionInspektorX,
    required this.direccionInspektorY,
    required this.komisarios,
    required this.segundosCazaInvertida,
    required this.faseBoca,
    required this.particulas,
    required this.bonusSelloActivo,
    required this.posicionBonusSello,
    required this.tiempoBonusRestanteSegundos,
    required this.partidaTerminada,
    required this.partidaGanada,
    this.imagenInspektor,
    this.imagenKomisarioGorro,
    this.imagenKomisarioMonoculo,
    this.imagenKomisarioBigote,
    this.imagenKomisarioPipa,
    this.imagenExpediente,
    this.imagenTintaPower,
    this.imagenFondoLaberinto,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final int filas = celdas.length;
    final int columnas = celdas[0].length;
    final double anchoCelda = size.width / columnas;
    final double altoCelda = size.height / filas;

    // Paredes a tinta sobre papel.
    final Paint pincelPared = Paint()
      ..color = PaletaRotulador.tintaDiluida(0.85)
      ..style = PaintingStyle.fill;
    final Paint pincelPasillo = Paint()
      ..color = PaletaRotulador.papel
      ..style = PaintingStyle.fill;
    final Paint pincelExpediente = Paint()
      ..color = PaletaRotulador.tinta;
    final Paint pincelPowerUp = Paint()
      ..color = PaletaRotulador.rojoEstampilla;
    final Paint pincelCorral = Paint()
      ..color = PaletaRotulador.papelSucio;

    // Posiciones predeterminadas de posters de propaganda decorativos
    // sobre bloques de pared (col, fila).
    const Set<(int, int)> posicionesPostersPared = <(int, int)>{
      (5, 4),
      (15, 4),
      (3, 12),
      (17, 12),
      (10, 7),
    };

    for (int fila = 0; fila < filas; fila++) {
      for (int columna = 0; columna < columnas; columna++) {
        final Rect rectCelda = Rect.fromLTWH(
          columna * anchoCelda,
          fila * altoCelda,
          anchoCelda,
          altoCelda,
        );
        final int valorCelda = celdas[fila][columna];
        switch (valorCelda) {
          case 1:
            // Pared del laberinto: bloque a tinta diluida + interior papel
            // para sugerir doble línea estilo Pac-Man pero a rotulador.
            canvas.drawRect(rectCelda, pincelPared);
            canvas.drawRect(
              rectCelda.deflate(anchoCelda * 0.15),
              Paint()..color = PaletaRotulador.papel,
            );
            // Posters de propaganda en algunos bloques.
            if (posicionesPostersPared.contains((columna, fila))) {
              _dibujarPosterPropaganda(canvas, rectCelda, columna + fila);
            }
            break;
          case 4:
            canvas.drawRect(rectCelda, pincelCorral);
            break;
          default:
            canvas.drawRect(rectCelda, pincelPasillo);
        }
        if (valorCelda == 0) {
          // Expediente: pequeño círculo a tinta (visible sobre papel).
          canvas.drawCircle(
            rectCelda.center,
            anchoCelda * 0.13,
            pincelExpediente,
          );
        } else if (valorCelda == 3) {
          // Power-up tacha de tinta: cuadradito que late.
          final double pulso =
              0.45 + 0.20 * math.sin(faseBoca * 0.5);
          canvas.drawRect(
            Rect.fromCenter(
              center: rectCelda.center,
              width: anchoCelda * pulso,
              height: altoCelda * pulso,
            ),
            pincelPowerUp,
          );
        }
      }
    }

    // Bonus sello del Comité (estampilla pulsante).
    final Offset? bonusPos = posicionBonusSello;
    if (bonusSelloActivo && bonusPos != null) {
      final double xBonusPx = bonusPos.dx * anchoCelda;
      final double yBonusPx = bonusPos.dy * altoCelda;
      // Pulso lento al inicio, rápido al final cuando va a desaparecer.
      final double urgencia =
          (1.0 - tiempoBonusRestanteSegundos / 8.0).clamp(0.0, 1.0);
      final double fasePulso = math.sin(faseBoca * (2.0 + urgencia * 6.0));
      final double escalaPulso = 1.0 + 0.15 * fasePulso;
      estampillaRoja(
        canvas,
        posicion: Offset(xBonusPx, yBonusPx),
        texto: 'COMITÉ',
        anchoEstampilla: anchoCelda * 2.0 * escalaPulso,
        altoEstampilla: altoCelda * 0.95 * escalaPulso,
        rotacionRadianes: -0.12 + fasePulso * 0.06,
        opacidad: 0.85 + 0.10 * fasePulso,
      );
    }

    // Partículas en pasillos (debajo de personajes).
    for (final particula in particulas) {
      final double alphaParticula =
          particula.vidaRestante.clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(particula.posicion.dx * anchoCelda,
            particula.posicion.dy * altoCelda),
        anchoCelda * 0.07,
        Paint()..color = particula.color.withValues(alpha: alphaParticula),
      );
    }

    // Komisarios.
    for (final komisario in komisarios) {
      _dibujarKomisario(canvas, komisario, anchoCelda, altoCelda);
    }

    // Inspektor.
    _dibujarInspektor(canvas, anchoCelda, altoCelda);

    // Overlay fin de partida.
    if (partidaTerminada) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = PaletaRotulador.papel.withValues(alpha: 0.88),
      );
      final pintorTitulo = TextPainter(
        text: TextSpan(
          text: partidaGanada
              ? '★ COMITÉ DERROTADO ★\nPULSA ENTER\nPARA OTRA RONDA'
              : 'EL EXPEDIENTE TE HA RECOGIDO\nPULSA ENTER\nPARA REINTENTAR',
          style: TextStyle(
            color: partidaGanada
                ? PaletaCosmoSovietica.verdeArchivo
                : PaletaCosmoSovietica.rojoOficial,
            fontFamily: 'CosmoMono',
            fontSize: anchoCelda * 1.2,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            height: 1.5,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: size.width * 0.85);
      pintorTitulo.paint(
        canvas,
        Offset(
          size.width / 2 - pintorTitulo.width / 2,
          size.height / 2 - pintorTitulo.height / 2,
        ),
      );
    }
  }

  void _dibujarInspektor(
      Canvas canvas, double anchoCelda, double altoCelda) {
    final Offset centro = Offset(
      inspektorX * anchoCelda,
      inspektorY * altoCelda,
    );
    final double radio = anchoCelda * 0.45;
    // Casco del cosmonauta abriendose como un Pac-Man.
    final double aperturaBoca =
        0.18 + 0.28 * math.sin(faseBoca).abs();
    double anguloBase;
    if (direccionInspektorX > 0) {
      anguloBase = 0;
    } else if (direccionInspektorX < 0) {
      anguloBase = math.pi;
    } else if (direccionInspektorY > 0) {
      anguloBase = math.pi / 2;
    } else if (direccionInspektorY < 0) {
      anguloBase = -math.pi / 2;
    } else {
      anguloBase = 0;
    }
    dibujarCabezaComeCocos(
      canvas,
      centro: centro,
      radio: radio,
      anguloApertura: aperturaBoca,
      anguloBase: anguloBase,
    );
  }

  void _dibujarKomisario(
      Canvas canvas, _Komisario komisario, double anchoCelda, double altoCelda) {
    final Offset centro = Offset(
      komisario.posX * anchoCelda,
      komisario.posY * altoCelda,
    );
    final double radio = anchoCelda * 0.45;
    final Color colorCuerpo = komisario.aturdido
        ? PaletaRotulador.tintaDiluida(0.20)
        : komisario.color;

    final Paint pincelTrazo = Paint()
      ..color = PaletaRotulador.tinta
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    // Cuerpo tipo fantasma (semicirculo + falda zig-zag).
    final Path caminoFantasma = Path()
      ..moveTo(centro.dx - radio, centro.dy + radio * 0.6)
      ..lineTo(centro.dx - radio, centro.dy)
      ..arcTo(
        Rect.fromCircle(center: centro, radius: radio),
        math.pi,
        math.pi,
        false,
      )
      ..lineTo(centro.dx + radio, centro.dy + radio * 0.6);
    const int dientes = 4;
    final double anchoDiente = (2 * radio) / dientes;
    for (int dienteIndice = dientes - 1; dienteIndice >= 0; dienteIndice--) {
      final double xCentroDiente =
          centro.dx - radio + (dienteIndice + 0.5) * anchoDiente;
      caminoFantasma.lineTo(
          xCentroDiente, centro.dy + radio * 0.95);
      caminoFantasma.lineTo(
          centro.dx - radio + dienteIndice * anchoDiente,
          centro.dy + radio * 0.6);
    }
    caminoFantasma.close();
    canvas.drawPath(caminoFantasma, Paint()..color = colorCuerpo);
    canvas.drawPath(caminoFantasma, pincelTrazo);

    // Gorra militar (peaked cap) por encima del cuerpo.
    if (!komisario.aturdido) {
      // Visera negra.
      canvas.drawRect(
        Rect.fromCenter(
          center: centro.translate(0, -radio * 0.92),
          width: radio * 1.45,
          height: radio * 0.18,
        ),
        Paint()..color = PaletaCosmoSovietica.tintaNegra,
      );
      // Plato superior color cuerpo.
      canvas.drawRect(
        Rect.fromCenter(
          center: centro.translate(0, -radio * 1.20),
          width: radio * 1.20,
          height: radio * 0.50,
        ),
        Paint()..color = colorCuerpo,
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: centro.translate(0, -radio * 1.20),
          width: radio * 1.20,
          height: radio * 0.50,
        ),
        pincelTrazo,
      );
      // Banda roja.
      canvas.drawRect(
        Rect.fromCenter(
          center: centro.translate(0, -radio * 0.97),
          width: radio * 1.20,
          height: radio * 0.18,
        ),
        Paint()..color = PaletaCosmoSovietica.rojoOficial,
      );
      // Estrella roja en la frente de la gorra.
      _dibujarEstrellaCinco(
        canvas,
        centro.translate(0, -radio * 1.20),
        radio * 0.18,
        Paint()..color = PaletaCosmoSovietica.rojoOficial,
      );
    }

    // Ojos blancos con pupilas que siguen la direccion.
    canvas.drawCircle(centro.translate(-radio * 0.35, -radio * 0.05),
        radio * 0.20, Paint()..color = PaletaCosmoSovietica.papelViejo);
    canvas.drawCircle(centro.translate(radio * 0.35, -radio * 0.05),
        radio * 0.20, Paint()..color = PaletaCosmoSovietica.papelViejo);
    canvas.drawCircle(centro.translate(-radio * 0.35, -radio * 0.05),
        radio * 0.20, pincelTrazo);
    canvas.drawCircle(centro.translate(radio * 0.35, -radio * 0.05),
        radio * 0.20, pincelTrazo);
    final double mirX = komisario.direccionX * radio * 0.08;
    final double mirY = komisario.direccionY * radio * 0.08;
    canvas.drawCircle(
        centro.translate(-radio * 0.35 + mirX, -radio * 0.05 + mirY),
        radio * 0.09,
        Paint()..color = PaletaCosmoSovietica.tintaNegra);
    canvas.drawCircle(
        centro.translate(radio * 0.35 + mirX, -radio * 0.05 + mirY),
        radio * 0.09,
        Paint()..color = PaletaCosmoSovietica.tintaNegra);

    // Bigote bajo los ojos cuando esta despierto (toque sovietico).
    if (!komisario.aturdido) {
      canvas.drawLine(
        centro.translate(-radio * 0.30, radio * 0.30),
        centro.translate(radio * 0.30, radio * 0.30),
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      );
    } else {
      // Aturdido: ojos en espiral.
      for (final ladoX in [-0.35, 0.35]) {
        canvas.drawArc(
          Rect.fromCircle(
              center: centro.translate(ladoX * radio, -radio * 0.05),
              radius: radio * 0.12),
          0,
          math.pi * 1.5,
          false,
          Paint()
            ..color = PaletaCosmoSovietica.tintaNegra
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      }
    }
  }

  void _dibujarPosterPropaganda(
      Canvas canvas, Rect rectBloque, int semilla) {
    // Mini-poster decorativo sobre un bloque de pared.
    final Rect rectPoster = Rect.fromCenter(
      center: rectBloque.center,
      width: rectBloque.width * 0.62,
      height: rectBloque.height * 0.74,
    );
    final int variantePoster = semilla % 3;
    // Tres variantes a rotulador: rojo, papel con marco tinta, papel
    // con cabecera roja.
    final Color colorFondoPoster = switch (variantePoster) {
      0 => PaletaRotulador.rojoEstampilla,
      1 => PaletaRotulador.papel,
      _ => PaletaRotulador.papel,
    };
    canvas.drawRect(rectPoster, Paint()..color = colorFondoPoster);
    if (variantePoster == 2) {
      // Cabecera roja en el segundo tipo.
      canvas.drawRect(
        Rect.fromLTWH(rectPoster.left, rectPoster.top,
            rectPoster.width, rectPoster.height * 0.25),
        Paint()..color = PaletaRotulador.rojoEstampilla,
      );
    }
    canvas.drawRect(
      rectPoster,
      Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Símbolo central según variante.
    switch (variantePoster) {
      case 0:
        // Estrella papel sobre rojo.
        _dibujarEstrellaCinco(
          canvas,
          rectPoster.center,
          rectPoster.shortestSide * 0.32,
          Paint()..color = PaletaRotulador.papel,
        );
        break;
      case 1:
        // Hoz y martillo a tinta sobre papel.
        canvas.drawLine(
          rectPoster.centerLeft.translate(rectPoster.width * 0.20, 0),
          rectPoster.centerRight.translate(-rectPoster.width * 0.20, 0),
          Paint()
            ..color = PaletaRotulador.tinta
            ..strokeWidth = 2.0,
        );
        canvas.drawArc(
          Rect.fromCircle(
              center: rectPoster.center,
              radius: rectPoster.shortestSide * 0.28),
          -math.pi * 0.85,
          math.pi * 0.9,
          false,
          Paint()
            ..color = PaletaRotulador.tinta
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0,
        );
        break;
      default:
        // Texto "СССР" a tinta sobre papel.
        final pintorTexto = TextPainter(
          text: TextSpan(
            text: 'СССР',
            style: TextStyle(
              color: PaletaCosmoSovietica.tintaNegra,
              fontFamily: 'CosmoMono',
              fontSize: rectPoster.height * 0.42,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        pintorTexto.paint(
          canvas,
          Offset(rectPoster.center.dx - pintorTexto.width / 2,
              rectPoster.center.dy - pintorTexto.height / 2),
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
  bool shouldRepaint(covariant _PintorTableroPacman viejo) => true;
}

const String _flagHighscorePacman = 'inspektor_highscore_';

int _leerHighscorePacman(EstadoJuego estado) {
  for (final flag in estado.flagsActivos) {
    if (flag.startsWith(_flagHighscorePacman)) {
      return int.tryParse(flag.substring(_flagHighscorePacman.length)) ?? 0;
    }
  }
  return 0;
}

void _guardarHighscorePacman(EstadoJuego estado, int puntuacion) {
  estado.flagsActivos.removeWhere(
    (flag) => flag.startsWith(_flagHighscorePacman),
  );
  estado.activarFlag('$_flagHighscorePacman$puntuacion');
}
