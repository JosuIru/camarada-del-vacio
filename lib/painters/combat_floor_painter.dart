import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

class PintorSueloTablero extends CustomPainter {
  final int columnas;
  final int filas;
  final int columnasJugador;
  final double fase;

  PintorSueloTablero({
    required this.columnas,
    required this.filas,
    this.columnasJugador = 3,
    this.fase = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final ladoCelda = size.width / columnas;

    final pincelFondoJugador = Paint()
      ..color = PaletaCosmoSovietica.papelSombra.withValues(alpha: 0.8);
    final pincelFondoEnemigo = Paint()
      ..color = PaletaCosmoSovietica.papelSombra.withValues(alpha: 0.5);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, ladoCelda * columnasJugador, size.height),
      pincelFondoJugador,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        ladoCelda * columnasJugador,
        0,
        size.width - ladoCelda * columnasJugador,
        size.height,
      ),
      pincelFondoEnemigo,
    );

    final pincelDiagonal = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.07)
      ..strokeWidth = 1;
    for (double y = -size.height; y < size.width + size.height; y += 18) {
      canvas.drawLine(
        Offset(y, 0),
        Offset(y - size.height, size.height),
        pincelDiagonal,
      );
    }

    final pincelLineaCelda = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (int col = 1; col < columnas; col++) {
      canvas.drawLine(
        Offset(col * ladoCelda, 0),
        Offset(col * ladoCelda, size.height),
        pincelLineaCelda,
      );
    }
    for (int fila = 1; fila < filas; fila++) {
      canvas.drawLine(
        Offset(0, fila * (size.height / filas)),
        Offset(size.width, fila * (size.height / filas)),
        pincelLineaCelda,
      );
    }

    final centroDivisoria = Offset(ladoCelda * columnasJugador, 0);
    final pincelDivisoria = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.45)
      ..strokeWidth = 2.5;
    for (double y = 4; y < size.height - 4; y += 14) {
      canvas.drawLine(
        Offset(centroDivisoria.dx, y),
        Offset(centroDivisoria.dx, y + 8),
        pincelDivisoria,
      );
    }

    final pulsoSello = math.sin(fase * math.pi * 2) * 0.5 + 0.5;
    _pintarSelloDecorativo(
      canvas,
      Offset(ladoCelda * 1, size.height * 0.5),
      ladoCelda * 0.55,
      pulsoSello,
      false,
    );
    _pintarSelloDecorativo(
      canvas,
      Offset(ladoCelda * (columnas - 1), size.height * 0.5),
      ladoCelda * 0.55,
      pulsoSello,
      true,
    );
  }

  void _pintarSelloDecorativo(
    Canvas canvas,
    Offset centro,
    double radio,
    double pulso,
    bool esEnemigo,
  ) {
    final color = esEnemigo
        ? PaletaCosmoSovietica.tintaNegra
        : PaletaCosmoSovietica.rojoOficial;

    final pincelCirculo = Paint()
      ..color = color.withValues(alpha: 0.06 + pulso * 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(centro, radio, pincelCirculo);
    canvas.drawCircle(centro, radio * 0.7, pincelCirculo);

    final puntos = 5;
    final pathEstrella = Path();
    final radioEstrella = radio * 0.42;
    for (int indice = 0; indice < puntos * 2; indice++) {
      final esExterior = indice % 2 == 0;
      final radioActual = esExterior ? radioEstrella : radioEstrella * 0.45;
      final angulo = -math.pi / 2 + indice * math.pi / puntos;
      final x = centro.dx + math.cos(angulo) * radioActual;
      final y = centro.dy + math.sin(angulo) * radioActual;
      if (indice == 0) {
        pathEstrella.moveTo(x, y);
      } else {
        pathEstrella.lineTo(x, y);
      }
    }
    pathEstrella.close();
    canvas.drawPath(
      pathEstrella,
      Paint()..color = color.withValues(alpha: 0.07 + pulso * 0.05),
    );
  }

  @override
  bool shouldRepaint(covariant PintorSueloTablero viejo) =>
      viejo.columnas != columnas ||
      viejo.filas != filas ||
      viejo.fase != fase ||
      viejo.columnasJugador != columnasJugador;
}

class SombraPeon extends StatelessWidget {
  final double ancho;
  final double opacidad;

  const SombraPeon({super.key, required this.ancho, this.opacidad = 0.22});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ancho,
      height: ancho * 0.18,
      decoration: BoxDecoration(
        color: PaletaCosmoSovietica.tintaNegra.withValues(alpha: opacidad),
        borderRadius: BorderRadius.all(Radius.circular(ancho)),
      ),
    );
  }
}
