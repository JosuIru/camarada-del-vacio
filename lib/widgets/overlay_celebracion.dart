import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/game_class.dart';
import '../theme.dart';
import 'animacion_cadete_combate.dart';

/// Overlay de celebración: el cadete cosmonauta baila (brazos en V,
/// saltitos), un texto enorme en serif italic rojo "¡MISIÓN CUMPLIDA!"
/// (configurable) y una lluvia de confeti rojo cayendo. Se invoca con
/// [mostrarCelebracion] para que sea fire-and-forget desde cualquier
/// pantalla.
class OverlayCelebracion extends StatefulWidget {
  final String texto;
  final String? subtitulo;
  /// Clase del cadete — se conserva en la API pública porque varios
  /// callers ya la pasan, pero la animación PNG (`cadete_celebra_f0X`)
  /// es la misma para las tres clases, así que internamente no se usa.
  // ignore: unused_element_parameter
  final ClaseCosmonauta? clase;
  final Duration duracion;
  final VoidCallback onTerminado;
  /// Ruta de un PNG estático que reemplaza la animación del cadete
  /// celebrando. Útil para celebraciones cuyo protagonista no es el
  /// cadete (ej. adopción de Laika → `laika_ladrando.png`).
  final String? rutaImagenPersonalizada;

  const OverlayCelebracion({
    super.key,
    required this.texto,
    required this.onTerminado,
    this.subtitulo,
    this.clase,
    this.duracion = const Duration(milliseconds: 2400),
    this.rutaImagenPersonalizada,
  });

  @override
  State<OverlayCelebracion> createState() => _OverlayCelebracionState();
}

