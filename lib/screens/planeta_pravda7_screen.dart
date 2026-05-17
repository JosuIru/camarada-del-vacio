import 'package:flutter/material.dart';
import '../data/dialogues_pravda7.dart';
import '../data/encounters.dart';
import '../data/huevos_de_pascua.dart';
import '../models/game_class.dart';
import '../models/game_state.dart';
import '../painters/pravda7_scene_painter.dart';
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
import 'epilogo_screen.dart';

class PantallaPlanetaPravda7 extends StatefulWidget {
  final EstadoJuego estado;

  const PantallaPlanetaPravda7({super.key, required this.estado});

  @override
  State<PantallaPlanetaPravda7> createState() =>
      _PantallaPlanetaPravda7State();
}

class _PantallaPlanetaPravda7State extends State<PantallaPlanetaPravda7>
    with SingleTickerProviderStateMixin {
  final List<String> registroAcciones = [];
  late AnimationController controladorFaseAmbiental;
  bool finalElegido = false;

  // Placa de presión sobre el panel central. Solo el cadete-bola pesa
  // lo suficiente para activarla. Dispara el huevo cinematográfico
  // "susurro_petrov".
  late final InterruptorPresion _placaPanelCentralPravda7;

  @override
  void initState() {
    super.initState();
    widget.estado.registrarVisitaModulo('pravda7');
    controladorFaseAmbiental = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _placaPanelCentralPravda7 = InterruptorPresion(
      identificador: 'placa_panel_central_pravda7',
      rect: const Rect.fromLTWH(0.46, 0.84, 0.10, 0.05),
      etiqueta: 'PANEL · PETROV',
      onPulsar: () {
        if (!mounted) return;
        desencadenarHuevoPascua(
          context,
          estado: widget.estado,
          idHuevo: 'susurro_petrov',
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ModalNarrativoPravda7(
        titulo: 'PRAVDA-7 · ESTACIÓN PERDIDA · 1962→',
        cuerpo:
            'La Pravda-12 acopla contra una compuerta que oficialmente no existe. Cruzas. Olor a aceite congelado y a té llevado en silencio durante décadas. El panel central transmite, en bucle: "TODAVÍA ESTAMOS ABAJO".\n\nDieciséis cosmonautas siguen en sus puestos exactos, con sus tazas exactas. Solo uno mueve los ojos: el Camarada Gromov.\n\nMisión final: decidir cómo cerrar el expediente de la Pravda-7.',
        textoBoton: 'AVANZAR',
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
          'En la cubierta vacía de la Pravda-7, el ecos repite ocho pasos no autorizados. Algo invisible aprueba con desgana.');
    }
  }

  void _alCadeteQuietoLargoRato() {
    if (widget.estado.tieneFlag('insignia_eco_pravda')) return;
    desbloquearInsigniaSiNueva(
      context,
      estado: widget.estado,
      identificadorFlag: 'insignia_eco_pravda',
    );
    _registrar(
        'Cuatro segundos de silencio en la Pravda-7. El intercomunicador cruje y emite la transmisión del miércoles que nunca existió. Tomas nota.');
  }

  Future<void> _abrirInventario() async {
    await mostrarDialogoInventario(context, estado: widget.estado);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _hablarConGromov() async {
    if (finalElegido) {
      _registrar(
          'Gromov ya no habla. Las tazas siguen tibias por costumbre.');
      return;
    }
    await mostrarPanelDialogo(
      context,
      conversacion: conversacionConGromov,
      estado: widget.estado,
      onConsecuencia: (consecuencia) async {
        switch (consecuencia) {
          case 'pravda7_final_partido':
            widget.estado.activarFlag('pravda7_final_partido');
            widget.estado.modificarCuota(3);
            finalElegido = true;
            _navegarAEpilogo(FinalPrototipo.partido);
            break;
          case 'pravda7_final_humanista':
            widget.estado.activarFlag('pravda7_final_humanista');
            widget.estado.modificarCuota(-3);
            finalElegido = true;
            _navegarAEpilogo(FinalPrototipo.humanista);
            break;
          case 'pravda7_final_combate':
            await _lanzarBossFinal();
            break;
        }
      },
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _lanzarBossFinal() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ModalNarrativoPravda7(
        titulo: 'EL ESPECTRO DEL MIÉRCOLES',
        cuerpo:
            'El Espectro de Directorskov se materializa frente al panel roto. Sostiene el botón en una mano espectral. A los lados, dos Sombras de Cosmonauta se desprenden de las paredes. La estación entera respira.',
        textoBoton: 'EXPULSARLO',
      ),
    );
    if (!mounted) return;
    final resultado = await Navigator.of(context).push<bool>(
      crearRutaConTransicion<bool>(
        PantallaCombate(
          estado: widget.estado,
          tipoEncuentro: TipoEncuentro.bossPravda7,
        ),
      ),
    );
    if (!mounted) return;
    if (resultado == true) {
      widget.estado.activarFlag('pravda7_final_combate');
      widget.estado.activarFlag('venciste_espectro_directorskov');
      finalElegido = true;
      _navegarAEpilogo(FinalPrototipo.combate);
    } else {
      widget.estado.activarFlag('pravda7_caiste');
      _navegarAEpilogo(FinalPrototipo.combate);
    }
  }

  void _navegarAEpilogo(FinalPrototipo final_) {
    Navigator.of(context).pushReplacement(
      crearRutaConTransicion(
        PantallaTransicionBurocratica(
          codigoInforme: 'INFORME FINAL · CASO PRAVDA-7',
          tituloInforme: 'EXPEDIENTE CERRADO POR EL CADETE',
          cuerpoInforme: _resumenTransicion(final_),
          selloFinal: _selloTransicion(final_),
          pantallaDestino: PantallaEpilogo(
            estado: widget.estado,
            finalElegido: final_,
          ),
        ),
      ),
    );
  }

  String _resumenTransicion(FinalPrototipo final_) {
    switch (final_) {
      case FinalPrototipo.partido:
        return 'El cadete sube a la Pravda-12 con los tres fragmentos de la '
            'bitácora y un comunicador de larga distancia. Destino inmediato: '
            'la oficina del Inspector Krilov. El Partido decidirá lo que sea '
            'que el Partido decida.\n\nCuota +3.';
      case FinalPrototipo.humanista:
        return 'El cadete vuelve a la Pravda-12 con la bitácora oculta en un '
            'compartimento que la Ingeniera Vostrikova selló con dos cucharas '
            'y un manifiesto. El Inspector Krilov no recibirá nada. Las '
            'tumbas de la Pravda-7 quedan, oficialmente, fuera del mapa.\n\n'
            'Cuota −3.';
      case FinalPrototipo.combate:
        return 'El cadete sube a la Pravda-12 con la respiración corta. El '
            'Espectro de Directorskov ya no parpadea en los pasillos. Algo se '
            'apagó esta tarde, y no fue el cadete.';
    }
  }

  String _selloTransicion(FinalPrototipo final_) {
    switch (final_) {
      case FinalPrototipo.partido:
        return 'APROBADO POR EL PARTIDO';
      case FinalPrototipo.humanista:
        return 'EXPEDIENTE OMITIDO';
      case FinalPrototipo.combate:
        return 'CASO CERRADO POR FUERZA';
    }
  }

  void _interactuarPanelCentral() {
    _registrar(
        'El panel transmite, en bucle verde fosforescente: "TODAVÍA ESTAMOS ABAJO".');
  }

  void _interactuarMesa() {
    _registrar(
        'Tres tazas servidas, escarchadas. La del centro está más limpia que las otras dos.');
  }

  void _interactuarBandera() {
    _registrar(
        'La bandera roja ha perdido la estrella. Quedan tres hilos blancos donde estuvo.');
  }

  void _interactuarCompuertaAcoplamiento() {
    _registrar(
        'La compuerta por la que has entrado. Sigue sellada con el formulario F-447 (copia número 7 de 7). El sello dice «sólo ida».');
  }

  void _interactuarCuadernoBitacora() {
    _registrar(
        'Un cuaderno de bitácora sobre el suelo, abierto en la página del miércoles. Solo hay una línea: «Directorskov ha pulsado el botón. Estamos abajo».');
  }

  void _interactuarRelojPravda7() {
    _registrar(
        'El reloj de la Pravda-7 marca las 4:47. Como todos los relojes del cuadrante. Llevan así desde que el miércoles dejó de existir.');
  }

  void _interactuarAsientoDirectorskov() {
    _registrar(
        'Asiento del Camarada Directorskov. Cojín gastado, marca exacta de sus dos manos en los reposabrazos. El asiento sigue tibio, dieciséis años después.');
  }

  void _interactuarTumbaImprovisada() {
    _registrar(
        'Una tumba improvisada con un casco encima. La placa, escrita a navaja: «AQUÍ DESCANSA QUIEN INTENTÓ APAGAR EL BOTÓN ANTES». No hay nombre.');
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
                      'PRAVDA-7 · ESTACIÓN PERDIDA',
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
                  'Pulsa a Gromov para tomar la decisión final. Los objetos solo registran constancia narrativa.',
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
          pintorFondo: PintorEscenarioPravda7(
            fase: controladorFaseAmbiental.value,
          ),
          rutaImagenFondo: 'assets/images/fondo_pravda7.png',
          claseJugador: widget.estado.personaje.clase,
          idSombreroEquipado: widget.estado.idObjetoCabezaEquipado,
          idArmaEquipada: widget.estado.idObjetoArmaEquipada,
          idTorsoEquipado: widget.estado.idObjetoTorsoEquipado,
          capaAmbiental: const CapaParticulasAmbientales(
            tipoAmbiente: TipoAmbiente.humoFantasmal,
            cantidadParticulas: 75,
          ),
          factorAnchoMundo: 2.2,
          posicionInicialJugador: const Offset(0.06, 0.86),
          puntoEntradaInicial: const Offset(-0.02, 0.86),
          onCodigoSecreto: _alCodigoSecretoMundoLibre,
          onCadeteQuietoLargoRato: _alCadeteQuietoLargoRato,
          hotspots: [
            // ─── Zona A · Compuerta de entrada (0.00 – 0.20) ───
            HotspotEscenario(
              identificador: 'compuerta_acoplamiento',
              posicionRelativa: const Offset(0.04, 0.5),
              anchoRelativo: 0.05,
              altoRelativo: 0.4,
              radioInteraccion: 0.08,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarCompuertaAcoplamiento,
            ),
            HotspotEscenario(
              identificador: 'cuaderno_bitacora',
              posicionRelativa: const Offset(0.12, 0.82),
              anchoRelativo: 0.04,
              altoRelativo: 0.06,
              radioInteraccion: 0.06,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarCuadernoBitacora,
            ),

            // ─── Zona B · Tripulación congelada (0.20 – 0.45) ───
            HotspotEscenario(
              identificador: 'gromov',
              posicionRelativa: const Offset(0.24, 0.8),
              anchoRelativo: 0.07,
              altoRelativo: 0.36,
              radioInteraccion: 0.10,
              destacar: !finalElegido,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/npc_cosmonauta_congelado.png',
                anchoSombra: 80,
              ),
              onInteractuar: _hablarConGromov,
            ),
            HotspotEscenario(
              identificador: 'mesa_tazas',
              posicionRelativa: const Offset(0.30, 0.77),
              anchoRelativo: 0.09,
              altoRelativo: 0.08,
              radioInteraccion: 0.09,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarMesa,
            ),
            HotspotEscenario(
              identificador: 'reloj_pravda7',
              posicionRelativa: const Offset(0.36, 0.20),
              anchoRelativo: 0.05,
              altoRelativo: 0.08,
              radioInteraccion: 0.08,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarRelojPravda7,
            ),

            // ─── Zona C · Panel central de transmisión (0.45 – 0.70) ───
            HotspotEscenario(
              identificador: 'panel_central',
              posicionRelativa: const Offset(0.55, 0.36),
              anchoRelativo: 0.16,
              altoRelativo: 0.32,
              radioInteraccion: 0.12,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarPanelCentral,
            ),
            HotspotEscenario(
              identificador: 'asiento_directorskov',
              posicionRelativa: const Offset(0.62, 0.74),
              anchoRelativo: 0.10,
              altoRelativo: 0.30,
              radioInteraccion: 0.10,
              // Retrato del Camarada Directorskov en su asiento de mando,
              // colgando del módulo como un espectro de propaganda. No
              // es el sprite de combate; es la presencia visual previa.
              representacion: const Opacity(
                opacity: 0.82,
                child: IconoHotspotImagen(
                  rutaAsset: 'assets/images/directorskov_f01.png',
                  anchoSombra: 70,
                ),
              ),
              onInteractuar: _interactuarAsientoDirectorskov,
            ),

            // ─── Zona D · Bandera + consolas reventadas (0.70 – 1.00) ───
            HotspotEscenario(
              identificador: 'bandera',
              posicionRelativa: const Offset(0.78, 0.42),
              anchoRelativo: 0.08,
              altoRelativo: 0.34,
              radioInteraccion: 0.10,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarBandera,
            ),
            HotspotEscenario(
              identificador: 'tumba_improvisada',
              posicionRelativa: const Offset(0.84, 0.85),
              anchoRelativo: 0.06,
              altoRelativo: 0.08,
              radioInteraccion: 0.08,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarTumbaImprovisada,
            ),
            HotspotEscenario(
              identificador: 'humo_fantasmal_a',
              posicionRelativa: const Offset(0.90, 0.55),
              anchoRelativo: 0.06,
              altoRelativo: 0.4,
              radioInteraccion: 0,
              representacion: EfectoHumoAscendente(
                cantidadPlumas: 8,
                tinte: PaletaCosmoSovietica.papelSombra.withValues(alpha: 0.8),
                anchoZonaEmision: 0.35,
                altoEmpuje: 1.0,
              ),
            ),
            HotspotEscenario(
              identificador: 'humo_fantasmal_b',
              posicionRelativa: const Offset(0.96, 0.6),
              anchoRelativo: 0.05,
              altoRelativo: 0.36,
              radioInteraccion: 0,
              representacion: EfectoHumoAscendente(
                cantidadPlumas: 6,
                tinte: PaletaCosmoSovietica.papelSombra.withValues(alpha: 0.73),
                anchoZonaEmision: 0.3,
                altoEmpuje: 0.95,
              ),
            ),
          ],
          interruptores: [_placaPanelCentralPravda7],
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
          const Text('CRÓNICA DE LA PRAVDA-7',
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
                      'Aire frío y dulce. Un panel verde repite "todavía estamos abajo". Dieciséis cosmonautas, una sola voz.',
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

class _ModalNarrativoPravda7 extends StatelessWidget {
  final String titulo;
  final String cuerpo;
  final String textoBoton;

  const _ModalNarrativoPravda7({
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
