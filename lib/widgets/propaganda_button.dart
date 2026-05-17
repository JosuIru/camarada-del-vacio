import 'package:flutter/material.dart';
import '../theme.dart';
import '../utilities/audio_procedural.dart';

class BotonPropaganda extends StatefulWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool destacado;
  final bool compacto;

  const BotonPropaganda({
    super.key,
    required this.texto,
    required this.onPressed,
    this.destacado = false,
    this.compacto = false,
  });

  @override
  State<BotonPropaganda> createState() => _BotonPropagandaState();
}

class _BotonPropagandaState extends State<BotonPropaganda> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final habilitado = widget.onPressed != null;
    final colorFondo = widget.destacado
        ? (habilitado
            ? PaletaCosmoSovietica.rojoOficial
            : PaletaCosmoSovietica.rojoSombra.withValues(alpha: 0.4))
        : (habilitado
            ? PaletaCosmoSovietica.papelViejo
            : PaletaCosmoSovietica.papelSombra);

    final colorTexto = widget.destacado
        ? PaletaCosmoSovietica.papelViejo
        : (habilitado
            ? PaletaCosmoSovietica.tintaNegra
            : PaletaCosmoSovietica.tintaTenue);

    return MouseRegion(
      cursor: habilitado
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed == null
            ? null
            : () {
                audioProcedural.despertarSiNecesario();
                audioProcedural.reproducirClickBoton();
                widget.onPressed!();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: EdgeInsets.symmetric(
            horizontal: widget.compacto ? 14 : 22,
            vertical: widget.compacto ? 8 : 14,
          ),
          decoration: BoxDecoration(
            color: colorFondo,
            border: Border.all(
              color: PaletaCosmoSovietica.tintaNegra,
              width: _hover && habilitado ? 3 : 2,
            ),
            boxShadow: _hover && habilitado
                ? const [
                    BoxShadow(
                      color: PaletaCosmoSovietica.tintaNegra,
                      offset: Offset(3, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.texto.toUpperCase(),
            style: TipografiaPropaganda.etiquetaBurocratica.copyWith(
              fontSize: widget.compacto ? 11 : 13,
              color: colorTexto,
            ),
          ),
        ),
      ),
    );
  }
}
