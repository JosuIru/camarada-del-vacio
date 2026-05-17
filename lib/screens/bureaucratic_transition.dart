import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../utilities/page_transitions.dart';
import '../widgets/paper_background.dart';
import '../widgets/propaganda_button.dart';

class PantallaTransicionBurocratica extends StatefulWidget {
  final String codigoInforme;
  final String tituloInforme;
  final String cuerpoInforme;
  final String selloFinal;
  final Widget pantallaDestino;

  const PantallaTransicionBurocratica({
    super.key,
    required this.codigoInforme,
    required this.tituloInforme,
    required this.cuerpoInforme,
    required this.selloFinal,
    required this.pantallaDestino,
  });

  @override
  State<PantallaTransicionBurocratica> createState() =>
      _PantallaTransicionBurocraticaState();
}

class _PantallaTransicionBurocraticaState
    extends State<PantallaTransicionBurocratica>
    with SingleTickerProviderStateMixin {
  int caracteresMostrados = 0;
  bool texturaCompleta = false;
  late Timer temporizadorTipeo;
  late AnimationController controladorSello;

  @override
  void initState() {
    super.initState();
    controladorSello = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    temporizadorTipeo = Timer.periodic(
      const Duration(milliseconds: 18),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (caracteresMostrados >= widget.cuerpoInforme.length) {
          timer.cancel();
          setState(() {
            texturaCompleta = true;
          });
          Future.delayed(const Duration(milliseconds: 150), () {
            if (!mounted) return;
            controladorSello.forward();
          });
        } else {
          setState(() {
            caracteresMostrados += 1;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    temporizadorTipeo.cancel();
    controladorSello.dispose();
    super.dispose();
  }

  void _saltarAlSiguiente() {
    Navigator.of(context).pushReplacement(
      crearRutaConTransicion(widget.pantallaDestino),
    );
  }

  void _saltarTipeo() {
    if (texturaCompleta) return;
    temporizadorTipeo.cancel();
    setState(() {
      caracteresMostrados = widget.cuerpoInforme.length;
      texturaCompleta = true;
    });
    controladorSello.forward();
  }

  double _curvaEstampado(double t) {
    if (t < 0.55) {
      final fragmento = t / 0.55;
      return 2.2 - 1.0 * fragmento;
    }
    final fragmento = (t - 0.55) / 0.45;
    final rebote = math.sin(fragmento * math.pi * 2) * 0.08 * (1 - fragmento);
    return 1.2 - 0.2 * fragmento + rebote;
  }

  String _textoSelloCircular(String selloFinal) {
    return '★ ${selloFinal.toUpperCase()} ★ ${selloFinal.toUpperCase()} ';
  }

  @override
  Widget build(BuildContext context) {
    final fragmento =
        widget.cuerpoInforme.substring(0, caracteresMostrados);
    return Scaffold(
      body: FondoPapelViejo(
        densidadMotas: 320,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: GestureDetector(
              onTap: _saltarTipeo,
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: PaletaCosmoSovietica.papelViejo,
                  border: Border.all(
                    color: PaletaCosmoSovietica.tintaNegra,
                    width: 3,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: PaletaCosmoSovietica.tintaNegra,
                      offset: Offset(6, 6),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.codigoInforme.toUpperCase(),
                              style: TipografiaPropaganda.etiquetaBurocratica,
                            ),
                            Text(
                              'PRAVDA-12 · CONFIDENCIAL',
                              style: TipografiaPropaganda.etiquetaBurocratica
                                  .copyWith(
                                color: PaletaCosmoSovietica.tintaTenue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Divider(
                          color: PaletaCosmoSovietica.tintaNegra,
                          thickness: 1,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          widget.tituloInforme,
                          style: TipografiaPropaganda.tituloSeccion,
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            '$fragmento${texturaCompleta ? '' : '▍'}',
                            style: const TextStyle(
                              fontFamily: TipografiaPropaganda
                                  .familiaMonoespaciada,
                              fontSize: 15,
                              height: 1.55,
                              color: PaletaCosmoSovietica.tintaNegra,
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        if (texturaCompleta)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.selloFinal.toUpperCase(),
                                style: TipografiaPropaganda
                                    .etiquetaBurocratica
                                    .copyWith(
                                  color: PaletaCosmoSovietica.rojoOficial,
                                ),
                              ),
                              BotonPropaganda(
                                texto: 'Visado · Continuar',
                                destacado: true,
                                onPressed: _saltarAlSiguiente,
                              ),
                            ],
                          )
                        else
                          const Text(
                            '(Pulsa cualquier punto del informe para saltar el tipeo.)',
                            style: TipografiaPropaganda.subtitulo,
                          ),
                      ],
                    ),
                    if (controladorSello.isAnimating ||
                        controladorSello.isCompleted)
                      Positioned(
                        right: -28,
                        top: 36,
                        child: AnimatedBuilder(
                          animation: controladorSello,
                          builder: (contexto, _) {
                            final t = controladorSello.value;
                            final escala = _curvaEstampado(t);
                            final opacidad = (t * 1.4).clamp(0.0, 1.0);
                            final tembleque =
                                math.sin(t * math.pi * 6) * (1 - t) * 0.05;
                            final inclinacion = -0.32 + tembleque;
                            return Opacity(
                              opacity: opacidad,
                              child: Transform.rotate(
                                angle: inclinacion,
                                child: Transform.scale(
                                  scale: escala,
                                  child: CustomPaint(
                                    size: const Size(170, 170),
                                    painter: _PintorSelloOficial(
                                      textoCircular: _textoSelloCircular(
                                          widget.selloFinal),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PintorSelloOficial extends CustomPainter {
  final String textoCircular;
  _PintorSelloOficial({required this.textoCircular});

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final radioExterior = size.width / 2 - 6;

    final pincelTrazo = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial.withValues(alpha: 0.82)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Aros del sello: exterior, doble y un anillo de relleno bajo el texto.
    canvas.drawCircle(centro, radioExterior, pincelTrazo);
    canvas.drawCircle(centro, radioExterior - 6, pincelTrazo..strokeWidth = 2);
    canvas.drawCircle(centro, radioExterior - 22, pincelTrazo..strokeWidth = 2);

    // Salpicaduras irregulares para sensación de tinta desigual.
    final aleatorio = math.Random(7);
    for (int indice = 0; indice < 24; indice++) {
      final angulo = aleatorio.nextDouble() * math.pi * 2;
      final radioPunto = radioExterior * (0.45 + aleatorio.nextDouble() * 0.55);
      final centroPunto = Offset(
        centro.dx + math.cos(angulo) * radioPunto,
        centro.dy + math.sin(angulo) * radioPunto,
      );
      canvas.drawCircle(
        centroPunto,
        0.6 + aleatorio.nextDouble() * 1.4,
        Paint()
          ..color = PaletaCosmoSovietica.rojoOficial
              .withValues(alpha: 0.45 + aleatorio.nextDouble() * 0.35),
      );
    }

    // Texto curvado alrededor del aro intermedio.
    _pintarTextoCircular(
      canvas,
      centro,
      radioExterior - 14,
      textoCircular,
      PaletaCosmoSovietica.rojoOficial.withValues(alpha: 0.92),
    );

    // Estrella central.
    final puntos = 5;
    final pathEstrella = Path();
    final radioEstrella = radioExterior * 0.38;
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
      Paint()
        ..color = PaletaCosmoSovietica.rojoOficial.withValues(alpha: 0.82)
        ..style = PaintingStyle.fill,
    );
  }

  void _pintarTextoCircular(
    Canvas canvas,
    Offset centro,
    double radio,
    String texto,
    Color color,
  ) {
    const tamanoFuente = 11.0;
    final caracteres = texto.split('');
    final pasoAngular = (math.pi * 2) / caracteres.length;
    for (int indice = 0; indice < caracteres.length; indice++) {
      final angulo = -math.pi / 2 + indice * pasoAngular;
      final caracter = caracteres[indice];
      final pintorCaracter = TextPainter(
        text: TextSpan(
          text: caracter,
          style: TextStyle(
            fontFamily: TipografiaPropaganda.familiaPrincipal,
            fontSize: tamanoFuente,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.translate(
        centro.dx + math.cos(angulo) * radio,
        centro.dy + math.sin(angulo) * radio,
      );
      canvas.rotate(angulo + math.pi / 2);
      pintorCaracter.paint(
        canvas,
        Offset(-pintorCaracter.width / 2, -pintorCaracter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PintorSelloOficial viejo) =>
      viejo.textoCircular != textoCircular;
}
