import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../models/game_class.dart';
import '../painters/stick_figure_painter.dart';
import '../theme.dart';
import 'breathing_stick_figure.dart';
import 'ciclo_frames.dart';
import 'interaction_marker.dart';

class HotspotEscenario {
  final String identificador;
  final Offset posicionRelativa;
  final Widget representacion;
  final double anchoRelativo;
  final double altoRelativo;
  final double radioInteraccion;
  final bool destacar;
  final VoidCallback? onInteractuar;

  /// Si vale `true`, el contenedor del hotspot aplica una oscilación
  /// sutil de respiración a su representación. Por defecto activo para
  /// que los NPCs y objetos no parezcan congelados. Pásalo a `false`
  /// para elementos estructurales (puertas, paneles, archivadores
  /// muertos) que deban quedarse quietos.
  final bool animarRespiracion;

  /// Texto que aparece bajo el marcador de interacción cuando el
  /// cadete está dentro del radio. Por defecto "TRAMITAR". Conviene
  /// personalizarlo para que el cartel sea coherente con la acción
  /// real: "HABLAR" para NPCs, "EXAMINAR" para objetos, "ABRIR" para
  /// compuertas operativas, "CERRADA" para puertas bloqueadas, etc.
  final String etiquetaAccion;

  const HotspotEscenario({
    required this.identificador,
    required this.posicionRelativa,
    required this.representacion,
    this.anchoRelativo = 0.10,
    this.altoRelativo = 0.22,
    this.radioInteraccion = 0.12,
    this.destacar = false,
    this.onInteractuar,
    this.animarRespiracion = true,
    this.etiquetaAccion = 'TRAMITAR',
  });
}

/// GRIETA del escenario: zona rectangular pintada en el suelo donde
/// sólo el cadete en MODO BOLA puede entrar. Si el cadete normal pasa
/// por encima no ocurre nada (la grieta es demasiado baja). Si la
/// bola está sobre la grieta durante [tiempoRodaduraNecesarioSegundos]
/// segundos, se dispara [onAtravesarEnBola]. Pensado para abrir
/// minijuegos ocultos, conceder insignias o conectar con habitaciones
/// secretas.
class GrietaEscenario {
  final String identificador;

  /// Rectángulo en coordenadas relativas 0..1 del mundo.
  final Rect rect;

  /// Texto que aparece en la etiqueta cuando estás en modo bola dentro.
  final String etiqueta;

  /// Disparado tras rodar el tiempo necesario dentro del rect.
  final VoidCallback onAtravesarEnBola;

  /// Cuánto tiempo (en segundos) tiene que estar la bola dentro para
  /// que se dispare. Por defecto 0.45 s — suficiente para que rodar
  /// sea intencional pero no agotador.
  final double tiempoRodaduraNecesarioSegundos;

  const GrietaEscenario({
    required this.identificador,
    required this.rect,
    required this.onAtravesarEnBola,
    this.etiqueta = 'GRIETA',
    this.tiempoRodaduraNecesarioSegundos = 0.45,
  });
}

/// OBJETO EMPUJABLE: bulto en el suelo (caja, archivador, taburete)
/// que el cadete puede mover empujándolo al caminar contra él. Como
/// está mutable, se modela con un wrapper que el escenario actualiza
/// frame a frame. Si pones una grieta debajo de su posición inicial,
/// el cadete tendrá que empujarlo primero para revelar la grieta.
class ObjetoEmpujable {
  final String identificador;

  /// Posición actual del centro del objeto en coordenadas relativas.
  Offset posicion;

  /// Radio relativo de su cuerpo (también usado para colisión).
  final double radio;

  /// Etiqueta corta dibujada encima (ej. "F-447", "CAJA", "ARCHIVO").
  final String etiqueta;

  /// Factor de "rozamiento" — cuánto avanza el objeto en proporción
  /// al movimiento del cadete. 0 = no se mueve; 1 = se mueve igual.
  final double factorEmpuje;

  /// Posición original del objeto al instanciarse, para detectar cuándo
  /// se ha desplazado lo bastante como para disparar [onMovidoLejos].
  final Offset _posicionInicial;

  /// Disparado una sola vez la primera vez que la distancia entre la
  /// posición actual y la inicial supera [distanciaMinimaParaEvento].
  /// Útil para revelar objetos ocultos debajo del bulto (sellos, notas,
  /// trampillas).
  final VoidCallback? onMovidoLejos;

  /// Umbral en unidades relativas (0..1) para considerar que el objeto
  /// se ha movido "lejos" de su posición inicial. Por defecto 0.04
  /// (un 4 % del ancho del mundo).
  final double distanciaMinimaParaEvento;

  /// Estado interno: true tras disparar [onMovidoLejos], para no
  /// repetirlo en frames sucesivos.
  bool _eventoMovimientoDisparado = false;

  ObjetoEmpujable({
    required this.identificador,
    required this.posicion,
    this.radio = 0.045,
    this.etiqueta = '',
    this.factorEmpuje = 0.55,
    this.onMovidoLejos,
    this.distanciaMinimaParaEvento = 0.04,
  }) : _posicionInicial = posicion;
}

/// BOLOS: pinos de bolera dispuestos en formación triangular. Sólo
/// el cadete en MODO BOLA los puede tirar (la bola es lo bastante
/// "pesada" para volcarlos). Se respawnean tras [segundosHastaRevivir]
/// segundos cuando todos están caídos.
class BoloDecorativo {
  final String identificador;

  /// Posición del pino. No cambia durante la vida del juego.
  final Offset posicion;
  final double radio;

  /// Estado actual: `false` = de pie, `true` = caído.
  bool tirado;

  /// Tiempo de "ondulación" tras ser tirado, para dibujar el rebote.
  double fasesCaida;

  BoloDecorativo({
    required this.identificador,
    required this.posicion,
    this.radio = 0.018,
  }) : tirado = false,
       fasesCaida = 0;
}

/// PARED DÉBIL: pared rectangular que bloquea al cadete y a la bola
/// en condiciones normales, PERO se rompe si la bola impacta con
/// velocidad superior a [velocidadRupturaRelativa]. Una vez rota,
/// queda libre el paso (la pared desaparece de la lógica de colisión
/// y del dibujado durante el resto de la sesión del escenario).
class ParedDebilEscenario {
  final String identificador;
  final Rect rect;

  /// Etiqueta corta dibujada sobre la pared para advertir "ROMPER".
  final String etiqueta;

  /// Si vale `true`, ya ha sido rota; deja de bloquear.
  bool rota;

  /// Fase de animación de explosión al romperse (decae 1→0).
  double faseRotura;

  /// Disparado una sola vez en el frame en que [rota] pasa a true.
  /// Útil para revelar grafitis, conceder insignias o abrir grietas
  /// detrás de la pared.
  final VoidCallback? onRomperse;

  ParedDebilEscenario({
    required this.identificador,
    required this.rect,
    this.etiqueta = 'PARED FRÁGIL',
    this.onRomperse,
  }) : rota = false,
       faseRotura = 0;
}

/// INTERRUPTOR DE PRESIÓN: placa rectangular en el suelo que sólo
/// se activa cuando el cadete está EN MODO BOLA encima (la masa de
/// la bola pulsa la placa; el cadete erguido es demasiado ligero).
/// Mientras esté pulsada, [onPulsar] se llama una vez; al salir
/// se llama [onSoltar] (opcional). Útil para puertas, luces, etc.
class InterruptorPresion {
  final String identificador;
  final Rect rect;
  final String etiqueta;
  bool pulsado;
  final VoidCallback onPulsar;
  final VoidCallback? onSoltar;

  InterruptorPresion({
    required this.identificador,
    required this.rect,
    required this.onPulsar,
    this.onSoltar,
    this.etiqueta = 'PLACA',
  }) : pulsado = false;
}

/// Configuración de la mascota cosmonauta que acompaña al cadete por
/// el escenario. Inspirada en Laika — una gatita-perra con su propio
/// casco. Sigue al cadete con suavizado lerp, se sienta cuando el
/// cadete está quieto y reacciona en modo bola.
class ConfiguracionMascota {
  /// Nombre mostrado en el bocadillo ocasional (default: "Laika").
  final String nombre;

  /// Posición de aparición inicial (relativa). Por defecto al lado
  /// del cadete.
  final Offset? posicionInicial;

  /// Distancia de seguimiento detrás del cadete (en unidades
  /// relativas del mundo, ej. 0.06 = ~6% del ancho).
  final double distanciaSeguimiento;

  /// Factor lerp por frame (0..1). Bajo = se queda atrás; alto = se
  /// pega como una sombra.
  final double suavizadoSeguimiento;

  /// Tamaño relativo del sprite (alto). Por defecto 0.06.
  final double altoRelativo;

  /// Frases que la mascota suelta de vez en cuando.
  final List<String> frases;

  const ConfiguracionMascota({
    this.nombre = 'Laika',
    this.posicionInicial,
    this.distanciaSeguimiento = 0.05,
    this.suavizadoSeguimiento = 0.10,
    this.altoRelativo = 0.07,
    this.frases = const <String>[
      'Guau, camarada.',
      'Anota el F-447.',
      'Por aquí, ¡rápido!',
      'Esto huele a comité.',
      'El Inspector se acerca.',
    ],
  });
}

/// Aplica una oscilación lenta vertical + escala muy sutil a un widget
/// hijo, para que los NPCs y objetos de fondo no parezcan calcomanías
/// pegadas al escenario. El periodo y la fase se derivan del
/// identificador para que distintos hotspots no respiren al unísono.
class _HotspotConRespiracion extends StatefulWidget {
  final Widget hijo;
  final String semilla;

  const _HotspotConRespiracion({required this.hijo, required this.semilla});

  @override
  State<_HotspotConRespiracion> createState() => _HotspotConRespiracionState();
}

class _HotspotConRespiracionState extends State<_HotspotConRespiracion>
    with SingleTickerProviderStateMixin {
  late final AnimationController controladorRespiracion;
  late final double desfaseFaseInicial;
  late final double periodoSegundos;

  @override
  void initState() {
    super.initState();
    final int hash = widget.semilla.hashCode;
    // Periodo entre 2.4 s y 3.6 s, desfase inicial 0..1.
    periodoSegundos = 2.4 + ((hash & 0xFF) / 255.0) * 1.2;
    desfaseFaseInicial = ((hash >> 8) & 0xFF) / 255.0;
    controladorRespiracion = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (periodoSegundos * 1000).round()),
    )..repeat();
  }

  @override
  void dispose() {
    controladorRespiracion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controladorRespiracion,
      builder: (contexto, hijoOpcional) {
        final double fase =
            (controladorRespiracion.value + desfaseFaseInicial) % 1.0;
        final double ondaSeno = math.sin(fase * math.pi * 2);
        final double desplazamientoY = ondaSeno * 1.4;
        final double factorEscala = 1.0 + ondaSeno * 0.012;
        return Transform.translate(
          offset: Offset(0, desplazamientoY),
          child: Transform.scale(
            scale: factorEscala,
            alignment: Alignment.bottomCenter,
            child: hijoOpcional,
          ),
        );
      },
      child: widget.hijo,
    );
  }
}

class EscenarioLibre extends StatefulWidget {
  /// Painter procedimental del fondo del escenario. Se usa cuando
  /// [rutaImagenFondo] es null. Si ambos se proporcionan, el PNG
  /// gana (el painter queda como fallback documental).
  final CustomPainter? pintorFondo;

  /// Ruta opcional a un PNG que sustituye al [pintorFondo]. Cuando
  /// se da, el fondo del escenario se renderiza como `Image.asset`
  /// en lugar del CustomPaint procedimental.
  final String? rutaImagenFondo;
  final List<HotspotEscenario> hotspots;
  final ClaseCosmonauta? claseJugador;
  final Offset posicionInicialJugador;
  final Offset? puntoEntradaInicial;
  final Offset? puntoSalidaActiva;
  final VoidCallback? alCompletarSalida;
  final double anchoJugadorRelativo;
  final double altoJugadorRelativo;
  final ValueChanged<String>? onRegistrar;
  final String? idSombreroEquipado;
  final String? idArmaEquipada;
  final String? idTorsoEquipado;

  /// Widget opcional renderizado entre el fondo y los hotspots, pensado para
  /// capas atmosféricas (ceniza, nieve, humo, chispas) específicas del planeta.
  final Widget? capaAmbiental;

  /// Disparado cuando el cadete introduce un código de teclado oculto en el
  /// mundo libre. El padre decide cómo reaccionar (normalmente, desbloquear
  /// una insignia). Identificadores actualmente soportados:
  /// `konami_invertido` (↓↓↑↑→←→←).
  final void Function(String identificadorCodigo)? onCodigoSecreto;

  /// Disparado cada vez que el cadete pulsa la tecla de interacción (E/Espacio
  /// /Enter) y NO hay ningún hotspot dentro del radio de alcance. Útil para
  /// huevos de pascua que reaccionan al «pulgar burocrático ocioso».
  final VoidCallback? onPulsacionInteraccionOciosa;

  /// Disparado tras [segundosQuietudParaEvento] segundos del peón inmóvil
  /// sin destino. Permite que el padre dispare eventos sutiles (susurro,
  /// archivo, insignia oculta). Para evitar disparos repetidos, sólo se
  /// llama una vez por periodo de quietud.
  final VoidCallback? onCadeteQuietoLargoRato;

  final double segundosQuietudParaEvento;

  /// Multiplicador del ancho del mundo respecto al viewport. `1.0` significa
  /// "el mundo cabe entero en pantalla" (sin scroll). `2.0` significa el
  /// doble: la cámara horizontal sigue al peón con clamp en los bordes.
  /// Las coordenadas relativas (0..1) se interpretan sobre el ancho del
  /// mundo, no del viewport.
  final double factorAnchoMundo;

  /// Límite superior del área caminable del cadete en coordenadas relativas
  /// (0..1). Sube este valor cuando el escenario pinta paredes o muros
  /// altos en la mitad superior del lienzo (de lo contrario el peón "se
  /// sube por la pared").
  final double bordeSuperior;
  final double bordeInferior;
  final double bordeIzquierdoArea;
  final double bordeDerechoArea;

  /// Obstáculos rectangulares (paredes, mesas, archivadores) en
  /// coordenadas relativas 0..1 sobre el ancho del mundo. El cadete no
  /// puede entrar dentro y desliza al chocar.
  final List<Rect> obstaculos;

  /// Grietas que sólo el cadete en modo bola puede atravesar. Útiles
  /// para conectar a minijuegos ocultos o desbloqueos.
  final List<GrietaEscenario> grietas;

  /// Objetos que el cadete a pie puede empujar caminando.
  final List<ObjetoEmpujable> objetosEmpujables;

