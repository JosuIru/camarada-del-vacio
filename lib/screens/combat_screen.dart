import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/classes.dart';
import '../data/companions.dart';
import '../data/encounters.dart';
import '../data/equipment.dart';
import '../data/skills.dart';
import '../models/character.dart';
import '../models/combat_action.dart';
import '../models/game_class.dart';
import '../models/game_state.dart';
import '../painters/combat_floor_painter.dart';
import '../painters/stick_figure_painter.dart';
import '../painters/transformaciones_ataque.dart';
import '../theme.dart';
import '../utilities/audio_procedural.dart';
import '../widgets/combat_portrait.dart';
import '../widgets/mascota_narrativa.dart';
import '../widgets/dust_particles.dart';
import '../widgets/sprite_clase_cadete.dart';
import '../widgets/level_up_dialog.dart';
import '../widgets/overlay_estados_peon.dart';
import '../widgets/paper_background.dart';
import '../widgets/propaganda_button.dart';
import '../widgets/stat_bar.dart';
import '../widgets/status_icons.dart';
import '../widgets/turn_banner.dart';

class PantallaCombate extends StatefulWidget {
  final EstadoJuego estado;
  final TipoEncuentro tipoEncuentro;

  const PantallaCombate({
    super.key,
    required this.estado,
    required this.tipoEncuentro,
  });

  Combatiente get jugador => estado.personaje;

  @override
  State<PantallaCombate> createState() => _PantallaCombateState();
}

