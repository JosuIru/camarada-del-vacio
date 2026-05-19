import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/encounters.dart';
import '../minijuegos/pantalla_boveda_suenos.dart';
import '../minijuegos/pantalla_dokumentris.dart';
import '../minijuegos/pantalla_frecuencia_747.dart';
import '../minijuegos/pantalla_pixel_perdido.dart';
import '../minijuegos/pantalla_transformacion.dart';
import '../models/game_class.dart';
import '../models/game_state.dart';
import '../theme.dart';
import 'pantalla_archivo_sellos.dart';
import '../utilities/page_transitions.dart';
import '../utilities/persistencia_partida.dart';
import '../widgets/ambient_particles.dart';
import '../widgets/ciclo_frames.dart';
import '../widgets/free_scene.dart';
import '../widgets/inventory_dialog.dart';
import '../widgets/mascota_narrativa.dart';
import '../widgets/notificacion_insignia.dart';
import '../widgets/overlay_celebracion.dart';
import '../widgets/paper_background.dart';
import '../widgets/propaganda_button.dart';
import 'bureaucratic_transition.dart';
import 'combat_screen.dart';
import 'overworld_map_screen.dart';

class PantallaSala extends StatefulWidget {
  final EstadoJuego estado;

  const PantallaSala({super.key, required this.estado});

  @override
  State<PantallaSala> createState() => _PantallaSalaState();
}

