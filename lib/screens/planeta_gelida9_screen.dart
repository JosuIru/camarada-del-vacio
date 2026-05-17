import 'package:flutter/material.dart';
import '../data/dialogues_jefe_gelida.dart';
import '../data/encounters.dart';
import '../data/huevos_de_pascua.dart';
import '../models/game_class.dart';
import '../models/game_state.dart';
import '../painters/gelida9_scene_painter.dart';
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

class PantallaPlanetaGelida9 extends StatefulWidget {
  final EstadoJuego estado;

  const PantallaPlanetaGelida9({super.key, required this.estado});

  @override
  State<PantallaPlanetaGelida9> createState() =>
      _PantallaPlanetaGelida9State();
}

class _PantallaPlanetaGelida9State extends State<PantallaPlanetaGelida9>
    with SingleTickerProviderStateMixin {
  final List<String> registroAcciones = [];
  late AnimationController controladorFaseAmbiental;
  late bool esRevisitaInicial;
  bool pasoGelidaConcedido = false;
  Offset? _puntoSalida;
  VoidCallback? _alCompletarSalida;

  int _contadorPulsacionesOciosas = 0;

  // Pared de F-447 congelados que sólo cede al impacto del cadete-bola
  // a velocidad elevada. Detrás aparece un Pingüino Burocrático que
  // estampa un visado de cortesía (−1 cuota).
  late final ParedDebilEscenario _muroFormulariosCongelados;
  bool _pinguinoVisible = false;

  @override
  void initState() {
    super.initState();
    esRevisitaInicial = widget.estado.esRevisita('gelida9');
    widget.estado.registrarVisitaModulo('gelida9');
    pasoGelidaConcedido =
        widget.estado.tieneFlag('paso_gelida_concedido');
    _pinguinoVisible =
        widget.estado.tieneFlag('insignia_pinguino_burocratico');
    controladorFaseAmbiental = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _muroFormulariosCongelados = ParedDebilEscenario(
      identificador: 'muro_f447_congelados',
      rect: const Rect.fromLTWH(0.84, 0.78, 0.06, 0.16),
      etiqueta: 'F-447 HELADOS',
      onRomperse: () {
        if (!mounted) return;
        setState(() => _pinguinoVisible = true);
        desencadenarHuevoPascua(
          context,
          estado: widget.estado,
          idHuevo: 'pinguino_burocratico',
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
        builder: (_) => _ModalNarrativoGelida(
          titulo: 'GÉLIDA-9 · REGRESO',
          cuerpo: pasoGelidaConcedido
              ? 'Vuelves a Gélida-9. La cola sigue inmóvil desde 1968, pero el Jefe de Recepción te reconoce. Tu pase provisional de emergencia sigue vigente.'
              : 'Vuelves a Gélida-9. El frío administrativo no perdona. El mostrador del Jefe sigue ahí, escarchado, esperando los 47 formularios F-447.',
          textoBoton: 'CONTINUAR',
        ),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ModalNarrativoGelida(
        titulo: 'GÉLIDA-9 · LUNA DE BUROCRACIA CONGELADA · 1962',
        cuerpo:
            'Aterrizas en Gélida-9. −180 °C. La aurora boreal oficial está aprobada por el Sindicato Estelar. Una cola de burócratas congelados se extiende desde 1968 ante un mostrador escarchado. Cartel: "F-447 · 47 COPIAS".\n\nEl Jefe de Recepción te mira con vaho institucional. Llevas exactamente una (1) copia.\n\nMisión opcional: obtener la segunda pista canónica sobre la Pravda-7.',
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

  void _alCodigoSecretoMundoLibre(String identificadorCodigo) {
    if (identificadorCodigo == 'konami_invertido') {
      desbloquearInsigniaSiNueva(
        context,
        estado: widget.estado,
        identificadorFlag: 'insignia_cadete_traidor',
      );
      _registrar(
          'La nieve burocrática se queda muy quieta. Algo, bajo el hielo, te ha anotado.');
    }
  }

  void _alPulsacionInteraccionOciosa() {
    _contadorPulsacionesOciosas++;
    if (_contadorPulsacionesOciosas == 12 &&
        !widget.estado.tieneFlag('insignia_tipo_glacial')) {
      desbloquearInsigniaSiNueva(
        context,
        estado: widget.estado,
        identificadorFlag: 'insignia_tipo_glacial',
      );
      _registrar(
          'Tu doceava tramitación contra la nada glacial despierta una insignia helada. El formulario se congela en el aire.');
    }
  }

  Future<void> _abrirInventario() async {
    await mostrarDialogoInventario(context, estado: widget.estado);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _hablarConJefe() async {
    await mostrarPanelDialogo(
      context,
      conversacion: conversacionConJefeGelida,
      estado: widget.estado,
      onConsecuencia: (consecuencia) async {
        switch (consecuencia) {
          case 'paso_gelida_concedido':
            widget.estado.activarFlag('paso_gelida_concedido');
            widget.estado.activarFlag('rumor_pravda7_fragmento2');
            widget.estado.anadirObjeto('fragmento_bitacora_pravda7_2');
            pasoGelidaConcedido = true;
            _registrar(
                'Recibes el FRAGMENTO 2 DE 3 de la bitácora de la Pravda-7. Pase concedido.');
            break;
          case 'gelida_combate':
            await _lanzarCombateRecepcion();
            break;
        }
      },
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _lanzarCombateRecepcion() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ModalNarrativoGelida(
        titulo: 'DESCONGELACIÓN PROCEDIMENTAL',
        cuerpo:
            'El Comité de Bienvenida activa a dos burócratas congelados en posición defensiva. El Jefe de Recepción desenvaina un sello escarchado. La temperatura baja otros tres grados.',
        textoBoton: 'DEFENDERSE',
      ),
    );
    if (!mounted) return;
    final resultado = await Navigator.of(context).push<bool>(
      crearRutaConTransicion<bool>(
        PantallaCombate(
          estado: widget.estado,
          tipoEncuentro: TipoEncuentro.recepcionGelida9,
        ),
      ),
    );
    if (!mounted) return;
    if (resultado == true) {
      widget.estado.activarFlag('paso_gelida_concedido');
      widget.estado.activarFlag('venciste_recepcion_gelida');
      widget.estado.activarFlag('rumor_pravda7_fragmento2');
      widget.estado.anadirObjeto('fragmento_bitacora_pravda7_2');
      pasoGelidaConcedido = true;
      _registrar(
          'El Jefe firma un "PASE PROVISIONAL DE EMERGENCIA". Recibes el FRAGMENTO 2 DE 3 de la bitácora.');
      setState(() {});
    } else {
      widget.estado.activarFlag('gelida_cola_eterna');
      _registrar(
          'Te ofrecen un asiento congelado en la cola. Lo aceptas a tu pesar.');
    }
  }

  void _interactuarColaCongelada() {
    _registrar(
        'La cola lleva inmóvil desde 1968. Un burócrata parpadea cada tres horas. No es desagradable, exactamente.');
  }

  void _interactuarPancarta() {
    _registrar(
        'Pancarta: "COMITÉ DE BIENVENIDA · EN SESIÓN DESDE 1968". Aprobada cinco veces sin cambios.');
  }

  void _interactuarFormularioCongelado() {
    _registrar(
        'Un formulario F-447 a medio rellenar, congelado en el aire a 30 cm del suelo. La pluma sigue suspendida. Si lo tocas, cae al suelo y se rompe en cristales.');
  }

  void _interactuarKioscoF447() {
    _registrar(
        'Kiosco autoexpendedor de formularios F-447. Cartel: «1 copia · 1 rublo · INDISPONIBLE DESDE 1971». La ranura está obturada por nieve histórica.');
  }

  void _interactuarEstatuaDirectorskov() {
    _registrar(
        'Estatua del Camarada Directorskov, dedo extendido hacia un horizonte que ya no existe. La base reza: «EL QUE PULSÓ POR TODOS». Alguien ha tallado con uña una segunda línea: «contra su voluntad».');
  }

  void _interactuarKvasHelado() {
    _registrar(
        'Una botella de kvas tirada en el hielo, abierta, con burbujas congeladas a medio escapar. La etiqueta dice «PARA CELEBRAR EL REGRESO». La fecha de envasado: 1962.');
  }

  void _interactuarOsoPolarNominal() {
    _registrar(
        'Lo que parece un oso polar a lo lejos. No respira. Cuando te acercas, ves la chapa: «UNIDAD CB-7 · OSO POLAR NOMINAL DEL SINDICATO». Modelo congelado por reglamento.');
  }

  void _interactuarCabinaCaldera() {
    _registrar(
        'Cabina de calefacción individual. La caldera, apagada desde 1968 por «consumo excesivo de carbón». Dentro, un esqueleto en posición laboral correcta.');
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
          codigoInforme: 'INFORME 902-G · ASCENSO DESDE GÉLIDA-9',
          tituloInforme: 'REGRESO AL CUADRANTE SIGMA',
          cuerpoInforme:
              'El cadete abandona Gélida-9 con o sin pase provisional. '
              'La cola le sigue con la mirada (donde aún les responde la '
              'mirada). El termómetro registra que la operación duró menos '
              'que la media histórica del planeta.\n\n'
              'Si se obtuvo el FRAGMENTO 2 DE 3 de la bitácora de la '
              'Pravda-7, la Pravda-7 se hace marginalmente más localizable. '
              'Falta el FRAGMENTO 3 (origen desconocido).',
          selloFinal: 'APROBADO POR EL PARTIDO',
          pantallaDestino: PantallaCuadranteSigma(
            estado: widget.estado,
            planetaDestacado: widget.estado.tieneFlag('rumor_pravda7_fragmento2')
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
                      'GÉLIDA-9 · LUNA DE BUROCRACIA CONGELADA',
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
                  'Pulsa al Jefe, a la cola, a la pancarta o al suelo. El cadete caminará antes de actuar.',
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
          pintorFondo: PintorEscenarioGelida9(
            fase: controladorFaseAmbiental.value,
          ),
          rutaImagenFondo: 'assets/images/fondo_gelida9.png',
          claseJugador: widget.estado.personaje.clase,
          idSombreroEquipado: widget.estado.idObjetoCabezaEquipado,
          idArmaEquipada: widget.estado.idObjetoArmaEquipada,
          idTorsoEquipado: widget.estado.idObjetoTorsoEquipado,
          capaAmbiental: const CapaParticulasAmbientales(
            tipoAmbiente: TipoAmbiente.nieveCristalina,
            cantidadParticulas: 95,
          ),
          factorAnchoMundo: 2.5,
          posicionInicialJugador: const Offset(0.05, 0.88),
          puntoEntradaInicial: const Offset(-0.02, 0.88),
          puntoSalidaActiva: _puntoSalida,
          onCodigoSecreto: _alCodigoSecretoMundoLibre,
          onPulsacionInteraccionOciosa: _alPulsacionInteraccionOciosa,
          alCompletarSalida: () {
            final callbackSalida = _alCompletarSalida;
            _alCompletarSalida = null;
            _puntoSalida = null;
            callbackSalida?.call();
          },
          hotspots: [
            HotspotEscenario(
              identificador: 'cola_izq_1',
              posicionRelativa: const Offset(0.16, 0.86),
              anchoRelativo: 0.1,
              altoRelativo: 0.3,
              radioInteraccion: 0.12,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/npc_burocrata_congelado.png',
                anchoSombra: 80,
              ),
              onInteractuar: _interactuarColaCongelada,
            ),
            HotspotEscenario(
              identificador: 'cola_izq_2',
              posicionRelativa: const Offset(0.26, 0.88),
              anchoRelativo: 0.09,
              altoRelativo: 0.28,
              radioInteraccion: 0.11,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/npc_burocrata_congelado.png',
                anchoSombra: 80,
              ),
              onInteractuar: _interactuarColaCongelada,
            ),
            HotspotEscenario(
              identificador: 'jefe_recepcion',
              posicionRelativa: const Offset(0.42, 0.82),
              anchoRelativo: 0.12,
              altoRelativo: 0.34,
              radioInteraccion: 0.16,
              destacar: !pasoGelidaConcedido,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/npc_burocrata_congelado.png',
                anchoSombra: 80,
              ),
              onInteractuar: _hablarConJefe,
            ),
            HotspotEscenario(
              identificador: 'pancarta',
              posicionRelativa: const Offset(0.36, 0.08),
              anchoRelativo: 0.7,
              altoRelativo: 0.1,
              radioInteraccion: 0.18,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarPancarta,
            ),
            HotspotEscenario(
              identificador: 'vaho_burocrata_izq',
              posicionRelativa: const Offset(0.16, 0.7),
              anchoRelativo: 0.08,
              altoRelativo: 0.18,
              radioInteraccion: 0,
              representacion: EfectoHumoAscendente(
                cantidadPlumas: 4,
                tinte: PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.8),
                anchoZonaEmision: 0.25,
                altoEmpuje: 0.7,
              ),
            ),
            HotspotEscenario(
              identificador: 'vaho_burocrata_der',
              posicionRelativa: const Offset(0.26, 0.74),
              anchoRelativo: 0.08,
              altoRelativo: 0.18,
              radioInteraccion: 0,
              representacion: EfectoHumoAscendente(
                cantidadPlumas: 4,
                tinte: PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.8),
                anchoZonaEmision: 0.22,
                altoEmpuje: 0.7,
              ),
            ),
            // Decoración del flanco derecho: cola burocrática lejana
            // congelada (más burócratas + vaho), evocando que la fila se
            // pierde en el horizonte de hielo.
            HotspotEscenario(
              identificador: 'cola_lejana_1',
              posicionRelativa: const Offset(0.6, 0.86),
              anchoRelativo: 0.07,
              altoRelativo: 0.22,
              radioInteraccion: 0,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/npc_burocrata_congelado.png',
                anchoSombra: 80,
              ),
            ),
            HotspotEscenario(
              identificador: 'cola_lejana_2',
              posicionRelativa: const Offset(0.7, 0.88),
              anchoRelativo: 0.06,
              altoRelativo: 0.2,
              radioInteraccion: 0,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/npc_burocrata_congelado.png',
                anchoSombra: 80,
              ),
            ),
            HotspotEscenario(
              identificador: 'cola_lejana_3',
              posicionRelativa: const Offset(0.79, 0.89),
              anchoRelativo: 0.055,
              altoRelativo: 0.18,
              radioInteraccion: 0,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/npc_burocrata_congelado.png',
                anchoSombra: 80,
              ),
            ),
            HotspotEscenario(
              identificador: 'cola_lejana_4',
              posicionRelativa: const Offset(0.88, 0.9),
              anchoRelativo: 0.045,
              altoRelativo: 0.15,
              radioInteraccion: 0,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/npc_burocrata_congelado.png',
                anchoSombra: 80,
              ),
            ),
            HotspotEscenario(
              identificador: 'cola_horizonte',
              posicionRelativa: const Offset(0.94, 0.91),
              anchoRelativo: 0.035,
              altoRelativo: 0.13,
              radioInteraccion: 0,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/npc_burocrata_congelado.png',
                anchoSombra: 80,
              ),
            ),
            HotspotEscenario(
              identificador: 'vaho_cola_lejana_a',
              posicionRelativa: const Offset(0.66, 0.7),
              anchoRelativo: 0.14,
              altoRelativo: 0.2,
              radioInteraccion: 0,
              representacion: EfectoHumoAscendente(
                cantidadPlumas: 5,
                tinte: PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.8),
                anchoZonaEmision: 0.4,
                altoEmpuje: 0.65,
              ),
            ),
            HotspotEscenario(
              identificador: 'vaho_cola_lejana_b',
              posicionRelativa: const Offset(0.88, 0.72),
              anchoRelativo: 0.12,
              altoRelativo: 0.18,
              radioInteraccion: 0,
              representacion: EfectoHumoAscendente(
                cantidadPlumas: 4,
                tinte: PaletaCosmoSovietica.papelSombra.withValues(alpha: 0.73),
                anchoZonaEmision: 0.35,
                altoEmpuje: 0.6,
              ),
            ),
            // ─── Hotspots de sabor ───────────────────────────────────
            HotspotEscenario(
              identificador: 'formulario_congelado',
              posicionRelativa: const Offset(0.10, 0.92),
              anchoRelativo: 0.04,
              altoRelativo: 0.04,
              radioInteraccion: 0.06,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarFormularioCongelado,
            ),
            HotspotEscenario(
              identificador: 'kiosco_f447',
              posicionRelativa: const Offset(0.34, 0.66),
              anchoRelativo: 0.06,
              altoRelativo: 0.14,
              radioInteraccion: 0.08,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarKioscoF447,
            ),
            HotspotEscenario(
              identificador: 'estatua_directorskov',
              posicionRelativa: const Offset(0.50, 0.55),
              anchoRelativo: 0.07,
              altoRelativo: 0.34,
              radioInteraccion: 0.10,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarEstatuaDirectorskov,
            ),
            HotspotEscenario(
              identificador: 'kvas_helado',
              posicionRelativa: const Offset(0.57, 0.86),
              anchoRelativo: 0.05,
              altoRelativo: 0.08,
              radioInteraccion: 0.07,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarKvasHelado,
            ),
            HotspotEscenario(
              identificador: 'oso_polar_nominal',
              posicionRelativa: const Offset(0.85, 0.65),
              anchoRelativo: 0.07,
              altoRelativo: 0.16,
              radioInteraccion: 0.10,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarOsoPolarNominal,
            ),
            HotspotEscenario(
              identificador: 'cabina_caldera',
              posicionRelativa: const Offset(0.98, 0.5),
              anchoRelativo: 0.04,
              altoRelativo: 0.4,
              radioInteraccion: 0.07,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarCabinaCaldera,
            ),
            if (_pinguinoVisible)
              HotspotEscenario(
                identificador: 'pinguino_visado',
                posicionRelativa: const Offset(0.88, 0.86),
                anchoRelativo: 0.09,
                altoRelativo: 0.20,
                radioInteraccion: 0.10,
                etiquetaAccion: 'HABLAR',
                representacion: const IconoHotspotImagen(
                  rutaAsset: 'assets/svg/npc_pinguino_burocratico.png',
                  anchoSombra: 70,
                ),
                animarRespiracion: true,
                onInteractuar: () => _registrar(
                  'Donde antes había muro de F-447 congelados, sólo queda un '
                  'pingüino oficial sentado sobre un cajón. Te mira con '
                  'profesionalidad polar. Tu visado ya está estampado.',
                ),
              ),
          ],
          paredesDebiles: [_muroFormulariosCongelados],
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
          const Text('CRÓNICA DE GÉLIDA-9',
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
                      'Vaho, sellos escarchados, formularios congelados al vuelo. La cola del Comité de Bienvenida lleva quieta desde 1968.',
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
          const Divider(color: PaletaCosmoSovietica.tintaNegra, height: 1),
          const SizedBox(height: 6),
          BotonPropaganda(
            texto: 'Volver al Cuadrante Sigma',
            compacto: true,
            destacado: true,
            onPressed: _volverAlMapa,
          ),
          const SizedBox(height: 6),
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

class _ModalNarrativoGelida extends StatelessWidget {
  final String titulo;
  final String cuerpo;
  final String textoBoton;

  const _ModalNarrativoGelida({
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
