import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/character.dart';
import '../theme.dart';

/// Overlay visible que se superpone al sprite del peón en combate para mostrar
/// estados activos (empapado, saboteado, bonus de PA) con animación.
///
/// Se diferencia de [FilaIconosEstado], que muestra los iconos pequeños en la
/// esquina superior: este overlay pinta efectos llamativos *encima* del cuerpo
/// del personaje para que el estado sea legible de un vistazo.
class OverlayEstadosPeon extends StatelessWidget {
  final Combatiente combatiente;
  final AnimationController controladorFase;

  const OverlayEstadosPeon({
    super.key,
    required this.combatiente,
    required this.controladorFase,
  });

  @override
  Widget build(BuildContext context) {
    final tieneEmpapado = combatiente.empapado;
    final tieneSabotaje = combatiente.turnosPenalizacionPaPendientes > 0 &&
        combatiente.paPenalizacionAcumulada > 0;
    final tieneBonusPa = combatiente.paBonusProximoTurno > 0;
    final tieneIntimidado = combatiente.intimidado;
    final tieneEuforico = combatiente.euforico;

    if (!tieneEmpapado &&
        !tieneSabotaje &&
        !tieneBonusPa &&
        !tieneIntimidado &&
        !tieneEuforico) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controladorFase,
        builder: (contexto, _) {
          return CustomPaint(
            painter: _PintorEstadosSobrePeon(
              fase: controladorFase.value,
              empapado: tieneEmpapado,
              saboteado: tieneSabotaje,
              bonusPaActivo: tieneBonusPa,
              intimidado: tieneIntimidado,
              euforico: tieneEuforico,
            ),
          );
        },
      ),
    );
  }
}

class _PintorEstadosSobrePeon extends CustomPainter {
  final double fase;
  final bool empapado;
  final bool saboteado;
  final bool bonusPaActivo;
  final bool intimidado;
  final bool euforico;

