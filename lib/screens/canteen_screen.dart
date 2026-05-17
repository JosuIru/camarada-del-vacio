import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/dialogues_madre_ferruginosa.dart';
import '../data/dialogues_ostrog.dart';
import '../data/huevos_de_pascua.dart';
import '../minijuegos/pantalla_snow_kamarada.dart';
import '../minijuegos/pantalla_transformacion.dart';
import '../models/dialogue.dart';
import '../models/game_class.dart';
import '../models/game_state.dart';
import '../theme.dart';
import '../utilities/page_transitions.dart';
import '../utilities/persistencia_partida.dart';
import '../widgets/ambient_particles.dart';
import '../widgets/ciclo_frames.dart';
import '../widgets/dialogue_panel.dart';
import '../widgets/efectos_hotspot.dart';
import '../widgets/free_scene.dart';
import '../widgets/inventory_dialog.dart';
import '../widgets/mascota_narrativa.dart';
import '../widgets/notificacion_insignia.dart';
import '../widgets/overlay_celebracion.dart';
import '../widgets/paper_background.dart';
import '../widgets/propaganda_button.dart';
import 'bureaucratic_transition.dart';
import 'overworld_map_screen.dart';

class PantallaCantina extends StatefulWidget {
  final EstadoJuego estado;

  const PantallaCantina({super.key, required this.estado});

  @override
  State<PantallaCantina> createState() => _PantallaCantinaState();
}

