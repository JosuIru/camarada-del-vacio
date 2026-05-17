import 'package:flutter/material.dart';

/// Tipo de animación del cadete en combate. Cada tipo cicla 3 frames
/// PNG del set de acción correspondiente.
enum TipoAnimacionCadete {
  /// `cadete_celebra_f01..f03` — brazos arriba, saltitos. Para
  /// victorias, subidas de nivel, insignias.
  celebra,

  /// `cadete_grito_marcial_f01..f03` — grito de combate al iniciar
  /// turno o un encuentro.
  gritoMarcial,

  /// `cadete_sabotaje_f01..f03` — gesto de sabotaje (Ingeniera).
  sabotaje,

  /// `cadete_sello_decreto_f01..f03` — estampar sello (Comisario).
  selloDecreto,
}

String _prefijoAssetParaTipo(TipoAnimacionCadete tipo) {
  switch (tipo) {
    case TipoAnimacionCadete.celebra:
      return 'cadete_celebra';
    case TipoAnimacionCadete.gritoMarcial:
      return 'cadete_grito_marcial';
    case TipoAnimacionCadete.sabotaje:
      return 'cadete_sabotaje';
    case TipoAnimacionCadete.selloDecreto:
      return 'cadete_sello_decreto';
  }
}

/// Cicla los 3 frames PNG de una animación de combate del cadete.
/// Mantiene el ciclo mientras el widget esté montado; al desmontarse
/// libera su controlador. Si `unaSolaVez` está activo, recorre los
/// frames una vez y se queda en el último.
class AnimacionCadeteCombate extends StatefulWidget {
  final TipoAnimacionCadete tipo;
  final Duration duracionPorFrame;
  final bool unaSolaVez;

  const AnimacionCadeteCombate({
    super.key,
    required this.tipo,
    this.duracionPorFrame = const Duration(milliseconds: 220),
    this.unaSolaVez = false,
  });

  @override
  State<AnimacionCadeteCombate> createState() =>
      _AnimacionCadeteCombateState();
}

class _AnimacionCadeteCombateState extends State<AnimacionCadeteCombate>
    with SingleTickerProviderStateMixin {
  late final AnimationController controladorCiclo;
  static const int totalFrames = 3;

  @override
  void initState() {
    super.initState();
    controladorCiclo = AnimationController(
      vsync: this,
      duration: widget.duracionPorFrame * totalFrames,
    );
    if (widget.unaSolaVez) {
      controladorCiclo.forward();
    } else {
      controladorCiclo.repeat();
    }
  }

  @override
  void dispose() {
    controladorCiclo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String prefijo = _prefijoAssetParaTipo(widget.tipo);
    return AnimatedBuilder(
      animation: controladorCiclo,
      builder: (contexto, _) {
        int indiceFrame;
        if (widget.unaSolaVez) {
          indiceFrame =
              (controladorCiclo.value * totalFrames).floor().clamp(0, 2);
        } else {
          indiceFrame =
              (controladorCiclo.value * totalFrames).floor() % totalFrames;
          if (indiceFrame < 0) indiceFrame = 0;
        }
        return Image.asset(
          'assets/images/${prefijo}_f0${indiceFrame + 1}.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        );
      },
    );
  }
}
