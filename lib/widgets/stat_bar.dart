import 'package:flutter/material.dart';
import '../theme.dart';

class BarraEstado extends StatelessWidget {
  final String etiqueta;
  final int valorActual;
  final int valorMaximo;
  final Color colorRelleno;
  final double ancho;

  const BarraEstado({
    super.key,
    required this.etiqueta,
    required this.valorActual,
    required this.valorMaximo,
    required this.colorRelleno,
    this.ancho = 200,
  });

  @override
  Widget build(BuildContext context) {
    final proporcion = valorMaximo == 0
        ? 0.0
        : (valorActual / valorMaximo).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(etiqueta, style: TipografiaPropaganda.etiquetaBurocratica),
            Text(
              '$valorActual / $valorMaximo',
              style: TipografiaPropaganda.etiquetaBurocratica,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: ancho,
          height: 18,
          decoration: BoxDecoration(
            color: PaletaCosmoSovietica.papelSombra,
            border: Border.all(
              color: PaletaCosmoSovietica.tintaNegra,
              width: 2,
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: proporcion,
              child: Container(color: colorRelleno),
            ),
          ),
        ),
      ],
    );
  }
}
