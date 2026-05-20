import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../painters/overworld_map_painter.dart';
import '../theme.dart';
import '../utilities/page_transitions.dart';
import '../utilities/persistencia_partida.dart';
import '../widgets/boton_mute_audio.dart';
import '../widgets/diario_misiones.dart';
import '../widgets/dialogo_guardar_partida.dart';
import '../widgets/inventory_dialog.dart';
import '../widgets/paper_background.dart';
import '../widgets/propaganda_button.dart';
import 'canteen_screen.dart';
import 'cuadrante_sigma_screen.dart';
import 'reactor_screen.dart';
import 'room_screen.dart';

class PantallaMapaOverworld extends StatefulWidget {
  final EstadoJuego estado;
  final String? moduloDestacado;

  const PantallaMapaOverworld({
    super.key,
    required this.estado,
    this.moduloDestacado,
  });

  @override
  State<PantallaMapaOverworld> createState() => _PantallaMapaOverworldState();
}

class _PantallaMapaOverworldState extends State<PantallaMapaOverworld>
    with SingleTickerProviderStateMixin {
  late AnimationController controladorFase;
  String? _moduloHover;

  @override
  void initState() {
    super.initState();
    controladorFase = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      persistenciaPartida.autoguardarPartida(widget.estado);
    });
  }

  @override
  void dispose() {
    controladorFase.dispose();
    super.dispose();
  }

  Set<String> _calcularAccesibles() {
    final identificadoresAccesibles = <String>{'capsula'};
    if (widget.estado.tieneFlag('combate_archivador_resuelto')) {
      identificadoresAccesibles.add('cantina');
    }
    if (widget.estado.tieneFlag('hablo_con_ostrog')) {
      identificadoresAccesibles.add('reactor');
    }
    return identificadoresAccesibles;
  }

  bool _puedeSalirAlCosmos() =>
      widget.estado.tieneFlag('hablo_con_ostrog');

  void _visitarModulo(String identificador) {
    if (!_calcularAccesibles().contains(identificador)) return;
    Widget pantallaDestino;
    switch (identificador) {
      case 'capsula':
        pantallaDestino = PantallaSala(estado: widget.estado);
        break;
      case 'cantina':
        pantallaDestino = PantallaCantina(estado: widget.estado);
        break;
      case 'reactor':
        pantallaDestino = PantallaReactor(estado: widget.estado);
        break;
      default:
        return;
    }
    Navigator.of(context).pushReplacement(
      crearRutaConTransicion(pantallaDestino),
    );
  }

  void _salirAlCosmos() {
    if (!_puedeSalirAlCosmos()) return;
    Navigator.of(context).pushReplacement(
      crearRutaConTransicion(
        PantallaCuadranteSigma(
          estado: widget.estado,
          planetaDestacado:
              widget.estado.tieneFlag('pista_pravda7_inicial')
                  ? 'pravda7'
                  : 'zovnak4',
        ),
      ),
    );
  }

  Future<void> _abrirInventario() async {
    await mostrarDialogoInventario(context, estado: widget.estado);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _abrirDiario() async {
    await mostrarDiarioMisiones(context, estado: widget.estado);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _abrirDialogoGuardado() async {
    await mostrarDialogoGuardarPartida(
      context,
      estadoActual: widget.estado,
    );
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final modulosAccesibles = _calcularAccesibles();
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
                      'PLANO INTERIOR · NAVE PRAVDA-12',
                      style: TipografiaPropaganda.tituloSeccion,
                    ),
                    Row(
                      children: [
                        _construirChipInfo(
                          'NIVEL ${widget.estado.nivelCadete}',
                        ),
                        const SizedBox(width: 8),
                        _construirChipInfo(
                          'XP ${widget.estado.experienciaAcumulada}/${widget.estado.xpParaSiguienteNivel}',
                        ),
                        const SizedBox(width: 8),
                        _construirChipInfo(
                          'CUOTA ${widget.estado.cuotaBurocratica >= 0 ? '+' : ''}${widget.estado.cuotaBurocratica}',
                          rojo: true,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.moduloDestacado != null
                      ? 'Próximo trámite recomendado: ${_etiquetaDe(widget.moduloDestacado!)}'
                      : 'Seleccione módulo de destino.',
                  style: TipografiaPropaganda.subtitulo,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                          flex: 3, child: _construirPlano(modulosAccesibles)),
                      const SizedBox(width: 16),
                      Expanded(
                          flex: 2,
                          child: _construirPanelLateral(modulosAccesibles)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    BotonPropaganda(
                      texto: 'Diario',
                      compacto: true,
                      onPressed: _abrirDiario,
                    ),
                    const SizedBox(width: 8),
                    BotonPropaganda(
                      texto: 'Inventario',
                      compacto: true,
                      onPressed: _abrirInventario,
                    ),
                    const SizedBox(width: 8),
                    BotonPropaganda(
                      texto: 'Guardar',
                      compacto: true,
                      onPressed: _abrirDialogoGuardado,
                    ),
                    const SizedBox(width: 8),
                    const BotonMuteAudio(),
                    const SizedBox(width: 8),
                    if (_puedeSalirAlCosmos())
                      BotonPropaganda(
                        texto: 'Salir al Cuadrante Sigma',
                        compacto: true,
                        destacado: true,
                        onPressed: _salirAlCosmos,
                      ),
                    const SizedBox(width: 8),
                    BotonPropaganda(
                      texto: 'Salir del prototipo',
                      compacto: true,
                      onPressed: () =>
                          Navigator.of(context).popUntil((r) => r.isFirst),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirChipInfo(String texto, {bool rojo = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: PaletaCosmoSovietica.papelViejo,
        border: Border.all(
          color: rojo
              ? PaletaCosmoSovietica.rojoOficial
              : PaletaCosmoSovietica.tintaNegra,
          width: 1.5,
        ),
      ),
      child: Text(
        texto,
        style: TipografiaPropaganda.etiquetaBurocratica.copyWith(
          color: rojo
              ? PaletaCosmoSovietica.rojoOficial
              : PaletaCosmoSovietica.tintaNegra,
        ),
      ),
    );
  }

  Widget _construirPlano(Set<String> modulosAccesibles) {
    return AnimatedBuilder(
      animation: controladorFase,
      builder: (contextoAnim, _) => LayoutBuilder(
        builder: (contextoLayout, restricciones) {
          final anchoTotal = restricciones.maxWidth;
          final altoTotal = restricciones.maxHeight;
          return Stack(
            children: [
              // Fondo PNG del plano interior de la Pravda-12 (§22 del
              // briefing). El painter procedimental queda como capa
              // SUPERIOR para las animaciones (módulos pulsantes, ruta
              // marcada, indicador de ubicación) — el PNG aporta la
              // arquitectura, pasillos, tuberías exteriores y sellos.
              const Positioned.fill(
                child: Image(
                  image: AssetImage(
                      'assets/images/fondo_pravda12_interior.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.high,
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: PintorMapaOverworld(
                    fase: controladorFase.value,
                    modulosAccesibles: modulosAccesibles,
                    moduloDestacado: widget.moduloDestacado,
                    moduloUbicacionActual:
                        widget.estado.ultimoModuloVisitado,
                  ),
                ),
              ),
              for (final modulo in modulosPravda12)
                Positioned(
                  left: modulo.posicionRelativa.dx * anchoTotal -
                      modulo.tamano.width * anchoTotal / 2,
                  top: modulo.posicionRelativa.dy * altoTotal -
                      modulo.tamano.height * altoTotal / 2,
                  width: modulo.tamano.width * anchoTotal,
                  height: modulo.tamano.height * altoTotal,
                  child: MouseRegion(
                    cursor:
                        modulosAccesibles.contains(modulo.identificador)
                            ? SystemMouseCursors.click
                            : SystemMouseCursors.forbidden,
                    onEnter: (_) =>
                        setState(() => _moduloHover = modulo.identificador),
                    onExit: (_) {
                      if (_moduloHover == modulo.identificador) {
                        setState(() => _moduloHover = null);
                      }
                    },
                    child: GestureDetector(
                      onTap: () => _visitarModulo(modulo.identificador),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _construirPanelLateral(Set<String> modulosAccesibles) {
    final identificadorActivo = _moduloHover ?? widget.moduloDestacado;
    final moduloActivo = identificadorActivo != null
        ? modulosPravda12.firstWhere(
            (m) => m.identificador == identificadorActivo,
            orElse: () => modulosPravda12.first,
          )
        : null;
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
          const Text('MÓDULOS DE LA ESTACIÓN',
              style: TipografiaPropaganda.etiquetaBurocratica),
          const SizedBox(height: 8),
          const Divider(color: PaletaCosmoSovietica.tintaNegra, height: 1),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final modulo in modulosPravda12)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 4, right: 6),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: modulosAccesibles
                                      .contains(modulo.identificador)
                                  ? PaletaCosmoSovietica.rojoOficial
                                  : PaletaCosmoSovietica.tintaTenue,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        modulo.etiqueta,
                                        style: TipografiaPropaganda
                                                .etiquetaBurocratica
                                            .copyWith(
                                          color: modulosAccesibles.contains(
                                                  modulo.identificador)
                                              ? PaletaCosmoSovietica
                                                  .tintaNegra
                                              : PaletaCosmoSovietica
                                                  .tintaTenue,
                                        ),
                                      ),
                                    ),
                                    if (widget.estado.ultimoModuloVisitado ==
                                        modulo.identificador)
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 4,
                                                vertical: 1),
                                        color: PaletaCosmoSovietica
                                            .rojoOficial,
                                        child: const Text(
                                          'AQUÍ',
                                          style: TextStyle(
                                            fontFamily: TipografiaPropaganda
                                                .familiaMonoespaciada,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            color: PaletaCosmoSovietica
                                                .papelViejo,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                if (modulo.subtitulo != null)
                                  Text(
                                    modulo.subtitulo!,
                                    style: TipografiaPropaganda.subtitulo
                                        .copyWith(fontSize: 11),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (moduloActivo != null) ...[
            const Divider(color: PaletaCosmoSovietica.tintaNegra, height: 1),
            const SizedBox(height: 6),
            Text(
              'SELECCIÓN: ${moduloActivo.etiqueta}',
              style: TipografiaPropaganda.etiquetaBurocratica.copyWith(
                color: PaletaCosmoSovietica.rojoOficial,
              ),
            ),
            const SizedBox(height: 4),
            if (moduloActivo.subtitulo != null)
              Text(
                moduloActivo.subtitulo!,
                style: TipografiaPropaganda.cuerpoLargo.copyWith(fontSize: 12),
              ),
          ],
        ],
      ),
    );
  }

  String _etiquetaDe(String identificador) {
    return modulosPravda12
        .firstWhere(
          (m) => m.identificador == identificador,
          orElse: () => modulosPravda12.first,
        )
        .etiqueta;
  }
}
