import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/character.dart';
import '../theme.dart';

class FilaIconosEstado extends StatelessWidget {
  final Combatiente combatiente;
  final double tamano;

  const FilaIconosEstado({
    super.key,
    required this.combatiente,
    this.tamano = 14,
  });

  @override
  Widget build(BuildContext context) {
    final iconos = <Widget>[];
    if (combatiente.empapado) {
      iconos.add(_IconoEstado(
        tamano: tamano,
        painter: _PintorGotaAgua(),
        tooltip: 'Empapado · armadura física anulada',
      ));
    }
    if (combatiente.turnosPenalizacionPaPendientes > 0 &&
        combatiente.paPenalizacionAcumulada > 0) {
      iconos.add(_IconoEstado(
        tamano: tamano,
        painter: _PintorEngranaje(),
        tooltip:
            'Saboteado · −${combatiente.paPenalizacionAcumulada} PA por ${combatiente.turnosPenalizacionPaPendientes} turnos',
      ));
    }
    if (combatiente.paBonusProximoTurno > 0) {
      iconos.add(_IconoEstado(
        tamano: tamano,
        painter: _PintorEstrellaMini(),
        tooltip: '+${combatiente.paBonusProximoTurno} PA bonus al inicio',
      ));
    }
    if (iconos.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 3, runSpacing: 3, children: iconos);
  }
}

class _IconoEstado extends StatelessWidget {
  final double tamano;
  final CustomPainter painter;
  final String tooltip;

  const _IconoEstado({
    required this.tamano,
    required this.painter,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: tamano,
        height: tamano,
        decoration: BoxDecoration(
          color: PaletaCosmoSovietica.papelViejo,
          border: Border.all(
            color: PaletaCosmoSovietica.tintaNegra,
            width: 1.2,
          ),
        ),
        child: CustomPaint(painter: painter),
      ),
    );
  }
}

class _PintorGotaAgua extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, size.height * 0.12)
      ..quadraticBezierTo(size.width * 0.92, size.height * 0.7,
          size.width / 2, size.height * 0.88)
      ..quadraticBezierTo(size.width * 0.08, size.height * 0.7,
          size.width / 2, size.height * 0.12)
      ..close();
    canvas.drawPath(path, pincel);
  }

  @override
  bool shouldRepaint(covariant _PintorGotaAgua oldDelegate) => false;
}

class _PintorEngranaje extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final radioExt = size.width / 2 * 0.85;
    final radioInt = radioExt * 0.6;
    final dientes = 8;
    final pincel = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..style = PaintingStyle.fill;
    final path = Path();
    for (int i = 0; i < dientes * 2; i++) {
      final r = i % 2 == 0 ? radioExt : radioInt * 1.1;
      final ang = (i * math.pi / dientes) - math.pi / 2;
      final px = centro.dx + r * math.cos(ang);
      final py = centro.dy + r * math.sin(ang);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, pincel);
    canvas.drawCircle(
      centro,
      radioInt * 0.42,
      Paint()..color = PaletaCosmoSovietica.papelViejo,
    );
  }

  @override
  bool shouldRepaint(covariant _PintorEngranaje oldDelegate) => false;
}

class _PintorEstrellaMini extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final radio = size.width / 2 * 0.78;
    final puntos = 5;
    final path = Path();
    for (int i = 0; i < puntos * 2; i++) {
      final r = i % 2 == 0 ? radio : radio * 0.45;
      final ang = -math.pi / 2 + i * math.pi / puntos;
      final x = centro.dx + r * math.cos(ang);
      final y = centro.dy + r * math.sin(ang);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()..color = PaletaCosmoSovietica.rojoOficial,
    );
  }

  @override
  bool shouldRepaint(covariant _PintorEstrellaMini oldDelegate) => false;
}
