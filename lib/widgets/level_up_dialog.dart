import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../theme.dart';
import 'propaganda_button.dart';

enum _RamaSubidaNivel { cuerpo, mente, carisma }

Future<void> mostrarDialogoSubidaNivel(
  BuildContext contextoLlamante, {
  required EstadoJuego estado,
}) async {
  while (estado.puedeSubirDeNivel()) {
    final rutaElegida = await showDialog<_RamaSubidaNivel>(
      context: contextoLlamante,
      barrierDismissible: false,
      builder: (_) => _DialogoSubidaNivel(estado: estado),
    );
    if (rutaElegida == null) break;
    estado.consumirXpParaSubirNivel();
    switch (rutaElegida) {
      case _RamaSubidaNivel.cuerpo:
        estado.personaje.cuerpo += 1;
        estado.personaje.puntosVidaMaximos += 3;
        estado.personaje.puntosVida =
            estado.personaje.puntosVidaMaximos;
        break;
      case _RamaSubidaNivel.mente:
        estado.personaje.mente += 1;
        estado.personaje.puntosVidaMaximos += 1;
        estado.personaje.puntosVida =
            estado.personaje.puntosVidaMaximos;
        break;
      case _RamaSubidaNivel.carisma:
        estado.personaje.carisma += 1;
        estado.personaje.moralMaxima += 3;
        estado.personaje.moral = estado.personaje.moralMaxima;
        break;
    }
  }
}

class _DialogoSubidaNivel extends StatefulWidget {
  final EstadoJuego estado;

  const _DialogoSubidaNivel({required this.estado});

  @override
  State<_DialogoSubidaNivel> createState() => _DialogoSubidaNivelState();
}

