import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

class MarcadorInteraccion extends StatefulWidget {
  final double tamano;

  /// Cuando vale `true`, el marcador añade una pequeña insignia con la tecla
  /// «E» debajo, indicando que el peón está dentro del rango de interacción
  /// y puede dispararla con teclado.
  final bool mostrarTeclaInteraccion;

  /// Texto opcional de acción que aparece bajo el marcador cuando el cadete
  /// está dentro del radio. Por defecto "TRAMITAR" — los escenarios pueden
  /// personalizarlo con "HABLAR", "EXAMINAR", "ABRIR", etc.
  final String etiquetaAccion;

  const MarcadorInteraccion({
    super.key,
    this.tamano = 36,
    this.mostrarTeclaInteraccion = false,
    this.etiquetaAccion = 'TRAMITAR',
  });

  @override
  State<MarcadorInteraccion> createState() => _MarcadorInteraccionState();
}

class _MarcadorInteraccionState extends State<MarcadorInteraccion>
    with SingleTickerProviderStateMixin {
  late AnimationController controlador;

  @override
  void initState() {
    super.initState();
    controlador = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controlador,
      builder: (contexto, _) {
        final fase = controlador.value;
        final flotacion = math.sin(fase * math.pi * 2) * 3;
        final escala = 1.0 + math.sin(fase * math.pi * 2) * 0.12;
        return Transform.translate(
          offset: Offset(0, flotacion),
          child: Transform.scale(
            scale: escala,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: widget.tamano,
                  height: widget.tamano,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: PaletaCosmoSovietica.rojoOficial,
                  ),
                  child: Text(
                    '!',
                    style: TextStyle(
                      fontFamily: TipografiaPropaganda.familiaPrincipal,
                      fontSize: widget.tamano * 0.7,
                      fontWeight: FontWeight.bold,
                      color: PaletaCosmoSovietica.papelViejo,
                      height: 1.0,
                    ),
                  ),
                ),
                if (widget.mostrarTeclaInteraccion) ...[
                  SizedBox(height: widget.tamano * 0.18),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.tamano * 0.32,
                      vertical: widget.tamano * 0.12,
                    ),
                    decoration: BoxDecoration(
                      color: PaletaCosmoSovietica.papelViejo,
                      border: Border.all(
                        color: PaletaCosmoSovietica.tintaNegra,
                        width: 1.8,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: PaletaCosmoSovietica.tintaNegra,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.etiquetaAccion,
                          style: TextStyle(
                            fontFamily: TipografiaPropaganda.familiaPrincipal,
                            fontSize: widget.tamano * 0.48,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: PaletaCosmoSovietica.rojoOficial,
                            letterSpacing: widget.tamano * 0.08,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(height: widget.tamano * 0.06),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: widget.tamano * 0.18,
                                vertical: widget.tamano * 0.04,
                              ),
                              decoration: BoxDecoration(
                                color: PaletaCosmoSovietica.tintaNegra,
                              ),
                              child: Text(
                                'E',
                                style: TextStyle(
                                  fontFamily:
                                      TipografiaPropaganda.familiaMonoespaciada,
                                  fontSize: widget.tamano * 0.34,
                                  fontWeight: FontWeight.bold,
                                  color: PaletaCosmoSovietica.papelViejo,
                                  height: 1.0,
                                ),
                              ),
                            ),
                            SizedBox(width: widget.tamano * 0.14),
                            Text(
                              'pulsar',
                              style: TextStyle(
                                fontFamily:
                                    TipografiaPropaganda.familiaPrincipal,
                                fontSize: widget.tamano * 0.30,
                                fontStyle: FontStyle.italic,
                                color: PaletaCosmoSovietica.tintaTenue,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
