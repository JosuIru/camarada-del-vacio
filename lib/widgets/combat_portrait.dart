import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import 'efectos_habilidad.dart';

class EventoDanoFlotante {
  final Key clave;
  final int cantidad;
  final TipoEventoDano tipo;
  final double offsetHorizontal;

  EventoDanoFlotante({
    required this.cantidad,
    required this.tipo,
    required this.offsetHorizontal,
  }) : clave = UniqueKey();
}

enum TipoEventoDano { fisico, moral }

class RetratoConEfectosImpacto extends StatefulWidget {
  final Widget contenido;
  final int puntosVida;
  final int moral;
  final bool resaltarDerrota;
  final double anchoMaximo;
  final double relacionAspectoAlto;

  /// Contador monótono que dispara la animación de un efecto especial
  /// (no slash genérico) sobre el peón objetivo. El tipo concreto del efecto
  /// lo determina [identificadorEfectoEspecial], que se mapea a un painter
  /// dedicado (sello del Decreto, polvo del salto, engranaje del sabotaje…).
  final int senalEfectoEspecial;

  /// Identificador del efecto a renderizar la próxima vez que
  /// [senalEfectoEspecial] incremente. Se persiste como `efectoVigente`
  /// hasta que termina la animación, para que cambios posteriores en el
  /// padre no rompan la animación en curso.
  final String? identificadorEfectoEspecial;

  const RetratoConEfectosImpacto({
    super.key,
    required this.contenido,
    required this.puntosVida,
    required this.moral,
    this.resaltarDerrota = false,
    this.anchoMaximo = 140,
    this.relacionAspectoAlto = 1.6,
    this.senalEfectoEspecial = 0,
    this.identificadorEfectoEspecial,
  });

  @override
  State<RetratoConEfectosImpacto> createState() =>
      _RetratoConEfectosImpactoState();
}