class _DialogoSubidaNivelState extends State<_DialogoSubidaNivel>
    with TickerProviderStateMixin {
  late final AnimationController controladorCelebracion;
  late final AnimationController controladorSello;

  @override
  void initState() {
    super.initState();
    controladorCelebracion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    controladorSello = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) controladorSello.forward();
    });
  }

  @override
  void dispose() {
    controladorCelebracion.dispose();
    controladorSello.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nivelObjetivo = widget.estado.nivelCadete + 1;
    return Dialog(
      backgroundColor: PaletaCosmoSovietica.papelViejo,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(
          color: PaletaCosmoSovietica.rojoOficial,
          width: 3,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _construirCabeceraCelebracion(nivelObjetivo),
              const SizedBox(height: 18),
              _TarjetaItinerario(
                titulo: 'ITINERARIO CUERPO',
                resumen:
                    'Gimnasia obligatoria al amanecer. +1 Cuerpo, +3 PV máximos.',
                onSeleccionar: () =>
                    Navigator.of(context).pop(_RamaSubidaNivel.cuerpo),
              ),
              const SizedBox(height: 8),
              _TarjetaItinerario(
                titulo: 'ITINERARIO MENTE',
                resumen:
                    'Lectura de manuales con cinco precintos. +1 Mente, +1 PV máximo. (Recordatorio: PA inicial en combate sube con Mente.)',
                onSeleccionar: () =>
                    Navigator.of(context).pop(_RamaSubidaNivel.mente),
              ),
              const SizedBox(height: 8),
              _TarjetaItinerario(
                titulo: 'ITINERARIO CARISMA',
                resumen:
                    'Tutorías retóricas con un retrato del Premier. +1 Carisma, +3 Moral máxima.',
                onSeleccionar: () =>
                    Navigator.of(context).pop(_RamaSubidaNivel.carisma),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirCabeceraCelebracion(int nivelObjetivo) {
    return SizedBox(
      height: 170,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: controladorCelebracion,
              builder: (contexto, _) => CustomPaint(
                painter: _PintorFiestaPromocion(
                  faseCelebracion: controladorCelebracion.value,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: AnimatedBuilder(
                animation: controladorCelebracion,
                builder: (contexto, _) {
                  final balanceo = math.sin(
                          controladorCelebracion.value * math.pi * 2) *
                      0.05;
                  return Transform.rotate(
                    angle: balanceo,
                    child: CustomPaint(
                      size: const Size(120, 150),
                      painter: _PintorMedallaSoviet(
                        faseCelebracion:
                            controladorCelebracion.value,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 0,
            child: AnimatedBuilder(
              animation: controladorSello,
              builder: (contexto, _) {
                final t = controladorSello.value;
                if (t == 0) return const SizedBox.shrink();
                final escala = t < 0.5
                    ? 2.2 - 1.2 * (t / 0.5)
                    : 1.0;
                final opacidad = t < 0.15
                    ? t / 0.15
                    : 1.0;
                return Transform.rotate(
                  angle: -0.18,
                  child: Transform.scale(
                    scale: escala,
                    child: Opacity(
                      opacity: opacidad,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: PaletaCosmoSovietica.papelViejo,
                          border: Border.all(
                            color: PaletaCosmoSovietica.rojoOficial,
                            width: 2.2,
                          ),
                        ),
                        child: Text(
                          'ASCENDIDO',
                          style: const TextStyle(
                            fontFamily:
                                TipografiaPropaganda.familiaPrincipal,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: PaletaCosmoSovietica.rojoOficial,
                            letterSpacing: 2.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXPEDIENTE PROMOCIONAL · NIVEL $nivelObjetivo',
                  style: TipografiaPropaganda.etiquetaBurocratica.copyWith(
                    color: PaletaCosmoSovietica.rojoOficial,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'El Comité ha aprobado su promoción.',
                  style: TipografiaPropaganda.tituloSeccion,
                ),
                const SizedBox(height: 2),
                const Text(
                  'Elija el itinerario de superación personal. La decisión es vinculante.',
                  style: TipografiaPropaganda.subtitulo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaItinerario extends StatelessWidget {
  final String titulo;
  final String resumen;
  final VoidCallback onSeleccionar;

  const _TarjetaItinerario({
    required this.titulo,
    required this.resumen,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSeleccionar,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: PaletaCosmoSovietica.papelViejo,
            border: Border.all(
              color: PaletaCosmoSovietica.tintaNegra,
              width: 1.8,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo,
                        style: TipografiaPropaganda.etiquetaBurocratica),
                    const SizedBox(height: 4),
                    Text(resumen,
                        style: TipografiaPropaganda.cuerpoLargo
                            .copyWith(fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              BotonPropaganda(
                texto: 'Elegir',
                compacto: true,
                onPressed: onSeleccionar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fondo de la cabecera: líneas radiales rojas detrás de la medalla + confeti
/// de papel viejo cayendo. Crea sensación de "anuncio oficial con pompa".
class _PintorFiestaPromocion extends CustomPainter {
  final double faseCelebracion;

  _PintorFiestaPromocion({required this.faseCelebracion});

  @override
  void paint(Canvas canvas, Size size) {
    final centroExpediente = Offset(size.width / 2, size.height * 0.5);

    // Rayos radiales rotantes detrás de la medalla.
    const cantidadRayos = 14;
    final pincelRayo = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial.withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;
    final radioInternoRayos = size.height * 0.25;
    final radioExternoRayos = size.height * 0.85;
    for (int indiceRayo = 0; indiceRayo < cantidadRayos; indiceRayo++) {
      final fragmentoAngular = indiceRayo / cantidadRayos;
      final anguloRayo =
          fragmentoAngular * math.pi * 2 + faseCelebracion * 0.6;
      final anchoRayo = 0.10;
      final puntoIzq = Offset(
        centroExpediente.dx +
            math.cos(anguloRayo - anchoRayo) * radioExternoRayos,
        centroExpediente.dy +
            math.sin(anguloRayo - anchoRayo) * radioExternoRayos,
      );
      final puntoDer = Offset(
        centroExpediente.dx +
            math.cos(anguloRayo + anchoRayo) * radioExternoRayos,
        centroExpediente.dy +
            math.sin(anguloRayo + anchoRayo) * radioExternoRayos,
      );
      final puntoBaseIzq = Offset(
        centroExpediente.dx +
            math.cos(anguloRayo - anchoRayo * 0.4) * radioInternoRayos,
        centroExpediente.dy +
            math.sin(anguloRayo - anchoRayo * 0.4) * radioInternoRayos,
      );
      final puntoBaseDer = Offset(
        centroExpediente.dx +
            math.cos(anguloRayo + anchoRayo * 0.4) * radioInternoRayos,
        centroExpediente.dy +
            math.sin(anguloRayo + anchoRayo * 0.4) * radioInternoRayos,
      );
      final caminoRayo = Path()
        ..moveTo(puntoBaseIzq.dx, puntoBaseIzq.dy)
        ..lineTo(puntoIzq.dx, puntoIzq.dy)
        ..lineTo(puntoDer.dx, puntoDer.dy)
        ..lineTo(puntoBaseDer.dx, puntoBaseDer.dy)
        ..close();
      canvas.drawPath(caminoRayo, pincelRayo);
    }

    // Confeti: rectángulos rojo/papel cayendo desde arriba.
    final aleatorioConfeti = math.Random(31);
    const cantidadConfeti = 28;
    for (int indiceConfeti = 0;
        indiceConfeti < cantidadConfeti;
        indiceConfeti++) {
      final desfaseConfeti = aleatorioConfeti.nextDouble();
      final faseConfeti = (faseCelebracion + desfaseConfeti) % 1.0;
      final xConfeti =
          (aleatorioConfeti.nextDouble() + faseConfeti * 0.08) * size.width;
      final yConfeti = faseConfeti * size.height * 1.2 - size.height * 0.1;
      if (yConfeti < -10 || yConfeti > size.height + 10) continue;
      final esRojo = aleatorioConfeti.nextDouble() < 0.55;
      final colorConfeti = esRojo
          ? PaletaCosmoSovietica.rojoOficial
          : PaletaCosmoSovietica.tintaNegra;
      final rotacionConfeti =
          faseConfeti * math.pi * 8 + indiceConfeti.toDouble();
      canvas.save();
      canvas.translate(xConfeti, yConfeti);
      canvas.rotate(rotacionConfeti);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: 5 + aleatorioConfeti.nextDouble() * 5,
          height: 2 + aleatorioConfeti.nextDouble() * 2.5,
        ),
        Paint()
          ..color = colorConfeti.withValues(
              alpha: 0.5 + aleatorioConfeti.nextDouble() * 0.4),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PintorFiestaPromocion viejo) =>
      viejo.faseCelebracion != faseCelebracion;
}

/// Medalla colgada de una cinta roja con dos colas, disco metálico con
/// estrella central y leve halo pulsante.
class _PintorMedallaSoviet extends CustomPainter {
  final double faseCelebracion;

  _PintorMedallaSoviet({required this.faseCelebracion});

  @override
  void paint(Canvas canvas, Size size) {
    final centroMedalla = Offset(size.width / 2, size.height * 0.62);
    final radioDisco = size.width * 0.32;
    final pulso = math.sin(faseCelebracion * math.pi * 2);

    // Halo trasero pulsante.
    final pincelHalo = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial
          .withValues(alpha: 0.18 + (pulso * 0.5 + 0.5) * 0.18);
    canvas.drawCircle(centroMedalla, radioDisco * 2.0, pincelHalo);

    // Cinta superior: dos triángulos rojos que cuelgan del borde superior
    // hasta el disco.
    final anchoCinta = radioDisco * 1.05;
    final puntoCintaArribaIzq = Offset(
      centroMedalla.dx - anchoCinta * 0.6,
      size.height * 0.04,
    );
    final puntoCintaArribaDer = Offset(
      centroMedalla.dx + anchoCinta * 0.6,
      size.height * 0.04,
    );
    final puntoCintaAbajoIzq = Offset(
      centroMedalla.dx - radioDisco * 0.45,
      centroMedalla.dy - radioDisco * 0.85,
    );
    final puntoCintaAbajoDer = Offset(
      centroMedalla.dx + radioDisco * 0.45,
      centroMedalla.dy - radioDisco * 0.85,
    );
    final caminoCintaIzq = Path()
      ..moveTo(puntoCintaArribaIzq.dx, puntoCintaArribaIzq.dy)
      ..lineTo(centroMedalla.dx, puntoCintaArribaIzq.dy + 4)
      ..lineTo(puntoCintaAbajoDer.dx, puntoCintaAbajoDer.dy)
      ..lineTo(puntoCintaAbajoIzq.dx, puntoCintaAbajoIzq.dy)
      ..close();
    final caminoCintaDer = Path()
      ..moveTo(puntoCintaArribaDer.dx, puntoCintaArribaDer.dy)
      ..lineTo(centroMedalla.dx, puntoCintaArribaDer.dy + 4)
      ..lineTo(puntoCintaAbajoIzq.dx, puntoCintaAbajoIzq.dy)
      ..lineTo(puntoCintaAbajoDer.dx, puntoCintaAbajoDer.dy)
      ..close();
    final pincelCintaRoja = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial;
    final pincelCintaSombra = Paint()
      ..color = PaletaCosmoSovietica.rojoSombra.withValues(alpha: 0.9);
    canvas.drawPath(caminoCintaIzq, pincelCintaSombra);
    canvas.drawPath(caminoCintaDer, pincelCintaRoja);
    canvas.drawPath(
      caminoCintaIzq,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      caminoCintaDer,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );

    // Disco principal de la medalla.
    final pincelDisco = Paint()
      ..shader = RadialGradient(
        colors: const [
          Color(0xFFE3B644),
          Color(0xFF8E6817),
        ],
      ).createShader(
          Rect.fromCircle(center: centroMedalla, radius: radioDisco));
    canvas.drawCircle(centroMedalla, radioDisco, pincelDisco);
    canvas.drawCircle(
      centroMedalla,
      radioDisco,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(
      centroMedalla,
      radioDisco * 0.78,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.4)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );

    // Estrella central roja con leve rotación.
    const cantidadPuntasEstrella = 5;
    final radioEstrellaCentral = radioDisco * 0.55;
    final anguloRotacionEstrella = faseCelebracion * math.pi * 0.4;
    final caminoEstrella = Path();
    for (int indicePunta = 0;
        indicePunta < cantidadPuntasEstrella * 2;
        indicePunta++) {
      final esExterior = indicePunta % 2 == 0;
      final radioPunto = esExterior
          ? radioEstrellaCentral
          : radioEstrellaCentral * 0.45;
      final anguloPunto = -math.pi / 2 +
          indicePunta * math.pi / cantidadPuntasEstrella +
          anguloRotacionEstrella;
      final x = centroMedalla.dx + math.cos(anguloPunto) * radioPunto;
      final y = centroMedalla.dy + math.sin(anguloPunto) * radioPunto;
      if (indicePunta == 0) {
        caminoEstrella.moveTo(x, y);
      } else {
        caminoEstrella.lineTo(x, y);
      }
    }
    caminoEstrella.close();
    canvas.drawPath(
      caminoEstrella,
      Paint()..color = PaletaCosmoSovietica.rojoOficial,
    );
    canvas.drawPath(
      caminoEstrella,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _PintorMedallaSoviet viejo) =>
      viejo.faseCelebracion != faseCelebracion;
}
