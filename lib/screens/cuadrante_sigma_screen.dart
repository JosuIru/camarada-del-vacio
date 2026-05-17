import 'package:flutter/material.dart';
import '../data/cuadrante_sigma.dart';
import '../models/game_state.dart';
import '../painters/cuadrante_sigma_painter.dart';
import '../theme.dart';
import '../utilities/page_transitions.dart';
import '../utilities/persistencia_partida.dart';
import '../widgets/boton_mute_audio.dart';
import '../widgets/diario_misiones.dart';
import '../widgets/dialogo_guardar_partida.dart';
import '../widgets/inventory_dialog.dart';
import '../widgets/propaganda_button.dart';
import 'overworld_map_screen.dart';
import '../minijuegos/pantalla_pinball_comite.dart';
import '../minijuegos/pantalla_transformacion.dart';
import 'planeta_gelida9_screen.dart';
import 'planeta_pravda7_screen.dart';
import 'planeta_sol_camarada_screen.dart';
import 'planeta_zovnak4_screen.dart';

class PantallaCuadranteSigma extends StatefulWidget {
  final EstadoJuego estado;
  final String? planetaDestacado;

  const PantallaCuadranteSigma({
    super.key,
    required this.estado,
    this.planetaDestacado,
  });

  @override
  State<PantallaCuadranteSigma> createState() =>
      _PantallaCuadranteSigmaState();
}

