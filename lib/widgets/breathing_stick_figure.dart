import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/game_class.dart';
import '../painters/stick_figure_painter.dart';
import 'sprite_clase_cadete.dart';

class StickFigureViviente extends StatefulWidget {
  final ClaseCosmonauta? clase;
  final PoseStickFigure pose;
  final bool animarRespiracion;
  final bool enMovimiento;
  final Duration duracionCiclo;
  final Duration duracionPaso;
  final double amplitudEscala;
  final String? idSombreroEquipado;
  final String? idArmaEquipada;
  final String? idTorsoEquipado;

  const StickFigureViviente({
    super.key,
    required this.clase,
    this.pose = PoseStickFigure.reposoFirme,
    this.animarRespiracion = true,
    this.enMovimiento = false,
    this.duracionCiclo = const Duration(milliseconds: 3200),
    this.duracionPaso = const Duration(milliseconds: 420),
    this.amplitudEscala = 0.025,
    this.idSombreroEquipado,
    this.idArmaEquipada,
    this.idTorsoEquipado,
  });

  @override
  State<StickFigureViviente> createState() => _StickFigureVivienteState();
}

class _StickFigureVivienteState extends State<StickFigureViviente>
    with TickerProviderStateMixin {
  late AnimationController controladorRespiracion;
  late AnimationController controladorPaso;

  @override
  void initState() {
    super.initState();
    controladorRespiracion = AnimationController(
      vsync: this,
      duration: widget.duracionCiclo,
    );
    controladorPaso = AnimationController(
      vsync: this,
      duration: widget.duracionPaso,
    );
    if (widget.animarRespiracion) {
      controladorRespiracion.repeat();
    }
    if (widget.enMovimiento) {
      controladorPaso.repeat();
    }
  }

  @override
  void didUpdateWidget(StickFigureViviente viejo) {
    super.didUpdateWidget(viejo);
    if (widget.animarRespiracion && !controladorRespiracion.isAnimating) {
      controladorRespiracion.repeat();
    } else if (!widget.animarRespiracion &&
        controladorRespiracion.isAnimating) {
      controladorRespiracion.stop();
      controladorRespiracion.value = 0;
    }
    if (widget.enMovimiento && !controladorPaso.isAnimating) {
      controladorPaso.repeat();
    } else if (!widget.enMovimiento && controladorPaso.isAnimating) {
      controladorPaso.stop();
      controladorPaso.value = 0;
    }
  }

  @override
  void dispose() {
    controladorRespiracion.dispose();
    controladorPaso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation:
          Listenable.merge([controladorRespiracion, controladorPaso]),
      builder: (contexto, _) {
        final faseResp =
            math.sin(controladorRespiracion.value * 2 * math.pi);
        final escala = 1.0 + faseResp * widget.amplitudEscala;
        final poseEfectiva = widget.enMovimiento
            ? PoseStickFigure.caminando
            : widget.pose;
        // Si hay clase definida y la pose no es "derrotado" (cuerpo
        // tumbado), superponemos el PNG de cabeza por clase encima del
        // stick figure. El sombrero equipado se sigue pintando en el
        // painter sobre la posición del casco — queda visualmente sobre
        // la cabeza PNG porque ambos comparten la misma cuadrícula
        // (unidad = alto / 14, centro cabeza en y = 2.2·u).
        final bool usarCabezaPng = widget.clase != null &&
            poseEfectiva != PoseStickFigure.derrotado;
        final Widget cuerpo = CustomPaint(
          painter: PintorStickFigure(
            clase: widget.clase,
            pose: poseEfectiva,
            fasePaso: controladorPaso.value,
            faseRespiracion: controladorRespiracion.value,
            idSombreroEquipado: widget.idSombreroEquipado,
            idArmaEquipada: widget.idArmaEquipada,
            idTorsoEquipado: widget.idTorsoEquipado,
            dibujarCabeza: !usarCabezaPng,
          ),
        );
        return Transform.scale(
          scale: escala,
          alignment: Alignment.bottomCenter,
          child: usarCabezaPng
              ? LayoutBuilder(
                  builder: (contextoLayout, restricciones) {
                    // El stick figure usa unidad = alto / 14. La cabeza
                    // se centra en y = 2.2·unidad y radio 1.3·unidad,
                    // ocupando de y=0.9·u a y=3.5·u. El PNG de cabeza
                    // incluye también hombros (≈ y=4·u). Ancho del PNG:
                    // ≈ 4·u para que tape el círculo y baje hasta cuello.
                    final double alto = restricciones.maxHeight;
                    final double unidad = alto / 14.0;
                    final bool tieneSombrero =
                        widget.idSombreroEquipado != null &&
                            widget.idSombreroEquipado!.isNotEmpty;
                    return Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Positioned.fill(child: cuerpo),
                        Positioned(
                          top: -unidad * 1.0,
                          width: unidad * 6.8,
                          height: unidad * 7.4,
                          child: Image.asset(
                            rutaCabezaCadete(widget.clase!),
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                        // Capa overlay: el sombrero equipado se pinta
                        // encima del PNG de cabeza para que ushankas y
                        // gorras específicas queden visibles sobre el
                        // casco soviético del retrato.
                        if (tieneSombrero)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: PintorStickFigure(
                                clase: widget.clase,
                                pose: poseEfectiva,
                                idSombreroEquipado:
                                    widget.idSombreroEquipado,
                                soloSombrero: true,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                )
              : cuerpo,
        );
      },
    );
  }
}