class _PantallaCantinaState extends State<PantallaCantina>
    with SingleTickerProviderStateMixin {
  final List<String> registroAcciones = [];
  final Set<String> conversacionesCerradas = {};
  bool puertaReactorAbierta = false;
  late AnimationController controladorFaseAmbiental;
  Offset? _puntoSalida;
  VoidCallback? _alCompletarSalida;

  late bool esRevisitaInicial;

  int _contadorClicksBarra = 0;

  // ── Puzles del escenario ─────────────────────────────────────────
  // Cajón empujable junto al fregadero. Al moverlo de su posición
  // inicial, revela un sello de cera con la K de Krilov — huevo de
  // pascua "archivero_krilov".
  late final ObjetoEmpujable _cajonFregadero;
  // Placa de presión bajo la mesa de Ostrog. Solo el cadete en modo
  // bola pesa lo suficiente; al pulsar dispara "pacto_bajo_la_mesa".
  late final InterruptorPresion _placaBajoMesaOstrog;
  bool _sellosKrilovRevelado = false;

  @override
  void initState() {
    super.initState();
    esRevisitaInicial = widget.estado.esRevisita('cantina');
    widget.estado.registrarVisitaModulo('cantina');
    puertaReactorAbierta =
        widget.estado.tieneFlag('hablo_con_ostrog');
    if (puertaReactorAbierta) {
      conversacionesCerradas.add('ostrog');
    }
    _sellosKrilovRevelado =
        widget.estado.tieneFlag('insignia_archivero_krilov');
    controladorFaseAmbiental = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _cajonFregadero = ObjetoEmpujable(
      identificador: 'cajon_fregadero',
      posicion: const Offset(0.235, 0.86),
      radio: 0.04,
      etiqueta: 'CAJÓN',
      factorEmpuje: 0.50,
      distanciaMinimaParaEvento: 0.05,
      onMovidoLejos: () {
        if (!mounted) return;
        setState(() => _sellosKrilovRevelado = true);
        desencadenarHuevoPascua(
          context,
          estado: widget.estado,
          idHuevo: 'archivero_krilov',
          registroEscenario: _registrar,
          claseCelebracion: widget.estado.personaje.clase,
        );
      },
    );
    _placaBajoMesaOstrog = InterruptorPresion(
      identificador: 'placa_mesa_ostrog',
      rect: const Rect.fromLTWH(0.36, 0.88, 0.08, 0.04),
      etiqueta: 'PLACA OCULTA',
      onPulsar: () {
        if (!mounted) return;
        desencadenarHuevoPascua(
          context,
          estado: widget.estado,
          idHuevo: 'pacto_bajo_la_mesa',
          registroEscenario: _registrar,
          claseCelebracion: widget.estado.personaje.clase,
        );
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      persistenciaPartida.autoguardarPartida(widget.estado);
      _mostrarIntro();
    });
  }

  @override
  void dispose() {
    controladorFaseAmbiental.dispose();
    super.dispose();
  }

  void _mostrarIntro() {
    if (esRevisitaInicial) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _ModalNarrativoCantina(
          titulo: 'CANTINA DEL OLVIDO · REGRESO',
          cuerpo: puertaReactorAbierta
              ? 'Vuelves a la cantina de la Pravda-12. Ostrog te dirige un asentimiento mineral. Madre Ferruginosa burbujea contenta cuando te ve. Alguien ha vuelto a romper la radio. La compuerta del reactor sigue desbloqueada.'
              : 'Vuelves a la cantina de la Pravda-12. Ostrog finge no reconocerte hasta que ya estás muy cerca. Madre Ferruginosa burbujea en clave morse algo que parece "otra vez tú". La radio insiste en sus dos frecuencias prohibidas.',
          textoBoton: 'CONTINUAR',
        ),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ModalNarrativoCantina(
        titulo: 'CANTINA DEL OLVIDO · PRAVDA-12',
        cuerpo:
            'Cruzas la compuerta y entras en la Cantina del Olvido. Olores acumulados: té viejo, vodka sintético, soldadura y melancolía orgánica. El Comandante Ostrog junto a una mesa, una mole metálica que canturrea sola junto a la barra. La radio escupe estática en frecuencias del sector Sigma.\n\n— El Camarada Gromov respira menos esta semana por llegar tarde al turno —comenta Ostrog sin mirarte—. Está de acuerdo. Es inquietante.',
        textoBoton: 'CONTINUAR',
      ),
    );
  }

  Future<void> _abrirInventario() async {
    await mostrarDialogoInventario(context, estado: widget.estado);
    if (!mounted) return;
    setState(() {});
  }

  void _registrar(String texto) {
    setState(() {
      registroAcciones.add(texto);
      if (registroAcciones.length > 9) {
        registroAcciones.removeRange(0, registroAcciones.length - 9);
      }
    });
  }

  Future<void> _hablarCon(ConversacionNpc conversacion, String idNpc) async {
    await mostrarPanelDialogo(
      context,
      conversacion: conversacion,
      estado: widget.estado,
      onConsecuencia: (consecuencia) {
        if (consecuencia == 'ostrog_alineado') {
          conversacionesCerradas.add('ostrog');
          widget.estado.activarFlag('hablo_con_ostrog');
        } else if (consecuencia == 'te_de_madre') {
          widget.estado.activarFlag('te_de_madre');
        } else if (consecuencia == 'companera_madre_activa') {
          widget.estado.activarFlag('te_de_madre');
          widget.estado.companeroFerruginosaActivo = true;
          _registrar(
              'Madre Ferruginosa portátil ahora te acompaña en combate.');
        }
      },
    );
    if (!mounted) return;
    setState(() {});
    if (idNpc == 'ostrog' && conversacionesCerradas.contains('ostrog')) {
      _registrar(
          'Ostrog te ha dado las instrucciones. La compuerta del Reactor se desbloquea.');
      setState(() => puertaReactorAbierta = true);
    }
  }

  void _interactuarRadio() {
    _registrar(
        'La radio cruje. La aguja oscila entre dos frecuencias prohibidas. Madre Ferruginosa la mira de reojo.');
  }

  void _interactuarBarra() {
    _contadorClicksBarra++;
    if (_contadorClicksBarra == 7 &&
        !widget.estado.tieneFlag('insignia_chiste_prohibido')) {
      _registrar(
          'Ostrog te mira un instante largo. Apoya el codo. Te cuenta el chiste sobre el bigote de Brezhnev, el cosmonauta y el sello equivocado. Te ríes hasta que el aire de la cantina pesa menos.');
      desbloquearInsigniaSiNueva(
        context,
        estado: widget.estado,
        identificadorFlag: 'insignia_chiste_prohibido',
      );
      return;
    }
    final mensajes = [
      'Tazas con asas distintas, ninguna limpia. Una etiqueta dice "PRUEBA: NO BEBER" en una caligrafía que parece reciente.',
      'Sirves un vodka sintético. Ostrog gruñe.',
      'Segundo vaso. La radio carraspea entre dos frecuencias.',
      'Tercer vaso. Madre Ferruginosa silba bajito.',
      'Cuarto vaso. Ostrog limpia la barra con la manga.',
      'Quinto vaso. Una mosca cae al fondo del cristal y nada satisfecha.',
      'Sexto vaso. Ostrog te mira como pesando algo.',
    ];
    final indice = (_contadorClicksBarra - 1).clamp(0, mensajes.length - 1);
    _registrar(mensajes[indice]);
  }

  void _alCodigoSecretoMundoLibre(String identificadorCodigo) {
    if (identificadorCodigo == 'konami_invertido') {
      desbloquearInsigniaSiNueva(
        context,
        estado: widget.estado,
        identificadorFlag: 'insignia_cadete_traidor',
      );
      _registrar(
          'Madre Ferruginosa burbujea con desaprobación: el cadete acaba de bailar una secuencia decididamente no soviética.');
    }
  }

  void _alCadeteQuietoLargoRato() {
    if (widget.estado.tieneFlag('insignia_madre_te_ve')) return;
    desbloquearInsigniaSiNueva(
      context,
      estado: widget.estado,
      identificadorFlag: 'insignia_madre_te_ve',
    );
    _registrar(
        'Madre Ferruginosa burbujea cuatro veces seguidas: «yo-te-ve-o». Ostrog, sin mirar, asiente.');
  }

  void _interactuarBarrilAlmacen() {
    if (widget.estado.tieneFlag('encontro_chaleco_canteen')) {
      _registrar('El barril del almacén ya no contiene nada útil.');
      return;
    }
    widget.estado.activarFlag('encontro_chaleco_canteen');
    widget.estado.anadirObjeto('torso_chaleco_reforzado');
    setState(() {});
    _registrar(
        'Forcejeas con la tapa de un barril del almacén. Encuentras un Chaleco Reforzado de Acolchados, doblado bajo tres formularios de 1979.');
  }

  void _interactuarPuertaCamarotes() {
    _registrar(
        'Pasillo a los camarotes. Bloqueado por dos sacos de patata congelada con etiqueta "PRUEBA".');
  }

  void _interactuarFregadero() {
    _registrar(
        'Fregadero industrial. Anillo de óxido alrededor del desagüe en forma exacta de una estrella de cinco puntas. Nadie lo ha denunciado, nadie lo ha pulido.');
  }

  void _interactuarSacosPatatas() {
    _registrar(
        'Sacos de patata. La etiqueta dice "GROZNI 1961". La cosecha del año en que Gromov dejó de respirar a tiempo.');
  }

  void _interactuarTrampillaCongelador() {
    _registrar(
        'Una trampilla mal disimulada entre los sacos de patata. Aire helado se filtra por los bordes. Al levantarla, la nieve sube hacia tu cara como si el agujero tuviera prisa.');
    Navigator.of(context).push(
      crearRutaConTransicion(
        PantallaTransformacion(
          formaDestino: FormaProtagonista.bolaNieve,
          nombreLugar: 'CONGELADOR DEL COCINERO',
          fraseTransformacion:
              'El frío te abriga. Tu uniforme se cubre de papel y nieve. Eres ahora un soldado del invierno.',
          alTerminar: () {
            Navigator.of(context).pushReplacement(
              crearRutaConTransicion(
                PantallaSnowKamarada(estado: widget.estado),
              ),
            );
          },
        ),
      ),
    );
  }

  void _interactuarDelantalCocinero() {
    _registrar(
        'Delantal del cocinero, todavía colgando. La mancha del pecho parece pintura roja seca, pero también podría ser borscht. Nadie sabe a dónde fue el cocinero.');
  }

  void _interactuarCartelPropaganda() {
    _registrar(
        'Cartel "TRABAJO – LEALTAD – SILENCIO". Alguien ha tachado "SILENCIO" con tinta roja y ha escrito "TÉ" encima.');
  }


  void _interactuarSofaRemendado() {
    _registrar(
        'Sofá rojo con tres remiendos burdos. Cojines hundidos en el lado izquierdo: el lado del Capitán Vassiliev cuando aún se sentaba.');
  }

  void _interactuarAjedrezInacabado() {
    _registrar(
        'Partida de ajedrez sin terminar. Las blancas perdían en cinco. El rey blanco está volcado, una pieza roja descansa sobre la casilla central — alguien ha decidido jugar con piezas de propaganda.');
  }

  void _interactuarTaquillasCamarote() {
    _registrar(
        'Tres taquillas: 11, 12, 13. La del 12 tiene una flor seca pegada con cinta. Era la de la Camarada Lyudmila, que se fue en la Pravda-7.');
  }

  void _interactuarSamovarDescanso() {
    _registrar(
        'Samovar comunal. Estrella roja sobre el costado. El grifo no cierra del todo y el agua hierve permanentemente, como una conciencia.');
  }

  void _interactuarVentanaCosmica() {
    _registrar(
        'Ojo de buey. Fuera, el planeta lejano gira lentamente. Esta semana parece más cerca que la anterior. Ostrog dice que es una ilusión óptica. Madre Ferruginosa burbujea «no».');
  }

  void _interactuarPuertaReactor() {
    if (!puertaReactorAbierta) {
      _registrar(
          'Compuerta al Reactor. Cerrada. Habla antes con el Comandante Ostrog.');
      return;
    }
    setState(() {
      _puntoSalida = const Offset(1.08, 0.78);
      _alCompletarSalida = _irAlMapaParaReactor;
    });
  }

  void _irAlMapaParaReactor() {
    Navigator.of(context).pushReplacement(
      crearRutaConTransicion(
        PantallaTransicionBurocratica(
          codigoInforme: 'INFORME 113-C · AUTORIZACIÓN DE PASO',
          tituloInforme: 'TRÁNSITO AL MÓDULO REACTOR',
          cuerpoInforme:
              'El Comandante Ostrog "el Quemado", al mando nominal de la '
              'nave Pravda-12, autoriza por la presente el tránsito del '
              'cadete al módulo de Reactor con el propósito declarado de '
              '"presentar respetos a la Ingeniera Vostrikova".\n\n'
              'Se recuerda al titular del visado que toda herramienta tomada '
              'del módulo Reactor sin firma deberá considerarse "extraviada '
              'en cumplimiento del servicio". El formulario F-447 (copia '
              'de cortesía) viaja con usted.\n\n'
              'Punto de control: superado.\n'
              'Estado nominal: insatisfactorio pero tolerable.\n'
              'Sello del Comandante: aplicado en condiciones adversas.',
          selloFinal: 'OSTROG · COMANDANTE NOMINAL',
          pantallaDestino: PantallaMapaOverworld(
            estado: widget.estado,
            moduloDestacado: 'reactor',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoPapelViejo(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'CANTINA DEL OLVIDO · PRAVDA-12',
                      style: TipografiaPropaganda.tituloSeccion,
                    ),
                    Text(
                      'CADETE · ${widget.estado.personaje.clase?.etiquetaCorta.toUpperCase() ?? "???"}',
                      style: TipografiaPropaganda.etiquetaBurocratica,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: _construirEscenario()),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: _construirPanelLateral()),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pulsa un NPC, un objeto o el suelo. El cadete caminará antes de interactuar.',
                  style: TipografiaPropaganda.subtitulo,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirEscenario() {
    return AnimatedBuilder(
      animation: controladorFaseAmbiental,
      builder: (contexto, _) => DecoratedBox(
        decoration: BoxDecoration(
          border:
              Border.all(color: PaletaCosmoSovietica.tintaNegra, width: 3),
        ),
        child: EscenarioLibre(
          rutaImagenFondo: 'assets/images/fondo_canteen.png',
          claseJugador: widget.estado.personaje.clase,
          idSombreroEquipado: widget.estado.idObjetoCabezaEquipado,
          idArmaEquipada: widget.estado.idObjetoArmaEquipada,
          idTorsoEquipado: widget.estado.idObjetoTorsoEquipado,
          capaAmbiental: const CapaParticulasAmbientales(
            tipoAmbiente: TipoAmbiente.motasArchivo,
            cantidadParticulas: 42,
          ),
          factorAnchoMundo: 2.0,
          posicionInicialJugador: const Offset(0.06, 0.88),
          puntoEntradaInicial: const Offset(-0.02, 0.88),
          puntoSalidaActiva: _puntoSalida,
          onCodigoSecreto: _alCodigoSecretoMundoLibre,
          onCadeteQuietoLargoRato: _alCadeteQuietoLargoRato,
          alCompletarSalida: () {
            final cb = _alCompletarSalida;
            _alCompletarSalida = null;
            _puntoSalida = null;
            cb?.call();
          },
          hotspots: [
            // ─── Zona A · Almacén/despensa (0.00 – 0.32) ───
            HotspotEscenario(
              identificador: 'barril_almacen',
              posicionRelativa: const Offset(0.10, 0.82),
              anchoRelativo: 0.06,
              altoRelativo: 0.18,
              radioInteraccion: 0.10,
              destacar: !widget.estado
                  .tieneFlag('encontro_chaleco_canteen'),
              etiquetaAccion: widget.estado
                      .tieneFlag('encontro_chaleco_canteen')
                  ? 'EXAMINAR'
                  : 'ABRIR',
              representacion: Stack(
                children: [
                  const Positioned.fill(
                    child: IconoHotspotImagen(
                      rutaAsset: 'assets/svg/mueble_barril.png',
                      anchoSombra: 68,
                    ),
                  ),
                  if (widget.estado.tieneFlag('encontro_chaleco_canteen'))
                    const Positioned.fill(
                      child: EfectoHumoAscendente(
                        cantidadPlumas: 6,
                        tinte: PaletaCosmoSovietica.tintaTenue,
                        anchoZonaEmision: 0.35,
                      ),
                    ),
                ],
              ),
              onInteractuar: _interactuarBarrilAlmacen,
            ),
            HotspotEscenario(
              identificador: 'fregadero',
              posicionRelativa: const Offset(0.205, 0.84),
              anchoRelativo: 0.07,
              altoRelativo: 0.10,
              radioInteraccion: 0.08,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarFregadero,
            ),
            HotspotEscenario(
              identificador: 'sacos_patatas',
              posicionRelativa: const Offset(0.045, 0.88),
              anchoRelativo: 0.05,
              altoRelativo: 0.08,
              radioInteraccion: 0.07,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarSacosPatatas,
            ),
            HotspotEscenario(
              identificador: 'cartel_congelador_no_tocar',
              posicionRelativa: const Offset(0.04, 0.40),
              anchoRelativo: 0.04,
              altoRelativo: 0.12,
              radioInteraccion: 0.06,
              etiquetaAccion: 'LEER',
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/cartel_congelador_no_tocar.png',
                conSombra: false,
              ),
              onInteractuar: () => _registrar(
                'Cartel atornillado a la pared: «CONGELADOR — NO TOCAR. '
                'Por orden del Comité de Inventario Térmico». Alguien ha '
                'escrito a lápiz debajo: "ya es tarde".',
              ),
            ),
            HotspotEscenario(
              identificador: 'trampilla_congelador',
              posicionRelativa: const Offset(0.135, 0.94),
              anchoRelativo: 0.07,
              altoRelativo: 0.06,
              radioInteraccion: 0.08,
              etiquetaAccion: 'BAJAR',
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/mueble_trampilla_congelador.png',
                conSombra: false,
              ),
              onInteractuar: _interactuarTrampillaCongelador,
            ),
            HotspotEscenario(
              identificador: 'delantal_cocinero',
              posicionRelativa: const Offset(0.275, 0.42),
              anchoRelativo: 0.04,
              altoRelativo: 0.14,
              radioInteraccion: 0.08,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarDelantalCocinero,
            ),

            // ─── Zona B · Barra principal (0.32 – 0.66) ───
            HotspotEscenario(
              identificador: 'ostrog',
              posicionRelativa: const Offset(0.67, 0.81),
              anchoRelativo: 0.07,
              altoRelativo: 0.22,
              radioInteraccion: 0.10,
              destacar: !widget.estado.tieneFlag('hablo_con_ostrog'),
              etiquetaAccion: 'HABLAR',
              representacion: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: 60,
                      height: 8,
                      decoration: BoxDecoration(
                        color: PaletaCosmoSovietica.tintaNegra
                            .withValues(alpha: 0.30),
                        borderRadius: const BorderRadius.all(
                            Radius.circular(20)),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Image.asset(
                      'assets/svg/ostrog.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ],
              ),
              onInteractuar: () =>
                  _hablarCon(conversacionConOstrog, 'ostrog'),
            ),
            HotspotEscenario(
              identificador: 'barra',
              posicionRelativa: const Offset(0.435, 0.78),
              anchoRelativo: 0.26,
              altoRelativo: 0.20,
              radioInteraccion: 0.16,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarBarra,
            ),
            HotspotEscenario(
              identificador: 'radio',
              posicionRelativa: const Offset(0.40, 0.50),
              anchoRelativo: 0.05,
              altoRelativo: 0.10,
              radioInteraccion: 0.10,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/radio_cantina.png',
                conSombra: false,
              ),
              onInteractuar: _interactuarRadio,
            ),
            HotspotEscenario(
              identificador: 'madre',
              posicionRelativa: const Offset(0.235, 0.72),
              anchoRelativo: 0.10,
              altoRelativo: 0.40,
              radioInteraccion: 0.14,
              etiquetaAccion: 'HABLAR',
              representacion: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: 72,
                      height: 9,
                      decoration: BoxDecoration(
                        color: PaletaCosmoSovietica.tintaNegra
                            .withValues(alpha: 0.30),
                        borderRadius: const BorderRadius.all(
                            Radius.circular(20)),
                      ),
                    ),
                  ),
                  // Madre Ferruginosa animada (3 frames §10.4): los
                  // PNGs contienen la silueta completa con variaciones
                  // del humo/corazones de la pipa, así que usamos el
                  // ciclo como sprite principal (no como overlay).
                  const Positioned.fill(
                    child: CicloDeFrames(
                      rutasFrames: [
                        'assets/images/madre_humo_f01.png',
                        'assets/images/madre_humo_f02.png',
                        'assets/images/madre_humo_f03.png',
                      ],
                      duracionPorFrame: Duration(milliseconds: 560),
                      ajuste: BoxFit.contain,
                      alineamiento: Alignment.bottomCenter,
                    ),
                  ),
                ],
              ),
              onInteractuar: () =>
                  _hablarCon(conversacionConMadreFerruginosa, 'madre'),
            ),
            // Capitán Vassiliev: NPC nuevo a la derecha de la cantina,
            // sentado leyendo F-447 en una mesa apartada. Diálogo
            // placeholder hasta que tenga conversación propia.
            HotspotEscenario(
              identificador: 'vassiliev',
              posicionRelativa: const Offset(0.93, 0.81),
              anchoRelativo: 0.08,
              altoRelativo: 0.22,
              radioInteraccion: 0.12,
              etiquetaAccion: 'HABLAR',
              representacion: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: 64,
                      height: 8,
                      decoration: BoxDecoration(
                        color: PaletaCosmoSovietica.tintaNegra
                            .withValues(alpha: 0.30),
                        borderRadius: const BorderRadius.all(
                            Radius.circular(20)),
                      ),
                    ),
                  ),
                  // Vassiliev animado (3 frames §10.5). Mismo
                  // patrón que la Madre: los PNGs son la silueta
                  // completa con variación del humo de pipa, así
                  // que el ciclo sustituye al sprite estático.
                  const Positioned.fill(
                    child: CicloDeFrames(
                      rutasFrames: [
                        'assets/images/vassiliev_humo_f01.png',
                        'assets/images/vassiliev_humo_f02.png',
                        'assets/images/vassiliev_humo_f03.png',
                      ],
                      duracionPorFrame: Duration(milliseconds: 600),
                      ajuste: BoxFit.contain,
                      alineamiento: Alignment.bottomCenter,
                    ),
                  ),
                ],
              ),
              onInteractuar: () {
                _registrar(
                  'Capitán Vassiliev no levanta la vista del F-447. '
                  'La pipa suelta tres aros rojos. — «Buenas, cadete. '
                  'Llega tarde. Como todos.»',
                );
              },
            ),
            HotspotEscenario(
              identificador: 'cartel_propaganda',
              posicionRelativa: const Offset(0.61, 0.32),
              anchoRelativo: 0.05,
              altoRelativo: 0.14,
              radioInteraccion: 0.08,
              etiquetaAccion: 'LEER',
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/cartel_gloria_al_camarada.png',
                conSombra: false,
              ),
              onInteractuar: _interactuarCartelPropaganda,
            ),

            // ─── Zona C · Sala de descanso (0.66 – 1.00) ───
            HotspotEscenario(
              identificador: 'sofa_remendado',
              posicionRelativa: const Offset(0.815, 0.87),
              anchoRelativo: 0.08,
              altoRelativo: 0.13,
              radioInteraccion: 0.08,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarSofaRemendado,
            ),
            HotspotEscenario(
              identificador: 'ajedrez_inacabado',
              posicionRelativa: const Offset(0.775, 0.87),
              anchoRelativo: 0.05,
              altoRelativo: 0.07,
              radioInteraccion: 0.07,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarAjedrezInacabado,
            ),
            HotspotEscenario(
              identificador: 'taquillas_camarote',
              posicionRelativa: const Offset(0.74, 0.50),
              anchoRelativo: 0.06,
              altoRelativo: 0.18,
              radioInteraccion: 0.09,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarTaquillasCamarote,
            ),
            HotspotEscenario(
              identificador: 'samovar_descanso',
              posicionRelativa: const Offset(0.97, 0.85),
              anchoRelativo: 0.04,
              altoRelativo: 0.18,
              radioInteraccion: 0.07,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarSamovarDescanso,
            ),
            HotspotEscenario(
              identificador: 'ventana_cosmica',
              posicionRelativa: const Offset(0.71, 0.27),
              anchoRelativo: 0.05,
              altoRelativo: 0.10,
              radioInteraccion: 0.10,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarVentanaCosmica,
            ),
            HotspotEscenario(
              identificador: 'puerta_camarotes',
              posicionRelativa: const Offset(0.855, 0.62),
              anchoRelativo: 0.035,
              altoRelativo: 0.34,
              radioInteraccion: 0.08,
              etiquetaAccion: 'BLOQUEADA',
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarPuertaCamarotes,
            ),
            HotspotEscenario(
              identificador: 'puerta_reactor',
              posicionRelativa: const Offset(0.905, 0.62),
              anchoRelativo: 0.035,
              altoRelativo: 0.34,
              radioInteraccion: 0.08,
              destacar: puertaReactorAbierta,
              etiquetaAccion: puertaReactorAbierta ? 'CRUZAR' : 'CERRADA',
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarPuertaReactor,
            ),
            // Sello de cera con la «К» revelado al empujar el cajón
            // del fregadero. Solo visible tras descubrir el huevo.
            if (_sellosKrilovRevelado)
              HotspotEscenario(
                identificador: 'sello_krilov_revelado',
                posicionRelativa: const Offset(0.20, 0.92),
                anchoRelativo: 0.04,
                altoRelativo: 0.04,
                radioInteraccion: 0.06,
                representacion: const IconoHotspotGenerico(
                  painter: _PintorSelloCeraK(),
                  conSombra: false,
                ),
                animarRespiracion: false,
                onInteractuar: () => _registrar(
                  'Sello de cera roja con la letra «К» y el código 7-Б. '
                  'Idéntico al de la nota del barril. Krilov firma con cera, '
                  'no con tinta. Eso ya dice algo.',
                ),
              ),
            // Gatito perdido bajo la mesa de la cantina. Sólo
            // aparece si Laika aún no ha sido adoptada. Interactuar
            // la "adopta" y queda como compañera permanente.
            if (!widget.estado.tieneFlag(flagLaikaAdoptada))
              HotspotEscenario(
                identificador: 'laika_perdida',
                posicionRelativa: const Offset(0.92, 0.89),
                anchoRelativo: 0.05,
                altoRelativo: 0.07,
                radioInteraccion: 0.10,
                destacar: true,
                etiquetaAccion: 'ADOPTAR',
                representacion: const IconoHotspotImagen(
                  rutaAsset: 'assets/svg/laika_perdida.png',
                  conSombra: false,
                ),
                onInteractuar: _adoptarLaika,
              ),
          ],
          objetosEmpujables: [_cajonFregadero],
          interruptores: [_placaBajoMesaOstrog],
          mascota: mascotaLaikaSiProcede(
            widget.estado,
            identificadorEscenario: 'cantina',
          ),
        ),
      ),
    );
  }

  void _adoptarLaika() {
    if (widget.estado.tieneFlag(flagLaikaAdoptada)) return;
    setState(() {
      widget.estado.activarFlag(flagLaikaAdoptada);
    });
    _registrar(
      '★ Una gatita-perra cosmonauta sale de debajo de la mesa. '
      'Casco de medio lado, mirada huérfana. "LAIKA" reza el collar.',
    );
    desbloquearInsigniaSiNueva(
      context,
      estado: widget.estado,
      identificadorFlag: 'insignia_laika_adoptada',
    );
    mostrarCelebracion(
      context,
      texto: '¡LAIKA ADOPTADA!',
      subtitulo: 'Te seguirá por los pasillos del Comité.\n'
          'A veces. Cuando le apetezca.',
      clase: widget.estado.personaje.clase,
      duracion: const Duration(milliseconds: 2400),
      rutaImagenPersonalizada: 'assets/images/laika_ladrando.png',
    );
  }

  Widget _construirPanelLateral() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PaletaCosmoSovietica.papelViejo,
        border:
            Border.all(color: PaletaCosmoSovietica.tintaNegra, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CRÓNICA DE LA CANTINA',
              style: TipografiaPropaganda.etiquetaBurocratica),
          const SizedBox(height: 8),
          const Divider(color: PaletaCosmoSovietica.tintaNegra, height: 1),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (registroAcciones.isEmpty)
                    const Text(
                      'La cantina huele a té viejo y soldadura. Una radio canturrea sola. Hay alguien junto a la mesa y algo metálico junto a la barra.',
                      style: TipografiaPropaganda.textoLog,
                    )
                  else
                    for (final linea in registroAcciones)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(linea,
                            style: TipografiaPropaganda.textoLog),
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: BotonPropaganda(
                  texto: 'Inventario',
                  compacto: true,
                  onPressed: _abrirInventario,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: BotonPropaganda(
                  texto: 'Salir',
                  compacto: true,
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}




class _ModalNarrativoCantina extends StatelessWidget {
  final String titulo;
  final String cuerpo;
  final String textoBoton;

  const _ModalNarrativoCantina({
    required this.titulo,
    required this.cuerpo,
    required this.textoBoton,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: PaletaCosmoSovietica.papelViejo,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(
          color: PaletaCosmoSovietica.tintaNegra,
          width: 3,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: TipografiaPropaganda.etiquetaBurocratica),
              const SizedBox(height: 8),
              const Divider(
                color: PaletaCosmoSovietica.rojoOficial,
                thickness: 1.5,
              ),
              const SizedBox(height: 16),
              Text(cuerpo, style: TipografiaPropaganda.bocadilloDialogo),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: BotonPropaganda(
                  texto: textoBoton,
                  destacado: true,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sello de cera rojo con la letra «К» (Krilov) y el código 7-Б,
/// revelado al desplazar el cajón del fregadero. Es un huevo de pascua
/// visual que conecta con el expediente Krilov.
class _PintorSelloCeraK extends CustomPainter {
  const _PintorSelloCeraK();

  @override
  void paint(Canvas canvas, Size size) {
    final double centroX = size.width * 0.5;
    final double centroY = size.height * 0.55;
    final double radio = math.min(size.width, size.height) * 0.42;

    // Sombra del sello.
    canvas.drawCircle(
      Offset(centroX + 1.2, centroY + 1.8),
      radio + 0.6,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.40),
    );
    // Disco de cera roja con borde irregular (salpicaduras).
    final Paint pinturaCera = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial;
    canvas.drawCircle(Offset(centroX, centroY), radio, pinturaCera);
    // 6 salpicaduras pequeñas.
    final salpicaduras = [
      const Offset(0.82, 0.18),
      const Offset(-0.78, 0.10),
      const Offset(0.20, -0.92),
      const Offset(-0.28, 0.86),
      const Offset(0.62, -0.55),
      const Offset(-0.55, -0.58),
    ];
    for (final salpicadura in salpicaduras) {
      canvas.drawCircle(
        Offset(centroX + salpicadura.dx * radio,
            centroY + salpicadura.dy * radio),
        radio * 0.18,
        pinturaCera,
      );
    }
    // Borde negro.
    canvas.drawCircle(
      Offset(centroX, centroY),
      radio,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // Letra cirílica К en blanco.
    final letraSello = TextPainter(
      text: const TextSpan(
        text: 'К',
        style: TextStyle(
          color: PaletaCosmoSovietica.papelViejo,
          fontFamily: 'CosmoSerif',
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    letraSello.paint(
      canvas,
      Offset(centroX - letraSello.width / 2, centroY - letraSello.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
