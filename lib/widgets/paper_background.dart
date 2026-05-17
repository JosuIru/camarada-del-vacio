import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

class FondoPapelViejo extends StatelessWidget {
  final Widget child;
  final double intensidadTextura;
  final int densidadMotas;

  const FondoPapelViejo({
    super.key,
    required this.child,
    this.intensidadTextura = 0.06,
    this.densidadMotas = 220,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PaletaCosmoSovietica.papelViejo,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _PintorTexturaPapel(
                  intensidad: intensidadTextura,
                  densidad: densidadMotas,
                ),
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _PintorTexturaPapel extends CustomPainter {
  final double intensidad;
  final int densidad;

  _PintorTexturaPapel({required this.intensidad, required this.densidad});

  @override
  void paint(Canvas canvas, Size size) {
    final semilla = (size.width * size.height).toInt();
    final aleatorio = math.Random(semilla);
    final pincelMota = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
          .withValues(alpha: intensidad);

    for (int indice = 0; indice < densidad; indice++) {
      final x = aleatorio.nextDouble() * size.width;
      final y = aleatorio.nextDouble() * size.height;
      final radio = aleatorio.nextDouble() * 1.4 + 0.3;
      canvas.drawCircle(Offset(x, y), radio, pincelMota);
    }

    final pincelMancha = Paint()
      ..color = PaletaCosmoSovietica.rojoSombra
          .withValues(alpha: intensidad * 0.5);
    for (int indice = 0; indice < 4; indice++) {
      final x = aleatorio.nextDouble() * size.width;
      final y = aleatorio.nextDouble() * size.height;
      final radio = 18 + aleatorio.nextDouble() * 26;
      canvas.drawCircle(Offset(x, y), radio, pincelMancha);
    }
  }

  @override
  bool shouldRepaint(covariant _PintorTexturaPapel viejo) =>
      viejo.intensidad != intensidad || viejo.densidad != densidad;
}