  /// Bolos burocráticos que la bola tira al pasar por encima.
  final List<BoloDecorativo> bolos;
  final ValueChanged<int>? onTodosBolosTirados;

  /// Paredes rompibles por impacto de la bola con velocidad alta.
  final List<ParedDebilEscenario> paredesDebiles;

  /// Interruptores de presión que sólo la bola pulsa.
  final List<InterruptorPresion> interruptores;

  /// Mascota acompañante (Laika cosmonauta). `null` = sin mascota.
  final ConfiguracionMascota? mascota;

  const EscenarioLibre({
    super.key,
    this.pintorFondo,
    required this.hotspots,
    required this.claseJugador,
    this.rutaImagenFondo,
    this.posicionInicialJugador = const Offset(0.1, 0.86),
    this.puntoEntradaInicial,
    this.puntoSalidaActiva,
    this.alCompletarSalida,
    this.anchoJugadorRelativo = 0.08,
    this.altoJugadorRelativo = 0.21,
    this.onRegistrar,
    this.idSombreroEquipado,
    this.idArmaEquipada,
    this.idTorsoEquipado,
    this.capaAmbiental,
    this.factorAnchoMundo = 1.0,
    this.onCodigoSecreto,
    this.onPulsacionInteraccionOciosa,
    this.onCadeteQuietoLargoRato,
    this.segundosQuietudParaEvento = 4.0,
    // Defaults restaurados a los originales tras corregir el bug raíz
    // (BoxFit.cover recortaba el fondo, lo que desalineaba las
    // coordenadas Y). Con BoxFit.fill las coordenadas relativas
    // coinciden con lo dibujado: la línea del suelo está al ~92% del
    // alto del fondo, y la pared/techo al ~55%. Si un escenario tiene
    // su suelo a otra altura, puede seguir sobrescribiendo.
    this.bordeSuperior = 0.55,
    this.bordeInferior = 0.92,
    this.bordeIzquierdoArea = 0.05,
    this.bordeDerechoArea = 0.95,
    this.obstaculos = const <Rect>[],
    this.grietas = const <GrietaEscenario>[],
    this.objetosEmpujables = const <ObjetoEmpujable>[],
    this.bolos = const <BoloDecorativo>[],
    this.onTodosBolosTirados,
    this.paredesDebiles = const <ParedDebilEscenario>[],
    this.interruptores = const <InterruptorPresion>[],
    this.mascota,
  });

  @override
  State<EscenarioLibre> createState() => _EscenarioLibreState();
}