class _PantallaSalaState extends State<PantallaSala>
    with SingleTickerProviderStateMixin {
  final List<String> registroAcciones = [];
  bool dialogoInicialMostrado = false;
  bool combateResuelto = false;
  late AnimationController controladorFaseAmbiental;
  Offset? _puntoSalida;
  VoidCallback? _alCompletarSalida;

  late bool esRevisitaInicial;

  int _contadorClicksCapsula = 0;
  int _contadorClicksSamovar = 0;
  int _contadorPulsacionesOciosas = 0;

  // Elementos de modo bola: estado mutable que vive durante la
  // visita al escenario.
  final ObjetoEmpujable cajaArchivo = ObjetoEmpujable(
    identificador: 'caja_f447',
    posicion: const Offset(0.50, 0.82),
    radio: 0.045,
    etiqueta: 'F-447',
    factorEmpuje: 0.62,
  );
  final ParedDebilEscenario paredDebilCripta = ParedDebilEscenario(
    identificador: 'pared_cripta',
    rect: const Rect.fromLTWH(1.70, 0.70, 0.08, 0.20),
    etiqueta: 'ROMPER',
  );
  late final InterruptorPresion interruptorIluminacion;
  // Cuatro bolos burocráticos en fila.
  final List<BoloDecorativo> bolosBurocraticos = List<BoloDecorativo>.generate(
    4,
    (indicePino) => BoloDecorativo(
      identificador: 'bolo_$indicePino',
      posicion: Offset(1.30 + indicePino * 0.05, 0.75),
      radio: 0.018,
    ),
  );
  int totalStrikesBolos = 0;

  @override
  void initState() {
    super.initState();
    esRevisitaInicial = widget.estado.esRevisita('capsula');
    widget.estado.registrarVisitaModulo('capsula');
    combateResuelto =
        widget.estado.tieneFlag('combate_archivador_resuelto');
    controladorFaseAmbiental = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    interruptorIluminacion = InterruptorPresion(
      identificador: 'placa_luz_capsula',
      rect: const Rect.fromLTWH(0.78, 0.84, 0.06, 0.04),
      etiqueta: 'PLACA · LUZ',
      onPulsar: () {
        _registrar('★ Placa pulsada. El intercomunicador chisporrotea.');
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
    if (dialogoInicialMostrado) return;
    dialogoInicialMostrado = true;
    if (esRevisitaInicial) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _ModalNarrativo(
          titulo: 'CÁPSULA DE LLEGADA · REGRESO',
          cuerpo: combateResuelto
              ? 'Vuelves a la cápsula de llegada de la Pravda-12. El archivador, ahora dócil, exhala formularios sin alma. Tu cápsula original sigue acoplada, como un mal pensamiento. El intercomunicador permanece muerto.\n\nNo hay nada nuevo aquí salvo el silencio y el polvo de papel.'
              : 'Vuelves a la cápsula de llegada de la Pravda-12. El archivador sigue temblando al fondo, como si te recordase con afecto burocrático. La voz del intercomunicador no ha vuelto.',
          textoBoton: 'CONTINUAR',
        ),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ModalNarrativo(
        titulo: 'CÁPSULA DE LLEGADA · NAVE PRAVDA-12 · 1962',
        cuerpo:
            'Aterrizaje técnico en el cuadrante Sigma. La cápsula golpea mal contra la compuerta de acoplamiento de la Pravda-12. Una voz por el intercomunicador, áspera como un saco de tornillos:\n\n— Camarada cadete. Bienvenido a la Pravda-12. El Inspector llega en 14 horas. Misión nominal: localizar la estación orbital Pravda-7, desaparecida desde el martes —no, miércoles— en que el Camarada Directorskov apretó el botón equivocado.\n\nPausa larga.\n\n— Misión inmediata: asegúrese de que el archivador del fondo deje de hacer ese ruido. Y no lo abra. Si lo abre, rellene tres copias del F-447.\n\n(La voz se corta. La línea no había estado nunca activa.)',
        textoBoton: 'COMPRENDIDO',
      ),
    );
  }

  Future<void> _abrirInventario() async {
    await mostrarDialogoInventario(context, estado: widget.estado);
    if (!mounted) return;
    setState(() {});
  }

  void _abrirArchivoSellos() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PantallaArchivoSellos(estado: widget.estado),
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

  void _interactuarSamovar() {
    _contadorClicksSamovar++;
    if (_contadorClicksSamovar == 12 &&
        !widget.estado.tieneFlag('insignia_te_sin_sufrimiento')) {
      _registrar(
          'El samovar resopla y, a la duodécima súplica, te sirve un té sin invocar a la Madre. Te lo bebes de un trago. +2 PA al próximo combate.');
      widget.estado.activarFlag('te_de_madre');
      desbloquearInsigniaSiNueva(
        context,
        estado: widget.estado,
        identificadorFlag: 'insignia_te_sin_sufrimiento',
      );
      return;
    }
    if (_contadorClicksSamovar < 12) {
      _registrar(
          'Samovar industrial gigante. Murmura algo que podría ser un nombre o una receta. (${12 - _contadorClicksSamovar} pulsaciones más, dice el reglamento interno.)');
    } else {
      _registrar('El samovar duerme, satisfecho. No queda té oficial.');
    }
  }

  void _interactuarCapsula() {
    _contadorClicksCapsula++;
    if (_contadorClicksCapsula == 3 &&
        !widget.estado.tieneFlag('insignia_martir_del_tornillo')) {
      widget.estado.personaje.aplicarDanoFisico(1);
      _registrar(
          'Tu dedo encuentra el remache mal soldado. Sangras 1 PV. Te otorgan, en secreto, una insignia honorífica.');
      desbloquearInsigniaSiNueva(
        context,
        estado: widget.estado,
        identificadorFlag: 'insignia_martir_del_tornillo',
      );
      setState(() {});
      return;
    }
    _registrar(
        'Tu cápsula de llegada. La compuerta sigue medio acoplada. No conviene volver dentro.');
  }

  void _alCodigoSecretoMundoLibre(String identificadorCodigo) {
    if (identificadorCodigo == 'konami_invertido') {
      desbloquearInsigniaSiNueva(
        context,
        estado: widget.estado,
        identificadorFlag: 'insignia_cadete_traidor',
      );
      _registrar(
          'El cadete, sin testigos, ejecuta una secuencia de movimientos no homologados. Una libreta invisible toma nota.');
    }
  }

  void _alPulsacionInteraccionOciosa() {
    _contadorPulsacionesOciosas++;
    if (_contadorPulsacionesOciosas == 12 &&
        !widget.estado.tieneFlag('insignia_pulgar_del_comisariado')) {
      desbloquearInsigniaSiNueva(
        context,
        estado: widget.estado,
        identificadorFlag: 'insignia_pulgar_del_comisariado',
      );
      _registrar(
          'Has pulsado tramitar contra el vacío doce veces. El Comité, conmovido, te concede una insignia honorífica.');
    }
  }

  void _alCadeteQuietoLargoRato() {
    final estaCercaDelArchivador =
        !widget.estado.tieneFlag('insignia_susurro_archivero') &&
            combateResuelto;
    if (!estaCercaDelArchivador) return;
    desbloquearInsigniaSiNueva(
      context,
      estado: widget.estado,
      identificadorFlag: 'insignia_susurro_archivero',
    );
    _registrar(
        'El archivador, al cabo de cuatro segundos de silencio total, te susurra un nombre que no recuerdas haber pronunciado.');
  }

  void _interactuarMangueraCombustible() {
    _registrar(
        'Manguera de combustible enrollada en el suelo. Conecta tu cápsula al deposito de la Pravda-12. Por el caudalímetro asoma «11.2 l/min · directo al reactor».');
  }

  void _interactuarRetratoFamiliar() {
    _registrar(
        'Retrato familiar. Dos siluetas borrosas, la marca rectangular de una tercera figura recortada. Se rumorea que el cadete tuvo un hermano hasta el día en que Petrov 58 cerró el archivo.');
  }

  void _interactuarCatre() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _ModalNarrativo(
        titulo: 'TU CATRE',
        cuerpo:
            'Manta roja con estrella bordada. Bajo la almohada: una linterna y un cuaderno de hule negro. Si te tumbas, no piensas dormir: vas a hacer turno doble de papeleo, mental.\n\n¿Cierras los ojos un momento?',
        textoBoton: 'Tumbarte',
        onClose: _entrarSuenoDokumentris,
      ),
    );
  }

  void _entrarSuenoDokumentris() {
    _registrar(
        'Cierras los ojos. Detrás de los párpados caen formularios sin parar; tu cuerpo se aplana en un F-447 vacío.');
    Navigator.of(context).push(
      crearRutaConTransicion(
        PantallaTransformacion(
          formaDestino: FormaProtagonista.piezaTetris,
          nombreLugar: 'SUEÑO BUROCRÁTICO',
          fraseTransformacion:
              'En tu sueño eres un F-447 cayendo en una columna infinita.',
          alTerminar: () {
            Navigator.of(context).pushReplacement(
              crearRutaConTransicion(
                PantallaDokumentris(estado: widget.estado),
              ),
            );
          },
        ),
      ),
    );
  }

  void _interactuarAlmohada() {
    _registrar(
        'La almohada está rota por una esquina. Por dentro sale aire helado y un susurro: "duerme un poco más, cadete". Si apoyas la cara en ella, el archivo nocturno te confisca cinco recuerdos antes de devolverte.');
    Navigator.of(context).push(
      crearRutaConTransicion(
        PantallaBovedaSuenos(estado: widget.estado),
      ),
    );
  }

  void _interactuarTuboFontaneria() {
    _registrar(
        'Un tubo verde brillante sobresale del suelo, junto al baúl. No es un tubo de la nave: es del otro lado del cosmos. Si te metes, tu cuerpo se reduce al tamaño de un píxel.');
    Navigator.of(context).push(
      crearRutaConTransicion(
        PantallaTransformacion(
          formaDestino: FormaProtagonista.cadete,
          nombreLugar: 'TUBERÍA DEL PÍXEL',
          fraseTransformacion:
              'Te cuelas en el tubo. El mundo se vuelve cuadrados. Saltas mejor que nunca.',
          alTerminar: () {
            Navigator.of(context).pushReplacement(
              crearRutaConTransicion(
                PantallaPixelPerdido(estado: widget.estado),
              ),
            );
          },
        ),
      ),
    );
  }

  void _interactuarRejillaVentilacion() {
    _registrar(
        'Detrás del cabecero del catre hay una rejilla de ventilación oxidada. Por una de las rendijas se filtra un siseo: alguien transmite. Si pegas la oreja, tu cuerpo se aplana hasta convertirse en señal.');
    Navigator.of(context).push(
      crearRutaConTransicion(
        PantallaTransformacion(
          formaDestino: FormaProtagonista.agujaRadio,
          nombreLugar: 'FRECUENCIA 7.47 MHz',
          fraseTransformacion:
              'Tu cuerpo se vuelve aguja; tu oído, dial. La estática te abraza.',
          alTerminar: () {
            Navigator.of(context).pushReplacement(
              crearRutaConTransicion(
                PantallaFrecuencia747(estado: widget.estado),
              ),
            );
          },
        ),
      ),
    );
  }

  void _interactuarMesillaVela() {
    _registrar(
        'Mesilla de noche. Una vela encendida, un cajón cerrado, una llave colgando del tirador del cajón. La llave no corresponde al cajón.');
  }

  void _interactuarEspejoLavabo() {
    _registrar(
        'Lavabo metálico. Espejo encima. Tu reflejo parpadea con dos décimas de retraso, como si el cristal dudara antes de copiarte.');
  }

  void _interactuarEstanteLibros() {
    _registrar(
        'Seis libros: el manual del cosmonauta (lomo gastado), dos volúmenes de propaganda, una novela tachada con tinta roja, un diario íntimo del Capitán Vassiliev, y un libro sin título que pesa demasiado.');
  }

  void _interactuarUniformeColgado() {
    _registrar(
        'Uniforme verde archivo colgado. Estrella roja en la solapa. La etiqueta del cuello dice "G. Vassiliev". El uniforme no es tuyo. Nadie ha venido a recogerlo.');
  }

  void _interactuarCalendario() {
    _registrar(
        'Calendario MAЯ-1962. Hoy está tachado en rojo. Mañana también. Pasado mañana también. La X roja se extiende hasta el final del mes, en letra que no recuerdas haber escrito.');
  }

  void _interactuarBaulCandado() {
    _registrar(
        'Baúl con candado pesado. La llave que cuelga de la mesilla no encaja. La etiqueta del baúl dice «PERTENENCIAS · CADETE ANTERIOR».');
  }

  void _interactuarIntercomunicador() {
    _registrar(
        'Panel intercomunicador. El botón rojo parpadea. Si lo pulsas, sólo se oye respiración pesada y, al fondo, alguien marcando un sello rítmicamente.');
  }

  void _interactuarSarcofagoInquilino() {
    _registrar(
        'Sarcófago criogénico del Inquilino nº 4. Etiqueta amarillenta: '
        '«MISIÓN PETROV · 1958 · NO ABRIR HASTA EL MIÉRCOLES». El cristal '
        'está empañado por dentro. Si miras fijamente cinco segundos, '
        'crees ver una mano apoyada contra el cristal. Ostrog dijo que '
        'si pita, finges que es la nevera.');
  }

  void _interactuarPuertaCantina() {
    if (!combateResuelto) {
      _registrar(
          'Compuerta al Pasillo Central. Bloqueada hasta resolver el incidente del archivador.');
      return;
    }
    _iniciarSalidaYTransicion(_avanzarAlMapa);
  }

  void _iniciarSalidaYTransicion(VoidCallback alLlegar) {
    setState(() {
      _puntoSalida = const Offset(1.08, 0.55);
      _alCompletarSalida = alLlegar;
    });
  }

  void _interactuarArchivador() {
    if (combateResuelto) {
      _registrar(
          'El archivador, ahora calmo, exhala formularios sin alma.');
      return;
    }
    _dispararCombateConArchivador();
  }

  void _dispararCombateConArchivador() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ModalNarrativo(
        titulo: 'EL ARCHIVADOR REACCIONA',
        cuerpo:
            'Abres el cajón superior. De su interior brota, con un crujido de papel rancio, un Funcionario Espectral de Archivo. De dos cajones inferiores escapan, chillando, dos Ratas Mutadas.\n\n— ¡Documentación, ciudadano!\n\nEl archivador queda abierto.',
        textoBoton: 'DEFENDERSE',
        onClose: () async {
          final resultado = await Navigator.of(context).push<bool>(
            crearRutaConTransicion<bool>(
              PantallaCombate(
                estado: widget.estado,
                tipoEncuentro: TipoEncuentro.archivadorYRatas,
              ),
            ),
          );
          if (!mounted) return;
          if (resultado == true) {
            setState(() {
              combateResuelto = true;
            });
            widget.estado.activarFlag('combate_archivador_resuelto');
            desbloquearInsigniaSiNueva(
              context,
              estado: widget.estado,
              identificadorFlag: 'insignia_primer_combate',
            );
            _registrar(
                'El Funcionario se disuelve, las ratas huyen. La compuerta al pasillo se desbloquea.');
            showDialog(
              context: context,
              builder: (_) => _ModalNarrativo(
                titulo: 'EXPEDIENTE CERRADO',
                cuerpo:
                    'El archivador descansa. El intercomunicador crepita: «Bien hecho, cadete. Acuda al Plano Oficial para reasignación operativa».\n\nLa compuerta al pasillo central se desbloquea con un suspiro hidráulico.',
                textoBoton: 'CRUZAR AL PASILLO',
                onClose: () => _iniciarSalidaYTransicion(_avanzarAlMapa),
              ),
            );
          }
        },
      ),
    );
  }

  void _avanzarAlMapa() {
    Navigator.of(context).pushReplacement(
      crearRutaConTransicion(
        PantallaTransicionBurocratica(
          codigoInforme: 'INFORME 472-B · TRÁNSITO INTERNO',
          tituloInforme: 'INCIDENTE DEL ARCHIVADOR Nº 404',
          cuerpoInforme:
              'A las 04:42 hora estación, el cadete asignado al módulo de '
              'llegada de la nave Pravda-12 procedió a la apertura del '
              'archivador metálico nº 404. Tras la apertura se reportó la '
              'aparición de un Funcionario Espectral de Archivo (clase ω) y '
              'dos Ratas Mutadas de Mantenimiento.\n\n'
              'El cadete neutralizó a las entidades por medios no del todo '
              'documentados (formulario F-447, copia carbónica n.º 3 anexa).\n\n'
              'Se recomienda que el incidente conste como "expediente cerrado" '
              'y que el cadete consulte el Plano Oficial para reasignación '
              'operativa: localizar la estación Pravda-7, perdida en el '
              'cuadrante Sigma.\n\n'
              'Firma del responsable: ILEGIBLE.\n'
              'Visado: pendiente.',
          selloFinal: 'APROBADO POR EL PARTIDO',
          pantallaDestino: PantallaMapaOverworld(
            estado: widget.estado,
            moduloDestacado: 'cantina',
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
                    const Text('CÁPSULA DE LLEGADA · PRAVDA-12',
                        style: TipografiaPropaganda.tituloSeccion),
                    Text(
                      'CADETE · ${widget.estado.personaje.clase?.etiquetaCorta.toUpperCase() ?? '???'}',
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
                  'Pulsa un objeto o el suelo. El cadete camina hasta el destino antes de interactuar.',
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
          rutaImagenFondo: 'assets/images/fondo_capsula.png',
          claseJugador: widget.estado.personaje.clase,
          idSombreroEquipado: widget.estado.idObjetoCabezaEquipado,
          idArmaEquipada: widget.estado.idObjetoArmaEquipada,
          idTorsoEquipado: widget.estado.idObjetoTorsoEquipado,
          capaAmbiental: const CapaParticulasAmbientales(
            tipoAmbiente: TipoAmbiente.motasArchivo,
            cantidadParticulas: 38,
          ),
          factorAnchoMundo: 2.0,
          bordeSuperior: 0.68,
          bordeInferior: 0.92,
          posicionInicialJugador: const Offset(0.08, 0.86),
          puntoEntradaInicial: const Offset(-0.02, 0.86),
          puntoSalidaActiva: _puntoSalida,
          onCodigoSecreto: _alCodigoSecretoMundoLibre,
          onPulsacionInteraccionOciosa: _alPulsacionInteraccionOciosa,
          onCadeteQuietoLargoRato: _alCadeteQuietoLargoRato,
          alCompletarSalida: () {
            final cb = _alCompletarSalida;
            _alCompletarSalida = null;
            _puntoSalida = null;
            cb?.call();
          },
          hotspots: [
            // ─── Zona A · Plataforma aterrizaje (0.00 – 0.20) ───
            HotspotEscenario(
              identificador: 'capsula',
              // PNG capsula.png es 1254×1254 (ratio 1.0). Antes el rect
              // era 0.14×0.50 → ratio 0.28 vertical-extremo y altura
              // media pantalla. Reescalado a cuadrado proporcional al
              // resto de muebles del suelo.
              posicionRelativa: const Offset(0.08, 0.78),
              anchoRelativo: 0.18,
              altoRelativo: 0.22,
              radioInteraccion: 0.12,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/capsula.png',
                anchoSombra: 110,
              ),
              onInteractuar: _interactuarCapsula,
            ),
            HotspotEscenario(
              identificador: 'manguera_combustible',
              posicionRelativa: const Offset(0.16, 0.84),
              anchoRelativo: 0.04,
              altoRelativo: 0.08,
              radioInteraccion: 0.07,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/capsula_manguera_combustible.png',
                anchoSombra: 40,
              ),
              onInteractuar: _interactuarMangueraCombustible,
            ),
            HotspotEscenario(
              identificador: 'samovar',
              posicionRelativa: const Offset(0.24, 0.75),
              anchoRelativo: 0.06,
              altoRelativo: 0.28,
              radioInteraccion: 0.10,
              representacion: const Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // El samovar ocupa los dos tercios inferiores; el
                  // tercio superior queda libre para el vapor.
                  Padding(
                    padding: EdgeInsets.only(top: 110, bottom: 6),
                    child: IconoHotspotImagen(
                      rutaAsset: 'assets/svg/samovar_oficial.png',
                      anchoSombra: 60,
                    ),
                  ),
                  // Vapor animado: 3 frames del set §10 del briefing.
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 140,
                    child: IgnorePointer(
                      child: CicloDeFrames(
                        rutasFrames: [
                          'assets/svg/samovar_humo_f01.png',
                          'assets/svg/samovar_humo_f02.png',
                          'assets/svg/samovar_humo_f03.png',
                        ],
                        duracionPorFrame: Duration(milliseconds: 420),
                      ),
                    ),
                  ),
                ],
              ),
              onInteractuar: _interactuarSamovar,
            ),

            // ─── Zona B · Dormitorio (0.20 – 0.45) ───
            HotspotEscenario(
              identificador: 'retrato_familiar',
              posicionRelativa: const Offset(0.245, 0.26),
              anchoRelativo: 0.05,
              altoRelativo: 0.12,
              radioInteraccion: 0.08,
              // Ya está pintado en fondo_capsula.png. El PNG de §12.1
              // queda generado y disponible — se cableará cuando se
              // regenere el fondo "limpio" (sólo arquitectura).
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarRetratoFamiliar,
            ),
            HotspotEscenario(
              identificador: 'catre',
              posicionRelativa: const Offset(0.32, 0.84),
              // Ratio del PNG capsula_catre.png: 400×260 = 1.54 (cama
              // horizontal). El rect anterior (0.10×0.14 = 0.71) lo
              // pintaba aplastado en vertical. Manteniendo altoRel,
              // el ancho coherente con el PNG es 0.14·1.54 ≈ 0.215.
              anchoRelativo: 0.22,
              altoRelativo: 0.14,
              radioInteraccion: 0.10,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/capsula_catre.png',
                anchoSombra: 110,
              ),
              onInteractuar: _interactuarCatre,
            ),
            HotspotEscenario(
              identificador: 'almohada',
              // Cabecera DERECHA del catre (centro del catre 0.32,
              // ancho 0.22 → borde derecho 0.43). El extremo izquierdo
              // (~0.245) colisionaba visualmente con el samovar/cafetera
              // que está en 0.24 con ancho 0.06, dando sensación de
              // almohada flotando sobre la cafetera en lugar del catre.
              posicionRelativa: const Offset(0.39, 0.82),
              // PNG mueble_almohada.png: 1536×1024 = 1.50. Antes era
              // cuadrada (0.05×0.05 = 1.00) → recalibrada a 0.075×0.05.
              anchoRelativo: 0.075,
              altoRelativo: 0.05,
              radioInteraccion: 0.06,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/mueble_almohada.png',
                conSombra: false,
              ),
              onInteractuar: _interactuarAlmohada,
            ),
            HotspotEscenario(
              identificador: 'mesilla_vela',
              // Desplazada un poco a la derecha para que no choque con
              // el nuevo catre ensanchado (borde derecho del catre ~0.43).
              posicionRelativa: const Offset(0.50, 0.83),
              // PNG capsula_mesilla_vela.png: 220×320 = 0.69. Antes era
              // 0.04×0.18 = 0.22 (demasiado estrecha) → recalibrada.
              anchoRelativo: 0.12,
              altoRelativo: 0.18,
              radioInteraccion: 0.08,
              // §12.3: el sprite nuevo incluye mesilla + vela en uno;
              // sustituye al `mueble_vela.png` anterior (sólo vela).
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/capsula_mesilla_vela.png',
                anchoSombra: 60,
              ),
              onInteractuar: _interactuarMesillaVela,
            ),

            // ─── Zona C · Aseo y vestuario (0.45 – 0.70) ───
            HotspotEscenario(
              identificador: 'espejo_lavabo',
              posicionRelativa: const Offset(0.50, 0.62),
              anchoRelativo: 0.06,
              altoRelativo: 0.22,
              radioInteraccion: 0.08,
              // Ya está pintado en fondo_capsula.png. PNG §12.4 generado.
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarEspejoLavabo,
            ),
            HotspotEscenario(
              identificador: 'estante_libros',
              posicionRelativa: const Offset(0.585, 0.42),
              anchoRelativo: 0.07,
              altoRelativo: 0.13,
              radioInteraccion: 0.08,
              // Ya está pintado en fondo_capsula.png. PNG §12.5 generado.
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarEstanteLibros,
            ),
            HotspotEscenario(
              identificador: 'uniforme_colgado',
              posicionRelativa: const Offset(0.66, 0.50),
              anchoRelativo: 0.06,
              altoRelativo: 0.22,
              radioInteraccion: 0.08,
              // Ya está pintado en fondo_capsula.png. PNG §12.6 generado.
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarUniformeColgado,
            ),

            // ─── Zona D · Oficina con archivador (0.70 – 1.00) ───
            HotspotEscenario(
              identificador: 'calendario',
              posicionRelativa: const Offset(0.745, 0.27),
              anchoRelativo: 0.05,
              altoRelativo: 0.14,
              radioInteraccion: 0.08,
              // Ya está pintado en fondo_capsula.png. PNG §12.7 generado.
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarCalendario,
            ),
            HotspotEscenario(
              identificador: 'baul_candado',
              posicionRelativa: const Offset(0.825, 0.83),
              anchoRelativo: 0.09,
              altoRelativo: 0.1,
              radioInteraccion: 0.08,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/mueble_caja_anonima.png',
                anchoSombra: 56,
              ),
              onInteractuar: _interactuarBaulCandado,
            ),
            HotspotEscenario(
              identificador: 'tubo_pixel',
              // PNG mueble_tubo.png es 887×1774 = ratio 0.50 (tubo
              // vertical estrecho pero no extremo). Antes el rect era
              // 0.05×0.18 = ratio 0.28 → tubo más estrecho de lo real.
              // Separado del baúl (en 0.825): rectángulo del tubo
              // (0.665..0.755) ya no se mete dentro del rect del baúl
              // (0.78..0.87).
              posicionRelativa: const Offset(0.71, 0.84),
              anchoRelativo: 0.09,
              altoRelativo: 0.18,
              radioInteraccion: 0.10,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/mueble_tubo.png',
                anchoSombra: 70,
              ),
              onInteractuar: _interactuarTuboFontaneria,
            ),
            HotspotEscenario(
              identificador: 'archivador',
              // Posicionada sobre la estantería de archivadores que el
              // fondo de la cápsula YA dibuja (con etiquetas F-A2, A-2,
              // M-7, Z-12 y "АРХИВО"). El PNG independiente duplicaba
              // visualmente la estantería y aparecía flotando al lado.
              // Mantiene la interacción como hotspot invisible.
              posicionRelativa: const Offset(0.875, 0.42),
              anchoRelativo: 0.07,
              altoRelativo: 0.20,
              radioInteraccion: 0.10,
              destacar: !combateResuelto,
              etiquetaAccion: combateResuelto ? 'EXAMINAR' : 'ABRIR',
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarArchivador,
            ),
            // Residuo fantasmal del Funcionario Espectral de Archivo:
            // tras vencerlo en el combate inicial, su silueta sigue
            // flotando sobre el archivador, firmando F-447 invisibles.
            // Patrón análogo al Cabo en reactor y Directorskov en
            // Pravda-7: hotspot decorativo, sin combate, opacidad baja.
            if (combateResuelto)
              HotspotEscenario(
                identificador: 'funcionario_espectral_residual',
                posicionRelativa: const Offset(0.80, 0.78),
                anchoRelativo: 0.07,
                altoRelativo: 0.22,
                radioInteraccion: 0.10,
                animarRespiracion: false,
                etiquetaAccion: 'EXAMINAR',
                representacion: AnimatedBuilder(
                  animation: controladorFaseAmbiental,
                  builder: (contexto, hijo) {
                    final double fase = controladorFaseAmbiental.value;
                    final double oscilacionY =
                        math.sin(fase * math.pi * 2) * 5;
                    return Transform.translate(
                      offset: Offset(0, oscilacionY),
                      child: hijo,
                    );
                  },
                  child: const Opacity(
                    opacity: 0.55,
                    child: Image(
                      image: AssetImage(
                          'assets/svg/npc_funcionario_espectral.png'),
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
                onInteractuar: () => _registrar(
                  'Sobre el archivador, todavía hoy, una silueta espectral '
                  'firma formularios que no existen. El Funcionario '
                  'Espectral no se ha ido del todo. Nunca lo hacen.',
                ),
              ),
            HotspotEscenario(
              identificador: 'intercomunicador',
              posicionRelativa: const Offset(0.945, 0.31),
              anchoRelativo: 0.05,
              altoRelativo: 0.12,
              radioInteraccion: 0.08,
              // Ya está pintado en fondo_capsula.png. PNG §12.8 generado.
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarIntercomunicador,
            ),
            // Sarcófago del Inquilino #4 (cosmonauta congelado desde la
            // Misión Petrov 58, mencionado por Ostrog). Hotspot
            // decorativo: el lore lo cita pero el jugador nunca lo veía.
            HotspotEscenario(
              identificador: 'sarcofago_inquilino4',
              posicionRelativa: const Offset(0.62, 0.88),
              anchoRelativo: 0.10,
              altoRelativo: 0.10,
              radioInteraccion: 0.10,
              etiquetaAccion: 'EXAMINAR',
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/sarcofago.png',
                anchoSombra: 90,
              ),
              onInteractuar: _interactuarSarcofagoInquilino,
            ),
            HotspotEscenario(
              identificador: 'rejilla_ventilacion',
              posicionRelativa: const Offset(0.40, 0.18),
              anchoRelativo: 0.08,
              altoRelativo: 0.12,
              radioInteraccion: 0.08,
              destacar: false,
              representacion: const IconoHotspotImagen(
                rutaAsset: 'assets/svg/mueble_rejilla_ventilacion.png',
                conSombra: false,
              ),
              onInteractuar: _interactuarRejillaVentilacion,
            ),
            HotspotEscenario(
              identificador: 'puerta_cantina',
              posicionRelativa: const Offset(0.97, 0.65),
              anchoRelativo: 0.04,
              altoRelativo: 0.30,
              radioInteraccion: 0.12,
              destacar: combateResuelto,
              representacion: const SizedBox.shrink(),
              onInteractuar: _interactuarPuertaCantina,
            ),
          ],
          grietas: [
            // Grieta del Píxel Perdido — cubierta inicialmente por
            // la caja F-447. Hay que empujar la caja para revelarla
            // y luego transformarse en bola.
            GrietaEscenario(
              identificador: 'grieta_pixel_perdido_capsula',
              rect: const Rect.fromLTWH(0.48, 0.84, 0.10, 0.04),
              etiqueta: 'PÍXEL PERDIDO · RODAR',
              onAtravesarEnBola: _abrirGrietaPixelPerdido,
            ),
            // Grieta detrás de la pared débil — sólo accesible tras
            // romperla con la bola.
            GrietaEscenario(
              identificador: 'grieta_dokumentris_capsula',
              rect: const Rect.fromLTWH(1.74, 0.84, 0.06, 0.04),
              etiqueta: 'DOKUMENTRIS',
              onAtravesarEnBola: _abrirGrietaDokumentris,
            ),
          ],
          objetosEmpujables: [cajaArchivo],
          bolos: bolosBurocraticos,
          onTodosBolosTirados: (cantidad) {
            setState(() {
              totalStrikesBolos += 1;
            });
            _registrar(
              '★ STRIKE BUROCRÁTICO · $totalStrikesBolos pleno(s) acumulado(s).',
            );
            // Insignia honorífica al primer strike. Los siguientes
            // strikes siguen disparando la celebración pero la insignia
            // ya está desbloqueada (idempotente).
            desbloquearInsigniaSiNueva(
              context,
              estado: widget.estado,
              identificadorFlag: 'insignia_strike_burocratico',
            );
            mostrarCelebracion(
              context,
              texto: '¡STRIKE!',
              subtitulo: 'PLENO N°$totalStrikesBolos\n'
                  'El Comité aprueba con expediente.',
              clase: widget.estado.personaje.clase,
              duracion: const Duration(milliseconds: 2200),
            );
          },
          paredesDebiles: [paredDebilCripta],
          interruptores: [interruptorIluminacion],
          mascota: mascotaLaikaSiProcede(
            widget.estado,
            identificadorEscenario: 'capsula',
            frasesEspecificas: const <String>[
              'Guau, camarada.',
              'Esto huele a F-447.',
              'El intercomunicador está muerto.',
              'Bola, bola.',
              'Aquí dormiste mal anoche.',
            ],
          ),
        ),
      ),
    );
  }

  void _abrirGrietaPixelPerdido() {
    if (!mounted) return;
    _registrar(
      '★ Grieta del suelo. El cadete-bola rueda hacia el píxel perdido.',
    );
    Navigator.of(context).push(
      crearRutaConTransicion(
        PantallaPixelPerdido(estado: widget.estado),
      ),
    );
  }

  void _abrirGrietaDokumentris() {
    if (!mounted) return;
    _registrar(
      '★ Tras la pared rota, la grieta lleva al expedientario rotativo.',
    );
    Navigator.of(context).push(
      crearRutaConTransicion(
        PantallaDokumentris(estado: widget.estado),
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
          const Text('CRÓNICA DE LA SALA',
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
                      'La sala huele a metal frío. Un archivador al fondo. Tu cápsula sigue tibia. El intercomunicador acaba de cortarse.',
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
                  texto: 'Archivo F-447',
                  compacto: true,
                  onPressed: _abrirArchivoSellos,
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

class _ModalNarrativo extends StatelessWidget {
  final String titulo;
  final String cuerpo;
  final String textoBoton;
  final VoidCallback? onClose;

  const _ModalNarrativo({
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

