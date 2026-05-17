import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import 'animacion_cadete_combate.dart';

class BannerDeTurno extends StatefulWidget {
  final String texto;
  final bool esJugador;

  const BannerDeTurno({
    super.key,
    required this.texto,
    required this.esJugador,
  });

  @override
  State<BannerDeTurno> createState() => _BannerDeTurnoState();
}

class _BannerDeTurnoState extends State<BannerDeTurno>
    with SingleTickerProviderStateMixin {
  late AnimationController controlador;

  @override
  void initState() {
    super.initState();
    controlador = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    controlador.dispose();
    super.dispose();
  }

  /// Modela la curva de entrada del cartel: viene desde la izquierda como
  /// un sellador que aterriza con fuerza, rebota corto y se asienta.
  double _desplazamientoHorizontalEnFase(double t) {
    if (t < 0.22) {
      final fragmentoEntrada = t / 0.22;
      return -180.0 * (1.0 - fragmentoEntrada * fragmentoEntrada);
    }
    if (t < 0.32) {
      final fragmentoRebote = (t - 0.22) / 0.10;
      return math.sin(fragmentoRebote * math.pi) * 14.0;
    }
    if (t > 0.82) {
      final fragmentoSalida = (t - 0.82) / 0.18;
      return fragmentoSalida * fragmentoSalida * 240.0;
    }
    return 0.0;
  }

  double _escalaEnFase(double t) {
    if (t < 0.22) {
      final fragmentoEntrada = t / 0.22;
      return 1.45 - 0.45 * fragmentoEntrada;
    }
    if (t < 0.34) {
      final fragmentoRebote = (t - 0.22) / 0.12;
      return 1.0 + math.sin(fragmentoRebote * math.pi) * 0.08;
    }
    return 1.0;
  }

  double _rotacionEnFase(double t) {
    if (t < 0.22) {
      final fragmentoEntrada = t / 0.22;
      return -0.12 * (1.0 - fragmentoEntrada);
    }
    if (t < 0.34) {
      final fragmentoRebote = (t - 0.22) / 0.12;
      return math.sin(fragmentoRebote * math.pi * 2) * 0.04;
    }
    return 0.0;
  }

  double _opacidadEnFase(double t) {
    if (t < 0.12) return t / 0.12;
    if (t > 0.86) return 1.0 - (t - 0.86) / 0.14;
    return 1.0;
  }

  /// Progreso de la onda de impacto: 0 → 1 mientras se expanden las líneas
  /// radiales. Solo visible en el corto rato tras el "golpe" de entrada.
  double _progresoImpacto(double t) {
    if (t < 0.22) return 0.0;
    if (t > 0.45) return 1.0;
    return (t - 0.22) / 0.23;
  }

  @override
  Widget build(BuildContext context) {
    final colorBase = widget.esJugador
        ? PaletaCosmoSovietica.rojoOficial
        : PaletaCosmoSovietica.tintaNegra;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controlador,
        builder: (contexto, _) {
          final tiempoActual = controlador.value;
          final desplazamientoHorizontal =
              _desplazamientoHorizontalEnFase(tiempoActual);
          final escalaActual = _escalaEnFase(tiempoActual);
          final rotacionActual = _rotacionEnFase(tiempoActual);
          final opacidadActual = _opacidadEnFase(tiempoActual);
          final progresoImpacto = _progresoImpacto(tiempoActual);
          return Center(
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (progresoImpacto > 0 && progresoImpacto < 1)
                  IgnorePointer(
                    child: SizedBox(
                      width: 360,
                      height: 220,
                      child: CustomPaint(
                        painter: _PintorLineasImpacto(
                          progreso: progresoImpacto,
                          colorAcento: colorBase,
                        ),
                      ),
                    ),
                  ),
                // Cuando arranca el turno del jugador, el cadete grita
                // marcial a la izquierda del rótulo. El sprite cicla los
                // 3 frames durante la fase de impacto y desaparece al
                // mismo ritmo que el banner sale.
                if (widget.esJugador &&
                    tiempoActual > 0.16 &&
                    tiempoActual < 0.82)
                  Positioned(
                    left: -160,
                    child: Opacity(
                      opacity: opacidadActual.clamp(0.0, 1.0),
                      child: const SizedBox(
                        width: 140,
                        height: 180,
                        child: AnimacionCadeteCombate(
                          tipo: TipoAnimacionCadete.gritoMarcial,
                          duracionPorFrame: Duration(milliseconds: 200),
                        ),
                      ),
                    ),
                  ),
                Transform.translate(
                  offset: Offset(desplazamientoHorizontal, 0),
                  child: Transform.rotate(
                    angle: rotacionActual,
                    child: Transform.scale(
                      scale: escalaActual,
                      child: Opacity(
                        opacity: opacidadActual.clamp(0.0, 1.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 38, vertical: 14),
                          decoration: BoxDecoration(
                            color: colorBase,
                            border: Border.all(
                              color: PaletaCosmoSovietica.tintaNegra,
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: PaletaCosmoSovietica.tintaNegra,
                                offset: Offset(5, 5),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.texto.toUpperCase(),
                            style: const TextStyle(
                              fontFamily:
                                  TipografiaPropaganda.familiaPrincipal,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: PaletaCosmoSovietica.papelViejo,
                              letterSpacing: 6,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Onda de impacto: 12 líneas radiales que se expanden desde el centro tras
/// la entrada agresiva del cartel, sugiriendo el "golpe seco" del sello.
class _PintorLineasImpacto extends CustomPainter {
  final double progreso;
  final Color colorAcento;

  _PintorLineasImpacto({
    required this.progreso,
    required this.colorAcento,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centroImpacto = Offset(size.width / 2, size.height / 2);
    const cantidadLineas = 12;
    final radioInterno = 90.0 + progreso * 60.0;
    final radioExterno = radioInterno + 22.0 + progreso * 60.0;
    final opacidadLineas = (1.0 - progreso) * 0.85;
    final pincelLineaImpacto = Paint()
      ..color = colorAcento.withValues(alpha: opacidadLineas)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0 - progreso * 2.5;

    for (int indiceLinea = 0; indiceLinea < cantidadLineas; indiceLinea++) {
      final anguloLinea =
          (indiceLinea / cantidadLineas) * math.pi * 2 + progreso * 0.4;
      final puntoInterno = Offset(
        centroImpacto.dx + math.cos(anguloLinea) * radioInterno,
        centroImpacto.dy + math.sin(anguloLinea) * radioInterno,
      );
      final puntoExterno = Offset(
        centroImpacto.dx + math.cos(anguloLinea) * radioExterno,
        centroImpacto.dy + math.sin(anguloLinea) * radioExterno,
      );
      canvas.drawLine(puntoInterno, puntoExterno, pincelLineaImpacto);
    }

    // Anillo de polvo que se ensancha.
    final pincelAnillo = Paint()
      ..color = colorAcento.withValues(alpha: opacidadLineas * 0.4)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(centroImpacto, radioInterno - 12, pincelAnillo);
  }

  @override
  bool shouldRepaint(covariant _PintorLineasImpacto viejo) =>
      viejo.progreso != progreso || viejo.colorAcento != colorAcento;
}
