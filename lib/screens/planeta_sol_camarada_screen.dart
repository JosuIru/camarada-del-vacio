import 'package:flutter/material.dart';
import '../data/dialogues_delegado_solar.dart';
import '../data/encounters.dart';
import '../data/huevos_de_pascua.dart';
import '../models/game_class.dart';
import '../models/game_state.dart';
import '../painters/sol_camarada_scene_painter.dart';
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

class PantallaPlanetaSolCamarada extends StatefulWidget {
  final EstadoJuego estado;

  const PantallaPlanetaSolCamarada({super.key, required this.estado});

  @override
  State<PantallaPlanetaSolCamarada> createState() =>
      _PantallaPlanetaSolCamaradaState();
}

class _PantallaPlanetaSolCamaradaState
    extends State<PantallaPlanetaSolCamarada>
    with SingleTickerProviderStateMixin {
  final List<String> registroAcciones = [];
  late AnimationController controladorFaseAmbiental;
  late bool esRevisitaInicial;
  bool negociacionResuelta = false;
  Offset? _puntoSalida;
  VoidCallback? _alCompletarSalida;

  // Cristalera sindical: pared rompible. Cuando se rompe, el Delegado
  // aplaude tres veces y se abre un atajo a la sala de actas.
  late final ParedDebilEscenario _cristaleraSindical;
  bool _atajoActasAbierto = false;

  @override
  void initState() {
    super.initState();
    esRevisitaInicial = widget.estado.esRevisita('sol_camarada');
    widget.estado.registrarVisitaModulo('sol_camarada');
    negociacionResuelta =
        widget.estado.tieneFlag('solar_negociacion_resuelta');
    _atajoActasAbierto =
        widget.estado.tieneFlag('insignia_huelga_silenciosa');
    controladorFaseAmbiental = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _cristaleraSindical = ParedDebilEscenario(
      identificador: 'cristalera_sindical',
      rect: const Rect.fromLTWH(0.88, 0.72, 0.06, 0.18),
      etiqueta: 'CRISTALERA',
      onRomperse: () {
        if (!mounted) return;
        setState(() => _atajoActasAbierto = true);
        desencadenarHuevoPascua(
          context,
          estado: widget.estado,
          idHuevo: 'huelga_silenciosa',
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
        builder: (_) => _ModalNarrativoSolar(
          titulo: 'SOL CAMARADA · REGRESO',
          cuerpo: negociacionResuelta
              ? 'Vuelves a la plataforma orbital frente al Sol Camarada. La pancarta de HUELGA ya no está. El Delegado te saluda con una mezcla de cordialidad y formulario.'
              : 'Vuelves a la plataforma orbital. El Sol gruñe por el altavoz. El Delegado te recibe con el maletín dorado todavía cerrado.',
          textoBoton: 'CONTINUAR',
        ),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ModalNarrativoSolar(
        titulo: 'SOL CAMARADA · ESTRELLA SINDICALIZADA · 1962',
        cuerpo:
            'La Pravda-12 atraca en una plataforma orbital al borde del Sistema. Ventana panorámica. Detrás del cristal, un sol con cara enfurruñada sostiene una pancarta de HUELGA. Frente a ti, un Delegado Sindical Solar abre un maletín dorado.\n\nMisión opcional: obtener el último fragmento de la bitácora de la Pravda-7 (FRAGMENTO 3 DE 3).',
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
          'Los Delegados Sindicales dejan de cantar durante un instante; el cadete acaba de coreografiar una secuencia anti-soviética bajo dos soles a la vez.');
    }
  }

  void _alCadeteQuietoLargoRato() {
    if (widget.estado.tieneFlag('insignia_cara_al_sol')) return;
    desbloquearInsigniaSiNueva(
      context,
      estado: widget.estado,
      identificadorFlag: 'insignia_cara_al_sol',
    );
    _registrar(
        'Cuatro segundos sin parpadear bajo los dos soles. El sol te mira de vuelta. El Estado anota tu firmeza retiniana.');
  }

  Future<void> _abrirInventario() async {
    await mostrarDialogoInventario(context, estado: widget.estado);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _hablarConDelegado() async {
    await mostrarPanelDialogo(
      context,
      conversacion: conversacionConDelegadoSolar,
      estado: widget.estado,
      onConsecuencia: (consecuencia) async {
        switch (consecuencia) {
          case 'solar_acuerdo':
            widget.estado.activarFlag('solar_negociacion_resuelta');
            widget.estado.activarFlag('solar_acuerdo_aceptado');
            widget.estado.activarFlag('rumor_pravda7_fragmento3');
            widget.estado.anadirObjeto('fragmento_bitacora_pravda7_3');
            widget.estado.modificarCuota(1);
            negociacionResuelta = true;
            _registrar(
                'Acuerdo sindical firmado. Recibes el FRAGMENTO 3 DE 3 de la bitácora. Cuota +1.');
            break;
          case 'solar_sabotaje':
            widget.estado.activarFlag('solar_negociacion_resuelta');
            widget.estado.activarFlag('solar_altavoz_saboteado');
            widget.estado.activarFlag('rumor_pravda7_fragmento3');
            widget.estado.anadirObjeto('fragmento_bitacora_pravda7_3');
            widget.estado.modificarCuota(-1);
            negociacionResuelta = true;
            _registrar(
                'Saboteas el altavoz solar. Recibes el FRAGMENTO 3 DE 3 de la bitácora. Cuota −1.');
            break;
          case 'solar_combate':
            await _lanzarCombateSindical();
            break;
        }
      },
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _lanzarCombateSindical() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ModalNarrativoSolar(
        titulo: 'INSPECTORES SINDICALES · ALERTA',
        cuerpo:
            'Dos Inspectores Sindicales irrumpen por las dos compuertas laterales. El Delegado abre su maletín y vuelca cuatro hojas oficiales sobre la mesa.',
        textoBoton: 'DEFENDERSE',
      ),
    );
    if (!mounted) return;
    final resultado = await Navigator.of(context).push<bool>(
      crearRutaConTransicion<bool>(
        PantallaCombate(
          estado: widget.estado,
          tipoEncuentro: TipoEncuentro.huelgaSolar,
        ),
      ),
    );
    if (!mounted) return;
    if (resultado == true) {
      widget.estado.activarFlag('solar_negociacion_resuelta');
      widget.estado.activarFlag('venciste_delegacion_solar');
      widget.estado.activarFlag('rumor_pravda7_fragmento3');
      widget.estado.anadirObjeto('fragmento_bitacora_pravda7_3');
      widget.estado.modificarCuota(-2);
      negociacionResuelta = true;
      _registrar(
          'Has reventado la negociación. Recibes el FRAGMENTO 3 DE 3 de la bitácora. Cuota −2.');
      setState(() {});
    } else {
      widget.estado.activarFlag('solar_carnet_obligatorio');
      _registrar(
          'Te dan un carné sindical con número de cinco cifras. Estás técnicamente afiliado al Sol.');
    }
  }

  void _interactuarAltavoz() {
    if (widget.estado.tieneFlag('solar_altavoz_saboteado')) {
      _registrar(
          'El altavoz solar está descolgado. El Sol Camarada solo gruñe por las junturas de la ventana.');
      return;
    }
    _registrar(
        'El altavoz solar reproduce, fielmente, los gruñidos de la estrella en huelga. Una grabación dice "y descansos pagados, y descansos pagados, y descansos pagados…".');
  }

  void _interactuarPanelSindical() {
    _registrar(
        'Panel SESG · 7-B. Tres diales miden: "voluntad de huelga" (alta), "claridad del comunicado" (baja) y "café" (vacío).');
  }

  void _interactuarEspejoRetroreflector() {
    _registrar(
        'Espejo gigante retroreflector. Devuelve la luz al Sol Camarada con un desfase exacto de 4 segundos. La placa: «POR ORDEN DEL PARTIDO · NO PERDEMOS NI UN FOTÓN».');
  }

  void _interactuarDunaCalcinada() {
    _registrar(
        'Duna de arena vitrificada. Bajo la costra: la silueta exacta de un cosmonauta tendido, brazos en cruz. La marca dice «MÁRTIR DEL TURNO DE MEDIODÍA».');
  }

  void _interactuarManifiestoSolar() {
    _registrar(
        'Cartel del Manifiesto Solar: «EL SOL CAMARADA SE QUEMA POR USTED». Pintado en una época en que aún se creía que la consigna sólo era literaria.');
  }

  void _interactuarTanqueProtones() {
    _registrar(
        'Tanque de protones embotellados, etiqueta «COSECHA 1959». Una válvula gotea unidades subatómicas que se desintegran antes de tocar el suelo.');
  }

  void _interactuarSombraInversa() {
    _registrar(
        'En el suelo, una sombra que va en dirección contraria al sol. No tiene cuerpo que la proyecte. Llevamos varias generaciones sin discutirlo.');
  }

  void _interactuarRelojDeSol() {
    _registrar(
        'Reloj de sol monumental. La sombra del gnomon marca las 4:47, y allí permanece desde hace dieciséis años. El sol gira, la sombra no.');
  }

  void _interactuarPapeles() {
    _registrar(
        'Cuatro papeles oficiales en la mesa de negociación. Todos rojos. Uno se titula "PLIEGO DE CONDICIONES DEL SOL CAMARADA, EXTRACTO".');
  }

  void _volverAlMapa() {
    setState(() {
      _puntoSalida = const Offset(-0.08, 0.86);
      _alCompletarSalida = _viajarAlMapa;
    });
  }

  void _viajarAlMapa() {
    // La pista inicial llega del reactor (Vostrikova). Los fragmentos
    // 2 y 3 son los de Gélida-9 y Sol Camarada — y este último es el
    // que activa la triangulación al regresar al mapa.
    final tieneTresFragmentos = widget.estado
            .tieneFlag('pista_pravda7_inicial') &&
        widget.estado.tieneFlag('rumor_pravda7_fragmento2') &&
        widget.estado.tieneFlag('rumor_pravda7_fragmento3');
    if (tieneTresFragmentos) {
      widget.estado.activarFlag('pravda7_localizable');
    }
    Navigator.of(context).pushReplacement(
      crearRutaConTransicion(
        PantallaTransicionBurocratica(
          codigoInforme: 'INFORME 903-S · DESATAQUE ORBITAL',
          tituloInforme: 'REGRESO AL CUADRANTE SIGMA',
          cuerpoInforme:
              'El cadete desatraca de la plataforma orbital del Sol Camarada. '
              'El Sindicato Estelar Galáctico (Rama 7-B) consigna el episodio '
              'como "incidente del calor moderado". El Sol vuelve a producir '
              'fotones reglamentarios.\n\n'
              '${tieneTresFragmentos ? "Con los tres fragmentos de la bitácora reunidos, la Pravda-7 deja de ser un rumor: aparece en el plano del Cuadrante con coordenadas tentativas." : "Faltan ${3 - _contarFragmentosPravda7()} fragmento(s) para localizar la Pravda-7."}',
          selloFinal: 'APROBADO POR EL PARTIDO',
          pantallaDestino: PantallaCuadranteSigma(
            estado: widget.estado,
            planetaDestacado:
                tieneTresFragmentos ? 'pravda7' : null,
          ),
        ),
      ),
    );
  }

  int _contarFragmentosPravda7() {
    int total = 0;
    if (widget.estado.tieneFlag('pista_pravda7_inicial')) total += 1;
    if (widget.estado.tieneFlag('rumor_pravda7_fragmento2')) total += 1;
    if (widget.estado.tieneFlag('rumor_pravda7_fragmento3')) total += 1;
    return total;
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
                      'SOL CAMARADA · ESTRELLA SINDICALIZADA',
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
                  'Pulsa al Delegado, al altavoz, al panel sindical o a la mesa. El cadete caminará antes de actuar.',
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
          pintorFondo: PintorEscenarioSolCamarada(
            fase: controladorFaseAmbiental.value,
          ),
          rutaImagenFondo: 'assets/images/fondo_sol_camarada.png',
          claseJugador: widget.estado.personaje.clase,
          idSombreroEquipado: widget.estado.idObjetoCabezaEquipado,
          idArmaEquipada: widget.estado.idObjetoArmaEquipada,
          idTorsoEquipado: widget.estado.idObjetoTorsoEquipado,
          capaAmbiental: const CapaParticulasAmbientales(
            tipoAmbiente: TipoAmbiente.motasSolares,
            cantidadParticulas: 85,
          ),
          factorAnchoMundo: 2.5,
          posicionInicialJugador: const Offset(0.06, 0.86),
          puntoEntradaInicial: const Offset(-0.02, 0.86),
          puntoSalidaActiva: _puntoSalida,
          onCodigoSecreto: _alCodigoSecretoMundoLibre,
          onCadeteQuietoLargoRato: _alCadeteQuietoLargoRato,
          alCompletarSalida: () {
            final callbackSalida = _alCompletarSalida;
            _alCompletarSalida = null;
            _puntoSalida = null;
            callbackSalida?.call();
          },
          hotspots: [
            HotspotEscenario(
              identificador: 'panel_sindical',
              posicionRelativa: const Offset(0.08, 0.74),
              anchoRelativo: 0.14,
              altoRelativo: 0.28,
              radioInteraccion: 0.14,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarPanelSindical,
            ),
            HotspotEscenario(
              identificador: 'mesa_papeles',
              posicionRelativa: const Offset(0.28, 0.74),
              anchoRelativo: 0.25,
              altoRelativo: 0.08,
              radioInteraccion: 0.18,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarPapeles,
            ),
            HotspotEscenario(
              identificador: 'delegado',
              posicionRelativa: const Offset(0.46, 0.84),
              anchoRelativo: 0.12,
              altoRelativo: 0.34,
              radioInteraccion: 0.16,
              destacar: !negociacionResuelta,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/npc_delegado_sindical.png',
                anchoSombra: 80,
              ),
              onInteractuar: _hablarConDelegado,
            ),
            HotspotEscenario(
              identificador: 'altavoz',
              posicionRelativa: const Offset(0.6, 0.34),
              anchoRelativo: 0.1,
              altoRelativo: 0.12,
              radioInteraccion: 0.14,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/mueble_altavoz_solar.png',
                conSombra: false,
              ),
              onInteractuar: _interactuarAltavoz,
            ),
            // Decoración del mundo extendido: refinerías y burócratas
            // distribuidos en la mitad derecha hasta el horizonte.
            HotspotEscenario(
              identificador: 'refineria_protones_a',
              posicionRelativa: const Offset(0.74, 0.4),
              anchoRelativo: 0.1,
              altoRelativo: 0.5,
              radioInteraccion: 0,
              representacion: EfectoHumoAscendente(
                cantidadPlumas: 14,
                tinte: PaletaCosmoSovietica.tintaTenue.withValues(alpha: 0.8),
                anchoZonaEmision: 0.45,
                altoEmpuje: 1.3,
              ),
            ),
            HotspotEscenario(
              identificador: 'refineria_protones_b',
              posicionRelativa: const Offset(0.92, 0.44),
              anchoRelativo: 0.08,
              altoRelativo: 0.45,
              radioInteraccion: 0,
              representacion: EfectoHumoAscendente(
                cantidadPlumas: 10,
                tinte: PaletaCosmoSovietica.tintaTenue.withValues(alpha: 0.73),
                anchoZonaEmision: 0.35,
                altoEmpuje: 1.2,
              ),
            ),
            HotspotEscenario(
              identificador: 'inspector_lejano_a',
              posicionRelativa: const Offset(0.7, 0.86),
              anchoRelativo: 0.045,
              altoRelativo: 0.18,
              radioInteraccion: 0,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/npc_delegado_sindical.png',
                anchoSombra: 32,
              ),
            ),
            HotspotEscenario(
              identificador: 'inspector_lejano_b',
              posicionRelativa: const Offset(0.82, 0.88),
              anchoRelativo: 0.038,
              altoRelativo: 0.15,
              radioInteraccion: 0,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/npc_delegado_sindical.png',
                anchoSombra: 28,
              ),
            ),
            HotspotEscenario(
              identificador: 'inspector_horizonte',
              posicionRelativa: const Offset(0.93, 0.9),
              anchoRelativo: 0.03,
              altoRelativo: 0.12,
              radioInteraccion: 0,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/npc_delegado_sindical.png',
                anchoSombra: 24,
              ),
            ),
            // ─── Hotspots de sabor ───────────────────────────────────
            HotspotEscenario(
              identificador: 'espejo_retroreflector',
              posicionRelativa: const Offset(0.16, 0.42),
              anchoRelativo: 0.06,
              altoRelativo: 0.22,
              radioInteraccion: 0.08,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarEspejoRetroreflector,
            ),
            HotspotEscenario(
              identificador: 'duna_calcinada',
              posicionRelativa: const Offset(0.35, 0.92),
              anchoRelativo: 0.06,
              altoRelativo: 0.06,
              radioInteraccion: 0.07,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarDunaCalcinada,
            ),
            HotspotEscenario(
              identificador: 'manifiesto_solar',
              posicionRelativa: const Offset(0.54, 0.20),
              anchoRelativo: 0.08,
              altoRelativo: 0.12,
              radioInteraccion: 0.10,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarManifiestoSolar,
            ),
            HotspotEscenario(
              identificador: 'tanque_protones',
              posicionRelativa: const Offset(0.66, 0.70),
              anchoRelativo: 0.05,
              altoRelativo: 0.22,
              radioInteraccion: 0.08,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarTanqueProtones,
            ),
            HotspotEscenario(
              identificador: 'sombra_inversa',
              posicionRelativa: const Offset(0.88, 0.92),
              anchoRelativo: 0.06,
              altoRelativo: 0.06,
              radioInteraccion: 0.08,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarSombraInversa,
            ),
            HotspotEscenario(
              identificador: 'reloj_de_sol',
              posicionRelativa: const Offset(0.97, 0.55),
              anchoRelativo: 0.04,
              altoRelativo: 0.3,
              radioInteraccion: 0.07,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarRelojDeSol,
            ),
            if (_atajoActasAbierto)
              HotspotEscenario(
                identificador: 'atajo_sala_actas',
                posicionRelativa: const Offset(0.91, 0.88),
                anchoRelativo: 0.06,
                altoRelativo: 0.10,
                radioInteraccion: 0.08,
                representacion: const SizedBox.shrink(),
                animarRespiracion: false,
                onInteractuar: () => _registrar(
                  'Hueco de la cristalera, recortado a base de cristales '
                  'caídos. Atajo lateral a la sala de actas del sindicato. '
                  'El delegado dice no haber visto nada.',
                ),
              ),
          ],
          paredesDebiles: [_cristaleraSindical],
        ),
      ),
    );
  }

  Widget _construirPanelLateral() {
    final fragmentos = _contarFragmentosPravda7();
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
          const Text('CRÓNICA SINDICAL',
              style: TipografiaPropaganda.etiquetaBurocratica),
          const SizedBox(height: 4),
          Text(
            'BITÁCORA PRAVDA-7: $fragmentos/3 fragmentos.',
            style: TipografiaPropaganda.etiquetaBurocratica.copyWith(
              color: fragmentos == 3
                  ? PaletaCosmoSovietica.rojoOficial
                  : PaletaCosmoSovietica.tintaNegra,
            ),
          ),
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
                      'El Sol Camarada gruñe por el altavoz. El Delegado Sindical aguarda con el maletín dorado abierto.',
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

class _ModalNarrativoSolar extends StatelessWidget {
  final String titulo;
  final String cuerpo;
  final String textoBoton;

  const _ModalNarrativoSolar({
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
