import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../widgets/propaganda_button.dart';
import 'pintor_rotulador.dart';
import 'sprite_cadete.dart';
import 'widget_pausa.dart';

/// SNOW KAMARADA.
///
/// Escenario nevado de plataformas. El cadete soviético, con gorro
/// ushanka, salta entre plataformas y arroja formularios F-447 a los
/// "Capitalistas Espaciales" (yankis con sombrero de copa, traje
/// rayado y maletín de dólares). Tres impactos envuelven al enemigo
/// en una bola de papel sellada; el cadete la patea y la bola rueda
/// eliminando otros yankis al pasar. Sobrevivir hasta limpiar la
/// oleada = victoria.
class PantallaSnowKamarada extends StatefulWidget {
  final EstadoJuego estado;

  const PantallaSnowKamarada({super.key, required this.estado});

  @override
  State<PantallaSnowKamarada> createState() => _PantallaSnowKamaradaState();
}

class _PantallaSnowKamaradaState extends State<PantallaSnowKamarada>
    with SingleTickerProviderStateMixin {
  // Mundo en coordenadas relativas (0..1 horizontal, 0..1 vertical).
  static const double anchoMundo = 1.0;
  static const double altoMundo = 1.0;
  static const double gravedadMundo = 2.6;
  static const double velocidadSalto = 1.75;
  static const double velocidadCaminar = 0.75;
  static const double radioCadete = 0.035;
  static const double cooldownDisparo = 0.25;
  static const double duracionEnvuelto = 5.0;

  late Ticker tickerJuego;
  Duration? marcaTemporalAnterior;
  final FocusNode nodoFoco = FocusNode(debugLabel: 'snow_kamarada');

  // Plataformas (rectangulos absolutos).
  final List<Rect> plataformas = const <Rect>[
    Rect.fromLTRB(0.00, 0.92, 1.00, 1.00), // suelo
    Rect.fromLTRB(0.06, 0.70, 0.34, 0.74),
    Rect.fromLTRB(0.66, 0.70, 0.94, 0.74),
    Rect.fromLTRB(0.30, 0.48, 0.70, 0.52),
    Rect.fromLTRB(0.00, 0.30, 0.22, 0.34),
    Rect.fromLTRB(0.78, 0.30, 1.00, 0.34),
    Rect.fromLTRB(0.40, 0.18, 0.60, 0.22),
  ];

  Offset posicionCadete = const Offset(0.50, 0.86);
  Offset velocidadCadete = Offset.zero;
  int direccionMiraCadete = 1;
  bool moviendoIzquierda = false;
  bool moviendoDerecha = false;
  bool enSuelo = false;
  double tiempoHastaSiguienteDisparo = 0.0;
  int vidas = 3;
  int puntuacion = 0;
  bool partidaTerminada = false;
  bool partidaPausada = false;
  bool partidaGanada = false;
  double tiempoInvulnerable = 0.0;

  final List<_CapitalistaEspacial> burocratas = <_CapitalistaEspacial>[];
  final List<_FormularioDisparado> formulariosVolando =
      <_FormularioDisparado>[];
  final List<_BolaDocumentos> bolasRodantes = <_BolaDocumentos>[];
  final List<_CopoNieve> copos = <_CopoNieve>[];
  int oleadaActual = 1;
  /// Fase 0..1 para animar el caminar del cadete.
  double fasePasoCadete = 0.0;

  // Power-up café soviético: tras 3 burócratas derrotados aparece un
  // café flotante. Al recogerlo, durante 6 segundos disparas más rápido
  // y te mueves un 30% más rápido.
  static const int burocratasParaCafe = 3;
  static const double duracionEfectoCafe = 6.0;
  static const double cooldownDisparoConCafe = 0.10;
  int burocratasDerrotadosAcumulados = 0;
  bool cafePowerUpActivo = false;
  double tiempoEfectoCafeRestante = 0;
  Offset? posicionCafePowerUp; // coords mundo (0..1) cuando aparece
  bool cafePowerUpDisponible = false;

  @override
  void initState() {
    super.initState();
    _generarOleada();
    _sembrarNieve();
    tickerJuego = createTicker(_alTick)..start();
  }

  @override
  void dispose() {
    tickerJuego.dispose();
    nodoFoco.dispose();
    super.dispose();
  }

  void _sembrarNieve() {
    final math.Random rng = math.Random(91);
    for (int indiceCopo = 0; indiceCopo < 70; indiceCopo++) {
      copos.add(_CopoNieve(
        posicion: Offset(rng.nextDouble(), rng.nextDouble()),
        velocidadCaida: 0.05 + rng.nextDouble() * 0.10,
        radio: 1.5 + rng.nextDouble() * 2.5,
        balanceo: rng.nextDouble() * math.pi * 2,
      ));
    }
  }

  void _generarOleada() {
    burocratas.clear();
    burocratas.addAll(<_CapitalistaEspacial>[
      _CapitalistaEspacial(posicion: const Offset(0.15, 0.66)),
      _CapitalistaEspacial(posicion: const Offset(0.50, 0.66)),
      _CapitalistaEspacial(posicion: const Offset(0.80, 0.66)),
      _CapitalistaEspacial(posicion: const Offset(0.30, 0.44)),
      _CapitalistaEspacial(posicion: const Offset(0.70, 0.44)),
      if (oleadaActual >= 2)
        _CapitalistaEspacial(posicion: const Offset(0.12, 0.26)),
      if (oleadaActual >= 2)
        _CapitalistaEspacial(posicion: const Offset(0.50, 0.26)),
      if (oleadaActual >= 2)
        _CapitalistaEspacial(posicion: const Offset(0.88, 0.26)),
      if (oleadaActual >= 3)
        _CapitalistaEspacial(posicion: const Offset(0.20, 0.08)),
      if (oleadaActual >= 3)
        _CapitalistaEspacial(posicion: const Offset(0.80, 0.08)),
    ]);
  }

  void _registrarBurocrataDerrotado(Offset posicionUltimaDerrota) {
    burocratasDerrotadosAcumulados++;
    if (!cafePowerUpDisponible && !cafePowerUpActivo &&
        burocratasDerrotadosAcumulados % burocratasParaCafe == 0) {
      // Aparece el café en la posición del burócrata derrotado,
      // ligeramente desplazado hacia arriba para que flote sobre el suelo.
      cafePowerUpDisponible = true;
      posicionCafePowerUp = Offset(
        posicionUltimaDerrota.dx.clamp(0.05, 0.95),
        posicionUltimaDerrota.dy.clamp(0.05, 0.85) - 0.05,
      );
    }
  }

  void _actualizarPowerUpCafe(double dt) {
    // Caída suave del icono hasta tocar la plataforma más cercana.
    if (cafePowerUpDisponible) {
      final Offset? posicionActual = posicionCafePowerUp;
      if (posicionActual != null) {
        // Aplicar gravedad suave hasta que pose sobre una plataforma.
        double nuevaY = posicionActual.dy + 0.45 * dt;
        bool poseEnPlataforma = false;
        for (final plataforma in plataformas) {
          if (posicionActual.dx >= plataforma.left &&
              posicionActual.dx <= plataforma.right &&
              nuevaY >= plataforma.top &&
              nuevaY <= plataforma.top + 0.02) {
            nuevaY = plataforma.top - 0.005;
            poseEnPlataforma = true;
            break;
          }
        }
        if (nuevaY > 0.95) nuevaY = 0.95;
        posicionCafePowerUp = Offset(posicionActual.dx, nuevaY);
        // Colisión con el cadete.
        final double distCafe =
            (posicionCafePowerUp! - posicionCadete).distance;
        if (distCafe < 0.06 ||
            (poseEnPlataforma && distCafe < 0.08)) {
          cafePowerUpDisponible = false;
          posicionCafePowerUp = null;
          cafePowerUpActivo = true;
          tiempoEfectoCafeRestante = duracionEfectoCafe;
          puntuacion += 50;
        }
      }
    }
    // Decaer efecto activo.
    if (cafePowerUpActivo) {
      tiempoEfectoCafeRestante -= dt;
      if (tiempoEfectoCafeRestante <= 0) {
        tiempoEfectoCafeRestante = 0;
        cafePowerUpActivo = false;
      }
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

    _actualizarCopos(dt);
    _actualizarCadete(dt);
    _actualizarFormularios(dt);
    _actualizarBurocratas(dt);
    _actualizarPowerUpCafe(dt);
    _actualizarBolas(dt);

    if (tiempoInvulnerable > 0) {
      tiempoInvulnerable = math.max(0, tiempoInvulnerable - dt);
    }
    if (tiempoHastaSiguienteDisparo > 0) {
      tiempoHastaSiguienteDisparo =
          math.max(0, tiempoHastaSiguienteDisparo - dt);
    }

    if (burocratas.isEmpty && bolasRodantes.isEmpty) {
      if (oleadaActual < 2) {
        oleadaActual++;
        _generarOleada();
      } else {
        partidaTerminada = true;
        partidaGanada = true;
        _guardarHighscoreSiToca();
      }
    }

    setState(() {});
  }

  void _actualizarCopos(double dt) {
    for (final copo in copos) {
      copo.balanceo += dt * 0.6;
      copo.posicion = Offset(
        copo.posicion.dx + math.sin(copo.balanceo) * 0.0025,
        copo.posicion.dy + copo.velocidadCaida * dt,
      );
      if (copo.posicion.dy > 1.05) {
        copo.posicion = Offset(copo.posicion.dx, -0.05);
      }
    }
  }

  void _actualizarCadete(double dt) {
    // Bajo efecto café, el cadete corre un 30% más rápido.
    final double velocidadCaminarEfectiva = cafePowerUpActivo
        ? velocidadCaminar * 1.30
        : velocidadCaminar;
    double vx = 0;
    if (moviendoIzquierda && !moviendoDerecha) {
      vx = -velocidadCaminarEfectiva;
      direccionMiraCadete = -1;
    } else if (moviendoDerecha && !moviendoIzquierda) {
      vx = velocidadCaminarEfectiva;
      direccionMiraCadete = 1;
    }
    // Cap a la velocidad de caída: evita acelerar indefinidamente
    // tras caídas largas y reduce el riesgo de tunneling contra
    // plataformas finas.
    const double velocidadCaidaMaxima = 3.6;
    velocidadCadete = Offset(
      vx,
      math.min(
        velocidadCaidaMaxima,
        velocidadCadete.dy + gravedadMundo * dt,
      ),
    );
    if (vx != 0) {
      fasePasoCadete = (fasePasoCadete + dt * 1.4) % 1.0;
    }
    Offset nuevaPos = posicionCadete + velocidadCadete * dt;
    enSuelo = false;

    // Colision con plataformas: solo techo (caer encima). La caja
    // del cadete coincide con el sprite real (5× radio de alto, 2×
    // de ancho), no con el radio del cuerpo: así los pies se asientan
    // sobre la plataforma en vez de quedar la plataforma a mitad del
    // cuerpo.
    const double mitadAltoCadete = radioCadete * 2.5;
    for (final plataforma in plataformas) {
      final Rect cajaCadete = Rect.fromCenter(
        center: nuevaPos,
        width: radioCadete * 2,
        height: mitadAltoCadete * 2,
      );
      if (!cajaCadete.overlaps(plataforma)) continue;
      final double pieAnterior =
          posicionCadete.dy + mitadAltoCadete;
      if (velocidadCadete.dy >= 0 && pieAnterior <= plataforma.top + 0.02) {
        nuevaPos = Offset(nuevaPos.dx, plataforma.top - mitadAltoCadete);
        velocidadCadete = Offset(velocidadCadete.dx, 0);
        enSuelo = true;
      }
    }

    // Limites horizontales (envuelve por los lados).
    if (nuevaPos.dx < 0) nuevaPos = Offset(anchoMundo, nuevaPos.dy);
    if (nuevaPos.dx > anchoMundo) nuevaPos = Offset(0, nuevaPos.dy);
    if (nuevaPos.dy < 0) {
      nuevaPos = Offset(nuevaPos.dx, 0);
      velocidadCadete = Offset(velocidadCadete.dx, 0);
    }

    posicionCadete = nuevaPos;

    // Las bolas ya tienen fisica propia; el puntapie real ocurre cuando
    // el cadete toca a un enemigo en estado "convertidoEnBola" (ver
    // _actualizarBurocratas), de modo que aqui solo aplicamos un
    // empujon extra si el cadete colisiona con una bola estacionaria.
    for (final bola in bolasRodantes) {
      if (bola.velocidad.dx.abs() > 0.2) continue;
      final Offset diferenciaBola = bola.posicion - posicionCadete;
      if (diferenciaBola.distance < radioCadete + bola.radio + 0.005) {
        bola.velocidad = Offset(
            direccionMiraCadete * 1.6, bola.velocidad.dy - 0.20);
      }
    }
  }

  /// Distancia mínima entre el punto [p] y el segmento [a, b].
  /// Si el segmento es de longitud cero (a==b), devuelve la distancia
  /// al punto. Usado para sweep collision en proyectiles rápidos.
  double _distanciaPuntoASegmento(Offset p, Offset a, Offset b) {
    final Offset ab = b - a;
    final double longitudCuadrada =
        ab.dx * ab.dx + ab.dy * ab.dy;
    if (longitudCuadrada < 1e-9) return (p - a).distance;
    final Offset ap = p - a;
    final double t = ((ap.dx * ab.dx + ap.dy * ab.dy) / longitudCuadrada)
        .clamp(0.0, 1.0);
    final Offset puntoCercano = a + ab * t;
    return (p - puntoCercano).distance;
  }

  void _disparar() {
    if (tiempoHastaSiguienteDisparo > 0) return;
    // Disparo con arco tipo Snow Bros: velocidad horizontal moderada
    // y empujón hacia arriba para que la gravedad lo curve. Más
    // lento que antes para que el jugador pueda apuntar bien y los
    // enemigos sean realmente impactables.
    formulariosVolando.add(_FormularioDisparado(
      posicion: posicionCadete.translate(
          direccionMiraCadete * radioCadete * 1.2, -radioCadete * 0.2),
      velocidad: Offset(direccionMiraCadete * 0.95, -0.85),
      vidaSegundos: 2.0,
    ));
    tiempoHastaSiguienteDisparo =
        cafePowerUpActivo ? cooldownDisparoConCafe : cooldownDisparo;
  }

  /// Aplica la fisica de aterrizaje a una entidad: gravedad, colision
  /// con plataformas (solo desde arriba) y limites laterales. Devuelve
  /// la nueva posicion y velocidad y si quedo en suelo.
  ({Offset posicion, Offset velocidad, bool enSuelo}) _aplicarFisicaSobrePlataformas({
    required Offset posicionPrevia,
    required Offset velocidadPrevia,
    required double radio,
    required double dt,
  }) {
    Offset velocidad = Offset(
      velocidadPrevia.dx,
      velocidadPrevia.dy + gravedadMundo * dt,
    );
    Offset nuevaPos = posicionPrevia + velocidad * dt;
    bool aterrizo = false;
    for (final plataforma in plataformas) {
      final Rect caja = Rect.fromCenter(
        center: nuevaPos,
        width: radio * 2,
        height: radio * 2,
      );
      if (!caja.overlaps(plataforma)) continue;
      final double pieAnterior = posicionPrevia.dy + radio;
      if (velocidad.dy >= 0 && pieAnterior <= plataforma.top + 0.005) {
        nuevaPos = Offset(nuevaPos.dx, plataforma.top - radio);
        velocidad = Offset(velocidad.dx, 0);
        aterrizo = true;
      }
    }
    // Envoltura lateral.
    if (nuevaPos.dx < 0) nuevaPos = Offset(anchoMundo + nuevaPos.dx, nuevaPos.dy);
    if (nuevaPos.dx > anchoMundo) {
      nuevaPos = Offset(nuevaPos.dx - anchoMundo, nuevaPos.dy);
    }
    return (posicion: nuevaPos, velocidad: velocidad, enSuelo: aterrizo);
  }

  void _actualizarFormularios(double dt) {
    for (final formulario in formulariosVolando) {
      formulario.vidaSegundos -= dt;
      // Trayectoria parabólica suave: gravedad reducida sobre el
      // papel para que los disparos sean controlables.
      formulario.velocidad = Offset(
        formulario.velocidad.dx,
        formulario.velocidad.dy + gravedadMundo * 1.05 * dt,
      );
      formulario.posicion = formulario.posicion + formulario.velocidad * dt;
      formulario.rotacion += dt * 8.0;
    }
    // Resolver impactos con burócratas. Hacemos un "swept test":
    // comprobamos no sólo la posición actual del formulario sino el
    // segmento entre la posición anterior y la nueva en este frame.
    // Eso evita que un disparo rápido "atraviese" al enemigo en un
    // único tick sin colisionar.
    for (final formulario in List<_FormularioDisparado>.from(
        formulariosVolando)) {
      if (formulario.vidaSegundos <= 0) continue;
      final Offset posPrevia =
          formulario.posicion - formulario.velocidad * dt;
      for (final burocrata in burocratas) {
        if (burocrata.convertidoEnBola) continue;
        // Distancia mínima entre el segmento [posPrevia, posActual]
        // y el centro del enemigo (sweep test continuo).
        final double dist = _distanciaPuntoASegmento(
          burocrata.posicion,
          posPrevia,
          formulario.posicion,
        );
        if (dist < 0.090) {
          burocrata.impactosRecibidos += 1;
          // El impacto detiene en seco al enemigo.
          burocrata.velocidad = Offset(0, burocrata.velocidad.dy);
          if (burocrata.impactosRecibidos >= 3) {
            burocrata.convertidoEnBola = true;
            burocrata.tiempoBolaRestante = duracionEnvuelto;
          }
          formulariosVolando.remove(formulario);
          break;
        }
      }
    }
    formulariosVolando.removeWhere((f) =>
        f.vidaSegundos <= 0 ||
        f.posicion.dx < -0.1 ||
        f.posicion.dx > anchoMundo + 0.1 ||
        f.posicion.dy > altoMundo + 0.1);
  }

  void _actualizarBurocratas(double dt) {
    const double velocidadCaminarEnemigo = 0.16;
    const double velocidadSaltoEnemigo = 0.95;
    final math.Random rngDecision = math.Random();

    for (final burocrata in List<_CapitalistaEspacial>.from(burocratas)) {
      // Estado bola: estatico, espera puntapie o explota.
      if (burocrata.convertidoEnBola) {
        burocrata.tiempoBolaRestante -= dt;
        // Aplicar gravedad por si esta cayendo.
        final fisica = _aplicarFisicaSobrePlataformas(
          posicionPrevia: burocrata.posicion,
          velocidadPrevia: burocrata.velocidad,
          radio: radioCadete * 1.2,
          dt: dt,
        );
        burocrata.posicion = fisica.posicion;
        burocrata.velocidad = fisica.velocidad;
        burocrata.enSuelo = fisica.enSuelo;

        // Si el cadete toca la bola estatica, patearla.
        final double dist =
            (burocrata.posicion - posicionCadete).distance;
        if (dist < radioCadete + 0.05) {
          bolasRodantes.add(_BolaDocumentos(
            posicion: burocrata.posicion,
            velocidad: Offset(
              direccionMiraCadete * 1.6,
              -0.30,
            ),
            radio: radioCadete * 1.2,
          ));
          burocratas.remove(burocrata);
          puntuacion += 50;
          _registrarBurocrataDerrotado(burocrata.posicion);
          continue;
        }
        // Si se acaba el tiempo, explota.
        if (burocrata.tiempoBolaRestante <= 0) {
          burocrata.convertidoEnBola = false;
          burocrata.impactosRecibidos = math.max(0,
              burocrata.impactosRecibidos - 1);
          burocrata.tiempoBolaRestante = 0;
        }
        continue;
      }

      // IA persecucion: avanzar horizontalmente hacia el cadete. Si el
      // cadete esta abajo, dejarse caer del borde de la plataforma.
      final double dx = posicionCadete.dx - burocrata.posicion.dx;
      final double dy = posicionCadete.dy - burocrata.posicion.dy;
      int direccionObjetivo = dx.abs() < 0.02 ? 0 : (dx > 0 ? 1 : -1);
      // Si esta muy cerca del cadete pero a distinta altura, no perseguir
      // si no hay plataforma para llegar (mejor patrullar local).
      if (burocrata.enSuelo) {
        if (direccionObjetivo != 0) {
          burocrata.direccionMover = direccionObjetivo;
          burocrata.velocidad = Offset(
              burocrata.direccionMover * velocidadCaminarEnemigo,
              burocrata.velocidad.dy);
        } else {
          burocrata.velocidad = Offset(
              burocrata.direccionMover * velocidadCaminarEnemigo * 0.4,
              burocrata.velocidad.dy);
        }
        // Pequeno salto ocasional si el cadete esta por encima (poco
        // frecuente para que no sean demasiado agresivos).
        if (dy < -0.10 &&
            rngDecision.nextDouble() < dt * 0.15) {
          burocrata.velocidad =
              Offset(burocrata.velocidad.dx, -velocidadSaltoEnemigo);
        }
      } else {
        // En el aire mantenemos la velocidad horizontal pero la
        // limitamos un poco para que se sienta mas natural.
        burocrata.velocidad = Offset(
          burocrata.velocidad.dx.clamp(-velocidadCaminarEnemigo,
              velocidadCaminarEnemigo),
          burocrata.velocidad.dy,
        );
      }

      // Fase de paso para animacion.
      if (burocrata.enSuelo && burocrata.velocidad.dx.abs() > 0.01) {
        burocrata.fasePaso = (burocrata.fasePaso + dt * 1.4) % 1.0;
      }

      // Aplicar fisica.
      final fisica = _aplicarFisicaSobrePlataformas(
        posicionPrevia: burocrata.posicion,
        velocidadPrevia: burocrata.velocidad,
        radio: radioCadete * 1.05,
        dt: dt,
      );
      burocrata.posicion = fisica.posicion;
      burocrata.velocidad = fisica.velocidad;
      burocrata.enSuelo = fisica.enSuelo;

      // Si cae por debajo del mundo, reaparece arriba (snow bros style).
      if (burocrata.posicion.dy > altoMundo + 0.05) {
        burocrata.posicion = Offset(burocrata.posicion.dx, -0.05);
        burocrata.velocidad = Offset.zero;
      }

      // Colision con cadete.
      if (tiempoInvulnerable <= 0) {
        final double distCadete =
            (burocrata.posicion - posicionCadete).distance;
        if (distCadete < radioCadete + 0.038) {
          _golpearCadete();
        }
      }
    }
  }

  void _actualizarBolas(double dt) {
    for (final bola in List<_BolaDocumentos>.from(bolasRodantes)) {
      // Las bolas tienen fisica: gravedad + rebote en paredes laterales.
      Offset velocidad = Offset(
        bola.velocidad.dx,
        bola.velocidad.dy + gravedadMundo * dt,
      );
      // Friccion suave al rodar (en suelo lo aplicaremos despues).
      Offset nuevaPos = bola.posicion + velocidad * dt;
      bool aterrizo = false;
      for (final plataforma in plataformas) {
        final Rect caja = Rect.fromCenter(
          center: nuevaPos,
          width: bola.radio * 2,
          height: bola.radio * 2,
        );
        if (!caja.overlaps(plataforma)) continue;
        final double pieAnterior = bola.posicion.dy + bola.radio;
        if (velocidad.dy >= 0 && pieAnterior <= plataforma.top + 0.005) {
          nuevaPos = Offset(nuevaPos.dx, plataforma.top - bola.radio);
          velocidad = Offset(velocidad.dx, 0);
          aterrizo = true;
        }
      }
      // Limites laterales: rebote elastico para que vuelva por el otro
      // lado matando enemigos en su retroceso.
      if (nuevaPos.dx - bola.radio < 0) {
        nuevaPos = Offset(bola.radio, nuevaPos.dy);
        velocidad = Offset(-velocidad.dx * 0.85, velocidad.dy);
      }
      if (nuevaPos.dx + bola.radio > anchoMundo) {
        nuevaPos = Offset(anchoMundo - bola.radio, nuevaPos.dy);
        velocidad = Offset(-velocidad.dx * 0.85, velocidad.dy);
      }
      bola.posicion = nuevaPos;
      bola.velocidad = velocidad;
      // Friccion horizontal en suelo para que vaya decelerando.
      if (aterrizo) {
        bola.velocidad =
            Offset(bola.velocidad.dx * (1.0 - dt * 0.3), bola.velocidad.dy);
      }
      bola.angulo += velocidad.dx * dt * 4.0;
      bola.tiempoVida -= dt;

      if (bola.tiempoVida <= 0 || bola.posicion.dy > altoMundo + 0.05) {
        bolasRodantes.remove(bola);
        continue;
      }
      // Atropella enemigos al pasar.
      for (final burocrata in List<_CapitalistaEspacial>.from(burocratas)) {
        final double distEnem =
            (burocrata.posicion - bola.posicion).distance;
        if (distEnem < bola.radio + 0.04) {
          burocratas.remove(burocrata);
          puntuacion += 100;
          _registrarBurocrataDerrotado(burocrata.posicion);
        }
      }
    }
  }

  void _golpearCadete() {
    vidas -= 1;
    tiempoInvulnerable = 1.3;
    if (vidas <= 0) {
      partidaTerminada = true;
      partidaGanada = false;
      _guardarHighscoreSiToca();
    }
  }

  void _guardarHighscoreSiToca() {
    final int previo = _leerHighscoreSnow(widget.estado);
    if (puntuacion > previo) {
      _guardarHighscoreSnow(widget.estado, puntuacion);
    }
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
        setState(() {
          posicionCadete = const Offset(0.50, 0.86);
          velocidadCadete = Offset.zero;
          vidas = 3;
          puntuacion = 0;
          oleadaActual = 1;
          partidaTerminada = false;
          partidaGanada = false;
          formulariosVolando.clear();
          bolasRodantes.clear();
          _generarOleada();
        });
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
      if (enSuelo) {
        velocidadCadete = Offset(velocidadCadete.dx, -velocidadSalto);
      }
      return KeyEventResult.handled;
    }
    if ((tecla == LogicalKeyboardKey.keyJ ||
            tecla == LogicalKeyboardKey.keyZ ||
            tecla == LogicalKeyboardKey.controlLeft ||
            tecla == LogicalKeyboardKey.shiftLeft) &&
        esPulsacion) {
      _disparar();
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
    final int mejor = _leerHighscoreSnow(widget.estado);
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
            semilla: 59,
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
          'SNOW KAMARADA · OPERATIVO INVIERNO',
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
            _chip('OLEADA', '$oleadaActual / 2', acentuado: true),
            const SizedBox(width: 6),
            _chip('PUNTOS', '$puntuacion', acentuado: true),
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
              : PaletaRotulador.papel,
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
          painter: _PintorSnowKamarada(
            plataformas: plataformas,
            posicionCadete: posicionCadete,
            direccionMiraCadete: direccionMiraCadete,
            cadeteEnSuelo: enSuelo,
            cadeteMoviendo:
                moviendoIzquierda || moviendoDerecha,
            fasePasoCadete: fasePasoCadete,
            burocratas: burocratas,
            formulariosVolando: formulariosVolando,
            bolasRodantes: bolasRodantes,
            copos: copos,
            partidaTerminada: partidaTerminada,
            partidaGanada: partidaGanada,
            tiempoInvulnerable: tiempoInvulnerable,
            posicionCafePowerUp:
                cafePowerUpDisponible ? posicionCafePowerUp : null,
            cafePowerUpActivo: cafePowerUpActivo,
            tiempoEfectoCafeRestante: tiempoEfectoCafeRestante,
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
          const SizedBox(height: 8),
          const Text(
            'Tres impactos con F-447 envuelven al burócrata. Tócalo para patearlo: rueda como bola y atropella todo en su plataforma. Si suelta, el burócrata vuelve a la patrulla.',
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
          const SizedBox(height: 6),
          Text(
            'A / ◀  : izquierda\n'
            'D / ▶  : derecha\n'
            'W / ↑  : saltar\n'
            'J / Z  : disparar\n'
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
            '«La nieve archiva mejor que el archivo. Y patea mejor que el Comité.»',
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

class _CapitalistaEspacial {
  /// Centro del enemigo en coords relativas.
  Offset posicion;
  /// Velocidad actual (unidades por segundo).
  Offset velocidad;
  /// Hacia donde mira (1 derecha, -1 izquierda).
  int direccionMover;
  /// Cantidad de F-447 recibidos: 0-2 muestra papel acumulado, 3 lo
  /// convierte en bola.
  int impactosRecibidos;
  /// True cuando ha alcanzado los 3 impactos y queda como bola
  /// estatica esperando un puntapie del cadete.
  bool convertidoEnBola;
  /// Tiempo restante en estado bola antes de explotar (libera enemigo
  /// con un -1 de impactos para volver a la pelea).
  double tiempoBolaRestante;
  /// Color del traje del capitalista (variacion visual).
  final Color colorTraje;
  /// True si esta apoyado sobre una plataforma este frame.
  bool enSuelo;
  /// Acumulador de pasos para animar la caminata.
  double fasePaso;

  _CapitalistaEspacial({
    required this.posicion,
    Color? colorTraje,
  })  : velocidad = Offset.zero,
        direccionMover = 1,
        impactosRecibidos = 0,
        convertidoEnBola = false,
        tiempoBolaRestante = 0,
        colorTraje = colorTraje ?? PaletaRotulador.tinta,
        enSuelo = false,
        fasePaso = 0;
}

class _FormularioDisparado {
  Offset posicion;
  Offset velocidad;
  double vidaSegundos;
  double rotacion = 0;

  _FormularioDisparado({
    required this.posicion,
    required this.velocidad,
    required this.vidaSegundos,
  });
}

class _BolaDocumentos {
  Offset posicion;
  Offset velocidad;
  double radio;
  double angulo;
  double tiempoVida;

  _BolaDocumentos({
    required this.posicion,
    required this.velocidad,
    required this.radio,
  })  : angulo = 0,
        tiempoVida = 3.5;
}

class _CopoNieve {
  Offset posicion;
  double velocidadCaida;
  double radio;
  double balanceo;

  _CopoNieve({
    required this.posicion,
    required this.velocidadCaida,
    required this.radio,
    required this.balanceo,
  });
}

class _PintorSnowKamarada extends CustomPainter {
  final List<Rect> plataformas;
  final Offset posicionCadete;
  final int direccionMiraCadete;
  final bool cadeteEnSuelo;
  final bool cadeteMoviendo;
  final double fasePasoCadete;
  final List<_CapitalistaEspacial> burocratas;
  final List<_FormularioDisparado> formulariosVolando;
  final List<_BolaDocumentos> bolasRodantes;
  final List<_CopoNieve> copos;
  final bool partidaTerminada;
  final bool partidaGanada;
  final double tiempoInvulnerable;
  final Offset? posicionCafePowerUp;
  final bool cafePowerUpActivo;
  final double tiempoEfectoCafeRestante;

  _PintorSnowKamarada({
    required this.plataformas,
    required this.posicionCadete,
    required this.direccionMiraCadete,
    required this.cadeteEnSuelo,
    required this.cadeteMoviendo,
    required this.fasePasoCadete,
    required this.burocratas,
    required this.formulariosVolando,
    required this.bolasRodantes,
    required this.copos,
    required this.partidaTerminada,
    required this.partidaGanada,
    required this.tiempoInvulnerable,
    required this.posicionCafePowerUp,
    required this.cafePowerUpActivo,
    required this.tiempoEfectoCafeRestante,
  });

  Offset _r(Offset p, Size size) =>
      Offset(p.dx * size.width, p.dy * size.height);
  Rect _rRect(Rect r, Size size) => Rect.fromLTRB(
        r.left * size.width,
        r.top * size.height,
        r.right * size.width,
        r.bottom * size.height,
      );

  @override
  void paint(Canvas canvas, Size size) {
    // Cielo: papel viejo (sin gradiente).
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = PaletaRotulador.papel,
    );

    // Aurora boreal a rotulador: tres bandas onduladas de tinta diluida
    // dibujadas con líneas que sugieren cortinas de luz.
    for (int indiceBanda = 0; indiceBanda < 3; indiceBanda++) {
      final double yBase = size.height * (0.10 + indiceBanda * 0.05);
      final double alphaBanda = 0.40 - indiceBanda * 0.10;
      final Paint pincelAurora = Paint()
        ..color = PaletaRotulador.tintaDiluida(alphaBanda)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      final Path caminoAurora = Path();
      for (double x = 0; x <= size.width; x += size.width * 0.05) {
        final double offsetX = x / size.width;
        final double ondulacion = math.sin(
                offsetX * math.pi * 3 + indiceBanda * 0.7) *
            size.height * 0.025;
        if (x == 0) {
          caminoAurora.moveTo(x, yBase + ondulacion);
        } else {
          caminoAurora.lineTo(x, yBase + ondulacion);
        }
      }
      canvas.drawPath(caminoAurora, pincelAurora);
    }

    // Estrellas a tinta con dos tamaños.
    final math.Random rngEstrellas = math.Random(57);
    for (int indice = 0; indice < 120; indice++) {
      final double xEst = rngEstrellas.nextDouble() * size.width;
      final double yEst = rngEstrellas.nextDouble() * size.height * 0.65;
      final double tEst = rngEstrellas.nextDouble();
      canvas.drawCircle(
        Offset(xEst, yEst),
        0.5 + tEst * 1.2,
        Paint()
          ..color = PaletaRotulador.tintaDiluida(0.30 + tEst * 0.40),
      );
    }

    // Luna roja al fondo (única nota de color) con borde tinta.
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.16),
      size.width * 0.06,
      Paint()
        ..color = PaletaRotulador.rojoEstampilla.withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.16),
      size.width * 0.06,
      Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Silueta de montañas a tinta (rayado paralelo para volumen).
    final Path montanas = Path()
      ..moveTo(0, size.height * 0.75)
      ..lineTo(size.width * 0.12, size.height * 0.60)
      ..lineTo(size.width * 0.25, size.height * 0.68)
      ..lineTo(size.width * 0.38, size.height * 0.55)
      ..lineTo(size.width * 0.50, size.height * 0.70)
      ..lineTo(size.width * 0.62, size.height * 0.58)
      ..lineTo(size.width * 0.78, size.height * 0.66)
      ..lineTo(size.width * 0.92, size.height * 0.55)
      ..lineTo(size.width, size.height * 0.70)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      montanas,
      Paint()..color = PaletaRotulador.tintaDiluida(0.70),
    );

    // Copos: pequeños círculos a tinta (nieve sobre papel).
    for (final copo in copos) {
      canvas.drawCircle(
        _r(copo.posicion, size),
        copo.radio,
        Paint()
          ..color = PaletaRotulador.tintaDiluida(0.55),
      );
    }

    // Plataformas con relieve (piedra estriada + nieve esponjada).
    for (final plataforma in plataformas) {
      final Rect rectPlat = _rRect(plataforma, size);
      // Sombra inferior.
      canvas.drawRect(
        Rect.fromLTRB(
            rectPlat.left,
            rectPlat.bottom,
            rectPlat.right,
            rectPlat.bottom + 4),
        Paint()..color = PaletaRotulador.tinta
            .withValues(alpha: 0.45),
      );
      // Piedra base: papel sucio con rayado paralelo de sombra.
      canvas.drawRect(
        rectPlat,
        Paint()..color = PaletaRotulador.papelSucio,
      );
      rayadoParalelo(
        canvas,
        rectPlat,
        pincel: Paint()
          ..color = PaletaRotulador.tintaDiluida(0.45)
          ..strokeWidth = 0.8,
        espaciado: math.max(3.0, rectPlat.height * 0.18),
        intensidadJitter: 0.3,
      );
      // Estrías verticales tenues de piedra.
      for (double xEstria = rectPlat.left + 6;
          xEstria < rectPlat.right;
          xEstria += 12) {
        canvas.drawLine(
          Offset(xEstria, rectPlat.top + rectPlat.height * 0.35),
          Offset(xEstria, rectPlat.bottom - 2),
          Paint()
            ..color = PaletaRotulador.tinta.withValues(alpha: 0.55)
            ..strokeWidth = 0.8,
        );
      }
      // Capa de nieve encima con borde ondulado.
      final Path nieve = Path()
        ..moveTo(rectPlat.left, rectPlat.top + rectPlat.height * 0.45);
      const int curvas = 5;
      for (int indiceCurva = 0; indiceCurva <= curvas; indiceCurva++) {
        final double xCurva = rectPlat.left +
            rectPlat.width * indiceCurva / curvas;
        final double yCurva = rectPlat.top +
            rectPlat.height *
                (0.40 + (indiceCurva.isEven ? 0.05 : -0.05));
        nieve.lineTo(xCurva, yCurva);
      }
      nieve.lineTo(rectPlat.right, rectPlat.top);
      nieve.lineTo(rectPlat.left, rectPlat.top);
      nieve.close();
      canvas.drawPath(
          nieve, Paint()..color = PaletaRotulador.papel);
      // Línea de borde superior de la nieve a tinta.
      canvas.drawLine(
        Offset(rectPlat.left + 4, rectPlat.top + rectPlat.height * 0.18),
        Offset(rectPlat.right - 4, rectPlat.top + rectPlat.height * 0.18),
        Paint()
          ..color = PaletaRotulador.tintaDiluida(0.40)
          ..strokeWidth = 1.0,
      );
      // Contorno negro fino.
      canvas.drawRect(
        rectPlat,
        Paint()
          ..color = PaletaRotulador.tinta
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
      // Pequenas estalactitas de hielo colgando.
      final math.Random rngHielo =
          math.Random(rectPlat.left.toInt() * 13);
      final int numHielos = (rectPlat.width / 36).floor().clamp(1, 6);
      for (int indiceHielo = 0; indiceHielo < numHielos; indiceHielo++) {
        final double xHielo = rectPlat.left + 8 +
            indiceHielo * rectPlat.width / (numHielos + 1) +
            rngHielo.nextDouble() * 4;
        final double altoHielo = 6 + rngHielo.nextDouble() * 8;
        final Path estalactita = Path()
          ..moveTo(xHielo - 3, rectPlat.bottom)
          ..lineTo(xHielo + 3, rectPlat.bottom)
          ..lineTo(xHielo, rectPlat.bottom + altoHielo)
          ..close();
        canvas.drawPath(
          estalactita,
          Paint()
            ..color = PaletaRotulador.papelSucio.withValues(alpha: 0.85),
        );
        canvas.drawPath(
          estalactita,
          Paint()
            ..color = PaletaRotulador.tinta
                .withValues(alpha: 0.65)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8,
        );
      }
    }

    // Banderita roja en una plataforma central (decorativa).
    if (plataformas.length >= 4) {
      final Rect rectPlatCentro = _rRect(plataformas[3], size);
      final double xPoste = rectPlatCentro.left + rectPlatCentro.width * 0.50;
      canvas.drawRect(
        Rect.fromLTWH(xPoste - 1.5,
            rectPlatCentro.top - size.height * 0.10, 3,
            size.height * 0.10),
        Paint()..color = PaletaRotulador.papel,
      );
      final Path bandera = Path()
        ..moveTo(xPoste + 1.5, rectPlatCentro.top - size.height * 0.10)
        ..lineTo(xPoste + size.width * 0.05,
            rectPlatCentro.top - size.height * 0.085)
        ..lineTo(xPoste + 1.5,
            rectPlatCentro.top - size.height * 0.07)
        ..close();
      canvas.drawPath(
          bandera, Paint()..color = PaletaRotulador.rojoEstampilla);
      canvas.drawPath(
        bandera,
        Paint()
          ..color = PaletaRotulador.tinta
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }

    // Bolas de documentos.
    for (final bola in bolasRodantes) {
      final Offset centroBola = _r(bola.posicion, size);
      final double radioBola = bola.radio * size.width;
      canvas.drawCircle(
        centroBola,
        radioBola,
        Paint()..color = PaletaRotulador.papel,
      );
      canvas.drawCircle(
        centroBola,
        radioBola,
        Paint()
          ..color = PaletaRotulador.tinta
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
      // Espirales para sugerir el rolido.
      for (int indiceMarca = 0; indiceMarca < 6; indiceMarca++) {
        final double anguloMarca =
            bola.angulo + indiceMarca * math.pi / 3;
        canvas.drawLine(
          centroBola,
          centroBola.translate(
              math.cos(anguloMarca) * radioBola * 0.9,
              math.sin(anguloMarca) * radioBola * 0.9),
          Paint()
            ..color = PaletaRotulador.tintaDiluida(0.45)
            ..strokeWidth = 1.0,
        );
      }
    }

    // Burocratas Sideralis.
    for (final burocrata in burocratas) {
      _dibujarBurocrata(canvas, burocrata, size);
    }

    // Power-up café soviético flotante (si disponible).
    final Offset? posCafe = posicionCafePowerUp;
    if (posCafe != null) {
      _dibujarPowerUpCafe(canvas, _r(posCafe, size), size);
    }

    // Cadete.
    _dibujarCadeteSnow(canvas, size);
    // Halo del cadete cuando tiene efecto café activo.
    if (cafePowerUpActivo) {
      final Offset centroCadetePx = _r(posicionCadete, size);
      final double radioHalo = size.width * 0.05;
      canvas.drawCircle(
        centroCadetePx,
        radioHalo,
        Paint()
          ..color = PaletaRotulador.rojoEstampilla
              .withValues(alpha: 0.25)
          ..maskFilter =
              const MaskFilter.blur(BlurStyle.normal, 6.0),
      );
    }

    // Formularios disparados.
    for (final formulario in formulariosVolando) {
      final Offset centroForm = _r(formulario.posicion, size);
      canvas.save();
      canvas.translate(centroForm.dx, centroForm.dy);
      canvas.rotate(formulario.rotacion);
      final Rect rectForm = Rect.fromCenter(
        center: Offset.zero,
        width: size.width * 0.025,
        height: size.width * 0.032,
      );
      canvas.drawRect(
        rectForm,
        Paint()..color = PaletaRotulador.papel,
      );
      canvas.drawRect(
        Rect.fromLTWH(rectForm.left, rectForm.top,
            rectForm.width, rectForm.height * 0.18),
        Paint()..color = PaletaRotulador.rojoEstampilla,
      );
      canvas.drawRect(
        rectForm,
        Paint()
          ..color = PaletaRotulador.tinta
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      canvas.restore();
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
              ? '★ INVIERNO LIQUIDADO ★\nPULSA ENTER\nPARA OTRA OPERACIÓN'
              : 'EL FRÍO TE ARCHIVA\nPULSA ENTER\nPARA REINTENTAR',
          style: TextStyle(
            color: partidaGanada
                ? PaletaRotulador.rojoEstampilla
                : PaletaRotulador.rojoEstampilla,
            fontFamily: 'CosmoMono',
            fontSize: size.width * 0.04,
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

  void _dibujarPowerUpCafe(Canvas canvas, Offset centro, Size size) {
    final double anchoCafePx = size.width * 0.045;
    final double altoCafePx = size.height * 0.06;
    // Taza: rectángulo con asa.
    final Rect rectTaza = Rect.fromCenter(
      center: centro,
      width: anchoCafePx,
      height: altoCafePx * 0.85,
    );
    canvas.drawRect(
      rectTaza,
      Paint()..color = PaletaRotulador.papel,
    );
    rectanguloRotulador(
      canvas,
      rectTaza,
      pincel: Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
      intensidadJitter: 0.8,
      semilla: centro.dx + centro.dy,
    );
    // Asa lateral.
    canvas.drawArc(
      Rect.fromCircle(
        center: rectTaza.centerRight.translate(anchoCafePx * 0.30, 0),
        radius: anchoCafePx * 0.30,
      ),
      -math.pi / 2,
      math.pi,
      false,
      Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    // Café dentro (rectángulo rojo).
    final Rect rectLiquido = Rect.fromLTWH(
      rectTaza.left + 3,
      rectTaza.top + 3,
      rectTaza.width - 6,
      rectTaza.height * 0.32,
    );
    canvas.drawRect(
      rectLiquido,
      Paint()..color = PaletaRotulador.rojoEstampilla,
    );
    // Vaho: 3 líneas onduladas hacia arriba.
    for (int indiceVaho = 0; indiceVaho < 3; indiceVaho++) {
      final double xVaho =
          rectTaza.left + rectTaza.width * (0.25 + indiceVaho * 0.25);
      final Path caminoVaho = Path()
        ..moveTo(xVaho, rectTaza.top - 4)
        ..quadraticBezierTo(
          xVaho + 4,
          rectTaza.top - altoCafePx * 0.35,
          xVaho,
          rectTaza.top - altoCafePx * 0.55,
        );
      canvas.drawPath(
        caminoVaho,
        Paint()
          ..color = PaletaRotulador.tintaDiluida(0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
    // Estrella roja sobre la taza (indicador de soviético).
    estrellaRotulador(
      canvas,
      rectTaza.center,
      anchoCafePx * 0.22,
      pincel: Paint()..color = PaletaRotulador.rojoEstampilla,
      intensidadJitter: 0.4,
      semilla: centro.dx,
    );
  }

  void _dibujarCadeteSnow(Canvas canvas, Size size) {
    final Offset centro = _r(posicionCadete, size);
    final double altoSprite =
        _PantallaSnowKamaradaState.radioCadete * size.width * 8.0;
    final bool parpadeoInvulnerable =
        tiempoInvulnerable > 0 && (tiempoInvulnerable * 12).floor().isEven;
    final PoseCadeteMinijuego pose;
    if (!cadeteEnSuelo) {
      pose = PoseCadeteMinijuego.saltando;
    } else if (cadeteMoviendo) {
      pose = PoseCadeteMinijuego.caminando;
    } else {
      pose = PoseCadeteMinijuego.quieto;
    }
    dibujarCadeteCosmonauta(
      canvas,
      centro: centro,
      alto: altoSprite,
      direccionMira: direccionMiraCadete,
      pose: pose,
      fasePaso: fasePasoCadete,
      ushanka: true,
      parpadeoInvulnerable: parpadeoInvulnerable,
    );
  }

  void _dibujarBurocrata(
      Canvas canvas, _CapitalistaEspacial burocrata, Size size) {
    final Offset centro = _r(burocrata.posicion, size);
    final double radio = 0.035 * size.width;
    if (burocrata.convertidoEnBola) {
      // Envuelto en bola de papel sellada con cuño F-447.
      canvas.drawCircle(
        centro,
        radio * 1.30,
        Paint()..color = PaletaRotulador.papel,
      );
      canvas.drawCircle(
        centro,
        radio * 1.30,
        Paint()
          ..color = PaletaRotulador.tinta
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
      // Sello rojo F-447 redondo.
      canvas.drawCircle(
        centro.translate(-radio * 0.3, -radio * 0.1),
        radio * 0.35,
        Paint()
          ..color = PaletaRotulador.rojoEstampilla.withValues(alpha: 0.85),
      );
      final pintorSello = TextPainter(
        text: const TextSpan(
          text: 'F-447',
          style: TextStyle(
            color: PaletaRotulador.papel,
            fontFamily: 'CosmoMono',
            fontSize: 7,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      pintorSello.paint(
        canvas,
        Offset(centro.dx - radio * 0.3 - pintorSello.width / 2,
            centro.dy - radio * 0.1 - pintorSello.height / 2),
      );
      // Pliegues de papel.
      for (int indicePliegue = 0; indicePliegue < 4; indicePliegue++) {
        final double angulo = indicePliegue * math.pi / 2 + 0.3;
        canvas.drawLine(
          centro,
          centro.translate(
              math.cos(angulo) * radio * 1.20,
              math.sin(angulo) * radio * 1.20),
          Paint()
            ..color = PaletaRotulador.tintaDiluida(0.45)
            ..strokeWidth = 1.0,
        );
      }
      return;
    }

    // Traje a rayas vertical (estilo wall-street).
    final Rect rectTraje = Rect.fromCenter(
      center: centro.translate(0, radio * 0.1),
      width: radio * 1.5,
      height: radio * 2.0,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rectTraje, Radius.circular(radio * 0.15)),
      Paint()..color = burocrata.colorTraje,
    );
    // Rayas finas (pinstripes).
    for (int indiceRaya = 1; indiceRaya < 5; indiceRaya++) {
      final double xRaya = rectTraje.left +
          rectTraje.width * (indiceRaya / 5);
      canvas.drawLine(
        Offset(xRaya, rectTraje.top + 2),
        Offset(xRaya, rectTraje.bottom - 2),
        Paint()
          ..color = PaletaRotulador.papel.withValues(alpha: 0.18)
          ..strokeWidth = 0.8,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(rectTraje, Radius.circular(radio * 0.15)),
      Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Camisa blanca con corbata roja.
    final Rect rectCorbata = Rect.fromCenter(
      center: centro.translate(0, radio * 0.15),
      width: radio * 0.30,
      height: radio * 1.40,
    );
    canvas.drawRect(
        rectCorbata, Paint()..color = PaletaRotulador.papel);
    canvas.drawPath(
      Path()
        ..moveTo(rectCorbata.left, rectCorbata.top + 4)
        ..lineTo(rectCorbata.right, rectCorbata.top + 4)
        ..lineTo(rectCorbata.center.dx, rectCorbata.top + 10)
        ..close(),
      Paint()..color = PaletaRotulador.rojoEstampilla.withValues(alpha: 0.9),
    );
    canvas.drawRect(
      Rect.fromLTRB(rectCorbata.left, rectCorbata.top + 10,
          rectCorbata.right, rectCorbata.bottom),
      Paint()..color = PaletaRotulador.rojoEstampilla.withValues(alpha: 0.9),
    );

    // Cabeza humana yanki.
    final Offset centroCabeza = centro.translate(0, -radio * 1.10);
    canvas.drawCircle(
      centroCabeza,
      radio * 0.65,
      Paint()..color = PaletaRotulador.papel,
    );
    canvas.drawCircle(
      centroCabeza,
      radio * 0.65,
      Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // Cara: ojos y sonrisa de comercial.
    canvas.drawCircle(
      centroCabeza.translate(-radio * 0.22, -radio * 0.05),
      radio * 0.07,
      Paint()..color = PaletaRotulador.tinta,
    );
    canvas.drawCircle(
      centroCabeza.translate(radio * 0.22, -radio * 0.05),
      radio * 0.07,
      Paint()..color = PaletaRotulador.tinta,
    );
    canvas.drawArc(
      Rect.fromCircle(
          center: centroCabeza.translate(0, radio * 0.12),
          radius: radio * 0.25),
      0,
      math.pi,
      false,
      Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Sombrero de copa.
    canvas.drawRect(
      Rect.fromCenter(
        center: centroCabeza.translate(0, -radio * 1.00),
        width: radio * 1.05,
        height: radio * 0.90,
      ),
      Paint()..color = PaletaRotulador.tinta,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: centroCabeza.translate(0, -radio * 0.55),
        width: radio * 1.55,
        height: radio * 0.18,
      ),
      Paint()..color = PaletaRotulador.tinta,
    );
    // Banda blanca con estrellas (sobre fondo tinta del sombrero).
    canvas.drawRect(
      Rect.fromCenter(
        center: centroCabeza.translate(0, -radio * 0.65),
        width: radio * 1.05,
        height: radio * 0.18,
      ),
      Paint()..color = PaletaRotulador.papel,
    );
    for (int indiceEstrellita = 0; indiceEstrellita < 3; indiceEstrellita++) {
      canvas.drawCircle(
        centroCabeza.translate(
            (indiceEstrellita - 1) * radio * 0.30, -radio * 0.65),
        radio * 0.05,
        Paint()..color = PaletaRotulador.tinta,
      );
    }

    // Maletin con simbolo $.
    final Rect rectMaletin = Rect.fromCenter(
      center: centro.translate(radio * 0.95, radio * 0.85),
      width: radio * 0.85,
      height: radio * 0.55,
    );
    canvas.drawRect(
        rectMaletin, Paint()..color = PaletaRotulador.tinta);
    canvas.drawRect(
      rectMaletin,
      Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    final pintorDolar = TextPainter(
      text: TextSpan(
        text: r'$',
        style: TextStyle(
          color: PaletaRotulador.papel,
          fontFamily: 'CosmoMono',
          fontSize: radio * 0.5,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintorDolar.paint(
      canvas,
      Offset(rectMaletin.center.dx - pintorDolar.width / 2,
          rectMaletin.center.dy - pintorDolar.height / 2),
    );

    // Capas de papel acumuladas por impactos (envoltura progresiva).
    // Cada impacto le pone un manchon de papel encima del cuerpo.
    if (burocrata.impactosRecibidos > 0 && !burocrata.convertidoEnBola) {
      final Paint pincelPapel = Paint()
        ..color = PaletaRotulador.papel;
      final Paint pincelTrazoPapel = Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      // Lista de zonas a cubrir segun cuantos impactos lleva.
      final List<({Offset offset, double radio})> manchas = <
          ({Offset offset, double radio})>[
        (offset: Offset(-radio * 0.45, radio * 0.30), radio: radio * 0.55),
        (offset: Offset(radio * 0.45, -radio * 0.50), radio: radio * 0.55),
        (offset: Offset(0, radio * 0.05), radio: radio * 0.85),
      ];
      for (int indiceImpacto = 0;
          indiceImpacto < burocrata.impactosRecibidos.clamp(0, 3);
          indiceImpacto++) {
        final mancha = manchas[indiceImpacto];
        canvas.drawCircle(
            centro.translate(mancha.offset.dx, mancha.offset.dy),
            mancha.radio,
            pincelPapel);
        canvas.drawCircle(
            centro.translate(mancha.offset.dx, mancha.offset.dy),
            mancha.radio,
            pincelTrazoPapel);
      }
      // Pequena fila de marcas-tick arriba indicando cuántos impactos.
      for (int impacto = 0;
          impacto < burocrata.impactosRecibidos.clamp(0, 3);
          impacto++) {
        canvas.drawCircle(
          centro.translate((impacto - 1) * radio * 0.30, -radio * 2.60),
          radio * 0.09,
          Paint()..color = PaletaRotulador.rojoEstampilla,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PintorSnowKamarada viejo) => true;
}

const String _flagHighscoreSnow = 'snow_highscore_';

int _leerHighscoreSnow(EstadoJuego estado) {
  for (final flag in estado.flagsActivos) {
    if (flag.startsWith(_flagHighscoreSnow)) {
      return int.tryParse(flag.substring(_flagHighscoreSnow.length)) ?? 0;
    }
  }
  return 0;
}

void _guardarHighscoreSnow(EstadoJuego estado, int puntuacion) {
  estado.flagsActivos.removeWhere(
    (flag) => flag.startsWith(_flagHighscoreSnow),
  );
  estado.activarFlag('$_flagHighscoreSnow$puntuacion');
}
