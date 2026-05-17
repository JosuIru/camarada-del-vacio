import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

/// Capa de humo lento ascendiendo desde la parte superior del hotspot,
/// pensada para barriles, samovares, reactores y otros elementos que emiten
/// vapor de forma continua. Las plumas se reciclan en bucle.
class EfectoHumoAscendente extends StatefulWidget {
  final int cantidadPlumas;
  final Color tinte;
  final double anchoZonaEmision;
  final double altoEmpuje;

  const EfectoHumoAscendente({
    super.key,
    this.cantidadPlumas = 12,
    this.tinte = const Color(0xCCB7B0A0),
    this.anchoZonaEmision = 0.5,
    this.altoEmpuje = 0.9,
  });

  @override
  State<EfectoHumoAscendente> createState() => _EfectoHumoAscendenteState();
}

class _EfectoHumoAscendenteState extends State<EfectoHumoAscendente>
    with SingleTickerProviderStateMixin {
  late final AnimationController controladorCiclo;
  late final List<_DescriptorPluma> plumas;

  @override
  void initState() {
    super.initState();
    controladorCiclo = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    final aleatorio = math.Random(widget.tinte.toARGB32() ^ 17);
    plumas = List.generate(widget.cantidadPlumas, (_) {
      return _DescriptorPluma(
        desfase: aleatorio.nextDouble(),
        xRelativa: 0.5 +
            (aleatorio.nextDouble() - 0.5) * widget.anchoZonaEmision,
        tamano: 4 + aleatorio.nextDouble() * 6,
        balanceoLateral: (aleatorio.nextDouble() - 0.5) * 0.15,
      );
    });
  }

  @override
  void dispose() {
    controladorCiclo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controladorCiclo,
        builder: (contexto, _) {
          return CustomPaint(
            painter: _PintorHumoAscendente(
              plumas: plumas,
              fase: controladorCiclo.value,
              tinte: widget.tinte,
              altoEmpuje: widget.altoEmpuje,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _DescriptorPluma {
  final double desfase;
  final double xRelativa;
  final double tamano;
  final double balanceoLateral;

  _DescriptorPluma({
    required this.desfase,
    required this.xRelativa,
    required this.tamano,
    required this.balanceoLateral,
  });
}

class _PintorHumoAscendente extends CustomPainter {
  final List<_DescriptorPluma> plumas;
  final double fase;
  final Color tinte;
  final double altoEmpuje;

  _PintorHumoAscendente({
    required this.plumas,
    required this.fase,
    required this.tinte,
    required this.altoEmpuje,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final pluma in plumas) {
      final faseLocal = (fase + pluma.desfase) % 1.0;
      final yRelativa = 1.0 - faseLocal * altoEmpuje;
      if (yRelativa < 0) continue;
      final xRelativa = pluma.xRelativa +
          math.sin(faseLocal * math.pi * 2.4) * pluma.balanceoLateral;
      final alphaCurva = _curvaAlphaCiclo(faseLocal);
      if (alphaCurva <= 0) continue;
      final centroPluma =
          Offset(xRelativa * size.width, yRelativa * size.height);
      final radioPluma = pluma.tamano + faseLocal * pluma.tamano * 0.6;
      canvas.drawCircle(
        centroPluma,
        radioPluma,
        Paint()..color = tinte.withValues(alpha: alphaCurva * 0.55),
      );
      canvas.drawCircle(
        centroPluma.translate(radioPluma * 0.5, -radioPluma * 0.3),
        radioPluma * 0.55,
        Paint()..color = tinte.withValues(alpha: alphaCurva * 0.4),
      );
    }
  }

  double _curvaAlphaCiclo(double t) {
    if (t < 0.1) return t / 0.1;
    if (t > 0.85) return (1.0 - t) / 0.15;
    return 1.0;
  }

  @override
  bool shouldRepaint(covariant _PintorHumoAscendente viejo) =>
      viejo.fase != fase;
}

/// Papeletas saltando desde el fondo del hotspot (urna o buzón). Aparecen,
/// suben en arco y caen fuera del marco; se reciclan.
class EfectoPapeletasSaltando extends StatefulWidget {
  final int cantidadPapeletas;

  const EfectoPapeletasSaltando({super.key, this.cantidadPapeletas = 6});

  @override
  State<EfectoPapeletasSaltando> createState() =>
      _EfectoPapeletasSaltandoState();
}

class _EfectoPapeletasSaltandoState extends State<EfectoPapeletasSaltando>
    with SingleTickerProviderStateMixin {
  late final AnimationController controladorCiclo;
  late final List<_DescriptorPapeleta> papeletas;

  @override
  void initState() {
    super.initState();
    controladorCiclo = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    final aleatorio = math.Random(31);
    papeletas = List.generate(widget.cantidadPapeletas, (indice) {
      return _DescriptorPapeleta(
        desfase: indice / widget.cantidadPapeletas +
            (aleatorio.nextDouble() - 0.5) * 0.08,
        direccionHorizontal: (aleatorio.nextDouble() - 0.5) * 0.3,
        rotacionMaxima:
            (aleatorio.nextDouble() - 0.5) * math.pi * 1.5,
      );
    });
  }

  @override
  void dispose() {
    controladorCiclo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controladorCiclo,
        builder: (contexto, _) {
          return CustomPaint(
            painter: _PintorPapeletasSaltando(
              papeletas: papeletas,
              fase: controladorCiclo.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _DescriptorPapeleta {
  final double desfase;
  final double direccionHorizontal;
  final double rotacionMaxima;

  _DescriptorPapeleta({
    required this.desfase,
    required this.direccionHorizontal,
    required this.rotacionMaxima,
  });
}

class _PintorPapeletasSaltando extends CustomPainter {
  final List<_DescriptorPapeleta> papeletas;
  final double fase;

  _PintorPapeletasSaltando({required this.papeletas, required this.fase});

  @override
  void paint(Canvas canvas, Size size) {
    for (final papeleta in papeletas) {
      final faseLocal = (fase + papeleta.desfase) % 1.0;
      // Curva parabólica: la papeleta sube y vuelve a caer.
      final yArco = -math.sin(faseLocal * math.pi) * size.height * 1.1;
      final xDesviacion =
          papeleta.direccionHorizontal * faseLocal * size.width;
      final centroPapeleta = Offset(
        size.width / 2 + xDesviacion,
        size.height * 0.5 + yArco,
      );
      if (centroPapeleta.dy < -10 ||
          centroPapeleta.dy > size.height + 10) {
        continue;
      }
      final rotacionPapeleta =
          papeleta.rotacionMaxima * faseLocal;
      final alphaPapeleta = math.sin(faseLocal * math.pi).clamp(0.0, 1.0);
      canvas.save();
      canvas.translate(centroPapeleta.dx, centroPapeleta.dy);
      canvas.rotate(rotacionPapeleta);
      final rectPapeleta = Rect.fromCenter(
        center: Offset.zero,
        width: size.width * 0.35,
        height: size.height * 0.16,
      );
      canvas.drawRect(
        rectPapeleta,
        Paint()
          ..color = PaletaCosmoSovietica.papelViejo
              .withValues(alpha: alphaPapeleta * 0.95),
      );
      canvas.drawRect(
        rectPapeleta,
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra
              .withValues(alpha: alphaPapeleta)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke,
      );
      // Marca roja "✓" en la papeleta.
      final pincelMarca = Paint()
        ..color = PaletaCosmoSovietica.rojoOficial
            .withValues(alpha: alphaPapeleta)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
          Offset(-rectPapeleta.width * 0.15, 0),
          Offset(-rectPapeleta.width * 0.05, rectPapeleta.height * 0.25),
          pincelMarca);
      canvas.drawLine(
          Offset(-rectPapeleta.width * 0.05, rectPapeleta.height * 0.25),
          Offset(rectPapeleta.width * 0.15, -rectPapeleta.height * 0.2),
          pincelMarca);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PintorPapeletasSaltando viejo) =>
      viejo.fase != fase;
}

/// Gota cayendo de un tubo: aparece arriba, recorre la altura completa
/// y al impactar deja un pequeño splash que se desvanece. Cíclico.
class EfectoGoteoIntermitente extends StatefulWidget {
  final Color tinte;
  final Duration intervaloGota;

  const EfectoGoteoIntermitente({
    super.key,
    this.tinte = const Color(0xFF1F4E79),
    this.intervaloGota = const Duration(milliseconds: 2400),
  });

  @override
  State<EfectoGoteoIntermitente> createState() =>
      _EfectoGoteoIntermitenteState();
}

class _EfectoGoteoIntermitenteState extends State<EfectoGoteoIntermitente>
    with SingleTickerProviderStateMixin {
  late final AnimationController controladorCiclo;

  @override
  void initState() {
    super.initState();
    controladorCiclo = AnimationController(
      vsync: this,
      duration: widget.intervaloGota,
    )..repeat();
  }

  @override
  void dispose() {
    controladorCiclo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controladorCiclo,
        builder: (contexto, _) {
          return CustomPaint(
            painter: _PintorGoteoIntermitente(
              fase: controladorCiclo.value,
              tinte: widget.tinte,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _PintorGoteoIntermitente extends CustomPainter {
  final double fase;
  final Color tinte;

  _PintorGoteoIntermitente({required this.fase, required this.tinte});

  @override
  void paint(Canvas canvas, Size size) {
    if (fase < 0.7) {
      final tCaida = fase / 0.7;
      final centroGota = Offset(
        size.width / 2,
        size.height * 0.08 + tCaida * size.height * 0.78,
      );
      final radioGota = 3.4;
      final caminoGota = Path()
        ..moveTo(centroGota.dx, centroGota.dy - radioGota * 1.6)
        ..quadraticBezierTo(centroGota.dx + radioGota * 1.2,
            centroGota.dy - radioGota * 0.1, centroGota.dx,
            centroGota.dy + radioGota)
        ..quadraticBezierTo(centroGota.dx - radioGota * 1.2,
            centroGota.dy - radioGota * 0.1, centroGota.dx,
            centroGota.dy - radioGota * 1.6)
        ..close();
      canvas.drawPath(
        caminoGota,
        Paint()..color = tinte,
      );
      canvas.drawPath(
        caminoGota,
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra
              .withValues(alpha: 0.85)
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke,
      );
    } else {
      // Splash en la base que se desvanece.
      final tSplash = (fase - 0.7) / 0.3;
      final centroSplash =
          Offset(size.width / 2, size.height * 0.86);
      final radioSplash = 3.0 + tSplash * 9.0;
      canvas.drawCircle(
        centroSplash,
        radioSplash,
        Paint()
          ..color = tinte.withValues(alpha: 1.0 - tSplash)
          ..strokeWidth = 1.4
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PintorGoteoIntermitente viejo) =>
      viejo.fase != fase;
}
