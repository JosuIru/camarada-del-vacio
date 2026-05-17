import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/dialogues_vela.dart';
import '../data/encounters.dart';
import '../data/huevos_de_pascua.dart';
import '../minijuegos/pantalla_camarada_invasors.dart';
import '../minijuegos/pantalla_cosmoom_doom.dart';
import '../minijuegos/pantalla_inspektor_pacman.dart';
import '../minijuegos/pantalla_transformacion.dart';
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
import '../widgets/notificacion_insignia.dart';
import '../widgets/inventory_dialog.dart';
import '../widgets/paper_background.dart';
import '../widgets/propaganda_button.dart';
import 'bureaucratic_transition.dart';
import 'combat_screen.dart';
import 'cuadrante_sigma_screen.dart';

class PantallaReactor extends StatefulWidget {
  final EstadoJuego estado;

  const PantallaReactor({super.key, required this.estado});

  @override
  State<PantallaReactor> createState() => _PantallaReactorState();
}

class _PantallaReactorState extends State<PantallaReactor>
    with SingleTickerProviderStateMixin {
  final List<String> registroAcciones = [];
  bool decisionCajaTomada = false;
  late AnimationController controladorFaseAmbiental;

  late bool esRevisitaInicial;

  int _contadorClicksReactor = 0;

  // ── Puzles del escenario ─────────────────────────────────────────
  // Pared débil oxidada cerca de la compuerta Yuriovka. Romperla en
  // modo bola revela el grafiti "PRAVDA-7 NO MURIÓ".
  late final ParedDebilEscenario _paredTuberiaOxidada;
  bool _grafitiRevelado = false;
  // Cinco conos de mantenimiento. Tirarlos todos en modo bola activa
  // el huevo "quincalla_vostrikova".
  final List<BoloDecorativo> _conosMantenimiento =
      List<BoloDecorativo>.generate(
    5,
    (indicePino) => BoloDecorativo(
      identificador: 'cono_mant_$indicePino',
      posicion: Offset(0.30 + indicePino * 0.025, 0.90),
      radio: 0.016,
    ),
  );

  @override
  void initState() {
    super.initState();
    esRevisitaInicial = widget.estado.esRevisita('reactor');
    widget.estado.registrarVisitaModulo('reactor');
    decisionCajaTomada = widget.estado.tieneFlag('caja_escondida_vela') ||
        widget.estado.tieneFlag('caja_entregada_krilov');
    _grafitiRevelado =
        widget.estado.tieneFlag('insignia_grafiti_pravda7');
    controladorFaseAmbiental = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _paredTuberiaOxidada = ParedDebilEscenario(
      identificador: 'pared_tuberia_oxidada',
      rect: const Rect.fromLTWH(0.91, 0.78, 0.04, 0.15),
      etiqueta: 'ROMPER',
      onRomperse: () {
        if (!mounted) return;
        setState(() => _grafitiRevelado = true);
        desencadenarHuevoPascua(
          context,
          estado: widget.estado,
          idHuevo: 'grafiti_pravda7',
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
      final cajaResuelta = decisionCajaTomada;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _ModalNarrativoReactor(
          titulo: 'SALA DEL REACTOR · REGRESO',
          cuerpo: cajaResuelta
              ? 'Vuelves al reactor de la Pravda-12. Vostrikova ha vuelto a abrir el panel; suelda algo que antes había soldado al revés. La caja ya no está, solo su silueta tibia en el polvo.'
              : 'Vuelves al reactor de la Pravda-12. Vostrikova te mira sin sorprenderse; la caja sigue donde estaba, oprimiendo el aire con su densidad anómala.',
          textoBoton: 'CONTINUAR',
        ),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ModalNarrativoReactor(
        titulo: 'SALA DEL REACTOR · PRAVDA-12',
        cuerpo:
            'La compuerta se sella tras de ti con un suspiro de fatiga. Olor a aceite quemado, té recalentado y vodka sintético. En el centro, una masa cilíndrica respira: el reactor. Frente a un panel abierto, la Ingeniera Vostrikova suelda algo. A su lado, una caja gris descansa sobre el suelo, sin etiqueta y sin el formulario F-447 que reglamentariamente debería acompañarla.',
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

  Future<void> _hablarConVela() async {
    await mostrarPanelDialogo(
      context,
      conversacion: conversacionConVelaTchun,
      estado: widget.estado,
      onConsecuencia: (consecuencia) {
        switch (consecuencia) {
          case 'caja_escondida_vela':
            widget.estado.activarFlag('caja_escondida_vela');
            widget.estado.anadirObjeto('caja_sin_etiquetar');
            decisionCajaTomada = true;
            _registrar(
                'Tomas la caja de Vostrikova. La metes bajo el uniforme.');
            break;
          case 'caja_entregada_krilov':
            widget.estado.activarFlag('caja_entregada_krilov');
            widget.estado.modificarCuota(1);
            decisionCajaTomada = true;
            _registrar(
                'Tomas la caja para entregársela a Krilov. Cuota +1.');
            break;
          case 'caja_vista':
            widget.estado.activarFlag('caja_vista');
            _registrar(
                'Examinas el contenido de la caja: un comunicador prohibido.');
            break;
        }
      },
    );
    if (!mounted) return;
    setState(() {});
    if (decisionCajaTomada) {
      if (widget.estado.tieneFlag('caja_escondida_vela')) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          _lanzarEmboscadaDelCabo();
        });
      } else {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          _mostrarFinPrototipo();
        });
      }
    }
  }

  void _interactuarCaja() {
    if (decisionCajaTomada) {
      _registrar('La caja ya no está aquí.');
      return;
    }
    _registrar(
        'Caja metálica sin etiqueta. Ocupa el aire alrededor con densidad anómala. Habla con Vostrikova antes de tocarla.');
  }

  void _interactuarCompuertaYuriovka() {
    _registrar(
        'Compuerta de acoplamiento a la Pravda-7 (desaparecida). Sellada con tres precintos del formulario F-447. Más allá de este prototipo.');
  }

  void _interactuarKareninaArchivera() {
    _registrar(
        'Karenina Archivera, ojos como dos rendijas de buzón, no levanta la cabeza del fichero. — «No me interrumpa, cadete. Si esta carpeta no entra en su balda antes del relevo, alguien deja de existir. Probablemente usted.»');
  }

  void _interactuarTablero() {
    _registrar(
        'Tres luces. Una pestañea entre rojo y verde como si no supiera decidirse.');
  }

  void _interactuarTrajesRadiacion() {
    _registrar(
        'Tres trajes anti-radiación cuelgan de sus perchas. El segundo tiene una quemadura circular en el pecho. Nadie habla de Petrov 58 en voz alta, pero la tela sí.');
  }

  void _interactuarSamovarGuardia() {
    _registrar(
        'Samovar de guardia. El agua sigue caliente. Alguien se ha bebido medio té recalentado y se ha ido sin lavar la taza. Tradición.');
  }

  void _interactuarPravdaOlvidada() {
    _registrar(
        'Un ejemplar atrasado de PRAVDA descansa sobre el banco. Titular: "PROGRESO ININTERRUMPIDO". Por debajo, alguien ha anotado a lápiz: «mentira útil».');
  }

  void _interactuarManometro() {
    _registrar(
        'La aguja del manómetro vibra cerca de la zona roja. No la cruza. Aún.');
  }

  void _interactuarPanelPalancas() {
    _registrar(
        'Doce palancas. Tres firmes hacia arriba, tres firmes hacia abajo, seis indecisas. Una etiqueta cosida bajo el panel dice: «no tocar sin autorización del médico del Estado». El médico del Estado no está.');
  }

  void _interactuarCarritoCajas() {
    _registrar(
        'Carrito con dos cajas precintadas. La de arriba tiene una banda roja idéntica a la de la caja sin etiquetar. Tampoco lleva F-447.');
  }

  void _interactuarPizarraTurnos() {
    _registrar(
        'Pizarra de turnos. La celda de hoy está tachada con tiza. El cosmonauta asignado se llamaba Krilov. El que firma encima, también Krilov.');
  }

  void _interactuarRelojIndustrial() {
    _registrar(
        'El reloj marca las 4:47. La hora Gromov. Por algún motivo, todos los relojes de la Pravda-12 se atrasan hasta coincidir en este número.');
  }

  void _interactuarTermometro() {
    _registrar(
        'Termómetro de columna. La línea roja oscila lentamente, como si respirara con el reactor.');
  }

  void _interactuarCompuertaMinisterio() {
    _registrar(
        'Una compuerta sellada con F-447 antiguos. Detrás hay pasos arrastrados y un olor a archivo húmedo: es la entrada al Ministerio. Cuando empujas, te encuentras solo. Y armado.');
    Navigator.of(context).push(
      crearRutaConTransicion(
        PantallaTransformacion(
          formaDestino: FormaProtagonista.cadete,
          nombreLugar: 'MINISTERIO COSMONÁUTICO',
          fraseTransformacion:
              'El sello se rompe. La gabardina se ajusta a tus hombros. El pasillo te traga.',
          alTerminar: () {
            Navigator.of(context).pushReplacement(
              crearRutaConTransicion(
                PantallaCosmoomDoom(estado: widget.estado),
              ),
            );
          },
        ),
      ),
    );
  }

  void _interactuarMonitorPropaganda() {
    _registrar(
        'Un monitor CRT empotrado entre los conductos. La pantalla parpadea con una flotilla descendente que no debería estar ahí. Al apoyar la mano en el cristal, te sientes succionado hacia adentro.');
    Navigator.of(context).push(
      crearRutaConTransicion(
        PantallaTransformacion(
          formaDestino: FormaProtagonista.cadete,
          nombreLugar: 'CANAL DE PROPAGANDA',
          fraseTransformacion:
              'La pantalla te traga. Sales al otro lado armado: contra ti, un cielo lleno de yankis.',
          alTerminar: () {
            Navigator.of(context).pushReplacement(
              crearRutaConTransicion(
                PantallaCamaradaInvasors(estado: widget.estado),
              ),
            );
          },
        ),
      ),
    );
  }

  void _interactuarConductoVentilacion() {
    _registrar(
        'Un conducto de ventilación bajo el panel de palancas. La rejilla está suelta. Al asomarte oyes ecos de pasos pequeños y el roce de cuatro gabardinas idénticas. Si te cuelas, no entrarás como tú.');
    Navigator.of(context).push(
      crearRutaConTransicion(
        PantallaTransformacion(
          formaDestino: FormaProtagonista.comecocos,
          nombreLugar: 'CORREDORES DEL COMITÉ',
          fraseTransformacion:
              'Te aplanas en una cabeza con gorra roja. Los pasillos saben más de ti que tú mismo.',
          alTerminar: () {
            Navigator.of(context).pushReplacement(
              crearRutaConTransicion(
                PantallaInspektorPacman(estado: widget.estado),
              ),
            );
          },
        ),
      ),
    );
  }

  void _interactuarReactor() {
    _contadorClicksReactor++;
    if (_contadorClicksReactor == 7 &&
        !widget.estado.tieneFlag('insignia_hierro_caliente')) {
      desbloquearInsigniaSiNueva(
        context,
        estado: widget.estado,
        identificadorFlag: 'insignia_hierro_caliente',
      );
      _registrar(
          'A la séptima palpada el reactor parece reconocerte. Una vibración cálida sube por el brazo. El médico del Estado, ausente, no comenta.');
      return;
    }
    final mensajes = [
      'El reactor respira con un ritmo asmático. Mejor no escuchar demasiado tiempo.',
      'Tocas la carcasa. Cálida. Demasiado.',
      'El reactor traga un suspiro. Tu mano se queja en silencio.',
      'Tercera caricia indebida. La caja de fusibles parpadea con desaprobación.',
      'El núcleo siente curiosidad por tu dedo. No es recíproca.',
      'Quinta vez. Algún ingeniero, en algún lugar, tiembla sin saber por qué.',
      'Sexta. El reactor empieza a llamarte por tu nombre, en otro idioma.',
    ];
    final indice = (_contadorClicksReactor - 1).clamp(0, mensajes.length - 1);
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
          'Vostrikova levanta la vista de la soldadura. Lo que acaba de ver no se enseña en la Academia.');
    }
  }

  Future<void> _lanzarEmboscadaDelCabo() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ModalNarrativoReactor(
        titulo: 'EMBOSCADA · CUERPO DE INSPECCIÓN',
        cuerpo:
            'Sales del reactor con la caja oculta a la espalda. Al doblar el primer recodo, un Cabo de uniforme gris y un Auxiliar Burocrático bloquean el paso. La porra brilla, el formulario aletea.\n\n— Camarada cadete. Necesito que me acompañe.',
        textoBoton: 'DEFENDERSE',
      ),
    );
    if (!mounted) return;
    final resultado = await Navigator.of(context).push<bool>(
      crearRutaConTransicion<bool>(
        PantallaCombate(
          estado: widget.estado,
          tipoEncuentro: TipoEncuentro.emboscadaCabo,
        ),
      ),
    );
    if (!mounted) return;
    if (resultado == true) {
      widget.estado.activarFlag('venciste_cabo');
      _registrar(
          'Has vencido al Cabo. La caja sigue oculta.');
    } else {
      widget.estado.consumirObjeto('caja_sin_etiquetar');
      widget.estado.activarFlag('caja_perdida_en_cabo');
      _registrar(
          'El Cabo se lleva la caja a Krilov.');
    }
    if (mounted) {
      setState(() {});
      _mostrarFinPrototipo();
    }
  }

  void _mostrarFinPrototipo() {
    final escondida = widget.estado.tieneFlag('caja_escondida_vela');
    final entregada = widget.estado.tieneFlag('caja_entregada_krilov');
    final vista = widget.estado.tieneFlag('caja_vista');
    final caboVencido = widget.estado.tieneFlag('venciste_cabo');
    final cajaPerdida = widget.estado.tieneFlag('caja_perdida_en_cabo');
    final cuotaFinal = widget.estado.cuotaBurocratica;

    final resumen = [
      if (escondida && !cajaPerdida)
        '• Aceptaste esconder la caja por Vostrikova y la conservaste tras la emboscada del Cabo.',
      if (escondida && cajaPerdida)
        '• Aceptaste esconder la caja, pero el Cabo te la arrebató.',
      if (entregada)
        '• Decidiste entregar la caja al Inspector Krilov.',
      if (vista)
        '• Examinaste el contenido: comunicador prohibido con frecuencias de Petrov 58.',
      if (caboVencido) '• Venciste al Cabo del Cuerpo de Inspección.',
      '• Cuota burocrática actual: ${cuotaFinal >= 0 ? '+' : ''}$cuotaFinal',
    ].join('\n');

    // Activar la pista INICIAL de Pravda-7 (fragmento que Vostrikova
    // le pasa al cadete al cerrar el reactor). Esto abre Gélida-9 en
    // el Cuadrante Sigma y deja Zovnak-4 como ruta opcional. La flag
    // `rumor_pravda7` se reserva para el voto del Marciano
    // Provisional en la Asamblea de Zovnak-4 — pista narrativa
    // pura, no desbloquea mapa.
    if (!widget.estado.tieneFlag('pista_pravda7_inicial')) {
      widget.estado.activarFlag('pista_pravda7_inicial');
    }

    showDialog(
      context: context,
      builder: (_) => _ModalNarrativoReactor(
        titulo: 'EXPEDIENTE PARCIAL · MISIÓN 1 RESUELTA',
        cuerpo:
            'Has cerrado los dos primeros arcos del Acto 1.\n\nTu expediente provisional:\n\n$resumen\n\nVostrikova te ha pasado, al despedirse, un fragmento garabateado de la bitácora de la Pravda-7. El Cuadrante Sigma se abre para ti: Zovnak-4 y Gélida-9 esperan visado.',
        textoBoton: 'SALIR AL CUADRANTE SIGMA',
        onClose: _avanzarAlCuadranteSigma,
      ),
    );
  }

  void _avanzarAlCuadranteSigma() {
    Navigator.of(context).pushReplacement(
      crearRutaConTransicion(
        PantallaTransicionBurocratica(
          codigoInforme: 'INFORME 113-D · CASO ABIERTO',
          tituloInforme: 'ASCENSO AL CUADRANTE SIGMA',
          cuerpoInforme:
              'El cadete abandona el módulo de Reactor. Una segunda copia '
              'del formulario F-447 le es entregada con tinta aún fresca.\n\n'
              'La Pravda-7 sigue sin aparecer en los registros oficiales, '
              'pero hay rumores de tres fragmentos de bitácora repartidos por '
              'el Cuadrante Sigma. Zovnak-4 y Gélida-9 se autorizan como '
              'destinos preliminares.\n\n'
              'Sol Camarada queda condicionado a recolectar el primer '
              'fragmento. La propia Pravda-7 sólo se hace localizable con '
              'los tres.',
          selloFinal: 'APROBADO POR EL PARTIDO',
          pantallaDestino: PantallaCuadranteSigma(
            estado: widget.estado,
            planetaDestacado: 'zovnak4',
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
                      'SALA DEL REACTOR · PRAVDA-12',
                      style: TipografiaPropaganda.tituloSeccion,
                    ),
                    Row(
                      children: [
                        Text(
                          'CUOTA: ${widget.estado.cuotaBurocratica >= 0 ? '+' : ''}${widget.estado.cuotaBurocratica}',
                          style:
                              TipografiaPropaganda.etiquetaBurocratica.copyWith(
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
                  'Pulsa el suelo para caminar, o un objeto/NPC para interactuar tras llegar.',
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
          rutaImagenFondo: 'assets/images/fondo_reactor.png',
          claseJugador: widget.estado.personaje.clase,
          idSombreroEquipado: widget.estado.idObjetoCabezaEquipado,
          idArmaEquipada: widget.estado.idObjetoArmaEquipada,
          idTorsoEquipado: widget.estado.idObjetoTorsoEquipado,
          capaAmbiental: const CapaParticulasAmbientales(
            tipoAmbiente: TipoAmbiente.motasSolares,
            cantidadParticulas: 36,
          ),
          factorAnchoMundo: 2.0,
          posicionInicialJugador: const Offset(0.06, 0.86),
          puntoEntradaInicial: const Offset(-0.02, 0.86),
          onCodigoSecreto: _alCodigoSecretoMundoLibre,
          hotspots: [
            // ─── Zona A · Antecámara de control (0.00 – 0.32) ───
            HotspotEscenario(
              identificador: 'tablero',
              posicionRelativa: const Offset(0.10, 0.30),
              anchoRelativo: 0.06,
              altoRelativo: 0.10,
              radioInteraccion: 0.12,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarTablero,
            ),
            HotspotEscenario(
              identificador: 'trajes_radiacion',
              posicionRelativa: const Offset(0.18, 0.46),
              anchoRelativo: 0.08,
              altoRelativo: 0.20,
              radioInteraccion: 0.1,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarTrajesRadiacion,
            ),
            HotspotEscenario(
              identificador: 'samovar_guardia',
              posicionRelativa: const Offset(0.155, 0.83),
              anchoRelativo: 0.05,
              altoRelativo: 0.14,
              radioInteraccion: 0.08,
              etiquetaAccion: 'BEBER',
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/mueble_samovar_pequeno.png',
                anchoSombra: 50,
              ),
              onInteractuar: _interactuarSamovarGuardia,
            ),
            HotspotEscenario(
              identificador: 'pravda_olvidada',
              posicionRelativa: const Offset(0.04, 0.78),
              anchoRelativo: 0.06,
              altoRelativo: 0.06,
              radioInteraccion: 0.07,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarPravdaOlvidada,
            ),
            HotspotEscenario(
              identificador: 'manometro_pared',
              posicionRelativa: const Offset(0.06, 0.45),
              anchoRelativo: 0.05,
              altoRelativo: 0.1,
              radioInteraccion: 0.08,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarManometro,
            ),

            // ─── Zona B · Núcleo del reactor (0.32 – 0.68) ───
            HotspotEscenario(
              identificador: 'reactor_nucleo',
              posicionRelativa: const Offset(0.50, 0.40),
              anchoRelativo: 0.12,
              altoRelativo: 0.42,
              radioInteraccion: 0.12,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarReactor,
            ),
            HotspotEscenario(
              identificador: 'humo_reactor',
              posicionRelativa: const Offset(0.50, 0.16),
              anchoRelativo: 0.10,
              altoRelativo: 0.2,
              radioInteraccion: 0,
              representacion: EfectoHumoAscendente(
                cantidadPlumas: 9,
                tinte: PaletaCosmoSovietica.tintaTenue.withValues(alpha: 0.7),
                anchoZonaEmision: 0.6,
                altoEmpuje: 1.1,
              ),
            ),
            HotspotEscenario(
              identificador: 'panel_palancas',
              posicionRelativa: const Offset(0.40, 0.55),
              anchoRelativo: 0.09,
              altoRelativo: 0.2,
              radioInteraccion: 0.09,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarPanelPalancas,
            ),
            HotspotEscenario(
              identificador: 'conducto_ventilacion_reactor',
              posicionRelativa: const Offset(0.36, 0.92),
              anchoRelativo: 0.08,
              altoRelativo: 0.06,
              radioInteraccion: 0.08,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/mueble_rejilla_conducto.png',
                conSombra: false,
              ),
              onInteractuar: _interactuarConductoVentilacion,
            ),
            HotspotEscenario(
              identificador: 'monitor_propaganda_reactor',
              posicionRelativa: const Offset(0.30, 0.30),
              anchoRelativo: 0.07,
              altoRelativo: 0.14,
              radioInteraccion: 0.10,
              representacion: const Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: IconoHotspotImagen(
                      rutaAsset: 'assets/svg/mueble_monitor_propaganda.png',
                      conSombra: false,
                    ),
                  ),
                  // Cara de Krilov dentro del marco del monitor:
                  // visor negro espejado, ojo rojo brillante, sello de
                  // cera con la «К». Vigila desde el canal oficial.
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(18, 22, 18, 40),
                      child: Image(
                        image: AssetImage('assets/images/cabeza_krilov.png'),
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ],
              ),
              onInteractuar: _interactuarMonitorPropaganda,
            ),
            HotspotEscenario(
              identificador: 'compuerta_ministerio',
              posicionRelativa: const Offset(0.745, 0.60),
              anchoRelativo: 0.04,
              altoRelativo: 0.32,
              radioInteraccion: 0.10,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/mueble_compuerta_ministerio.png',
                anchoSombra: 80,
              ),
              onInteractuar: _interactuarCompuertaMinisterio,
            ),
            HotspotEscenario(
              identificador: 'carrito_cajas',
              posicionRelativa: const Offset(0.60, 0.62),
              anchoRelativo: 0.07,
              altoRelativo: 0.13,
              radioInteraccion: 0.08,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarCarritoCajas,
            ),
            if (!decisionCajaTomada)
              HotspotEscenario(
                identificador: 'caja',
                posicionRelativa: const Offset(0.42, 0.88),
                anchoRelativo: 0.06,
                altoRelativo: 0.08,
                radioInteraccion: 0.08,
                destacar: true,
                representacion: const IconoHotspotImagen(
                  rutaAsset: 'assets/svg/mueble_caja_anonima.png',
                  anchoSombra: 56,
                ),
                onInteractuar: _interactuarCaja,
              ),
            // Retrato de la Ingeniera Vostrikova trabajando frente al
            // panel abierto. Comparte el callback de la vela: ambos
            // disparan el diálogo (la vela es la metáfora del lugar de
            // trabajo, la cabeza es la ingeniera misma).
            HotspotEscenario(
              identificador: 'vostrikova_retrato',
              posicionRelativa: const Offset(0.25, 0.36),
              anchoRelativo: 0.05,
              altoRelativo: 0.13,
              radioInteraccion: 0.10,
              destacar: !decisionCajaTomada,
              etiquetaAccion: 'HABLAR',
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/images/cabeza_vostrikova.png',
                conSombra: false,
              ),
              onInteractuar: _hablarConVela,
            ),
            HotspotEscenario(
              identificador: 'vela',
              posicionRelativa: const Offset(0.46, 0.86),
              anchoRelativo: 0.03,
              altoRelativo: 0.08,
              radioInteraccion: 0.10,
              destacar: !decisionCajaTomada,
              etiquetaAccion: 'EXAMINAR',
              // Cuerpo de la vela (PNG) + llama animada de 3 frames
              // (§10.9) en la parte superior, balanceándose en bucle.
              representacion: const Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  IconoHotspotImagen(
                    rutaAsset: 'assets/svg/mueble_vela.png',
                    conSombra: false,
                    margenInterior: EdgeInsets.only(top: 70, bottom: 0),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: IgnorePointer(
                      child: CicloDeFrames(
                        rutasFrames: [
                          'assets/svg/vela_llama_f01.png',
                          'assets/svg/vela_llama_f02.png',
                          'assets/svg/vela_llama_f03.png',
                        ],
                        duracionPorFrame: Duration(milliseconds: 320),
                      ),
                    ),
                  ),
                ],
              ),
              onInteractuar: _hablarConVela,
            ),

            // ─── Zona C · Sección sellada hacia Pravda-7 (0.68 – 1.00) ───
            HotspotEscenario(
              identificador: 'pizarra_turnos',
              posicionRelativa: const Offset(0.76, 0.23),
              anchoRelativo: 0.05,
              altoRelativo: 0.15,
              radioInteraccion: 0.08,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarPizarraTurnos,
            ),
            HotspotEscenario(
              identificador: 'reloj_industrial',
              posicionRelativa: const Offset(0.84, 0.17),
              anchoRelativo: 0.04,
              altoRelativo: 0.08,
              radioInteraccion: 0.07,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarRelojIndustrial,
            ),
            HotspotEscenario(
              identificador: 'termometro',
              posicionRelativa: const Offset(0.88, 0.45),
              anchoRelativo: 0.03,
              altoRelativo: 0.2,
              radioInteraccion: 0.07,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarTermometro,
            ),
            HotspotEscenario(
              identificador: 'fuga_refrigerante',
              posicionRelativa: const Offset(0.78, 0.78),
              anchoRelativo: 0.025,
              altoRelativo: 0.15,
              radioInteraccion: 0,
              representacion: EfectoGoteoIntermitente(
                tinte: PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.85),
                intervaloGota: const Duration(milliseconds: 2600),
              ),
            ),
            HotspotEscenario(
              identificador: 'cartel_acceso_restringido_yuriovka',
              posicionRelativa: const Offset(0.92, 0.20),
              anchoRelativo: 0.05,
              altoRelativo: 0.10,
              radioInteraccion: 0.06,
              etiquetaAccion: 'LEER',
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/cartel_acceso_restringido.png',
                conSombra: false,
              ),
              onInteractuar: () => _registrar(
                'Placa atornillada a la compuerta: «ACCESO RESTRINGIDO — '
                'autorizado únicamente con sello vigente del Comité '
                'Yuriovka». El óxido come las letras desde abajo.',
              ),
            ),
            HotspotEscenario(
              identificador: 'compuerta_yuriovka',
              posicionRelativa: const Offset(0.94, 0.55),
              anchoRelativo: 0.04,
              altoRelativo: 0.36,
              radioInteraccion: 0.10,
              etiquetaAccion: 'CRUZAR',
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarCompuertaYuriovka,
            ),
            // Cabo del Cuerpo de Inspección haciendo ronda al fondo del
            // reactor, decorativo. Lo ves por la espalda; él no te ve.
            // Foreshadowing visual de la posible emboscada.
            HotspotEscenario(
              identificador: 'cabo_inspeccion_ronda',
              posicionRelativa: const Offset(0.88, 0.81),
              anchoRelativo: 0.07,
              altoRelativo: 0.22,
              radioInteraccion: 0.08,
              representacion: const Opacity(
                opacity: 0.88,
                child: IconoHotspotImagen(
                  rutaAsset: 'assets/svg/npc_cabo_inspeccion.png',
                  anchoSombra: 40,
                ),
              ),
              onInteractuar: () => _registrar(
                'El Cabo del Cuerpo de Inspección hace ronda lenta cerca de '
                'la compuerta. No te ve por la espalda. Aún.',
              ),
            ),
            // Grafiti revelado tras romper la pared débil.
            if (_grafitiRevelado)
              HotspotEscenario(
                identificador: 'grafiti_pravda7',
                posicionRelativa: const Offset(0.93, 0.84),
                anchoRelativo: 0.06,
                altoRelativo: 0.16,
                radioInteraccion: 0.08,
                representacion: const IconoHotspotGenerico(
                  painter: _PintorGrafitiPravda7Reactor(),
                  conSombra: false,
                ),
                animarRespiracion: false,
                onInteractuar: () => _registrar(
                  'Grafiti reciente, pintado a brocha gorda con tinta roja: '
                  '«PRAVDA-7 NO MURIÓ». Una flecha apunta al sello del '
                  'Comisariado. Alguien dentro del Comité disiente.',
                ),
              ),
            // Karenina Archivera: NPC nuevo a la izquierda del reactor,
            // archivando expedientes ignorando el caos. Diálogo
            // placeholder hasta que tenga su propia conversación.
            HotspotEscenario(
              identificador: 'karenina_archivera',
              posicionRelativa: const Offset(0.20, 0.81),
              anchoRelativo: 0.07,
              altoRelativo: 0.22,
              radioInteraccion: 0.14,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/images/karenina_archivera.png',
                anchoSombra: 120,
              ),
              onInteractuar: _interactuarKareninaArchivera,
            ),
          ],
          paredesDebiles: [_paredTuberiaOxidada],
          bolos: _conosMantenimiento,
          onTodosBolosTirados: (cantidad) {
            desencadenarHuevoPascua(
              context,
              estado: widget.estado,
              idHuevo: 'quincalla_vostrikova',
              registroEscenario: _registrar,
              claseCelebracion: widget.estado.personaje.clase,
            );
          },
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
          const Text('CRÓNICA DEL REACTOR',
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
                      'Aire denso, olor a aceite y vodka sintético. El reactor respira. Vostrikova suelda. La caja descansa cerca, oprimiendo el aire que la rodea.',
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
          if (widget.estado.flagsActivos.isNotEmpty) ...[
            const Divider(color: PaletaCosmoSovietica.tintaNegra, height: 1),
            const SizedBox(height: 6),
            const Text('EXPEDIENTE:',
                style: TipografiaPropaganda.etiquetaBurocratica),
            const SizedBox(height: 4),
            for (final flag in widget.estado.flagsActivos)
              Text('· ${_traducirFlag(flag)}',
                  style:
                      TipografiaPropaganda.textoLog.copyWith(fontSize: 11)),
            const SizedBox(height: 8),
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

  String _traducirFlag(String flag) {
    switch (flag) {
      case 'hablo_con_ostrog':
        return 'Hablaste con Ostrog';
      case 'caja_escondida_vela':
        return 'Escondiste la caja por Vostrikova';
      case 'caja_entregada_krilov':
        return 'Decidiste entregar la caja';
      case 'caja_vista':
        return 'Examinaste la caja';
      case 'te_de_madre':
        return 'Té de Madre Ferruginosa (+2 PA próx combate)';
      case 'venciste_cabo':
        return 'Venciste al Cabo';
      case 'caja_perdida_en_cabo':
        return 'El Cabo te arrebató la caja';
      default:
        return flag;
    }
  }
}


class _ModalNarrativoReactor extends StatelessWidget {
  final String titulo;
  final String cuerpo;
  final String textoBoton;
  final VoidCallback? onClose;

  const _ModalNarrativoReactor({
    required this.titulo,
    required this.cuerpo,
    required this.textoBoton,
    this.onClose,
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
                  onPressed: () {
                    Navigator.of(context).pop();
                    onClose?.call();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grafiti pintado con rotulador rojo tras la tubería oxidada del
/// reactor. Mensaje "PRAVDA-7 NO MURIÓ" con una flecha que apunta al
/// sello oficial. Es un huevo de pascua visual: solo aparece cuando
/// el cadete-bola rompe la pared débil con suficiente velocidad.
class _PintorGrafitiPravda7Reactor extends CustomPainter {
  const _PintorGrafitiPravda7Reactor();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint pinturaRoja = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.2, size.height * 0.035)
      ..strokeCap = StrokeCap.round;

    final double anchoTexto = size.width;
    final double y = size.height * 0.38;
    // Trazos del texto "P-7" simplificado a tres palos verticales y
    // una barra. No es una tipografía: es una pintada apresurada.
    final List<List<Offset>> trazosTexto = [
      // P
      [
        Offset(anchoTexto * 0.10, y - size.height * 0.22),
        Offset(anchoTexto * 0.10, y + size.height * 0.20),
      ],
      [
        Offset(anchoTexto * 0.10, y - size.height * 0.22),
        Offset(anchoTexto * 0.28, y - size.height * 0.10),
        Offset(anchoTexto * 0.10, y - size.height * 0.02),
      ],
      // 7
      [
        Offset(anchoTexto * 0.40, y - size.height * 0.22),
        Offset(anchoTexto * 0.62, y - size.height * 0.22),
        Offset(anchoTexto * 0.46, y + size.height * 0.20),
      ],
      // ! como tres puntos vibrantes
    ];
    for (final trazo in trazosTexto) {
      final ruta = Path()..moveTo(trazo[0].dx, trazo[0].dy);
      for (int i = 1; i < trazo.length; i++) {
        ruta.lineTo(trazo[i].dx, trazo[i].dy);
      }
      canvas.drawPath(ruta, pinturaRoja);
    }
    // Tres puntos de exclamación.
    final Paint puntos = Paint()..color = PaletaCosmoSovietica.rojoOficial;
    for (int idxPunto = 0; idxPunto < 3; idxPunto++) {
      canvas.drawCircle(
        Offset(anchoTexto * (0.78 + idxPunto * 0.06),
            y + size.height * 0.20),
        size.height * 0.045,
        puntos,
      );
    }
    // Flecha pequeña hacia abajo (apunta al sello del Comisariado).
    final Path flecha = Path()
      ..moveTo(anchoTexto * 0.40, y + size.height * 0.45)
      ..lineTo(anchoTexto * 0.50, y + size.height * 0.70)
      ..lineTo(anchoTexto * 0.60, y + size.height * 0.45);
    canvas.drawPath(
      flecha,
      Paint()
        ..color = PaletaCosmoSovietica.rojoOficial
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.6, size.height * 0.028)
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawLine(
      Offset(anchoTexto * 0.50, y + size.height * 0.30),
      Offset(anchoTexto * 0.50, y + size.height * 0.70),
      Paint()
        ..color = PaletaCosmoSovietica.rojoOficial
        ..strokeWidth = math.max(1.6, size.height * 0.028),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