class _EscenarioLibreState extends State<EscenarioLibre>
    with SingleTickerProviderStateMixin {
  /// Velocidad de desplazamiento expresada en unidades relativas (0..1) por
  /// segundo. Ajustada para que cruzar la pantalla cueste ~2.2 s.
  static const double velocidadRelativaCaminar = 0.45;

  /// Multiplicador de velocidad al mantener Shift (correr).
  static const double multiplicadorSprint = 1.85;

  /// Desplazamiento vertical (px) que sube la sombra del cadete /
  /// mascota / bola respecto a su posición lógica. Cambia esto si
  /// los nuevos fondos PNG mueven la línea visual del suelo.
  static const double offsetVerticalSombraPx = 50.0;

  double get bordeIzquierdo => widget.bordeIzquierdoArea;
  double get bordeDerecho => widget.bordeDerechoArea;
  double get bordeSuperior => widget.bordeSuperior;
  double get bordeInferior => widget.bordeInferior;

  late Ticker tickerMovimiento;
  Duration? marcaTemporalAnterior;

  Offset posicionJugador = const Offset(0.1, 0.78);
  bool _orientadoDerecha = true;
  bool _moviendoseEsteFrame = false;

  /// True durante un frame en el que el cadete está apoyado contra
  /// un objeto empujable Y avanzando hacia él, para inclinar el
  /// sprite como si lo estuviera empujando con el cuerpo.
  bool _empujandoEsteFrame = false;

  /// Destino al que el peón intenta llegar tras un clic. Se cancela si el
  /// usuario empieza a mover con teclas.
  Offset? destinoClic;
  String? idHotspotPendienteInteraccion;

  /// Punto al que el peón debe llegar para que se dispare `alCompletarSalida`.
  /// Activado externamente al cambiar `puntoSalidaActiva`.
  Offset? destinoSalida;

  final Set<LogicalKeyboardKey> teclasActivas = <LogicalKeyboardKey>{};

  /// Última marca temporal en la que el navegador reportó actividad de cada
  /// tecla (KeyDown o KeyRepeat). Si una tecla queda en [teclasActivas] sin
  /// recibir actividad reciente, el ticker la considera zombie y la elimina.
  /// Sin este watchdog, una tecla cuyo KeyUp se pierde durante un modal
  /// quedaría arrastrando al peón indefinidamente hacia esa dirección.
  final Map<LogicalKeyboardKey, DateTime> _ultimaActividadTecla =
      <LogicalKeyboardKey, DateTime>{};
  static const Duration _toleranciaSinActividadTecla = Duration(
    milliseconds: 220,
  );
  final FocusNode nodoFoco = FocusNode(debugLabel: 'escenario_libre_teclado');

  /// MODO BOLA: el cadete se hace una bola rodante con mayor velocidad y
  /// la capacidad de saltar obstáculos pequeños. Se activa con la tecla R
  /// y mientras dura un salto los obstáculos rectangulares se ignoran.
  bool modoBolaActivo = false;

  /// Acumulador de avance del cadete caminando (no bola). Sólo crece
  /// cuando el cadete se mueve realmente; sirve para indexar el
  /// walk-cycle de 4 frames sin que el ciclo avance al estar quieto.
  double _avanceCaminadoCadete = 0;
  double segundosRodando = 0;
  double segundosSaltoRestante = 0;
  static const double duracionSaltoBolaSegundos = 0.48;
  static const double multiplicadorVelocidadBola = 1.55;

  /// Tiempo acumulado rodando dentro de cada grieta (clave =
  /// identificador). Cuando supera `tiempoRodaduraNecesarioSegundos`
  /// se dispara el callback y la grieta entra en cooldown.
  final Map<String, double> _segundosEnGrieta = <String, double>{};
  final Map<String, double> _cooldownGrieta = <String, double>{};
  static const double cooldownGrietaSegundos = 2.5;

  /// Estado de la mascota: posición actual, dirección, fase de paso,
  /// frase activa y temporizador. Sólo se inicializa si hay mascota.
  Offset posicionMascota = const Offset(0.05, 0.85);
  bool mascotaMirandoDerecha = true;
  double faseAndarMascota = 0;
  bool mascotaSentada = false;
  double segundosQuietaMascota = 0;
  String? fraseMascotaActiva;
  double tiempoFraseMascotaRestante = 0;
  double segundosHastaSiguienteFraseMascota = 12;

  /// Laika usa su animación de olfato como pista diegética cuando el
  /// cadete se acerca a un secreto físico que todavía no ha resuelto.
  /// El radio es corto a propósito: insinúa "aquí hay algo" sin señalar
  /// la solución desde media sala.
  bool get _laikaDetectaRastro {
    if (widget.mascota == null) return false;
    const double radioOlfato = 0.16;
    bool cercaDe(Offset punto) =>
        (posicionJugador - punto).distance <= radioOlfato;

    for (final grieta in widget.grietas) {
      if (cercaDe(grieta.rect.center)) return true;
    }
    for (final pared in widget.paredesDebiles) {
      if (!pared.rota && cercaDe(pared.rect.center)) return true;
    }
    for (final interruptor in widget.interruptores) {
      if (!interruptor.pulsado && cercaDe(interruptor.rect.center)) {
        return true;
      }
    }
    for (final objeto in widget.objetosEmpujables) {
      if (!objeto._eventoMovimientoDisparado &&
          objeto.onMovidoLejos != null &&
          cercaDe(objeto.posicion)) {
        return true;
      }
    }
    return false;
  }

  /// Partículas de polvo bajo los pies. Se generan periódicamente mientras
  /// el peón se desplaza y desaparecen tras un tiempo corto, dando feedback
  /// kinestésico al movimiento.
  final List<_PolvoPisada> polvoPisadas = [];
  double segundosDesdeUltimoPolvo = 0;
  static const double intervaloSpawnPolvo = 0.16;
  static const double vidaPolvoSegundos = 0.55;

  /// Acumula segundos sin movimiento real del peón. Cuando supera
  /// [EscenarioLibre.segundosQuietudParaEvento] se dispara el callback
  /// `onCadeteQuietoLargoRato` una vez por periodo de quietud.
  double segundosQuieto = 0;
  bool eventoQuietudDisparadoYa = false;

  static final Set<LogicalKeyboardKey> teclasArriba = {
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.keyW,
  };
  static final Set<LogicalKeyboardKey> teclasAbajo = {
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.keyS,
  };
  static final Set<LogicalKeyboardKey> teclasIzquierda = {
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.keyA,
  };
  static final Set<LogicalKeyboardKey> teclasDerecha = {
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.keyD,
  };
  static final Set<LogicalKeyboardKey> teclasInteraccion = {
    LogicalKeyboardKey.keyE,
    LogicalKeyboardKey.space,
    LogicalKeyboardKey.enter,
    LogicalKeyboardKey.numpadEnter,
  };

  /// Buffer rotatorio de las últimas direcciones canónicas pulsadas para
  /// detectar códigos secretos como el Konami invertido.
  final List<String> bufferDireccionesRecientes = <String>[];
  static const List<String> secuenciaKonamiInvertido = [
    'down',
    'down',
    'up',
    'up',
    'right',
    'left',
    'right',
    'left',
  ];

  static final Set<LogicalKeyboardKey> teclasSprint = {
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.shiftRight,
  };

  @override
  void initState() {
    super.initState();
    // El peón aparece directamente en su posición inicial, sin caminar desde
    // un punto de entrada. La animación de entrada generaba la sensación de
    // que el cadete "se iba solo a la derecha" cada vez que se cargaba una
    // escena con un modal de bienvenida superpuesto.
    posicionJugador = widget.posicionInicialJugador;
    if (widget.mascota != null) {
      posicionMascota =
          widget.mascota!.posicionInicial ??
          posicionJugador.translate(-widget.mascota!.distanciaSeguimiento, 0);
    }
    tickerMovimiento = createTicker(_alTickFrame)..start();
    nodoFoco.addListener(_alCambiarFoco);
  }

  /// Al perder el foco (porque se abrió un diálogo, otra ventana o el
  /// navegador se desactivó), descartamos las teclas direccionales activas
  /// para evitar que queden "pegadas" cuando vuelva el foco — si no, el peón
  /// seguiría moviéndose en la última dirección pulsada antes de la
  /// interrupción. También cancelamos el destino del clic en curso: si el
  /// jugador abre un diálogo a mitad de un paseo, al cerrarlo no queremos
  /// que el peón siga caminando solo.
  void _alCambiarFoco() {
    if (teclasActivas.isNotEmpty) {
      teclasActivas.clear();
    }
    _ultimaActividadTecla.clear();
    final perdioFoco = !nodoFoco.hasFocus;
    if (perdioFoco && destinoSalida == null) {
      destinoClic = null;
      idHotspotPendienteInteraccion = null;
    }
  }

  @override
  void didUpdateWidget(covariant EscenarioLibre viejo) {
    super.didUpdateWidget(viejo);
    if (widget.puntoSalidaActiva != null &&
        viejo.puntoSalidaActiva != widget.puntoSalidaActiva) {
      destinoSalida = widget.puntoSalidaActiva;
      destinoClic = widget.puntoSalidaActiva;
      idHotspotPendienteInteraccion = null;
      teclasActivas.clear();
    }
  }

  @override
  void dispose() {
    tickerMovimiento.dispose();
    nodoFoco.removeListener(_alCambiarFoco);
    nodoFoco.dispose();
    super.dispose();
  }

  void _alTickFrame(Duration tiempoAcumulado) {
    final marcaAnterior = marcaTemporalAnterior;
    marcaTemporalAnterior = tiempoAcumulado;
    if (marcaAnterior == null) return;
    final segundosTranscurridos =
        (tiempoAcumulado - marcaAnterior).inMicroseconds / 1e6;
    if (segundosTranscurridos <= 0) return;

    // Watchdog de teclas zombie: si una tecla en `teclasActivas` lleva más
    // de [_toleranciaSinActividadTecla] sin recibir KeyDown o KeyRepeat, el
    // navegador probablemente perdió el evento KeyUp (suele pasar al abrir
    // un modal o cambiar de pestaña). La consideramos soltada para evitar
    // que el peón se desplace solo en esa dirección.
    final ahora = DateTime.now();
    teclasActivas.removeWhere((tecla) {
      final ultima = _ultimaActividadTecla[tecla];
      if (ultima == null) return true;
      if (ahora.difference(ultima) > _toleranciaSinActividadTecla) {
        _ultimaActividadTecla.remove(tecla);
        return true;
      }
      return false;
    });

    Offset vectorDireccion = _calcularDireccionTeclado();
    final hayMovimientoPorTeclado = vectorDireccion != Offset.zero;

    // Si hay movimiento por teclado, cancelamos cualquier destino de clic
    // (excepto la salida automática, que es prioritaria).
    if (hayMovimientoPorTeclado &&
        destinoSalida == null &&
        destinoClic != null) {
      destinoClic = null;
      idHotspotPendienteInteraccion = null;
    }

    Offset posicionTentativa = posicionJugador;
    bool huboDesplazamiento = false;

    if (hayMovimientoPorTeclado) {
      final magnitud = vectorDireccion.distance;
      if (magnitud > 0) {
        vectorDireccion = vectorDireccion / magnitud;
      }
      final correUsuario = teclasActivas.any((t) => teclasSprint.contains(t));
      double velocidadEfectiva = correUsuario
          ? velocidadRelativaCaminar * multiplicadorSprint
          : velocidadRelativaCaminar;
      if (modoBolaActivo) {
        velocidadEfectiva *= multiplicadorVelocidadBola;
      }
      posicionTentativa =
          posicionJugador +
          vectorDireccion * velocidadEfectiva * segundosTranscurridos;
      huboDesplazamiento = true;
    } else if (destinoClic != null) {
      final destino = destinoClic!;
      final diferencia = destino - posicionJugador;
      final distancia = diferencia.distance;
      final pasoMaximo = velocidadRelativaCaminar * segundosTranscurridos;
      if (distancia <= pasoMaximo || distancia < 0.004) {
        posicionTentativa = destino;
        huboDesplazamiento = distancia > 0.0005;
      } else {
        final direccionNormalizada = diferencia / distancia;
        posicionTentativa = posicionJugador + direccionNormalizada * pasoMaximo;
        huboDesplazamiento = true;
      }
    }

    posicionTentativa = Offset(
      posicionTentativa.dx.clamp(bordeIzquierdo, bordeDerecho),
      posicionTentativa.dy.clamp(bordeSuperior, bordeInferior),
    );
    // Durante un salto en modo bola, ignoramos las colisiones con
    // obstáculos rectangulares (el cadete pasa por encima en el arco).
    if (segundosSaltoRestante <= 0) {
      posicionTentativa = _resolverColisionObstaculos(
        posicionJugador,
        posicionTentativa,
      );
    }
    if (modoBolaActivo) {
      // Sólo acumulamos rotación cuando la bola se mueve de verdad.
      // Una bola quieta no rota — y el ciclo de 4 frames PNG da
      // tirones si lo dejamos avanzar sin desplazamiento. Usamos el
      // flag del frame anterior (1 frame de lag, imperceptible).
      if (_moviendoseEsteFrame) {
        segundosRodando += segundosTranscurridos;
      }
    } else if (_moviendoseEsteFrame) {
      // Mismo principio para el walk-cycle del cadete a pie.
      _avanceCaminadoCadete += segundosTranscurridos;
    } else {
      segundosRodando = 0;
    }
    if (segundosSaltoRestante > 0) {
      segundosSaltoRestante -= segundosTranscurridos;
      if (segundosSaltoRestante < 0) segundosSaltoRestante = 0;
    }
    // OBJETOS EMPUJABLES: si el cadete (en cualquier modo) avanza
    // contra el cuerpo de un objeto, le aplicamos un empuje
    // proporcional a su factor. El objeto se queda clamped al área
    // caminable y respeta los obstáculos. Si dos objetos chocan
    // entre ellos, se ignoran (no enrollamos cadena).
    bool empujandoAlgun = false;
    for (final objeto in widget.objetosEmpujables) {
      final Offset diferencia = posicionTentativa - objeto.posicion;
      final double distancia = diferencia.distance;
      // Radio ajustado a la silueta visual del cadete (no a su
      // bounding box, que incluye aire lateral). Antes era
      // anchoJugadorRelativo / 2 = 0.04 → se empujaba la caja
      // sin tocarla.
      final double radioColisionObjeto =
          objeto.radio + widget.anchoJugadorRelativo * 0.25;
      if (distancia < radioColisionObjeto && distancia > 0) {
        empujandoAlgun = true;
        // Calcula cuánto está penetrando el cadete dentro del objeto
        // y empuja al objeto en esa misma dirección.
        final Offset normalEmpuje = diferencia / distancia;
        final double penetracion = radioColisionObjeto - distancia;
        final Offset desplazamientoObjeto =
            normalEmpuje * penetracion * objeto.factorEmpuje;
        Offset nuevaPosObjeto = objeto.posicion - desplazamientoObjeto;
        // Clamp del objeto al área caminable y respeto a obstáculos.
        nuevaPosObjeto = Offset(
          nuevaPosObjeto.dx.clamp(bordeIzquierdo, bordeDerecho),
          nuevaPosObjeto.dy.clamp(bordeSuperior, bordeInferior),
        );
        if (!_estaDentroDeObstaculo(nuevaPosObjeto)) {
          objeto.posicion = nuevaPosObjeto;
        }
        // Y al cadete lo empujamos en sentido contrario para que no
        // atraviese el objeto.
        posicionTentativa =
            objeto.posicion + normalEmpuje * radioColisionObjeto * 1.001;
        // Si el objeto se aleja lo suficiente de su posición original,
        // dispara una sola vez su callback (revelar lo que había debajo).
        if (!objeto._eventoMovimientoDisparado &&
            objeto.onMovidoLejos != null) {
          final double desvio =
              (objeto.posicion - objeto._posicionInicial).distance;
          if (desvio >= objeto.distanciaMinimaParaEvento) {
            objeto._eventoMovimientoDisparado = true;
            objeto.onMovidoLejos!();
          }
        }
      }
    }
    _empujandoEsteFrame = empujandoAlgun;

    // BOLOS: si la bola toca un pino aún de pie, lo derriba. Si
    // todos están tirados, notificamos al padre. Tras N segundos
    // sin toca pino activo, los pinos vuelven a aparecer.
    if (modoBolaActivo) {
      for (final pino in widget.bolos) {
        if (pino.tirado) continue;
        final double distanciaPino =
            (posicionTentativa - pino.posicion).distance;
        if (distanciaPino < pino.radio + widget.anchoJugadorRelativo / 2) {
          pino.tirado = true;
          pino.fasesCaida = 1.0;
        }
      }
      if (widget.bolos.isNotEmpty &&
          widget.bolos.every((pino) => pino.tirado)) {
        widget.onTodosBolosTirados?.call(widget.bolos.length);
        // Levantar los pinos tras 2.5 s.
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (!mounted) return;
          setState(() {
            for (final pino in widget.bolos) {
              pino.tirado = false;
              pino.fasesCaida = 0;
            }
          });
        });
      }
    }
    // Animación de caída: la fase decae con el tiempo.
    for (final pino in widget.bolos) {
      if (pino.fasesCaida > 0) {
        pino.fasesCaida = math.max(
          0,
          pino.fasesCaida - segundosTranscurridos * 1.6,
        );
      }
    }

    // PAREDES DÉBILES: bloquean cadete y bola como obstáculo normal
    // a menos que la BOLA impacte con velocidad superior al umbral
    // → entonces se rompen. La velocidad de la bola se infiere del
    // desplazamiento del frame (modoBola escala movimiento).
    final double velocidadDesplazamientoCadete =
        (posicionTentativa - posicionJugador).distance /
        math.max(0.0001, segundosTranscurridos);
    for (final pared in widget.paredesDebiles) {
      if (pared.rota) continue;
      if (pared.rect.contains(posicionTentativa)) {
        // Está dentro: si va deprisa Y modo bola → ROMPER.
        if (modoBolaActivo && velocidadDesplazamientoCadete > 0.55) {
          pared.rota = true;
          pared.faseRotura = 1.0;
          pared.onRomperse?.call();
        } else {
          // Empujamos al cadete fuera por el lado más cercano.
          final double diferenciaIzq = (posicionTentativa.dx - pared.rect.left)
              .abs();
          final double diferenciaDer = (pared.rect.right - posicionTentativa.dx)
              .abs();
          final double diferenciaArr = (posicionTentativa.dy - pared.rect.top)
              .abs();
          final double diferenciaAba =
              (pared.rect.bottom - posicionTentativa.dy).abs();
          final double menor = math.min(
            math.min(diferenciaIzq, diferenciaDer),
            math.min(diferenciaArr, diferenciaAba),
          );
          if (menor == diferenciaIzq) {
            posicionTentativa = Offset(
              pared.rect.left - 0.001,
              posicionTentativa.dy,
            );
          } else if (menor == diferenciaDer) {
            posicionTentativa = Offset(
              pared.rect.right + 0.001,
              posicionTentativa.dy,
            );
          } else if (menor == diferenciaArr) {
            posicionTentativa = Offset(
              posicionTentativa.dx,
              pared.rect.top - 0.001,
            );
          } else {
            posicionTentativa = Offset(
              posicionTentativa.dx,
              pared.rect.bottom + 0.001,
            );
          }
        }
      }
    }
    // Decaer fase de rotura.
    for (final pared in widget.paredesDebiles) {
      if (pared.faseRotura > 0) {
        pared.faseRotura = math.max(
          0,
          pared.faseRotura - segundosTranscurridos * 1.4,
        );
      }
    }

    // INTERRUPTORES DE PRESIÓN: la bola pulsa, el cadete normal no.
    for (final interruptor in widget.interruptores) {
      final bool dentro =
          modoBolaActivo && interruptor.rect.contains(posicionTentativa);
      if (dentro && !interruptor.pulsado) {
        interruptor.pulsado = true;
        interruptor.onPulsar();
      } else if (!dentro && interruptor.pulsado) {
        interruptor.pulsado = false;
        interruptor.onSoltar?.call();
      }
    }

    // GRIETAS: si estamos en modo bola sobre una grieta sin cooldown,
    // acumulamos tiempo. Al cruzar el umbral disparamos el callback.
    // El cadete normal no acumula nada (la grieta es "demasiado baja").
    _cooldownGrieta.updateAll(
      (id, valor) => math.max(0, valor - segundosTranscurridos),
    );
    if (modoBolaActivo) {
      for (final grieta in widget.grietas) {
        final bool dentro = grieta.rect.contains(posicionTentativa);
        if (dentro && (_cooldownGrieta[grieta.identificador] ?? 0) <= 0) {
          final double acumulado =
              (_segundosEnGrieta[grieta.identificador] ?? 0) +
              segundosTranscurridos;
          if (acumulado >= grieta.tiempoRodaduraNecesarioSegundos) {
            _segundosEnGrieta[grieta.identificador] = 0;
            _cooldownGrieta[grieta.identificador] = cooldownGrietaSegundos;
            grieta.onAtravesarEnBola();
          } else {
            _segundosEnGrieta[grieta.identificador] = acumulado;
          }
        } else if (!dentro) {
          _segundosEnGrieta[grieta.identificador] = 0;
        }
      }
    } else {
      _segundosEnGrieta.clear();
    }

    final orientacionNueva = posicionTentativa.dx == posicionJugador.dx
        ? _orientadoDerecha
        : posicionTentativa.dx > posicionJugador.dx;

    final desplazamientoFinal = (posicionTentativa - posicionJugador).distance;
    final huboMovimientoSignificativo = desplazamientoFinal > 0.0005;

    // El destinoClic puede apuntar fuera del rango visible (especialmente las
    // salidas automáticas hacia el pasillo). El peón queda clamped al borde
    // y nunca alcanzaría el punto literal. Comparamos contra el destino
    // proyectado al rango legal: cuando el peón está pegado al borde
    // correspondiente, lo damos por llegado.
    final destinoEfectivo = destinoClic == null
        ? null
        : Offset(
            destinoClic!.dx.clamp(bordeIzquierdo, bordeDerecho),
            destinoClic!.dy.clamp(bordeSuperior, bordeInferior),
          );
    final llegoADestino =
        destinoEfectivo != null &&
        (posicionTentativa - destinoEfectivo).distance < 0.018;

    if (huboMovimientoSignificativo) {
      segundosDesdeUltimoPolvo += segundosTranscurridos;
      if (segundosDesdeUltimoPolvo >= intervaloSpawnPolvo) {
        polvoPisadas.add(
          _PolvoPisada(
            posicionRelativa: Offset(
              posicionTentativa.dx,
              posicionTentativa.dy + widget.altoJugadorRelativo * 0.45,
            ),
            vidaRestante: vidaPolvoSegundos,
          ),
        );
        segundosDesdeUltimoPolvo = 0;
      }
    } else {
      segundosDesdeUltimoPolvo = intervaloSpawnPolvo;
    }
    polvoPisadas.removeWhere((polvo) {
      polvo.vidaRestante -= segundosTranscurridos;
      return polvo.vidaRestante <= 0;
    });

    // MASCOTA: sigue al cadete con lerp suave. Se ofrece detrás de la
    // espalda del cadete (en la dirección opuesta a la última
    // orientación). Si el cadete está quieto > 2.5 s la mascota se
    // sienta y se queda quieta donde está. Pasea fases de paso cuando
    // hay movimiento.
    if (widget.mascota != null) {
      final double signoOrientacion = orientacionNueva ? 1.0 : -1.0;
      final Offset destinoMascota = posicionTentativa.translate(
        -widget.mascota!.distanciaSeguimiento * signoOrientacion,
        0,
      );
      final double distanciaAObjetivo =
          (destinoMascota - posicionMascota).distance;
      // Sentarse si quieto. Levantarse en cuanto el cadete se mueva
      // o esté lejos.
      if (huboMovimientoSignificativo || distanciaAObjetivo > 0.03) {
        mascotaSentada = false;
        segundosQuietaMascota = 0;
      } else {
        segundosQuietaMascota += segundosTranscurridos;
        if (segundosQuietaMascota > 2.5) {
          mascotaSentada = true;
        }
      }
      // Lerp suave.
      final double factor = widget.mascota!.suavizadoSeguimiento;
      posicionMascota = Offset(
        posicionMascota.dx + (destinoMascota.dx - posicionMascota.dx) * factor,
        posicionMascota.dy + (destinoMascota.dy - posicionMascota.dy) * factor,
      );
      // Orientación de la mascota: hacia donde se está moviendo en X.
      if ((destinoMascota.dx - posicionMascota.dx).abs() > 0.001) {
        mascotaMirandoDerecha = destinoMascota.dx > posicionMascota.dx;
      }
      // Fase de paso si va caminando (no sentada).
      if (!mascotaSentada && distanciaAObjetivo > 0.002) {
        faseAndarMascota =
            (faseAndarMascota + segundosTranscurridos * 4.5) % 1.0;
      } else {
        faseAndarMascota = 0;
      }
      // Bocadillo cíclico (cada 12-25 s aprox).
      if (tiempoFraseMascotaRestante > 0) {
        tiempoFraseMascotaRestante -= segundosTranscurridos;
        if (tiempoFraseMascotaRestante <= 0) {
          fraseMascotaActiva = null;
        }
      } else {
        segundosHastaSiguienteFraseMascota -= segundosTranscurridos;
        if (segundosHastaSiguienteFraseMascota <= 0 &&
            widget.mascota!.frases.isNotEmpty) {
          final List<String> frasesDisponibles = widget.mascota!.frases;
          fraseMascotaActiva =
              frasesDisponibles[math.Random().nextInt(
                frasesDisponibles.length,
              )];
          tiempoFraseMascotaRestante = 2.6;
          segundosHastaSiguienteFraseMascota =
              16 + math.Random().nextDouble() * 10;
        }
      }
    }

    setState(() {
      posicionJugador = posicionTentativa;
      _orientadoDerecha = orientacionNueva;
      _moviendoseEsteFrame = huboMovimientoSignificativo;
    });

    if (huboMovimientoSignificativo || destinoClic != null) {
      segundosQuieto = 0;
      eventoQuietudDisparadoYa = false;
    } else {
      segundosQuieto += segundosTranscurridos;
      if (!eventoQuietudDisparadoYa &&
          segundosQuieto >= widget.segundosQuietudParaEvento &&
          widget.onCadeteQuietoLargoRato != null) {
        eventoQuietudDisparadoYa = true;
        widget.onCadeteQuietoLargoRato!.call();
      }
    }

    if (llegoADestino) {
      _resolverLlegadaADestinoClic();
    } else if (!huboDesplazamiento) {
      _moviendoseEsteFrame = false;
    }
  }

  Offset _calcularDireccionTeclado() {
    // Mientras el escenario no tenga el foco (ej. hay un diálogo encima o
    // el usuario navegó a otra pantalla), descartamos cualquier tecla que
    // pueda haber quedado zombie. El navegador no entrega KeyUp a un widget
    // sin foco, y sin esto el peón seguiría moviéndose al volver del combate.
    if (!nodoFoco.hasFocus) {
      if (teclasActivas.isNotEmpty) teclasActivas.clear();
      return Offset.zero;
    }
    double ejeX = 0;
    double ejeY = 0;
    if (teclasActivas.any((t) => teclasIzquierda.contains(t))) ejeX -= 1;
    if (teclasActivas.any((t) => teclasDerecha.contains(t))) ejeX += 1;
    if (teclasActivas.any((t) => teclasArriba.contains(t))) ejeY -= 1;
    if (teclasActivas.any((t) => teclasAbajo.contains(t))) ejeY += 1;
    return Offset(ejeX, ejeY);
  }

  /// Si el cadete lleva algún item equipado (sombrero, arma o torso),
  /// usamos el stick figure procedimental para que esos items se vean.
  /// Si va "desnudo", podemos sustituirlo por el walk-cycle PNG sin
  /// perder información visual.
  bool _llevaEquipamiento() {
    final s = widget.idSombreroEquipado;
    final a = widget.idArmaEquipada;
    final t = widget.idTorsoEquipado;
    return (s != null && s.isNotEmpty) ||
        (a != null && a.isNotEmpty) ||
        (t != null && t.isNotEmpty);
  }

  void _resolverLlegadaADestinoClic() {
    final hotspotPendiente = idHotspotPendienteInteraccion;
    // Las salidas automáticas suelen apuntar fuera del rango visible (e.g.
    // 1.08 mientras el bordeDerecho es 0.95) para representar "el cadete
    // sale por el lateral". Proyectamos al rango legal para reconocer la
    // llegada cuando el peón está pegado al borde correspondiente.
    final destinoSalidaEfectiva = destinoSalida == null
        ? null
        : Offset(
            destinoSalida!.dx.clamp(bordeIzquierdo, bordeDerecho),
            destinoSalida!.dy.clamp(bordeSuperior, bordeInferior),
          );
    final eraSalida =
        destinoSalidaEfectiva != null &&
        (posicionJugador - destinoSalidaEfectiva).distance < 0.01;
    destinoClic = null;
    idHotspotPendienteInteraccion = null;
    if (eraSalida) {
      destinoSalida = null;
      widget.alCompletarSalida?.call();
      return;
    }
    if (hotspotPendiente != null) {
      final hotspot = widget.hotspots.firstWhere(
        (h) => h.identificador == hotspotPendiente,
        orElse: () => widget.hotspots.first,
      );
      hotspot.onInteractuar?.call();
    }
  }

  KeyEventResult _alEventoTeclado(FocusNode nodo, KeyEvent evento) {
    if (evento is KeyDownEvent || evento is KeyRepeatEvent) {
      // R: toggle modo bola (rodar). Solo en KeyDown para evitar repeticiones.
      if (evento is KeyDownEvent &&
          evento.logicalKey == LogicalKeyboardKey.keyR) {
        setState(() {
          modoBolaActivo = !modoBolaActivo;
          segundosRodando = 0;
          segundosSaltoRestante = 0;
        });
        return KeyEventResult.handled;
      }
      // En modo bola, las teclas "arriba" disparan un salto que ignora
      // obstáculos durante un breve arco. NO consumimos el evento si
      // hay desplazamiento direccional pendiente — sólo si la tecla es
      // exclusivamente "arriba" (W/↑) interpretada como salto. Para no
      // romper el movimiento normal usamos sólo el evento de KeyDown.
      if (modoBolaActivo &&
          evento is KeyDownEvent &&
          teclasArriba.contains(evento.logicalKey) &&
          segundosSaltoRestante <= 0) {
        setState(() {
          segundosSaltoRestante = duracionSaltoBolaSegundos;
        });
        // No retornamos handled aquí: queremos que la tecla siga
        // también acumulando movimiento direccional (la bola "salta
        // mientras avanza").
      }
      if (teclasInteraccion.contains(evento.logicalKey)) {
        _intentarInteraccionDeTeclado();
        return KeyEventResult.handled;
      }
      final esDireccional =
          teclasArriba.contains(evento.logicalKey) ||
          teclasAbajo.contains(evento.logicalKey) ||
          teclasIzquierda.contains(evento.logicalKey) ||
          teclasDerecha.contains(evento.logicalKey) ||
          teclasSprint.contains(evento.logicalKey);
      if (esDireccional) {
        teclasActivas.add(evento.logicalKey);
        _ultimaActividadTecla[evento.logicalKey] = DateTime.now();
        if (evento is KeyDownEvent) {
          _registrarTeclaParaCodigoSecreto(evento.logicalKey);
        }
        return KeyEventResult.handled;
      }
    } else if (evento is KeyUpEvent) {
      _ultimaActividadTecla.remove(evento.logicalKey);
      if (teclasActivas.remove(evento.logicalKey)) {
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _registrarTeclaParaCodigoSecreto(LogicalKeyboardKey tecla) {
    String? etiquetaDireccion;
    if (teclasArriba.contains(tecla)) {
      etiquetaDireccion = 'up';
    } else if (teclasAbajo.contains(tecla)) {
      etiquetaDireccion = 'down';
    } else if (teclasIzquierda.contains(tecla)) {
      etiquetaDireccion = 'left';
    } else if (teclasDerecha.contains(tecla)) {
      etiquetaDireccion = 'right';
    }
    if (etiquetaDireccion == null) return;
    bufferDireccionesRecientes.add(etiquetaDireccion);
    if (bufferDireccionesRecientes.length > secuenciaKonamiInvertido.length) {
      bufferDireccionesRecientes.removeAt(0);
    }
    if (bufferDireccionesRecientes.length == secuenciaKonamiInvertido.length &&
        _listasIguales(bufferDireccionesRecientes, secuenciaKonamiInvertido)) {
      bufferDireccionesRecientes.clear();
      widget.onCodigoSecreto?.call('konami_invertido');
    }
  }

  bool _listasIguales(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _intentarInteraccionDeTeclado() {
    if (destinoSalida != null) return;
    HotspotEscenario? hotspotMasCercano;
    double mejorDistancia = double.infinity;
    for (final hotspot in widget.hotspots) {
      if (hotspot.onInteractuar == null) continue;
      final distanciaAlPeon =
          (hotspot.posicionRelativa - posicionJugador).distance;
      if (distanciaAlPeon > hotspot.radioInteraccion) continue;
      if (distanciaAlPeon < mejorDistancia) {
        mejorDistancia = distanciaAlPeon;
        hotspotMasCercano = hotspot;
      }
    }
    if (hotspotMasCercano != null) {
      hotspotMasCercano.onInteractuar?.call();
    } else {
      widget.onPulsacionInteraccionOciosa?.call();
    }
  }

  Offset _puntoAdyacenteA(HotspotEscenario hotspot) {
    final destino = hotspot.posicionRelativa;
    final origen = posicionJugador;
    final diferencia = destino - origen;
    final distancia = diferencia.distance;
    if (distancia <= hotspot.radioInteraccion * 0.55) return origen;
    final escalaAcercamiento =
        (distancia - hotspot.radioInteraccion * 0.55) / distancia;
    return Offset(
      origen.dx + diferencia.dx * escalaAcercamiento,
      origen.dy + diferencia.dy * escalaAcercamiento,
    );
  }

  void _caminarHaciaHotspot(HotspotEscenario hotspot) {
    if (destinoSalida != null) return;
    // Si el cadete ya está dentro del radio de interacción del
    // hotspot, no le hacemos caminar: disparamos la interacción al
    // momento. Esto evita el problema clásico de "estoy literalmente
    // encima del objeto pero tengo que hacer click dos veces porque
    // el destino calculado queda 0.5px más allá".
    final distanciaActual =
        (posicionJugador - hotspot.posicionRelativa).distance;
    if (distanciaActual <= hotspot.radioInteraccion) {
      hotspot.onInteractuar?.call();
      return;
    }
    final destino = _puntoAdyacenteA(hotspot);
    setState(() {
      destinoClic = destino;
      idHotspotPendienteInteraccion = hotspot.identificador;
    });
    nodoFoco.requestFocus();
  }

  void _caminarHastaPunto(Offset punto) {
    if (destinoSalida != null) return;
    // Al hacer tap, las teclas se consideran soltadas: el usuario expresa
    // intención clara con el clic. Si quedaba alguna tecla "fantasma" tras
    // una pérdida de foco, esto la limpia.
    teclasActivas.clear();
    setState(() {
      destinoClic = Offset(
        punto.dx.clamp(bordeIzquierdo, bordeDerecho),
        punto.dy.clamp(bordeSuperior, bordeInferior),
      );
      idHotspotPendienteInteraccion = null;
    });
    nodoFoco.requestFocus();
  }

  /// Altura visual del arco parabólico cuando el cadete-bola está
  /// saltando, expresada en píxeles. Devuelve 0 si no hay salto activo.
  double _alturaSaltoBolaPx(double altoViewport) {
    if (segundosSaltoRestante <= 0) return 0;
    final double fraccionSalto =
        1.0 - (segundosSaltoRestante / duracionSaltoBolaSegundos);
    // Parábola simple: pico en t=0.5, valor 0..1.
    final double altura = 4 * fraccionSalto * (1.0 - fraccionSalto);
    return altura * altoViewport * 0.18;
  }

  /// Resuelve la colisión del cadete con los obstáculos rectangulares
  /// declarados por el escenario. Si la posición tentativa cae dentro de
  /// algún obstáculo, intenta primero un movimiento sólo en X (deslizando
  /// contra la pared horizontal), luego sólo en Y, y como último recurso
  /// se queda quieto. Así se evita el "subirse por las paredes" típico de
  /// los clamps planos.
  Offset _resolverColisionObstaculos(Offset posicionPrevia, Offset tentativa) {
    if (widget.obstaculos.isEmpty) return tentativa;
    if (!_estaDentroDeObstaculo(tentativa)) return tentativa;
    final Offset desplazamientoSoloX = Offset(tentativa.dx, posicionPrevia.dy);
    if (!_estaDentroDeObstaculo(desplazamientoSoloX)) {
      return desplazamientoSoloX;
    }
    final Offset desplazamientoSoloY = Offset(posicionPrevia.dx, tentativa.dy);
    if (!_estaDentroDeObstaculo(desplazamientoSoloY)) {
      return desplazamientoSoloY;
    }
    return posicionPrevia;
  }

  bool _estaDentroDeObstaculo(Offset posicion) {
    for (final rectObstaculo in widget.obstaculos) {
      if (rectObstaculo.contains(posicion)) return true;
    }
    return false;
  }

  /// Detecta si una representación de hotspot es esencialmente
  /// invisible (un `SizedBox.shrink()` o sin contenido), para
  /// decidir si añadir el indicador tenue de "aquí hay algo".
  bool _representacionEsInvisible(Widget representacion) {
    if (representacion is SizedBox) {
      return representacion.child == null;
    }
    return false;
  }

  bool _esHotspotEnAlcance(HotspotEscenario hotspot) {
    final distanciaAlPeon =
        (hotspot.posicionRelativa - posicionJugador).distance;
    return distanciaAlPeon <= hotspot.radioInteraccion;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (contexto, restricciones) {
        final anchoViewport = restricciones.maxWidth;
        final alto = restricciones.maxHeight;
        final anchoMundo = anchoViewport * widget.factorAnchoMundo;
        final anchoExtraScrolleable = anchoMundo - anchoViewport;
        final posicionJugadorPxMundo = posicionJugador.dx * anchoMundo;
        final offsetCamara = anchoExtraScrolleable <= 0
            ? 0.0
            : (posicionJugadorPxMundo - anchoViewport / 2).clamp(
                0.0,
                anchoExtraScrolleable,
              );
        return Focus(
          focusNode: nodoFoco,
          autofocus: true,
          onKeyEvent: _alEventoTeclado,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (detalles) {
              nodoFoco.requestFocus();
              // El tap llega en coordenadas del viewport; lo proyectamos al
              // sistema 0..1 del mundo sumando el offset de cámara.
              final xMundo = detalles.localPosition.dx + offsetCamara;
              final posicionPulsada = Offset(
                xMundo / anchoMundo,
                detalles.localPosition.dy / alto,
              );
              _caminarHastaPunto(posicionPulsada);
            },
            child: ClipRect(
              child: Stack(
                children: [
                  // Envolvemos en Positioned para que el SizedBox interno
                  // pueda exceder el ancho del Stack padre (que está limitado
                  // al ancho del viewport). Sin esto, anchoMundo se colapsa a
                  // anchoViewport y todo el mundo amplio se aplasta dentro de
                  // la pantalla.
                  Positioned(
                    left: -offsetCamara,
                    top: 0,
                    width: anchoMundo,
                    height: alto,
                    child: SizedBox(
                      width: anchoMundo,
                      height: alto,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            // `BoxFit.fill` (en vez de `cover`): el fondo
                            // se estira para llenar exactamente
                            // `anchoMundo × alto` sin recortar. Imprescindible
                            // para que las coordenadas relativas (0..1) del
                            // sistema coincidan con lo que el jugador ve.
                            // Con `cover` el fondo quedaba recortado y la
                            // línea visual del suelo flotaba respecto a las
                            // coordenadas Y → cadete se subía a paredes o
                            // flotaba según el tamaño de la ventana.
                            child: widget.rutaImagenFondo != null
                                ? Image.asset(
                                    widget.rutaImagenFondo!,
                                    fit: BoxFit.fill,
                                    filterQuality: FilterQuality.high,
                                  )
                                : CustomPaint(painter: widget.pintorFondo),
                          ),
                          if (widget.capaAmbiental != null)
                            Positioned.fill(child: widget.capaAmbiental!),
                          // GRIETAS dibujadas sobre el fondo, debajo de
                          // hotspots y peón. Más visibles en modo bola.
                          if (widget.grietas.isNotEmpty)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: CustomPaint(
                                  painter: _PintorGrietas(
                                    grietas: widget.grietas,
                                    enModoBola: modoBolaActivo,
                                    progresoPorGrieta: {
                                      for (final grietaIter in widget.grietas)
                                        grietaIter.identificador:
                                            (_segundosEnGrieta[grietaIter
                                                    .identificador] ??
                                                0) /
                                            grietaIter
                                                .tiempoRodaduraNecesarioSegundos,
                                    },
                                  ),
                                ),
                              ),
                            ),
                          // Capa unificada para paredes débiles e
                          // interruptores (siguen siendo procedimentales).
                          // Los objetos empujables y bolos pasan a PNGs
                          // (ver capas siguientes), pero el painter aún
                          // los necesita para dibujar el indicador
                          // "EMPUJAR" / "STRIKE" cuando el cadete está
                          // cerca en modo bola.
                          if (widget.objetosEmpujables.isNotEmpty ||
                              widget.bolos.isNotEmpty ||
                              widget.paredesDebiles.isNotEmpty ||
                              widget.interruptores.isNotEmpty)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: CustomPaint(
                                  painter: _PintorElementosBola(
                                    objetosEmpujables: widget.objetosEmpujables,
                                    bolos: widget.bolos,
                                    paredesDebiles: widget.paredesDebiles,
                                    interruptores: widget.interruptores,
                                    enModoBola: modoBolaActivo,
                                    pintarSiluetasGraficas: false,
                                  ),
                                ),
                              ),
                            ),
                          // Cajas empujables: usamos el PNG con fondo
                          // transparente (`mueble_caja_anonima.png`) en
                          // vez del antiguo `caja_f447.png` con fondo
                          // blanco sólido, que dejaba un rectángulo
                          // blanco horrible al arrastrar la caja.
                          for (final caja in widget.objetosEmpujables)
                            Positioned(
                              left:
                                  (caja.posicion.dx - caja.radio * 1.4) *
                                  anchoMundo,
                              top: (caja.posicion.dy - caja.radio * 1.4) * alto,
                              width: caja.radio * 2.8 * anchoMundo,
                              height: caja.radio * 2.8 * alto,
                              child: const IgnorePointer(
                                child: Image(
                                  image: AssetImage(
                                    'assets/svg/mueble_caja_anonima.png',
                                  ),
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ),
                          // Bolos burocráticos: PNG art. Sólo se
                          // pintan los aún en pie; los derribados se
                          // ocultan (el painter ya gestionaba esa
                          // lógica con `derribado`).
                          for (final bolo in widget.bolos)
                            if (!bolo.tirado)
                              Positioned(
                                left:
                                    (bolo.posicion.dx - bolo.radio * 1.6) *
                                    anchoMundo,
                                top:
                                    (bolo.posicion.dy - bolo.radio * 2.4) *
                                    alto,
                                width: bolo.radio * 3.2 * anchoMundo,
                                height: bolo.radio * 4.0 * alto,
                                child: const IgnorePointer(
                                  child: Image(
                                    image: AssetImage(
                                      'assets/svg/bolo_burocratico.png',
                                    ),
                                    fit: BoxFit.contain,
                                    alignment: Alignment.bottomCenter,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                              ),
                          // Animación de impacto sobre cada pared
                          // débil recién rota: 2 frames del set
                          // §10.12 que se desvanecen mientras
                          // [faseRotura] decae de 1.0 a 0.
                          for (final pared in widget.paredesDebiles)
                            if (pared.rota && pared.faseRotura > 0)
                              Positioned(
                                left: pared.rect.left * anchoMundo,
                                top: pared.rect.top * alto,
                                width: pared.rect.width * anchoMundo,
                                height: pared.rect.height * alto,
                                child: IgnorePointer(
                                  child: Opacity(
                                    opacity: pared.faseRotura.clamp(0.0, 1.0),
                                    child: Image.asset(
                                      pared.faseRotura > 0.5
                                          ? 'assets/images/cadete_bola_impacto_f01.png'
                                          : 'assets/images/cadete_bola_impacto_f02.png',
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.high,
                                    ),
                                  ),
                                ),
                              ),
                          // Render del hotspot. Tras la auditoría de
                          // 2026-05-17 se aplica un MÍNIMO visual de
                          // ancho 0.10 y alto 0.12. El ancho es el
                          // verdadero cuello de botella: con
                          // `BoxFit.contain` un PNG cuadrado (la
                          // mayoría de los muebles y NPCs son sprites
                          // ~1024×1024 o ~1024×1536) ocupa siempre el
                          // mínimo entre ancho y alto del rect, y
                          // como casi todos los hotspots tienen el
                          // ancho mucho menor que el alto, el ancho
                          // manda y la imagen se ve pequeña con
                          // padding vertical. Se eleva al 10% de la
                          // viewport para que los sprites no salgan
                          // miniaturizados.
                          for (final hotspot in widget.hotspots)
                            Builder(
                              builder: (_) {
                                final double anchoRelativoEfectivo =
                                    math.max(hotspot.anchoRelativo, 0.10);
                                final double altoRelativoEfectivo =
                                    math.max(hotspot.altoRelativo, 0.12);
                                // Ancho contra MUNDO para que el hotspot
                                // escale como objeto del mundo (idéntico
                                // razonamiento que el cadete, líneas
                                // arriba). En escenarios sin scroll
                                // (factorAnchoMundo=1.0) anchoMundo ==
                                // anchoViewport, así que el cambio es no-op.
                                final double anchoHotspot =
                                    anchoRelativoEfectivo * anchoMundo;
                                final double altoHotspot =
                                    altoRelativoEfectivo * alto;
                                return Positioned(
                                  left:
                                      hotspot.posicionRelativa.dx *
                                          anchoMundo -
                                      anchoHotspot / 2,
                                  top:
                                      hotspot.posicionRelativa.dy * alto -
                                      altoHotspot / 2,
                                  width: anchoHotspot,
                                  height: altoHotspot,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: hotspot.onInteractuar == null
                                    ? null
                                    : () => _caminarHaciaHotspot(hotspot),
                                child: MouseRegion(
                                  cursor: hotspot.onInteractuar == null
                                      ? SystemMouseCursors.basic
                                      : SystemMouseCursors.click,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.center,
                                    children: [
                                      // Para hotspots sin
                                      // representación visible
                                      // (SizedBox.shrink) pero con
                                      // interacción, pintamos un
                                      // punto tenue de fondo para
                                      // que el jugador sepa que hay
                                      // algo. Se intensifica al
                                      // acercarse.
                                      if (_representacionEsInvisible(
                                            hotspot.representacion,
                                          ) &&
                                          hotspot.onInteractuar != null)
                                        Positioned.fill(
                                          child: IgnorePointer(
                                            child: CustomPaint(
                                              painter:
                                                  _PintorMarcaHotspotInvisible(
                                                    enAlcance:
                                                        _esHotspotEnAlcance(
                                                          hotspot,
                                                        ),
                                                  ),
                                            ),
                                          ),
                                        ),
                                      Positioned.fill(
                                        child: hotspot.animarRespiracion
                                            ? _HotspotConRespiracion(
                                                semilla: hotspot.identificador,
                                                hijo: hotspot.representacion,
                                              )
                                            : hotspot.representacion,
                                      ),
                                      if ((hotspot.destacar ||
                                              _esHotspotEnAlcance(hotspot)) &&
                                          hotspot.onInteractuar != null)
                                        Positioned(
                                          top: -alto * 0.06,
                                          right: -anchoViewport * 0.015,
                                          child: MarcadorInteraccion(
                                            tamano: anchoViewport * 0.038,
                                            mostrarTeclaInteraccion:
                                                _esHotspotEnAlcance(hotspot),
                                            etiquetaAccion:
                                                hotspot.etiquetaAccion,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                                );
                              },
                            ),
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: _PintorPolvoPisadas(
                                  polvoActivo: polvoPisadas,
                                ),
                              ),
                            ),
                          ),
                          // SOMBRA del cadete: elipse fina pegada a la
                          // línea de pies. La sombra anterior era el
                          // doble de gruesa y caía 35% del altoJ por
                          // debajo, dando sensación de que el cadete
                          // flotaba sobre ella.
                          Positioned(
                            // Sombra del cadete: ancho contra MUNDO para
                            // que coincida con la base del sprite (que
                            // ahora también usa anchoMundo arriba).
                            left:
                                posicionJugador.dx * anchoMundo -
                                (widget.anchoJugadorRelativo * anchoMundo) / 2,
                            top:
                                posicionJugador.dy * alto -
                                widget.altoJugadorRelativo * alto * 0.03 -
                                offsetVerticalSombraPx,
                            width: widget.anchoJugadorRelativo * anchoMundo,
                            height: widget.altoJugadorRelativo * alto * 0.10,
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: _PintorSombraPersonaje(
                                  intensidad:
                                      modoBolaActivo &&
                                          segundosSaltoRestante > 0
                                      ? 0.45
                                      : 1.0,
                                ),
                              ),
                            ),
                          ),
                          // SOMBRA de la mascota.
                          if (widget.mascota != null)
                            Positioned(
                              left:
                                  posicionMascota.dx * anchoMundo -
                                  (widget.mascota!.altoRelativo *
                                          0.8 *
                                          anchoMundo) /
                                      2,
                              // Sombra de Laika justo bajo sus patas
                              // (mismo principio que la sombra del
                              // cadete tras anclar por los pies).
                              top:
                                  posicionMascota.dy * alto -
                                  widget.mascota!.altoRelativo * alto * 0.03 -
                                  offsetVerticalSombraPx,
                              // Ancho contra MUNDO (igual que el sprite
                              // del personaje arriba).
                              width:
                                  widget.mascota!.altoRelativo *
                                  0.8 *
                                  anchoMundo,
                              height:
                                  widget.mascota!.altoRelativo * alto * 0.08,
                              child: const IgnorePointer(
                                child: CustomPaint(
                                  painter: _PintorSombraPersonaje(
                                    intensidad: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          // MASCOTA: dibujada DEBAJO del cadete en
                          // el Stack pero a su misma altura visual.
                          // Como el cadete, se ancla por sus patas a
                          // `posicionMascota.dy`.
                          if (widget.mascota != null)
                            Positioned(
                              left:
                                  posicionMascota.dx * anchoMundo -
                                  (widget.mascota!.altoRelativo *
                                          0.8 *
                                          anchoMundo) /
                                      2,
                              top:
                                  posicionMascota.dy * alto -
                                  widget.mascota!.altoRelativo * alto * 0.92,
                              // Ancho contra MUNDO (idéntico razonamiento
                              // que el cadete y los hotspots) para que
                              // Laika escale con el resto de la escena.
                              width:
                                  widget.mascota!.altoRelativo *
                                  0.8 *
                                  anchoMundo,
                              height: widget.mascota!.altoRelativo * alto,
                              child: IgnorePointer(
                                child: _laikaDetectaRastro
                                    ? Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.diagonal3Values(
                                          mascotaMirandoDerecha ? 1.0 : -1.0,
                                          1.0,
                                          1.0,
                                        ),
                                        child: const CicloDeFrames(
                                          rutasFrames: [
                                            'assets/images/laika_olfato_f01.png',
                                            'assets/images/laika_olfato_f02.png',
                                          ],
                                          duracionPorFrame: Duration(
                                            milliseconds: 360,
                                          ),
                                          ajuste: BoxFit.contain,
                                        ),
                                      )
                                    : mascotaSentada
                                    ? Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.diagonal3Values(
                                          mascotaMirandoDerecha ? 1.0 : -1.0,
                                          1.0,
                                          1.0,
                                        ),
                                        child: const Image(
                                          image: AssetImage(
                                            'assets/images/laika_sentada.png',
                                          ),
                                          fit: BoxFit.contain,
                                          filterQuality: FilterQuality.high,
                                        ),
                                      )
                                    : CustomPaint(
                                        painter: _PintorMascotaLaika(
                                          mirandoDerecha: mascotaMirandoDerecha,
                                          sentada: mascotaSentada,
                                          fasePaso: faseAndarMascota,
                                          enModoBola: modoBolaActivo,
                                        ),
                                      ),
                              ),
                            ),
                          // Bocadillo de la mascota.
                          if (widget.mascota != null &&
                              fraseMascotaActiva != null)
                            Positioned(
                              left:
                                  posicionMascota.dx * anchoMundo -
                                  anchoViewport * 0.10,
                              top:
                                  posicionMascota.dy * alto -
                                  widget.mascota!.altoRelativo * alto * 1.0,
                              width: anchoViewport * 0.20,
                              child: IgnorePointer(
                                child: _BocadilloMascota(
                                  texto: fraseMascotaActiva!,
                                  nombre: widget.mascota!.nombre,
                                ),
                              ),
                            ),
                          Positioned(
                            left:
                                posicionJugador.dx * anchoMundo -
                                (widget.anchoJugadorRelativo * anchoMundo) / 2,
                            // Anclamos el peón por sus PIES: el borde
                            // inferior del rectángulo del sprite cae en
                            // `posicionJugador.dy * alto`. El stick figure
                            // pinta los pies al ~89% del rectángulo, así
                            // que los pies dibujados quedan exactamente
                            // sobre la línea lógica del jugador en lugar
                            // de flotar (el rectángulo antes se centraba
                            // verticalmente en dy, no se anclaba al suelo).
                            top:
                                posicionJugador.dy * alto -
                                widget.altoJugadorRelativo * alto * 0.89 -
                                _alturaSaltoBolaPx(alto),
                            // Ancho relativo al MUNDO, no al viewport: en
                            // escenarios con scroll horizontal
                            // (factorAnchoMundo=2.0) el cadete debe escalar
                            // como un objeto del mundo. Si usásemos
                            // anchoViewport, el cadete se vería la mitad
                            // de ancho que los muebles del fondo.
                            width: widget.anchoJugadorRelativo * anchoMundo,
                            height: widget.altoJugadorRelativo * alto,
                            child: IgnorePointer(
                              child: modoBolaActivo
                                  ? _ImagenCadeteBolaCiclo(
                                      // segundosRodando ya sólo crece
                                      // cuando la bola avanza, así que
                                      // basta con un factor de velocidad
                                      // uniforme — no hace falta
                                      // distinguir "quieto vs en marcha"
                                      // aquí.
                                      progresoRodadura: segundosRodando * 6.0,
                                      enSalto: segundosSaltoRestante > 0,
                                    )
                                  : Transform.rotate(
                                      // Inclinación hacia adelante
                                      // cuando el cadete empuja un
                                      // objeto: ~17° (más visible) en la
                                      // dirección a la que mira.
                                      angle: _empujandoEsteFrame
                                          ? (_orientadoDerecha ? 0.30 : -0.30)
                                          : 0,
                                      alignment: Alignment.bottomCenter,
                                      child: Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.diagonal3Values(
                                          _orientadoDerecha ? 1.0 : -1.0,
                                          1.0,
                                          1.0,
                                        ),
                                        // Al empujar, abandonamos el
                                        // walk-cycle PNG (sería caminar
                                        // normal) y usamos el stick
                                        // figure con pose de combate
                                        // listo — los brazos extendidos
                                        // dejan claro que está
                                        // empujando con las dos manos.
                                        child: _empujandoEsteFrame
                                            ? StickFigureViviente(
                                                clase: widget.claseJugador,
                                                pose:
                                                    PoseStickFigure.combateListo,
                                                enMovimiento: false,
                                                idSombreroEquipado:
                                                    widget.idSombreroEquipado,
                                                idArmaEquipada:
                                                    widget.idArmaEquipada,
                                                idTorsoEquipado:
                                                    widget.idTorsoEquipado,
                                              )
                                            : (_moviendoseEsteFrame &&
                                                  !_llevaEquipamiento())
                                            ? _ImagenCadeteWalkCiclo(
                                                avanceCaminado:
                                                    _avanceCaminadoCadete,
                                              )
                                            : StickFigureViviente(
                                                clase: widget.claseJugador,
                                                pose:
                                                    PoseStickFigure.reposoFirme,
                                                enMovimiento:
                                                    _moviendoseEsteFrame,
                                                idSombreroEquipado:
                                                    widget.idSombreroEquipado,
                                                idArmaEquipada:
                                                    widget.idArmaEquipada,
                                                idTorsoEquipado:
                                                    widget.idTorsoEquipado,
                                              ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (anchoExtraScrolleable > 0)
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: IgnorePointer(
                        child: IndicadorCamaraHorizontal(
                          progresoCamara: anchoExtraScrolleable <= 0
                              ? 0.0
                              : offsetCamara / anchoExtraScrolleable,
                        ),
                      ),
                    ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: IgnorePointer(child: AyudaControlesTeclado()),
                  ),
                  // Banderín "MODO BOLA" en la esquina superior central
                  // cuando la transformación está activa. Pulsa.
                  if (modoBolaActivo)
                    Positioned(
                      top: 14,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Center(
                          child: _BanderinModoBola(
                            enSalto: segundosSaltoRestante > 0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Pequeña barrita horizontal en la esquina inferior izquierda que muestra
/// qué tramo del mundo está visible en el viewport. Solo aparece cuando el
/// escenario es más ancho que la pantalla (factorAnchoMundo > 1.0).
class IndicadorCamaraHorizontal extends StatelessWidget {
  final double progresoCamara;

  const IndicadorCamaraHorizontal({super.key, required this.progresoCamara});

  @override
  Widget build(BuildContext context) {
    const anchoIndicador = 110.0;
    const altoIndicador = 8.0;
    const anchoVentanaInterna = 38.0;
    final desplazamientoVentana =
        (anchoIndicador - anchoVentanaInterna - 4) *
        progresoCamara.clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.85),
        border: Border.all(color: PaletaCosmoSovietica.tintaNegra, width: 1.2),
      ),
      child: SizedBox(
        width: anchoIndicador,
        height: altoIndicador + 14,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Text(
                'TRAMO VISIBLE',
                style: TextStyle(
                  fontFamily: TipografiaPropaganda.familiaMonoespaciada,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: PaletaCosmoSovietica.rojoOficial,
                  letterSpacing: 1.4,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: altoIndicador,
                decoration: BoxDecoration(
                  color: PaletaCosmoSovietica.papelSombra,
                  border: Border.all(
                    color: PaletaCosmoSovietica.tintaNegra,
                    width: 0.8,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 2 + desplazamientoVentana,
              bottom: 1,
              child: Container(
                width: anchoVentanaInterna,
                height: altoIndicador - 2,
                color: PaletaCosmoSovietica.rojoOficial,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cartel con sello en la esquina inferior derecha de cada escenario libre,
/// recordándole al usuario los controles de teclado disponibles.
class AyudaControlesTeclado extends StatelessWidget {
  const AyudaControlesTeclado({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.88),
        border: Border.all(color: PaletaCosmoSovietica.tintaNegra, width: 1.4),
        boxShadow: const [
          BoxShadow(
            color: PaletaCosmoSovietica.tintaNegra,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INSTRUCTIVO DE TRÁNSITO',
            style: TextStyle(
              fontFamily: TipografiaPropaganda.familiaMonoespaciada,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: PaletaCosmoSovietica.rojoOficial,
              letterSpacing: 1.4,
            ),
          ),
          SizedBox(height: 3),
          _LineaInstructivo(simbolo: '↑↓←→', accion: 'desplazar'),
          _LineaInstructivo(simbolo: 'WASD', accion: 'desplazar'),
          _LineaInstructivo(simbolo: '⇧', accion: 'apurar paso'),
          _LineaInstructivo(simbolo: 'R', accion: 'rodar bola'),
          _LineaInstructivo(simbolo: 'W (bola)', accion: 'saltar'),
          _LineaInstructivo(simbolo: 'E / ␣', accion: 'tramitar'),
          _LineaInstructivo(simbolo: '🖱', accion: 'caminar al punto'),
        ],
      ),
    );
  }
}

class _LineaInstructivo extends StatelessWidget {
  final String simbolo;
  final String accion;
  const _LineaInstructivo({required this.simbolo, required this.accion});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 38,
            child: Text(
              simbolo,
              style: const TextStyle(
                fontFamily: TipografiaPropaganda.familiaMonoespaciada,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: PaletaCosmoSovietica.tintaNegra,
              ),
            ),
          ),
          Text(
            accion,
            style: const TextStyle(
              fontFamily: TipografiaPropaganda.familiaMonoespaciada,
              fontSize: 10,
              color: PaletaCosmoSovietica.tintaNegra,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cadete bola usando los 4 frames PNG del set §10.11. El índice se
/// calcula a partir de [progresoRodadura] para que la bola "gire" a
/// la velocidad del movimiento real, no a un tick fijo. Cuando está
/// quieta el frame se congela (una bola quieta no rota).
/// Walk-cycle del cadete a pie usando los 4 frames PNG del set
/// §10.1. El frame se calcula a partir del avance acumulado de
/// caminado (no del tiempo de wall-clock), así que al pararse el
/// cadete se congela en el frame actual en lugar de seguir
/// "andando en el sitio". La velocidad del ciclo está acoplada a
/// la velocidad real de desplazamiento.
class _ImagenCadeteWalkCiclo extends StatelessWidget {
  final double avanceCaminado;

  const _ImagenCadeteWalkCiclo({required this.avanceCaminado});

  @override
  Widget build(BuildContext context) {
    // 4 frames a ~6 ciclos completos por segundo de movimiento real
    // (factor 6 da una cadencia natural para velocidad de caminado).
    final int indice = ((avanceCaminado * 6).floor() % 4).abs();
    return Image.asset(
      'assets/images/cadete_walk_f0${indice + 1}.png',
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}

class _ImagenCadeteBolaCiclo extends StatelessWidget {
  final double progresoRodadura;
  final bool enSalto;

  const _ImagenCadeteBolaCiclo({
    required this.progresoRodadura,
    required this.enSalto,
  });

  @override
  Widget build(BuildContext context) {
    // 4 frames a razón de 1 frame por unidad de progresoRodadura
    // (progresoRodadura ya está escalado por velocidad en el sitio
    // de llamada). Esto da una rotación visualmente coherente: al
    // andar rápido el ciclo va rápido; al parar se queda quieto.
    final int indice = (progresoRodadura.floor() % 4).abs();
    final String ruta = 'assets/images/cadete_bola_f0${indice + 1}.png';
    final Widget imagen = Image.asset(
      ruta,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
    // El PNG de la bola es 400×400 cuadrado, pero la caja del jugador
    // en el escenario libre es alta y estrecha (stick figure
    // vertical). Con BoxFit.contain dentro de esa caja la bola queda
    // diminuta. Escalamos con Transform.scale para darle presencia
    // sin tocar el layout del jugador (que también gestiona el flip
    // izquierda/derecha). Al saltar se infla un poco más.
    final double escala = enSalto ? 2.80 : 2.55;
    // Anclamos la bola al borde INFERIOR de la caja del peón: la
    // posición Y del jugador apunta al centro vertical del stick
    // figure, así que sin este ajuste la bola escalada queda
    // flotando muy por encima del suelo. Con bottomCenter, la parte
    // baja del sprite cae a la línea de pie del cadete.
    return Align(
      alignment: Alignment.bottomCenter,
      child: Transform.scale(
        scale: escala,
        alignment: Alignment.bottomCenter,
        child: imagen,
      ),
    );
  }
}

/// Dibuja al cadete hecho una bola rodante (casco esférico) usando el
/// vocabulario visual del juego: trazo negro grueso, tinta papel viejo,
/// estrella roja girando. Cuando [enSalto] es `true` la bola se "comba"
/// ligeramente y suelta un par de líneas de viento debajo.
///
/// Fallback legacy: ya no se usa por defecto (se sustituyó por
/// [_ImagenCadeteBolaCiclo]). Se conserva por si en algún flujo
/// específico se quiere volver al render procedimental.
// ignore: unused_element
class _PintorCadeteBola extends CustomPainter {
  final double progresoRodadura;
  final bool enSalto;

  _PintorCadeteBola({required this.progresoRodadura, required this.enSalto});

  @override
  void paint(Canvas canvas, Size size) {
    final double radioCasco = math.min(size.width, size.height) * 0.42;
    final Offset centroCasco = Offset(size.width / 2, size.height * 0.65);

    // Sombra elíptica bajo la bola.
    final double anchoSombra = enSalto ? radioCasco * 1.2 : radioCasco * 1.5;
    final double opacidadSombra = enSalto ? 0.18 : 0.32;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centroCasco.dx, size.height * 0.92 - 50),
        width: anchoSombra,
        height: radioCasco * 0.32,
      ),
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra.withValues(
          alpha: opacidadSombra,
        ),
    );

    // Cuerpo del casco: relleno papel viejo + trazo grueso negro.
    canvas.drawCircle(
      centroCasco,
      radioCasco,
      Paint()..color = PaletaCosmoSovietica.papelViejo,
    );
    final Paint pincelTrazo = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.0, radioCasco * 0.14)
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(centroCasco, radioCasco, pincelTrazo);

    // Visor arqueado superior (rasgo distintivo del cosmonauta).
    canvas.drawArc(
      Rect.fromCenter(
        center: centroCasco,
        width: radioCasco * 1.4,
        height: radioCasco * 0.85,
      ),
      math.pi * 1.15,
      math.pi * 0.70,
      false,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2.0, radioCasco * 0.16),
    );

    // Estrella roja orbitando: gira con la rodadura.
    final double anguloEstrella = progresoRodadura + math.pi / 2;
    final Offset centroEstrella = centroCasco.translate(
      math.cos(anguloEstrella) * radioCasco * 0.55,
      math.sin(anguloEstrella) * radioCasco * 0.55,
    );
    _pintarEstrellaCinco(
      canvas,
      centroEstrella,
      radioCasco * 0.22,
      Paint()..color = PaletaCosmoSovietica.rojoOficial,
    );

    // Líneas de velocidad cuando hay rodadura significativa.
    if (progresoRodadura > 0.5) {
      final Paint pincelEstela = Paint()
        ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.5)
        ..strokeWidth = math.max(1.4, radioCasco * 0.10)
        ..strokeCap = StrokeCap.round;
      for (int indiceLinea = 0; indiceLinea < 3; indiceLinea++) {
        final double desfaseY = (indiceLinea - 1) * radioCasco * 0.45;
        final Offset puntoInicio = centroCasco.translate(
          -radioCasco * 1.05,
          desfaseY,
        );
        final Offset puntoFin = puntoInicio.translate(-radioCasco * 0.7, 0);
        canvas.drawLine(puntoInicio, puntoFin, pincelEstela);
      }
    }
  }

  void _pintarEstrellaCinco(
    Canvas canvas,
    Offset centro,
    double radio,
    Paint pincel,
  ) {
    final Path camino = Path();
    for (int indice = 0; indice < 10; indice++) {
      final bool esExterior = indice.isEven;
      final double radioActual = esExterior ? radio : radio * 0.42;
      final double angulo = -math.pi / 2 + indice * math.pi / 5;
      final double x = centro.dx + math.cos(angulo) * radioActual;
      final double y = centro.dy + math.sin(angulo) * radioActual;
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
  bool shouldRepaint(covariant _PintorCadeteBola viejo) =>
      viejo.progresoRodadura != progresoRodadura || viejo.enSalto != enSalto;
}

class _PolvoPisada {
  final Offset posicionRelativa;
  double vidaRestante;

  _PolvoPisada({required this.posicionRelativa, required this.vidaRestante});
}

/// Indicador sutil de "aquí hay un hotspot interactivo invisible".
/// Pinta un pequeño círculo de tinta diluida en el centro del
/// hotspot. Se intensifica cuando el cadete está en alcance para
/// dar feedback de proximidad.
class _PintorMarcaHotspotInvisible extends CustomPainter {
  final bool enAlcance;

  _PintorMarcaHotspotInvisible({required this.enAlcance});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset centro = Offset(size.width / 2, size.height / 2);
    final double radio =
        math.min(size.width, size.height) * (enAlcance ? 0.30 : 0.22);
    // Punto interior tenue.
    canvas.drawCircle(
      centro,
      radio,
      Paint()
        ..color = PaletaCosmoSovietica.tintaTenue.withValues(
          alpha: enAlcance ? 0.42 : 0.22,
        ),
    );
    // Anillo exterior aún más diluido para dar volumen al punto.
    canvas.drawCircle(
      centro,
      radio * 1.6,
      Paint()
        ..color = PaletaCosmoSovietica.tintaTenue.withValues(
          alpha: enAlcance ? 0.18 : 0.08,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant _PintorMarcaHotspotInvisible viejo) =>
      viejo.enAlcance != enAlcance;
}

class _PintorPolvoPisadas extends CustomPainter {
  final List<_PolvoPisada> polvoActivo;

  _PintorPolvoPisadas({required this.polvoActivo});

  @override
  void paint(Canvas canvas, Size size) {
    for (final polvo in polvoActivo) {
      final fraccionVida =
          (polvo.vidaRestante / _EscenarioLibreState.vidaPolvoSegundos).clamp(
            0.0,
            1.0,
          );
      final radioPolvo = (1.0 - fraccionVida) * size.width * 0.014 + 1.5;
      final centroPolvo = Offset(
        polvo.posicionRelativa.dx * size.width,
        polvo.posicionRelativa.dy * size.height,
      );
      final pincelPolvo = Paint()
        ..color = PaletaCosmoSovietica.tintaTenue.withValues(
          alpha: fraccionVida * 0.35,
        );
      canvas.drawCircle(centroPolvo, radioPolvo, pincelPolvo);
      canvas.drawCircle(
        centroPolvo.translate(radioPolvo * 0.6, -radioPolvo * 0.2),
        radioPolvo * 0.6,
        Paint()
          ..color = PaletaCosmoSovietica.tintaTenue.withValues(
            alpha: fraccionVida * 0.22,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PintorPolvoPisadas viejo) => true;
}

class IconoHotspotGenerico extends StatelessWidget {
  final CustomPainter painter;
  final bool conSombra;

  const IconoHotspotGenerico({
    super.key,
    required this.painter,
    this.conSombra = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned.fill(child: CustomPaint(painter: painter)),
        if (conSombra)
          Positioned(
            bottom: 0,
            child: Container(
              width: 30,
              height: 6,
              decoration: BoxDecoration(
                color: PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.22),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
            ),
          ),
      ],
    );
  }
}

/// Reemplazo de [IconoHotspotGenerico] cuando ya tenemos un PNG/SVG
/// artístico para un mueble o NPC. Mantiene la misma sombra de contacto
/// (elipse oscura en el suelo) para que el objeto no flote y conserva
/// el alineamiento bottomCenter del resto de hotspots.
///
/// Uso esperado dentro de un [HotspotEscenario]:
/// ```dart
/// representacion: const IconoHotspotImagen(
///   rutaAsset: 'assets/svg/archivador.png',
/// ),
/// ```
class IconoHotspotImagen extends StatelessWidget {
  final String rutaAsset;
  final bool conSombra;

  /// Ancho de la sombra de contacto. Subir a 40-50 para muebles
  /// anchos (archivador, barril); bajar a 20 para objetos finos.
  final double anchoSombra;

  /// Padding interior para que la imagen no toque la sombra del suelo.
  /// Útil cuando el PNG ya incluye su propia base.
  final EdgeInsets margenInterior;

  /// Si el PNG no tiene transparencia perfecta y conviene recortarlo
  /// con un BoxFit distinto al por defecto.
  final BoxFit ajuste;

  /// Tiñe el sprite hacia el tono papel viejo del fondo. Por defecto
  /// activo para que los muebles no canten como blancos sobre los
  /// PNG color papel.
  final bool integracionTonal;

  const IconoHotspotImagen({
    super.key,
    required this.rutaAsset,
    this.conSombra = true,
    this.anchoSombra = 32,
    this.margenInterior = const EdgeInsets.only(bottom: 4),
    this.ajuste = BoxFit.contain,
    this.integracionTonal = true,
  });

  @override
  Widget build(BuildContext context) {
    // Si el PNG todavía no existe en disco (assets pendientes del
    // briefing), no rompemos la app: el `errorBuilder` devuelve un
    // espacio vacío y el hotspot sigue siendo interactuable. En
    // cuanto el PNG aparezca en `assets/`, el sprite se renderiza
    // automáticamente.
    // Alineación bottomCenter: cuando el PNG es cuadrado y el rect
    // del hotspot es alto-estrecho, BoxFit.contain reduce la imagen al
    // ancho y deja padding vertical. Sin alignment explícito, ese
    // padding se reparte arriba y abajo y el objeto "flota en el
    // techo". Con bottomCenter la imagen queda pegada al suelo del
    // rect, que es el comportamiento esperado para muebles y NPCs.
    Widget imagen = Image.asset(
      rutaAsset,
      fit: ajuste,
      alignment: Alignment.bottomCenter,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, e, s) => const SizedBox.shrink(),
    );
    if (integracionTonal) {
      imagen = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.93,
          0,
          0,
          0,
          0,
          0,
          0.89,
          0,
          0,
          0,
          0,
          0,
          0.82,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: imagen,
      );
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        if (conSombra)
          Positioned(
            bottom: 0,
            child: Container(
              width: anchoSombra,
              height: 6,
              decoration: BoxDecoration(
                color: PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.22),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
            ),
          ),
        Positioned.fill(
          child: Padding(padding: margenInterior, child: imagen),
        ),
      ],
    );
  }
}

/// Pinta las grietas del escenario en el suelo. Sutiles cuando el
/// cadete va a pie (sólo una sombra rojiza tenue, casi un manchurrón
/// que no llama la atención) y muy evidentes cuando el cadete está
/// en MODO BOLA: borde rojo bien marcado, etiqueta "RODAR", y un
/// indicador circular de progreso cuando la bola está dentro.
class _PintorGrietas extends CustomPainter {
  final List<GrietaEscenario> grietas;
  final bool enModoBola;
  final Map<String, double> progresoPorGrieta;

  _PintorGrietas({
    required this.grietas,
    required this.enModoBola,
    required this.progresoPorGrieta,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final grieta in grietas) {
      final Rect rectPx = Rect.fromLTRB(
        grieta.rect.left * size.width,
        grieta.rect.top * size.height,
        grieta.rect.right * size.width,
        grieta.rect.bottom * size.height,
      );
      final double alphaBase = enModoBola ? 0.85 : 0.25;
      final Paint pincelRelleno = Paint()
        ..color = PaletaCosmoSovietica.tintaNegra.withValues(
          alpha: alphaBase * 0.45,
        );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rectPx, const Radius.circular(4)),
        pincelRelleno,
      );
      // Borde rojo tembloroso: muy visible en modo bola, casi
      // invisible cuando el cadete está erguido.
      final Paint pincelBorde = Paint()
        ..color = PaletaCosmoSovietica.rojoOficial.withValues(alpha: alphaBase)
        ..style = PaintingStyle.stroke
        ..strokeWidth = enModoBola ? 2.4 : 1.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rectPx, const Radius.circular(4)),
        pincelBorde,
      );
      // Líneas internas de quiebra (grietas pintadas).
      final int hashSemilla = grieta.identificador.hashCode;
      final math.Random rngGrieta = math.Random(hashSemilla);
      final int totalLineas = enModoBola ? 5 : 2;
      for (int indiceLinea = 0; indiceLinea < totalLineas; indiceLinea++) {
        final double y1 = rectPx.top + rngGrieta.nextDouble() * rectPx.height;
        final double y2 = rectPx.top + rngGrieta.nextDouble() * rectPx.height;
        canvas.drawLine(
          Offset(rectPx.left + 4, y1),
          Offset(rectPx.right - 4, y2),
          Paint()
            ..color = PaletaCosmoSovietica.tintaNegra.withValues(
              alpha: alphaBase * 0.55,
            )
            ..strokeWidth = 1.0,
        );
      }
      // Etiqueta + barra de progreso sólo visibles en modo bola.
      if (enModoBola) {
        final TextPainter pintorEtiquetaGrieta = TextPainter(
          text: TextSpan(
            text: grieta.etiqueta,
            style: const TextStyle(
              fontFamily: 'CosmoSerif',
              fontSize: 11,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: PaletaCosmoSovietica.rojoOficial,
              letterSpacing: 1.6,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        pintorEtiquetaGrieta.paint(
          canvas,
          Offset(
            rectPx.center.dx - pintorEtiquetaGrieta.width / 2,
            rectPx.top - pintorEtiquetaGrieta.height - 2,
          ),
        );
        // Barra de progreso si la bola está dentro.
        final double progreso = (progresoPorGrieta[grieta.identificador] ?? 0)
            .clamp(0.0, 1.0);
        if (progreso > 0.01) {
          final double anchoBarra = rectPx.width * 0.7;
          final Rect rectBarra = Rect.fromLTWH(
            rectPx.center.dx - anchoBarra / 2,
            rectPx.bottom + 4,
            anchoBarra,
            5,
          );
          canvas.drawRect(
            rectBarra,
            Paint()
              ..color = PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.85),
          );
          canvas.drawRect(
            Rect.fromLTWH(
              rectBarra.left,
              rectBarra.top,
              rectBarra.width * progreso,
              rectBarra.height,
            ),
            Paint()..color = PaletaCosmoSovietica.rojoOficial,
          );
          canvas.drawRect(
            rectBarra,
            Paint()
              ..color = PaletaCosmoSovietica.tintaNegra
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PintorGrietas viejo) =>
      viejo.enModoBola != enModoBola ||
      viejo.progresoPorGrieta != progresoPorGrieta;
}

/// Banderín que aparece en lo alto del escenario cuando el cadete
/// está en modo bola. Recuerda al jugador la transformación activa
/// y le da pista del salto. Pulsa suavemente al estar saltando.
class _BanderinModoBola extends StatelessWidget {
  final bool enSalto;

  const _BanderinModoBola({required this.enSalto});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.symmetric(
        horizontal: enSalto ? 18 : 14,
        vertical: enSalto ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.92),
        border: Border.all(
          color: PaletaCosmoSovietica.rojoOficial,
          width: enSalto ? 2.2 : 1.6,
        ),
        boxShadow: const [
          BoxShadow(
            color: PaletaCosmoSovietica.tintaNegra,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              color: PaletaCosmoSovietica.rojoOficial,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'MODO BOLA',
            style: TextStyle(
              fontFamily: 'CosmoSerif',
              fontSize: 13,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w900,
              color: PaletaCosmoSovietica.rojoOficial,
              letterSpacing: 2.0,
              height: 1.0,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 1,
            height: 14,
            color: PaletaCosmoSovietica.tintaNegra,
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: const BoxDecoration(
              color: PaletaCosmoSovietica.tintaNegra,
            ),
            child: const Text(
              'W',
              style: TextStyle(
                fontFamily: 'CosmoMono',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: PaletaCosmoSovietica.papelViejo,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'saltar',
            style: TextStyle(
              fontFamily: 'CosmoSerif',
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.8),
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pinta los cuatro elementos nuevos del modo bola: objetos
/// empujables, bolos, paredes débiles e interruptores. Mantenidos
/// en un sólo painter para no abrir 4 capas más en el Stack.
class _PintorElementosBola extends CustomPainter {
  final List<ObjetoEmpujable> objetosEmpujables;
  final List<BoloDecorativo> bolos;
  final List<ParedDebilEscenario> paredesDebiles;
  final List<InterruptorPresion> interruptores;
  final bool enModoBola;

  /// Si false, no dibuja las siluetas geométricas de cajas ni bolos
  /// (que se renderizan en su lugar como PNG art en una capa superior).
  /// Las etiquetas "EMPUJAR" / "STRIKE" y la ondulación de impacto sí
  /// se conservan.
  final bool pintarSiluetasGraficas;

  _PintorElementosBola({
    required this.objetosEmpujables,
    required this.bolos,
    required this.paredesDebiles,
    required this.interruptores,
    required this.enModoBola,
    this.pintarSiluetasGraficas = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // PAREDES DÉBILES: rectángulo con borde rojo y rayado. Si está
    // rota, fading suave del fragmento.
    for (final pared in paredesDebiles) {
      final Rect rectPx = Rect.fromLTRB(
        pared.rect.left * size.width,
        pared.rect.top * size.height,
        pared.rect.right * size.width,
        pared.rect.bottom * size.height,
      );
      if (pared.rota) {
        if (pared.faseRotura > 0) {
          // Fragmentos volando: cuatro líneas radiales tenues.
          final Paint pincelFragmento = Paint()
            ..color = PaletaCosmoSovietica.rojoOficial.withValues(
              alpha: pared.faseRotura * 0.6,
            )
            ..strokeWidth = 2.0
            ..strokeCap = StrokeCap.round;
          for (
            int indiceFragmento = 0;
            indiceFragmento < 6;
            indiceFragmento++
          ) {
            final double angulo = indiceFragmento * math.pi / 3;
            final Offset desde = rectPx.center;
            final double radioFragmento =
                rectPx.shortestSide * (1.0 + (1.0 - pared.faseRotura));
            final Offset hasta =
                desde +
                Offset(
                  math.cos(angulo) * radioFragmento,
                  math.sin(angulo) * radioFragmento,
                );
            canvas.drawLine(desde, hasta, pincelFragmento);
          }
        }
        continue;
      }
      // Cuerpo de la pared (papel ladrillo).
      canvas.drawRect(rectPx, Paint()..color = const Color(0xFFD9C6A2));
      // Rayado diagonal para que parezca "agrietada".
      canvas.save();
      canvas.clipRect(rectPx);
      final Paint pincelRayado = Paint()
        ..color = PaletaCosmoSovietica.rojoOficial.withValues(alpha: 0.45)
        ..strokeWidth = 1.4;
      for (double x = rectPx.left - rectPx.height; x < rectPx.right; x += 8) {
        canvas.drawLine(
          Offset(x, rectPx.top),
          Offset(x + rectPx.height, rectPx.bottom),
          pincelRayado,
        );
      }
      canvas.restore();
      // Borde tinta.
      canvas.drawRect(
        rectPx,
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
      // Etiqueta.
      final TextPainter pintorEtiquetaPared = TextPainter(
        text: TextSpan(
          text: pared.etiqueta,
          style: const TextStyle(
            fontFamily: 'CosmoSerif',
            fontSize: 10,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w900,
            color: PaletaCosmoSovietica.rojoOficial,
            letterSpacing: 1.4,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: rectPx.width);
      pintorEtiquetaPared.paint(
        canvas,
        Offset(
          rectPx.center.dx - pintorEtiquetaPared.width / 2,
          rectPx.top - pintorEtiquetaPared.height - 2,
        ),
      );
    }

    // INTERRUPTORES DE PRESIÓN: placa con borde grueso. Si pulsado,
    // relleno rojo; si reposo, papel sucio con cruz central.
    for (final interruptor in interruptores) {
      final Rect rectPx = Rect.fromLTRB(
        interruptor.rect.left * size.width,
        interruptor.rect.top * size.height,
        interruptor.rect.right * size.width,
        interruptor.rect.bottom * size.height,
      );
      canvas.drawRect(
        rectPx,
        Paint()
          ..color = interruptor.pulsado
              ? PaletaCosmoSovietica.rojoOficial
              : PaletaCosmoSovietica.papelSombra,
      );
      canvas.drawRect(
        rectPx,
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      );
      // X central.
      final Paint pincelEquis = Paint()
        ..color = interruptor.pulsado
            ? PaletaCosmoSovietica.papelViejo
            : PaletaCosmoSovietica.tintaNegra
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(rectPx.left + 4, rectPx.top + 4),
        Offset(rectPx.right - 4, rectPx.bottom - 4),
        pincelEquis,
      );
      canvas.drawLine(
        Offset(rectPx.right - 4, rectPx.top + 4),
        Offset(rectPx.left + 4, rectPx.bottom - 4),
        pincelEquis,
      );
      // Etiqueta encima.
      final TextPainter pintorEtiquetaInterr = TextPainter(
        text: TextSpan(
          text: interruptor.etiqueta,
          style: TextStyle(
            fontFamily: 'CosmoMono',
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: enModoBola
                ? PaletaCosmoSovietica.rojoOficial
                : PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.55),
            letterSpacing: 1.4,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      pintorEtiquetaInterr.paint(
        canvas,
        Offset(
          rectPx.center.dx - pintorEtiquetaInterr.width / 2,
          rectPx.top - pintorEtiquetaInterr.height - 2,
        ),
      );
    }

    // OBJETOS EMPUJABLES: caja rectangular con sombra elíptica.
    for (final objeto in objetosEmpujables) {
      final Offset centroPx = Offset(
        objeto.posicion.dx * size.width,
        objeto.posicion.dy * size.height,
      );
      final double anchoPx = objeto.radio * 2 * size.width;
      final double altoPx = objeto.radio * 2 * size.height;
      final Rect rectCaja = Rect.fromCenter(
        center: centroPx,
        width: anchoPx,
        height: altoPx,
      );
      if (pintarSiluetasGraficas) {
        // Sombra elíptica.
        canvas.drawOval(
          Rect.fromCenter(
            center: centroPx.translate(0, altoPx * 0.5),
            width: anchoPx * 1.05,
            height: altoPx * 0.25,
          ),
          Paint()
            ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.25),
        );
        canvas.drawRect(
          rectCaja,
          Paint()..color = PaletaCosmoSovietica.papelSombra,
        );
        // Cruz interior (cruces de cinta de embalaje).
        final Paint pincelCintaCaja = Paint()
          ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.55)
          ..strokeWidth = 1.6;
        canvas.drawLine(
          rectCaja.centerLeft,
          rectCaja.centerRight,
          pincelCintaCaja,
        );
        canvas.drawLine(
          rectCaja.topCenter,
          rectCaja.bottomCenter,
          pincelCintaCaja,
        );
        // Borde tinta grueso.
        canvas.drawRect(
          rectCaja,
          Paint()
            ..color = PaletaCosmoSovietica.tintaNegra
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2,
        );
      }
      // Etiqueta opcional sobre la caja.
      if (objeto.etiqueta.isNotEmpty) {
        final TextPainter pintorEtiquetaCaja = TextPainter(
          text: TextSpan(
            text: objeto.etiqueta,
            style: const TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: PaletaCosmoSovietica.tintaNegra,
              letterSpacing: 1.2,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        pintorEtiquetaCaja.paint(
          canvas,
          Offset(
            rectCaja.center.dx - pintorEtiquetaCaja.width / 2,
            rectCaja.center.dy - pintorEtiquetaCaja.height / 2,
          ),
        );
      }
    }

    // BOLOS: la silueta del bolo en pie ahora es un PNG art en una
    // capa superior. Sólo se sigue dibujando la sombra de impacto al
    // suelo cuando el bolo cae, y la pose girada cuando ya está
    // tumbado, para no perder la animación.
    if (pintarSiluetasGraficas) {
      for (final pino in bolos) {
        if (!pino.tirado) continue;
        final Offset centroPx = Offset(
          pino.posicion.dx * size.width,
          pino.posicion.dy * size.height,
        );
        final double radioPx = pino.radio * size.width;
        canvas.save();
        canvas.translate(centroPx.dx, centroPx.dy);
        canvas.rotate(math.pi / 2 + pino.fasesCaida * 0.3);
        // Sombra de pino tumbado: sólo un óvalo.
        canvas.drawOval(
          Rect.fromCenter(
            center: const Offset(0, 0).translate(0, radioPx * 2.0),
            width: radioPx * 1.8,
            height: radioPx * 0.4,
          ),
          Paint()
            ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.25),
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PintorElementosBola viejo) => true;
}

/// Bocadillo de cómic flotando sobre la mascota.
class _BocadilloMascota extends StatelessWidget {
  final String texto;
  final String nombre;

  const _BocadilloMascota({required this.texto, required this.nombre});

  /// Heurística: la frase trata sobre papeleo/expedientes y conviene
  /// adornar el bocadillo con la viñeta de Laika trayendo un
  /// expediente en la boca (`laika_expediente.png`).
  bool get _esFraseDeExpediente {
    final textoMinuscula = texto.toLowerCase();
    const palabrasClaveExpediente = <String>[
      'f-447',
      'papel',
      'expediente',
      'anota',
      'comité',
      'comite',
      'sello',
      'formulario',
    ];
    for (final palabraClave in palabrasClaveExpediente) {
      if (textoMinuscula.contains(palabraClave)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final Widget textoBocadillo = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nombre,
          style: const TextStyle(
            fontFamily: 'CosmoMono',
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: PaletaCosmoSovietica.rojoOficial,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          texto,
          style: const TextStyle(
            fontFamily: 'CosmoSerif',
            fontSize: 11,
            fontStyle: FontStyle.italic,
            color: PaletaCosmoSovietica.tintaNegra,
            height: 1.2,
          ),
        ),
      ],
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.95),
        border: Border.all(color: PaletaCosmoSovietica.tintaNegra, width: 1.4),
        boxShadow: const [
          BoxShadow(
            color: PaletaCosmoSovietica.tintaNegra,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: _esFraseDeExpediente
          ? Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 26,
                  height: 26,
                  child: Image(
                    image: AssetImage('assets/images/laika_expediente.png'),
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(child: textoBocadillo),
              ],
            )
          : textoBocadillo,
    );
  }
}

/// Pinta a Laika cosmonauta: cuerpo ovalado, cabeza con casco
/// transparente y antena, cuatro patas con animación de paso, cola
/// que se agita. Cuando va en modo bola se convierte en una bolita
/// que rueda, como un mini-eco del cadete.
class _PintorMascotaLaika extends CustomPainter {
  final bool mirandoDerecha;
  final bool sentada;
  final double fasePaso;
  final bool enModoBola;

  _PintorMascotaLaika({
    required this.mirandoDerecha,
    required this.sentada,
    required this.fasePaso,
    required this.enModoBola,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    if (!mirandoDerecha) {
      canvas.translate(size.width, 0);
      canvas.scale(-1.0, 1.0);
    }
    final double altoTotal = size.height;
    final double anchoTotal = size.width;
    // Centro vertical aproximado.
    final double cyCuerpo = altoTotal * 0.62;

    if (enModoBola) {
      // Bolita rodante.
      final double radioBolita = math.min(anchoTotal, altoTotal) * 0.40;
      final Offset centroBola = Offset(anchoTotal * 0.5, altoTotal * 0.62);
      canvas.drawCircle(
        centroBola,
        radioBolita,
        Paint()..color = PaletaCosmoSovietica.papelViejo,
      );
      canvas.drawCircle(
        centroBola,
        radioBolita,
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
      // Línea de rotación con la fase.
      canvas.drawArc(
        Rect.fromCircle(center: centroBola, radius: radioBolita * 0.7),
        fasePaso * math.pi * 2,
        math.pi * 0.6,
        false,
        Paint()
          ..color = PaletaCosmoSovietica.rojoOficial
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
      canvas.restore();
      return;
    }

    // CUERPO: óvalo horizontal.
    final Rect rectCuerpo = Rect.fromCenter(
      center: Offset(anchoTotal * 0.45, cyCuerpo),
      width: anchoTotal * 0.78,
      height: altoTotal * 0.36,
    );
    canvas.drawOval(
      rectCuerpo,
      Paint()..color = PaletaCosmoSovietica.papelViejo,
    );
    canvas.drawOval(
      rectCuerpo,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
    // Estrella roja en el lomo.
    _dibujarEstrellaCinco(
      canvas,
      Offset(rectCuerpo.center.dx, rectCuerpo.center.dy - altoTotal * 0.04),
      altoTotal * 0.05,
      Paint()..color = PaletaCosmoSovietica.rojoOficial,
    );
    // PATAS: cuatro líneas verticales con leve bounce alternado.
    if (!sentada) {
      final double swing = math.sin(fasePaso * math.pi * 2);
      final double swingOpuesto = math.cos(fasePaso * math.pi * 2);
      _dibujarPata(
        canvas,
        rectCuerpo.left + anchoTotal * 0.10,
        rectCuerpo.bottom - 2,
        altoTotal * 0.18,
        swing,
      );
      _dibujarPata(
        canvas,
        rectCuerpo.left + anchoTotal * 0.28,
        rectCuerpo.bottom - 2,
        altoTotal * 0.18,
        swingOpuesto,
      );
      _dibujarPata(
        canvas,
        rectCuerpo.left + anchoTotal * 0.50,
        rectCuerpo.bottom - 2,
        altoTotal * 0.18,
        swingOpuesto,
      );
      _dibujarPata(
        canvas,
        rectCuerpo.left + anchoTotal * 0.68,
        rectCuerpo.bottom - 2,
        altoTotal * 0.18,
        swing,
      );
    } else {
      // Sentada: patas traseras dobladas, delanteras rectas.
      _dibujarPata(
        canvas,
        rectCuerpo.left + anchoTotal * 0.10,
        rectCuerpo.bottom - 2,
        altoTotal * 0.18,
        0,
      );
      _dibujarPata(
        canvas,
        rectCuerpo.left + anchoTotal * 0.28,
        rectCuerpo.bottom - 2,
        altoTotal * 0.18,
        0,
      );
      // Las traseras (sentadas) son sólo un trazo curvo corto.
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(
            rectCuerpo.left + anchoTotal * 0.60,
            rectCuerpo.bottom - altoTotal * 0.05,
          ),
          width: anchoTotal * 0.20,
          height: altoTotal * 0.15,
        ),
        math.pi * 1.1,
        math.pi * 0.8,
        false,
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round,
      );
    }
    // COLA: línea curva atrás (izquierda en orientación derecha).
    final Path caminoCola = Path()
      ..moveTo(rectCuerpo.left + anchoTotal * 0.02, rectCuerpo.center.dy)
      ..quadraticBezierTo(
        rectCuerpo.left - anchoTotal * 0.10,
        rectCuerpo.center.dy -
            altoTotal * (0.06 + 0.04 * math.sin(fasePaso * math.pi * 4)),
        rectCuerpo.left - anchoTotal * 0.05,
        rectCuerpo.center.dy - altoTotal * 0.12,
      );
    canvas.drawPath(
      caminoCola,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );

    // CABEZA: círculo a la derecha del cuerpo.
    final double radioCabeza = altoTotal * 0.16;
    final Offset centroCabeza = Offset(
      rectCuerpo.right - anchoTotal * 0.04,
      rectCuerpo.center.dy - altoTotal * 0.12,
    );
    canvas.drawCircle(
      centroCabeza,
      radioCabeza,
      Paint()..color = PaletaCosmoSovietica.papelViejo,
    );
    canvas.drawCircle(
      centroCabeza,
      radioCabeza,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
    // Orejas pequeñas triangulares.
    final Path caminoOrejaIzq = Path()
      ..moveTo(
        centroCabeza.dx - radioCabeza * 0.7,
        centroCabeza.dy - radioCabeza * 0.6,
      )
      ..lineTo(
        centroCabeza.dx - radioCabeza * 0.4,
        centroCabeza.dy - radioCabeza * 1.4,
      )
      ..lineTo(
        centroCabeza.dx - radioCabeza * 0.1,
        centroCabeza.dy - radioCabeza * 0.7,
      )
      ..close();
    canvas.drawPath(
      caminoOrejaIzq,
      Paint()..color = PaletaCosmoSovietica.papelViejo,
    );
    canvas.drawPath(
      caminoOrejaIzq,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    final Path caminoOrejaDer = Path()
      ..moveTo(
        centroCabeza.dx + radioCabeza * 0.7,
        centroCabeza.dy - radioCabeza * 0.6,
      )
      ..lineTo(
        centroCabeza.dx + radioCabeza * 0.4,
        centroCabeza.dy - radioCabeza * 1.4,
      )
      ..lineTo(
        centroCabeza.dx + radioCabeza * 0.1,
        centroCabeza.dy - radioCabeza * 0.7,
      )
      ..close();
    canvas.drawPath(
      caminoOrejaDer,
      Paint()..color = PaletaCosmoSovietica.papelViejo,
    );
    canvas.drawPath(
      caminoOrejaDer,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // Ojo y nariz.
    canvas.drawCircle(
      Offset(
        centroCabeza.dx + radioCabeza * 0.30,
        centroCabeza.dy - radioCabeza * 0.10,
      ),
      radioCabeza * 0.12,
      Paint()..color = PaletaCosmoSovietica.tintaNegra,
    );
    canvas.drawCircle(
      Offset(
        centroCabeza.dx + radioCabeza * 0.85,
        centroCabeza.dy + radioCabeza * 0.20,
      ),
      radioCabeza * 0.10,
      Paint()..color = PaletaCosmoSovietica.rojoOficial,
    );
    // CASCO ESFÉRICO transparente.
    final double radioCasco = radioCabeza * 1.45;
    canvas.drawCircle(
      centroCabeza,
      radioCasco,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
    // Visor.
    canvas.drawArc(
      Rect.fromCircle(center: centroCabeza, radius: radioCasco * 0.78),
      math.pi * 1.1,
      math.pi * 0.8,
      false,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Antena.
    final Offset baseAntena = Offset(
      centroCabeza.dx - radioCasco * 0.5,
      centroCabeza.dy - radioCasco * 0.85,
    );
    final Offset puntaAntena = Offset(
      baseAntena.dx - radioCasco * 0.05,
      baseAntena.dy - radioCasco * 0.45,
    );
    canvas.drawLine(
      baseAntena,
      puntaAntena,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      puntaAntena,
      radioCasco * 0.10,
      Paint()..color = PaletaCosmoSovietica.rojoOficial,
    );
    canvas.restore();
  }

  void _dibujarPata(
    Canvas canvas,
    double x,
    double yBase,
    double altoPata,
    double swing,
  ) {
    final double extension = altoPata * (1.0 + swing * 0.15);
    canvas.drawLine(
      Offset(x, yBase),
      Offset(x + swing * altoPata * 0.20, yBase + extension),
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );
  }

  void _dibujarEstrellaCinco(
    Canvas canvas,
    Offset centro,
    double radio,
    Paint pincel,
  ) {
    final Path camino = Path();
    for (int indicePunta = 0; indicePunta < 10; indicePunta++) {
      final bool esExterior = indicePunta.isEven;
      final double radioActual = esExterior ? radio : radio * 0.42;
      final double angulo = -math.pi / 2 + indicePunta * math.pi / 5;
      final double x = centro.dx + math.cos(angulo) * radioActual;
      final double y = centro.dy + math.sin(angulo) * radioActual;
      if (indicePunta == 0) {
        camino.moveTo(x, y);
      } else {
        camino.lineTo(x, y);
      }
    }
    camino.close();
    canvas.drawPath(camino, pincel);
  }

  @override
  bool shouldRepaint(covariant _PintorMascotaLaika viejo) =>
      viejo.fasePaso != fasePaso ||
      viejo.mirandoDerecha != mirandoDerecha ||
      viejo.sentada != sentada ||
      viejo.enModoBola != enModoBola;
}

/// Sombra elíptica que se pinta debajo del cadete o de la mascota.
/// Es deliberadamente simple — un óvalo oscuro semi-translúcido con
/// borde más débil — para no recargar la escena pero dar volumen.
class _PintorSombraPersonaje extends CustomPainter {
  final double intensidad;

  const _PintorSombraPersonaje({this.intensidad = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rectSombra = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawOval(
      rectSombra,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra.withValues(
          alpha: 0.14 * intensidad,
        ),
    );
    canvas.drawOval(
      rectSombra.deflate(size.width * 0.22),
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra.withValues(
          alpha: 0.22 * intensidad,
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _PintorSombraPersonaje viejo) =>
      viejo.intensidad != intensidad;
}