class _OverlayCelebracionState extends State<OverlayCelebracion>
    with TickerProviderStateMixin {
  late final AnimationController controladorEntrada;
  late final AnimationController controladorConfeti;
  late final List<_PiezaConfeti> piezasConfeti;
  final math.Random _rngConfeti = math.Random(7);

  @override
  void initState() {
    super.initState();
    controladorEntrada = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..forward();
    controladorConfeti = AnimationController(
      vsync: this,
      duration: widget.duracion,
    )..forward();
    piezasConfeti = List<_PiezaConfeti>.generate(
      32,
      (indicePieza) => _PiezaConfeti(
        xRelativo: _rngConfeti.nextDouble(),
        yInicial: -_rngConfeti.nextDouble() * 0.4 - 0.05,
        rotacionInicial: _rngConfeti.nextDouble() * math.pi * 2,
        velocidadRotacion:
            (_rngConfeti.nextDouble() - 0.5) * 8,
        velocidadCaida: 0.6 + _rngConfeti.nextDouble() * 0.8,
        anchoRelativo: 0.012 + _rngConfeti.nextDouble() * 0.014,
        derivaHorizontal:
            (_rngConfeti.nextDouble() - 0.5) * 0.35,
        esRojo: _rngConfeti.nextDouble() < 0.65,
      ),
    );
    Future.delayed(widget.duracion + const Duration(milliseconds: 220), () {
      if (!mounted) return;
      widget.onTerminado();
    });
  }

  @override
  void dispose() {
    controladorEntrada.dispose();
    controladorConfeti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        controladorEntrada,
        controladorConfeti,
      ]),
      builder: (contexto, _) {
        final double progresoEntrada =
            Curves.easeOutBack.transform(controladorEntrada.value);
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Velo de papel translúcido animando la entrada.
              Positioned.fill(
                child: Container(
                  color: PaletaCosmoSovietica.papelViejo
                      .withValues(alpha: controladorEntrada.value * 0.78),
                ),
              ),
              // Confeti cayendo.
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _PintorConfeti(
                      piezas: piezasConfeti,
                      tiempoNormalizado: controladorConfeti.value,
                    ),
                  ),
                ),
              ),
              Center(
                child: Opacity(
                  opacity: controladorEntrada.value,
                  child: Transform.scale(
                    scale: 0.5 + progresoEntrada * 0.5,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Protagonista de la celebración. Por defecto
                        // el cadete bailando (`cadete_celebra_f01..f03`),
                        // pero si se pasa `rutaImagenPersonalizada` se
                        // muestra ese PNG (ej. Laika ladrando al ser
                        // adoptada).
                        SizedBox(
                          width: 180,
                          height: 220,
                          child: widget.rutaImagenPersonalizada != null
                              ? Image.asset(
                                  widget.rutaImagenPersonalizada!,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                )
                              : const AnimacionCadeteCombate(
                                  tipo: TipoAnimacionCadete.celebra,
                                  duracionPorFrame:
                                      Duration(milliseconds: 200),
                                ),
                        ),
                        const SizedBox(height: 18),
                        // Texto principal.
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 14),
                          decoration: BoxDecoration(
                            color: PaletaCosmoSovietica.papelSombra
                                .withValues(alpha: 0.92),
                            border: Border.all(
                              color: PaletaCosmoSovietica.rojoOficial,
                              width: 3.4,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: PaletaCosmoSovietica.tintaNegra,
                                offset: Offset(4, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.texto,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'CosmoSerif',
                                  fontSize: 36,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w900,
                                  color: PaletaCosmoSovietica.rojoOficial,
                                  letterSpacing: 3,
                                  height: 1.1,
                                ),
                              ),
                              if (widget.subtitulo != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  width: 180,
                                  height: 1.4,
                                  color: PaletaCosmoSovietica.tintaNegra,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.subtitulo!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'CosmoSerif',
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: PaletaCosmoSovietica.tintaNegra,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PiezaConfeti {
  final double xRelativo;
  final double yInicial;
  final double rotacionInicial;
  final double velocidadRotacion;
  final double velocidadCaida;
  final double anchoRelativo;
  final double derivaHorizontal;
  final bool esRojo;

  const _PiezaConfeti({
    required this.xRelativo,
    required this.yInicial,
    required this.rotacionInicial,
    required this.velocidadRotacion,
    required this.velocidadCaida,
    required this.anchoRelativo,
    required this.derivaHorizontal,
    required this.esRojo,
  });
}

class _PintorConfeti extends CustomPainter {
  final List<_PiezaConfeti> piezas;
  /// Tiempo normalizado 0..1 a lo largo de la celebración.
  final double tiempoNormalizado;

  _PintorConfeti({required this.piezas, required this.tiempoNormalizado});

  @override
  void paint(Canvas canvas, Size size) {
    for (final pieza in piezas) {
      final double yProgreso =
          pieza.yInicial + tiempoNormalizado * pieza.velocidadCaida * 1.4;
      if (yProgreso < -0.1 || yProgreso > 1.15) continue;
      final double yPx = yProgreso * size.height;
      // Pequeña oscilación horizontal mientras cae (efecto papel).
      final double xPx = (pieza.xRelativo +
              math.sin(tiempoNormalizado * 6 + pieza.rotacionInicial) *
                  pieza.derivaHorizontal *
                  0.08) *
          size.width;
      final double anchoPx = pieza.anchoRelativo * size.width;
      final double altoPx = anchoPx * 0.55;
      final double rotacion = pieza.rotacionInicial +
          pieza.velocidadRotacion * tiempoNormalizado;
      canvas.save();
      canvas.translate(xPx, yPx);
      canvas.rotate(rotacion);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: anchoPx,
          height: altoPx,
        ),
        Paint()
          ..color = pieza.esRojo
              ? PaletaCosmoSovietica.rojoOficial
              : PaletaCosmoSovietica.tintaNegra,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PintorConfeti viejo) =>
      viejo.tiempoNormalizado != tiempoNormalizado;
}

/// Helper fire-and-forget para mostrar la celebración desde cualquier
/// pantalla. Encola el overlay y lo retira automáticamente cuando la
/// animación termina.
Future<void> mostrarCelebracion(
  BuildContext context, {
  required String texto,
  String? subtitulo,
  ClaseCosmonauta? clase,
  Duration duracion = const Duration(milliseconds: 2400),
  String? rutaImagenPersonalizada,
}) async {
  final overlayState = Overlay.maybeOf(context, rootOverlay: true);
  if (overlayState == null) return;
  late final OverlayEntry entrada;
  entrada = OverlayEntry(
    builder: (_) => OverlayCelebracion(
      texto: texto,
      subtitulo: subtitulo,
      clase: clase,
      duracion: duracion,
      rutaImagenPersonalizada: rutaImagenPersonalizada,
      onTerminado: () {
        entrada.remove();
      },
    ),
  );
  overlayState.insert(entrada);
}
