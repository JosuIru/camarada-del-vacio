import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../data/classes.dart';
import '../models/character.dart';
import '../models/game_class.dart';
import '../models/game_state.dart';
import '../theme.dart';
import '../utilities/audio_procedural.dart';
import '../utilities/navegacion_partida_cargada.dart';
import '../widgets/ciclo_frames.dart';
import '../utilities/page_transitions.dart';
import '../utilities/persistencia_partida.dart';
import '../widgets/propaganda_button.dart';
import '../minijuegos/pantalla_boveda_suenos.dart';
import '../minijuegos/pantalla_camarada_invasors.dart';
import '../minijuegos/pantalla_cosmoom_doom.dart';
import '../minijuegos/pantalla_dokumentris.dart';
import '../minijuegos/pantalla_frecuencia_747.dart';
import '../minijuegos/pantalla_inspektor_pacman.dart';
import '../minijuegos/pantalla_pinball_comite.dart';
import '../minijuegos/pantalla_pixel_perdido.dart';
import '../minijuegos/pantalla_snow_kamarada.dart';
import '../minijuegos/pantalla_super_pang.dart';
import 'canteen_screen.dart';
import 'class_select_screen.dart';
import 'cuadrante_sigma_screen.dart';
import 'overworld_map_screen.dart';
import 'planeta_gelida9_screen.dart';
import 'planeta_pravda7_screen.dart';
import 'planeta_sol_camarada_screen.dart';
import 'planeta_zovnak4_screen.dart';
import 'reactor_screen.dart';
import 'room_screen.dart';

class PantallaTitulo extends StatefulWidget {
  const PantallaTitulo({super.key});

  @override
  State<PantallaTitulo> createState() => _PantallaTituloState();
}

