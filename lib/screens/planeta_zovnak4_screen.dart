import 'package:flutter/material.dart';
import '../data/dialogues_alcalde_zovnak.dart';
import '../data/encounters.dart';
import '../data/huevos_de_pascua.dart';
import '../models/game_class.dart';
import '../models/game_state.dart';
import '../painters/zovnak4_scene_painter.dart';
import '../theme.dart';
import '../utilities/page_transitions.dart';
import '../utilities/persistencia_partida.dart';
import '../widgets/ambient_particles.dart';
import '../widgets/dialogue_panel.dart';
import '../widgets/efectos_hotspot.dart';
import '../widgets/free_scene.dart';
import '../widgets/inventory_dialog.dart';
import '../widgets/notificacion_insignia.dart';
import '../widgets/paper_background.dart';
import '../widgets/propaganda_button.dart';
import 'bureaucratic_transition.dart';
import 'combat_screen.dart';
import 'cuadrante_sigma_screen.dart';

class PantallaPlanetaZovnak4 extends StatefulWidget {
  final EstadoJuego estado;

  const PantallaPlanetaZovnak4({super.key, required this.estado});

  @override
  State<PantallaPlanetaZovnak4> createState() => _PantallaPlanetaZovnak4State();
}

class _PantallaPlanetaZovnak4State extends State<PantallaPlanetaZovnak4>
    with SingleTickerProviderStateMixin {
  final List<String> registroAcciones = [];
  late AnimationController controladorFaseAmbiental;
  late bool esRevisitaInicial;
  bool asambleaResuelta = false;
  int _contadorVotosEnBlanco = 0;
  Offset? _puntoSalida;
  VoidCallback? _alCompletarSalida;

  // Fardo empujable con papeletas marcadas con la letra K. Al moverlo
  // de su rectángulo oficial se revela el huevo "urna_desplazada".
  late final ObjetoEmpujable _fardoPapeletasK;
  bool _papeletasKReveladas = false;

  @override
  void initState() {
    super.initState();
    esRevisitaInicial = widget.estado.esRevisita('zovnak4');
    widget.estado.registrarVisitaModulo('zovnak4');
    asambleaResuelta =
        widget.estado.tieneFlag('asamblea_zovnak4_resuelta');
    _papeletasKReveladas =
        widget.estado.tieneFlag('insignia_urna_descubierta');
    controladorFaseAmbiental = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _fardoPapeletasK = ObjetoEmpujable(
      identificador: 'fardo_papeletas_k',
      posicion: const Offset(0.27, 0.80),
      radio: 0.045,
      etiqueta: 'PAPELETAS',
      factorEmpuje: 0.55,
      distanciaMinimaParaEvento: 0.06,
      onMovidoLejos: () {
        if (!mounted) return;
        setState(() => _papeletasKReveladas = true);
        desencadenarHuevoPascua(
          context,
          estado: widget.estado,
          idHuevo: 'urna_desplazada',
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
        builder: (_) => _ModalNarrativoZovnak(
          titulo: 'ZOVNAK-4 · REGRESO',
          cuerpo: asambleaResuelta
              ? 'Aterrizas otra vez en Zovnak-4. La asamblea sigue votando si la votación anterior fue legítima. Tu insignia "VOTANTE HONORARIO" abre una pequeña vía de respeto entre las papeletas.'
              : 'Aterrizas otra vez en Zovnak-4. El Alcalde Provisional te mira con tres ojos rojos y un asentimiento procedimental.',
          textoBoton: 'CONTINUAR',
        ),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ModalNarrativoZovnak(
        titulo: 'ZOVNAK-4 · ASAMBLEA PERMANENTE · 1962',
        cuerpo:
            'Aterrizas en Zovnak-4. Dos soles enfermizos en el cielo, formularios revoloteando como hojas, y al fondo una pancarta: ASAMBLEA PERMANENTE. La asamblea lleva cuarenta años votando si instalar agua corriente. Hoy votan sobre ti.\n\nUna voz cavernosa anuncia: "Mociónese contra el camarada".\n\nMisión nominal: cruzar el planeta sin que la asamblea apruebe arrestarte. Misión opcional: obtener pistas sobre la Pravda-7.',
        textoBoton: 'COMPRENDIDO',
      ),
    );
  }

  void _registrar(String texto) {
    setState(() {
      registroAcciones.add(texto);
      if (registroAcciones.length > 9) {
        registroAcciones.removeRange(0, registroAcciones.length - 9);
      }
    });
  }

  Future<void> _abrirInventario() async {
    await mostrarDialogoInventario(context, estado: widget.estado);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _hablarConAlcalde() async {
    await mostrarPanelDialogo(
      context,
      conversacion: conversacionConAlcaldeZovnak,
      estado: widget.estado,
      onConsecuencia: (consecuencia) async {
        switch (consecuencia) {
          case 'alcalde_aliado':
            widget.estado.activarFlag('alcalde_zovnak_aliado');
            widget.estado.activarFlag('asamblea_zovnak4_resuelta');
            widget.estado.anadirObjeto('insignia_votante_honorario');
            asambleaResuelta = true;
            _registrar(
                'El Alcalde te concede paso. Recibes la insignia "VOTANTE HONORARIO".');
            break;
          case 'alcalde_pacifico':
            widget.estado.activarFlag('asamblea_zovnak4_resuelta');
            asambleaResuelta = true;
            _registrar(
                'Votas a favor de la luz. La asamblea reabre debate. Pasas.');
            break;
          case 'alcalde_combate':
            await _lanzarCombateAsamblea();
            break;
        }
      },
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _lanzarCombateAsamblea() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ModalNarrativoZovnak(
        titulo: 'MOCIÓN APROBADA · COMBATE INMEDIATO',
        cuerpo:
            'La asamblea aprueba por unanimidad procesar al camarada. Dos marcianos votantes alzan papeletas. El Alcalde Provisional sube al estrado con el martillo de basalto.',
        textoBoton: 'DEFENDERSE',
      ),
    );
    if (!mounted) return;
    final resultado = await Navigator.of(context).push<bool>(
      crearRutaConTransicion<bool>(
        PantallaCombate(
          estado: widget.estado,
          tipoEncuentro: TipoEncuentro.asambleaZovnak4,
        ),
      ),
    );
    if (!mounted) return;
    if (resultado == true) {
      widget.estado.activarFlag('asamblea_zovnak4_resuelta');
      widget.estado.activarFlag('venciste_asamblea_zovnak');
      asambleaResuelta = true;
      _registrar(
          'Has disuelto la asamblea por procedimiento. El Alcalde firma su derrota.');
      setState(() {});
    } else {
      widget.estado.activarFlag('asamblea_zovnak4_perdida');
      _registrar(
          'La asamblea aprueba retenerte indefinidamente. Te invitan a votar a favor.');
    }
  }

  void _interactuarUrna() {
    if (!widget.estado.tieneFlag('voto_depositado_zovnak')) {
      widget.estado.activarFlag('voto_depositado_zovnak');
      widget.estado.activarFlag('rumor_pravda7');
      _registrar(
          'Depositas un F-447 en la urna nº 47. Una hoja sale flotando: "PRAVDA-7 · ÚLTIMA SEÑAL · SECTOR SIGMA-NORTE".');
      setState(() {});
      return;
    }
    _contadorVotosEnBlanco++;
    if (_contadorVotosEnBlanco == 5 &&
        !widget.estado.tieneFlag('insignia_voto_marciano')) {
      _registrar(
          'Depositas tu quinta papeleta en blanco. Un Marciano Provisional te susurra sin abrir la boca: «usted es de los nuestros». La cuota burocrática baja una pizca.');
      widget.estado.modificarCuota(-1);
      desbloquearInsigniaSiNueva(
        context,
        estado: widget.estado,
        identificadorFlag: 'insignia_voto_marciano',
      );
      return;
    }
    _registrar(
        'Vuelves a votar en blanco ($_contadorVotosEnBlanco/5). La urna nº 47 acepta papeletas con elegancia minimalista.');
  }

  void _alCodigoSecretoMundoLibre(String identificadorCodigo) {
    if (identificadorCodigo == 'konami_invertido') {
      desbloquearInsigniaSiNueva(
        context,
        estado: widget.estado,
        identificadorFlag: 'insignia_cadete_traidor',
      );
      _registrar(
          'Tres marcianos giran la cabeza al unísono: el cadete acaba de ejecutar movimientos no asamblearios.');
    }
  }

  void _interactuarPancarta() {
    _registrar(
        'La pancarta sigue diciendo "ASAMBLEA PERMANENTE · ZOVNAK-4". Ha sido reaprobada cuatro veces sin cambios.');
  }

  void _interactuarCaboMarciano() {
    if (asambleaResuelta) {
      _registrar(
          'Los marcianos votantes te dejan pasar. Uno te ofrece una papeleta de cortesía.');
      return;
    }
    _registrar(
        'Los marcianos votantes alzan papeletas en cuanto te acercas. Si quieres pasar, habla con el Alcalde primero.');
  }

  void _interactuarCabinaVoto() {
    _registrar(
        'Cabina de votación con cortina raída. Dentro huele a tinta vieja y a indecisión institucional. Una nota a lápiz: «mismo voto que en 1959».');
  }

  void _interactuarEstatuaCaida() {
    _registrar(
        'Estatua tumbada de un marciano histórico. Tres dedos rotos en la mano levantada. La placa: «AL PRIMER VOTANTE». Nadie sabe ya quién fue.');
  }

  void _interactuarCartelMarciano() {
    _registrar(
        'Cartel en lengua marciana oficial. Bajo el ideograma principal, traducción al ruso: «VOTAR ES VIVIR». Bajo la traducción, a navaja: «o algo parecido».');
  }

  void _interactuarAnforaSufragios() {
    _registrar(
        'Ánfora ceremonial repleta de papeletas dobladas. La capa superior es de 1961. La inferior, de 1894. Ninguna ha sido contada.');
  }

  void _interactuarGeiserAzufre() {
    _registrar(
        'Géiser de azufre que erupciona cada catorce minutos. Pequeño cartel atornillado al suelo: «PROHIBIDO ASOCIAR ERUPCIÓN CON DESCONTENTO POLÍTICO».');
  }

  void _interactuarCosmonautaPerdido() {
    _registrar(
        'Un cosmonauta soviético con el casco roto, sentado en un peñasco. No habla. La etiqueta del traje: «I. ZAYTSEV · PRAVDA-7». Lleva diecisiete años esperando relevo.');
  }

  void _volverAlMapa() {
    setState(() {
      _puntoSalida = const Offset(-0.08, 0.86);
      _alCompletarSalida = _viajarAlMapa;
    });
  }

  void _viajarAlMapa() {
    Navigator.of(context).pushReplacement(
      crearRutaConTransicion(
        PantallaTransicionBurocratica(
          codigoInforme: 'INFORME 901-Z · ASCENSO A ÓRBITA',
          tituloInforme: 'REGRESO AL CUADRANTE SIGMA',
          cuerpoInforme:
              'El cadete cierra trámites en Zovnak-4 y asciende a órbita. '
              'La asamblea sigue en sesión, pero esta vez sin moción contra el '
              'titular del visado. El F-447 se conserva en estado nominal de '
              '"presentado con dudas".\n\n'
              'Próxima escala recomendada: revisar mapa galáctico. Posibilidad '
              'de localizar la Pravda-7 si se obtienen tres rumores '
              'concurrentes.',
          selloFinal: 'APROBADO POR EL PARTIDO',
          pantallaDestino: PantallaCuadranteSigma(
            estado: widget.estado,
            planetaDestacado:
                widget.estado.tieneFlag('pista_pravda7_inicial')
                    ? 'pravda7'
                    : null,
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
                      'ZOVNAK-4 · ASAMBLEA PERMANENTE',
                      style: TipografiaPropaganda.tituloSeccion,
                    ),
                    Row(
                      children: [
                        Text(
                          'CUOTA: ${widget.estado.cuotaBurocratica >= 0 ? '+' : ''}${widget.estado.cuotaBurocratica}',
                          style: TipografiaPropaganda.etiquetaBurocratica
                              .copyWith(
                            color: PaletaCosmoSovietica.rojoOficial,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'CADETE · ${widget.estado.personaje.clase?.etiquetaCorta.toUpperCase() ?? "???"}',
                          style: TipografiaPropaganda.etiquetaBurocratica,
                        ),
                      ],
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
                  'Pulsa al Alcalde, a la urna, a un marciano o al suelo. El cadete caminará antes de actuar.',
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
          pintorFondo: PintorEscenarioZovnak4(
            fase: controladorFaseAmbiental.value,
          ),
          rutaImagenFondo: 'assets/images/fondo_zovnak4.png',
          claseJugador: widget.estado.personaje.clase,
          idSombreroEquipado: widget.estado.idObjetoCabezaEquipado,
          idArmaEquipada: widget.estado.idObjetoArmaEquipada,
          idTorsoEquipado: widget.estado.idObjetoTorsoEquipado,
          capaAmbiental: const CapaParticulasAmbientales(
            tipoAmbiente: TipoAmbiente.cenizaVolcanica,
            cantidadParticulas: 80,
          ),
          factorAnchoMundo: 2.4,
          // Desierto agrietado: horizonte en dy≈0.70 (base de las
          // pirámides), suelo agrietado caminable hasta abajo.
          bordeSuperior: 0.70,
          bordeInferior: 0.96,
          posicionInicialJugador: const Offset(0.08, 0.90),
          puntoEntradaInicial: const Offset(-0.03, 0.90),
          puntoSalidaActiva: _puntoSalida,
          onCodigoSecreto: _alCodigoSecretoMundoLibre,
          alCompletarSalida: () {
            final callbackSalida = _alCompletarSalida;
            _alCompletarSalida = null;
            _puntoSalida = null;
            callbackSalida?.call();
          },
          hotspots: [
            // Marcianos votantes y elemento principal del mitin, ahora
            // distribuidos a lo largo del mundo extendido.
            HotspotEscenario(
              identificador: 'marciano_izq',
              posicionRelativa: const Offset(0.18, 0.86),
              anchoRelativo: 0.1,
              altoRelativo: 0.3,
              radioInteraccion: 0.13,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/npc_marciano_votante.png',
                anchoSombra: 80,
              ),
              onInteractuar: _interactuarCaboMarciano,
            ),
            HotspotEscenario(
              identificador: 'urna',
              posicionRelativa: const Offset(0.32, 0.62),
              anchoRelativo: 0.08,
              altoRelativo: 0.16,
              radioInteraccion: 0.12,
              destacar: !widget.estado.tieneFlag('voto_depositado_zovnak'),
              representacion: const Stack(
                children: [
                  Positioned.fill(
                    child: IconoHotspotImagen(
                      rutaAsset: 'assets/svg/mueble_urna_zovnak.png',
                      anchoSombra: 80,
                    ),
                  ),
                  Positioned.fill(
                    child: EfectoPapeletasSaltando(),
                  ),
                ],
              ),
              onInteractuar: _interactuarUrna,
            ),
            HotspotEscenario(
              identificador: 'alcalde',
              posicionRelativa: const Offset(0.46, 0.8),
              anchoRelativo: 0.12,
              altoRelativo: 0.36,
              radioInteraccion: 0.16,
              destacar: !asambleaResuelta,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/npc_marciano_votante.png',
                anchoSombra: 80,
              ),
              onInteractuar: _hablarConAlcalde,
            ),
            HotspotEscenario(
              identificador: 'marciano_der',
              posicionRelativa: const Offset(0.6, 0.86),
              anchoRelativo: 0.1,
              altoRelativo: 0.3,
              radioInteraccion: 0.13,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/npc_marciano_votante.png',
                anchoSombra: 80,
              ),
              onInteractuar: _interactuarCaboMarciano,
            ),
            HotspotEscenario(
              identificador: 'pancarta',
              posicionRelativa: const Offset(0.42, 0.08),
              anchoRelativo: 0.7,
              altoRelativo: 0.1,
              radioInteraccion: 0.18,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarPancarta,
            ),
            // Decorativos en la mitad derecha del mundo extendido.
            HotspotEscenario(
              identificador: 'mitin_lejano_izq',
              posicionRelativa: const Offset(0.74, 0.86),
              anchoRelativo: 0.05,
              altoRelativo: 0.17,
              radioInteraccion: 0,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/npc_marciano_votante.png',
                anchoSombra: 80,
              ),
            ),
            HotspotEscenario(
              identificador: 'mitin_lejano_centro',
              posicionRelativa: const Offset(0.79, 0.88),
              anchoRelativo: 0.04,
              altoRelativo: 0.14,
              radioInteraccion: 0,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/npc_marciano_votante.png',
                anchoSombra: 80,
              ),
            ),
            HotspotEscenario(
              identificador: 'mitin_lejano_der',
              posicionRelativa: const Offset(0.85, 0.87),
              anchoRelativo: 0.05,
              altoRelativo: 0.17,
              radioInteraccion: 0,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/npc_marciano_votante.png',
                anchoSombra: 80,
              ),
            ),
            HotspotEscenario(
              identificador: 'mitin_horizonte',
              posicionRelativa: const Offset(0.93, 0.89),
              anchoRelativo: 0.035,
              altoRelativo: 0.12,
              radioInteraccion: 0,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/npc_marciano_votante.png',
                anchoSombra: 28,
              ),
            ),
            HotspotEscenario(
              identificador: 'columna_humo_volcan_a',
              posicionRelativa: const Offset(0.7, 0.42),
              anchoRelativo: 0.08,
              altoRelativo: 0.55,
              radioInteraccion: 0,
              representacion: EfectoHumoAscendente(
                cantidadPlumas: 10,
                tinte: PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.8),
                anchoZonaEmision: 0.35,
                altoEmpuje: 1.2,
              ),
            ),
            HotspotEscenario(
              identificador: 'columna_humo_volcan_b',
              posicionRelativa: const Offset(0.88, 0.46),
              anchoRelativo: 0.07,
              altoRelativo: 0.5,
              radioInteraccion: 0,
              representacion: EfectoHumoAscendente(
                cantidadPlumas: 8,
                tinte: PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.73),
                anchoZonaEmision: 0.3,
                altoEmpuje: 1.15,
              ),
            ),
            // ─── Hotspots de sabor ───────────────────────────────────
            HotspotEscenario(
              identificador: 'cabina_voto',
              posicionRelativa: const Offset(0.27, 0.5),
              anchoRelativo: 0.05,
              altoRelativo: 0.36,
              radioInteraccion: 0.08,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarCabinaVoto,
            ),
            HotspotEscenario(
              identificador: 'estatua_caida',
              posicionRelativa: const Offset(0.40, 0.92),
              anchoRelativo: 0.08,
              altoRelativo: 0.06,
              radioInteraccion: 0.08,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarEstatuaCaida,
            ),
            HotspotEscenario(
              identificador: 'cartel_marciano',
              posicionRelativa: const Offset(0.55, 0.20),
              anchoRelativo: 0.07,
              altoRelativo: 0.12,
              radioInteraccion: 0.08,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarCartelMarciano,
            ),
            HotspotEscenario(
              identificador: 'anfora_sufragios',
              posicionRelativa: const Offset(0.66, 0.78),
              anchoRelativo: 0.05,
              altoRelativo: 0.12,
              radioInteraccion: 0.08,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarAnforaSufragios,
            ),
            HotspotEscenario(
              identificador: 'geiser_azufre',
              posicionRelativa: const Offset(0.78, 0.92),
              anchoRelativo: 0.05,
              altoRelativo: 0.08,
              radioInteraccion: 0.07,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarGeiserAzufre,
            ),
            HotspotEscenario(
              identificador: 'cosmonauta_perdido',
              posicionRelativa: const Offset(0.96, 0.84),
              anchoRelativo: 0.05,
              altoRelativo: 0.18,
              radioInteraccion: 0.08,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarCosmonautaPerdido,
            ),
            // Puerto esclusa de aterrizaje, mirando a la entrada del
            // planeta. Decorativo pero clicable: recuerda al cadete por
            // dónde llegó y por dónde se vuelve.
            HotspotEscenario(
              identificador: 'puerto_esclusa_zovnak',
              posicionRelativa: const Offset(0.05, 0.74),
              anchoRelativo: 0.10,
              altoRelativo: 0.34,
              radioInteraccion: 0.10,
              etiquetaAccion: 'EXAMINAR',
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/mueble_puerto_esclusa.png',
                anchoSombra: 80,
              ),
              onInteractuar: () => _registrar(
                'Puerto esclusa de aterrizaje. Por aquí descendió tu '
                'cápsula. Una etiqueta oxidada dice «SALIDA · Cuadrante '
                'Sigma». Hace 47 años que nadie la limpia.',
              ),
            ),
            if (_papeletasKReveladas)
              HotspotEscenario(
                identificador: 'papeletas_k_zovnak',
                posicionRelativa: const Offset(0.27, 0.92),
                anchoRelativo: 0.05,
                altoRelativo: 0.04,
                radioInteraccion: 0.07,
                representacion: const SizedBox.shrink(),
                animarRespiracion: false,
                onInteractuar: () => _registrar(
                  'Fajo de papeletas con la letra «K» tachada con savia '
                  'marciana espesa. Quien votó en la urna 47, lo hizo con la '
                  'firma de Krilov falsificada. El expediente engorda.',
                ),
              ),
          ],
          objetosEmpujables: [_fardoPapeletasK],
        ),
      ),
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
          const Text('CRÓNICA DEL DESCENSO',
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
                      'Polvo rojizo. Dos soles. La urna nº 47 zumba con cuarenta años de votos. La asamblea no se calla.',
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
          if (asambleaResuelta) ...[
            const Divider(color: PaletaCosmoSovietica.tintaNegra, height: 1),
            const SizedBox(height: 6),
            BotonPropaganda(
              texto: 'Volver a la Pravda-12',
              compacto: true,
              destacado: true,
              onPressed: _volverAlMapa,
            ),
            const SizedBox(height: 6),
          ],
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


class _ModalNarrativoZovnak extends StatelessWidget {
  final String titulo;
  final String cuerpo;
  final String textoBoton;

  const _ModalNarrativoZovnak({
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
        constraints: const BoxConstraints(maxWidth: 600),
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