  _PintorEstadosSobrePeon({
    required this.fase,
    required this.empapado,
    required this.saboteado,
    required this.bonusPaActivo,
    required this.intimidado,
    required this.euforico,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (empapado) {
      _pintarGotasCayendo(canvas, size);
    }
    if (saboteado) {
      _pintarChispasOrbitando(canvas, size);
    }
    if (bonusPaActivo) {
      _pintarAuraBonus(canvas, size);
    }
    if (intimidado) {
      _pintarSudorIntimidacion(canvas, size);
    }
    if (euforico) {
      _pintarChispasEuforia(canvas, size);
    }
  }

  void _pintarSudorIntimidacion(Canvas canvas, Size size) {
    final pincelGota = Paint()
      ..color = const Color(0xFFB3C9D9)
      ..style = PaintingStyle.fill;
    final pincelBorde = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    const cantidadGotasSudor = 3;
    for (int indiceGotaSudor = 0;
        indiceGotaSudor < cantidadGotasSudor;
        indiceGotaSudor++) {
      final desfase = indiceGotaSudor / cantidadGotasSudor;
      final progreso = (fase * 0.6 + desfase) % 1.0;
      final centroX = size.width * (0.7 + indiceGotaSudor * 0.08);
      final centroY = size.height * (0.1 + progreso * 0.35);
      final radio = size.width * 0.022;
      final caminoSudor = Path()
        ..moveTo(centroX, centroY - radio * 1.5)
        ..quadraticBezierTo(
            centroX + radio, centroY, centroX, centroY + radio)
        ..quadraticBezierTo(
            centroX - radio, centroY, centroX, centroY - radio * 1.5)
        ..close();
      canvas.drawPath(caminoSudor, pincelGota);
      canvas.drawPath(caminoSudor, pincelBorde);
    }
    // Símbolo de exclamación nervioso encima de la cabeza.
    final centroSimbolo = Offset(size.width * 0.5, size.height * 0.04);
    final temblor = math.sin(fase * math.pi * 12) * size.width * 0.008;
    final pincelSimbolo = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centroSimbolo.dx + temblor, centroSimbolo.dy),
        width: size.width * 0.012,
        height: size.height * 0.05,
      ),
      pincelSimbolo,
    );
    canvas.drawCircle(
      Offset(centroSimbolo.dx + temblor, centroSimbolo.dy + size.height * 0.045),
      size.width * 0.008,
      pincelSimbolo,
    );
  }

  void _pintarChispasEuforia(Canvas canvas, Size size) {
    const cantidadDestellos = 5;
    final pincelDestello = Paint()
      ..color = const Color(0xFFFFCB45)
      ..style = PaintingStyle.fill;
    final pincelBorde = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    for (int indiceDestello = 0;
        indiceDestello < cantidadDestellos;
        indiceDestello++) {
      final desfase = indiceDestello / cantidadDestellos;
      final progreso = (fase + desfase) % 1.0;
      final centroDestello = Offset(
        size.width *
            (0.1 + (indiceDestello * 0.21 + math.sin(progreso * math.pi) * 0.04)),
        size.height * (1.0 - progreso * 1.05),
      );
      final tamano = size.width * (0.028 + math.sin(progreso * math.pi) * 0.012);
      final caminoEstrella = Path();
      const cantidadPuntas = 5;
      for (int indicePunta = 0;
          indicePunta < cantidadPuntas * 2;
          indicePunta++) {
        final esExterior = indicePunta % 2 == 0;
        final radio = esExterior ? tamano : tamano * 0.4;
        final angulo = -math.pi / 2 + indicePunta * math.pi / cantidadPuntas;
        final x = centroDestello.dx + math.cos(angulo) * radio;
        final y = centroDestello.dy + math.sin(angulo) * radio;
        if (indicePunta == 0) {
          caminoEstrella.moveTo(x, y);
        } else {
          caminoEstrella.lineTo(x, y);
        }
      }
      caminoEstrella.close();
      canvas.drawPath(caminoEstrella, pincelDestello);
      canvas.drawPath(caminoEstrella, pincelBorde);
    }
  }

  void _pintarGotasCayendo(Canvas canvas, Size size) {
    const cantidadGotas = 5;
    final pincelGota = Paint()
      ..color = const Color(0xFF1F4E79)
      ..style = PaintingStyle.fill;
    final pincelBorde = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final pincelBrillo = Paint()
      ..color = PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    for (int indiceGota = 0; indiceGota < cantidadGotas; indiceGota++) {
      final desfase = indiceGota / cantidadGotas;
      final progresoCaida = (fase + desfase) % 1.0;
      final columnaRelativa =
          (indiceGota * 0.21 + 0.07 + math.sin(indiceGota * 1.7) * 0.05);
      final centroX = size.width * columnaRelativa;
      final centroY = size.height * (0.05 + progresoCaida * 0.95);
      final radioGota = size.width * 0.045;

      final caminoGota = Path()
        ..moveTo(centroX, centroY - radioGota * 1.6)
        ..quadraticBezierTo(
          centroX + radioGota * 1.15,
          centroY - radioGota * 0.1,
          centroX,
          centroY + radioGota,
        )
        ..quadraticBezierTo(
          centroX - radioGota * 1.15,
          centroY - radioGota * 0.1,
          centroX,
          centroY - radioGota * 1.6,
        )
        ..close();

      canvas.drawPath(caminoGota, pincelGota);
      canvas.drawPath(caminoGota, pincelBorde);
      canvas.drawCircle(
        Offset(centroX - radioGota * 0.35, centroY - radioGota * 0.2),
        radioGota * 0.22,
        pincelBrillo,
      );
    }
  }

  void _pintarChispasOrbitando(Canvas canvas, Size size) {
    const cantidadChispas = 6;
    final centroOrbita = Offset(size.width / 2, size.height * 0.55);
    final radioOrbita = size.width * 0.42;
    final pincelChispa = Paint()
      ..color = const Color(0xFFE6B400)
      ..style = PaintingStyle.fill;
    final pincelContornoChispa = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    for (int indiceChispa = 0; indiceChispa < cantidadChispas; indiceChispa++) {
      final fragmentoAngular = indiceChispa / cantidadChispas;
      final anguloChispa =
          fragmentoAngular * math.pi * 2 + fase * math.pi * 2;
      final pulsoRadial =
          1.0 + math.sin(fase * math.pi * 4 + indiceChispa) * 0.06;
      final centroChispa = Offset(
        centroOrbita.dx + math.cos(anguloChispa) * radioOrbita * pulsoRadial,
        centroOrbita.dy +
            math.sin(anguloChispa) * radioOrbita * 0.85 * pulsoRadial,
      );
      final tamanoChispa = size.width *
          (0.04 + math.sin(fase * math.pi * 6 + indiceChispa * 1.3) * 0.012);

      final caminoChispa = Path();
      const cantidadPuntas = 4;
      for (int indicePunta = 0; indicePunta < cantidadPuntas * 2; indicePunta++) {
        final esExterior = indicePunta % 2 == 0;
        final radioPunto =
            esExterior ? tamanoChispa : tamanoChispa * 0.32;
        final anguloPunto =
            -math.pi / 2 + indicePunta * math.pi / cantidadPuntas;
        final x = centroChispa.dx + math.cos(anguloPunto) * radioPunto;
        final y = centroChispa.dy + math.sin(anguloPunto) * radioPunto;
        if (indicePunta == 0) {
          caminoChispa.moveTo(x, y);
        } else {
          caminoChispa.lineTo(x, y);
        }
      }
      caminoChispa.close();
      canvas.drawPath(caminoChispa, pincelChispa);
      canvas.drawPath(caminoChispa, pincelContornoChispa);
    }
  }

  void _pintarAuraBonus(Canvas canvas, Size size) {
    final centroAura = Offset(size.width / 2, size.height * 0.55);
    final radioBase = size.width * 0.5;
    final pulso = 0.85 + math.sin(fase * math.pi * 2) * 0.15;
    final pincelAura = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawCircle(centroAura, radioBase * pulso, pincelAura);
    canvas.drawCircle(centroAura, radioBase * pulso * 0.78,
        pincelAura..color = PaletaCosmoSovietica.rojoOficial.withValues(alpha: 0.12));
  }

  @override
  bool shouldRepaint(covariant _PintorEstadosSobrePeon oldDelegate) {
    return oldDelegate.fase != fase ||
        oldDelegate.empapado != empapado ||
        oldDelegate.saboteado != saboteado ||
        oldDelegate.bonusPaActivo != bonusPaActivo ||
        oldDelegate.intimidado != intimidado ||
        oldDelegate.euforico != euforico;
  }
}