class _RetratoConEfectosImpactoState extends State<RetratoConEfectosImpacto>
    with TickerProviderStateMixin {
  late AnimationController controladorSacudida;
  late AnimationController controladorDestelloRojo;
  late AnimationController controladorSlash;
  late AnimationController controladorEfectoEspecial;
  final List<EventoDanoFlotante> eventosVisibles = [];
  final math.Random aleatorio = math.Random();
  double anguloSlashActual = 0;
  double inclinacionSelloActual = 0;
  bool suprimirSlashEnImpactoActual = false;

  /// Identificador del efecto actualmente animado. Se fija al disparar la
  /// animación para que el painter no cambie a media transición si el padre
  /// rehace el widget con un identificador nuevo.
  String? identificadorEfectoVigente;

  @override
  void initState() {
    super.initState();
    controladorSacudida = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    controladorDestelloRojo = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    );
    controladorSlash = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    controladorEfectoEspecial = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
  }

  @override
  void didUpdateWidget(RetratoConEfectosImpacto viejo) {
    super.didUpdateWidget(viejo);
    if (widget.senalEfectoEspecial > viejo.senalEfectoEspecial) {
      _dispararEfectoEspecial();
    }
    if (widget.puntosVida < viejo.puntosVida) {
      _dispararImpacto(
        viejo.puntosVida - widget.puntosVida,
        TipoEventoDano.fisico,
      );
    }
    if (widget.moral < viejo.moral) {
      _dispararImpacto(viejo.moral - widget.moral, TipoEventoDano.moral);
    }
    suprimirSlashEnImpactoActual = false;
  }

  @override
  void dispose() {
    controladorSacudida.dispose();
    controladorDestelloRojo.dispose();
    controladorSlash.dispose();
    controladorEfectoEspecial.dispose();
    super.dispose();
  }

  void _dispararEfectoEspecial() {
    identificadorEfectoVigente = widget.identificadorEfectoEspecial;
    inclinacionSelloActual = -0.28 + (aleatorio.nextDouble() - 0.5) * 0.18;
    final duracion = switch (identificadorEfectoVigente) {
      'laika_mordisco' => const Duration(milliseconds: 900),
      'comisaria_decreto_realidad' => const Duration(milliseconds: 1600),
      _ => const Duration(milliseconds: 1900),
    };
    controladorEfectoEspecial.duration = duracion;
    controladorEfectoEspecial.forward(from: 0);
    suprimirSlashEnImpactoActual = true;
  }

  void _dispararImpacto(int cantidad, TipoEventoDano tipo) {
    controladorSacudida.forward(from: 0);
    controladorDestelloRojo.forward(from: 0);
    if (!suprimirSlashEnImpactoActual) {
      anguloSlashActual =
          (math.pi / 4) + (aleatorio.nextDouble() - 0.5) * (math.pi / 6);
      controladorSlash.forward(from: 0);
    }
    final evento = EventoDanoFlotante(
      cantidad: cantidad,
      tipo: tipo,
      offsetHorizontal: (aleatorio.nextDouble() - 0.5) * 30,
    );
    setState(() {
      eventosVisibles.add(evento);
    });
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (!mounted) return;
      setState(() {
        eventosVisibles.removeWhere((e) => e.clave == evento.clave);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (contexto, constraints) {
        final anchoDisponible = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : widget.anchoMaximo;
        final altoDisponible = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : widget.anchoMaximo * widget.relacionAspectoAlto;
        final anchoEfectivo = math.min(widget.anchoMaximo, anchoDisponible);
        final altoSegunRelacion = anchoEfectivo * widget.relacionAspectoAlto;
        final altoEfectivo = math.min(altoSegunRelacion, altoDisponible);
        final anchoFinal = altoEfectivo / widget.relacionAspectoAlto;
        return Center(
          child: SizedBox(
            width: anchoFinal,
            height: altoEfectivo,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: controladorSacudida,
                    builder: (contexto, hijo) {
                      final fase = controladorSacudida.value;
                      final desplazamiento = fase == 0
                          ? Offset.zero
                          : Offset(
                              math.sin(fase * math.pi * 5) * (1 - fase) * 9,
                              math.cos(fase * math.pi * 3) * (1 - fase) * 3,
                            );
                      return Transform.translate(
                        offset: desplazamiento,
                        child: hijo,
                      );
                    },
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 600),
                      opacity: widget.resaltarDerrota ? 0.55 : 1.0,
                      child: widget.contenido,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: controladorDestelloRojo,
                      builder: (contexto, hijo) {
                        final alpha =
                            (1 - controladorDestelloRojo.value) *
                            (controladorDestelloRojo.isAnimating ? 0.32 : 0);
                        return Container(
                          decoration: BoxDecoration(
                            color: PaletaCosmoSovietica.rojoOficial.withValues(
                              alpha: alpha,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: controladorSlash,
                      builder: (contexto, hijo) {
                        if (!controladorSlash.isAnimating) {
                          return const SizedBox.shrink();
                        }
                        return CustomPaint(
                          size: Size.infinite,
                          painter: _PintorSlashImpacto(
                            progreso: controladorSlash.value,
                            angulo: anguloSlashActual,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: controladorEfectoEspecial,
                      builder: (contexto, hijo) {
                        if (!controladorEfectoEspecial.isAnimating &&
                            !controladorEfectoEspecial.isCompleted) {
                          return const SizedBox.shrink();
                        }
                        final idVigente = identificadorEfectoVigente;
                        if (idVigente == null) {
                          return const SizedBox.shrink();
                        }
                        if (idVigente == 'comisaria_decreto_realidad') {
                          return CustomPaint(
                            size: Size.infinite,
                            painter: _PintorSelloAntirrevolucionario(
                              progreso: controladorEfectoEspecial.value,
                              inclinacion: inclinacionSelloActual,
                            ),
                          );
                        }
                        if (idVigente == 'laika_mordisco') {
                          final progreso = controladorEfectoEspecial.value;
                          final indiceFrame = progreso < 0.34
                              ? 1
                              : (progreso < 0.67 ? 2 : 3);
                          return Transform.translate(
                            offset: Offset(math.sin(progreso * math.pi) * 8, 0),
                            child: Image.asset(
                              'assets/images/laika_mordisco_f0$indiceFrame.png',
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          );
                        }
                        return CustomPaint(
                          size: Size.infinite,
                          painter: PintorEfectoHabilidad(
                            identificadorHabilidad: idVigente,
                            progreso: controladorEfectoEspecial.value,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                for (final evento in eventosVisibles)
                  _NumeroDanoFlotante(key: evento.clave, evento: evento),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PintorSlashImpacto extends CustomPainter {
  final double progreso;
  final double angulo;

  _PintorSlashImpacto({required this.progreso, required this.angulo});

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final largo =
        math.sqrt(size.width * size.width + size.height * size.height) * 0.55;
    final dx = math.cos(angulo) * largo;
    final dy = math.sin(angulo) * largo;
    final desde = Offset(centro.dx - dx, centro.dy - dy);
    final hasta = Offset(centro.dx + dx, centro.dy + dy);

    final visibilidad = progreso < 0.5
        ? progreso / 0.5
        : 1.0 - (progreso - 0.5) / 0.5;
    final alpha = visibilidad.clamp(0.0, 1.0);

    final pincelExterior = Paint()
      ..color = PaletaCosmoSovietica.papelViejo.withValues(alpha: alpha * 0.9)
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(desde, hasta, pincelExterior);

    final pincelInterior = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial.withValues(alpha: alpha)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(desde, hasta, pincelInterior);

    final pincelDestello = Paint()
      ..color = PaletaCosmoSovietica.papelViejo.withValues(alpha: alpha * 0.25);
    canvas.drawCircle(centro, largo * 0.4, pincelDestello);
  }

  @override
  bool shouldRepaint(covariant _PintorSlashImpacto viejo) =>
      viejo.progreso != progreso || viejo.angulo != angulo;
}

/// Sello rojo estampado «ANTIRREVOLUCIONARIO» que aparece sobre el peón
/// objetivo cuando la Comisaria Poeta ejecuta el Decreto de Realidad.
/// La curva imita el gesto de un buró estampando con fuerza un papel:
/// llegada agresiva de grande a tamaño final con ligero rebote, y desaparición
/// suave al final.
class _PintorSelloAntirrevolucionario extends CustomPainter {
  final double progreso;
  final double inclinacion;

  _PintorSelloAntirrevolucionario({
    required this.progreso,
    required this.inclinacion,
  });

  double _curvaEscalaEstampado(double t) {
    if (t < 0.5) {
      final fragmentoEntrada = t / 0.5;
      return 2.6 - 1.4 * fragmentoEntrada;
    }
    final fragmentoFinal = (t - 0.5) / 0.5;
    final rebote =
        math.sin(fragmentoFinal * math.pi * 2) * 0.07 * (1 - fragmentoFinal);
    return 1.2 - 0.05 * fragmentoFinal + rebote;
  }

  double _curvaOpacidadEstampado(double t) {
    if (t < 0.18) {
      return (t / 0.18).clamp(0.0, 1.0);
    }
    if (t < 0.78) {
      return 1.0;
    }
    return (1.0 - (t - 0.78) / 0.22).clamp(0.0, 1.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centroSello = Offset(size.width / 2, size.height * 0.45);
    final escalaSello = _curvaEscalaEstampado(progreso);
    final opacidadSello = _curvaOpacidadEstampado(progreso);
    if (opacidadSello <= 0) return;

    canvas.save();
    canvas.translate(centroSello.dx, centroSello.dy);
    canvas.rotate(inclinacion);
    canvas.scale(escalaSello, escalaSello);

    final anchoSello = size.width * 0.92;
    final altoSello = size.height * 0.34;
    final rectanguloSello = Rect.fromCenter(
      center: Offset.zero,
      width: anchoSello,
      height: altoSello,
    );

    final pincelMarcoExterior = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial.withValues(
        alpha: opacidadSello * 0.92,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4;
    final pincelMarcoInterior = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial.withValues(
        alpha: opacidadSello * 0.78,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    canvas.drawRect(rectanguloSello, pincelMarcoExterior);
    canvas.drawRect(rectanguloSello.deflate(4), pincelMarcoInterior);

    final pintorTexto = TextPainter(
      text: TextSpan(
        text: 'ANTIRREVOLUCIONARIO',
        style: TextStyle(
          fontFamily: TipografiaPropaganda.familiaPrincipal,
          fontSize: altoSello * 0.46,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.4,
          color: PaletaCosmoSovietica.rojoOficial.withValues(
            alpha: opacidadSello,
          ),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: anchoSello);
    pintorTexto.paint(
      canvas,
      Offset(-pintorTexto.width / 2, -pintorTexto.height / 2),
    );

    final pincelSalpicadura = Paint()..style = PaintingStyle.fill;
    final aleatorioSalpicaduras = math.Random(11);
    for (
      int indiceSalpicadura = 0;
      indiceSalpicadura < 18;
      indiceSalpicadura++
    ) {
      final desplazamientoHorizontal =
          (aleatorioSalpicaduras.nextDouble() - 0.5) * anchoSello * 1.1;
      final desplazamientoVertical =
          (aleatorioSalpicaduras.nextDouble() - 0.5) * altoSello * 1.35;
      final radioSalpicadura = 0.4 + aleatorioSalpicaduras.nextDouble() * 1.6;
      pincelSalpicadura.color = PaletaCosmoSovietica.rojoOficial.withValues(
        alpha:
            opacidadSello * (0.32 + aleatorioSalpicaduras.nextDouble() * 0.38),
      );
      canvas.drawCircle(
        Offset(desplazamientoHorizontal, desplazamientoVertical),
        radioSalpicadura,
        pincelSalpicadura,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PintorSelloAntirrevolucionario viejo) =>
      viejo.progreso != progreso || viejo.inclinacion != inclinacion;
}

class _NumeroDanoFlotante extends StatefulWidget {
  final EventoDanoFlotante evento;

  const _NumeroDanoFlotante({super.key, required this.evento});

  @override
  State<_NumeroDanoFlotante> createState() => _NumeroDanoFlotanteState();
}

class _NumeroDanoFlotanteState extends State<_NumeroDanoFlotante>
    with SingleTickerProviderStateMixin {
  late AnimationController controlador;

  @override
  void initState() {
    super.initState();
    controlador = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controlador,
      builder: (contexto, hijo) {
        final fase = controlador.value;
        return Positioned(
          top: 30 - fase * 80,
          left: 30 + widget.evento.offsetHorizontal,
          child: Opacity(
            opacity: (1 - fase * fase).clamp(0.0, 1.0),
            child: Transform.scale(
              scale: 0.6 + fase * 0.6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.evento.tipo == TipoEventoDano.fisico
                      ? PaletaCosmoSovietica.tintaNegra
                      : PaletaCosmoSovietica.rojoOficial,
                  border: Border.all(
                    color: PaletaCosmoSovietica.papelViejo,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '−${widget.evento.cantidad}',
                  style: TextStyle(
                    fontFamily: TipografiaPropaganda.familiaMonoespaciada,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: PaletaCosmoSovietica.papelViejo,
                    letterSpacing: 1,
                    shadows: const [
                      Shadow(
                        color: PaletaCosmoSovietica.tintaNegra,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