class _PantallaCuadranteSigmaState extends State<PantallaCuadranteSigma>
    with SingleTickerProviderStateMixin {
  late AnimationController controladorFase;
  String? _planetaHover;

  @override
  void initState() {
    super.initState();
    controladorFase = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
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

  Set<String> _calcularPlanetasAccesibles() {
    final identificadoresAccesibles = <String>{'pravda12'};
    if (widget.estado.tieneFlag('hablo_con_ostrog')) {
      identificadoresAccesibles.add('zovnak4');
    }
    if (widget.estado.tieneFlag('pista_pravda7_inicial')) {
      identificadoresAccesibles.add('gelida9');
    }
    if (widget.estado.tieneFlag('rumor_pravda7_fragmento2')) {
      identificadoresAccesibles.add('sol_camarada');
    }
    if (widget.estado.tieneFlag('pravda7_localizable')) {
      identificadoresAccesibles.add('pravda7');
    }
    // El planeta-bola Pi-7 solo aparece tras sintonizar la frecuencia
    // oculta 7.47 MHz: la radio mismo revela las coordenadas.
    if (widget.estado.tieneFlag('radio_kamarada')) {
      identificadoresAccesibles.add('pi7');
    }
    return identificadoresAccesibles;
  }

  String _planetaUbicacionActual() {
    final ultimoModulo = widget.estado.ultimoModuloVisitado;
    final planetasIds = {
      for (final planeta in planetasCuadranteSigma) planeta.identificador,
    };
    if (planetasIds.contains(ultimoModulo)) return ultimoModulo;
    return 'pravda12';
  }

  void _viajarA(String identificador) {
    if (!_calcularPlanetasAccesibles().contains(identificador)) return;
    final planeta = planetasCuadranteSigma.firstWhere(
      (p) => p.identificador == identificador,
      orElse: () => planetasCuadranteSigma.first,
    );
    if (!planeta.implementado && identificador != 'pravda12') {
      _mostrarPlanetaEnObras(planeta);
      return;
    }
    Widget pantallaDestino;
    switch (identificador) {
      case 'pravda12':
        pantallaDestino = PantallaMapaOverworld(
          estado: widget.estado,
          moduloDestacado: 'capsula',
        );
        break;
      case 'zovnak4':
        pantallaDestino = PantallaPlanetaZovnak4(estado: widget.estado);
        break;
      case 'gelida9':
        pantallaDestino = PantallaPlanetaGelida9(estado: widget.estado);
        break;
      case 'sol_camarada':
        pantallaDestino = PantallaPlanetaSolCamarada(estado: widget.estado);
        break;
      case 'pravda7':
        pantallaDestino = PantallaPlanetaPravda7(estado: widget.estado);
        break;
      case 'pi7':
        _aterrizarEnPlanetaBola();
        return;
      default:
        return;
    }
    Navigator.of(context).pushReplacement(
      crearRutaConTransicion(pantallaDestino),
    );
  }

  /// Aterrizaje en el planeta-bola Pi-7: el cadete pierde su forma
  /// humana y rueda como bola por los corredores del Comite Central.
  void _aterrizarEnPlanetaBola() {
    Navigator.of(context).push(
      crearRutaConTransicion(
        PantallaTransformacion(
          formaDestino: FormaProtagonista.bolaPinball,
          nombreLugar: 'Π-7 · PLANETA-BOLA',
          fraseTransformacion:
              'La gravedad del Comité es plana y pulida. Te conviertes en bola: rueda hasta despertarlos a todos.',
          alTerminar: () {
            Navigator.of(context).pushReplacement(
              crearRutaConTransicion(
                PantallaPinballComite(estado: widget.estado),
              ),
            );
          },
        ),
      ),
    );
  }

  void _mostrarPlanetaEnObras(ConfiguracionPlanetaCosmos planeta) {
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
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXPEDIENTE EN OBRAS · ${planeta.etiqueta}',
                  style: TipografiaPropaganda.etiquetaBurocratica.copyWith(
                    color: PaletaCosmoSovietica.rojoOficial,
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(
                  color: PaletaCosmoSovietica.rojoOficial,
                  thickness: 1.4,
                ),
                const SizedBox(height: 12),
                Text(
                  planeta.subtitulo,
                  style: TipografiaPropaganda.bocadilloDialogo,
                ),
                const SizedBox(height: 12),
                const Text(
                  'El Comité de Expansión Cósmica todavía no ha aprobado este expediente. Próximamente: capítulo dedicado.',
                  style: TipografiaPropaganda.cuerpoLargo,
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: BotonPropaganda(
                    texto: 'Volver al mapa',
                    destacado: true,
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
    final accesibles = _calcularPlanetasAccesibles();
    final ubicacionActual = _planetaUbicacionActual();
    final identificadorEnfoque =
        _planetaHover ?? widget.planetaDestacado;
    final planetaEnfoque = identificadorEnfoque != null
        ? planetasCuadranteSigma.firstWhere(
            (planeta) => planeta.identificador == identificadorEnfoque,
            orElse: () => planetasCuadranteSigma.first,
          )
        : null;

    return Scaffold(
      backgroundColor: PaletaCosmoSovietica.tintaNegra,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'CUADRANTE SIGMA · MAPA OFICIAL',
                    style: TextStyle(
                      fontFamily: 'CosmoSerif',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: PaletaCosmoSovietica.papelViejo,
                      letterSpacing: 2,
                    ),
                  ),
                  Row(
                    children: [
                      _chipInfo(
                          'NIVEL ${widget.estado.nivelCadete}', false),
                      const SizedBox(width: 6),
                      _chipInfo(
                          'XP ${widget.estado.experienciaAcumulada}/${widget.estado.xpParaSiguienteNivel}',
                          false),
                      const SizedBox(width: 6),
                      _chipInfo(
                          'CUOTA ${widget.estado.cuotaBurocratica >= 0 ? '+' : ''}${widget.estado.cuotaBurocratica}',
                          true),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.planetaDestacado != null
                    ? 'Recomendación: ${_etiquetaDe(widget.planetaDestacado!)}'
                    : 'Seleccione planeta de destino. Solo planetas con ruta sólida son accesibles.',
                style: TextStyle(
                  fontFamily: 'CosmoSerif',
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: PaletaCosmoSovietica.tintaTenue.withValues(alpha: 0.7),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: _construirMapaInteractivo(
                          accesibles, ubicacionActual),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _construirPanelPlaneta(
                          planetaEnfoque, accesibles, ubicacionActual),
                    ),
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
                  BotonPropaganda(
                    texto: 'Volver a la Pravda-12',
                    compacto: true,
                    destacado: true,
                    onPressed: () => _viajarA('pravda12'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chipInfo(String texto, bool rojo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: PaletaCosmoSovietica.tintaNegra,
        border: Border.all(
          color: rojo
              ? PaletaCosmoSovietica.rojoOficial
              : PaletaCosmoSovietica.papelViejo,
          width: 1.5,
        ),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontFamily: 'CosmoMono',
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: rojo
              ? PaletaCosmoSovietica.rojoOficial
              : PaletaCosmoSovietica.papelViejo,
          letterSpacing: 1.6,
        ),
      ),
    );
  }

  Widget _construirMapaInteractivo(
      Set<String> accesibles, String ubicacionActual) {
    return AnimatedBuilder(
      animation: controladorFase,
      builder: (contextoAnim, _) => LayoutBuilder(
        builder: (contextoLayout, restricciones) {
          final anchoTotal = restricciones.maxWidth;
          final altoTotal = restricciones.maxHeight;
          return Stack(
            children: [
              // Fondo PNG del cosmos (estrellas, gradiente espacio).
              // El painter procedimental queda encima para las órbitas
              // animadas, los cometas, las rutas y los planetas
              // interactivos.
              const Positioned.fill(
                child: Image(
                  image: AssetImage(
                      'assets/images/fondo_cuadrante_sigma.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.high,
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: PintorCuadranteSigma(
                    fase: controladorFase.value,
                    planetasAccesibles: accesibles,
                    planetaDestacado: widget.planetaDestacado,
                    planetaUbicacionActual: ubicacionActual,
                  ),
                ),
              ),
              for (final planeta in planetasCuadranteSigma)
                Positioned(
                  left: planeta.posicionRelativa.dx * anchoTotal -
                      planeta.radioRelativo * anchoTotal,
                  top: planeta.posicionRelativa.dy * altoTotal -
                      planeta.radioRelativo * anchoTotal,
                  width: planeta.radioRelativo * anchoTotal * 2,
                  height: planeta.radioRelativo * anchoTotal * 2,
                  child: MouseRegion(
                    cursor: accesibles.contains(planeta.identificador)
                        ? SystemMouseCursors.click
                        : SystemMouseCursors.forbidden,
                    onEnter: (_) => setState(
                        () => _planetaHover = planeta.identificador),
                    onExit: (_) {
                      if (_planetaHover == planeta.identificador) {
                        setState(() => _planetaHover = null);
                      }
                    },
                    child: GestureDetector(
                      onTap: () => _viajarA(planeta.identificador),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _construirPanelPlaneta(
    ConfiguracionPlanetaCosmos? planetaEnfoque,
    Set<String> accesibles,
    String ubicacionActual,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PaletaCosmoSovietica.tintaNegra,
        border: Border.all(
          color: PaletaCosmoSovietica.rojoOficial,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'EXPEDIENTE DEL PLANETA',
            style: TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: PaletaCosmoSovietica.rojoOficial,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: PaletaCosmoSovietica.rojoOficial),
          const SizedBox(height: 8),
          if (planetaEnfoque == null) ...[
            Text(
              'Pase el cursor sobre un planeta para revisar su expediente.',
              style: TextStyle(
                fontFamily: 'CosmoSerif',
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: PaletaCosmoSovietica.tintaTenue.withValues(alpha: 0.7),
              ),
            ),
          ] else ...[
            Text(
              planetaEnfoque.etiqueta,
              style: const TextStyle(
                fontFamily: 'CosmoSerif',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: PaletaCosmoSovietica.papelViejo,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              planetaEnfoque.subtitulo,
              style: TextStyle(
                fontFamily: 'CosmoSerif',
                fontSize: 13,
                color: PaletaCosmoSovietica.tintaTenue.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 10),
            _filaInfoCosmos(
              'ACCESIBLE',
              accesibles.contains(planetaEnfoque.identificador)
                  ? 'SÍ'
                  : 'NO',
              acentuado:
                  accesibles.contains(planetaEnfoque.identificador),
            ),
            _filaInfoCosmos(
              'ESTADO',
              planetaEnfoque.implementado ? 'OPERATIVO' : 'EN OBRAS',
              acentuado: planetaEnfoque.implementado,
            ),
            if (ubicacionActual == planetaEnfoque.identificador)
              _filaInfoCosmos('UBICACIÓN', 'USTED ESTÁ AQUÍ',
                  acentuado: true),
            const SizedBox(height: 12),
            if (accesibles.contains(planetaEnfoque.identificador) &&
                planetaEnfoque.identificador != ubicacionActual)
              BotonPropaganda(
                texto: 'Viajar al planeta',
                destacado: true,
                compacto: true,
                onPressed: () => _viajarA(planetaEnfoque.identificador),
              ),
          ],
        ],
      ),
    );
  }

  Widget _filaInfoCosmos(String etiqueta, String valor,
      {bool acentuado = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              etiqueta,
              style: TextStyle(
                fontFamily: 'CosmoMono',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: PaletaCosmoSovietica.tintaTenue.withValues(alpha: 0.7),
                letterSpacing: 1.4,
              ),
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontFamily: 'CosmoMono',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: acentuado
                  ? PaletaCosmoSovietica.rojoOficial
                  : PaletaCosmoSovietica.papelViejo,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _etiquetaDe(String identificador) {
    return planetasCuadranteSigma
        .firstWhere(
          (planeta) => planeta.identificador == identificador,
          orElse: () => planetasCuadranteSigma.first,
        )
        .etiqueta;
  }
}
