import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

/// Identifica el tipo de partícula ambiental a renderizar sobre el fondo
/// de un escenario libre. Cada valor mapea a una paleta, una curva de
/// movimiento y un comportamiento de ciclo que evoca el clima del planeta.
enum TipoAmbiente {
  /// Ceniza volcánica de Zovnak-4: motas oscuras que ascienden derivando.
  cenizaVolcanica,

  /// Copos de Gélida-9: nieve blanca cayendo con balanceo lento.
  nieveCristalina,

  /// Sol Camarada: motas doradas que suben con tirones eléctricos.
  motasSolares,

  /// Pravda-7: humo fantasmagórico que repta horizontalmente.
  humoFantasmal,

  /// Pravda-12 (estación): motas de papel viejo flotando despacio.
  motasArchivo,
}

class _DescriptorParticulaAmbiental {
  final double xRelativaInicial;
  final double yRelativaInicial;
  final double velocidadHorizontalBase;
  final double velocidadVerticalBase;
  final double amplitudOscilacionLateral;
  final double frecuenciaOscilacion;
  final double tamano;
  final double desfaseCiclo;
  final Color tinte;
  final double alphaMaximo;

  _DescriptorParticulaAmbiental({
    required this.xRelativaInicial,
    required this.yRelativaInicial,
    required this.velocidadHorizontalBase,
    required this.velocidadVerticalBase,
    required this.amplitudOscilacionLateral,
    required this.frecuenciaOscilacion,
    required this.tamano,
    required this.desfaseCiclo,
    required this.tinte,
    required this.alphaMaximo,
  });
}

class CapaParticulasAmbientales extends StatefulWidget {
  final TipoAmbiente tipoAmbiente;
  final int cantidadParticulas;

  const CapaParticulasAmbientales({
    super.key,
    required this.tipoAmbiente,
    this.cantidadParticulas = 48,
  });

  @override
  State<CapaParticulasAmbientales> createState() =>
      _CapaParticulasAmbientalesState();
}