class _PantallaCombateState extends State<PantallaCombate>
    with TickerProviderStateMixin {
  static const int columnasGrid = 6;
  static const int filasGrid = 3;

  late ConfiguracionEncuentro encuentro;
  late List<Combatiente> enemigos;
  Combatiente? companeroPortatil;
  final List<String> registroCombate = [];
  final math.Random aleatorio = math.Random();
  final Map<String, int> usosGastados = {};
  bool esTurnoJugador = true;
  int numeroRonda = 1;
  bool combateFinalizado = false;
  bool victoriaJugador = false;
  late AnimationController controladorAmbiental;

  /// Controlador del "viaje de ataque": el atacante se desplaza visualmente
  /// hacia el objetivo, se transforma cómicamente en el peak y vuelve. Es
  /// puramente cosmético: el daño se aplica al inicio, la animación
  /// proporciona feedback en paralelo.
  late AnimationController controladorViajeAtaque;
  Combatiente? atacanteEnViaje;
  Combatiente? objetivoDelViaje;
  String? idHabilidadDelViaje;
  List<String> buffsAplicadosAlIniciar = [];
  int versionBanner = 0;
  String textoBannerActual = 'TU TURNO';
  bool bannerEsJugador = true;
  bool companeroYaActuoEsteTurno = false;
  int xpRecompensaPendiente = 0;
  String? idBotinPendiente;

  AccionCombate? accionSeleccionada;
  Set<(int, int)> casillasValidas = {};

  /// Contador monótono por combatiente que dispara la animación de efecto
  /// especial sobre su peón. El identificador del efecto a renderizar se
  /// guarda en [idEfectoEspecialPorCombatiente] y se mapea a un painter
  /// dedicado por `RetratoConEfectosImpacto`.
  final Map<Combatiente, int> contadorEfectoEspecial = {};
  final Map<Combatiente, String> idEfectoEspecialPorCombatiente = {};

  /// Identificadores de habilidad que tienen un efecto visual dedicado.
  /// Si una habilidad no está aquí, el peón usa el slash genérico.
  static const Set<String> habilidadesConEfectoVisual = {
    'laika_mordisco',
    'comisaria_decreto_realidad',
    'comisaria_soneto_demoledor',
    'comisaria_discurso_tedioso',
    'comisaria_cita_reglamentaria',
    'gimnasta_salto_mortal',
    'gimnasta_calistenia',
    'gimnasta_patada_olimpica',
    'ingeniera_sabotaje',
    'ingeniera_caja_inversa',
    'ingeniera_cinta_inmovilizante',
    'samovar_portatil',
  };

  @override
  void initState() {
    super.initState();
    encuentro = obtenerConfiguracionEncuentro(widget.tipoEncuentro);
    enemigos = encuentro.enemigos.map((cfg) {
      final enemigo = cfg.factoria();
      enemigo.posicionFila = cfg.filaInicial;
      enemigo.posicionColumna = cfg.columnaInicial;
      return enemigo;
    }).toList();

    widget.jugador.posicionFila = 1;
    widget.jugador.posicionColumna = 1;

    if (widget.estado.companeroFerruginosaActivo) {
      final aliadoCreado = crearMadreFerruginosaPortatil();
      aliadoCreado.posicionFila = 2;
      aliadoCreado.posicionColumna = 0;
      companeroPortatil = aliadoCreado;
    }

    controladorAmbiental = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    controladorViajeAtaque = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _aplicarBuffsAlIniciarCombate();
    final piezasEquipo = _piezasDeEquipoActivas();
    int bonusPaPorEquipoTotal = 0;
    for (final piezaEquipo in piezasEquipo) {
      if (piezaEquipo.bonusPaInicialCombate > 0) {
        bonusPaPorEquipoTotal += piezaEquipo.bonusPaInicialCombate;
        buffsAplicadosAlIniciar.add(
          '${piezaEquipo.nombre}: +${piezaEquipo.bonusPaInicialCombate} PA inicial.',
        );
      }
    }
    widget.jugador.puntosAccionDisponibles =
        widget.jugador.calcularAPInicialCombate() + bonusPaPorEquipoTotal;
    if (widget.estado.tieneFlag('te_de_madre')) {
      widget.jugador.puntosAccionDisponibles += 2;
      widget.estado.desactivarFlag('te_de_madre');
      widget.estado.activarFlag('te_de_madre_consumido');
      buffsAplicadosAlIniciar.add('Té de Madre Ferruginosa: +2 PA iniciales.');
    }
    if (companeroPortatil != null) {
      buffsAplicadosAlIniciar.add(
        'Madre Ferruginosa portátil te acompaña en este combate.',
      );
    }

    _aplicarBonificacionesDeEquipo();

    _anadirRegistro(encuentro.textoApertura);
    for (final descripcion in buffsAplicadosAlIniciar) {
      _anadirRegistro(descripcion);
    }
    _anadirRegistro(
      'Ronda $numeroRonda · Te corresponde mover. AP disponibles: ${widget.jugador.puntosAccionDisponibles}.',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _disparoBanner('TU TURNO', true);
    });
  }

  int _cuerpoBackupOriginal = 0;
  int _menteBackupOriginal = 0;
  int _carismaBackupOriginal = 0;
  int _armaduraFisicaBackupOriginal = 0;
  int _conviccionBackupOriginal = 0;

  List<ObjetoEquipable> _piezasDeEquipoActivas() {
    final lista = <ObjetoEquipable>[];
    final cabeza = obtenerEquipoPorIdentificador(
      widget.estado.idObjetoCabezaEquipado,
    );
    final arma = obtenerEquipoPorIdentificador(
      widget.estado.idObjetoArmaEquipada,
    );
    final torso = obtenerEquipoPorIdentificador(
      widget.estado.idObjetoTorsoEquipado,
    );
    if (cabeza != null) lista.add(cabeza);
    if (arma != null) lista.add(arma);
    if (torso != null) lista.add(torso);
    return lista;
  }

  void _aplicarBonificacionesDeEquipo() {
    _cuerpoBackupOriginal = widget.jugador.cuerpo;
    _menteBackupOriginal = widget.jugador.mente;
    _carismaBackupOriginal = widget.jugador.carisma;
    _armaduraFisicaBackupOriginal = widget.jugador.armaduraFisica;
    _conviccionBackupOriginal = widget.jugador.conviccion;
    for (final piezaEquipo in _piezasDeEquipoActivas()) {
      widget.jugador.cuerpo += piezaEquipo.bonusCuerpo;
      widget.jugador.mente += piezaEquipo.bonusMente;
      widget.jugador.carisma += piezaEquipo.bonusCarisma;
      widget.jugador.armaduraFisica += piezaEquipo.bonusArmaduraFisica;
      widget.jugador.conviccion += piezaEquipo.bonusConviccion;
    }
  }

  void _revertirBonificacionesDeEquipo() {
    widget.jugador.cuerpo = _cuerpoBackupOriginal;
    widget.jugador.mente = _menteBackupOriginal;
    widget.jugador.carisma = _carismaBackupOriginal;
    widget.jugador.armaduraFisica = _armaduraFisicaBackupOriginal;
    widget.jugador.conviccion = _conviccionBackupOriginal;
  }

  @override
  void dispose() {
    _revertirBonificacionesDeEquipo();
    controladorAmbiental.dispose();
    controladorViajeAtaque.dispose();
    super.dispose();
  }

  void _aplicarBuffsAlIniciarCombate() {
    if (widget.estado.contarObjeto('caja_sin_etiquetar') > 0) {
      buffsAplicadosAlIniciar.add(
        'Llevas la caja oculta: empiezas con la Moral al máximo por concentración.',
      );
      widget.jugador.recuperarMoral(widget.jugador.moralMaxima);
    }
  }

  void _disparoBanner(String texto, bool esJugador) {
    setState(() {
      versionBanner += 1;
      textoBannerActual = texto;
      bannerEsJugador = esJugador;
    });
    final estaVersion = versionBanner;
    Future.delayed(const Duration(milliseconds: 1150), () {
      if (!mounted) return;
      if (estaVersion == versionBanner) {
        setState(() {
          versionBanner = -versionBanner.abs();
        });
      }
    });
  }

  void _anadirRegistro(String texto) {
    setState(() {
      registroCombate.add(texto);
      // Acotar registro: combates largos podrían acumular cientos
      // de entradas. 50 líneas son contexto narrativo de sobra y
      // evitan la lista creciendo sin tope durante un boss largo.
      if (registroCombate.length > 50) {
        registroCombate.removeRange(0, registroCombate.length - 50);
      }
    });
  }

  List<AccionCombate> _construirAccionesDelJugador() {
    final definicion = widget.jugador.clase != null
        ? catalogoClases[widget.jugador.clase!]
        : null;
    final acciones = <AccionCombate>[accionAtaqueBasicoMelee, accionMoverse];
    if (definicion != null) {
      for (final id in definicion.idsHabilidadesClase) {
        final hab = catalogoHabilidades[id];
        if (hab != null) acciones.add(hab);
      }
    }
    acciones.add(utilidadSamovarPortatil);
    if (widget.estado.tieneFlag(flagLaikaAdoptada)) {
      acciones.add(accionLaikaMordisco);
    }
    acciones.add(utilidadEsperar);
    return acciones;
  }

  Combatiente? _enemigoEn(int columna, int fila) {
    for (final enemigo in enemigos) {
      if (!enemigo.sigueEnPie) continue;
      if (enemigo.posicionColumna == columna && enemigo.posicionFila == fila) {
        return enemigo;
      }
    }
    return null;
  }

  bool _casillaOcupada(int columna, int fila) {
    if (widget.jugador.posicionColumna == columna &&
        widget.jugador.posicionFila == fila) {
      return true;
    }
    final aliado = companeroPortatil;
    if (aliado != null &&
        aliado.sigueEnPie &&
        aliado.posicionColumna == columna &&
        aliado.posicionFila == fila) {
      return true;
    }
    return _enemigoEn(columna, fila) != null;
  }

  Combatiente? _enemigoMasCercano(Combatiente origen) {
    Combatiente? mejorCandidato;
    int mejorDistancia = 9999;
    for (final enemigoCandidato in enemigos) {
      if (!enemigoCandidato.sigueEnPie) continue;
      final distanciaCandidato = origen.distanciaA(enemigoCandidato);
      if (distanciaCandidato < mejorDistancia) {
        mejorDistancia = distanciaCandidato;
        mejorCandidato = enemigoCandidato;
      }
    }
    return mejorCandidato;
  }

  Set<(int, int)> _calcularCasillasValidasParaAccion(AccionCombate accion) {
    if (combateFinalizado) return {};
    final resultado = <(int, int)>{};
    final px = widget.jugador.posicionColumna;
    final py = widget.jugador.posicionFila;

    switch (accion.targeting) {
      case TipoTargeting.ningunObjetivo:
        return {};
      case TipoTargeting.casillaLibre:
        for (int fila = 0; fila < filasGrid; fila++) {
          for (int col = 0; col < columnasGrid; col++) {
            final dx = (col - px).abs();
            final dy = (fila - py).abs();
            final distancia = dx > dy ? dx : dy;
            if (distancia >= accion.alcanceMinimo &&
                distancia <= accion.alcanceMaximo &&
                !_casillaOcupada(col, fila)) {
              if (accion.categoria == CategoriaAccion.moverse &&
                  distancia > widget.jugador.puntosAccionDisponibles) {
                continue;
              }
              resultado.add((col, fila));
            }
          }
        }
        return resultado;
      case TipoTargeting.enemigoUnico:
        for (final enemigo in enemigos) {
          if (!enemigo.sigueEnPie) continue;
          final dx = (enemigo.posicionColumna - px).abs();
          final dy = (enemigo.posicionFila - py).abs();
          final distancia = dx > dy ? dx : dy;
          if (distancia >= accion.alcanceMinimo &&
              distancia <= accion.alcanceMaximo) {
            resultado.add((enemigo.posicionColumna, enemigo.posicionFila));
          }
        }
        return resultado;
      case TipoTargeting.cualquierCasilla:
        for (int fila = 0; fila < filasGrid; fila++) {
          for (int col = 0; col < columnasGrid; col++) {
            final dx = (col - px).abs();
            final dy = (fila - py).abs();
            final distancia = dx > dy ? dx : dy;
            if (distancia >= accion.alcanceMinimo &&
                distancia <= accion.alcanceMaximo) {
              resultado.add((col, fila));
            }
          }
        }
        return resultado;
    }
  }

  bool _puedeSeleccionar(AccionCombate accion) {
    if (combateFinalizado || !esTurnoJugador) return false;
    if (accion.costePuntosAccion > widget.jugador.puntosAccionDisponibles) {
      return false;
    }
    if (accion.usosPorCombate > 0) {
      final usos = usosGastados[accion.identificador] ?? 0;
      if (usos >= accion.usosPorCombate) return false;
    }
    return true;
  }

  void _seleccionarAccion(AccionCombate accion) {
    if (!_puedeSeleccionar(accion)) return;
    if (accion.targeting == TipoTargeting.ningunObjetivo) {
      _ejecutarAccionSinObjetivo(accion);
      return;
    }
    setState(() {
      accionSeleccionada = accion;
      casillasValidas = _calcularCasillasValidasParaAccion(accion);
    });
    if (casillasValidas.isEmpty) {
      _anadirRegistro(
        'No hay objetivos válidos en alcance para «${accion.nombre}».',
      );
      setState(() {
        accionSeleccionada = null;
        casillasValidas = {};
      });
    }
  }

  void _cancelarSeleccion() {
    setState(() {
      accionSeleccionada = null;
      casillasValidas = {};
    });
  }

  void _ejecutarAccionSinObjetivo(AccionCombate accion) {
    setState(() {
      widget.jugador.puntosAccionDisponibles -= accion.costePuntosAccion;
      _registrarUso(accion);
    });
    if (accion.curaPuntosVidaPropios > 0) {
      widget.jugador.curar(accion.curaPuntosVidaPropios);
      _anadirRegistro(
        '«${accion.nombre}» → +${accion.curaPuntosVidaPropios} PV.',
      );
    }
    if (accion.curaMoralPropia > 0) {
      widget.jugador.recuperarMoral(accion.curaMoralPropia);
      _anadirRegistro('«${accion.nombre}» → +${accion.curaMoralPropia} Moral.');
    }
    if (accion.identificador == 'gimnasta_calistenia') {
      widget.jugador.aplicarEuforia(turnos: 2);
      _anadirRegistro(
        'La calistenia te deja eufórico: +1 PA al inicio de los próximos turnos.',
      );
    }
    if (accion.categoria == CategoriaAccion.esperar) {
      widget.jugador.puntosAccionDisponibles += 2;
      _anadirRegistro('Respiras hondo: +2 PA, +2 Moral. Cedes el turno.');
      _finalizarTurnoJugador();
    }
  }

  void _registrarUso(AccionCombate accion) {
    if (accion.usosPorCombate <= 0) return;
    usosGastados[accion.identificador] =
        (usosGastados[accion.identificador] ?? 0) + 1;
  }

  void _clickEnCelda(int columna, int fila) {
    if (accionSeleccionada == null) return;
    if (!casillasValidas.contains((columna, fila))) {
      _anadirRegistro('Casilla fuera de alcance.');
      return;
    }
    final accion = accionSeleccionada!;
    _ejecutarAccionConObjetivo(accion, columna, fila);
  }

  void _ejecutarAccionConObjetivo(AccionCombate accion, int columna, int fila) {
    if (accion.categoria == CategoriaAccion.moverse) {
      final dx = (columna - widget.jugador.posicionColumna).abs();
      final dy = (fila - widget.jugador.posicionFila).abs();
      final pasos = dx > dy ? dx : dy;
      setState(() {
        widget.jugador.puntosAccionDisponibles -= pasos;
        widget.jugador.posicionColumna = columna;
        widget.jugador.posicionFila = fila;
        accionSeleccionada = null;
        casillasValidas = {};
      });
      _anadirRegistro('Te desplazas $pasos casilla(s) (−$pasos PA).');
      return;
    }

    setState(() {
      widget.jugador.puntosAccionDisponibles -= accion.costePuntosAccion;
      _registrarUso(accion);
      accionSeleccionada = null;
      casillasValidas = {};
    });

    final objetivosImpactados = <Combatiente>[];
    final objetivoDirecto = _enemigoEn(columna, fila);
    if (objetivoDirecto != null) objetivosImpactados.add(objetivoDirecto);
    if (accion.radioArea > 0) {
      for (final enemigo in enemigos) {
        if (!enemigo.sigueEnPie) continue;
        if (objetivosImpactados.contains(enemigo)) continue;
        final dx = (enemigo.posicionColumna - columna).abs();
        final dy = (enemigo.posicionFila - fila).abs();
        final dist = dx > dy ? dx : dy;
        if (dist <= accion.radioArea) {
          objetivosImpactados.add(enemigo);
        }
      }
    }

    if (accion.curaPuntosVidaPropios > 0) {
      widget.jugador.curar(accion.curaPuntosVidaPropios);
      _anadirRegistro(
        '«${accion.nombre}» → +${accion.curaPuntosVidaPropios} PV (propio).',
      );
    }
    if (accion.curaMoralPropia > 0) {
      widget.jugador.recuperarMoral(accion.curaMoralPropia);
      _anadirRegistro(
        '«${accion.nombre}» → +${accion.curaMoralPropia} Moral (propio).',
      );
    }

    if (objetivosImpactados.isEmpty &&
        accion.targeting == TipoTargeting.cualquierCasilla &&
        accion.aplicaMojar == false) {
      _anadirRegistro(
        'La acción «${accion.nombre}» se aplica al aire vacío. Las ratas se ríen.',
      );
    }

    for (final objetivo in objetivosImpactados) {
      _aplicarDanoYEfectos(accion, objetivo);
    }

    final todosVencidos = enemigos.every((e) => !e.sigueEnPie);
    if (todosVencidos) {
      _finalizarCombateVictoria();
    }
  }

  /// Dispara la animación cosmética de viaje del atacante hacia el objetivo.
  /// El daño se aplica en paralelo (no espera la animación), de modo que el
  /// turno avanza con el tempo de siempre y la animación enriquece sin
  /// bloquear.
  void _dispararViajeDeAtaque(
    Combatiente atacante,
    Combatiente objetivo,
    AccionCombate accion,
  ) {
    _dispararViajePorIdHabilidad(atacante, objetivo, accion.identificador);
  }

  /// Variante usable por la IA enemiga, que no opera con objetos AccionCombate
  /// sino con literales de identificador de habilidad.
  void _dispararViajePorIdHabilidad(
    Combatiente atacante,
    Combatiente objetivo,
    String idHabilidad,
  ) {
    setState(() {
      atacanteEnViaje = atacante;
      objetivoDelViaje = objetivo;
      idHabilidadDelViaje = idHabilidad;
    });
    controladorViajeAtaque.forward(from: 0).then((_) {
      if (!mounted) return;
      setState(() {
        atacanteEnViaje = null;
        objetivoDelViaje = null;
        idHabilidadDelViaje = null;
      });
    });
  }

  void _aplicarDanoYEfectos(AccionCombate accion, Combatiente objetivo) {
    String descripcion = '«${accion.nombre}» → ${objetivo.nombre}: ';
    final detalles = <String>[];

    if (habilidadesConEfectoVisual.contains(accion.identificador)) {
      contadorEfectoEspecial[objetivo] =
          (contadorEfectoEspecial[objetivo] ?? 0) + 1;
      idEfectoEspecialPorCombatiente[objetivo] = accion.identificador;
      if (accion.identificador == 'comisaria_decreto_realidad') {
        audioProcedural.reproducirSelloBurocratico();
      }
    }

    // Viaje cosmético del jugador hacia su objetivo. Se ejecuta para
    // cualquier acción dirigida a un enemigo (habilidad o ataque básico).
    _dispararViajeDeAtaque(widget.jugador, objetivo, accion);

    if (accion.aplicaMojar) {
      objetivo.mojar();
      detalles.add('empapado');
    }

    if (accion.danoBase > 0 || accion.aplicaMojar) {
      int danoFinal = 0;
      switch (accion.tipoDano) {
        case TipoDano.fisico:
          final armadura = accion.ignoraArmaduraFisica || objetivo.empapado
              ? 0
              : objetivo.armaduraFisica;
          danoFinal = math.max(
            1,
            accion.danoBase + (widget.jugador.cuerpo ~/ 2) - armadura,
          );
          objetivo.aplicarDanoFisico(danoFinal);
          detalles.add('$danoFinal físico');
          audioProcedural.reproducirGolpeFisico();
          break;
        case TipoDano.tecnico:
          final armadura = accion.ignoraArmaduraFisica
              ? 0
              : objetivo.armaduraTecnica;
          danoFinal = math.max(
            1,
            accion.danoBase + (widget.jugador.mente ~/ 2) - armadura,
          );
          objetivo.aplicarDanoFisico(danoFinal);
          detalles.add('$danoFinal técnico');
          audioProcedural.reproducirGolpeTecnico();
          break;
        case TipoDano.moral:
          final conviccion = accion.ignoraConviccion ? 0 : objetivo.conviccion;
          danoFinal = math.max(
            1,
            accion.danoBase + (widget.jugador.carisma ~/ 2) - conviccion,
          );
          objetivo.aplicarDanoMoral(danoFinal);
          detalles.add('$danoFinal moral');
          audioProcedural.reproducirGolpeMoral();
          break;
        case TipoDano.ninguno:
          break;
      }
    }

    if (accion.penalizacionPaEnemigo > 0 &&
        accion.turnosPenalizacionPaEnemigo > 0) {
      objetivo.aplicarPenalizacionPa(
        accion.penalizacionPaEnemigo,
        accion.turnosPenalizacionPaEnemigo,
      );
      detalles.add(
        '−${accion.penalizacionPaEnemigo} PA durante ${accion.turnosPenalizacionPaEnemigo}',
      );
    }

    // Forzamos un rebuild para que las barras de PV/Moral del retrato se
    // actualicen al instante. Sin esto, los valores del modelo cambian pero
    // el ticker visual no redibujaría hasta que termine la animación del
    // viaje de ataque, dando la sensación de que la vida no baja.
    setState(() {});

    _anadirRegistro(descripcion + detalles.join(' · '));
  }

  void _finalizarTurnoJugador() {
    if (combateFinalizado) return;
    _ejecutarTurnoCompaneroPortatil();
    if (combateFinalizado) return;
    setState(() {
      esTurnoJugador = false;
      accionSeleccionada = null;
      casillasValidas = {};
    });
    _disparoBanner('TURNO ENEMIGO', false);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _ejecutarTurnoDeEnemigos();
    });
  }

  void _ejecutarTurnoCompaneroPortatil() {
    final aliado = companeroPortatil;
    if (aliado == null || !aliado.sigueEnPie) return;
    final jugador = widget.jugador;
    final ratioVida = jugador.puntosVida / jugador.puntosVidaMaximos;
    if (ratioVida < 0.5 && jugador.puntosVida > 0) {
      const curacion = 4;
      jugador.curar(curacion);
      _anadirRegistro(
        'Madre portátil vierte té reparador: +$curacion PV al cadete.',
      );
      return;
    }
    final blanco = _enemigoMasCercano(aliado);
    if (blanco == null) return;
    final distanciaBlanco = aliado.distanciaA(blanco);
    if (distanciaBlanco > 2) {
      _avanzarCompaneroHacia(aliado, blanco);
      _anadirRegistro('Madre portátil avanza un paso hacia ${blanco.nombre}.');
      return;
    }
    final danoVaporPresion = math.max(
      1,
      3 + (aliado.cuerpo ~/ 2) - blanco.armaduraFisica,
    );
    blanco.aplicarDanoFisico(danoVaporPresion);
    blanco.mojar();
    _anadirRegistro(
      'Madre portátil escupe vapor a presión a ${blanco.nombre}: −$danoVaporPresion PV · empapado.',
    );
    final todosVencidos = enemigos.every((e) => !e.sigueEnPie);
    if (todosVencidos) {
      _finalizarCombateVictoria();
    }
  }

  void _avanzarCompaneroHacia(Combatiente aliado, Combatiente objetivo) {
    final dx = objetivo.posicionColumna - aliado.posicionColumna;
    final dy = objetivo.posicionFila - aliado.posicionFila;
    final nuevaColumna = aliado.posicionColumna + dx.sign;
    final nuevaFila = aliado.posicionFila + dy.sign;
    if (!_casillaOcupada(nuevaColumna, nuevaFila)) {
      aliado.posicionColumna = nuevaColumna;
      aliado.posicionFila = nuevaFila;
    }
  }

  void _ejecutarTurnoDeEnemigos() {
    if (combateFinalizado) return;
    final enemigosOrdenados = enemigos.where((e) => e.sigueEnPie).toList()
      ..sort((a, b) => b.velocidad.compareTo(a.velocidad));
    _ejecutarSiguienteEnemigoEnCadena(enemigosOrdenados, 0);
  }

  void _ejecutarSiguienteEnemigoEnCadena(List<Combatiente> lista, int indice) {
    if (combateFinalizado) return;
    if (indice >= lista.length) {
      _iniciarNuevaRonda();
      return;
    }
    final enemigo = lista[indice];
    if (!enemigo.sigueEnPie) {
      _ejecutarSiguienteEnemigoEnCadena(lista, indice + 1);
      return;
    }
    enemigo.reiniciarPuntosAccion();
    enemigo.tickEstados();
    _iaResolverTurnoDeEnemigo(enemigo);
    if (!widget.jugador.sigueEnPie) {
      _finalizarCombateDerrota();
      return;
    }
    Future.delayed(const Duration(milliseconds: 1350), () {
      if (!mounted) return;
      _ejecutarSiguienteEnemigoEnCadena(lista, indice + 1);
    });
  }

  Combatiente _objetivoMeleePreferido(Combatiente enemigo) {
    final aliado = companeroPortatil;
    if (aliado == null || !aliado.sigueEnPie) return widget.jugador;
    final distanciaAJugador = enemigo.distanciaA(widget.jugador);
    final distanciaAAliado = enemigo.distanciaA(aliado);
    if (distanciaAAliado < distanciaAJugador) return aliado;
    return widget.jugador;
  }

  void _iaResolverTurnoDeEnemigo(Combatiente enemigo) {
    if (enemigo.puntosAccionDisponibles <= 0) {
      _anadirRegistro('${enemigo.nombre} no tiene PA para actuar.');
      return;
    }

    if (enemigo.empapado && enemigo.nombre.contains('Funcionario')) {
      _anadirRegistro(
        '${enemigo.nombre} se seca el sudario y murmura cifras administrativas.',
      );
      return;
    }

    final distancia = enemigo.distanciaA(widget.jugador);

    if (enemigo.nombre.contains('Funcionario')) {
      final alcance = 4;
      if (distancia <= alcance) {
        final dano = math.max(
          1,
          2 + (enemigo.mente ~/ 2) - (widget.jugador.carisma ~/ 2),
        );
        _dispararViajePorIdHabilidad(
          enemigo,
          widget.jugador,
          'comisaria_cita_reglamentaria',
        );
        audioProcedural.reproducirGolpeMoral();
        widget.jugador.aplicarDanoMoral(dano);
        _anadirRegistro(
          '${enemigo.nombre} lanza Citación Reglamentaria. −$dano Moral.',
        );
      } else {
        _moverEnemigoAlejandose(enemigo);
      }
      return;
    }

    if (enemigo.nombre.contains('Rata')) {
      final objetivoMelee = _objetivoMeleePreferido(enemigo);
      if (enemigo.distanciaA(objetivoMelee) <= 1) {
        final dano = math.max(1, 1 + (enemigo.cuerpo ~/ 2));
        _dispararViajePorIdHabilidad(
          enemigo,
          objetivoMelee,
          'ataque_basico_melee',
        );
        audioProcedural.reproducirGolpeFisico();
        objetivoMelee.aplicarDanoFisico(dano);
        _anadirRegistro(
          '${enemigo.nombre} muerde a ${objetivoMelee.nombre}. −$dano PV.',
        );
      } else {
        _moverEnemigoHaciaObjetivo(enemigo, objetivoMelee, pasos: 2);
      }
      return;
    }

    if (enemigo.nombre.contains('Cabo')) {
      final objetivoMelee = _objetivoMeleePreferido(enemigo);
      if (enemigo.distanciaA(objetivoMelee) <= 1) {
        final dano = math.max(1, 3 + (enemigo.cuerpo ~/ 2));
        _dispararViajePorIdHabilidad(
          enemigo,
          objetivoMelee,
          'ataque_basico_melee',
        );
        audioProcedural.reproducirGolpeFisico();
        objetivoMelee.aplicarDanoFisico(dano);
        _anadirRegistro(
          '${enemigo.nombre} golpea con la porra a ${objetivoMelee.nombre}. −$dano PV.',
        );
      } else {
        _moverEnemigoHaciaObjetivo(enemigo, objetivoMelee, pasos: 2);
      }
      return;
    }

    if (enemigo.nombre.contains('Brigada del Sello')) {
      final esVarianteRifle = enemigo.nombre.contains('Rifle');
      final esVariantePunos = enemigo.nombre.contains('Puños');
      final objetivoMelee = _objetivoMeleePreferido(enemigo);
      final int distanciaObjetivo = enemigo.distanciaA(objetivoMelee);
      if (esVarianteRifle) {
        // Tirador: prefiere disparar a distancia de 3 a 6. Si está
        // demasiado cerca, retrocede; si está demasiado lejos, avanza
        // lo justo para entrar en rango.
        if (distanciaObjetivo >= 3 && distanciaObjetivo <= 6) {
          final dano = math.max(1, 2 + (enemigo.mente ~/ 2));
          _dispararViajePorIdHabilidad(
            enemigo,
            objetivoMelee,
            'ataque_basico_distancia',
          );
          audioProcedural.reproducirGolpeFisico();
          objetivoMelee.aplicarDanoFisico(dano);
          _anadirRegistro(
            '${enemigo.nombre} dispara un sello a quemarropa contra ${objetivoMelee.nombre}. −$dano PV.',
          );
        } else if (distanciaObjetivo < 3) {
          _moverEnemigoAlejandose(enemigo);
        } else {
          _moverEnemigoHaciaObjetivo(enemigo, objetivoMelee, pasos: 2);
        }
      } else if (esVariantePunos) {
        // Variante a puño: corre más y pega rápido pero menos.
        if (distanciaObjetivo <= 1) {
          final dano = math.max(1, 2 + (enemigo.cuerpo ~/ 2));
          _dispararViajePorIdHabilidad(
            enemigo,
            objetivoMelee,
            'ataque_basico_melee',
          );
          audioProcedural.reproducirGolpeFisico();
          objetivoMelee.aplicarDanoFisico(dano);
          _anadirRegistro(
            '${enemigo.nombre} descarga dos puñetazos secos en ${objetivoMelee.nombre}. −$dano PV.',
          );
        } else {
          _moverEnemigoHaciaObjetivo(enemigo, objetivoMelee, pasos: 3);
        }
      } else {
        // Variante con garrote: tanque, pega fuerte pero lento.
        if (distanciaObjetivo <= 1) {
          final dano = math.max(2, 4 + (enemigo.cuerpo ~/ 2));
          _dispararViajePorIdHabilidad(
            enemigo,
            objetivoMelee,
            'ataque_basico_melee',
          );
          audioProcedural.reproducirGolpeFisico();
          objetivoMelee.aplicarDanoFisico(dano);
          _anadirRegistro(
            '${enemigo.nombre} estampa el garrote sobre ${objetivoMelee.nombre}. −$dano PV.',
          );
        } else {
          _moverEnemigoHaciaObjetivo(enemigo, objetivoMelee, pasos: 2);
        }
      }
      return;
    }

    if (enemigo.nombre.contains('Auxiliar')) {
      if (distancia <= 4) {
        final dano = math.max(
          1,
          1 + (enemigo.mente ~/ 2) - (widget.jugador.mente ~/ 2),
        );
        _dispararViajePorIdHabilidad(
          enemigo,
          widget.jugador,
          'comisaria_discurso_tedioso',
        );
        audioProcedural.reproducirGolpeMoral();
        widget.jugador.aplicarDanoMoral(dano);
        widget.jugador.aplicarPenalizacionPa(1, 1);
        _anadirRegistro(
          '${enemigo.nombre} dicta un Trámite Suspensivo: −$dano Moral, −1 PA próximo turno.',
        );
      } else {
        _moverEnemigoAlejandose(enemigo);
      }
      return;
    }

    if (enemigo.nombre.contains('Marciano')) {
      if (distancia <= 5) {
        final dano = math.max(
          1,
          2 + (enemigo.carisma ~/ 2) - (widget.jugador.carisma ~/ 2),
        );
        _dispararViajePorIdHabilidad(
          enemigo,
          widget.jugador,
          'comisaria_cita_reglamentaria',
        );
        audioProcedural.reproducirGolpeMoral();
        widget.jugador.aplicarDanoMoral(dano);
        _anadirRegistro(
          '${enemigo.nombre} alza una papeleta de "moción contra el camarada": −$dano Moral.',
        );
      } else {
        _moverEnemigoHaciaObjetivo(enemigo, widget.jugador, pasos: 1);
      }
      return;
    }

    if (enemigo.nombre.contains('Alcalde')) {
      if (distancia <= 6) {
        final danoMoral = math.max(
          1,
          3 + (enemigo.carisma ~/ 2) - (widget.jugador.carismaEfectivo ~/ 2),
        );
        _dispararViajePorIdHabilidad(
          enemigo,
          widget.jugador,
          'comisaria_soneto_demoledor',
        );
        audioProcedural.reproducirGolpeMoral();
        widget.jugador.aplicarDanoMoral(danoMoral);
        widget.jugador.aplicarPenalizacionPa(1, 2);
        widget.jugador.intimidar(turnos: 2);
        _anadirRegistro(
          '${enemigo.nombre} golpea el martillo de asamblea: −$danoMoral Moral, −1 PA durante 2 turnos, intimidado.',
        );
      } else {
        _moverEnemigoAlejandose(enemigo);
      }
      return;
    }

    if (enemigo.nombre.contains('Burócrata Congelado')) {
      final objetivoMelee = _objetivoMeleePreferido(enemigo);
      if (enemigo.distanciaA(objetivoMelee) <= 1) {
        final dano = math.max(
          1,
          2 + (enemigo.cuerpo ~/ 2) - objetivoMelee.armaduraFisica,
        );
        _dispararViajePorIdHabilidad(
          enemigo,
          objetivoMelee,
          'comisaria_decreto_realidad',
        );
        audioProcedural.reproducirSelloBurocratico();
        objetivoMelee.aplicarDanoFisico(dano);
        _anadirRegistro(
          '${enemigo.nombre} planta un sello escarchado en ${objetivoMelee.nombre}: −$dano PV.',
        );
      } else {
        _moverEnemigoHaciaObjetivo(enemigo, objetivoMelee, pasos: 1);
      }
      return;
    }

    if (enemigo.nombre.contains('Jefe de Recepción')) {
      if (distancia <= 4) {
        final danoMoral = math.max(
          1,
          2 + (enemigo.mente ~/ 2) - (widget.jugador.mente ~/ 2),
        );
        _dispararViajePorIdHabilidad(
          enemigo,
          widget.jugador,
          'comisaria_discurso_tedioso',
        );
        audioProcedural.reproducirGolpeMoral();
        widget.jugador.aplicarDanoMoral(danoMoral);
        widget.jugador.aplicarPenalizacionPa(1, 1);
        _anadirRegistro(
          '${enemigo.nombre} dicta una "denegación administrativa por congelación": −$danoMoral Moral, −1 PA próximo turno.',
        );
      } else {
        _moverEnemigoAlejandose(enemigo);
      }
      return;
    }

    if (enemigo.nombre.contains('Delegado Sindical')) {
      if (distancia <= 5) {
        final danoMoral = math.max(
          1,
          3 + (enemigo.carisma ~/ 2) - (widget.jugador.carisma ~/ 2),
        );
        _dispararViajePorIdHabilidad(
          enemigo,
          widget.jugador,
          'comisaria_soneto_demoledor',
        );
        audioProcedural.reproducirGolpeMoral();
        widget.jugador.aplicarDanoMoral(danoMoral);
        widget.jugador.aplicarPenalizacionPa(2, 1);
        _anadirRegistro(
          '${enemigo.nombre} convoca una huelga relámpago: −$danoMoral Moral, −2 PA próximo turno.',
        );
      } else {
        _moverEnemigoAlejandose(enemigo);
      }
      return;
    }

    if (enemigo.nombre.contains('Inspector Sindical')) {
      final objetivoMelee = _objetivoMeleePreferido(enemigo);
      if (enemigo.distanciaA(objetivoMelee) <= 1) {
        final dano = math.max(
          1,
          3 + (enemigo.cuerpo ~/ 2) - objetivoMelee.armaduraFisica,
        );
        _dispararViajePorIdHabilidad(
          enemigo,
          objetivoMelee,
          'ataque_basico_melee',
        );
        audioProcedural.reproducirGolpeFisico();
        objetivoMelee.aplicarDanoFisico(dano);
        _anadirRegistro(
          '${enemigo.nombre} aplica un "expediente disciplinario" a ${objetivoMelee.nombre}: −$dano PV.',
        );
      } else {
        _moverEnemigoHaciaObjetivo(enemigo, objetivoMelee, pasos: 2);
      }
      return;
    }

    if (enemigo.nombre.contains('Espectro de Directorskov')) {
      final usoAleatorio = aleatorio.nextDouble();
      if (usoAleatorio < 0.5) {
        final danoMoral = math.max(
          1,
          5 + (enemigo.carisma ~/ 2) - widget.jugador.conviccion,
        );
        _dispararViajePorIdHabilidad(
          enemigo,
          widget.jugador,
          'comisaria_decreto_realidad',
        );
        audioProcedural.reproducirGolpeMoral();
        widget.jugador.aplicarDanoMoral(danoMoral);
        widget.jugador.intimidar(turnos: 3);
        _anadirRegistro(
          '${enemigo.nombre} recita el manifiesto del miércoles: −$danoMoral Moral, intimidado durante 3 turnos.',
        );
      } else {
        final danoTecnico = math.max(
          1,
          4 + (enemigo.mente ~/ 2) - widget.jugador.armaduraTecnica,
        );
        _dispararViajePorIdHabilidad(
          enemigo,
          widget.jugador,
          'ingeniera_sabotaje',
        );
        audioProcedural.reproducirGolpeTecnico();
        widget.jugador.aplicarDanoFisico(danoTecnico);
        widget.jugador.aplicarPenalizacionPa(2, 1);
        _anadirRegistro(
          '${enemigo.nombre} oscila el botón espectral: −$danoTecnico PV, −2 PA próximo turno.',
        );
      }
      return;
    }

    if (enemigo.nombre.contains('Sombra de Cosmonauta')) {
      final objetivoMelee = _objetivoMeleePreferido(enemigo);
      if (enemigo.distanciaA(objetivoMelee) <= 1) {
        final dano = math.max(
          1,
          2 + (enemigo.cuerpo ~/ 2) - objetivoMelee.armaduraFisica,
        );
        _dispararViajePorIdHabilidad(
          enemigo,
          objetivoMelee,
          'ataque_basico_melee',
        );
        audioProcedural.reproducirGolpeFisico();
        objetivoMelee.aplicarDanoFisico(dano);
        _anadirRegistro(
          '${enemigo.nombre} susurra "todavía estamos abajo" y golpea a ${objetivoMelee.nombre}: −$dano PV.',
        );
      } else {
        _moverEnemigoHaciaObjetivo(enemigo, objetivoMelee, pasos: 2);
      }
      return;
    }

    _anadirRegistro('${enemigo.nombre} pasa el turno.');
  }

  void _moverEnemigoHaciaObjetivo(
    Combatiente enemigo,
    Combatiente objetivo, {
    int pasos = 1,
  }) {
    int restantes = pasos;
    while (restantes > 0 && enemigo.distanciaA(objetivo) > 1) {
      final dx = objetivo.posicionColumna - enemigo.posicionColumna;
      final dy = objetivo.posicionFila - enemigo.posicionFila;
      final nuevoCol = enemigo.posicionColumna + dx.sign;
      final nuevoFila = enemigo.posicionFila + dy.sign;
      if (_casillaOcupada(nuevoCol, nuevoFila)) {
        break;
      }
      enemigo.posicionColumna = nuevoCol;
      enemigo.posicionFila = nuevoFila;
      restantes -= 1;
    }
    _anadirRegistro(
      '${enemigo.nombre} avanza hacia ${objetivo.nombre} (${pasos - restantes} casilla(s)).',
    );
  }

  void _moverEnemigoAlejandose(Combatiente enemigo) {
    final dx = enemigo.posicionColumna - widget.jugador.posicionColumna;
    final nuevoCol = (enemigo.posicionColumna + dx.sign).clamp(
      0,
      columnasGrid - 1,
    );
    if (!_casillaOcupada(nuevoCol, enemigo.posicionFila) &&
        nuevoCol != enemigo.posicionColumna) {
      enemigo.posicionColumna = nuevoCol;
      _anadirRegistro('${enemigo.nombre} retrocede para mantener distancia.');
    } else {
      _anadirRegistro('${enemigo.nombre} no encuentra dónde retroceder.');
    }
  }

  void _iniciarNuevaRonda() {
    if (combateFinalizado) return;
    setState(() {
      numeroRonda += 1;
      esTurnoJugador = true;
    });
    _disparoBanner('TU TURNO', true);
    _anadirRegistro(
      'Ronda $numeroRonda · Tu turno. AP disponibles: ${widget.jugador.puntosAccionDisponibles}.',
    );
  }

  void _finalizarCombateVictoria() {
    final cantidadXp = encuentro.xpRecompensa;
    final identificadorBotin = encuentro.idObjetoBotin;
    final yaTeniaBotin =
        identificadorBotin != null &&
        widget.estado.contarObjeto(identificadorBotin) > 0;
    widget.estado.otorgarExperiencia(cantidadXp);
    if (identificadorBotin != null && !yaTeniaBotin) {
      widget.estado.anadirObjeto(identificadorBotin);
    }
    xpRecompensaPendiente = cantidadXp;
    idBotinPendiente = (identificadorBotin != null && !yaTeniaBotin)
        ? identificadorBotin
        : null;
    setState(() {
      combateFinalizado = true;
      victoriaJugador = true;
      accionSeleccionada = null;
      casillasValidas = {};
    });
    _anadirRegistro(encuentro.textoVictoria);
    _anadirRegistro('Recompensa: +$cantidadXp XP.');
    if (idBotinPendiente != null) {
      _anadirRegistro('Botín recibido: ${_traducirBotin(idBotinPendiente!)}.');
    }
    audioProcedural.reproducirFanfarriaVictoria();
  }

  String _traducirBotin(String idObjeto) {
    final equipoBotin = obtenerEquipoPorIdentificador(idObjeto);
    if (equipoBotin != null) return equipoBotin.nombre;
    return idObjeto;
  }

  void _finalizarCombateDerrota() {
    setState(() {
      combateFinalizado = true;
      victoriaJugador = false;
      accionSeleccionada = null;
      casillasValidas = {};
    });
    _anadirRegistro(encuentro.textoDerrota);
    audioProcedural.reproducirDoblesCampanasDerrota();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoPapelViejo(
        child: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _construirEncabezado(),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 6, child: _construirTablero()),
                          const SizedBox(width: 14),
                          Expanded(flex: 4, child: _construirColumnaDerecha()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _construirRegistro(),
                    const SizedBox(height: 8),
                    if (combateFinalizado) _construirControlesFin(),
                  ],
                ),
              ),
            ),
            if (versionBanner > 0)
              Positioned.fill(
                child: BannerDeTurno(
                  key: ValueKey(versionBanner),
                  texto: textoBannerActual,
                  esJugador: bannerEsJugador,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _construirEncabezado() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'COMBATE · RONDA $numeroRonda',
          style: TipografiaPropaganda.tituloSeccion.copyWith(fontSize: 22),
        ),
        Row(
          children: [
            Text('PA: ', style: TipografiaPropaganda.etiquetaBurocratica),
            Text(
              '${widget.jugador.puntosAccionDisponibles}',
              style: TipografiaPropaganda.numeroStat,
            ),
            const SizedBox(width: 16),
            Text(
              esTurnoJugador ? 'TURNO DEL CAMARADA' : 'TURNO DEL ENEMIGO',
              style: TipografiaPropaganda.etiquetaBurocratica.copyWith(
                color: esTurnoJugador
                    ? PaletaCosmoSovietica.rojoOficial
                    : PaletaCosmoSovietica.tintaTenue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _construirTablero() {
    return LayoutBuilder(
      builder: (contexto, restricciones) {
        final maxAncho = restricciones.maxWidth;
        final maxAlto = restricciones.maxHeight;
        final ladoCelda = maxAncho / columnasGrid < maxAlto / filasGrid
            ? maxAncho / columnasGrid
            : maxAlto / filasGrid;
        final anchoTotal = ladoCelda * columnasGrid;
        final altoTotal = ladoCelda * filasGrid;
        return Center(
          child: AnimatedBuilder(
            animation: controladorAmbiental,
            builder: (contexto, hijo) {
              final pulsoMarco =
                  math.sin(controladorAmbiental.value * math.pi * 2) * 0.5 +
                  0.5;
              final colorMarco = esTurnoJugador && !combateFinalizado
                  ? Color.lerp(
                      PaletaCosmoSovietica.tintaNegra,
                      PaletaCosmoSovietica.rojoOficial,
                      0.4 + pulsoMarco * 0.6,
                    )!
                  : PaletaCosmoSovietica.tintaNegra;
              final grosorMarco = esTurnoJugador && !combateFinalizado
                  ? 3.0 + pulsoMarco * 2.0
                  : 3.0;
              return Container(
                width: anchoTotal,
                height: altoTotal,
                decoration: BoxDecoration(
                  color: PaletaCosmoSovietica.papelSombra,
                  border: Border.all(color: colorMarco, width: grosorMarco),
                ),
                child: hijo,
              );
            },
            child: Stack(
              children: [
                // Fondo PNG del tablero de combate (suelo cuadriculado
                // pintado a rotulador). El painter procedimental queda
                // ENCIMA para las líneas del grid, la mitad jugador vs
                // enemigo y los efectos de la fase ambiental.
                const Positioned.fill(
                  child: Image(
                    image: AssetImage(
                      'assets/images/fondo_tablero_combate.png',
                    ),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: controladorAmbiental,
                    builder: (contexto, _) => CustomPaint(
                      painter: PintorSueloTablero(
                        columnas: columnasGrid,
                        filas: filasGrid,
                        columnasJugador: 3,
                        fase: controladorAmbiental.value,
                      ),
                    ),
                  ),
                ),
                for (int fila = 0; fila < filasGrid; fila++)
                  for (int col = 0; col < columnasGrid; col++)
                    Positioned(
                      left: col * ladoCelda,
                      top: fila * ladoCelda,
                      width: ladoCelda,
                      height: ladoCelda,
                      child: _construirCeldaTablero(col, fila, ladoCelda),
                    ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  left: widget.jugador.posicionColumna * ladoCelda,
                  top: widget.jugador.posicionFila * ladoCelda,
                  width: ladoCelda,
                  height: ladoCelda,
                  child: IgnorePointer(child: _construirPeonJugador(ladoCelda)),
                ),
                if (companeroPortatil != null)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    left: companeroPortatil!.posicionColumna * ladoCelda,
                    top: companeroPortatil!.posicionFila * ladoCelda,
                    width: ladoCelda,
                    height: ladoCelda,
                    child: IgnorePointer(
                      child: _construirPeonCompanero(
                        companeroPortatil!,
                        ladoCelda,
                      ),
                    ),
                  ),
                for (final enemigo in enemigos)
                  AnimatedPositioned(
                    key: ValueKey('enemigo_${enemigo.hashCode}'),
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    left: enemigo.posicionColumna * ladoCelda,
                    top: enemigo.posicionFila * ladoCelda,
                    width: ladoCelda,
                    height: ladoCelda,
                    child: IgnorePointer(
                      child: _construirPeonEnemigo(enemigo, ladoCelda),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _construirCeldaTablero(int columna, int fila, double lado) {
    final esValida = casillasValidas.contains((columna, fila));
    return GestureDetector(
      onTap: () {
        if (combateFinalizado) return;
        if (esValida) _clickEnCelda(columna, fila);
      },
      child: MouseRegion(
        cursor: esValida ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: AnimatedBuilder(
          animation: controladorAmbiental,
          builder: (contexto, _) {
            final faseGlobal = controladorAmbiental.value;
            final pulso = math.sin(faseGlobal * math.pi * 2) * 0.4 + 0.6;
            final alfaResaltado = esValida ? pulso : 0.0;
            return Container(
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: esValida
                    ? PaletaCosmoSovietica.rojoOficial.withValues(
                        alpha: alfaResaltado * 0.18,
                      )
                    : Colors.transparent,
                border: Border.all(
                  color: esValida
                      ? PaletaCosmoSovietica.rojoOficial.withValues(
                          alpha: alfaResaltado * 0.85,
                        )
                      : PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.18),
                  width: esValida ? 1.8 : 1,
                ),
              ),
              child: esValida
                  ? CustomPaint(
                      painter: _PintorCursorObjetivo(
                        fase: faseGlobal,
                        desfaseCelda: (columna * 0.13 + fila * 0.27) % 1.0,
                      ),
                    )
                  : null,
            );
          },
        ),
      ),
    );
  }

  /// Curva del viaje cosmético: el peón avanza un 75% del camino hacia el
  /// objetivo, se queda con leve agitación durante el peak (transformación
  /// visible) y vuelve a su posición original. Devuelve la fracción
  /// (0..0.75) en función de la fase del controlador.
  double _curvaFraccionViaje(double t) {
    if (t < 0.32) {
      final fragmentoAvance = t / 0.32;
      // Aceleración suave hacia el objetivo.
      return 0.75 * (1.0 - (1.0 - fragmentoAvance) * (1.0 - fragmentoAvance));
    }
    if (t < 0.62) {
      // Peak: pequeña vibración alrededor de 0.75.
      final fragmentoPeak = (t - 0.32) / 0.30;
      return 0.75 + math.sin(fragmentoPeak * math.pi * 3) * 0.03;
    }
    final fragmentoRegreso = (t - 0.62) / 0.38;
    return 0.75 * (1.0 - fragmentoRegreso) * (1.0 - fragmentoRegreso);
  }

  /// Envoltura común para todos los peones que aplica la animación de viaje
  /// y reemplaza el sprite por una transformación cómica durante el peak.
  Widget _envolverConViajeDeAtaque({
    required Combatiente combatiente,
    required double lado,
    required Widget hijoBase,
    required Widget Function(double faseTransformacion)
    constructorTransformacion,
  }) {
    return AnimatedBuilder(
      animation: controladorViajeAtaque,
      builder: (contexto, _) {
        if (atacanteEnViaje != combatiente || objetivoDelViaje == null) {
          return hijoBase;
        }
        final fase = controladorViajeAtaque.value;
        final fraccionDesplazamiento = _curvaFraccionViaje(fase);
        final desplazamientoColumnas =
            (objetivoDelViaje!.posicionColumna - combatiente.posicionColumna)
                .toDouble();
        final desplazamientoFilas =
            (objetivoDelViaje!.posicionFila - combatiente.posicionFila)
                .toDouble();
        final offsetViaje = Offset(
          desplazamientoColumnas * lado * fraccionDesplazamiento,
          desplazamientoFilas * lado * fraccionDesplazamiento,
        );
        final estaEnPeak = fase > 0.34 && fase < 0.6;
        final hijoActual = estaEnPeak
            ? constructorTransformacion(((fase - 0.34) / 0.26).clamp(0.0, 1.0))
            : hijoBase;
        return Transform.translate(offset: offsetViaje, child: hijoActual);
      },
    );
  }

  /// Devuelve el sprite base del cadete en combate. Capas en orden de
  /// preferencia:
  /// 1. **Sprite atlas completo por clase** (`cadete_[clase]_combate.png`):
  ///    cuando no hay ningún equipo equipado, ni está derrotado. Es el más
  ///    expresivo y conserva los rasgos faciales del retrato oficial.
  /// 2. **Stick figure + cabeza PNG superpuesta**: cuando hay clase y NO
  ///    hay sombrero (aunque sí pueda haber arma o torso). El cuerpo se
  ///    pinta con `dibujarCabeza: false` para que la cabeza por clase se
  ///    superponga sin solaparse.
  /// 3. **Stick figure completo**: el sombrero equipado, la pose derrotada
  ///    o las clases sin retrato dependen del painter procedimental para
  ///    quedar bien.
  Widget _construirSpriteBaseCadeteCombate(PoseStickFigure pose) {
    final claseJugador = widget.jugador.clase;
    final String? idSombrero = widget.estado.idObjetoCabezaEquipado;
    final String? idArma = widget.estado.idObjetoArmaEquipada;
    final String? idTorso = widget.estado.idObjetoTorsoEquipado;
    final bool tieneSombrero = idSombrero != null && idSombrero.isNotEmpty;
    final bool tieneArma = idArma != null && idArma.isNotEmpty;
    final bool tieneTorso = idTorso != null && idTorso.isNotEmpty;
    final bool puedeUsarSpriteAtlas =
        claseJugador != null &&
        !tieneSombrero &&
        !tieneArma &&
        !tieneTorso &&
        pose != PoseStickFigure.derrotado;
    if (puedeUsarSpriteAtlas) {
      return SpriteClaseCadete(
        clase: claseJugador,
        estado: EstadoSpriteClase.combate,
      );
    }
    final bool usarCabezaPng =
        claseJugador != null && pose != PoseStickFigure.derrotado;
    final Widget cuerpo = CustomPaint(
      painter: PintorStickFigure(
        clase: claseJugador,
        pose: pose,
        idSombreroEquipado: idSombrero,
        idArmaEquipada: idArma,
        idTorsoEquipado: idTorso,
        dibujarCabeza: !usarCabezaPng,
      ),
    );
    if (!usarCabezaPng) return cuerpo;
    return LayoutBuilder(
      builder: (contextoLayout, restricciones) {
        final double alto = restricciones.maxHeight;
        final double unidad = alto / 14.0;
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned.fill(child: cuerpo),
            Positioned(
              top: -unidad * 1.0,
              width: unidad * 6.8,
              height: unidad * 7.4,
              child: Image.asset(
                rutaCabezaCadete(claseJugador),
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            if (tieneSombrero)
              Positioned.fill(
                child: CustomPaint(
                  painter: PintorStickFigure(
                    clase: claseJugador,
                    pose: pose,
                    idSombreroEquipado: idSombrero,
                    soloSombrero: true,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _construirPeonJugador(double lado) {
    final pose = combateFinalizado && !victoriaJugador
        ? PoseStickFigure.derrotado
        : PoseStickFigure.combateListo;
    // Animaciones de habilidad del cadete: cada habilidad
    // identificada por su `idHabilidadDelViaje` mapea a un set de 3
    // frames PNG superpuesto al stick figure, sincronizado con el
    // progreso del viaje de ataque (1800ms / 3 frames).
    final bool jugadorViajando = atacanteEnViaje == widget.jugador;
    // §10.13.1 — Decreto Burocrático
    final bool ejecutandoDecreto =
        jugadorViajando && idHabilidadDelViaje == 'comisaria_decreto_realidad';
    // §10.13.2 — Grito Marcial (soneto demoledor)
    final bool ejecutandoGrito =
        jugadorViajando && idHabilidadDelViaje == 'comisaria_soneto_demoledor';
    // §10.13.3 — Sabotaje Técnico
    final bool ejecutandoSabotaje =
        jugadorViajando && idHabilidadDelViaje == 'ingeniera_sabotaje';
    // §10.3.2 — Laika mordisco (overlay PNG sobre el cadete: Laika
    // salta del bolsillo y muerde al enemigo). Sólo disponible si
    // Laika ya ha sido adoptada (ver `accionLaikaMordisco`).
    final bool ejecutandoLaikaMordisco =
        jugadorViajando && idHabilidadDelViaje == 'laika_mordisco';
    // Prefijo del nombre de archivo según habilidad activa, o null
    // si el jugador no está canalizando ninguna animada.
    final String? prefijoFramesHabilidad = ejecutandoDecreto
        ? 'cadete_sello_decreto'
        : ejecutandoGrito
        ? 'cadete_grito_marcial'
        : ejecutandoSabotaje
        ? 'cadete_sabotaje'
        : ejecutandoLaikaMordisco
        ? 'laika_mordisco'
        : null;
    final hijoBase = Padding(
      padding: EdgeInsets.all(lado * 0.08),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                RetratoConEfectosImpacto(
                  puntosVida: widget.jugador.puntosVida,
                  moral: widget.jugador.moral,
                  resaltarDerrota: combateFinalizado && !victoriaJugador,
                  anchoMaximo: lado * 0.9,
                  relacionAspectoAlto: 1.0,
                  contenido: _construirSpriteBaseCadeteCombate(pose),
                ),
                if (prefijoFramesHabilidad != null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: controladorViajeAtaque,
                        builder: (contexto, _) {
                          final double progreso = controladorViajeAtaque.value;
                          final int indiceFrame = progreso < 0.34
                              ? 1
                              : (progreso < 0.67 ? 2 : 3);
                          return Image.asset(
                            'assets/images/${prefijoFramesHabilidad}_f0$indiceFrame.png',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          );
                        },
                      ),
                    ),
                  ),
                // Overlay de daño: 2 frames §10.14 que aparecen
                // brevemente cuando el cadete pierde PV o moral.
                Positioned.fill(
                  child: IgnorePointer(
                    child: _OverlayDanoCadete(
                      puntosVida: widget.jugador.puntosVida,
                      moral: widget.jugador.moral,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: OverlayEstadosPeon(
                    combatiente: widget.jugador,
                    controladorFase: controladorAmbiental,
                  ),
                ),
              ],
            ),
          ),
          SombraPeon(ancho: lado * 0.5),
        ],
      ),
    );
    return _envolverConViajeDeAtaque(
      combatiente: widget.jugador,
      lado: lado,
      hijoBase: hijoBase,
      constructorTransformacion: (faseTransformacion) => Padding(
        padding: EdgeInsets.all(lado * 0.08),
        child: Column(
          children: [
            Expanded(
              child: CustomPaint(
                painter: PintorTransformacionAtaque(
                  identificadorHabilidad: idHabilidadDelViaje ?? 'default',
                  faseTransformacion: faseTransformacion,
                ),
              ),
            ),
            SombraPeon(ancho: lado * 0.5),
          ],
        ),
      ),
    );
  }

  Widget _construirPeonCompanero(Combatiente aliado, double lado) {
    return Padding(
      padding: EdgeInsets.all(lado * 0.1),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                RetratoConEfectosImpacto(
                  puntosVida: aliado.puntosVida,
                  moral: aliado.moral,
                  resaltarDerrota: !aliado.sigueEnPie,
                  anchoMaximo: lado * 0.8,
                  relacionAspectoAlto: 1.0,
                  contenido: AnimatedBuilder(
                    animation: controladorAmbiental,
                    builder: (contexto, _) {
                      // Pequeño burbujeo: oscilación vertical sutil para
                      // que el sprite de Madre Ferruginosa portátil no
                      // parezca pegado al tablero.
                      final double fase = controladorAmbiental.value;
                      final double desplazamientoY =
                          math.sin(fase * math.pi * 2) * 1.8;
                      final Widget retratoPng = const Image(
                        image: AssetImage(
                          'assets/svg/combate_madre_portatil.png',
                        ),
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      );
                      final Widget retratoConBurbujeo = Transform.translate(
                        offset: Offset(0, desplazamientoY),
                        child: retratoPng,
                      );
                      if (aliado.sigueEnPie) return retratoConBurbujeo;
                      // Si está derrotada, lo desaturamos y oscurecemos.
                      return Opacity(
                        opacity: 0.45,
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.matrix(<double>[
                            0.33,
                            0.33,
                            0.33,
                            0,
                            0,
                            0.33,
                            0.33,
                            0.33,
                            0,
                            0,
                            0.33,
                            0.33,
                            0.33,
                            0,
                            0,
                            0,
                            0,
                            0,
                            1,
                            0,
                          ]),
                          child: retratoConBurbujeo,
                        ),
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: OverlayEstadosPeon(
                    combatiente: aliado,
                    controladorFase: controladorAmbiental,
                  ),
                ),
                Positioned(
                  top: -8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      color: PaletaCosmoSovietica.rojoOficial,
                      child: const Text(
                        'PARDNER',
                        style: TextStyle(
                          fontFamily: TipografiaPropaganda.familiaMonoespaciada,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: PaletaCosmoSovietica.papelViejo,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SombraPeon(ancho: lado * 0.45),
        ],
      ),
    );
  }

  Widget _construirPeonEnemigo(Combatiente enemigo, double lado) {
    final esFantasma = enemigo.nombre.contains('Funcionario');
    final esCabo = enemigo.nombre.contains('Cabo');
    final esRata = enemigo.nombre.contains('Rata');
    final esAuxiliar = enemigo.nombre.contains('Auxiliar');
    final esBrigadistaSello = enemigo.nombre.contains('Brigada del Sello');
    final esMarciano = enemigo.nombre.contains('Marciano');
    final esAlcalde = enemigo.nombre.contains('Alcalde');
    final esBurocrataCongelado = enemigo.nombre.contains('Burócrata Congelado');
    final esJefeRecepcion = enemigo.nombre.contains('Jefe de Recepción');
    final esDelegadoSindical = enemigo.nombre.contains('Delegado Sindical');
    final esInspectorSindical = enemigo.nombre.contains('Inspector Sindical');
    final esEspectroDirectorskov = enemigo.nombre.contains(
      'Espectro de Directorskov',
    );
    final esSombraCosmonauta = enemigo.nombre.contains('Sombra de Cosmonauta');

    Widget contenido;
    if (esBrigadistaSello) {
      // Una de las tres variantes de la Brigada del Sello: la imagen
      // se elige por el sufijo del nombre.
      final String rutaSprite;
      if (enemigo.nombre.contains('Rifle')) {
        rutaSprite = 'assets/images/brigada_sello_rifle.png';
      } else if (enemigo.nombre.contains('Puños')) {
        rutaSprite = 'assets/images/brigada_sello_punos.png';
      } else {
        rutaSprite = 'assets/images/brigada_sello_garrote.png';
      }
      contenido = AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: enemigo.sigueEnPie ? 1.0 : 0.45,
        child: Image.asset(
          rutaSprite,
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
          filterQuality: FilterQuality.high,
        ),
      );
    } else if (esFantasma) {
      // Funcionario Espectral con sprite PNG (sale del archivador,
      // cuerpo etéreo con líneas onduladas). Mantenemos la elevación
      // rítmica del original con un Transform.translate amortiguado.
      contenido = AnimatedBuilder(
        animation: controladorAmbiental,
        builder: (contexto, hijo) {
          final double fase = controladorAmbiental.value;
          final double oscilacionY = math.sin(fase * math.pi * 2) * 6;
          return Transform.translate(
            offset: Offset(0, oscilacionY),
            child: hijo,
          );
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          opacity: enemigo.sigueEnPie ? 0.92 : 0.30,
          child: Image.asset(
            'assets/svg/npc_funcionario_espectral.png',
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
            filterQuality: FilterQuality.high,
          ),
        ),
      );
    } else if (esCabo) {
      contenido = AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: enemigo.sigueEnPie ? 1.0 : 0.45,
        child: Image.asset(
          'assets/svg/npc_cabo_inspeccion.png',
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
          filterQuality: FilterQuality.high,
        ),
      );
    } else if (esRata) {
      contenido = AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: enemigo.sigueEnPie ? 1.0 : 0.45,
        child: Image.asset(
          'assets/svg/combate_rata_mutada.png',
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
          filterQuality: FilterQuality.high,
        ),
      );
    } else if (esAuxiliar) {
      contenido = AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: enemigo.sigueEnPie ? 1.0 : 0.45,
        child: Image.asset(
          'assets/svg/combate_auxiliar_burocratico.png',
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
          filterQuality: FilterQuality.high,
        ),
      );
    } else if (esMarciano || esAlcalde) {
      contenido = AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: enemigo.sigueEnPie ? 1.0 : 0.45,
        child: Image.asset(
          'assets/svg/npc_marciano_votante.png',
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
          filterQuality: FilterQuality.high,
        ),
      );
    } else if (esBurocrataCongelado || esJefeRecepcion) {
      contenido = AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: enemigo.sigueEnPie ? 1.0 : 0.45,
        child: Image.asset(
          'assets/svg/npc_burocrata_congelado.png',
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
          filterQuality: FilterQuality.high,
        ),
      );
    } else if (esDelegadoSindical || esInspectorSindical) {
      contenido = AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: enemigo.sigueEnPie ? 1.0 : 0.45,
        child: Image.asset(
          'assets/svg/npc_delegado_sindical.png',
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
          filterQuality: FilterQuality.high,
        ),
      );
    } else if (esEspectroDirectorskov) {
      contenido = AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: enemigo.sigueEnPie ? 1.0 : 0.55,
        child: Image.asset(
          'assets/svg/npc_directorskov_espectro.png',
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
          filterQuality: FilterQuality.high,
        ),
      );
    } else if (esSombraCosmonauta) {
      contenido = Image.asset(
        'assets/svg/npc_cosmonauta_congelado.png',
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
        filterQuality: FilterQuality.high,
      );
    } else {
      contenido = CustomPaint(
        painter: PintorStickFigure(
          clase: null,
          pose: PoseStickFigure.combateListo,
        ),
      );
    }

    final mostrarLluvia =
        esFantasma && !enemigo.sigueEnPie && combateFinalizado;

    final hijoBase = Padding(
      padding: EdgeInsets.all(lado * 0.08),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                RetratoConEfectosImpacto(
                  puntosVida: enemigo.puntosVida,
                  moral: enemigo.moral,
                  resaltarDerrota: !enemigo.sigueEnPie,
                  anchoMaximo: lado * 0.9,
                  relacionAspectoAlto: 1.0,
                  senalEfectoEspecial: contadorEfectoEspecial[enemigo] ?? 0,
                  identificadorEfectoEspecial:
                      idEfectoEspecialPorCombatiente[enemigo],
                  contenido: contenido,
                ),
                Positioned.fill(
                  child: OverlayEstadosPeon(
                    combatiente: enemigo,
                    controladorFase: controladorAmbiental,
                  ),
                ),
                if (mostrarLluvia)
                  const Positioned.fill(child: LluviaDePolvoDeCarbon()),
                Positioned(
                  top: -2,
                  right: -2,
                  child: FilaIconosEstado(
                    combatiente: enemigo,
                    tamano: lado * 0.18,
                  ),
                ),
                Positioned(
                  bottom: -4,
                  left: 0,
                  right: 0,
                  child: _BarritaPVMini(
                    valorActual: enemigo.puntosVida,
                    valorMaximo: enemigo.puntosVidaMaximos,
                  ),
                ),
              ],
            ),
          ),
          SombraPeon(ancho: lado * 0.5),
        ],
      ),
    );
    return _envolverConViajeDeAtaque(
      combatiente: enemigo,
      lado: lado,
      hijoBase: hijoBase,
      constructorTransformacion: (faseTransformacion) => Padding(
        padding: EdgeInsets.all(lado * 0.08),
        child: Column(
          children: [
            Expanded(
              child: CustomPaint(
                painter: PintorTransformacionAtaque(
                  identificadorHabilidad:
                      idHabilidadDelViaje ?? 'ataque_basico_melee',
                  faseTransformacion: faseTransformacion,
                ),
              ),
            ),
            SombraPeon(ancho: lado * 0.5),
          ],
        ),
      ),
    );
  }

  Widget _construirColumnaDerecha() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _construirStatsJugador(),
        const SizedBox(height: 10),
        Expanded(child: _construirPanelAcciones()),
      ],
    );
  }

  Widget _construirStatsJugador() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PaletaCosmoSovietica.papelViejo,
        border: Border.all(color: PaletaCosmoSovietica.tintaNegra, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.jugador.clase?.etiquetaCorta.toUpperCase() ?? 'CADETE',
            style: TipografiaPropaganda.etiquetaBurocratica,
          ),
          const SizedBox(height: 6),
          BarraEstado(
            etiqueta: 'PV',
            valorActual: widget.jugador.puntosVida,
            valorMaximo: widget.jugador.puntosVidaMaximos,
            colorRelleno: PaletaCosmoSovietica.tintaNegra,
          ),
          const SizedBox(height: 4),
          BarraEstado(
            etiqueta: 'MORAL',
            valorActual: widget.jugador.moral,
            valorMaximo: widget.jugador.moralMaxima,
            colorRelleno: PaletaCosmoSovietica.rojoOficial,
          ),
          if (widget.estado.contarObjeto('caja_sin_etiquetar') > 0) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(
                  color: PaletaCosmoSovietica.rojoOficial,
                  width: 1.5,
                ),
              ),
              child: const Text(
                'CAJA OCULTA',
                style: TipografiaPropaganda.etiquetaBurocratica,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _construirPanelAcciones() {
    final acciones = _construirAccionesDelJugador();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: PaletaCosmoSovietica.papelViejo,
        border: Border.all(color: PaletaCosmoSovietica.tintaNegra, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ACCIONES',
                style: TipografiaPropaganda.etiquetaBurocratica,
              ),
              if (accionSeleccionada != null)
                GestureDetector(
                  onTap: _cancelarSeleccion,
                  child: const Text(
                    'CANCELAR ✕',
                    style: TipografiaPropaganda.etiquetaBurocratica,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(
            color: PaletaCosmoSovietica.rojoOficial,
            thickness: 1.5,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.separated(
              itemCount: acciones.length,
              separatorBuilder: (c, i) => const SizedBox(height: 4),
              itemBuilder: (c, i) {
                final accion = acciones[i];
                final habilitada = _puedeSeleccionar(accion);
                final estaSeleccionada =
                    accionSeleccionada?.identificador == accion.identificador;
                final usosRestantes = accion.usosPorCombate > 0
                    ? accion.usosPorCombate -
                          (usosGastados[accion.identificador] ?? 0)
                    : null;
                return _CardAccion(
                  accion: accion,
                  habilitada: habilitada,
                  seleccionada: estaSeleccionada,
                  usosRestantes: usosRestantes,
                  onPressed: () => _seleccionarAccion(accion),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Center(
              child: BotonPropaganda(
                texto: 'Fin de turno',
                destacado: true,
                compacto: true,
                onPressed: esTurnoJugador && !combateFinalizado
                    ? _finalizarTurnoJugador
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirRegistro() {
    return Container(
      height: 90,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: PaletaCosmoSovietica.papelSombra,
        border: Border.all(color: PaletaCosmoSovietica.tintaNegra, width: 2),
      ),
      child: SingleChildScrollView(
        reverse: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final linea in registroCombate)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text('› $linea', style: TipografiaPropaganda.textoLog),
              ),
          ],
        ),
      ),
    );
  }

  Widget _construirControlesFin() {
    return Center(
      child: Column(
        children: [
          Text(
            victoriaJugador
                ? 'EXPEDIENTE CERRADO CON ÉXITO'
                : 'EXPEDIENTE TRASPAPELADO',
            style: TipografiaPropaganda.tituloSeccion,
          ),
          if (victoriaJugador) ...[
            const SizedBox(height: 4),
            Text(
              'Recompensa: +$xpRecompensaPendiente XP'
              '${idBotinPendiente != null ? ' · ${_traducirBotin(idBotinPendiente!)}' : ''}',
              style: TipografiaPropaganda.etiquetaBurocratica.copyWith(
                color: PaletaCosmoSovietica.rojoOficial,
              ),
            ),
            if (widget.estado.puedeSubirDeNivel())
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '¡Promoción disponible al nivel ${widget.estado.nivelCadete + 1}!',
                  style: TipografiaPropaganda.etiquetaBurocratica.copyWith(
                    color: PaletaCosmoSovietica.rojoOficial,
                  ),
                ),
              ),
          ],
          const SizedBox(height: 10),
          BotonPropaganda(
            texto: victoriaJugador ? 'Continuar' : 'Reintentar trámite',
            destacado: true,
            onPressed: () async {
              if (victoriaJugador && widget.estado.puedeSubirDeNivel()) {
                audioProcedural.reproducirSubidaDeNivel();
                await mostrarDialogoSubidaNivel(context, estado: widget.estado);
                if (!mounted) return;
              }
              if (!mounted) return;
              Navigator.of(context).pop(victoriaJugador);
            },
          ),
        ],
      ),
    );
  }
}

class _BarritaPVMini extends StatelessWidget {
  final int valorActual;
  final int valorMaximo;

  const _BarritaPVMini({required this.valorActual, required this.valorMaximo});

  @override
  Widget build(BuildContext context) {
    final ratio = valorMaximo == 0
        ? 0.0
        : (valorActual / valorMaximo).clamp(0.0, 1.0);
    return Container(
      height: 5,
      decoration: BoxDecoration(
        color: PaletaCosmoSovietica.papelSombra,
        border: Border.all(color: PaletaCosmoSovietica.tintaNegra, width: 1),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: ratio,
          child: Container(color: PaletaCosmoSovietica.rojoOficial),
        ),
      ),
    );
  }
}

class _CardAccion extends StatelessWidget {
  final AccionCombate accion;
  final bool habilitada;
  final bool seleccionada;
  final int? usosRestantes;
  final VoidCallback onPressed;

  const _CardAccion({
    required this.accion,
    required this.habilitada,
    required this.seleccionada,
    required this.usosRestantes,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: habilitada ? onPressed : null,
      child: MouseRegion(
        cursor: habilitada
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        child: Opacity(
          opacity: habilitada ? 1 : 0.45,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: seleccionada
                  ? PaletaCosmoSovietica.papelSombra
                  : PaletaCosmoSovietica.papelViejo,
              border: Border.all(
                color: seleccionada
                    ? PaletaCosmoSovietica.rojoOficial
                    : PaletaCosmoSovietica.tintaNegra,
                width: seleccionada ? 2.5 : 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        accion.nombre,
                        style: TipografiaPropaganda.etiquetaBurocratica,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      color: accion.costePuntosAccion == 0
                          ? PaletaCosmoSovietica.tintaNegra
                          : PaletaCosmoSovietica.rojoOficial,
                      child: Text(
                        '${accion.costePuntosAccion} PA',
                        style: const TextStyle(
                          fontFamily: TipografiaPropaganda.familiaMonoespaciada,
                          fontSize: 10,
                          color: PaletaCosmoSovietica.papelViejo,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  accion.descripcion,
                  style: TipografiaPropaganda.cuerpoLargo.copyWith(
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
                if (accion.alcanceMaximo > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Alcance: ${accion.alcanceMinimo == accion.alcanceMaximo ? accion.alcanceMinimo : '${accion.alcanceMinimo}-${accion.alcanceMaximo == 99 ? '∞' : accion.alcanceMaximo}'} · '
                      'Área: ${accion.radioArea}',
                      style: TipografiaPropaganda.etiquetaBurocratica.copyWith(
                        fontSize: 9,
                      ),
                    ),
                  ),
                if (usosRestantes != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Usos: $usosRestantes',
                      style: TipografiaPropaganda.etiquetaBurocratica.copyWith(
                        fontSize: 9,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cursor "ojo de mira burocrático" que aparece en cada celda válida cuando
/// el jugador tiene una habilidad seleccionada. Combina una cruz fina que
/// gira lentamente con cuatro esquinas tipo viewfinder pulsando hacia
/// dentro, evocando un sello que está a punto de estampar.
class _PintorCursorObjetivo extends CustomPainter {
  final double fase;
  final double desfaseCelda;

  _PintorCursorObjetivo({required this.fase, required this.desfaseCelda});

  @override
  void paint(Canvas canvas, Size size) {
    final centroCelda = Offset(size.width / 2, size.height / 2);
    final pulsoCursor = math.sin((fase + desfaseCelda) * math.pi * 2);
    final intensidadCursor = pulsoCursor * 0.5 + 0.5;

    // Cruz central rotante.
    final pincelCruz = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial.withValues(
        alpha: 0.55 + intensidadCursor * 0.35,
      )
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final radioCruz = size.shortestSide * 0.18;
    final anguloRotacionCruz = (fase + desfaseCelda) * math.pi * 2 * 0.18;
    final cosRotacion = math.cos(anguloRotacionCruz);
    final senRotacion = math.sin(anguloRotacionCruz);
    canvas.drawLine(
      Offset(
        centroCelda.dx - radioCruz * cosRotacion,
        centroCelda.dy - radioCruz * senRotacion,
      ),
      Offset(
        centroCelda.dx + radioCruz * cosRotacion,
        centroCelda.dy + radioCruz * senRotacion,
      ),
      pincelCruz,
    );
    canvas.drawLine(
      Offset(
        centroCelda.dx + radioCruz * senRotacion,
        centroCelda.dy - radioCruz * cosRotacion,
      ),
      Offset(
        centroCelda.dx - radioCruz * senRotacion,
        centroCelda.dy + radioCruz * cosRotacion,
      ),
      pincelCruz,
    );

    // Cuatro esquinas que se acercan al centro con el pulso (viewfinder).
    final pincelEsquinaViewfinder = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial.withValues(
        alpha: 0.7 + intensidadCursor * 0.25,
      )
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final distanciaEsquinas =
        size.shortestSide * (0.32 + intensidadCursor * 0.06);
    final largoEsquinas = size.shortestSide * 0.10;
    final esquinas = [
      Offset(
        centroCelda.dx - distanciaEsquinas,
        centroCelda.dy - distanciaEsquinas,
      ),
      Offset(
        centroCelda.dx + distanciaEsquinas,
        centroCelda.dy - distanciaEsquinas,
      ),
      Offset(
        centroCelda.dx + distanciaEsquinas,
        centroCelda.dy + distanciaEsquinas,
      ),
      Offset(
        centroCelda.dx - distanciaEsquinas,
        centroCelda.dy + distanciaEsquinas,
      ),
    ];
    final direcciones = [
      const Offset(1, 0),
      const Offset(-1, 0),
      const Offset(-1, 0),
      const Offset(1, 0),
    ];
    final direccionesVerticales = [
      const Offset(0, 1),
      const Offset(0, 1),
      const Offset(0, -1),
      const Offset(0, -1),
    ];
    for (
      int indiceEsquina = 0;
      indiceEsquina < esquinas.length;
      indiceEsquina++
    ) {
      final esquina = esquinas[indiceEsquina];
      final direccionHorizontal = direcciones[indiceEsquina];
      final direccionVertical = direccionesVerticales[indiceEsquina];
      canvas.drawLine(
        esquina,
        esquina + direccionHorizontal * largoEsquinas,
        pincelEsquinaViewfinder,
      );
      canvas.drawLine(
        esquina,
        esquina + direccionVertical * largoEsquinas,
        pincelEsquinaViewfinder,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PintorCursorObjetivo viejo) =>
      viejo.fase != fase || viejo.desfaseCelda != desfaseCelda;
}

/// Overlay de daño del cadete (§10.14). Detecta caídas de PV o moral
/// y reproduce 2 frames (f01 → f02) durante 700ms.
class _OverlayDanoCadete extends StatefulWidget {
  final int puntosVida;
  final int moral;

  const _OverlayDanoCadete({required this.puntosVida, required this.moral});

  @override
  State<_OverlayDanoCadete> createState() => _OverlayDanoCadeteState();
}

class _OverlayDanoCadeteState extends State<_OverlayDanoCadete>
    with SingleTickerProviderStateMixin {
  late final AnimationController controlador;
  late int ultimoPV;
  late int ultimoMoral;

  @override
  void initState() {
    super.initState();
    controlador = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    ultimoPV = widget.puntosVida;
    ultimoMoral = widget.moral;
  }

  @override
  void didUpdateWidget(_OverlayDanoCadete viejo) {
    super.didUpdateWidget(viejo);
    final bool perdiVida = widget.puntosVida < ultimoPV;
    final bool perdiMoral = widget.moral < ultimoMoral;
    ultimoPV = widget.puntosVida;
    ultimoMoral = widget.moral;
    if (perdiVida || perdiMoral) {
      controlador.forward(from: 0);
    }
  }

  @override
  void dispose() {
    controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controlador,
      builder: (contexto, _) {
        if (!controlador.isAnimating && !controlador.isCompleted) {
          return const SizedBox.shrink();
        }
        final double progreso = controlador.value;
        // f01: golpe entrante (0 → 0.5). f02: recuperación (0.5 → 1).
        final String ruta = progreso < 0.5
            ? 'assets/images/cadete_dano_f01.png'
            : 'assets/images/cadete_dano_f02.png';
        // Fade in rápido, fade out al final.
        final double opacidad = progreso < 0.15
            ? progreso / 0.15
            : (progreso > 0.85 ? (1 - progreso) / 0.15 : 1.0);
        return Opacity(
          opacity: opacidad.clamp(0.0, 1.0),
          child: Image.asset(
            ruta,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        );
      },
    );
  }
}
