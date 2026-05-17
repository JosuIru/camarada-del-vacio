import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

class _Particula {
  final double xInicial;
  final double yInicial;
  final double velocidadX;
  final double velocidadY;
  final double rotacionInicial;
  final double velocidadRotacion;
  final double tamano;
  final double retraso;
  final Color tinte;

  _Particula({
    required this.xInicial,
    required this.yInicial,
    required this.velocidadX,
    required this.velocidadY,
    required this.rotacionInicial,
    required this.velocidadRotacion,
    required this.tamano,
    required this.retraso,
    required this.tinte,
  });
}

class LluviaDePolvoDeCarbon extends StatefulWidget {
  final int cantidadParticulas;
  final Duration duracionTotal;

  const LluviaDePolvoDeCarbon({
    super.key,
    this.cantidadParticulas = 38,
    this.duracionTotal = const Duration(milliseconds: 2200),
  });

  @override
  State<LluviaDePolvoDeCarbon> createState() => _LluviaDePolvoDeCarbonState();
}

class _LluviaDePolvoDeCarbonState extends State<LluviaDePolvoDeCarbon>
    with SingleTickerProviderStateMixin {
  late AnimationController controlador;
  late List<_Particula> particulas;
  final math.Random aleatorio = math.Random();

  @override
  void initState() {
    super.initState();
    controlador = AnimationController(
      vsync: this,
      duration: widget.duracionTotal,
    )..forward();
    particulas = List.generate(widget.cantidadParticulas, (_) {
      final esRojo = aleatorio.nextDouble() < 0.18;
      return _Particula(
        xInicial: aleatorio.nextDouble() * 80 - 40,
        yInicial: aleatorio.nextDouble() * 60 - 30,
        velocidadX: (aleatorio.nextDouble() - 0.5) * 80,
        velocidadY: 60 + aleatorio.nextDouble() * 110,
        rotacionInicial: aleatorio.nextDouble() * math.pi * 2,
        velocidadRotacion: (aleatorio.nextDouble() - 0.5) * 6,
        tamano: 2.0 + aleatorio.nextDouble() * 3.0,
        retraso: aleatorio.nextDouble() * 0.25,
        tinte: esRojo
            ? PaletaCosmoSovietica.rojoOficial
            : PaletaCosmoSovietica.tintaNegra,
      );
    });
  }

  @override
  void dispose() {
    controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controlador,
        builder: (contexto, _) {
          return CustomPaint(
            painter: _PintorLluvia(
              particulas: particulas,
              progreso: controlador.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _PintorLluvia extends CustomPainter {
  final List<_Particula> particulas;
  final double progreso;

  _PintorLluvia({required this.particulas, required this.progreso});

  @override
  void paint(Canvas canvas, Size size) {
    final centroX = size.width / 2;
    final centroY = size.height / 2;
    final gravedad = 110.0;

    for (final p in particulas) {
      final tLocal = ((progreso - p.retraso) / (1.0 - p.retraso))
          .clamp(0.0, 1.0);
      if (tLocal <= 0) continue;
      final tSegundos = tLocal * 1.8;
      final x = centroX + p.xInicial + p.velocidadX * tSegundos;
      final y = centroY +
          p.yInicial +
          p.velocidadY * tSegundos +
          0.5 * gravedad * tSegundos * tSegundos;
      final rotacion = p.rotacionInicial + p.velocidadRotacion * tSegundos;
      final alpha = (1.0 - tLocal * tLocal).clamp(0.0, 1.0);
      final pincel = Paint()..color = p.tinte.withValues(alpha: alpha);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotacion);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.tamano,
          height: p.tamano,
        ),
        pincel,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PintorLluvia viejo) =>
      viejo.progreso != progreso;
}
