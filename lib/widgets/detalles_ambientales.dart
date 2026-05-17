import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

/// Tipos de detalle decorativo esparcibles por los escenarios.
enum TipoDetalleAmbiental {
  /// Hoja de papel arrugada con esquinas dobladas.
  papelArrugado,
  /// Sello rojo redondo con borde y estrella.
  selloRojoSuelto,
  /// Mancha de tinta irregular.
  manchaTinta,
  /// Colilla apagada con ceniza tenue.
  colillaCigarro,
  /// Taza pequeña tumbada con marca circular debajo.
  tazaCaida,
  /// Clip-presilla metálica.
  clipMetalico,
}

/// Sistema reutilizable de "detalles ambientales": esparce N pequeños
/// objetos decorativos (papeles, sellos, manchas, colillas) por el
/// escenario de forma determinista a partir de una semilla, así cada
/// escenario tiene su propio conjunto pero es estable entre frames.
///
/// Se monta como `Positioned.fill` dentro del Stack del escenario,
/// debajo del peón y los hotspots. No es interactivo.
class CapaDetallesAmbientales extends StatelessWidget {
  /// Semilla del generador determinista. Cambia esto entre escenarios
  /// para que cada uno tenga su propia disposición.
  final int semilla;

  /// Cuántos detalles esparcir. Más = más recargado.
  final int cantidadDetalles;

  /// Mezcla de tipos permitidos. Si está vacío, usa todos.
  final List<TipoDetalleAmbiental> tiposPermitidos;

  /// Banda vertical donde se acepta colocar detalles. Por defecto
  /// la mitad inferior (suelo). [0..1] en coordenadas relativas.
  final double yMinimoRelativo;
  final double yMaximoRelativo;

  const CapaDetallesAmbientales({
    super.key,
    required this.semilla,
    this.cantidadDetalles = 24,
    this.tiposPermitidos = const <TipoDetalleAmbiental>[],
    this.yMinimoRelativo = 0.62,
    this.yMaximoRelativo = 0.95,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PintorCapaDetallesAmbientales(
        semilla: semilla,
        cantidadDetalles: cantidadDetalles,
        tiposPermitidos: tiposPermitidos.isEmpty
            ? TipoDetalleAmbiental.values
            : tiposPermitidos,
        yMinimoRelativo: yMinimoRelativo,
        yMaximoRelativo: yMaximoRelativo,
      ),
    );
  }
}

class _PintorCapaDetallesAmbientales extends CustomPainter {
  final int semilla;
  final int cantidadDetalles;
  final List<TipoDetalleAmbiental> tiposPermitidos;
  final double yMinimoRelativo;
  final double yMaximoRelativo;

