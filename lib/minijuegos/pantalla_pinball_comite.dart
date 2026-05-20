import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import 'pintor_rotulador.dart';
import '../theme.dart';
import '../widgets/ciclo_frames.dart';
import '../widgets/propaganda_button.dart';
import 'sprite_cadete.dart';
import 'widget_pausa.dart';

/// PINBALL DEL COMITÉ CENTRAL.
///
/// Mesa vertical 1.0×1.5 (coordenadas relativas) con bumpers redondos
/// que son retratos del Comité, dos paletas inferiores accionadas con
/// A / D y un lanzador a la derecha. La bola se carga con la barra
/// espaciadora; las paredes y los bumpers la rebotan. Si cae por el
/// hueco entre paletas, se pierde una vida (3 vidas). El highscore se
/// almacena en flags del EstadoJuego.
class PantallaPinballComite extends StatefulWidget {
  final EstadoJuego estado;

  const PantallaPinballComite({super.key, required this.estado});

  @override
  State<PantallaPinballComite> createState() => _PantallaPinballComiteState();
}

class _PantallaPinballComiteState extends State<PantallaPinballComite>
    with SingleTickerProviderStateMixin {
  /// Coordenadas relativas (0..1 horizontal, 0..1.5 vertical para mesa
  /// alargada). Todas las medidas son fracciones para no depender del
  /// tamaño de pantalla.
  static const double anchoMesa = 1.0;
  static const double altoMesa = 1.5;

  /// Radio de la bola en coords relativas. Calibrado a 0.045
  /// (del original 0.028, ~1.6×). El render visual aplica además
  /// un `factorEscalaVisualBola` de 1.4 para compensar el padding
  /// transparente del PNG cuadrado: la bola visible queda ~2.25×
  /// del tamaño original, claramente legible sin invadir el
  /// resto del tablero.
  static const double radioBola = 0.045;

  /// Gravedad efectiva (unidades relativas por segundo cuadrado).
  /// Bajada de 1.7 a 1.15 para que la bola sea más manejable y
  /// permita más tiempo de lectura visual del cadete-bola PNG.
  static const double gravedadMesa = 1.15;

  /// Cap a la velocidad absoluta de la bola, en unidades relativas
  /// por segundo. Evita tunneling cuando la bola cae mucho tiempo
  /// y permite ver al cadete bola en cada frame. Bajado de 2.4 a 1.9
  /// tras feedback de partida: la bola iba demasiado rápida para
  /// reaccionar con las paletas, sobre todo al venir rebotada de
  /// bumpers o slingshots.
  static const double velocidadMaximaBola = 1.9;

  /// Velocidad inicial maxima del lanzador. Bajada de 2.6 a 2.2 para
  /// que el lanzamiento sea más manejable. Sigue siendo suficiente
  /// para coronar la rampa superior cuando se carga al 70 %+.
  static const double velocidadLanzadorMaxima = 2.2;

  /// Anchura del carril del lanzador.
  static const double anchoCarrilLanzador = 0.10;

  late Ticker tickerJuego;
  Duration? marcaTemporalAnterior;
  final FocusNode nodoFoco = FocusNode(debugLabel: 'pinball_comite');

  /// Posicion de la bola.
  Offset posicionBola = const Offset(anchoMesa - 0.05, altoMesa - 0.15);
  Offset velocidadBola = Offset.zero;
  bool bolaEnLanzador = true;

  /// Distancia acumulada que ha rodado la bola — sirve para
  /// seleccionar el frame de animación del cadete-bola
  /// (cadete_bola_f01..f04) y hacer el ciclo en bucle. El paso
  /// entre frames es ~0.04 unidades de mesa (≈ un cuarto de
  /// revolución por celda de paso).
  double acumuladorRodaduraBola = 0.0;

  /// Carga del lanzador: 0 a 1.
  double cargaLanzador = 0.0;
  bool lanzadorPulsado = false;

  /// Rotacion de cada paleta: 0 reposo, 1 levantada completamente.
  double rotacionPaletaIzquierda = 0.0;
  double rotacionPaletaDerecha = 0.0;
  bool paletaIzquierdaActiva = false;
  bool paletaDerechaActiva = false;

  int puntuacion = 0;
  int vidas = 3;
  int multiplicador = 1;
  bool partidaTerminada = false;

  /// Bumpers fijos. Cada uno: posicion relativa, radio, score, etiqueta.
  /// Indice del tablero actual (0 = Antecamara, 1 = Salon, 2 = Cripta).
  int indiceTableroActual = 0;

  /// Configuracion de los tres tableros encadenados.
  late final List<_ConfiguracionTablero> tableros;

  /// Atajos al tablero activo.
  List<_BumperRetrato> get bumpers => tableros[indiceTableroActual].bumpers;
  List<_TargetVertical> get targets => tableros[indiceTableroActual].targets;
  _ConfiguracionTablero get tableroActual => tableros[indiceTableroActual];

  /// Cuando la bola ha sido enviada al siguiente tablero, la animacion
  /// dura unos frames con un alpha de transicion.
  double progresoTransicion = 0;

  /// Jefe-sarcofago de la cripta (solo en tablero 2).
  _JefeSarcofago? jefe;

  /// Sprite PNG del sarcófago para el painter. Si es null se cae al
  /// dibujado procedimental como fallback.
  ui.Image? imagenSarcofago;

  /// Sprites opcionales de los elementos del pinball (§11 del
  /// `BRIEFING_ARTE.md`). Si alguno es `null` el painter usa el
  /// dibujo procedural existente. Se cargan en `initState` con
  /// `rootBundle.load` y se ignoran silenciosamente si el asset no
  /// está en disco (no rompe el minijuego mientras los PNGs llegan).
  ui.Image? imagenTableroAntecamara;
  ui.Image? imagenTableroSalon;
  ui.Image? imagenTableroCripta;
  ui.Image? imagenBumper;
  ui.Image? imagenSlingshotIzq;
  ui.Image? imagenSlingshotDer;
  ui.Image? imagenFlipperIzq;
  ui.Image? imagenFlipperDer;
  ui.Image? imagenTargetActivo;
  ui.Image? imagenTargetCaido;
  ui.Image? imagenLaneApagado;
  ui.Image? imagenLaneEncendido;
  ui.Image? imagenSpinner;
  ui.Image? imagenLanzadorResorte;
  ui.Image? imagenSaucer;

  /// Mensajes flotantes (puntos al rebotar).
  final List<_TextoFlotante> textosFlotantes = <_TextoFlotante>[];

  /// Mensaje grande de aviso (multibola, vida perdida...).
  _AvisoCentral? avisoCentral;

  /// Animacion de flash global (al impactar bumper destacado).
  double flashRojoFase = 0.0;

  /// Sacudida cinetica del tablero (camera shake) cuando hay golpe fuerte
  /// o se activa BANDERA ROJA. Decae con el tiempo.
  double intensidadSacudida = 0.0;

  /// Estela de posiciones recientes de la bola: hasta 12 puntos para
  /// dibujar una cola desvaneciendo cuando la bola va rapida.
  final List<Offset> historialPosicionesBola = <Offset>[];
  static const int longitudEstela = 12;

  /// Chispas que saltan al golpear bumpers/targets.
  final List<_ChispaPinball> chispasPinball = <_ChispaPinball>[];

  /// Combo: rebotes seguidos sin caer en outhole. Se reinicia al perder
  /// vida o tras un timeout sin rebotar.
  int golpesComboActual = 0;
  double tiempoComboRestanteSegundos = 0;

  /// Multiplicador máximo histórico alcanzado en la partida.
  int multiplicadorMejor = 1;

  /// Multibola fantasma: al entrar a la Cripta (3er tablero) aparecen
  /// dos bolas espectrales que orbitan la bola real durante 8 segundos
  /// y dan +50 puntos al pasar cerca de un bumper.
  static const double duracionMultibolaSegundos = 8.0;
  double tiempoMultibolaRestante = 0;

  /// Fase para orbitar las bolas fantasma alrededor de la bola real.
  double faseMultibola = 0;

  /// Dos slingshots activos sobre las paletas. Comunes a todos los
  /// tableros: aceleran el ritmo del juego clásico tipo Williams.
  final List<_Slingshot> slingshots = <_Slingshot>[
    // Izquierdo: triángulo encima y a la izquierda de la paleta izq.
    _Slingshot(
      vertice1: const Offset(0.08, 1.08),
      vertice2: const Offset(0.24, 1.14),
      vertice3: const Offset(0.08, 1.24),
      puntos: 80,
      etiqueta: '+80',
    ),
    // Derecho: triángulo encima y a la derecha de la paleta dch.
    _Slingshot(
      vertice1: const Offset(0.92, 1.08),
      vertice2: const Offset(0.76, 1.14),
      vertice3: const Offset(0.92, 1.24),
      puntos: 80,
      etiqueta: '+80',
    ),
  ];

  /// Cuatro lanes superiores con letras COMÉ — al iluminar los cuatro,
  /// el multiplicador sube y se reinicia la fila.
  final List<_LaneSuperior> lanesSuperior = <_LaneSuperior>[
    _LaneSuperior(
      rect: const Rect.fromLTWH(0.10, 0.08, 0.12, 0.05),
      letra: 'C',
    ),
    _LaneSuperior(
      rect: const Rect.fromLTWH(0.30, 0.08, 0.12, 0.05),
      letra: 'O',
    ),
    _LaneSuperior(
      rect: const Rect.fromLTWH(0.50, 0.08, 0.12, 0.05),
      letra: 'M',
    ),
    _LaneSuperior(
      rect: const Rect.fromLTWH(0.70, 0.08, 0.12, 0.05),
      letra: 'É',
    ),
  ];

  /// Skill shot: tras lanzar con carga alta, hay una ventana de tiempo
  /// para golpear un bumper alto y conseguir +5000 puntos.
  bool skillShotDisponible = false;
  double tiempoSkillShotRestante = 0;
  static const double duracionVentanaSkillShotSegundos = 3.0;
  static const int puntosSkillShot = 5000;

  /// SAUCER / LOCK HOLE central: captura la bola, espera, y la
  /// dispara hacia un ángulo semi-aleatorio. +300 pts cada captura.
  static const Offset posicionSaucer = Offset(0.50, 0.20);
  static const double radioSaucer = 0.045;
  bool bolaEnSaucer = false;
  double tiempoEnSaucerRestante = 0;
  static const double duracionRetencionSaucerSegundos = 1.4;
  int totalCapturasSaucer = 0;

  /// SPINNER vertical en el lateral izquierdo: la bola al atravesarlo
  /// hace girar el aspa y suma puntos por cada vuelta cruzada.
  static const Rect rectSpinner = Rect.fromLTWH(0.04, 0.50, 0.055, 0.13);

  /// Ángulo acumulado del aspa.
  double anguloSpinner = 0.0;

  /// Velocidad angular actual (radianes/segundo) del aspa que decae.
  double velocidadAngularSpinner = 0.0;

  /// Posición previa de la bola dentro del spinner — usada para
  /// detectar cuándo cruza un "ciclo" y otorgar puntos.
  double? yEntradaSpinner;

  /// Modo BUROCRACIA AVANZADA: x2 puntos durante 12 s.
  bool burocraciaAvanzadaActiva = false;
  double tiempoBurocraciaAvanzadaRestante = 0;
  static const double duracionBurocraciaAvanzadaSegundos = 12.0;
  int vecesCompletadasCome = 0;

  /// RAMPA DE RETORNO: tubo curvo desde la esquina superior izquierda
  /// del campo hasta el carril derecho (justo encima del lanzador). La
  /// bola entra si llega con velocidad mínima vertical en la boca de
  /// entrada; recorre una curva Bézier cuadrática en 0.95 s y reemerge.
  /// Cada rampa completada vale +500 pts. Encadenar 3 en menos de 15 s
  /// dispara "TÚNEL FRENÉTICO": x2 durante 8 s.
  static const Offset puntoEntradaRampaRetorno = Offset(0.06, 0.12);
  // Salida en el lateral derecho del campo pero a una altura cómoda
  // (y=0.30), lejos del carril del lanzador (que ocupa x ≥ 0.90).
  static const Offset puntoSalidaRampaRetorno = Offset(0.82, 0.30);
  // El control point está MUY a la derecha (x=0.75) para que la
  // tangente Bézier en el punto de salida apunte casi verticalmente
  // hacia abajo: la bola sale del tubo cayendo, no disparada en
  // horizontal — si no, choca contra el slingshot derecho y rebota
  // de vuelta al carril del lanzador.
  static const Offset puntoControlRampaRetorno = Offset(0.75, 0.04);
  // Velocidad de salida moderada: deja que la gravedad la acelere.
  static const double velocidadSalidaRampaRetorno = 2.0;
  static const double duracionRampaRetornoSegundos = 0.95;
  static const double radioCapturaRampaRetorno = 0.055;
  static const double velocidadMinimaCapturaRampa = 1.5;
  bool bolaEnRampaRetorno = false;
  double progresoRampaRetorno = 0;
  int rampasEnCadena = 0;
  double tiempoUltimaRampaSegundos = 0;
  bool tunelFreneticoActivo = false;
  double tiempoTunelFreneticoRestante = 0;
  static const double duracionTunelFreneticoSegundos = 8.0;

  /// PAUSA del minijuego: tecla P congela toda la simulación.
  bool partidaPausada = false;

  /// DROP BANK con bonus exponencial: cada vez que se limpia la fila
  /// completa de targets, se suma `1000 · 2^(N-1)` puntos hasta un
  /// máximo de 32000, y el contador `vecesLimpiadoBank` sube.
  int vecesLimpiadoBank = 0;

  /// Tiempo (s) restante en el "modo bandera roja": mientras > 0,
  /// los targets están abajo. Al llegar a 0 se inicia el levantamiento
  /// escalonado en cascada.
  double tiempoBankRestante = 0;
  static const double duracionPausaBank = 0.9;

  /// Bonus base que se duplica con cada limpieza.
  static const int bonusBaseBank = 1000;
  static const int bonusMaximoBank = 32000;

  /// Generador unico para pequenos jitters visuales del shake.
  final math.Random _rngVisual = math.Random();

  @override
  void initState() {
    super.initState();
    tableros = _generarTableros();
    jefe = _JefeSarcofago(
      posicion: const Offset(0.50, 0.45),
      radio: 0.13,
      vidasIniciales: 6,
    );
    tickerJuego = createTicker(_alTick)..start();
    _cargarSpriteSarcofago();
    _cargarSpritesPinballOpcionales();
  }

  Future<void> _cargarSpriteSarcofago() async {
    final ByteData datos = await rootBundle.load('assets/svg/sarcofago.png');
    final ui.Codec codec = await ui.instantiateImageCodec(
      datos.buffer.asUint8List(),
    );
    final ui.FrameInfo frame = await codec.getNextFrame();
    if (!mounted) return;
    setState(() => imagenSarcofago = frame.image);
  }

  /// Intenta cargar un PNG opcional. Si el asset no existe en disco
  /// devuelve `null` silenciosamente — el painter usará el dibujo
  /// procedural como fallback. Esto permite ir entregando los
  /// PNGs del §11 del briefing uno a uno sin romper el juego.
  Future<ui.Image?> _intentarCargarPng(String ruta) async {
    try {
      final ByteData datos = await rootBundle.load(ruta);
      final ui.Codec codec = await ui.instantiateImageCodec(
        datos.buffer.asUint8List(),
      );
      final ui.FrameInfo frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  Future<void> _cargarSpritesPinballOpcionales() async {
    final resultados = await Future.wait<ui.Image?>([
      _intentarCargarPng('assets/svg/pinball_tablero_antecamara.png'),
      _intentarCargarPng('assets/svg/pinball_tablero_salon.png'),
      _intentarCargarPng('assets/svg/pinball_tablero_cripta.png'),
      _intentarCargarPng('assets/svg/pinball_bumper.png'),
      _intentarCargarPng('assets/svg/pinball_slingshot_izq.png'),
      _intentarCargarPng('assets/svg/pinball_slingshot_der.png'),
      _intentarCargarPng('assets/svg/pinball_flipper_izq.png'),
      _intentarCargarPng('assets/svg/pinball_flipper_der.png'),
      _intentarCargarPng('assets/svg/pinball_target_activo.png'),
      _intentarCargarPng('assets/svg/pinball_target_caido.png'),
      _intentarCargarPng('assets/svg/pinball_lane_apagado.png'),
      _intentarCargarPng('assets/svg/pinball_lane_encendido.png'),
      _intentarCargarPng('assets/svg/pinball_spinner.png'),
      _intentarCargarPng('assets/svg/pinball_lanzador_resorte.png'),
      _intentarCargarPng('assets/svg/pinball_saucer.png'),
    ]);
    if (!mounted) return;
    setState(() {
      imagenTableroAntecamara = resultados[0];
      imagenTableroSalon = resultados[1];
      imagenTableroCripta = resultados[2];
      imagenBumper = resultados[3];
      imagenSlingshotIzq = resultados[4];
      imagenSlingshotDer = resultados[5];
      imagenFlipperIzq = resultados[6];
      imagenFlipperDer = resultados[7];
      imagenTargetActivo = resultados[8];
      imagenTargetCaido = resultados[9];
      imagenLaneApagado = resultados[10];
      imagenLaneEncendido = resultados[11];
      imagenSpinner = resultados[12];
      imagenLanzadorResorte = resultados[13];
      imagenSaucer = resultados[14];
    });
  }

  /// Devuelve la imagen del fondo de tablero correspondiente al
  /// índice activo, o `null` si el PNG no está disponible.
  ui.Image? get _imagenFondoTableroActivo {
    switch (indiceTableroActual) {
      case 0:
        return imagenTableroAntecamara;
      case 1:
        return imagenTableroSalon;
      case 2:
        return imagenTableroCripta;
      default:
        return null;
    }
  }

  List<_ConfiguracionTablero> _generarTableros() {
    return <_ConfiguracionTablero>[
      _ConfiguracionTablero(
        nombre: 'ANTECÁMARA F-447',
        colorAcento: PaletaRotulador.rojoEstampilla,
        // Antecámara: papel viejo claro (mas iluminada).
        colorFondoSuperior: PaletaRotulador.papelSucio,
        colorFondoInferior: PaletaRotulador.papel,
        bumpers: _generarBumpersAntecamara(),
        targets: _generarTargetsAntecamara(),
      ),
      _ConfiguracionTablero(
        nombre: 'SALÓN DEL COMITÉ',
        colorAcento: PaletaRotulador.rojoEstampilla,
        // Salón: papel sucio uniforme.
        colorFondoSuperior: PaletaRotulador.papelSucio,
        colorFondoInferior: PaletaRotulador.papelSucio,
        bumpers: _generarBumpersSalon(),
        targets: _generarTargetsSalon(),
      ),
      _ConfiguracionTablero(
        nombre: 'CRIPTA DE DIRECTORSKOV',
        colorAcento: PaletaRotulador.rojoEstampilla,
        // Cripta: tinta diluida media (lo más oscuro de los tres).
        colorFondoSuperior: PaletaRotulador.tintaDiluida(0.30),
        colorFondoInferior: PaletaRotulador.tintaDiluida(0.55),
        bumpers: _generarBumpersCripta(),
        targets: const <_TargetVertical>[],
      ),
    ];
  }

  @override
  void dispose() {
    tickerJuego.dispose();
    nodoFoco.dispose();
    super.dispose();
  }

  List<_BumperRetrato> _generarBumpersAntecamara() {
    return <_BumperRetrato>[
      _BumperRetrato(
        posicion: const Offset(0.30, 0.32),
        radio: 0.07,
        puntos: 100,
        etiqueta: 'F-447',
        colorAcento: PaletaRotulador.rojoEstampilla,
        frasesAleatorias: const ['F-447 SELLADO', 'TRIPLE COPIA', '+100'],
      ),
      _BumperRetrato(
        posicion: const Offset(0.70, 0.32),
        radio: 0.07,
        puntos: 100,
        etiqueta: 'TIMBRE',
        colorAcento: PaletaRotulador.rojoEstampilla,
        frasesAleatorias: const ['¡TIMBRE!', 'PASE INMEDIATO', '+100'],
      ),
      _BumperRetrato(
        posicion: const Offset(0.50, 0.50),
        radio: 0.08,
        puntos: 250,
        etiqueta: 'KRL',
        colorAcento: PaletaRotulador.rojoEstampilla,
        frasesAleatorias: const [
          'KRILOV ANOTA',
          'ESTO VA AL EXPEDIENTE',
          'TURNO DOBLE',
        ],
      ),
      _BumperRetrato(
        posicion: const Offset(0.20, 0.70),
        radio: 0.06,
        puntos: 75,
        etiqueta: 'VAS',
        colorAcento: PaletaRotulador.rojoEstampilla,
        frasesAleatorias: const [
          'VASSILIEV TOSE',
          'CAPITÁN PRESENTE',
          'GLORIA',
        ],
      ),
      _BumperRetrato(
        posicion: const Offset(0.80, 0.70),
        radio: 0.06,
        puntos: 75,
        etiqueta: 'OST',
        colorAcento: PaletaRotulador.rojoEstampilla,
        frasesAleatorias: const ['OSTROG GRUÑE', 'BIEN, CADETE', '+75'],
      ),
      _BumperRetrato(
        posicion: const Offset(0.50, 0.90),
        radio: 0.05,
        puntos: 50,
        etiqueta: 'COLA',
        colorAcento: PaletaCosmoSovietica.tintaTenue,
        frasesAleatorias: const ['HAY COLA', 'ESPERA EN FILA', 'PASE 7'],
      ),
    ];
  }

  List<_TargetVertical> _generarTargetsAntecamara() {
    return <_TargetVertical>[
      _TargetVertical(
        rect: const Rect.fromLTRB(0.02, 0.40, 0.07, 0.55),
        puntos: 200,
        etiqueta: 'F',
      ),
      _TargetVertical(
        rect: const Rect.fromLTRB(0.02, 0.60, 0.07, 0.75),
        puntos: 200,
        etiqueta: '447',
      ),
      // Targets derechos REPOSICIONADOS fuera del carril del lanzador
      // (que ocupa x >= 0.90 = anchoMesa - anchoCarrilLanzador). Antes
      // estaban en x=0.93..0.98, lo cual intersectaba la trayectoria
      // ascendente de la bola desde el lanzador: la bola rebotaba en
      // estos targets antes de alcanzar la rampa curva superior. Ahora
      // están justo al borde INTERNO del carril (x=0.83..0.88),
      // simétricos a los izquierdos respecto al campo de juego.
      _TargetVertical(
        rect: const Rect.fromLTRB(0.83, 0.40, 0.88, 0.55),
        puntos: 200,
        etiqueta: 'F',
      ),
      _TargetVertical(
        rect: const Rect.fromLTRB(0.83, 0.60, 0.88, 0.75),
        puntos: 200,
        etiqueta: '447',
      ),
    ];
  }

  /// Tablero 1: el Salón del Comité. Bumpers retratos del Politburo
  /// en disposición simétrica.
  List<_BumperRetrato> _generarBumpersSalon() {
    return <_BumperRetrato>[
      _BumperRetrato(
        posicion: const Offset(0.30, 0.28),
        radio: 0.08,
        puntos: 150,
        etiqueta: 'BRZ',
        colorAcento: PaletaRotulador.rojoEstampilla,
        frasesAleatorias: const ['BRÉZHNEV BENDICE', 'CEJAS POR LA PATRIA'],
      ),
      _BumperRetrato(
        posicion: const Offset(0.70, 0.28),
        radio: 0.08,
        puntos: 150,
        etiqueta: 'MOL',
        colorAcento: PaletaRotulador.rojoEstampilla,
        frasesAleatorias: const ['MOLOTOV ESPERA', 'AL PIE DEL CAÑÓN'],
      ),
      _BumperRetrato(
        posicion: const Offset(0.20, 0.55),
        radio: 0.07,
        puntos: 120,
        etiqueta: 'AND',
        colorAcento: PaletaRotulador.rojoEstampilla,
        frasesAleatorias: const ['ANDROPOV SONRÍE', 'NUNCA'],
      ),
      _BumperRetrato(
        posicion: const Offset(0.80, 0.55),
        radio: 0.07,
        puntos: 120,
        etiqueta: 'CHR',
        colorAcento: PaletaRotulador.rojoEstampilla,
        frasesAleatorias: const ['CHRENNIKOV TOSE', 'AL ARCHIVO'],
      ),
      _BumperRetrato(
        posicion: const Offset(0.50, 0.42),
        radio: 0.09,
        puntos: 300,
        etiqueta: 'CC',
        colorAcento: PaletaRotulador.rojoEstampilla,
        frasesAleatorias: const ['COMITÉ CENTRAL', 'UNÁNIME', 'POR ACLAMACIÓN'],
      ),
      _BumperRetrato(
        posicion: const Offset(0.50, 0.85),
        radio: 0.06,
        puntos: 75,
        etiqueta: 'SEC',
        colorAcento: PaletaCosmoSovietica.tintaTenue,
        frasesAleatorias: const ['SECRETARIA', 'TOMA NOTA', '+75'],
      ),
    ];
  }

  List<_TargetVertical> _generarTargetsSalon() {
    return <_TargetVertical>[
      _TargetVertical(
        rect: const Rect.fromLTRB(0.03, 0.30, 0.08, 0.42),
        puntos: 250,
        etiqueta: 'C',
      ),
      _TargetVertical(
        rect: const Rect.fromLTRB(0.03, 0.45, 0.08, 0.57),
        puntos: 250,
        etiqueta: 'C',
      ),
      // Misma razón que en Antecámara: estos targets antes a x=0.92..0.97
      // estaban dentro del carril del lanzador (x >= 0.90) y bloqueaban
      // la subida de la bola. Movidos al borde interno del carril.
      _TargetVertical(
        rect: const Rect.fromLTRB(0.82, 0.30, 0.87, 0.42),
        puntos: 250,
        etiqueta: 'P',
      ),
      _TargetVertical(
        rect: const Rect.fromLTRB(0.82, 0.45, 0.87, 0.57),
        puntos: 250,
        etiqueta: 'C',
      ),
    ];
  }

  /// Tablero 2: la Cripta de Directorskov. Pocos bumpers pero un jefe
  /// central (sarcofago) con varios puntos de vida que hay que vaciar.
  List<_BumperRetrato> _generarBumpersCripta() {
    return <_BumperRetrato>[
      _BumperRetrato(
        posicion: const Offset(0.18, 0.85),
        radio: 0.05,
        puntos: 80,
        etiqueta: 'CIR',
        colorAcento: PaletaRotulador.rojoEstampilla,
        frasesAleatorias: const ['CIRIO', 'ETERNA LUZ', '+80'],
      ),
      _BumperRetrato(
        posicion: const Offset(0.82, 0.85),
        radio: 0.05,
        puntos: 80,
        etiqueta: 'CIR',
        colorAcento: PaletaRotulador.rojoEstampilla,
        frasesAleatorias: const ['CIRIO', 'ETERNA LUZ', '+80'],
      ),
      _BumperRetrato(
        posicion: const Offset(0.30, 0.30),
        radio: 0.05,
        puntos: 100,
        etiqueta: 'CRUZ',
        colorAcento: PaletaCosmoSovietica.tintaTenue,
        frasesAleatorias: const ['+100', 'CRUZ DE PAPEL', 'NÚMERO 7'],
      ),
      _BumperRetrato(
        posicion: const Offset(0.70, 0.30),
        radio: 0.05,
        puntos: 100,
        etiqueta: 'CRUZ',
        colorAcento: PaletaRotulador.tintaDiluida(0.45),
        frasesAleatorias: const ['+100', 'CRUZ DE PAPEL', 'NÚMERO 7'],
      ),
    ];
  }

  void _resetearPartida() {
    setState(() {
      puntuacion = 0;
      vidas = 3;
      multiplicador = 1;
      partidaTerminada = false;
      bolaEnLanzador = true;
      posicionBola = const Offset(anchoMesa - 0.05, altoMesa - 0.15);
      velocidadBola = Offset.zero;
      cargaLanzador = 0;
      textosFlotantes.clear();
      avisoCentral = null;
      historialPosicionesBola.clear();
      intensidadSacudida = 0;
      flashRojoFase = 0;
      indiceTableroActual = 0;
      tiempoMultibolaRestante = 0;
      faseMultibola = 0;
      golpesComboActual = 0;
      tiempoComboRestanteSegundos = 0;
      chispasPinball.clear();
      if (jefe != null) {
        jefe!.vidasRestantes = jefe!.vidasIniciales;
        jefe!.flashImpacto = 0;
      }
      for (final tablero in tableros) {
        for (final bumper in tablero.bumpers) {
          bumper.flashIndividual = 0;
        }
        for (final target in tablero.targets) {
          target.golpeado = false;
        }
      }
    });
  }

  void _alTick(Duration tiempoAcumulado) {
    final marcaAnterior = marcaTemporalAnterior;
    marcaTemporalAnterior = tiempoAcumulado;
    if (marcaAnterior == null) return;
    final dt = (tiempoAcumulado - marcaAnterior).inMicroseconds / 1e6;
    if (dt <= 0) return;
    // Pausa: congelamos toda la simulación. El ticker sigue corriendo
    // para mantener la marca temporal actualizada pero no avanzamos
    // ningún estado del juego ni redibujamos.
    if (partidaPausada) return;

    // Decaer textos flotantes.
    for (final texto in textosFlotantes) {
      texto.vidaRestante -= dt;
      texto.posicion = texto.posicion.translate(0, -dt * 0.18);
    }
    textosFlotantes.removeWhere((t) => t.vidaRestante <= 0);

    // Actualizar chispas (gravedad ligera + decaimiento).
    for (final chispa in chispasPinball) {
      chispa.posicion =
          chispa.posicion +
          Offset(chispa.velocidad.dx * dt, chispa.velocidad.dy * dt);
      chispa.velocidad = Offset(
        chispa.velocidad.dx * 0.92,
        chispa.velocidad.dy + 0.8 * dt,
      );
      chispa.vidaRestante -= dt;
    }
    chispasPinball.removeWhere((c) => c.vidaRestante <= 0);

    // Decaer combo.
    if (tiempoComboRestanteSegundos > 0) {
      tiempoComboRestanteSegundos -= dt;
      if (tiempoComboRestanteSegundos <= 0) {
        tiempoComboRestanteSegundos = 0;
        golpesComboActual = 0;
      }
    }

    // Multibola fantasma: actualizar fase y chequear pase cerca de bumpers.
    if (tiempoMultibolaRestante > 0) {
      tiempoMultibolaRestante -= dt;
      faseMultibola += dt * 2.4;
      // Calcular posiciones orbitales de las 2 bolas fantasma.
      for (int indiceFantasma = 0; indiceFantasma < 2; indiceFantasma++) {
        final double anguloOrbital = faseMultibola + indiceFantasma * math.pi;
        final Offset posFantasma = posicionBola.translate(
          math.cos(anguloOrbital) * 0.10,
          math.sin(anguloOrbital) * 0.06,
        );
        for (final bumper in bumpers) {
          if ((posFantasma - bumper.posicion).distance < bumper.radio * 1.10) {
            // Solo registrar una vez por proximidad: usar flashIndividual.
            if (bumper.flashIndividual < 0.05) {
              bumper.flashIndividual = 0.55;
              puntuacion += 50;
              textosFlotantes.add(
                _TextoFlotante(
                  texto: '+50',
                  posicion: posFantasma,
                  vidaRestante: 0.7,
                ),
              );
            }
          }
        }
      }
    }

    if (avisoCentral != null) {
      avisoCentral!.vidaRestante -= dt;
      if (avisoCentral!.vidaRestante <= 0) {
        avisoCentral = null;
      }
    }
    if (flashRojoFase > 0) {
      flashRojoFase = math.max(0, flashRojoFase - dt * 3.5);
    }
    if (intensidadSacudida > 0) {
      intensidadSacudida = math.max(0, intensidadSacudida - dt * 5.0);
    }
    // Decaer flash individual de cada bumper.
    for (final bumper in bumpers) {
      if (bumper.flashIndividual > 0) {
        bumper.flashIndividual = math.max(0, bumper.flashIndividual - dt * 3.0);
      }
    }
    // Decaer flash de slingshots y lanes.
    for (final slingshot in slingshots) {
      if (slingshot.flashIndividual > 0) {
        slingshot.flashIndividual = math.max(
          0,
          slingshot.flashIndividual - dt * 4.0,
        );
      }
    }
    for (final lane in lanesSuperior) {
      if (lane.flashFase > 0) {
        lane.flashFase = math.max(0, lane.flashFase - dt * 2.5);
      }
    }
    // Ventana de skill shot: caducidad y desactivación.
    if (skillShotDisponible) {
      tiempoSkillShotRestante -= dt;
      if (tiempoSkillShotRestante <= 0) {
        skillShotDisponible = false;
        tiempoSkillShotRestante = 0;
      }
    }
    // Spinner: rotación se actualiza por velocidad angular con fricción.
    if (velocidadAngularSpinner != 0) {
      anguloSpinner += velocidadAngularSpinner * dt;
      // Decaimiento lineal: el aspa frena con el aire.
      velocidadAngularSpinner *= math.exp(-dt * 1.8);
      if (velocidadAngularSpinner.abs() < 0.02) {
        velocidadAngularSpinner = 0;
      }
    }
    // DROP BANK: cuenta atrás de la pausa global y del levantamiento
    // individual de cada target. Cuando `tiempoHastaLevantarse` llega
    // a 0, el target se "levanta" (golpeado=false) con flash visual.
    if (tiempoBankRestante > 0) {
      tiempoBankRestante = math.max(0, tiempoBankRestante - dt);
    }
    for (final objetivo in targets) {
      if (objetivo.tiempoHastaLevantarse > 0) {
        objetivo.tiempoHastaLevantarse -= dt;
        if (objetivo.tiempoHastaLevantarse <= 0) {
          objetivo.tiempoHastaLevantarse = 0;
          objetivo.golpeado = false;
          objetivo.flashLevantamiento = 1.0;
        }
      }
      if (objetivo.flashLevantamiento > 0) {
        objetivo.flashLevantamiento = math.max(
          0,
          objetivo.flashLevantamiento - dt * 3.0,
        );
      }
    }

    // Modo TÚNEL FRENÉTICO: cuenta atrás y desactivación.
    if (tunelFreneticoActivo) {
      tiempoTunelFreneticoRestante -= dt;
      if (tiempoTunelFreneticoRestante <= 0) {
        tunelFreneticoActivo = false;
        tiempoTunelFreneticoRestante = 0;
        multiplicador = math.max(1, multiplicador - 1);
        avisoCentral = _AvisoCentral(
          texto: 'TÚNEL CALMADO\nMULTI x$multiplicador',
          vidaRestante: 1.2,
        );
      }
    }
    // Modo BUROCRACIA AVANZADA: cuenta atrás y desactivación.
    if (burocraciaAvanzadaActiva) {
      tiempoBurocraciaAvanzadaRestante -= dt;
      if (tiempoBurocraciaAvanzadaRestante <= 0) {
        burocraciaAvanzadaActiva = false;
        tiempoBurocraciaAvanzadaRestante = 0;
        multiplicador = math.max(1, multiplicador - 2);
        avisoCentral = _AvisoCentral(
          texto: 'BUROCRACIA NORMAL\nMULTI x$multiplicador',
          vidaRestante: 1.2,
        );
      }
    }
    // Decaer flash del jefe.
    if (jefe != null && jefe!.flashImpacto > 0) {
      jefe!.flashImpacto = math.max(0, jefe!.flashImpacto - dt * 2.5);
    }
    if (progresoTransicion > 0) {
      progresoTransicion = math.max(0, progresoTransicion - dt * 2.0);
    }

    // Rotacion paletas.
    final velocidadPaleta = 12.0; // 0..1 en ~80 ms.
    rotacionPaletaIzquierda = _aproximar(
      rotacionPaletaIzquierda,
      paletaIzquierdaActiva ? 1.0 : 0.0,
      velocidadPaleta * dt,
    );
    rotacionPaletaDerecha = _aproximar(
      rotacionPaletaDerecha,
      paletaDerechaActiva ? 1.0 : 0.0,
      velocidadPaleta * dt,
    );

    if (partidaTerminada) {
      setState(() {});
      return;
    }

    // Cargar lanzador.
    if (lanzadorPulsado && bolaEnLanzador) {
      cargaLanzador = math.min(1.0, cargaLanzador + dt * 1.2);
    }

    if (bolaEnLanzador) {
      posicionBola = Offset(
        anchoMesa - 0.05,
        altoMesa - 0.15 + cargaLanzador * 0.04,
      );
      setState(() {});
      return;
    }

    // Simulacion bola.
    velocidadBola = velocidadBola.translate(0, gravedadMesa * dt);
    // Cap a la velocidad para evitar tunneling y mejorar legibilidad.
    final double magnitudVelocidad = velocidadBola.distance;
    if (magnitudVelocidad > velocidadMaximaBola) {
      velocidadBola = velocidadBola * (velocidadMaximaBola / magnitudVelocidad);
    }
    final desplazamiento = velocidadBola * dt;
    Offset nuevaPos = posicionBola + desplazamiento;
    // Avanzamos el ciclo de rotación de la bola (4 frames PNG)
    // proporcional a la magnitud del desplazamiento real.
    acumuladorRodaduraBola += desplazamiento.distance;

    // Colisiones con paredes laterales.
    if (nuevaPos.dx - radioBola < 0) {
      nuevaPos = Offset(radioBola, nuevaPos.dy);
      velocidadBola = Offset(-velocidadBola.dx * 0.86, velocidadBola.dy);
    }
    if (nuevaPos.dx + radioBola > anchoMesa) {
      nuevaPos = Offset(anchoMesa - radioBola, nuevaPos.dy);
      velocidadBola = Offset(-velocidadBola.dx * 0.86, velocidadBola.dy);
    }

    // Rampa curva en la esquina superior derecha:
    // empuja la bola que sube por el carril del lanzador hacia el campo.
    // Centro del cuarto de circulo en (anchoMesa - anchoCarrilLanzador, radioRampa).
    // La curva conecta el carril vertical con el techo del campo de juego.
    const double radioRampa = anchoCarrilLanzador;
    const Offset centroRampa = Offset(
      anchoMesa - anchoCarrilLanzador,
      radioRampa,
    );
    final Offset diferenciaRampa = nuevaPos - centroRampa;
    bool gestionadoPorRampa = false;
    if (diferenciaRampa.dx > 0 && diferenciaRampa.dy < 0) {
      final double distanciaRampa = diferenciaRampa.distance;
      final double limiteRampa = radioRampa - radioBola;
      if (distanciaRampa > limiteRampa && distanciaRampa > 0) {
        final Offset normalExterior = diferenciaRampa / distanciaRampa;
        nuevaPos = centroRampa + normalExterior * limiteRampa;
        final double productoEscalar =
            velocidadBola.dx * normalExterior.dx +
            velocidadBola.dy * normalExterior.dy;
        if (productoEscalar > 0) {
          velocidadBola =
              velocidadBola - normalExterior * (2 * productoEscalar) * 0.86;
        }
        // Empujon constante hacia el campo para garantizar que la bola
        // no quede atascada subiendo por el carril cuando llega con poca
        // velocidad horizontal.
        velocidadBola = velocidadBola + const Offset(-0.25, 0.10);
      }
      gestionadoPorRampa = true;
    }
    // Techo del campo de juego (solo a la izquierda de la rampa y
    // con un hueco central cuando hay portal hacia otro tablero).
    final bool hayPortalArriba = indiceTableroActual < tableros.length - 1;
    final bool enZonaPortal =
        hayPortalArriba && nuevaPos.dx > 0.35 && nuevaPos.dx < 0.65;
    if (!gestionadoPorRampa && !enZonaPortal && nuevaPos.dy - radioBola < 0) {
      nuevaPos = Offset(nuevaPos.dx, radioBola);
      velocidadBola = Offset(velocidadBola.dx, -velocidadBola.dy * 0.86);
    }

    // Colisiones con carril del lanzador (pared interna).
    // El carril ocupa los ultimos `anchoCarrilLanzador` horizontalmente
    // en la franja vertical superior a 1.0 (mesa baja). Si la bola entra
    // de regreso al carril por encima, dejamos que vuelva al lanzador.
    if (nuevaPos.dy > 1.0 && nuevaPos.dx > anchoMesa - anchoCarrilLanzador) {
      // Borde izquierdo del carril.
      if (nuevaPos.dx - radioBola < anchoMesa - anchoCarrilLanzador &&
          velocidadBola.dx < 0) {
        nuevaPos = Offset(
          anchoMesa - anchoCarrilLanzador + radioBola,
          nuevaPos.dy,
        );
        velocidadBola = Offset(-velocidadBola.dx * 0.6, velocidadBola.dy);
      }
    }

    // RAMPA DE RETORNO: captura por boca de entrada. Sólo se captura
    // si la bola se acerca lo suficiente Y lleva velocidad vertical
    // ascendente mínima (no queremos que cualquier roce robe la bola).
    if (!bolaEnRampaRetorno && !bolaEnSaucer) {
      final double distanciaBoca =
          (nuevaPos - puntoEntradaRampaRetorno).distance;
      final bool velocidadAscendente =
          velocidadBola.dy < -velocidadMinimaCapturaRampa;
      if (distanciaBoca < radioCapturaRampaRetorno && velocidadAscendente) {
        bolaEnRampaRetorno = true;
        progresoRampaRetorno = 0;
        nuevaPos = puntoEntradaRampaRetorno;
        velocidadBola = Offset.zero;
        _emitirChispas(
          puntoEntradaRampaRetorno,
          cantidad: 6,
          colorPrincipal: PaletaRotulador.rojoEstampilla,
        );
        flashRojoFase = 0.55;
        avisoCentral = _AvisoCentral(
          texto: 'TÚNEL DE RETORNO\n',
          vidaRestante: 0.6,
        );
      }
    }
    // Si la bola está dentro del tubo, avanza por la curva y se salta
    // toda otra colisión.
    if (bolaEnRampaRetorno) {
      progresoRampaRetorno += dt / duracionRampaRetornoSegundos;
      if (progresoRampaRetorno >= 1.0) {
        // Salida: posición + tangente como velocidad.
        bolaEnRampaRetorno = false;
        nuevaPos = puntoSalidaRampaRetorno;
        final Offset tangenteSalida = _tangenteCurvaRampaRetorno(1.0);
        final double magnitudTangente = tangenteSalida.distance;
        if (magnitudTangente > 0) {
          velocidadBola =
              tangenteSalida / magnitudTangente * velocidadSalidaRampaRetorno;
        } else {
          velocidadBola = const Offset(0.0, 2.0);
        }
        // Encadenamiento de rampas: si la última se completó hace
        // menos de 15 s, acumulamos cadena; si no, reiniciamos.
        if (tiempoUltimaRampaSegundos > 0 && tiempoUltimaRampaSegundos < 15.0) {
          rampasEnCadena += 1;
        } else {
          rampasEnCadena = 1;
        }
        tiempoUltimaRampaSegundos = 0;
        _registrarPuntos(
          500,
          posicion: puntoSalidaRampaRetorno,
          etiqueta: '+500 RETORNO',
        );
        // 3 rampas seguidas → modo TÚNEL FRENÉTICO.
        if (rampasEnCadena >= 3 && !tunelFreneticoActivo) {
          tunelFreneticoActivo = true;
          tiempoTunelFreneticoRestante = duracionTunelFreneticoSegundos;
          multiplicador = math.min(multiplicador + 1, 8);
          if (multiplicador > multiplicadorMejor) {
            multiplicadorMejor = multiplicador;
          }
          avisoCentral = _AvisoCentral(
            texto: '★ TÚNEL FRENÉTICO ★\n3 RAMPAS · MULTI x$multiplicador',
            vidaRestante: 2.0,
          );
          flashRojoFase = 1.0;
          rampasEnCadena = 0;
        }
      } else {
        // Avance sobre la curva.
        nuevaPos = _posicionEnCurvaRampaRetorno(progresoRampaRetorno);
        velocidadBola = Offset.zero;
        posicionBola = nuevaPos;
        setState(() {});
        return; // saltar el resto del frame
      }
    }
    // Acumulamos tiempo desde la última rampa para encadenar.
    if (tiempoUltimaRampaSegundos >= 0) {
      tiempoUltimaRampaSegundos += dt;
      if (tiempoUltimaRampaSegundos > 30) {
        rampasEnCadena = 0;
      }
    }

    // SAUCER / LOCK HOLE: si la bola entra en el radio del saucer y
    // no estaba ya retenida, se queda fija en el centro durante
    // duracionRetencionSaucerSegundos. Mientras está dentro, no se
    // aplica el resto de física de bumpers/slingshots.
    if (!bolaEnSaucer) {
      final double distanciaSaucer = (nuevaPos - posicionSaucer).distance;
      if (distanciaSaucer < radioSaucer * 0.7) {
        bolaEnSaucer = true;
        tiempoEnSaucerRestante = duracionRetencionSaucerSegundos;
        totalCapturasSaucer += 1;
        nuevaPos = posicionSaucer;
        velocidadBola = Offset.zero;
        flashRojoFase = 0.7;
        _registrarPuntos(
          300,
          posicion: posicionSaucer,
          etiqueta: '+300 EXPEDIENTE',
        );
        _emitirChispas(
          posicionSaucer,
          cantidad: 10,
          colorPrincipal: PaletaRotulador.rojoEstampilla,
        );
        avisoCentral = _AvisoCentral(
          texto: 'EXPEDIENTE RECIBIDO\n#$totalCapturasSaucer',
          vidaRestante: 1.2,
        );
      }
    }
    if (bolaEnSaucer) {
      tiempoEnSaucerRestante -= dt;
      nuevaPos = posicionSaucer;
      velocidadBola = Offset.zero;
      posicionBola = nuevaPos;
      if (tiempoEnSaucerRestante <= 0) {
        bolaEnSaucer = false;
        // Dispara la bola hacia abajo con un ángulo entre -45° y +45°.
        final double anguloDisparo =
            (math.Random().nextDouble() - 0.5) * math.pi * 0.65;
        const double velocidadDisparo = 2.6;
        velocidadBola = Offset(
          math.sin(anguloDisparo) * velocidadDisparo,
          math.cos(anguloDisparo) * velocidadDisparo,
        );
        // Bumper-like push out: ligero offset para no auto-reentrar.
        nuevaPos = posicionSaucer.translate(
          math.sin(anguloDisparo) * (radioSaucer + radioBola + 0.005),
          math.cos(anguloDisparo) * (radioSaucer + radioBola + 0.005),
        );
        _emitirChispas(
          posicionSaucer,
          cantidad: 8,
          colorPrincipal: PaletaRotulador.tinta,
        );
      } else {
        setState(() {});
        return; // saltar el resto del frame
      }
    }

    // SPINNER lateral: cuando la bola está dentro del rect del spinner,
    // contamos su recorrido vertical y damos +25 por cada 0.025 unidades
    // cruzadas. También aceleramos el aspa para la animación.
    if (rectSpinner.contains(nuevaPos)) {
      if (yEntradaSpinner == null) {
        yEntradaSpinner = nuevaPos.dy;
      } else {
        final double avanceY = (nuevaPos.dy - yEntradaSpinner!).abs();
        if (avanceY > 0.025) {
          // Cada "tic" de 0.025 unidades = 1 giro pequeño = +25 pts.
          final int giros = (avanceY / 0.025).floor();
          velocidadAngularSpinner += giros * 4.2;
          _registrarPuntos(
            25 * giros,
            posicion: rectSpinner.center,
            etiqueta: '+${25 * giros}',
          );
          yEntradaSpinner = nuevaPos.dy;
        }
      }
    } else {
      yEntradaSpinner = null;
    }

    // Colisiones con bumpers.
    for (final bumper in bumpers) {
      final diferencia = nuevaPos - bumper.posicion;
      final distancia = diferencia.distance;
      final radioColision = bumper.radio + radioBola;
      if (distancia < radioColision && distancia > 0) {
        final normal = diferencia / distancia;
        // Reposicionar fuera del bumper.
        nuevaPos = bumper.posicion + normal * radioColision;
        // Reflejar velocidad.
        final dot = velocidadBola.dx * normal.dx + velocidadBola.dy * normal.dy;
        velocidadBola = velocidadBola - normal * (2 * dot);
        // Empujon adicional.
        velocidadBola = velocidadBola + normal * 0.6;
        _registrarRebote(bumper);
        // SKILL SHOT: si el primer rebote durante la ventana del skill
        // shot es contra un bumper alto (y < 0.45), conceder bonus
        // grande y consumir la ventana.
        if (skillShotDisponible && bumper.posicion.dy < 0.45) {
          skillShotDisponible = false;
          tiempoSkillShotRestante = 0;
          puntuacion += puntosSkillShot;
          textosFlotantes.add(
            _TextoFlotante(
              texto: '★ SKILL SHOT ★\n+$puntosSkillShot',
              posicion: bumper.posicion,
              vidaRestante: 1.4,
            ),
          );
          avisoCentral = _AvisoCentral(
            texto: '★ DIRECTORSKOV APLAUDE ★\nSKILL SHOT +$puntosSkillShot',
            vidaRestante: 1.6,
          );
          flashRojoFase = 1.0;
        }
      }
    }

    // Colisiones con SLINGSHOTS (triángulos activos a los lados).
    for (final slingshot in slingshots) {
      final List<List<Offset>> aristas = <List<Offset>>[
        <Offset>[slingshot.vertice1, slingshot.vertice2],
        <Offset>[slingshot.vertice2, slingshot.vertice3],
        <Offset>[slingshot.vertice3, slingshot.vertice1],
      ];
      for (final arista in aristas) {
        final Offset cercano = _puntoMasCercanoEnSegmento(
          nuevaPos,
          arista[0],
          arista[1],
        );
        final Offset diferenciaSling = nuevaPos - cercano;
        final double distanciaSling = diferenciaSling.distance;
        final double radioColisionSling = radioBola + 0.014;
        if (distanciaSling < radioColisionSling && distanciaSling > 0) {
          final Offset normalSling = diferenciaSling / distanciaSling;
          nuevaPos = cercano + normalSling * radioColisionSling;
          final double productoEscalarSling =
              velocidadBola.dx * normalSling.dx +
              velocidadBola.dy * normalSling.dy;
          if (productoEscalarSling < 0) {
            velocidadBola =
                velocidadBola - normalSling * (2 * productoEscalarSling);
            // Boost agresivo (factor 1.7) — el slingshot escupe la bola.
            velocidadBola = velocidadBola * 1.7 + normalSling * 0.45;
          }
          slingshot.flashIndividual = 1.0;
          _emitirChispas(
            slingshot.centro,
            cantidad: 6,
            colorPrincipal: PaletaRotulador.rojoEstampilla,
          );
          _registrarPuntos(
            slingshot.puntos,
            posicion: slingshot.centro,
            etiqueta: slingshot.etiqueta,
          );
          _incrementarCombo();
          intensidadSacudida = math.min(1.0, intensidadSacudida + 0.25);
          break;
        }
      }
    }

    // LANES SUPERIORES: detectar paso de la bola por cada carril.
    for (final lane in lanesSuperior) {
      if (lane.encendida) continue;
      if (lane.rect.inflate(radioBola).contains(nuevaPos)) {
        lane.encendida = true;
        lane.flashFase = 1.0;
        _registrarPuntos(150, posicion: lane.rect.center, etiqueta: lane.letra);
        if (lanesSuperior.every((l) => l.encendida)) {
          // Completar COMÉ: bonus + sube multiplicador.
          multiplicador = math.min(multiplicador + 1, 6);
          if (multiplicador > multiplicadorMejor) {
            multiplicadorMejor = multiplicador;
          }
          puntuacion += 1500;
          vecesCompletadasCome += 1;
          textosFlotantes.add(
            _TextoFlotante(
              texto: '★ COMÉ COMPLETO ★\nMULTI x$multiplicador',
              posicion: Offset(anchoMesa / 2, 0.18),
              vidaRestante: 1.6,
            ),
          );
          avisoCentral = _AvisoCentral(
            texto: '★ COMÉ ★\nMULTIPLICADOR x$multiplicador',
            vidaRestante: 1.8,
          );
          flashRojoFase = 1.0;
          // Reiniciar lanes para volver a intentarlo.
          for (final laneReset in lanesSuperior) {
            laneReset.encendida = false;
          }
          // Tras completar 2 veces seguidas, entra MODO BUROCRACIA
          // AVANZADA durante 12 s: multiplicador efectivo x2 extra
          // (subimos +2 y al expirar restamos -2). Borde rojo
          // intermitente alrededor del campo.
          if (vecesCompletadasCome >= 2 && !burocraciaAvanzadaActiva) {
            burocraciaAvanzadaActiva = true;
            tiempoBurocraciaAvanzadaRestante =
                duracionBurocraciaAvanzadaSegundos;
            multiplicador = math.min(multiplicador + 2, 8);
            if (multiplicador > multiplicadorMejor) {
              multiplicadorMejor = multiplicador;
            }
            vecesCompletadasCome = 0;
            avisoCentral = _AvisoCentral(
              texto: '★ BUROCRACIA AVANZADA ★\nMULTI x$multiplicador · 12 s',
              vidaRestante: 2.2,
            );
          }
        }
      }
    }

    // Colision con jefe-sarcofago (solo tablero Cripta).
    if (indiceTableroActual == 2 && jefe != null && jefe!.vidasRestantes > 0) {
      final diferenciaJefe = nuevaPos - jefe!.posicion;
      final distanciaJefe = diferenciaJefe.distance;
      final radioColisionJefe = jefe!.radio + radioBola;
      if (distanciaJefe < radioColisionJefe && distanciaJefe > 0) {
        final normal = diferenciaJefe / distanciaJefe;
        nuevaPos = jefe!.posicion + normal * radioColisionJefe;
        final dot = velocidadBola.dx * normal.dx + velocidadBola.dy * normal.dy;
        velocidadBola = velocidadBola - normal * (2 * dot);
        velocidadBola = velocidadBola + normal * 0.9;
        jefe!.vidasRestantes -= 1;
        jefe!.flashImpacto = 1.0;
        flashRojoFase = 1.0;
        intensidadSacudida = math.min(1.0, intensidadSacudida + 0.7);
        _registrarPuntos(
          500,
          posicion: jefe!.posicion,
          etiqueta: '+500 SARCÓFAGO',
        );
        if (jefe!.vidasRestantes <= 0) {
          // Victoria del prototipo.
          partidaTerminada = true;
          _registrarHighscoreSiToca();
          avisoCentral = _AvisoCentral(
            texto:
                '★ DIRECTORSKOV CAE ★\nFIN DEL PROTOTIPO\nPULSA ENTER PARA REINICIAR',
            vidaRestante: double.infinity,
          );
        }
      }
    }

    // Portal hacia el siguiente tablero: si la bola alcanza la parte
    // alta y tiene suficiente velocidad ascendente, sube al tablero
    // de arriba. La zona portal esta en el centro superior (x entre
    // 0.35 y 0.65, y cerca de 0).
    if (indiceTableroActual < tableros.length - 1 &&
        nuevaPos.dy < 0.05 &&
        nuevaPos.dx > 0.35 &&
        nuevaPos.dx < 0.65 &&
        velocidadBola.dy < -0.5) {
      indiceTableroActual += 1;
      progresoTransicion = 1.0;
      // Reposicionar la bola dentro del nuevo tablero ANTES de salir.
      // Aparece en el centro inferior con un empujon hacia arriba para
      // que tenga momentum al entrar.
      posicionBola = const Offset(0.50, 1.20);
      velocidadBola = const Offset(0, -1.6);
      historialPosicionesBola.clear();
      avisoCentral = _AvisoCentral(
        texto: '↑ ${tableroActual.nombre} ↑',
        vidaRestante: 1.4,
      );
      // Activar multibola fantasma al entrar a la Cripta (índice 2).
      if (indiceTableroActual == 2) {
        tiempoMultibolaRestante = duracionMultibolaSegundos;
        avisoCentral = _AvisoCentral(
          texto: '★ MULTIBOLA FANTASMA ★\nESPECTROS DE DIRECTORSKOV',
          vidaRestante: 2.0,
        );
      }
      setState(() {});
      return; // saltar el resto del frame
    }

    // Colisiones con targets rectangulares (laterales).
    for (final target in targets) {
      if (target.golpeado) continue;
      if (target.rect.inflate(radioBola).contains(nuevaPos)) {
        // Calcular eje de rebote por la cara mas cercana.
        final dxLeft = (nuevaPos.dx - target.rect.left).abs();
        final dxRight = (target.rect.right - nuevaPos.dx).abs();
        final dyTop = (nuevaPos.dy - target.rect.top).abs();
        final dyBottom = (target.rect.bottom - nuevaPos.dy).abs();
        final menor = math.min(
          math.min(dxLeft, dxRight),
          math.min(dyTop, dyBottom),
        );
        if (menor == dxLeft) {
          velocidadBola = Offset(-velocidadBola.dx.abs(), velocidadBola.dy);
          nuevaPos = Offset(target.rect.left - radioBola, nuevaPos.dy);
        } else if (menor == dxRight) {
          velocidadBola = Offset(velocidadBola.dx.abs(), velocidadBola.dy);
          nuevaPos = Offset(target.rect.right + radioBola, nuevaPos.dy);
        } else if (menor == dyTop) {
          velocidadBola = Offset(velocidadBola.dx, -velocidadBola.dy.abs());
          nuevaPos = Offset(nuevaPos.dx, target.rect.top - radioBola);
        } else {
          velocidadBola = Offset(velocidadBola.dx, velocidadBola.dy.abs());
          nuevaPos = Offset(nuevaPos.dx, target.rect.bottom + radioBola);
        }
        target.golpeado = true;
        _registrarPuntos(
          target.puntos,
          posicion: nuevaPos,
          etiqueta: '+${target.puntos}',
        );
        if (targets.every((t) => t.golpeado)) {
          _activarBonusBanderaRoja();
        }
      }
    }

    // Guias laterales inferiores: dos segmentos diagonales que canalizan
    // la bola desde las paredes hacia las paletas. La guía DERECHA debe
    // empezar en el borde *interno* del carril del lanzador
    // (anchoMesa - anchoCarrilLanzador), no en el borde externo
    // (anchoMesa). Si no, la línea cruza la salida del carril y bloquea
    // la bola cuando sube por la rampa.
    final List<List<Offset>> guiasInferiores = const <List<Offset>>[
      <Offset>[Offset(0.0, 1.05), Offset(0.30, 1.30)],
      <Offset>[
        Offset(anchoMesa - anchoCarrilLanzador, 1.05),
        Offset(0.70, 1.30),
      ],
    ];
    for (final guia in guiasInferiores) {
      final Offset cercanoEnGuia = _puntoMasCercanoEnSegmento(
        nuevaPos,
        guia[0],
        guia[1],
      );
      final Offset diferenciaGuia = nuevaPos - cercanoEnGuia;
      final double distanciaGuia = diferenciaGuia.distance;
      final double radioColisionGuia = radioBola + 0.012;
      if (distanciaGuia < radioColisionGuia && distanciaGuia > 0) {
        final Offset normalGuia = diferenciaGuia / distanciaGuia;
        nuevaPos = cercanoEnGuia + normalGuia * radioColisionGuia;
        final double productoEscalarGuia =
            velocidadBola.dx * normalGuia.dx + velocidadBola.dy * normalGuia.dy;
        if (productoEscalarGuia < 0) {
          velocidadBola =
              velocidadBola - normalGuia * (2 * productoEscalarGuia);
          // Las guias son lisas: rozamiento minimo.
          velocidadBola = velocidadBola * 0.92;
        }
      }
    }

    // Colisiones con paletas.
    _colisionPaleta(
      pivotPaleta: const Offset(0.34, 1.30),
      esIzquierda: true,
      rotacion: rotacionPaletaIzquierda,
      nuevaPos: nuevaPos,
      callback: (correccion, nuevaVel) {
        nuevaPos = correccion;
        velocidadBola = nuevaVel;
      },
    );
    _colisionPaleta(
      pivotPaleta: const Offset(0.66, 1.30),
      esIzquierda: false,
      rotacion: rotacionPaletaDerecha,
      nuevaPos: nuevaPos,
      callback: (correccion, nuevaVel) {
        nuevaPos = correccion;
        velocidadBola = nuevaVel;
      },
    );

    // Bola se sale por el fondo: pierde vida.
    if (nuevaPos.dy > altoMesa + 0.05) {
      _perderVida();
      setState(() {});
      return;
    }

    // Limitamos velocidad maxima por estabilidad.
    final speed = velocidadBola.distance;
    if (speed > 3.5) {
      velocidadBola = velocidadBola / speed * 3.5;
    }

    // Actualizar estela: insertamos la posicion anterior solo si la bola
    // realmente se mueve (evita acumular puntos cuando esta cargando).
    if ((nuevaPos - posicionBola).distance > 0.002) {
      historialPosicionesBola.insert(0, posicionBola);
      if (historialPosicionesBola.length > longitudEstela) {
        historialPosicionesBola.removeLast();
      }
    }

    posicionBola = nuevaPos;
    setState(() {});
  }

  double _aproximar(double actual, double objetivo, double paso) {
    if ((actual - objetivo).abs() <= paso) return objetivo;
    return actual + (objetivo > actual ? paso : -paso);
  }

  /// Posición sobre la curva Bézier cuadrática de la rampa de retorno
  /// en función del parámetro t ∈ [0,1]. P0 = entrada, P1 = control,
  /// P2 = salida.
  Offset _posicionEnCurvaRampaRetorno(double t) {
    final double u = 1.0 - t;
    return Offset(
      u * u * puntoEntradaRampaRetorno.dx +
          2 * u * t * puntoControlRampaRetorno.dx +
          t * t * puntoSalidaRampaRetorno.dx,
      u * u * puntoEntradaRampaRetorno.dy +
          2 * u * t * puntoControlRampaRetorno.dy +
          t * t * puntoSalidaRampaRetorno.dy,
    );
  }

  /// Derivada de la curva Bézier en el parámetro t — útil para emitir
  /// la bola al salir con velocidad tangente correcta.
  Offset _tangenteCurvaRampaRetorno(double t) {
    final double u = 1.0 - t;
    return Offset(
      2 * u * (puntoControlRampaRetorno.dx - puntoEntradaRampaRetorno.dx) +
          2 * t * (puntoSalidaRampaRetorno.dx - puntoControlRampaRetorno.dx),
      2 * u * (puntoControlRampaRetorno.dy - puntoEntradaRampaRetorno.dy) +
          2 * t * (puntoSalidaRampaRetorno.dy - puntoControlRampaRetorno.dy),
    );
  }

  /// Genera la linea principal de la paleta segun su rotacion.
  /// La paleta gira 50 grados desde reposo (apuntando hacia abajo-fuera)
  /// hasta la posicion activa (apuntando hacia arriba-dentro).
  static const double longitudPaleta = 0.16;
  static const double anchoPaleta = 0.028;

  void _colisionPaleta({
    required Offset pivotPaleta,
    required bool esIzquierda,
    required double rotacion,
    required Offset nuevaPos,
    required void Function(Offset, Offset) callback,
  }) {
    // Angulo en reposo: pala caida hacia los lados-abajo.
    final anguloReposo = esIzquierda ? -math.pi / 9 : math.pi + math.pi / 9;
    final anguloActivo = esIzquierda
        ? -math.pi / 3 * 1.4
        : math.pi + math.pi / 3 * 1.4;
    final angulo = anguloReposo + (anguloActivo - anguloReposo) * rotacion;
    final extremoPaleta = Offset(
      pivotPaleta.dx + math.cos(angulo) * longitudPaleta,
      pivotPaleta.dy + math.sin(angulo) * longitudPaleta,
    );

    // Distancia minima entre la bola y el segmento.
    final cercaMin = _puntoMasCercanoEnSegmento(
      nuevaPos,
      pivotPaleta,
      extremoPaleta,
    );
    final diferencia = nuevaPos - cercaMin;
    final distancia = diferencia.distance;
    final radioColision = radioBola + anchoPaleta / 2;
    if (distancia < radioColision && distancia > 0) {
      final normal = diferencia / distancia;
      final correccion = cercaMin + normal * radioColision;
      // Velocidad de la paleta en el punto: si esta activa, transmite
      // impulso angular hacia arriba.
      final factorImpulso =
          (esIzquierda
              ? (paletaIzquierdaActiva ? 1.0 : 0.0)
              : (paletaDerechaActiva ? 1.0 : 0.0)) *
          0.9;
      var nuevaVel = velocidadBola;
      final dot = velocidadBola.dx * normal.dx + velocidadBola.dy * normal.dy;
      nuevaVel = nuevaVel - normal * (2 * dot);
      // Boost extra si paleta activa.
      nuevaVel =
          nuevaVel +
          Offset(
            normal.dx * factorImpulso,
            normal.dy * factorImpulso - factorImpulso * 0.6,
          );
      callback(correccion, nuevaVel);
    }
  }

  Offset _puntoMasCercanoEnSegmento(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final ap = p - a;
    final lenAB2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (lenAB2 == 0) return a;
    final t = ((ap.dx * ab.dx + ap.dy * ab.dy) / lenAB2).clamp(0.0, 1.0);
    return a + ab * t;
  }

  void _registrarRebote(_BumperRetrato bumper) {
    flashRojoFase = 1.0;
    bumper.flashIndividual = 1.0;
    intensidadSacudida = math.min(1.0, intensidadSacudida + 0.45);
    _incrementarCombo();
    _emitirChispas(
      bumper.posicion,
      cantidad: 8,
      colorPrincipal: bumper.colorAcento,
    );
    _registrarPuntos(
      bumper.puntos,
      posicion: bumper.posicion,
      etiqueta:
          bumper.frasesAleatorias[math.Random().nextInt(
            bumper.frasesAleatorias.length,
          )],
    );
  }

  void _incrementarCombo() {
    setState(() {
      golpesComboActual += 1;
      tiempoComboRestanteSegundos = 2.5;
      // El multiplicador efectivo es el multiplicador base + bonus por combo.
      final int bonusCombo = (golpesComboActual / 5).floor();
      multiplicadorMejor = math.max(
        multiplicadorMejor,
        multiplicador + bonusCombo,
      );
    });
  }

  void _emitirChispas(
    Offset posicion, {
    required int cantidad,
    required Color colorPrincipal,
  }) {
    final math.Random rngChispa = math.Random();
    for (int indice = 0; indice < cantidad; indice++) {
      final double angulo = rngChispa.nextDouble() * math.pi * 2;
      final double velocidadChispa = 0.5 + rngChispa.nextDouble() * 1.2;
      chispasPinball.add(
        _ChispaPinball(
          posicion: posicion,
          velocidad: Offset(
            math.cos(angulo) * velocidadChispa,
            math.sin(angulo) * velocidadChispa,
          ),
          color: indice.isEven ? colorPrincipal : PaletaRotulador.papel,
          vidaRestante: 0.35 + rngChispa.nextDouble() * 0.30,
        ),
      );
    }
  }

  void _registrarPuntos(
    int puntosBase, {
    required Offset posicion,
    required String etiqueta,
  }) {
    setState(() {
      final int bonusComboPuntos = (golpesComboActual / 5).floor();
      final int multiplicadorEfectivo = multiplicador + bonusComboPuntos;
      puntuacion += puntosBase * multiplicadorEfectivo;
      textosFlotantes.add(
        _TextoFlotante(
          texto: multiplicadorEfectivo > 1
              ? '$etiqueta ×$multiplicadorEfectivo'
              : etiqueta,
          posicion: posicion,
          vidaRestante: 0.9,
        ),
      );
    });
  }

  void _activarBonusBanderaRoja() {
    setState(() {
      vecesLimpiadoBank += 1;
      // Bonus exponencial 1000, 2000, 4000, 8000, 16000, 32000.
      final int bonus = math.min(
        bonusBaseBank * (1 << (vecesLimpiadoBank - 1)),
        bonusMaximoBank,
      );
      puntuacion += bonus;
      // Subir multiplicador cada 2 limpiezas.
      if (vecesLimpiadoBank % 2 == 0) {
        multiplicador = math.min(multiplicador + 1, 8);
        if (multiplicador > multiplicadorMejor) {
          multiplicadorMejor = multiplicador;
        }
      }
      intensidadSacudida = 1.0;
      flashRojoFase = 1.0;
      avisoCentral = _AvisoCentral(
        texto: '★ BANK LIMPIO N°$vecesLimpiadoBank ★\n+$bonus  ×$multiplicador',
        vidaRestante: 1.8,
      );
      textosFlotantes.add(
        _TextoFlotante(
          texto: '+$bonus',
          posicion: targets.isEmpty
              ? const Offset(0.5, 0.5)
              : targets.first.rect.center,
          vidaRestante: 1.4,
        ),
      );
      _emitirChispas(
        targets.isEmpty
            ? const Offset(0.5, 0.5)
            : Offset(
                targets.first.rect.center.dx,
                (targets.first.rect.center.dy + targets.last.rect.center.dy) /
                    2,
              ),
        cantidad: 18,
        colorPrincipal: PaletaRotulador.rojoEstampilla,
      );
      // Pausa antes de levantar los targets, y luego levantamiento
      // escalonado en cascada (uno cada 0.22 s).
      tiempoBankRestante = duracionPausaBank;
      for (
        int indiceTarget = 0;
        indiceTarget < targets.length;
        indiceTarget++
      ) {
        final _TargetVertical objetivo = targets[indiceTarget];
        objetivo.tiempoHastaLevantarse =
            duracionPausaBank + indiceTarget * 0.22;
      }
    });
  }

  void _perderVida() {
    golpesComboActual = 0;
    tiempoComboRestanteSegundos = 0;
    vidas -= 1;
    if (vidas <= 0) {
      partidaTerminada = true;
      _registrarHighscoreSiToca();
      avisoCentral = _AvisoCentral(
        texto: 'EXPEDIENTE CERRADO\nPULSA ENTER PARA REABRIR',
        vidaRestante: double.infinity,
      );
      bolaEnLanzador = false;
    } else {
      avisoCentral = _AvisoCentral(
        texto: 'VIDA CONFISCADA · QUEDAN $vidas',
        vidaRestante: 1.4,
      );
      // Tras perder una bola, volvemos a la Antecamara.
      indiceTableroActual = 0;
      bolaEnLanzador = true;
      cargaLanzador = 0;
      velocidadBola = Offset.zero;
      posicionBola = const Offset(anchoMesa - 0.05, altoMesa - 0.15);
      historialPosicionesBola.clear();
      intensidadSacudida = 0.7;
    }
  }

  void _lanzarBola() {
    if (!bolaEnLanzador) return;
    // Incluso una pulsacion instantanea (carga 0) lanza con suficiente
    // velocidad para coronar la rampa y entrar al campo.
    final velocidad = -velocidadLanzadorMaxima * (0.70 + cargaLanzador * 0.30);
    // Skill shot: si el lanzamiento es con carga alta (>= 0.85), abrimos
    // una breve ventana en la que el primer golpe contra un bumper alto
    // concede +5000 puntos.
    if (cargaLanzador >= 0.85) {
      skillShotDisponible = true;
      tiempoSkillShotRestante = duracionVentanaSkillShotSegundos;
      avisoCentral = _AvisoCentral(
        texto: 'SKILL SHOT ABIERTO\nGOLPEA ARRIBA',
        vidaRestante: 1.2,
      );
    }
    velocidadBola = Offset(0, velocidad);
    bolaEnLanzador = false;
    cargaLanzador = 0;
  }

  void _registrarHighscoreSiToca() {
    final prev = _leerHighscorePinball(widget.estado);
    if (puntuacion > prev) {
      _guardarHighscorePinball(widget.estado, puntuacion);
    }
  }

  KeyEventResult _alEventoTeclado(FocusNode nodo, KeyEvent evento) {
    final esPulsacion = evento is KeyDownEvent || evento is KeyRepeatEvent;
    final esLevantamiento = evento is KeyUpEvent;
    final tecla = evento.logicalKey;

    // Tecla P: toggle pausa (sólo en KeyDown, no en KeyRepeat).
    if (evento is KeyDownEvent &&
        tecla == LogicalKeyboardKey.keyP &&
        !partidaTerminada) {
      setState(() {
        partidaPausada = !partidaPausada;
      });
      return KeyEventResult.handled;
    }
    // Mientras esté en pausa, ignoramos cualquier otro input para
    // que no entren teclas-fantasma de paletas/lanzador.
    if (partidaPausada) {
      return KeyEventResult.handled;
    }

    if (partidaTerminada && esPulsacion) {
      if (tecla == LogicalKeyboardKey.enter ||
          tecla == LogicalKeyboardKey.space ||
          tecla == LogicalKeyboardKey.numpadEnter) {
        _resetearPartida();
        return KeyEventResult.handled;
      }
    }

    if (tecla == LogicalKeyboardKey.keyA ||
        tecla == LogicalKeyboardKey.arrowLeft) {
      if (esPulsacion) {
        paletaIzquierdaActiva = true;
      } else if (esLevantamiento) {
        paletaIzquierdaActiva = false;
      }
      return KeyEventResult.handled;
    }
    if (tecla == LogicalKeyboardKey.keyD ||
        tecla == LogicalKeyboardKey.arrowRight) {
      if (esPulsacion) {
        paletaDerechaActiva = true;
      } else if (esLevantamiento) {
        paletaDerechaActiva = false;
      }
      return KeyEventResult.handled;
    }
    if (tecla == LogicalKeyboardKey.space) {
      if (bolaEnLanzador) {
        if (esPulsacion) {
          lanzadorPulsado = true;
        }
        if (esLevantamiento) {
          lanzadorPulsado = false;
          _lanzarBola();
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final mejor = _leerHighscorePinball(widget.estado);
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
            semilla: 47,
            child: Stack(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _construirCabecera(mejor),
                        const SizedBox(height: 10),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: _construirMesa()),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 220,
                                child: _construirPanelLateral(),
                              ),
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
          'PINBALL · COMITÉ CENTRAL',
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
            _chip('VIDAS', '$vidas'),
            const SizedBox(width: 8),
            _chip('×$multiplicador', 'MULTI', acentuado: true),
            const SizedBox(width: 8),
            _chip('PUNTOS', '$puntuacion'),
            const SizedBox(width: 8),
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

  Widget _construirMesa() {
    return Center(
      child: AspectRatio(
        aspectRatio: anchoMesa / altoMesa,
        child: MarcoRotulador(
          color: PaletaRotulador.tinta,
          grosor: 3.6,
          intensidadJitter: 1.5,
          margenInterior: 2.0,
          child: Container(
            decoration: const BoxDecoration(color: PaletaRotulador.papel),
            child: LayoutBuilder(
              builder: (contexto, restricciones) {
                final double desplazamientoSacudida = intensidadSacudida * 6.0;
                final Offset offsetSacudida = Offset(
                  (_rngVisual.nextDouble() - 0.5) * desplazamientoSacudida,
                  (_rngVisual.nextDouble() - 0.5) * desplazamientoSacudida,
                );
                final Widget mesaPinball = CustomPaint(
                  painter: _PintorMesaPinball(
                    bumpers: bumpers,
                    targets: targets,
                    posicionBola: bolaEnLanzador
                        ? Offset(
                            anchoMesa - 0.05,
                            altoMesa - 0.15 + cargaLanzador * 0.04,
                          )
                        : posicionBola,
                    bolaEnLanzador: bolaEnLanzador,
                    cargaLanzador: cargaLanzador,
                    rotacionPaletaIzquierda: rotacionPaletaIzquierda,
                    rotacionPaletaDerecha: rotacionPaletaDerecha,
                    textosFlotantes: textosFlotantes,
                    avisoCentral: avisoCentral,
                    flashRojoFase: flashRojoFase,
                    historialPosicionesBola: List<Offset>.from(
                      historialPosicionesBola,
                    ),
                    todosTargetsActivos:
                        targets.isNotEmpty && targets.every((t) => t.golpeado),
                    multiplicador: multiplicador,
                    offsetSacudida: offsetSacudida,
                    tableroActual: tableroActual,
                    indiceTablero: indiceTableroActual,
                    totalTableros: tableros.length,
                    jefe: indiceTableroActual == 2 ? jefe : null,
                    chispasPinball: chispasPinball,
                    golpesComboActual: golpesComboActual,
                    tiempoComboRestanteSegundos: tiempoComboRestanteSegundos,
                    tiempoMultibolaRestante: tiempoMultibolaRestante,
                    faseMultibola: faseMultibola,
                    slingshots: slingshots,
                    lanesSuperior: lanesSuperior,
                    skillShotDisponible: skillShotDisponible,
                    tiempoSkillShotRestante: tiempoSkillShotRestante,
                    bolaEnSaucer: bolaEnSaucer,
                    tiempoEnSaucerRestante: tiempoEnSaucerRestante,
                    anguloSpinner: anguloSpinner,
                    burocraciaAvanzadaActiva: burocraciaAvanzadaActiva,
                    tiempoBurocraciaAvanzadaRestante:
                        tiempoBurocraciaAvanzadaRestante,
                    bolaEnRampaRetorno: bolaEnRampaRetorno,
                    progresoRampaRetorno: progresoRampaRetorno,
                    tunelFreneticoActivo: tunelFreneticoActivo,
                    tiempoTunelFreneticoRestante: tiempoTunelFreneticoRestante,
                    vecesLimpiadoBank: vecesLimpiadoBank,
                    imagenSarcofago: imagenSarcofago,
                    imagenFondoTablero: _imagenFondoTableroActivo,
                    imagenBumper: imagenBumper,
                    imagenSlingshotIzq: imagenSlingshotIzq,
                    imagenSlingshotDer: imagenSlingshotDer,
                    imagenFlipperIzq: imagenFlipperIzq,
                    imagenFlipperDer: imagenFlipperDer,
                    imagenTargetActivo: imagenTargetActivo,
                    imagenTargetCaido: imagenTargetCaido,
                    imagenLaneApagado: imagenLaneApagado,
                    imagenLaneEncendido: imagenLaneEncendido,
                    imagenSpinner: imagenSpinner,
                    imagenLanzadorResorte: imagenLanzadorResorte,
                    imagenSaucer: imagenSaucer,
                  ),
                );
                // Cadete-bola PNG encima del painter: posicionada según
                // escala de la mesa, rotando con el desplazamiento.
                final double escalaXMesa = restricciones.maxWidth / anchoMesa;
                final double escalaYMesa = restricciones.maxHeight / altoMesa;
                final double radioBolaPxMesa = radioBola * escalaXMesa;
                // El PNG `cadete_bola_f0X.png` es 1254×1254 cuadrado
                // con la silueta del cadete-bola sin llenar el lienzo
                // entero (queda padding transparente alrededor). Con
                // `BoxFit.contain` la bola visible queda más pequeña
                // que el rect lógico. Compensamos con un factor de
                // escala visual de 1.6 sobre el rect renderizado —
                // colisión sigue siendo `radioBola` puro.
                const double factorEscalaVisualBola = 1.4;
                final double anchoBolaRender =
                    radioBolaPxMesa * 2 * factorEscalaVisualBola;
                final Offset posicionBolaPx = Offset(
                  (bolaEnLanzador ? (anchoMesa - 0.05) : posicionBola.dx) *
                          escalaXMesa -
                      anchoBolaRender / 2,
                  (bolaEnLanzador
                              ? (altoMesa - 0.15 + cargaLanzador * 0.04)
                              : posicionBola.dy) *
                          escalaYMesa -
                      anchoBolaRender / 2,
                );
                final double rotacionBolaPng = posicionBola.dx * 16.0;
                // Selección del frame del cadete-bola (4 frames) en
                // función de la distancia rodada: 1 unidad de rodadura
                // ≈ 25 frames, así la animación es perceptible cuando
                // la bola rueda rápido y se queda quieta cuando está
                // parada en el lanzador.
                final int indiceFrameBola =
                    (acumuladorRodaduraBola * 25).floor() % 4;
                final String rutaFrameBola =
                    'assets/images/cadete_bola_f0${indiceFrameBola + 1}.png';
                final Widget cadeteBolaPng = Positioned(
                  left: posicionBolaPx.dx,
                  top: posicionBolaPx.dy,
                  width: anchoBolaRender,
                  height: anchoBolaRender,
                  child: IgnorePointer(
                    child: Transform.rotate(
                      angle: rotacionBolaPng,
                      child: Image.asset(
                        rutaFrameBola,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                );
                if (indiceTableroActual != 2 || jefe == null) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [mesaPinball, cadeteBolaPng],
                  );
                }
                final double vidaProporcion = jefe!.vidasIniciales == 0
                    ? 0.0
                    : jefe!.vidasRestantes / jefe!.vidasIniciales;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    mesaPinball,
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      height: restricciones.maxHeight * 0.28,
                      child: IgnorePointer(
                        child: Opacity(
                          opacity: 0.35 + 0.55 * vidaProporcion,
                          child: const CicloDeFrames(
                            rutasFrames: [
                              'assets/images/directorskov_f01.png',
                              'assets/images/directorskov_f02.png',
                              'assets/images/directorskov_f03.png',
                            ],
                            duracionPorFrame: Duration(milliseconds: 280),
                            ajuste: BoxFit.contain,
                            alineamiento: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    cadeteBolaPng,
                  ],
                );
              },
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
        border: Border.all(color: PaletaRotulador.tinta, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COMITÉ AL COMPLETO',
            style: TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: PaletaRotulador.rojoEstampilla,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          for (final bumper in bumpers)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: bumper.colorAcento,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: PaletaRotulador.papel,
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    bumper.etiqueta,
                    style: const TextStyle(
                      fontFamily: 'CosmoMono',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PaletaRotulador.papel,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${bumper.puntos} pt',
                    style: const TextStyle(
                      fontFamily: 'CosmoMono',
                      fontSize: 10,
                      color: PaletaRotulador.tinta,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(color: PaletaRotulador.papel, height: 16),
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
          const Text(
            'A / ◀  : paleta izquierda\n'
            'D / ▶  : paleta derecha\n'
            'ESPACIO: cargar y soltar lanzador',
            style: TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 11,
              color: PaletaRotulador.tinta,
              height: 1.5,
            ),
          ),
          const Spacer(),
          const Text(
            '«Que la bola del cosmonauta despierte a cada miembro del Comité.»',
            style: TextStyle(
              fontFamily: 'CosmoSerif',
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: PaletaRotulador.papel,
            ),
          ),
        ],
      ),
    );
  }
}

/// Configuracion de un tablero de pinball (parte del sistema multi-tablero
/// estilo Kirby's Pinball Land / Revenge of the 'Gator).
class _ConfiguracionTablero {
  final String nombre;
  final Color colorAcento;
  final Color colorFondoSuperior;
  final Color colorFondoInferior;
  final List<_BumperRetrato> bumpers;
  final List<_TargetVertical> targets;

  _ConfiguracionTablero({
    required this.nombre,
    required this.colorAcento,
    required this.colorFondoSuperior,
    required this.colorFondoInferior,
    required this.bumpers,
    required this.targets,
  });
}

/// Jefe-sarcofago de la cripta. Bumper grande con varios HP. Cada
/// impacto resta vida; al llegar a 0, victoria del prototipo.
class _JefeSarcofago {
  final Offset posicion;
  final double radio;
  final int vidasIniciales;
  int vidasRestantes;
  double flashImpacto;

  _JefeSarcofago({
    required this.posicion,
    required this.radio,
    required this.vidasIniciales,
  }) : vidasRestantes = vidasIniciales,
       flashImpacto = 0;
}

class _BumperRetrato {
  final Offset posicion;
  final double radio;
  final int puntos;
  final String etiqueta;
  final Color colorAcento;
  final List<String> frasesAleatorias;

  /// Tiempo que queda de flash propio (segundos).
  double flashIndividual;

  _BumperRetrato({
    required this.posicion,
    required this.radio,
    required this.puntos,
    required this.etiqueta,
    required this.colorAcento,
    this.frasesAleatorias = const <String>[
      '¡GLORIA!',
      'AL EXPEDIENTE',
      'BUEN CAMARADA',
      'TOMA NOTA',
      'F-447',
    ],
  }) : flashIndividual = 0.0;
}

class _TargetVertical {
  final Rect rect;
  final int puntos;
  final String etiqueta;
  bool golpeado;

  /// Mientras `tiempoHastaLevantarse > 0`, el target está caído y se
  /// le hace cuenta atrás en cada tick. Al llegar a 0 se levanta
  /// (golpeado = false). Se usa para el levantamiento escalonado del
  /// drop bank tras limpiar la fila.
  double tiempoHastaLevantarse;

  /// Pequeño impulso visual al recibir o al levantarse de nuevo.
  double flashLevantamiento;

  _TargetVertical({
    required this.rect,
    required this.puntos,
    required this.etiqueta,
  }) : golpeado = false,
       tiempoHastaLevantarse = 0,
       flashLevantamiento = 0;
}

/// Slingshot: triángulo activo a los lados de las paletas que rebota
/// la bola con un boost de impulso, como en cualquier mesa clásica.
/// Se modela como tres segmentos de pared (las tres aristas del
/// triángulo) y el "flash" se dispara al colisionar.
class _Slingshot {
  final Offset vertice1;
  final Offset vertice2;
  final Offset vertice3;
  final int puntos;
  final String etiqueta;

  /// Tiempo restante de flash visual tras el último rebote.
  double flashIndividual;

  _Slingshot({
    required this.vertice1,
    required this.vertice2,
    required this.vertice3,
    this.puntos = 80,
    this.etiqueta = '+80',
  }) : flashIndividual = 0.0;

  /// Centroide del triángulo, usado para emitir chispas en su rebote.
  Offset get centro => Offset(
    (vertice1.dx + vertice2.dx + vertice3.dx) / 3.0,
    (vertice1.dy + vertice2.dy + vertice3.dy) / 3.0,
  );
}

/// Lane superior: carril rectangular en la parte alta del campo que
/// se enciende al ser cruzado por la bola. Cuando los cuatro lanes
/// están encendidos, se otorga bonus y se reinician.
class _LaneSuperior {
  final Rect rect;
  final String letra;
  bool encendida;

  /// Flash al encenderse.
  double flashFase;

  _LaneSuperior({required this.rect, required this.letra})
    : encendida = false,
      flashFase = 0.0;
}

class _TextoFlotante {
  final String texto;
  Offset posicion;
  double vidaRestante;

  _TextoFlotante({
    required this.texto,
    required this.posicion,
    required this.vidaRestante,
  });
}

class _ChispaPinball {
  Offset posicion;
  Offset velocidad;
  final Color color;
  double vidaRestante;

  _ChispaPinball({
    required this.posicion,
    required this.velocidad,
    required this.color,
    required this.vidaRestante,
  });
}

class _AvisoCentral {
  final String texto;
  double vidaRestante;

  _AvisoCentral({required this.texto, required this.vidaRestante});
}

class _PintorMesaPinball extends CustomPainter {
  final List<_BumperRetrato> bumpers;
  final List<_TargetVertical> targets;
  final Offset posicionBola;
  final bool bolaEnLanzador;
  final double cargaLanzador;
  final double rotacionPaletaIzquierda;
  final double rotacionPaletaDerecha;
  final List<_TextoFlotante> textosFlotantes;
  final _AvisoCentral? avisoCentral;
  final double flashRojoFase;
  final List<Offset> historialPosicionesBola;
  final bool todosTargetsActivos;
  final int multiplicador;
  final Offset offsetSacudida;
  final _ConfiguracionTablero tableroActual;
  final int indiceTablero;
  final int totalTableros;
  final _JefeSarcofago? jefe;
  final List<_ChispaPinball> chispasPinball;
  final int golpesComboActual;
  final double tiempoComboRestanteSegundos;
  final double tiempoMultibolaRestante;
  final double faseMultibola;
  final List<_Slingshot> slingshots;
  final List<_LaneSuperior> lanesSuperior;
  final bool skillShotDisponible;
  final double tiempoSkillShotRestante;
  final bool bolaEnSaucer;
  final double tiempoEnSaucerRestante;
  final double anguloSpinner;
  final bool burocraciaAvanzadaActiva;
  final double tiempoBurocraciaAvanzadaRestante;
  final bool bolaEnRampaRetorno;
  final double progresoRampaRetorno;
  final bool tunelFreneticoActivo;
  final double tiempoTunelFreneticoRestante;
  final int vecesLimpiadoBank;

  /// PNG del sarcófago. Puede ser null durante los primeros frames
  /// mientras se carga; en ese caso se cae al dibujado procedimental.
  final ui.Image? imagenSarcofago;

  /// PNGs opcionales del §11 del briefing. Si están disponibles
  /// reemplazan el dibujo procedimental del elemento correspondiente;
  /// si falta alguno, ese elemento conserva su fallback previo.
  final ui.Image? imagenFondoTablero;
  final ui.Image? imagenBumper;
  final ui.Image? imagenSlingshotIzq;
  final ui.Image? imagenSlingshotDer;
  final ui.Image? imagenFlipperIzq;
  final ui.Image? imagenFlipperDer;
  final ui.Image? imagenTargetActivo;
  final ui.Image? imagenTargetCaido;
  final ui.Image? imagenLaneApagado;
  final ui.Image? imagenLaneEncendido;
  final ui.Image? imagenSpinner;
  final ui.Image? imagenLanzadorResorte;
  final ui.Image? imagenSaucer;

  _PintorMesaPinball({
    required this.bumpers,
    required this.targets,
    required this.posicionBola,
    required this.bolaEnLanzador,
    required this.cargaLanzador,
    required this.rotacionPaletaIzquierda,
    required this.rotacionPaletaDerecha,
    required this.textosFlotantes,
    required this.avisoCentral,
    required this.flashRojoFase,
    required this.historialPosicionesBola,
    required this.todosTargetsActivos,
    required this.multiplicador,
    required this.offsetSacudida,
    required this.tableroActual,
    required this.indiceTablero,
    required this.totalTableros,
    required this.jefe,
    required this.chispasPinball,
    required this.golpesComboActual,
    required this.tiempoComboRestanteSegundos,
    required this.tiempoMultibolaRestante,
    required this.faseMultibola,
    required this.slingshots,
    required this.lanesSuperior,
    required this.skillShotDisponible,
    required this.tiempoSkillShotRestante,
    required this.bolaEnSaucer,
    required this.tiempoEnSaucerRestante,
    required this.anguloSpinner,
    required this.burocraciaAvanzadaActiva,
    required this.tiempoBurocraciaAvanzadaRestante,
    required this.bolaEnRampaRetorno,
    required this.progresoRampaRetorno,
    required this.tunelFreneticoActivo,
    required this.tiempoTunelFreneticoRestante,
    required this.vecesLimpiadoBank,
    this.imagenSarcofago,
    this.imagenFondoTablero,
    this.imagenBumper,
    this.imagenSlingshotIzq,
    this.imagenSlingshotDer,
    this.imagenFlipperIzq,
    this.imagenFlipperDer,
    this.imagenTargetActivo,
    this.imagenTargetCaido,
    this.imagenLaneApagado,
    this.imagenLaneEncendido,
    this.imagenSpinner,
    this.imagenLanzadorResorte,
    this.imagenSaucer,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final escalaX = size.width / _PantallaPinballComiteState.anchoMesa;
    final escalaY = size.height / _PantallaPinballComiteState.altoMesa;

    Offset r(Offset rel) => Offset(rel.dx * escalaX, rel.dy * escalaY);
    double rX(double v) => v * escalaX;

    final pincelTrazo = Paint()
      ..color = PaletaRotulador.tinta
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Fondo del tablero. Si hay un PNG de §11 disponible
    // (`pinball_tablero_<tablero>.png`) lo pintamos a tamaño completo
    // y saltamos el degradado procedural. Si no, fallback al gradiente
    // radial habitual.
    if (imagenFondoTablero != null) {
      final ui.Image sprite = imagenFondoTablero!;
      paintImage(
        canvas: canvas,
        rect: Offset.zero & size,
        image: sprite,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      );
    } else {
      final gradiente = Paint()
        ..shader = RadialGradient(
          colors: [
            tableroActual.colorFondoSuperior,
            tableroActual.colorFondoInferior,
          ],
        ).createShader(Offset.zero & size);
      canvas.drawRect(Offset.zero & size, gradiente);
    }

    // Aplicar sacudida al resto del playfield.
    canvas.save();
    canvas.translate(offsetSacudida.dx, offsetSacudida.dy);

    // Decoracion tematica de fondo segun el tablero. Cuando existe un
    // fondo ilustrado de §11, ya trae esa ornamentación impresa y no
    // conviene duplicarla por encima.
    if (imagenFondoTablero == null) {
      switch (indiceTablero) {
        case 0:
          // Antecamara F-447: banderines colgando arriba.
          for (int indiceBanderin = 0; indiceBanderin < 6; indiceBanderin++) {
            final double xBanderin =
                size.width * (0.10 + indiceBanderin * 0.13);
            canvas.drawLine(
              Offset(xBanderin, size.height * 0.02),
              Offset(xBanderin, size.height * 0.07),
              Paint()..color = PaletaRotulador.papel.withValues(alpha: 0.55),
            );
            final Path banderinPath = Path()
              ..moveTo(xBanderin, size.height * 0.07)
              ..lineTo(xBanderin - rX(0.025), size.height * 0.09)
              ..lineTo(xBanderin, size.height * 0.11)
              ..close();
            canvas.drawPath(
              banderinPath,
              Paint()
                ..color =
                    (indiceBanderin.isEven
                            ? PaletaRotulador.rojoEstampilla
                            : PaletaRotulador.papel)
                        .withValues(alpha: 0.45),
            );
          }
          // Sello F-447 grande tenue de fondo.
          canvas.drawCircle(
            r(const Offset(0.5, 0.22)),
            rX(0.10),
            Paint()
              ..color = PaletaRotulador.rojoEstampilla.withValues(alpha: 0.10)
              ..style = PaintingStyle.stroke
              ..strokeWidth = rX(0.015),
          );
          break;
        case 1:
          // Salon del Comite: cortinas rojas + lampara central.
          for (final ladoCortina in <double>[-1, 1]) {
            final double xCortina =
                size.width / 2 + ladoCortina * size.width * 0.45;
            final Rect rectCortina = Rect.fromLTWH(
              xCortina - size.width * 0.04,
              0,
              size.width * 0.08,
              size.height * 0.30,
            );
            canvas.drawRect(
              rectCortina,
              Paint()
                ..color = PaletaRotulador.rojoEstampilla.withValues(
                  alpha: 0.65,
                ),
            );
            // Pliegues verticales de la cortina.
            for (int indicePliegue = 0; indicePliegue < 3; indicePliegue++) {
              final double xPliegue =
                  rectCortina.left +
                  rectCortina.width * (indicePliegue + 0.5) / 3;
              canvas.drawLine(
                Offset(xPliegue, rectCortina.top),
                Offset(xPliegue, rectCortina.bottom),
                Paint()
                  ..color = PaletaRotulador.tinta.withValues(alpha: 0.35)
                  ..strokeWidth = 1.2,
              );
            }
          }
          // Lampara central colgante.
          canvas.drawLine(
            Offset(size.width / 2, 0),
            Offset(size.width / 2, size.height * 0.18),
            Paint()
              ..color = PaletaRotulador.papel.withValues(alpha: 0.55)
              ..strokeWidth = 1.5,
          );
          canvas.drawCircle(
            Offset(size.width / 2, size.height * 0.20),
            rX(0.05),
            Paint()
              ..color = PaletaRotulador.rojoEstampilla.withValues(alpha: 0.65),
          );
          canvas.drawCircle(
            Offset(size.width / 2, size.height * 0.20),
            rX(0.05),
            Paint()
              ..color = PaletaRotulador.tinta
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4,
          );
          break;
        case 2:
          // Cripta de Directorskov: arcos goticos + cirios.
          for (int indiceArco = 0; indiceArco < 3; indiceArco++) {
            final double xArco = size.width * (0.20 + indiceArco * 0.30);
            final Rect rectArco = Rect.fromCenter(
              center: Offset(xArco, size.height * 0.16),
              width: rX(0.16),
              height: size.height * 0.30,
            );
            canvas.drawArc(
              rectArco,
              math.pi,
              math.pi,
              false,
              Paint()
                ..color = PaletaRotulador.tinta.withValues(alpha: 0.75)
                ..style = PaintingStyle.fill,
            );
            canvas.drawArc(
              rectArco,
              math.pi,
              math.pi,
              false,
              Paint()
                ..color = PaletaRotulador.rojoEstampilla.withValues(alpha: 0.55)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.6,
            );
          }
          // Velas a los lados.
          for (final xVela in <double>[0.08, 0.92]) {
            final Offset baseVela = Offset(
              size.width * xVela,
              size.height * 0.40,
            );
            canvas.drawRect(
              Rect.fromCenter(
                center: baseVela,
                width: rX(0.02),
                height: size.height * 0.06,
              ),
              Paint()..color = PaletaRotulador.papelSucio,
            );
            // Llama parpadeante.
            final double tFlash =
                0.85 + 0.15 * math.sin(flashRojoFase * math.pi * 6);
            canvas.drawCircle(
              baseVela.translate(0, -size.height * 0.035),
              rX(0.012) * tFlash,
              Paint()
                ..color = PaletaRotulador.rojoEstampilla.withValues(
                  alpha: 0.85,
                ),
            );
          }
          break;
      }
    }

    // Estrella roja central tenue (comun a todos los tableros).
    _dibujarEstrellaCinco(
      canvas,
      r(const Offset(0.5, 0.12)),
      rX(0.035),
      Paint()..color = PaletaRotulador.rojoEstampilla.withValues(alpha: 0.18),
    );

    // Carril del lanzador (lado derecho) que arranca debajo de la rampa curva.
    final double radioRampaPx = rX(
      _PantallaPinballComiteState.anchoCarrilLanzador,
    );
    final rectCarril = Rect.fromLTRB(
      r(
        const Offset(
          _PantallaPinballComiteState.anchoMesa -
              _PantallaPinballComiteState.anchoCarrilLanzador,
          0,
        ),
      ).dx,
      radioRampaPx,
      r(const Offset(_PantallaPinballComiteState.anchoMesa, 0)).dx,
      r(const Offset(0, _PantallaPinballComiteState.altoMesa)).dy,
    );
    canvas.drawRect(
      rectCarril,
      Paint()..color = PaletaRotulador.tintaDiluida(0.85),
    );
    // Pared interior del carril (vertical).
    canvas.drawLine(
      Offset(rectCarril.left, rectCarril.top),
      Offset(rectCarril.left, rectCarril.bottom * 0.95),
      pincelTrazo
        ..strokeWidth = 1.6
        ..color = PaletaRotulador.papel.withValues(alpha: 0.55),
    );

    // Rampa curva: cuarto de circulo en la esquina superior derecha
    // que conecta el carril del lanzador con el techo del campo de juego.
    final Offset centroRampaPx = Offset(rectCarril.left, rectCarril.top);
    final caminoRampa = Path()
      // Empieza en la salida hacia el campo (debajo del centro de curvatura).
      ..moveTo(centroRampaPx.dx, 0)
      // Sube hasta el techo (donde la curva se cierra).
      ..lineTo(centroRampaPx.dx, centroRampaPx.dy - radioRampaPx)
      // Cuarto de circulo hasta el borde derecho del tablero.
      ..arcToPoint(
        Offset(centroRampaPx.dx + radioRampaPx, centroRampaPx.dy),
        radius: Radius.circular(radioRampaPx),
        clockwise: true,
      )
      // Baja por el borde derecho hasta unirse con el carril.
      ..lineTo(centroRampaPx.dx + radioRampaPx, centroRampaPx.dy)
      ..close();
    canvas.drawPath(
      caminoRampa,
      Paint()..color = PaletaRotulador.tintaDiluida(0.85),
    );
    // Trazo del borde interior (concavo) de la rampa.
    final caminoBordeRampa = Path()
      ..addArc(
        Rect.fromCircle(center: centroRampaPx, radius: radioRampaPx),
        -math.pi / 2,
        math.pi / 2,
      );
    canvas.drawPath(
      caminoBordeRampa,
      Paint()
        ..color = PaletaRotulador.papel.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Borde redondeado del playfield arriba (solo hasta el inicio de la rampa).
    final caminoTope = Path()
      ..moveTo(0, rectCarril.bottom * 0.35)
      ..quadraticBezierTo(
        size.width * 0.4,
        -rectCarril.bottom * 0.08,
        centroRampaPx.dx,
        centroRampaPx.dy * 0.6,
      );
    canvas.drawPath(
      caminoTope,
      Paint()
        ..color = PaletaRotulador.rojoEstampilla.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // LANES SUPERIORES: cuatro pasillos rectangulares con letras COMÉ
    // arriba del campo. Encendidos: relleno rojo + letra papel; apagados:
    // relleno papel + letra tinta diluida. La idea visual es la fila
    // clásica de "rollover lanes" del pinball arcade.
    for (final lane in lanesSuperior) {
      final Rect rectLanePx = Rect.fromLTRB(
        lane.rect.left * escalaX,
        lane.rect.top * escalaY,
        lane.rect.right * escalaX,
        lane.rect.bottom * escalaY,
      );
      final bool encendidaConFlash = lane.encendida;
      final ui.Image? spriteLane = encendidaConFlash
          ? imagenLaneEncendido
          : imagenLaneApagado;
      if (spriteLane != null) {
        _dibujarSpriteEnRect(canvas, spriteLane, rectLanePx);
      } else {
        canvas.drawRect(
          rectLanePx,
          Paint()
            ..color = encendidaConFlash
                ? PaletaRotulador.rojoEstampilla
                : PaletaRotulador.papel,
        );
        rectanguloRotulador(
          canvas,
          rectLanePx,
          pincel: Paint()
            ..color = PaletaRotulador.tinta
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
          intensidadJitter: 0.7,
          semilla: lane.rect.left * 17 + lane.rect.top * 31,
        );
      }
      // Letra centrada.
      final TextPainter pintorLetraLane = TextPainter(
        text: TextSpan(
          text: lane.letra,
          style: TextStyle(
            fontFamily: 'CosmoSerif',
            fontSize: rectLanePx.height * 0.65,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w900,
            color: encendidaConFlash
                ? PaletaRotulador.papel
                : PaletaRotulador.tintaDiluida(0.6),
            height: 1.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      pintorLetraLane.paint(
        canvas,
        Offset(
          rectLanePx.center.dx - pintorLetraLane.width / 2,
          rectLanePx.center.dy - pintorLetraLane.height / 2,
        ),
      );
      // Brillo de flash al encenderse: aro pulsante.
      if (lane.flashFase > 0) {
        canvas.drawRect(
          rectLanePx.inflate(rectLanePx.height * 0.18 * lane.flashFase),
          Paint()
            ..color = PaletaRotulador.rojoEstampilla.withValues(
              alpha: lane.flashFase * 0.45,
            )
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2,
        );
      }
    }

    // SLINGSHOTS: dos triángulos activos sobre las paletas. Relleno
    // papel sucio (parecen pestañas de papel pegado a la mesa), borde
    // tembloroso a tinta y aro rojo al rebotar.
    for (final slingshot in slingshots) {
      final Path caminoSling = Path()
        ..moveTo(
          slingshot.vertice1.dx * escalaX,
          slingshot.vertice1.dy * escalaY,
        )
        ..lineTo(
          slingshot.vertice2.dx * escalaX,
          slingshot.vertice2.dy * escalaY,
        )
        ..lineTo(
          slingshot.vertice3.dx * escalaX,
          slingshot.vertice3.dy * escalaY,
        )
        ..close();
      final Rect rectBoundSling = caminoSling.getBounds();
      final double flashSling = slingshot.flashIndividual.clamp(0.0, 1.0);
      final bool esSlingIzquierdo = slingshot.centro.dx < 0.5;
      final ui.Image? spriteSling = esSlingIzquierdo
          ? imagenSlingshotIzq
          : imagenSlingshotDer;
      if (spriteSling != null) {
        final Rect rectDestino = rectBoundSling.inflate(4);
        _dibujarSpriteEnRect(canvas, spriteSling, rectDestino);
        if (flashSling > 0) {
          canvas.drawPath(
            caminoSling,
            Paint()
              ..color = PaletaRotulador.rojoEstampilla.withValues(
                alpha: flashSling * 0.40,
              ),
          );
        }
        continue;
      }
      // Relleno principal: papel sucio si reposo, rojo si flash.
      canvas.drawPath(
        caminoSling,
        Paint()
          ..color =
              Color.lerp(
                PaletaRotulador.papelSucio,
                PaletaRotulador.rojoEstampilla,
                flashSling * 0.85,
              ) ??
              PaletaRotulador.papelSucio,
      );
      // Rayado paralelo interno para textura.
      canvas.save();
      canvas.clipPath(caminoSling);
      rayadoParalelo(
        canvas,
        rectBoundSling,
        pincel: Paint()
          ..color = PaletaRotulador.tintaDiluida(0.35)
          ..strokeWidth = 0.8,
        espaciado: 6.0,
        intensidadJitter: 0.4,
      );
      canvas.restore();
      // Trazo tembloroso por las tres aristas.
      final List<List<Offset>> aristasPx = <List<Offset>>[
        <Offset>[
          Offset(
            slingshot.vertice1.dx * escalaX,
            slingshot.vertice1.dy * escalaY,
          ),
          Offset(
            slingshot.vertice2.dx * escalaX,
            slingshot.vertice2.dy * escalaY,
          ),
        ],
        <Offset>[
          Offset(
            slingshot.vertice2.dx * escalaX,
            slingshot.vertice2.dy * escalaY,
          ),
          Offset(
            slingshot.vertice3.dx * escalaX,
            slingshot.vertice3.dy * escalaY,
          ),
        ],
        <Offset>[
          Offset(
            slingshot.vertice3.dx * escalaX,
            slingshot.vertice3.dy * escalaY,
          ),
          Offset(
            slingshot.vertice1.dx * escalaX,
            slingshot.vertice1.dy * escalaY,
          ),
        ],
      ];
      for (final aristaPx in aristasPx) {
        trazoTembloroso(
          canvas,
          aristaPx[0],
          aristaPx[1],
          pincel: Paint()
            ..color = PaletaRotulador.tinta
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4 + flashSling * 1.6
            ..strokeCap = StrokeCap.round,
          intensidadJitter: 1.0,
          semilla: aristaPx[0].dx + aristaPx[0].dy * 7,
        );
      }
      // Estrella roja en el centro del slingshot.
      estrellaRotulador(
        canvas,
        Offset(
          (slingshot.vertice1.dx +
                  slingshot.vertice2.dx +
                  slingshot.vertice3.dx) /
              3.0 *
              escalaX,
          (slingshot.vertice1.dy +
                  slingshot.vertice2.dy +
                  slingshot.vertice3.dy) /
              3.0 *
              escalaY,
        ),
        6.0 + flashSling * 4.0,
        pincel: Paint()
          ..color = flashSling > 0.1
              ? PaletaRotulador.rojoEstampilla
              : PaletaRotulador.rojoEstampilla.withValues(alpha: 0.55),
      );
    }

    // Targets laterales (DROP BANK).
    // - Si están golpeados, los dibujamos "rebajados" (caídos hacia
    //   abajo dentro de su slot), con sombra interior.
    // - Mientras están bajados con cuenta atrás, se acerca su
    //   levantamiento — animamos un pequeño "rebote" al final.
    // - flashLevantamiento ilumina el target tras restablecerse.
    for (final target in targets) {
      final Rect rectPx = Rect.fromLTRB(
        target.rect.left * escalaX,
        target.rect.top * escalaY,
        target.rect.right * escalaX,
        target.rect.bottom * escalaY,
      );
      final ui.Image? spriteTarget = target.golpeado
          ? imagenTargetCaido
          : imagenTargetActivo;
      if (spriteTarget != null) {
        _dibujarSpriteEnRect(canvas, spriteTarget, rectPx);
        continue;
      }
      // Slot fijo del target (caja donde encaja). Siempre dibujado en
      // gris papel sucio para que se note que está la base.
      canvas.drawRect(rectPx, Paint()..color = PaletaRotulador.papelSucio);
      canvas.drawRect(
        rectPx,
        Paint()
          ..color = PaletaRotulador.tintaDiluida(0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
      // Cuerpo del target: cuando está golpeado, baja hasta ocultarse
      // en el slot. Calculamos la fracción de "asomar".
      double fraccionAsomar;
      if (target.golpeado) {
        fraccionAsomar = 0.18;
      } else if (target.flashLevantamiento > 0) {
        // Rebote elástico al subir: pasa de 0 a 1.0 en una curva.
        final double frac = 1.0 - target.flashLevantamiento;
        fraccionAsomar = 1.0 + math.sin(frac * math.pi) * 0.08;
      } else {
        fraccionAsomar = 1.0;
      }
      final double altoCuerpo = rectPx.height * fraccionAsomar;
      final Rect rectCuerpo = Rect.fromLTWH(
        rectPx.left,
        rectPx.bottom - altoCuerpo,
        rectPx.width,
        altoCuerpo,
      );
      // Color base del cuerpo: papel cuando arriba, oscuro cuando
      // golpeado, rojo brillante mientras flashea por levantarse.
      Color colorCuerpo;
      if (target.flashLevantamiento > 0.05) {
        colorCuerpo =
            Color.lerp(
              PaletaRotulador.papel,
              PaletaRotulador.rojoEstampilla,
              target.flashLevantamiento * 0.7,
            ) ??
            PaletaRotulador.papel;
      } else if (target.golpeado) {
        colorCuerpo = PaletaRotulador.tintaDiluida(0.55);
      } else {
        colorCuerpo = PaletaRotulador.papel;
      }
      canvas.drawRect(rectCuerpo, Paint()..color = colorCuerpo);
      canvas.drawRect(
        rectCuerpo,
        Paint()
          ..color = PaletaRotulador.tinta
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
      // Línea horizontal en el tope del cuerpo (rotulador) para
      // simular el "borde superior" del drop target.
      canvas.drawLine(
        Offset(rectCuerpo.left, rectCuerpo.top),
        Offset(rectCuerpo.right, rectCuerpo.top),
        Paint()
          ..color = PaletaRotulador.tinta
          ..strokeWidth = 1.8,
      );
      // Etiqueta sólo si el cuerpo asoma lo suficiente.
      if (fraccionAsomar > 0.4) {
        final TextPainter pintorEtiquetaTarget = TextPainter(
          text: TextSpan(
            text: target.etiqueta,
            style: TextStyle(
              color: target.flashLevantamiento > 0.4
                  ? PaletaRotulador.papel
                  : (target.golpeado
                        ? PaletaRotulador.tintaDiluida(0.45)
                        : PaletaRotulador.tinta),
              fontFamily: 'CosmoMono',
              fontSize: rectPx.width * 0.55,
              fontWeight: FontWeight.w900,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        pintorEtiquetaTarget.paint(
          canvas,
          Offset(
            rectCuerpo.center.dx - pintorEtiquetaTarget.width / 2,
            rectCuerpo.center.dy - pintorEtiquetaTarget.height / 2,
          ),
        );
      }
    }
    // Contador del DROP BANK: pequeña estampilla en la esquina alta
    // izquierda mostrando cuántas veces se ha limpiado.
    if (vecesLimpiadoBank > 0) {
      estampillaRoja(
        canvas,
        posicion: Offset(size.width * 0.13, size.height * 0.14),
        texto: 'BANK ×$vecesLimpiadoBank',
        anchoEstampilla: rX(0.18),
        altoEstampilla: rX(0.05),
        rotacionRadianes: -0.18,
        opacidad: 0.75,
      );
    }

    // Guias laterales inferiores (rampas que canalizan a las paletas).
    // La guía derecha debe empezar pegada al borde *interno* del carril
    // del lanzador, no al externo, para no atravesar la salida.
    final List<List<Offset>> guiasInferioresVis = const <List<Offset>>[
      <Offset>[Offset(0.0, 1.05), Offset(0.30, 1.30)],
      <Offset>[
        Offset(
          _PantallaPinballComiteState.anchoMesa -
              _PantallaPinballComiteState.anchoCarrilLanzador,
          1.05,
        ),
        Offset(0.70, 1.30),
      ],
    ];
    for (final guia in guiasInferioresVis) {
      canvas.drawLine(
        r(guia[0]),
        r(guia[1]),
        Paint()
          ..color = PaletaRotulador.rojoEstampilla.withValues(alpha: 0.7)
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        r(guia[0]),
        r(guia[1]),
        Paint()
          ..color = PaletaRotulador.tinta.withValues(alpha: 0.55)
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round,
      );
    }

    // RAMPA DE RETORNO: tubo curvo desde arriba-izquierda hasta el
    // lateral derecho. Dibujamos dos curvas Bézier paralelas para
    // simular un canal con paredes, más una flecha en la salida.
    final Offset p0Px = r(_PantallaPinballComiteState.puntoEntradaRampaRetorno);
    final Offset p1Px = r(_PantallaPinballComiteState.puntoControlRampaRetorno);
    final Offset p2Px = r(_PantallaPinballComiteState.puntoSalidaRampaRetorno);
    // Sombra del tubo (más oscuro abajo).
    final Path caminoSombra = Path()
      ..moveTo(p0Px.dx, p0Px.dy + 4)
      ..quadraticBezierTo(p1Px.dx, p1Px.dy + 4, p2Px.dx, p2Px.dy + 4);
    canvas.drawPath(
      caminoSombra,
      Paint()
        ..color = PaletaRotulador.tinta.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round,
    );
    // Cuerpo del tubo: trazo grueso papel sucio.
    final Path caminoCurva = Path()
      ..moveTo(p0Px.dx, p0Px.dy)
      ..quadraticBezierTo(p1Px.dx, p1Px.dy, p2Px.dx, p2Px.dy);
    canvas.drawPath(
      caminoCurva,
      Paint()
        ..color = PaletaRotulador.papelSucio
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );
    // Bordes del tubo: dos curvas paralelas a tinta.
    canvas.drawPath(
      caminoCurva,
      Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round,
    );
    // Líneas paralelas internas (efecto "carril" del tubo).
    canvas.drawPath(
      caminoCurva,
      Paint()
        ..color = PaletaRotulador.tintaDiluida(0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.round,
    );
    // Boca de entrada: círculo doble en p0.
    canvas.drawCircle(p0Px, 9, Paint()..color = PaletaRotulador.tinta);
    canvas.drawCircle(p0Px, 6, Paint()..color = PaletaRotulador.rojoEstampilla);
    final TextPainter pintorEntradaRampa = TextPainter(
      text: const TextSpan(
        text: 'RETORNO',
        style: TextStyle(
          fontFamily: 'CosmoSerif',
          fontSize: 9,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w900,
          color: PaletaRotulador.tinta,
          letterSpacing: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintorEntradaRampa.paint(
      canvas,
      Offset(p0Px.dx + 12, p0Px.dy - pintorEntradaRampa.height / 2),
    );
    // Boca de salida: triángulo apuntando en dirección tangente.
    final Offset tangenteSalidaPx = Offset(
      2 * (p2Px.dx - p1Px.dx),
      2 * (p2Px.dy - p1Px.dy),
    );
    final double magnitudTangenteSalida = tangenteSalidaPx.distance;
    if (magnitudTangenteSalida > 0) {
      final Offset direccionSalidaPx =
          tangenteSalidaPx / magnitudTangenteSalida;
      final Offset perpendicularSalida = Offset(
        -direccionSalidaPx.dy,
        direccionSalidaPx.dx,
      );
      final Path triSalida = Path()
        ..moveTo(
          p2Px.dx + direccionSalidaPx.dx * 10,
          p2Px.dy + direccionSalidaPx.dy * 10,
        )
        ..lineTo(
          p2Px.dx + perpendicularSalida.dx * 7,
          p2Px.dy + perpendicularSalida.dy * 7,
        )
        ..lineTo(
          p2Px.dx - perpendicularSalida.dx * 7,
          p2Px.dy - perpendicularSalida.dy * 7,
        )
        ..close();
      canvas.drawPath(
        triSalida,
        Paint()..color = PaletaRotulador.rojoEstampilla,
      );
      canvas.drawPath(
        triSalida,
        Paint()
          ..color = PaletaRotulador.tinta
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }
    // Si la bola está viajando por la rampa, dibujamos un puntito
    // espectral en su posición actual sobre la curva.
    if (bolaEnRampaRetorno) {
      final double tCurva = progresoRampaRetorno.clamp(0.0, 1.0);
      final double u = 1.0 - tCurva;
      final Offset posicionEnTuboPx = Offset(
        u * u * p0Px.dx + 2 * u * tCurva * p1Px.dx + tCurva * tCurva * p2Px.dx,
        u * u * p0Px.dy + 2 * u * tCurva * p1Px.dy + tCurva * tCurva * p2Px.dy,
      );
      canvas.drawCircle(
        posicionEnTuboPx,
        rX(_PantallaPinballComiteState.radioBola) * 0.9,
        Paint()..color = PaletaRotulador.rojoEstampilla.withValues(alpha: 0.75),
      );
      canvas.drawCircle(
        posicionEnTuboPx,
        rX(_PantallaPinballComiteState.radioBola) * 1.4,
        Paint()..color = PaletaRotulador.rojoEstampilla.withValues(alpha: 0.18),
      );
    }
    // Si el TÚNEL FRENÉTICO está activo, el cuerpo del tubo destella.
    if (tunelFreneticoActivo) {
      final double pulsoTunel =
          (math.sin(tiempoTunelFreneticoRestante * 7.0) + 1.0) / 2.0;
      canvas.drawPath(
        caminoCurva,
        Paint()
          ..color = PaletaRotulador.rojoEstampilla.withValues(
            alpha: 0.35 + pulsoTunel * 0.35,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6 + pulsoTunel * 4
          ..strokeCap = StrokeCap.round,
      );
    }

    // SAUCER / LOCK HOLE central. Disco oscuro + anillo rojo + cuenta
    // atrás si la bola está dentro.
    final Offset centroSaucerPx = r(_PantallaPinballComiteState.posicionSaucer);
    final double radioSaucerPx = rX(_PantallaPinballComiteState.radioSaucer);
    if (imagenSaucer != null) {
      _dibujarSpriteCentrado(
        canvas,
        imagenSaucer!,
        centro: centroSaucerPx,
        ancho: radioSaucerPx * 3.1,
        alto: radioSaucerPx * 3.1,
      );
    } else {
      canvas.drawCircle(
        centroSaucerPx,
        radioSaucerPx,
        Paint()..color = PaletaRotulador.tintaDiluida(0.85),
      );
      canvas.drawCircle(
        centroSaucerPx,
        radioSaucerPx,
        Paint()
          ..color = PaletaRotulador.tinta
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
      // Aro interno rojo (la "boca" del saucer).
      canvas.drawCircle(
        centroSaucerPx,
        radioSaucerPx * 0.55,
        Paint()..color = PaletaRotulador.rojoEstampilla.withValues(alpha: 0.45),
      );
      canvas.drawCircle(
        centroSaucerPx,
        radioSaucerPx * 0.55,
        Paint()
          ..color = PaletaRotulador.rojoEstampilla
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      // Etiqueta "EXPEDIENTE" debajo.
      final TextPainter pintorSaucer = TextPainter(
        text: const TextSpan(
          text: 'EXPEDIENTE',
          style: TextStyle(
            fontFamily: 'CosmoSerif',
            fontSize: 9,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            color: PaletaRotulador.tinta,
            letterSpacing: 1.4,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      pintorSaucer.paint(
        canvas,
        Offset(
          centroSaucerPx.dx - pintorSaucer.width / 2,
          centroSaucerPx.dy + radioSaucerPx + 2,
        ),
      );
    }
    // Si la bola está retenida, dibujar aro pulsante con cuenta atrás.
    if (bolaEnSaucer) {
      final double fraccionRestante =
          (tiempoEnSaucerRestante /
                  _PantallaPinballComiteState.duracionRetencionSaucerSegundos)
              .clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: centroSaucerPx, radius: radioSaucerPx + 6),
        -math.pi / 2,
        math.pi * 2 * fraccionRestante,
        false,
        Paint()
          ..color = PaletaRotulador.rojoEstampilla
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0,
      );
    }

    // SPINNER lateral: aspa de molino que gira al pasar la bola.
    final Rect rectSpinnerPx = Rect.fromLTRB(
      _PantallaPinballComiteState.rectSpinner.left * escalaX,
      _PantallaPinballComiteState.rectSpinner.top * escalaY,
      _PantallaPinballComiteState.rectSpinner.right * escalaX,
      _PantallaPinballComiteState.rectSpinner.bottom * escalaY,
    );
    if (imagenSpinner != null) {
      canvas.save();
      canvas.translate(rectSpinnerPx.center.dx, rectSpinnerPx.center.dy);
      canvas.rotate(anguloSpinner);
      _dibujarSpriteCentrado(
        canvas,
        imagenSpinner!,
        centro: Offset.zero,
        ancho: rectSpinnerPx.height,
        alto: rectSpinnerPx.width,
      );
      canvas.restore();
    } else {
      // Carcasa rectangular (papel + borde).
      canvas.drawRect(rectSpinnerPx, Paint()..color = PaletaRotulador.papel);
      rectanguloRotulador(
        canvas,
        rectSpinnerPx,
        pincel: Paint()
          ..color = PaletaRotulador.tinta
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
        intensidadJitter: 0.6,
        semilla: 41,
      );
      // Aspas: 4 cuchillas a tinta rotando.
      final Offset centroSpinnerPx = rectSpinnerPx.center;
      final double radioAspa =
          math.min(rectSpinnerPx.width, rectSpinnerPx.height) * 0.42;
      canvas.save();
      canvas.translate(centroSpinnerPx.dx, centroSpinnerPx.dy);
      canvas.rotate(anguloSpinner);
      final Paint pincelAspa = Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      for (int indiceAspa = 0; indiceAspa < 4; indiceAspa++) {
        final double angulo = indiceAspa * math.pi / 2;
        canvas.drawLine(
          Offset(math.cos(angulo) * radioAspa, math.sin(angulo) * radioAspa),
          Offset(
            math.cos(angulo) * radioAspa * 0.15,
            math.sin(angulo) * radioAspa * 0.15,
          ),
          pincelAspa,
        );
      }
      canvas.drawCircle(
        Offset.zero,
        2.0,
        Paint()..color = PaletaRotulador.rojoEstampilla,
      );
      canvas.restore();
    }
    // Etiqueta SPINNER vertical.
    canvas.save();
    canvas.translate(rectSpinnerPx.left - 6, rectSpinnerPx.center.dy);
    canvas.rotate(-math.pi / 2);
    final TextPainter pintorSpinnerTexto = TextPainter(
      text: TextSpan(
        text: 'SPINNER',
        style: TextStyle(
          fontFamily: 'CosmoMono',
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: PaletaRotulador.tintaDiluida(0.65),
          letterSpacing: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintorSpinnerTexto.paint(
      canvas,
      Offset(-pintorSpinnerTexto.width / 2, -pintorSpinnerTexto.height / 2),
    );
    canvas.restore();

    // BORDE DE BUROCRACIA AVANZADA: doble marco rojo intermitente
    // cuando el modo bonus está activo.
    if (burocraciaAvanzadaActiva) {
      final double pulsoBurocracia =
          (math.sin(tiempoBurocraciaAvanzadaRestante * 6.0) + 1.0) / 2.0;
      final Rect marcoExterior = Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height,
      ).deflate(4);
      canvas.drawRect(
        marcoExterior,
        Paint()
          ..color = PaletaRotulador.rojoEstampilla.withValues(
            alpha: 0.45 + pulsoBurocracia * 0.35,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.5 + pulsoBurocracia * 2.5,
      );
      // Sello rotado en esquina inferior izquierda.
      estampillaRoja(
        canvas,
        posicion: Offset(size.width * 0.18, size.height * 0.95),
        texto: 'BUROCRACIA AVANZADA',
        anchoEstampilla: size.width * 0.30,
        altoEstampilla: size.height * 0.04,
        rotacionRadianes: -0.10,
        opacidad: (0.6 + pulsoBurocracia * 0.4).clamp(0.0, 1.0),
      );
    }

    // INDICADOR DE SKILL SHOT: estampilla pulsante en la parte superior
    // del carril del lanzador cuando la ventana está abierta.
    if (skillShotDisponible) {
      final double pulsoSkill =
          (math.sin(tiempoSkillShotRestante * 8.0) + 1.0) / 2.0;
      final Offset centroSkill = Offset(
        (_PantallaPinballComiteState.anchoMesa -
                _PantallaPinballComiteState.anchoCarrilLanzador / 2) *
            escalaX,
        0.05 * escalaY,
      );
      estampillaRoja(
        canvas,
        posicion: centroSkill,
        texto: 'SKILL SHOT',
        anchoEstampilla: rX(0.16),
        altoEstampilla: rX(0.05),
        rotacionRadianes: -0.18,
        opacidad: (0.6 + pulsoSkill * 0.4).clamp(0.0, 1.0),
      );
    }

    // Bumpers: cabecitas-retrato del Comité (cabeza redonda + visera +
    // estrella roja + etiqueta de 3 letras debajo).
    for (final bumper in bumpers) {
      final centroPx = r(bumper.posicion);
      final radioPx = rX(bumper.radio);
      // Halo flash individual + flash global atenuado.
      final double alphaHalo =
          0.18 + bumper.flashIndividual * 0.55 + flashRojoFase * 0.10;
      canvas.drawCircle(
        centroPx,
        radioPx * (1.30 + bumper.flashIndividual * 0.25),
        Paint()
          ..color = bumper.colorAcento.withValues(
            alpha: alphaHalo.clamp(0.0, 1.0),
          ),
      );
      if (imagenBumper != null) {
        _dibujarSpriteCentrado(
          canvas,
          imagenBumper!,
          centro: centroPx,
          ancho: radioPx * 2.3,
          alto: radioPx * 2.3,
        );
        continue;
      }
      // Disco base color acento (uniforme del retrato).
      canvas.drawCircle(centroPx, radioPx, Paint()..color = bumper.colorAcento);
      canvas.drawCircle(
        centroPx,
        radioPx,
        Paint()
          ..color = PaletaRotulador.tinta
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      // Cara (cabeza redonda papel viejo).
      final Offset centroCara = centroPx.translate(0, -radioPx * 0.10);
      canvas.drawCircle(
        centroCara,
        radioPx * 0.62,
        Paint()
          ..color = Color.lerp(
            PaletaRotulador.papel,
            PaletaRotulador.papel,
            bumper.flashIndividual,
          )!,
      );
      canvas.drawCircle(
        centroCara,
        radioPx * 0.62,
        Paint()
          ..color = PaletaRotulador.tinta
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
      // Ojos.
      canvas.drawCircle(
        centroCara.translate(-radioPx * 0.22, -radioPx * 0.05),
        radioPx * 0.07,
        Paint()..color = PaletaRotulador.tinta,
      );
      canvas.drawCircle(
        centroCara.translate(radioPx * 0.22, -radioPx * 0.05),
        radioPx * 0.07,
        Paint()..color = PaletaRotulador.tinta,
      );
      // Boca: seria por defecto, sorprendida en flash.
      if (bumper.flashIndividual > 0.4) {
        canvas.drawCircle(
          centroCara.translate(0, radioPx * 0.22),
          radioPx * 0.08,
          Paint()..color = PaletaRotulador.tinta,
        );
      } else {
        canvas.drawLine(
          centroCara.translate(-radioPx * 0.16, radioPx * 0.22),
          centroCara.translate(radioPx * 0.16, radioPx * 0.22),
          Paint()
            ..color = PaletaRotulador.tinta
            ..strokeWidth = 1.8
            ..strokeCap = StrokeCap.round,
        );
      }
      // Bigote tipico del Comite (excepto F-447 que no tiene cara).
      if (bumper.etiqueta != 'F-447') {
        canvas.drawLine(
          centroCara.translate(-radioPx * 0.22, radioPx * 0.13),
          centroCara.translate(radioPx * 0.22, radioPx * 0.13),
          Paint()
            ..color = PaletaRotulador.tinta
            ..strokeWidth = 2.4
            ..strokeCap = StrokeCap.round,
        );
      }
      // Visera militar arriba.
      canvas.drawArc(
        Rect.fromCircle(center: centroCara, radius: radioPx * 0.62),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = PaletaRotulador.tinta.withValues(alpha: 0.6)
          ..style = PaintingStyle.fill,
      );
      // Estrella roja en la frente.
      _dibujarEstrellaCinco(
        canvas,
        centroCara.translate(0, -radioPx * 0.42),
        radioPx * 0.14,
        Paint()..color = PaletaRotulador.rojoEstampilla,
      );
      // Etiqueta debajo del retrato (3 letras).
      final pintorEtiqueta = TextPainter(
        text: TextSpan(
          text: bumper.etiqueta,
          style: TextStyle(
            color: PaletaRotulador.papel,
            fontFamily: 'CosmoMono',
            fontSize: radioPx * 0.32,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      pintorEtiqueta.paint(
        canvas,
        Offset(
          centroPx.dx - pintorEtiqueta.width / 2,
          centroPx.dy + radioPx * 0.55,
        ),
      );
    }

    // Jefe-sarcofago (solo en tablero Cripta).
    if (jefe != null && jefe!.vidasRestantes > 0) {
      final Offset centroJefePx = r(jefe!.posicion);
      final double radioJefePx = rX(jefe!.radio);
      // Halo flash: se conserva siempre (sirve de feedback de impacto).
      canvas.drawCircle(
        centroJefePx,
        radioJefePx * (1.25 + jefe!.flashImpacto * 0.25),
        Paint()
          ..color = PaletaRotulador.rojoEstampilla.withValues(
            alpha: 0.2 + jefe!.flashImpacto * 0.5,
          ),
      );
      if (imagenSarcofago != null) {
        // PNG del sarcófago, centrado en la posición del jefe. La
        // altura es proporcional al radio para mantener la silueta
        // original del bumper.
        final ui.Image sprite = imagenSarcofago!;
        final double anchoSpritePx = radioJefePx * 2.4;
        final double altoSpritePx = radioJefePx * 3.4;
        final Rect rectDestino = Rect.fromCenter(
          center: centroJefePx.translate(0, radioJefePx * 0.20),
          width: anchoSpritePx,
          height: altoSpritePx,
        );
        final Rect rectOrigen = Rect.fromLTWH(
          0,
          0,
          sprite.width.toDouble(),
          sprite.height.toDouble(),
        );
        canvas.drawImageRect(
          sprite,
          rectOrigen,
          rectDestino,
          Paint()..filterQuality = FilterQuality.high,
        );
      } else {
        // Fallback procedimental mientras carga el PNG.
        final Path sarcofago = Path()
          ..moveTo(
            centroJefePx.dx - radioJefePx * 0.85,
            centroJefePx.dy - radioJefePx * 0.20,
          )
          ..lineTo(
            centroJefePx.dx + radioJefePx * 0.85,
            centroJefePx.dy - radioJefePx * 0.20,
          )
          ..lineTo(
            centroJefePx.dx + radioJefePx * 0.70,
            centroJefePx.dy + radioJefePx * 1.30,
          )
          ..lineTo(
            centroJefePx.dx - radioJefePx * 0.70,
            centroJefePx.dy + radioJefePx * 1.30,
          )
          ..close();
        canvas.drawPath(sarcofago, Paint()..color = PaletaRotulador.papelSucio);
        canvas.drawPath(
          sarcofago,
          Paint()
            ..color = PaletaRotulador.tinta
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.6,
        );
        canvas.drawCircle(
          centroJefePx.translate(0, -radioJefePx * 0.50),
          radioJefePx * 0.55,
          Paint()..color = PaletaRotulador.papelSucio,
        );
        canvas.drawCircle(
          centroJefePx.translate(0, -radioJefePx * 0.50),
          radioJefePx * 0.55,
          Paint()
            ..color = PaletaRotulador.tinta
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );
        canvas.drawLine(
          centroJefePx.translate(-radioJefePx * 0.22, -radioJefePx * 0.50),
          centroJefePx.translate(-radioJefePx * 0.10, -radioJefePx * 0.50),
          Paint()
            ..color = PaletaRotulador.tinta
            ..strokeWidth = 2.4
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawLine(
          centroJefePx.translate(radioJefePx * 0.10, -radioJefePx * 0.50),
          centroJefePx.translate(radioJefePx * 0.22, -radioJefePx * 0.50),
          Paint()
            ..color = PaletaRotulador.tinta
            ..strokeWidth = 2.4
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawLine(
          centroJefePx.translate(-radioJefePx * 0.25, -radioJefePx * 0.30),
          centroJefePx.translate(radioJefePx * 0.25, -radioJefePx * 0.30),
          Paint()
            ..color = PaletaRotulador.tinta
            ..strokeWidth = 3.5
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawRect(
          Rect.fromCenter(
            center: centroJefePx.translate(0, radioJefePx * 0.40),
            width: radioJefePx * 0.20,
            height: radioJefePx * 1.00,
          ),
          Paint()..color = PaletaRotulador.rojoEstampilla,
        );
        canvas.drawRect(
          Rect.fromCenter(
            center: centroJefePx.translate(0, radioJefePx * 0.20),
            width: radioJefePx * 0.80,
            height: radioJefePx * 0.20,
          ),
          Paint()..color = PaletaRotulador.rojoEstampilla,
        );
      }
      // Barra de vida del jefe arriba.
      final Rect rectVida = Rect.fromLTWH(
        centroJefePx.dx - radioJefePx * 0.85,
        centroJefePx.dy - radioJefePx * 1.05,
        radioJefePx * 1.7,
        rX(0.020),
      );
      canvas.drawRect(rectVida, Paint()..color = PaletaRotulador.tinta);
      canvas.drawRect(
        Rect.fromLTWH(
          rectVida.left,
          rectVida.top,
          rectVida.width * jefe!.vidasRestantes / jefe!.vidasIniciales,
          rectVida.height,
        ),
        Paint()..color = PaletaRotulador.rojoEstampilla,
      );
    }

    // Portal de subida al siguiente tablero (si lo hay).
    if (indiceTablero < totalTableros - 1) {
      final double pulso =
          0.4 +
          0.3 *
              math.sin(
                flashRojoFase * math.pi * 4 +
                    DateTime.now().millisecondsSinceEpoch / 200,
              );
      final Rect rectPortal = Rect.fromLTWH(
        size.width * 0.42,
        0,
        size.width * 0.16,
        rX(0.04),
      );
      canvas.drawRect(
        rectPortal,
        Paint()..color = tableroActual.colorAcento.withValues(alpha: pulso),
      );
      final pintorPortal = TextPainter(
        text: const TextSpan(
          text: '↑ SIGUIENTE PISO ↑',
          style: TextStyle(
            color: PaletaRotulador.papel,
            fontFamily: 'CosmoMono',
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      pintorPortal.paint(
        canvas,
        Offset(
          rectPortal.center.dx - pintorPortal.width / 2,
          rectPortal.center.dy - pintorPortal.height / 2,
        ),
      );
    }

    // Nombre del tablero arriba a la izquierda.
    final pintorTablero = TextPainter(
      text: TextSpan(
        text: '${indiceTablero + 1}/$totalTableros · ${tableroActual.nombre}',
        style: TextStyle(
          color: PaletaRotulador.papel.withValues(alpha: 0.7),
          fontFamily: 'CosmoMono',
          fontSize: rX(0.025),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintorTablero.paint(canvas, Offset(size.width * 0.06, size.height * 0.96));

    // Paletas.
    _pintarPaleta(
      canvas,
      pivot: r(const Offset(0.34, 1.30)),
      escala: escalaX,
      esIzquierda: true,
      rotacion: rotacionPaletaIzquierda,
      sprite: imagenFlipperIzq,
    );
    _pintarPaleta(
      canvas,
      pivot: r(const Offset(0.66, 1.30)),
      escala: escalaX,
      esIzquierda: false,
      rotacion: rotacionPaletaDerecha,
      sprite: imagenFlipperDer,
    );

    // Lanzador (muelle).
    final pinTopY = r(const Offset(0, 1.05)).dy;
    final pinBotY = r(const Offset(0, 1.45)).dy;
    final pinX = r(
      const Offset(_PantallaPinballComiteState.anchoMesa - 0.05, 0),
    ).dx;
    if (imagenLanzadorResorte != null) {
      _dibujarSpriteCentrado(
        canvas,
        imagenLanzadorResorte!,
        centro: Offset(pinX, (pinTopY + pinBotY) / 2),
        ancho: rX(0.09),
        alto: pinBotY - pinTopY,
      );
    } else {
      // Caja del lanzador.
      canvas.drawRect(
        Rect.fromLTWH(pinX - rX(0.03), pinTopY, rX(0.06), pinBotY - pinTopY),
        Paint()..color = PaletaRotulador.tinta,
      );
      // Indicador de carga.
      final yIndicador =
          pinTopY + (pinBotY - pinTopY) * (1.0 - 0.6 * cargaLanzador);
      canvas.drawRect(
        Rect.fromLTRB(pinX - rX(0.026), yIndicador, pinX + rX(0.026), pinBotY),
        Paint()
          ..color = Color.lerp(
            PaletaRotulador.rojoEstampilla,
            PaletaRotulador.rojoEstampilla,
            cargaLanzador,
          )!,
      );
    }

    // Bola = cabeza del cosmonauta rodando.
    final radioBolaPx = rX(_PantallaPinballComiteState.radioBola);
    // Estela: circulos cada vez mas pequenos y transparentes.
    for (int indice = 0; indice < historialPosicionesBola.length; indice++) {
      final double progresoEstela =
          1.0 - indice / historialPosicionesBola.length;
      canvas.drawCircle(
        r(historialPosicionesBola[indice]),
        radioBolaPx * (0.45 + progresoEstela * 0.55),
        Paint()
          ..color = PaletaRotulador.papel.withValues(
            alpha: progresoEstela * 0.30,
          ),
      );
    }
    // Halo brillante.
    canvas.drawCircle(
      r(posicionBola),
      radioBolaPx * 1.8,
      Paint()..color = PaletaRotulador.papel.withValues(alpha: 0.18),
    );
    // Multibola fantasma: dibujar dos bolas espectrales orbitando.
    if (tiempoMultibolaRestante > 0) {
      final double alphaFantasma = (tiempoMultibolaRestante / 2.0).clamp(
        0.0,
        0.85,
      );
      for (int indiceFantasma = 0; indiceFantasma < 2; indiceFantasma++) {
        final double anguloOrbital = faseMultibola + indiceFantasma * math.pi;
        final Offset posFantasmaMundo = posicionBola.translate(
          math.cos(anguloOrbital) * 0.10,
          math.sin(anguloOrbital) * 0.06,
        );
        final Offset centroFantasmaPx = r(posFantasmaMundo);
        // Halo neón rojo (espectro).
        canvas.drawCircle(
          centroFantasmaPx,
          radioBolaPx * 1.6,
          Paint()
            ..color = PaletaRotulador.rojoEstampilla.withValues(
              alpha: alphaFantasma * 0.30,
            )
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
        );
        // Cuerpo: cabeza-cosmonauta semitransparente.
        canvas.saveLayer(
          Rect.fromCircle(center: centroFantasmaPx, radius: radioBolaPx * 2),
          Paint()..color = Color.fromRGBO(0, 0, 0, alphaFantasma),
        );
        dibujarCabezaComoBola(
          canvas,
          centro: centroFantasmaPx,
          radio: radioBolaPx * 0.85,
          rotacion: anguloOrbital * 2.0,
        );
        canvas.restore();
      }
    }

    // La bola se renderiza fuera del painter como Image.asset
    // (cadete_bola_f01.png) en un Positioned dentro del LayoutBuilder.
    // Aquí sólo dejamos estela/halo/multibola.

    // Chispas que saltan al golpear bumpers (debajo de los textos).
    for (final chispa in chispasPinball) {
      final double alphaChispa = chispa.vidaRestante.clamp(0.0, 1.0);
      canvas.drawCircle(
        r(chispa.posicion),
        rX(0.006) + rX(0.004) * alphaChispa,
        Paint()..color = chispa.color.withValues(alpha: alphaChispa),
      );
    }

    // Textos flotantes.
    for (final texto in textosFlotantes) {
      final alpha = (texto.vidaRestante / 0.9).clamp(0.0, 1.0);
      final pintor = TextPainter(
        text: TextSpan(
          text: texto.texto,
          style: TextStyle(
            color: PaletaRotulador.papel.withValues(alpha: alpha),
            fontFamily: 'CosmoMono',
            fontSize: rX(0.04),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      pintor.paint(
        canvas,
        Offset(
          r(texto.posicion).dx - pintor.width / 2,
          r(texto.posicion).dy - pintor.height / 2,
        ),
      );
    }

    // Cerrar la sacudida (todo lo de arriba va sacudido; lo de abajo no).
    canvas.restore();

    // HUD multiplicador siempre visible en esquina superior derecha del
    // tablero (encima de la rampa). Muestra ×N en grande cuando es >1.
    if (multiplicador > 1) {
      final pintorMulti = TextPainter(
        text: TextSpan(
          text: '×$multiplicador',
          style: TextStyle(
            color: PaletaRotulador.rojoEstampilla,
            fontFamily: 'CosmoMono',
            fontSize: rX(0.07),
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      pintorMulti.paint(canvas, Offset(size.width * 0.06, size.height * 0.04));
    }

    // Indicador de combo bajo el multiplicador (decae con el tiempo).
    if (golpesComboActual >= 2) {
      final double escalaCombo = tiempoComboRestanteSegundos / 2.5;
      final pintorCombo = TextPainter(
        text: TextSpan(
          text: 'COMBO ${golpesComboActual}x',
          style: TextStyle(
            color: PaletaRotulador.rojoEstampilla.withValues(
              alpha: escalaCombo.clamp(0.2, 1.0),
            ),
            fontFamily: 'CosmoMono',
            fontSize: rX(0.034),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      pintorCombo.paint(canvas, Offset(size.width * 0.06, size.height * 0.11));
      // Barra de tiempo restante del combo.
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * 0.06,
          size.height * 0.145,
          size.width * 0.16 * escalaCombo,
          size.height * 0.008,
        ),
        Paint()..color = PaletaRotulador.rojoEstampilla.withValues(alpha: 0.85),
      );
    }

    // Indicador de progreso BANDERA ROJA: cuatro estrellas que se encienden
    // segun los targets golpeados. Cuando los cuatro estan, parpadea.
    final int targetsActivos = targets.where((t) => t.golpeado).length;
    final bool destelloFinal = todosTargetsActivos && (flashRojoFase > 0.3);
    for (int indice = 0; indice < targets.length; indice++) {
      final bool encendida = indice < targetsActivos;
      final Offset centroEstrella = Offset(
        size.width * (0.20 + indice * 0.05),
        size.height * 0.06,
      );
      _dibujarEstrellaCinco(
        canvas,
        centroEstrella,
        rX(0.018),
        Paint()
          ..color = encendida || destelloFinal
              ? PaletaRotulador.rojoEstampilla
              : PaletaRotulador.papel.withValues(alpha: 0.25),
      );
    }

    // Aviso central.
    if (avisoCentral != null) {
      final alpha = avisoCentral!.vidaRestante == double.infinity
          ? 1.0
          : (avisoCentral!.vidaRestante / 1.5).clamp(0.3, 1.0);
      final pintor = TextPainter(
        text: TextSpan(
          text: avisoCentral!.texto,
          style: TextStyle(
            color: PaletaRotulador.rojoEstampilla.withValues(alpha: alpha),
            fontFamily: 'CosmoMono',
            fontSize: rX(0.05),
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            height: 1.3,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: size.width * 0.8);
      pintor.paint(
        canvas,
        Offset(
          size.width / 2 - pintor.width / 2,
          size.height / 2 - pintor.height / 2,
        ),
      );
    }
  }

  void _pintarPaleta(
    Canvas canvas, {
    required Offset pivot,
    required double escala,
    required bool esIzquierda,
    required double rotacion,
    ui.Image? sprite,
  }) {
    final anguloReposo = esIzquierda ? -math.pi / 9 : math.pi + math.pi / 9;
    final anguloActivo = esIzquierda
        ? -math.pi / 3 * 1.4
        : math.pi + math.pi / 3 * 1.4;
    final angulo = anguloReposo + (anguloActivo - anguloReposo) * rotacion;
    final longitudPx = _PantallaPinballComiteState.longitudPaleta * escala;
    final anchoPx = _PantallaPinballComiteState.anchoPaleta * escala;
    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(angulo);
    if (sprite != null) {
      // La convención física de la paleta dibuja siempre desde el pivote
      // local hacia +X. El arte derecho, en cambio, trae el remache en su
      // borde derecho para que la rotulación quede natural en pantalla.
      // Lo giramos 180º dentro de su propio marco: así el remache vuelve
      // al pivote que espera el motor sin dejar el texto en espejo.
      if (!esIzquierda) {
        canvas.translate(longitudPx, 0);
        canvas.rotate(math.pi);
      }
      _dibujarSpriteEnRect(
        canvas,
        sprite,
        Rect.fromLTWH(0, -anchoPx * 0.95, longitudPx, anchoPx * 1.9),
      );
      canvas.restore();
      return;
    }
    final rectPaleta = Rect.fromLTWH(0, -anchoPx / 2, longitudPx, anchoPx);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rectPaleta, Radius.circular(anchoPx / 2)),
      Paint()..color = PaletaRotulador.rojoEstampilla,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rectPaleta, Radius.circular(anchoPx / 2)),
      Paint()
        ..color = PaletaRotulador.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    // Estrella en la base.
    _dibujarEstrellaCinco(
      canvas,
      const Offset(0, 0),
      anchoPx * 0.55,
      Paint()..color = PaletaRotulador.papel,
    );
    canvas.restore();
  }

  void _dibujarSpriteEnRect(Canvas canvas, ui.Image sprite, Rect destino) {
    canvas.drawImageRect(
      sprite,
      Rect.fromLTWH(0, 0, sprite.width.toDouble(), sprite.height.toDouble()),
      destino,
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  void _dibujarSpriteCentrado(
    Canvas canvas,
    ui.Image sprite, {
    required Offset centro,
    required double ancho,
    required double alto,
  }) {
    _dibujarSpriteEnRect(
      canvas,
      sprite,
      Rect.fromCenter(center: centro, width: ancho, height: alto),
    );
  }

  void _dibujarEstrellaCinco(
    Canvas canvas,
    Offset centro,
    double radio,
    Paint pincel,
  ) {
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
  bool shouldRepaint(covariant _PintorMesaPinball viejo) => true;
}

const String _flagHighscorePinball = 'pinball_highscore_';

int _leerHighscorePinball(EstadoJuego estado) {
  for (final flag in estado.flagsActivos) {
    if (flag.startsWith(_flagHighscorePinball)) {
      return int.tryParse(flag.substring(_flagHighscorePinball.length)) ?? 0;
    }
  }
  return 0;
}

void _guardarHighscorePinball(EstadoJuego estado, int puntuacion) {
  estado.flagsActivos.removeWhere(
    (flag) => flag.startsWith(_flagHighscorePinball),
  );
  estado.activarFlag('$_flagHighscorePinball$puntuacion');
}