class _PantallaTituloState extends State<PantallaTitulo>
    with TickerProviderStateMixin {
  late AnimationController controladorPalpitacion;
  late AnimationController controladorTembleque;
  bool _hayPartidaGuardada = false;
  bool _estaCargandoPartida = false;

  // Huevo de pascua meta: 7 toques sobre la estrella roja activan el
  // modo "Expediente Sin Filtro" (cambio cosmético + sello rojo + temblor
  // de la portada). No persiste entre sesiones porque la pantalla de
  // título es anterior a cualquier EstadoJuego.
  int _contadorPulsacionesEstrella = 0;
  bool _expedienteSinFiltroActivo = false;

  @override
  void initState() {
    super.initState();
    controladorPalpitacion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    controladorTembleque = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _verificarSiExistePartidaGuardada();
  }

  Future<void> _verificarSiExistePartidaGuardada() async {
    final existe = await persistenciaPartida.existePartidaGuardada();
    if (!mounted) return;
    setState(() => _hayPartidaGuardada = existe);
  }

  Future<void> _intentarCargarPartida() async {
    if (_estaCargandoPartida) return;
    setState(() => _estaCargandoPartida = true);
    // Primero probamos el slot principal; si está vacío, caemos al autosave.
    final estadoCargadoPrincipal =
        await persistenciaPartida.cargarPartidaPrincipal();
    final estadoCargado =
        estadoCargadoPrincipal ?? await persistenciaPartida.cargarAutoguardado();
    if (!mounted) return;
    if (estadoCargado == null) {
      setState(() => _estaCargandoPartida = false);
      _mostrarAvisoCargaFallida();
      return;
    }
    navegarAPartidaCargada(context, estadoCargado);
  }

  void _mostrarAvisoCargaFallida() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: PaletaCosmoSovietica.papelViejo,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            color: PaletaCosmoSovietica.tintaNegra,
            width: 3,
          ),
        ),
        title: const Text(
          'EXPEDIENTE ILEGIBLE',
          style: TipografiaPropaganda.etiquetaBurocratica,
        ),
        content: const Text(
          'El archivero no consigue restaurar la partida. El Comité recomienda iniciar un nuevo expediente.',
          style: TipografiaPropaganda.cuerpoLargo,
        ),
        actions: [
          BotonPropaganda(
            texto: 'Entendido',
            destacado: true,
            compacto: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controladorPalpitacion.dispose();
    controladorTembleque.dispose();
    super.dispose();
  }

  void _alPulsarEstrellaRoja() {
    if (_expedienteSinFiltroActivo) {
      // Ya estaba activo: redisparamos sello y temblor como recordatorio.
      _disparoSelloExpediente();
      return;
    }
    setState(() {
      _contadorPulsacionesEstrella++;
    });
    audioProcedural.reproducirSubidaDeNivel();
    if (_contadorPulsacionesEstrella >= 7) {
      setState(() {
        _expedienteSinFiltroActivo = true;
      });
      _disparoSelloExpediente();
    } else {
      // Temblor breve para indicar que está pasando algo.
      controladorTembleque
        ..reset()
        ..animateTo(0.35, duration: const Duration(milliseconds: 220));
    }
  }

  void _disparoSelloExpediente() {
    controladorTembleque
      ..reset()
      ..forward();
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    late OverlayEntry entrada;
    entrada = OverlayEntry(
      builder: (_) => _SelloExpedienteSinFiltro(
        alTerminar: () {
          if (entrada.mounted) entrada.remove();
        },
      ),
    );
    overlay.insert(entrada);
  }

  /// Construye un EstadoJuego listo para saltar a cualquier escenario
  /// específico, con las flags y objetos necesarios para que la escena no
  /// se quede bloqueada por requisitos previos del flujo normal.
  EstadoJuego _construirEstadoDebug(String identificadorEscenario) {
    final definicion = catalogoClases[ClaseCosmonauta.gimnasta]!;
    final personaje = Combatiente(
      nombre: 'Cadete Debug',
      esJugador: true,
      clase: definicion.identificador,
      cuerpo: definicion.cuerpoBase,
      mente: definicion.menteBase,
      carisma: definicion.carismaBase,
      puntosVidaMaximos: definicion.puntosVidaMaximos,
      moralMaxima: definicion.moralMaxima,
    );
    final estado = EstadoJuego(personaje: personaje);
    estado.anadirObjeto('gorra_cosmonauta');
    estado.idObjetoCabezaEquipado = 'gorra_cosmonauta';

    switch (identificadorEscenario) {
      case 'capsula':
        // Sin flags adicionales: experiencia limpia.
        break;
      case 'cantina':
        estado.activarFlag('combate_archivador_resuelto');
        break;
      case 'reactor':
        estado.activarFlag('combate_archivador_resuelto');
        estado.activarFlag('hablo_con_ostrog');
        break;
      case 'cuadrante_sigma':
        estado.activarFlag('combate_archivador_resuelto');
        estado.activarFlag('hablo_con_ostrog');
        estado.activarFlag('pista_pravda7_inicial');
        break;
      case 'zovnak4':
      case 'gelida9':
        estado.activarFlag('combate_archivador_resuelto');
        estado.activarFlag('hablo_con_ostrog');
        estado.activarFlag('pista_pravda7_inicial');
        break;
      case 'sol_camarada':
        estado.activarFlag('combate_archivador_resuelto');
        estado.activarFlag('hablo_con_ostrog');
        estado.activarFlag('pista_pravda7_inicial');
        estado.activarFlag('rumor_pravda7');
        estado.activarFlag('rumor_pravda7_fragmento2');
        estado.anadirObjeto('fragmento_bitacora_pravda7_2');
        break;
      case 'pravda7':
        estado.activarFlag('combate_archivador_resuelto');
        estado.activarFlag('hablo_con_ostrog');
        estado.activarFlag('pista_pravda7_inicial');
        estado.activarFlag('rumor_pravda7');
        estado.activarFlag('rumor_pravda7_fragmento2');
        estado.activarFlag('pravda7_localizable');
        estado.anadirObjeto('fragmento_bitacora_pravda7_2');
        break;
      case 'overworld':
        estado.activarFlag('combate_archivador_resuelto');
        estado.activarFlag('hablo_con_ostrog');
        break;
    }
    return estado;
  }

  void _saltarAEscenario(String identificadorEscenario) {
    Navigator.of(context).pop(); // Cierra el modal del menú.
    final estado = _construirEstadoDebug(identificadorEscenario);
    Widget pantallaDestino;
    switch (identificadorEscenario) {
      case 'capsula':
        pantallaDestino = PantallaSala(estado: estado);
        break;
      case 'cantina':
        pantallaDestino = PantallaCantina(estado: estado);
        break;
      case 'reactor':
        pantallaDestino = PantallaReactor(estado: estado);
        break;
      case 'overworld':
        pantallaDestino = PantallaMapaOverworld(estado: estado);
        break;
      case 'cuadrante_sigma':
        pantallaDestino = PantallaCuadranteSigma(estado: estado);
        break;
      case 'zovnak4':
        pantallaDestino = PantallaPlanetaZovnak4(estado: estado);
        break;
      case 'gelida9':
        pantallaDestino = PantallaPlanetaGelida9(estado: estado);
        break;
      case 'sol_camarada':
        pantallaDestino = PantallaPlanetaSolCamarada(estado: estado);
        break;
      case 'pravda7':
        pantallaDestino = PantallaPlanetaPravda7(estado: estado);
        break;
      case 'dokumentris':
        pantallaDestino = PantallaDokumentris(estado: estado);
        break;
      case 'pinball':
        pantallaDestino = PantallaPinballComite(estado: estado);
        break;
      case 'frecuencia_747':
        pantallaDestino = PantallaFrecuencia747(estado: estado);
        break;
      case 'inspektor_pacman':
        pantallaDestino = PantallaInspektorPacman(estado: estado);
        break;
      case 'snow_kamarada':
        pantallaDestino = PantallaSnowKamarada(estado: estado);
        break;
      case 'camarada_invasors':
        pantallaDestino = PantallaCamaradaInvasors(estado: estado);
        break;
      case 'pixel_perdido':
        pantallaDestino = PantallaPixelPerdido(estado: estado);
        break;
      case 'boveda_suenos':
        pantallaDestino = PantallaBovedaSuenos(estado: estado);
        break;
      case 'cosmoom_doom':
        pantallaDestino = PantallaCosmoomDoom(estado: estado);
        break;
      case 'super_pang':
        pantallaDestino = PantallaSuperPangGalactico(estado: estado);
        break;
      default:
        return;
    }
    Navigator.of(context)
        .push(crearRutaConTransicion(pantallaDestino));
  }

  void _mostrarMenuDebug() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: PaletaCosmoSovietica.papelViejo,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            color: PaletaCosmoSovietica.tintaNegra,
            width: 3,
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ACCESO RÁPIDO · MENÚ DE DEBUG',
                  style: TipografiaPropaganda.etiquetaBurocratica,
                ),
                const SizedBox(height: 6),
                const Divider(
                  color: PaletaCosmoSovietica.rojoOficial,
                  thickness: 1.4,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Salta directamente a cualquier escenario con un Cadete de prueba. Las flags necesarias se activan en silencio.',
                  style: TipografiaPropaganda.subtitulo,
                ),
                const SizedBox(height: 14),
                const Text(
                  'PRAVDA-12 · INTERIOR',
                  style: TipografiaPropaganda.etiquetaBurocratica,
                ),
                const SizedBox(height: 6),
                _filaBotonesDebug([
                  _ItemMenuDebug('Cápsula', 'capsula'),
                  _ItemMenuDebug('Cantina', 'cantina'),
                  _ItemMenuDebug('Reactor', 'reactor'),
                ]),
                const SizedBox(height: 10),
                const Text(
                  'CUADRANTE SIGMA · EXTERIOR',
                  style: TipografiaPropaganda.etiquetaBurocratica,
                ),
                const SizedBox(height: 6),
                _filaBotonesDebug([
                  _ItemMenuDebug('Plano técnico', 'overworld'),
                  _ItemMenuDebug('Mapa estelar', 'cuadrante_sigma'),
                ]),
                const SizedBox(height: 6),
                _filaBotonesDebug([
                  _ItemMenuDebug('Zovnak-4', 'zovnak4'),
                  _ItemMenuDebug('Gélida-9', 'gelida9'),
                ]),
                const SizedBox(height: 6),
                _filaBotonesDebug([
                  _ItemMenuDebug('Sol Camarada', 'sol_camarada'),
                  _ItemMenuDebug('Pravda-7 (final)', 'pravda7'),
                ]),
                const SizedBox(height: 10),
                const Text(
                  'MINIJUEGOS · LUGARES OCULTOS',
                  style: TipografiaPropaganda.etiquetaBurocratica,
                ),
                const SizedBox(height: 6),
                _filaBotonesDebug([
                  _ItemMenuDebug('Dokumentris', 'dokumentris'),
                  _ItemMenuDebug('Pinball Π-7', 'pinball'),
                ]),
                const SizedBox(height: 6),
                _filaBotonesDebug([
                  _ItemMenuDebug('Frecuencia 7.47', 'frecuencia_747'),
                  _ItemMenuDebug('Inspektor', 'inspektor_pacman'),
                ]),
                const SizedBox(height: 6),
                _filaBotonesDebug([
                  _ItemMenuDebug('Snow Kamarada', 'snow_kamarada'),
                  _ItemMenuDebug('Invasors', 'camarada_invasors'),
                ]),
                const SizedBox(height: 6),
                _filaBotonesDebug([
                  _ItemMenuDebug('Píxel Perdido', 'pixel_perdido'),
                  _ItemMenuDebug('Bóveda Sueños', 'boveda_suenos'),
                ]),
                const SizedBox(height: 6),
                _filaBotonesDebug([
                  _ItemMenuDebug('Cosmoom Doom', 'cosmoom_doom'),
                  _ItemMenuDebug('Super Pang Galáctico', 'super_pang'),
                ]),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: BotonPropaganda(
                    texto: 'Cerrar',
                    compacto: true,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _filaBotonesDebug(List<_ItemMenuDebug> items) {
    return Row(
      children: [
        for (int indiceItem = 0; indiceItem < items.length; indiceItem++) ...[
          if (indiceItem > 0) const SizedBox(width: 6),
          Expanded(
            child: BotonPropaganda(
              texto: items[indiceItem].etiqueta,
              compacto: true,
              onPressed: () =>
                  _saltarAEscenario(items[indiceItem].identificador),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: controladorTembleque,
        builder: (contexto, hijoEstable) {
          final double valorTemblor = controladorTembleque.value;
          // Tembleque que decae: oscilación amortiguada que se apaga.
          final double amplitudPx =
              valorTemblor > 0 ? 14 * (1 - valorTemblor) : 0;
          final double desplazamientoX =
              math.sin(valorTemblor * math.pi * 8) * amplitudPx;
          final double desplazamientoY =
              math.cos(valorTemblor * math.pi * 6) * amplitudPx * 0.6;
          return Transform.translate(
            offset: Offset(desplazamientoX, desplazamientoY),
            child: hijoEstable,
          );
        },
        child: Stack(
        fit: StackFit.expand,
        children: [
          // PORTADA generada como fondo a pantalla completa.
          Image.asset(
            'assets/images/portada_principal.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          // Estrella roja con pulso lento (§10.10) en la esquina
          // superior derecha, como un latido sutil sobre la portada.
          // 4 frames a 500ms = ciclo de 2s.
          // Huevo de pascua: pulsarla 7 veces activa el Expediente Sin
          // Filtro. Por eso se vuelve interactiva (GestureDetector).
          // Huevo de pascua: la estrella roja pulsante encaja
          // visualmente DENTRO del sello "СОВ. СЕКРЕТНО" derecho de la
          // portada. Antes era 340×340 y desbordaba el sello,
          // perforándolo. Reducida a 90×90 y reposicionada para que
          // sustituya/refuerce la estrella pequeña ya dibujada en el
          // sello, sin tapar otras zonas legibles.
          Positioned(
            top: 96,
            right: 118,
            width: 90,
            height: 90,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _alPulsarEstrellaRoja,
              child: Opacity(
                opacity: 0.92,
                child: const CicloDeFrames(
                  rutasFrames: [
                    'assets/svg/estrella_pulso_f01.png',
                    'assets/svg/estrella_pulso_f02.png',
                    'assets/svg/estrella_pulso_f03.png',
                    'assets/svg/estrella_pulso_f04.png',
                  ],
                  duracionPorFrame: Duration(milliseconds: 500),
                ),
              ),
            ),
          ),
          // Degradado papel translúcido en la mitad inferior para que
          // los botones se lean sin tapar la ilustración.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 360,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.0),
                    PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.85),
                    PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          // Botones flotando en la parte inferior centrada.
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: controladorPalpitacion,
                      builder: (contexto, _) => CustomPaint(
                        size: const Size(380, 28),
                        painter: _PintorGuirnaldaBanderitas(
                          fase: controladorPalpitacion.value,
                        ),
                      ),
                    ),
                    // Marco de propaganda como adorno bajo la guirnalda,
                    // anclando visualmente la zona del CTA.
                    const SizedBox(
                      width: 380,
                      height: 24,
                      child: Image(
                        image: AssetImage('assets/svg/marco_propaganda.png'),
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tarjeta de papel detrás del texto narrativo: sin
                    // ella el texto cae sobre los contornos de la nave
                    // dibujada en la portada y queda ilegible (los
                    // trazos oscuros se cruzan con las letras).
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: PaletaCosmoSovietica.papelViejo
                              .withValues(alpha: 0.92),
                          border: Border.all(
                            color: PaletaCosmoSovietica.tintaNegra
                                .withValues(alpha: 0.45),
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          _expedienteSinFiltroActivo
                              ? 'EXPEDIENTE SIN FILTRO · El archivo no registrará esta partida. La estrella roja ha sido pulsada siete veces. El Comité finge no haberse enterado.'
                              : '1962. Cuadrante Sigma. La estación Pravda-7 desapareció el miércoles que el Camarada Directorskov apretó el botón equivocado. Llegas en la Pravda-12. El F-447 es obligatorio.',
                          textAlign: TextAlign.center,
                          style: _expedienteSinFiltroActivo
                              ? TipografiaPropaganda.subtitulo.copyWith(
                                  color: PaletaCosmoSovietica.rojoOficial,
                                  fontStyle: FontStyle.italic,
                                )
                              : TipografiaPropaganda.subtitulo,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    BotonPropaganda(
                      texto: 'Iniciar procedimiento',
                      destacado: true,
                      onPressed: _estaCargandoPartida
                          ? null
                          : () {
                              Navigator.of(context).push(
                                crearRutaConTransicion(
                                  const PantallaSeleccionClase(),
                                ),
                              );
                            },
                    ),
                    if (_hayPartidaGuardada) ...[
                      const SizedBox(height: 10),
                      BotonPropaganda(
                        texto: _estaCargandoPartida
                            ? 'Restaurando expediente…'
                            : 'Continuar expediente',
                        compacto: true,
                        onPressed: _estaCargandoPartida
                            ? null
                            : _intentarCargarPartida,
                      ),
                    ],
                    // En builds de release el botón sólo aparece si el
                    // jugador ha desbloqueado el huevo de pascua
                    // "Expediente Sin Filtro" (7 pulsaciones sobre la
                    // estrella roja). En debug es siempre visible para
                    // que el desarrollo no requiera repetir el ritual.
                    if (kDebugMode || _expedienteSinFiltroActivo) ...[
                      const SizedBox(height: 8),
                      BotonPropaganda(
                        texto: _expedienteSinFiltroActivo
                            ? '★ EXPEDIENTE SIN FILTRO ★'
                            : '⚙ ACCESO RÁPIDO (DEBUG)',
                        compacto: true,
                        destacado: _expedienteSinFiltroActivo,
                        onPressed: _mostrarMenuDebug,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      _expedienteSinFiltroActivo
                          ? '★ ARCHIVO TACHADO · PROTOTIPO LIBERADO ★'
                          : '★ APROBADO POR EL PARTIDO · PROTOTIPO ACTO 1 ★',
                      style: TipografiaPropaganda.etiquetaBurocratica.copyWith(
                        color: _expedienteSinFiltroActivo
                            ? PaletaCosmoSovietica.rojoOficial
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _ItemMenuDebug {
  final String etiqueta;
  final String identificador;
  const _ItemMenuDebug(this.etiqueta, this.identificador);
}

/// Sello rojo flotante mostrado cuando se activa el Expediente Sin Filtro
/// tras pulsar la estrella roja del título siete veces. Aparece centrado,
/// se estampa con rebote y se va. Es un huevo de pascua meta — no afecta
/// al estado persistente porque ocurre antes de crear un EstadoJuego.
class _SelloExpedienteSinFiltro extends StatefulWidget {
  final VoidCallback alTerminar;

  const _SelloExpedienteSinFiltro({required this.alTerminar});

  @override
  State<_SelloExpedienteSinFiltro> createState() =>
      _SelloExpedienteSinFiltroState();
}

class _SelloExpedienteSinFiltroState extends State<_SelloExpedienteSinFiltro>
    with SingleTickerProviderStateMixin {
  late final AnimationController controladorEstampado;

  @override
  void initState() {
    super.initState();
    controladorEstampado = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    controladorEstampado.forward();
    Future<void>.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) widget.alTerminar();
    });
  }

  @override
  void dispose() {
    controladorEstampado.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: AnimatedBuilder(
            animation: controladorEstampado,
            builder: (contexto, hijo) {
              final double fase = controladorEstampado.value;
              double escala;
              double opacidad;
              if (fase < 0.14) {
                final t = fase / 0.14;
                escala = 2.8 - t * 1.5;
                opacidad = t.clamp(0.0, 1.0);
              } else if (fase < 0.78) {
                final t = (fase - 0.14) / 0.64;
                escala = 1.3 + (1 - t) * 0.08;
                opacidad = 1.0;
              } else {
                final t = (fase - 0.78) / 0.22;
                escala = 1.3 - t * 0.10;
                opacidad = 1.0 - t;
              }
              final double anguloVibracion =
                  fase < 0.30 ? (0.22 - fase * 0.6) : -0.06;
              return Opacity(
                opacity: opacidad.clamp(0.0, 1.0),
                child: Transform.rotate(
                  angle: anguloVibracion,
                  child: Transform.scale(scale: escala, child: hijo),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                  color: PaletaCosmoSovietica.rojoOficial,
                  width: 5,
                ),
                color: PaletaCosmoSovietica.papelViejo
                    .withValues(alpha: 0.92),
                boxShadow: const [
                  BoxShadow(
                    color: PaletaCosmoSovietica.tintaNegra,
                    offset: Offset(6, 6),
                  ),
                ],
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '★ EXPEDIENTE SIN FILTRO ★',
                    style: TextStyle(
                      fontFamily: 'CosmoSerif',
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      color: PaletaCosmoSovietica.rojoOficial,
                      letterSpacing: 3,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'La estrella ha sido pulsada siete veces.',
                    style: TextStyle(
                      fontFamily: 'CosmoSerif',
                      fontSize: 14,
                      color: PaletaCosmoSovietica.tintaNegra,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


/// Guirnalda decorativa de banderitas triangulares rojas y blancas, atadas
/// a un hilo curvo. Cada banderita oscila ligeramente con desfase propio,
/// como movida por la corriente de aire del sistema de ventilación.
class _PintorGuirnaldaBanderitas extends CustomPainter {
  final double fase;
  _PintorGuirnaldaBanderitas({required this.fase});

  @override
  void paint(Canvas canvas, Size size) {
    final pincelCuerda = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final puntoIzq = Offset(size.width * 0.05, size.height * 0.18);
    final puntoDer = Offset(size.width * 0.95, size.height * 0.18);
    final puntoControlCuerda =
        Offset(size.width * 0.5, size.height * 0.55);
    final caminoCuerda = Path()
      ..moveTo(puntoIzq.dx, puntoIzq.dy)
      ..quadraticBezierTo(puntoControlCuerda.dx, puntoControlCuerda.dy,
          puntoDer.dx, puntoDer.dy);
    canvas.drawPath(caminoCuerda, pincelCuerda);

    const cantidadBanderitas = 11;
    for (int indiceBanderita = 0;
        indiceBanderita < cantidadBanderitas;
        indiceBanderita++) {
      final fragmentoCurva =
          (indiceBanderita + 1) / (cantidadBanderitas + 1);
      final centroBanderita = _evaluarCurvaQuadratica(
          puntoIzq, puntoControlCuerda, puntoDer, fragmentoCurva);
      final desfaseOndulacion = indiceBanderita * 0.6;
      final amplitudOndulacion =
          math.sin(fase * math.pi * 2 + desfaseOndulacion) * 1.5;
      final esRoja = indiceBanderita % 2 == 0;
      final colorBanderita = esRoja
          ? PaletaCosmoSovietica.rojoOficial
          : PaletaCosmoSovietica.papelViejo;
      final pincelBanderita = Paint()
        ..color = colorBanderita
        ..style = PaintingStyle.fill;
      final altoBanderita = size.height * 0.55;
      final anchoBanderita = size.width * 0.045;
      final caminoBanderita = Path()
        ..moveTo(centroBanderita.dx - anchoBanderita / 2,
            centroBanderita.dy + 1)
        ..lineTo(centroBanderita.dx + anchoBanderita / 2,
            centroBanderita.dy + 1)
        ..lineTo(centroBanderita.dx + amplitudOndulacion,
            centroBanderita.dy + altoBanderita)
        ..close();
      canvas.drawPath(caminoBanderita, pincelBanderita);
      canvas.drawPath(
        caminoBanderita,
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke,
      );
    }
  }

  Offset _evaluarCurvaQuadratica(
      Offset puntoInicio, Offset puntoControl, Offset puntoFin, double t) {
    final fragmentoComplementario = 1.0 - t;
    return Offset(
      fragmentoComplementario * fragmentoComplementario * puntoInicio.dx +
          2 * fragmentoComplementario * t * puntoControl.dx +
          t * t * puntoFin.dx,
      fragmentoComplementario * fragmentoComplementario * puntoInicio.dy +
          2 * fragmentoComplementario * t * puntoControl.dy +
          t * t * puntoFin.dy,
    );
  }

  @override
  bool shouldRepaint(covariant _PintorGuirnaldaBanderitas viejo) =>
      viejo.fase != fase;
}