  _PintorCapaDetallesAmbientales({
    required this.semilla,
    required this.cantidadDetalles,
    required this.tiposPermitidos,
    required this.yMinimoRelativo,
    required this.yMaximoRelativo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final math.Random rng = math.Random(semilla);
    for (int indiceDetalle = 0;
        indiceDetalle < cantidadDetalles;
        indiceDetalle++) {
      final double xRel = rng.nextDouble();
      final double yRel = yMinimoRelativo +
          rng.nextDouble() * (yMaximoRelativo - yMinimoRelativo);
      final double centroX = xRel * size.width;
      final double centroY = yRel * size.height;
      final TipoDetalleAmbiental tipo =
          tiposPermitidos[rng.nextInt(tiposPermitidos.length)];
      final double rotacion = (rng.nextDouble() - 0.5) * math.pi;
      // Tamaño reducido: 0.005..0.011 del ancho (≈ 10-21px en 1920p),
      // antes era 0.012..0.032 (23-61px), demasiado grande.
      final double tamanoBase = size.width * (0.005 + rng.nextDouble() * 0.006);
      canvas.save();
      canvas.translate(centroX, centroY);
      canvas.rotate(rotacion);
      switch (tipo) {
        case TipoDetalleAmbiental.papelArrugado:
          _pintarPapel(canvas, tamanoBase, rng);
          break;
        case TipoDetalleAmbiental.selloRojoSuelto:
          _pintarSello(canvas, tamanoBase);
          break;
        case TipoDetalleAmbiental.manchaTinta:
          _pintarManchaTinta(canvas, tamanoBase, rng);
          break;
        case TipoDetalleAmbiental.colillaCigarro:
          _pintarColilla(canvas, tamanoBase);
          break;
        case TipoDetalleAmbiental.tazaCaida:
          _pintarTaza(canvas, tamanoBase);
          break;
        case TipoDetalleAmbiental.clipMetalico:
          _pintarClip(canvas, tamanoBase);
          break;
      }
      canvas.restore();
    }
  }

  void _pintarPapel(Canvas canvas, double tamano, math.Random rng) {
    final double ancho = tamano * 2.4;
    final double alto = tamano * 1.6;
    final Path camino = Path()
      ..moveTo(-ancho * 0.5, -alto * 0.5 + rng.nextDouble() * 1.5)
      ..lineTo(ancho * 0.45, -alto * 0.4)
      ..lineTo(ancho * 0.50, alto * 0.5)
      ..lineTo(-ancho * 0.4, alto * 0.45)
      ..close();
    canvas.drawPath(
      camino,
      Paint()..color = PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.85),
    );
    canvas.drawPath(
      camino,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );
    // Tres líneas de "texto".
    for (int indiceLinea = 0; indiceLinea < 3; indiceLinea++) {
      canvas.drawLine(
        Offset(-ancho * 0.35, -alto * 0.20 + indiceLinea * alto * 0.20),
        Offset(ancho * 0.30, -alto * 0.20 + indiceLinea * alto * 0.20),
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.45)
          ..strokeWidth = 0.6,
      );
    }
  }

  void _pintarSello(Canvas canvas, double tamano) {
    final double radio = tamano * 1.1;
    canvas.drawCircle(
      Offset.zero,
      radio,
      Paint()
        ..color = PaletaCosmoSovietica.rojoOficial.withValues(alpha: 0.30)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset.zero,
      radio,
      Paint()
        ..color = PaletaCosmoSovietica.rojoOficial.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Estrella central.
    final Path estrella = Path();
    for (int indicePunta = 0; indicePunta < 10; indicePunta++) {
      final bool exterior = indicePunta.isEven;
      final double r = exterior ? radio * 0.55 : radio * 0.22;
      final double angulo = -math.pi / 2 + indicePunta * math.pi / 5;
      final double x = math.cos(angulo) * r;
      final double y = math.sin(angulo) * r;
      if (indicePunta == 0) {
        estrella.moveTo(x, y);
      } else {
        estrella.lineTo(x, y);
      }
    }
    estrella.close();
    canvas.drawPath(
      estrella,
      Paint()..color = PaletaCosmoSovietica.rojoOficial.withValues(alpha: 0.85),
    );
  }

  void _pintarManchaTinta(Canvas canvas, double tamano, math.Random rng) {
    final int numPuntos = 6 + rng.nextInt(4);
    final Path mancha = Path();
    for (int indicePunto = 0; indicePunto < numPuntos; indicePunto++) {
      final double angulo = indicePunto * math.pi * 2 / numPuntos;
      final double radio =
          tamano * (0.5 + rng.nextDouble() * 0.4);
      final double x = math.cos(angulo) * radio;
      final double y = math.sin(angulo) * radio;
      if (indicePunto == 0) {
        mancha.moveTo(x, y);
      } else {
        mancha.lineTo(x, y);
      }
    }
    mancha.close();
    canvas.drawPath(
      mancha,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.22),
    );
    // Pequeñas salpicaduras alrededor.
    for (int indiceSalpicadura = 0;
        indiceSalpicadura < 3;
        indiceSalpicadura++) {
      final double angulo = rng.nextDouble() * math.pi * 2;
      final double distancia = tamano * (1.5 + rng.nextDouble());
      canvas.drawCircle(
        Offset(math.cos(angulo) * distancia,
            math.sin(angulo) * distancia),
        tamano * 0.12,
        Paint()
          ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.35),
      );
    }
  }

  void _pintarColilla(Canvas canvas, double tamano) {
    // Cuerpo del cigarrillo.
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset.zero, width: tamano * 1.8, height: tamano * 0.45),
      Paint()..color = PaletaCosmoSovietica.papelViejo,
    );
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset.zero, width: tamano * 1.8, height: tamano * 0.45),
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );
    // Filtro (amarillo-papel oscuro, lo dejamos tinta diluida).
    canvas.drawRect(
      Rect.fromLTWH(
          tamano * 0.4, -tamano * 0.22, tamano * 0.5, tamano * 0.44),
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.55),
    );
    // Ceniza.
    canvas.drawCircle(
      Offset(-tamano * 0.9, 0),
      tamano * 0.18,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.7),
    );
  }

  void _pintarTaza(Canvas canvas, double tamano) {
    // Marca circular del culo de la taza en el suelo.
    canvas.drawCircle(
      Offset.zero,
      tamano * 1.5,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.15),
    );
    canvas.drawCircle(
      Offset.zero,
      tamano * 1.5,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    // Taza tumbada (óvalo).
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(-tamano * 0.2, -tamano * 0.4),
          width: tamano * 1.4,
          height: tamano * 0.7),
      Paint()..color = PaletaCosmoSovietica.papelViejo,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(-tamano * 0.2, -tamano * 0.4),
          width: tamano * 1.4,
          height: tamano * 0.7),
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    // Asa.
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(-tamano * 0.95, -tamano * 0.4),
          width: tamano * 0.5,
          height: tamano * 0.5),
      math.pi * 1.5,
      math.pi,
      false,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  void _pintarClip(Canvas canvas, double tamano) {
    final Paint pincelClip = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    // Curva exterior + curva interna del clip.
    final Path camino = Path()
      ..moveTo(-tamano, -tamano * 0.5)
      ..lineTo(tamano * 0.9, -tamano * 0.5)
      ..arcToPoint(
        Offset(tamano * 0.9, tamano * 0.5),
        radius: Radius.circular(tamano * 0.5),
        clockwise: true,
      )
      ..lineTo(-tamano * 0.7, tamano * 0.5)
      ..lineTo(-tamano * 0.7, -tamano * 0.25)
      ..lineTo(tamano * 0.6, -tamano * 0.25);
    canvas.drawPath(camino, pincelClip);
  }

  @override
  bool shouldRepaint(covariant _PintorCapaDetallesAmbientales viejo) =>
      viejo.semilla != semilla ||
      viejo.cantidadDetalles != cantidadDetalles;
}