class _CapaParticulasAmbientalesState extends State<CapaParticulasAmbientales>
    with SingleTickerProviderStateMixin {
  late final AnimationController controladorCiclo;
  late List<_DescriptorParticulaAmbiental> particulas;

  @override
  void initState() {
    super.initState();
    controladorCiclo = AnimationController(
      vsync: this,
      duration: _duracionCicloSegunAmbiente(widget.tipoAmbiente),
    )..repeat();
    particulas = _generarParticulasParaAmbiente(
      widget.tipoAmbiente,
      widget.cantidadParticulas,
    );
  }

  @override
  void didUpdateWidget(covariant CapaParticulasAmbientales viejo) {
    super.didUpdateWidget(viejo);
    if (viejo.tipoAmbiente != widget.tipoAmbiente ||
        viejo.cantidadParticulas != widget.cantidadParticulas) {
      controladorCiclo.duration =
          _duracionCicloSegunAmbiente(widget.tipoAmbiente);
      particulas = _generarParticulasParaAmbiente(
        widget.tipoAmbiente,
        widget.cantidadParticulas,
      );
    }
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
            painter: _PintorParticulasAmbientales(
              tipoAmbiente: widget.tipoAmbiente,
              progresoCiclo: controladorCiclo.value,
              particulas: particulas,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

Duration _duracionCicloSegunAmbiente(TipoAmbiente tipo) {
  switch (tipo) {
    case TipoAmbiente.cenizaVolcanica:
      return const Duration(seconds: 9);
    case TipoAmbiente.nieveCristalina:
      return const Duration(seconds: 14);
    case TipoAmbiente.motasSolares:
      return const Duration(seconds: 11);
    case TipoAmbiente.humoFantasmal:
      return const Duration(seconds: 18);
    case TipoAmbiente.motasArchivo:
      return const Duration(seconds: 20);
  }
}

List<_DescriptorParticulaAmbiental> _generarParticulasParaAmbiente(
  TipoAmbiente tipo,
  int cantidad,
) {
  final aleatorio = math.Random(tipo.index * 11 + 3);
  return List.generate(cantidad, (indice) {
    switch (tipo) {
      case TipoAmbiente.cenizaVolcanica:
        return _DescriptorParticulaAmbiental(
          xRelativaInicial: aleatorio.nextDouble(),
          yRelativaInicial: 0.95 + aleatorio.nextDouble() * 0.1,
          velocidadHorizontalBase:
              (aleatorio.nextDouble() - 0.5) * 0.04,
          velocidadVerticalBase: -0.18 - aleatorio.nextDouble() * 0.14,
          amplitudOscilacionLateral: 0.02 + aleatorio.nextDouble() * 0.04,
          frecuenciaOscilacion: 0.8 + aleatorio.nextDouble() * 1.2,
          tamano: 1.4 + aleatorio.nextDouble() * 2.8,
          desfaseCiclo: aleatorio.nextDouble(),
          tinte: aleatorio.nextDouble() < 0.15
              ? PaletaCosmoSovietica.rojoOficial
              : PaletaCosmoSovietica.tintaNegra,
          alphaMaximo: 0.45 + aleatorio.nextDouble() * 0.3,
        );
      case TipoAmbiente.nieveCristalina:
        return _DescriptorParticulaAmbiental(
          xRelativaInicial: aleatorio.nextDouble(),
          yRelativaInicial: -0.05 - aleatorio.nextDouble() * 0.1,
          velocidadHorizontalBase:
              (aleatorio.nextDouble() - 0.5) * 0.03,
          velocidadVerticalBase: 0.14 + aleatorio.nextDouble() * 0.1,
          amplitudOscilacionLateral: 0.025 + aleatorio.nextDouble() * 0.045,
          frecuenciaOscilacion: 0.3 + aleatorio.nextDouble() * 0.6,
          tamano: 1.8 + aleatorio.nextDouble() * 3.0,
          desfaseCiclo: aleatorio.nextDouble(),
          tinte: PaletaCosmoSovietica.papelViejo,
          alphaMaximo: 0.7 + aleatorio.nextDouble() * 0.25,
        );
      case TipoAmbiente.motasSolares:
        return _DescriptorParticulaAmbiental(
          xRelativaInicial: aleatorio.nextDouble(),
          yRelativaInicial: 0.95 + aleatorio.nextDouble() * 0.1,
          velocidadHorizontalBase:
              (aleatorio.nextDouble() - 0.5) * 0.05,
          velocidadVerticalBase: -0.22 - aleatorio.nextDouble() * 0.18,
          amplitudOscilacionLateral: 0.015 + aleatorio.nextDouble() * 0.035,
          frecuenciaOscilacion: 1.4 + aleatorio.nextDouble() * 1.6,
          tamano: 1.2 + aleatorio.nextDouble() * 2.2,
          desfaseCiclo: aleatorio.nextDouble(),
          tinte: aleatorio.nextDouble() < 0.35
              ? const Color(0xFFE6B400)
              : PaletaCosmoSovietica.rojoOficial,
          alphaMaximo: 0.55 + aleatorio.nextDouble() * 0.35,
        );
      case TipoAmbiente.humoFantasmal:
        return _DescriptorParticulaAmbiental(
          xRelativaInicial: aleatorio.nextDouble(),
          yRelativaInicial: 0.3 + aleatorio.nextDouble() * 0.6,
          velocidadHorizontalBase: 0.06 + aleatorio.nextDouble() * 0.1,
          velocidadVerticalBase: -0.03 - aleatorio.nextDouble() * 0.05,
          amplitudOscilacionLateral: 0.015 + aleatorio.nextDouble() * 0.025,
          frecuenciaOscilacion: 0.5 + aleatorio.nextDouble() * 0.7,
          tamano: 3.0 + aleatorio.nextDouble() * 5.0,
          desfaseCiclo: aleatorio.nextDouble(),
          tinte: const Color(0xFFB7C4D6),
          alphaMaximo: 0.18 + aleatorio.nextDouble() * 0.2,
        );
      case TipoAmbiente.motasArchivo:
        return _DescriptorParticulaAmbiental(
          xRelativaInicial: aleatorio.nextDouble(),
          yRelativaInicial: aleatorio.nextDouble(),
          velocidadHorizontalBase:
              (aleatorio.nextDouble() - 0.5) * 0.025,
          velocidadVerticalBase: -0.015 - aleatorio.nextDouble() * 0.03,
          amplitudOscilacionLateral: 0.02 + aleatorio.nextDouble() * 0.03,
          frecuenciaOscilacion: 0.25 + aleatorio.nextDouble() * 0.5,
          tamano: 1.0 + aleatorio.nextDouble() * 1.6,
          desfaseCiclo: aleatorio.nextDouble(),
          tinte: PaletaCosmoSovietica.tintaTenue,
          alphaMaximo: 0.32 + aleatorio.nextDouble() * 0.28,
        );
    }
  });
}

class _PintorParticulasAmbientales extends CustomPainter {
  final TipoAmbiente tipoAmbiente;
  final double progresoCiclo;
  final List<_DescriptorParticulaAmbiental> particulas;

  _PintorParticulasAmbientales({
    required this.tipoAmbiente,
    required this.progresoCiclo,
    required this.particulas,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particulaActual in particulas) {
      final faseLocal = (progresoCiclo + particulaActual.desfaseCiclo) % 1.0;
      final desplazamientoVertical =
          particulaActual.velocidadVerticalBase * faseLocal;
      final desplazamientoHorizontal =
          particulaActual.velocidadHorizontalBase * faseLocal +
              math.sin(faseLocal * math.pi * 2 *
                      particulaActual.frecuenciaOscilacion) *
                  particulaActual.amplitudOscilacionLateral;

      final xRelativa =
          particulaActual.xRelativaInicial + desplazamientoHorizontal;
      final yRelativa =
          particulaActual.yRelativaInicial + desplazamientoVertical;

      if (xRelativa < -0.05 || xRelativa > 1.05) continue;
      if (yRelativa < -0.05 || yRelativa > 1.05) continue;

      final alphaCurva = _curvaAlphaCiclo(faseLocal) *
          particulaActual.alphaMaximo;
      if (alphaCurva <= 0.01) continue;

      final pincel = Paint()
        ..color = particulaActual.tinte.withValues(alpha: alphaCurva);
      final centro =
          Offset(xRelativa * size.width, yRelativa * size.height);

      switch (tipoAmbiente) {
        case TipoAmbiente.cenizaVolcanica:
        case TipoAmbiente.motasArchivo:
          canvas.drawCircle(centro, particulaActual.tamano * 0.5, pincel);
          break;
        case TipoAmbiente.nieveCristalina:
          _pintarCopoNieve(canvas, centro, particulaActual.tamano, pincel);
          break;
        case TipoAmbiente.motasSolares:
          _pintarChispaSolar(
              canvas, centro, particulaActual.tamano, pincel);
          break;
        case TipoAmbiente.humoFantasmal:
          _pintarManchaHumo(
              canvas, centro, particulaActual.tamano, pincel, faseLocal);
          break;
      }
    }
  }

  double _curvaAlphaCiclo(double t) {
    if (t < 0.15) return t / 0.15;
    if (t > 0.85) return (1.0 - t) / 0.15;
    return 1.0;
  }

  void _pintarCopoNieve(
      Canvas canvas, Offset centro, double tamano, Paint pincel) {
    final radio = tamano * 0.6;
    canvas.drawCircle(centro, radio, pincel);
    final pincelBordeOscuro = Paint()
      ..color = PaletaCosmoSovietica.tintaTenue
          .withValues(alpha: pincel.color.a * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    canvas.drawCircle(centro, radio, pincelBordeOscuro);
  }

  void _pintarChispaSolar(
      Canvas canvas, Offset centro, double tamano, Paint pincel) {
    final radioBase = tamano * 0.5;
    canvas.drawCircle(centro, radioBase, pincel);
    final pincelHalo = Paint()
      ..color = pincel.color.withValues(alpha: pincel.color.a * 0.35);
    canvas.drawCircle(centro, radioBase * 2.2, pincelHalo);
  }

  void _pintarManchaHumo(Canvas canvas, Offset centro, double tamano,
      Paint pincel, double fase) {
    final radioPrincipal = tamano * 0.9 + math.sin(fase * math.pi * 2) * 0.6;
    canvas.drawCircle(centro, radioPrincipal, pincel);
    canvas.drawCircle(
      centro.translate(radioPrincipal * 0.45, -radioPrincipal * 0.2),
      radioPrincipal * 0.7,
      Paint()
        ..color = pincel.color.withValues(alpha: pincel.color.a * 0.6),
    );
  }

  @override
  bool shouldRepaint(covariant _PintorParticulasAmbientales viejo) =>
      viejo.progresoCiclo != progresoCiclo ||
      viejo.tipoAmbiente != tipoAmbiente;
}
